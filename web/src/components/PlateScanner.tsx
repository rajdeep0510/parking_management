"use client";

import { useEffect, useRef, useState, useCallback, useMemo } from "react";
import Link from "next/link";
import { createWorker, Worker } from "tesseract.js";
import { extractPlateNumber, preprocessCanvasForOcr, playSuccessChime, formatPlateAsYouType } from "@/lib/anpr";
import { Icon } from "./Icon";
import { LicensePlate } from "./LicensePlate";

export type GateOption = {
  value: number;
  label: string;
  gate_type: "ENTRY" | "EXIT";
  gate_number: string;
  zone_name: string;
};

type TypeOption = { value: number; label: string };

type SessionActivity = {
  id: string;
  action: "ENTRY" | "EXIT";
  ticketNo: number;
  registrationNo: string;
  scannedReg?: string;
  slotNo: string;
  zoneName: string;
  time: string;
  status: "SUCCESS" | "ALREADY_PARKED" | "NOT_PARKED" | "NO_SLOTS";
  amountPaid?: number;
  isNewVehicle?: boolean;
  matchType?: "EXACT" | "FUZZY" | "DIRECT";
  matchConfidence?: number;
  suggestions?: { ticket_no: number; registration_no: string; slot_no: string; similarity: number }[];
};

export function PlateScanner({
  gates,
  vehicleTypes,
  initialMode = "ENTRY",
  initialGateId,
}: {
  gates: GateOption[];
  vehicleTypes: TypeOption[];
  initialMode?: "ENTRY" | "EXIT";
  initialGateId?: number;
}) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const hiddenCanvasRef = useRef<HTMLCanvasElement>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const workerRef = useRef<Worker | null>(null);

  // Gate & Mode States
  const [gateMode, setGateMode] = useState<"ENTRY" | "EXIT">(initialMode);

  const entryGates = useMemo(() => gates.filter((g) => g.gate_type === "ENTRY"), [gates]);
  const exitGates = useMemo(() => gates.filter((g) => g.gate_type === "EXIT"), [gates]);
  const currentGates = gateMode === "ENTRY" ? entryGates : exitGates;

  const [selectedGate, setSelectedGate] = useState<number>(() => {
    if (initialGateId && gates.some((g) => g.value === initialGateId)) {
      return initialGateId;
    }
    const matching = initialMode === "ENTRY" ? entryGates : exitGates;
    return matching[0]?.value ?? gates[0]?.value ?? 0;
  });

  const [selectedType, setSelectedType] = useState<number>(vehicleTypes[0]?.value ?? 1);
  const [autoSave, setAutoSave] = useState<boolean>(true);
  const [isScanning, setIsScanning] = useState<boolean>(true);
  const [devices, setDevices] = useState<MediaDeviceInfo[]>([]);
  const [selectedDeviceId, setSelectedDeviceId] = useState<string>("");
  const [cameraError, setCameraError] = useState<string | null>(null);
  const [ocrStatus, setOcrStatus] = useState<string>("Initializing OCR engine…");
  const [candidatePlate, setCandidatePlate] = useState<string | null>(null);
  const [processing, setProcessing] = useState<boolean>(false);
  const [flashSuccess, setFlashSuccess] = useState<boolean>(false);
  const [recentActivities, setRecentActivities] = useState<SessionActivity[]>([]);

  // Manual plate input field for testing without camera
  const [manualPlate, setManualPlate] = useState<string>("");

  // Cooldown map: plate -> timestamp
  const cooldownRef = useRef<Map<string, number>>(new Map());

  // Switch gate mode and pick first active gate of that type
  const handleModeChange = (mode: "ENTRY" | "EXIT") => {
    setGateMode(mode);
    const targetGates = mode === "ENTRY" ? entryGates : exitGates;
    if (targetGates.length > 0) {
      setSelectedGate(targetGates[0].value);
    }
    setOcrStatus(
      mode === "ENTRY"
        ? "🟢 Ready for ENTRY: Scanning plate will allocate & FILL slot (OCCUPIED)."
        : "🔴 Ready for EXIT: Scanning plate will calculate fee & EMPTY slot (AVAILABLE)."
    );
  };

  // 1. Initialize Tesseract Worker
  useEffect(() => {
    let isMounted = true;
    (async () => {
      try {
        setOcrStatus("Loading OCR models…");
        const worker = await createWorker("eng");
        await worker.setParameters({
          tessedit_char_whitelist: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ- ",
          tessedit_pageseg_mode: "7" as unknown as never,
        });
        if (isMounted) {
          workerRef.current = worker;
          setOcrStatus(
            gateMode === "ENTRY"
              ? "🟢 Ready. Point camera at number plate to check-in (fills slot)."
              : "🔴 Ready. Point camera at number plate to check-out (empties slot)."
          );
        } else {
          await worker.terminate();
        }
      } catch (err) {
        console.error("Failed to load OCR worker:", err);
        setOcrStatus("OCR engine error. Try manual capture or image upload.");
      }
    })();

    return () => {
      isMounted = false;
      if (workerRef.current) {
        workerRef.current.terminate();
        workerRef.current = null;
      }
    };
  }, []);

  // 2. Enumerate Cameras
  useEffect(() => {
    async function getCameras() {
      try {
        const mediaDevices = await navigator.mediaDevices.enumerateDevices();
        const videoInputs = mediaDevices.filter((d) => d.kind === "videoinput");
        setDevices(videoInputs);
        if (videoInputs.length > 0 && !selectedDeviceId) {
          const backCam = videoInputs.find((d) => /back|rear|environment/i.test(d.label));
          setSelectedDeviceId(backCam ? backCam.deviceId : videoInputs[0].deviceId);
        }
      } catch {
        // Enumerate may fail before permissions granted
      }
    }
    getCameras();
  }, [selectedDeviceId]);

  // 3. Start Camera Stream
  useEffect(() => {
    let stream: MediaStream | null = null;
    let cancelled = false;

    async function startCamera() {
      setCameraError(null);
      try {
        const constraints: MediaStreamConstraints = {
          video: selectedDeviceId
            ? { deviceId: { exact: selectedDeviceId } }
            : { facingMode: { ideal: "environment" }, width: { ideal: 1280 } },
        };
        const s = await navigator.mediaDevices.getUserMedia(constraints);
        if (cancelled) {
          s.getTracks().forEach((t) => t.stop());
          return;
        }
        stream = s;
        if (videoRef.current) {
          videoRef.current.srcObject = s;
          videoRef.current.play();
        }
      } catch (err) {
        console.error("Camera access error:", err);
        setCameraError(
          "Could not access camera. Please allow camera permissions or test using manual plate input below."
        );
      }
    }

    startCamera();

    return () => {
      cancelled = true;
      if (stream) {
        stream.getTracks().forEach((t) => t.stop());
      }
    };
  }, [selectedDeviceId]);

  // 4. Save Vehicle to Database (Handles both ENTRY and EXIT)
  const submitToDatabase = useCallback(
    async (plate: string) => {
      const cleanPlate = plate.trim().toUpperCase();
      if (!cleanPlate || !selectedGate) return;

      // Check cooldown (skip cooldown if manually typed)
      const now = Date.now();
      const lastScanned = cooldownRef.current.get(cleanPlate) || 0;
      if (now - lastScanned < 15000) {
        setOcrStatus(`Plate ${cleanPlate} was processed recently. Cooling down…`);
        return;
      }

      setProcessing(true);
      setOcrStatus(`Processing ${gateMode} for ${cleanPlate}…`);

      try {
        if (gateMode === "ENTRY") {
          // ================= ENTRY SCAN LOGIC =================
          const res = await fetch("/api/anpr/entry", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              registration_no: cleanPlate,
              entry_gate_id: selectedGate,
              type_id: selectedType,
            }),
          });

          const data = await res.json();
          cooldownRef.current.set(cleanPlate, now);

          if (data.success && data.data) {
            playSuccessChime();
            setFlashSuccess(true);
            setTimeout(() => setFlashSuccess(false), 900);

            const activity: SessionActivity = {
              id: String(Date.now()),
              action: "ENTRY",
              ticketNo: data.data.ticketNo,
              registrationNo: data.data.registrationNo,
              slotNo: data.data.slotNo,
              zoneName: data.data.zoneName,
              time: data.data.entryTime,
              status: "SUCCESS",
              isNewVehicle: data.data.isNewVehicle,
            };
            setRecentActivities((prev) => [activity, ...prev.slice(0, 19)]);
            setOcrStatus(
              `✅ ENTRY: Ticket #${data.data.ticketNo} issued! Slot ${data.data.slotNo} is now FILLED (OCCUPIED).`
            );
          } else if (data.status === "ALREADY_PARKED") {
            const activity: SessionActivity = {
              id: String(Date.now()),
              action: "ENTRY",
              ticketNo: data.ticketNo,
              registrationNo: cleanPlate,
              slotNo: data.slotNo,
              zoneName: "Parked",
              time: "Active",
              status: "ALREADY_PARKED",
            };
            setRecentActivities((prev) => [activity, ...prev.slice(0, 19)]);
            setOcrStatus(`⚠️ ${cleanPlate} is ALREADY PARKED (Ticket #${data.ticketNo} in Slot ${data.slotNo}).`);
          } else if (data.status === "NO_SLOTS") {
            setOcrStatus(`❌ Lot is full: No available slots for ${cleanPlate}.`);
          } else {
            setOcrStatus(`Error: ${data.error || "Failed to process entry."}`);
          }
        } else {
          // ================= EXIT SCAN LOGIC =================
          const res = await fetch("/api/anpr/exit", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              registration_no: cleanPlate,
              exit_gate_id: selectedGate,
            }),
          });

          const data = await res.json();
          cooldownRef.current.set(cleanPlate, now);

          if (data.success && data.data) {
            playSuccessChime();
            setFlashSuccess(true);
            setTimeout(() => setFlashSuccess(false), 900);

            const activity: SessionActivity = {
              id: String(Date.now()),
              action: "EXIT",
              ticketNo: data.data.ticketNo,
              registrationNo: data.data.registrationNo,
              scannedReg: data.data.scannedReg,
              slotNo: data.data.slotNo,
              zoneName: data.data.zoneName,
              time: data.data.exitTime,
              status: "SUCCESS",
              amountPaid: data.data.totalAmount,
              matchType: data.data.matchType,
              matchConfidence: data.data.matchConfidence,
            };
            setRecentActivities((prev) => [activity, ...prev.slice(0, 19)]);
            const matchMsg =
              data.data.matchType === "FUZZY"
                ? ` (Fuzzy matched from "${cleanPlate}" with ${data.data.matchConfidence}% confidence)`
                : "";
            setOcrStatus(
              `🚗💨 EXIT: Vehicle ${data.data.registrationNo}${matchMsg} exited! Slot ${data.data.slotNo} is now EMPTY (AVAILABLE). Fee: ₹${data.data.totalAmount}.`
            );
          } else if (data.status === "NOT_PARKED") {
            const activity: SessionActivity = {
              id: String(Date.now()),
              action: "EXIT",
              ticketNo: 0,
              registrationNo: cleanPlate,
              slotNo: "—",
              zoneName: "Not in lot",
              time: "Now",
              status: "NOT_PARKED",
              suggestions: data.suggestions || [],
            };
            setRecentActivities((prev) => [activity, ...prev.slice(0, 19)]);
            setOcrStatus(`⚠️ Cannot exit: ${cleanPlate} not found. Check suggestions below.`);
          } else {
            setOcrStatus(`Error: ${data.error || "Failed to process exit."}`);
          }
        }
      } catch (err) {
        console.error("API error:", err);
        setOcrStatus("Failed to contact parking database API.");
      } finally {
        setProcessing(false);
      }
    },
    [gateMode, selectedGate, selectedType]
  );

  // Directly exit a ticket (e.g. from suggestion or manual selection)
  const submitExitByTicket = useCallback(
    async (ticketNo: number) => {
      if (!ticketNo || !selectedGate) return;
      setProcessing(true);
      setOcrStatus(`Processing checkout for Ticket #${ticketNo}…`);
      try {
        const res = await fetch("/api/anpr/exit", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            ticket_no: ticketNo,
            exit_gate_id: selectedGate,
          }),
        });
        const data = await res.json();
        if (data.success && data.data) {
          playSuccessChime();
          setFlashSuccess(true);
          setTimeout(() => setFlashSuccess(false), 900);
          const activity: SessionActivity = {
            id: String(Date.now()),
            action: "EXIT",
            ticketNo: data.data.ticketNo,
            registrationNo: data.data.registrationNo,
            slotNo: data.data.slotNo,
            zoneName: data.data.zoneName,
            time: data.data.exitTime,
            status: "SUCCESS",
            amountPaid: data.data.totalAmount,
            matchType: "DIRECT",
          };
          setRecentActivities((prev) => [activity, ...prev.slice(0, 19)]);
          setOcrStatus(
            `🚗💨 EXIT: Vehicle ${data.data.registrationNo} exited! Slot ${data.data.slotNo} is now EMPTY (AVAILABLE). Fee: ₹${data.data.totalAmount}.`
          );
        } else {
          setOcrStatus(`Error: ${data.error || data.message || "Checkout failed."}`);
        }
      } catch (err) {
        console.error("Exit by ticket error:", err);
        setOcrStatus("Failed to process checkout.");
      } finally {
        setProcessing(false);
      }
    },
    [selectedGate]
  );

  // 5. Run Recognition on Current Frame
  const analyzeFrame = useCallback(async () => {
    if (!videoRef.current || !workerRef.current || processing) return;
    const video = videoRef.current;
    if (video.videoWidth === 0 || video.videoHeight === 0) return;

    const canvas = hiddenCanvasRef.current || document.createElement("canvas");
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    ctx.drawImage(video, 0, 0, canvas.width, canvas.height);

    const cropWidth = canvas.width * 0.65;
    const cropHeight = canvas.height * 0.28;
    const cropX = (canvas.width - cropWidth) / 2;
    const cropY = (canvas.height - cropHeight) / 2;

    const preprocessed = preprocessCanvasForOcr(canvas, {
      x: cropX,
      y: cropY,
      width: cropWidth,
      height: cropHeight,
    });

    try {
      const { data } = await workerRef.current.recognize(preprocessed);
      const extracted = extractPlateNumber(data.text);

      if (extracted && extracted.isValid) {
        setCandidatePlate(extracted.plate);
        setOcrStatus(`Plate detected: ${extracted.plate} (${extracted.format})`);

        if (autoSave) {
          await submitToDatabase(extracted.plate);
        }
      }
    } catch (err) {
      console.warn("OCR frame warning:", err);
    }
  }, [processing, autoSave, submitToDatabase]);

  // 6. Continuous Auto-Scan Loop
  useEffect(() => {
    if (!isScanning) return;

    const interval = setInterval(() => {
      if (!processing) {
        analyzeFrame();
      }
    }, 650);

    return () => clearInterval(interval);
  }, [isScanning, processing, analyzeFrame]);

  // 7. Handle Image Upload
  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file || !workerRef.current) return;

    setProcessing(true);
    setOcrStatus(`Analyzing uploaded photo ${file.name}…`);

    const img = new Image();
    img.src = URL.createObjectURL(file);
    img.onload = async () => {
      try {
        const { data } = await workerRef.current!.recognize(img);
        const extracted = extractPlateNumber(data.text);
        if (extracted && extracted.isValid) {
          setCandidatePlate(extracted.plate);
          setOcrStatus(`Found plate: ${extracted.plate}`);
          if (autoSave) {
            await submitToDatabase(extracted.plate);
          }
        } else {
          setOcrStatus(`Could not detect plate. Text found: "${data.text.trim()}"`);
        }
      } catch (err) {
        console.error("Uploaded image OCR failed:", err);
        setOcrStatus("Failed to read text from uploaded image.");
      } finally {
        setProcessing(false);
        URL.revokeObjectURL(img.src);
      }
    };
  };

  const handleManualSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!manualPlate.trim()) return;
    submitToDatabase(manualPlate.trim());
    setManualPlate("");
  };

  const isEntry = gateMode === "ENTRY";

  return (
    <div className="space-y-6">
      {/* Station Header & Mode Selector */}
      <div className="rounded-2xl border border-border bg-surface p-4 sm:p-5 shadow-xs">
        <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <div className="text-xs font-semibold uppercase tracking-wider text-muted">
              Select Gate Station Mode
            </div>
            <p className="text-sm text-muted mt-0.5">
              {isEntry
                ? "🟢 ENTRY GATE: Incoming vehicles are assigned a slot. Slot status changes to OCCUPIED."
                : "🔴 EXIT GATE: Outgoing vehicles pay fare. Slot status changes to AVAILABLE (EMPTY)."}
            </p>
          </div>

          {/* Mode Switcher Tabs */}
          <div className="inline-flex rounded-xl bg-surface-2 p-1 border border-border shrink-0">
            <button
              type="button"
              onClick={() => handleModeChange("ENTRY")}
              className={`flex items-center gap-2 rounded-lg px-4 py-2 text-xs font-bold transition cursor-pointer ${
                isEntry
                  ? "bg-emerald-500 text-white shadow-xs"
                  : "text-muted hover:text-foreground"
              }`}
            >
              <span className={`h-2.5 w-2.5 rounded-full ${isEntry ? "bg-white" : "bg-emerald-500"}`} />
              ENTRY GATE (Fills Slot)
            </button>
            <button
              type="button"
              onClick={() => handleModeChange("EXIT")}
              className={`flex items-center gap-2 rounded-lg px-4 py-2 text-xs font-bold transition cursor-pointer ${
                !isEntry
                  ? "bg-rose-500 text-white shadow-xs"
                  : "text-muted hover:text-foreground"
              }`}
            >
              <span className={`h-2.5 w-2.5 rounded-full ${!isEntry ? "bg-white" : "bg-rose-500"}`} />
              EXIT GATE (Empties Slot)
            </button>
          </div>
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-3">
        {/* Hidden processing canvas */}
        <canvas ref={hiddenCanvasRef} className="hidden" />

        {/* Main Scanner Section */}
        <div className="space-y-4 lg:col-span-2">
          <div
            className={`card relative overflow-hidden p-0 transition-all duration-300 ${
              flashSuccess
                ? isEntry
                  ? "ring-4 ring-emerald-500 shadow-lg shadow-emerald-500/20"
                  : "ring-4 ring-rose-500 shadow-lg shadow-rose-500/20"
                : ""
            }`}
          >
            {/* Camera Viewport with Futuristic HUD */}
            <div className="relative aspect-video w-full bg-slate-950 overflow-hidden select-none">
              <video
                ref={videoRef}
                playsInline
                muted
                autoPlay
                className="h-full w-full object-cover"
              />

              {/* HUD Top Bar: Recording & Telemetry */}
              <div className="absolute top-3 inset-x-3 z-10 flex items-center justify-between text-white text-[11px] font-mono pointer-events-none">
                <div className="flex items-center gap-2">
                  <span
                    className={`inline-flex items-center gap-1.5 rounded-md px-2.5 py-1 text-xs font-bold tracking-wide shadow-md backdrop-blur-md ${
                      isEntry
                        ? "bg-emerald-600/90 text-white border border-emerald-400/40"
                        : "bg-rose-600/90 text-white border border-rose-400/40"
                    }`}
                  >
                    <Icon name="gate" className="h-3.5 w-3.5" />
                    {isEntry ? "ENTRY TERMINAL" : "EXIT TERMINAL"}
                  </span>

                  <span className="hidden sm:inline-flex items-center gap-1.5 rounded-md bg-black/60 px-2 py-1 backdrop-blur-md text-emerald-400 border border-white/10">
                    <span className="h-2 w-2 rounded-full bg-rose-500 animate-pulse" />
                    LIVE REC · 30 FPS
                  </span>
                </div>

                <div className="flex items-center gap-2 text-white/80">
                  <span className="rounded bg-black/60 px-2 py-1 backdrop-blur-md border border-white/10 hidden min-[480px]:inline-block">
                    OPTICAL ANPR · HD
                  </span>
                </div>
              </div>

              {/* Futuristic Viewfinder Targeting Reticle */}
              <div className="pointer-events-none absolute inset-0 flex flex-col items-center justify-center">
                <div
                  className={`relative h-[34%] w-[72%] rounded-xl border-2 transition-all duration-200 backdrop-blur-[0.5px] ${
                    candidatePlate
                      ? isEntry
                        ? "border-emerald-400 bg-emerald-500/10 shadow-[0_0_25px_rgba(16,185,129,0.4)]"
                        : "border-rose-400 bg-rose-500/10 shadow-[0_0_25px_rgba(244,63,94,0.4)]"
                      : isEntry
                      ? "border-emerald-400/60 border-dashed bg-emerald-500/[0.03]"
                      : "border-rose-400/60 border-dashed bg-rose-500/[0.03]"
                  }`}
                >
                  {/* Precision Reticle Corner Brackets */}
                  <div className={`absolute -left-1 -top-1 h-5 w-5 border-l-[3px] border-t-[3px] ${isEntry ? "border-emerald-400" : "border-rose-400"}`} />
                  <div className={`absolute -right-1 -top-1 h-5 w-5 border-r-[3px] border-t-[3px] ${isEntry ? "border-emerald-400" : "border-rose-400"}`} />
                  <div className={`absolute -bottom-1 -left-1 h-5 w-5 border-b-[3px] border-l-[3px] ${isEntry ? "border-emerald-400" : "border-rose-400"}`} />
                  <div className={`absolute -bottom-1 -right-1 h-5 w-5 border-b-[3px] border-r-[3px] ${isEntry ? "border-emerald-400" : "border-rose-400"}`} />

                  {/* Center HUD Crosshair */}
                  <div className="absolute inset-0 flex items-center justify-center opacity-30 text-white font-mono text-xs">
                    <span>+</span>
                  </div>

                  {/* Target Status Tag */}
                  <div className="flex h-full items-center justify-center">
                    {candidatePlate ? (
                      <span className="rounded-md bg-black/80 px-2.5 py-1 text-xs font-mono font-bold uppercase tracking-wider text-emerald-400 border border-emerald-500/50 shadow-lg">
                        🎯 TARGET LOCKED
                      </span>
                    ) : (
                      <span className="rounded bg-black/60 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-wider text-white/90 backdrop-blur-sm">
                        ALIGN LICENSE PLATE HERE
                      </span>
                    )}
                  </div>

                  {/* Animated Laser Scan Beam */}
                  {isScanning && !processing && (
                    <div
                      className={`laser-beam pointer-events-none absolute inset-x-2 h-0.5 rounded-full shadow-md ${
                        isEntry
                          ? "bg-emerald-400 shadow-emerald-400/80"
                          : "bg-rose-400 shadow-rose-400/80"
                      }`}
                      aria-hidden="true"
                    />
                  )}
                </div>
              </div>

              {/* Radar Ripple Animation on Success */}
              {flashSuccess && (
                <div className="pointer-events-none absolute inset-0 flex items-center justify-center">
                  <span
                    className={`h-40 w-40 rounded-full animate-ping opacity-75 ${
                      isEntry ? "bg-emerald-500" : "bg-rose-500"
                    }`}
                  />
                </div>
              )}

              {/* Live Status Overlay Bar */}
              <div className="absolute bottom-0 inset-x-0 bg-gradient-to-t from-black/90 via-black/70 to-transparent p-3.5 text-white">
                <div className="flex flex-wrap items-center justify-between gap-2 text-xs">
                  <span className="flex items-center gap-2">
                    <span
                      className={`h-2.5 w-2.5 rounded-full ${
                        processing
                          ? "animate-ping bg-amber-400"
                          : isScanning
                          ? isEntry
                            ? "animate-pulse bg-emerald-400"
                            : "animate-pulse bg-rose-400"
                          : "bg-gray-400"
                      }`}
                    />
                    <span className="font-mono text-white/90">{ocrStatus}</span>
                  </span>
                  {candidatePlate && (
                    <div className="flex items-center gap-2">
                      <span className="text-[10px] uppercase font-bold text-emerald-400 hidden min-[400px]:inline">
                        Matched:
                      </span>
                      <LicensePlate plate={candidatePlate} size="sm" />
                    </div>
                  )}
                </div>
              </div>
            </div>

            {cameraError && (
              <div className="p-4 border-t border-border bg-surface-2/50">
                <p className="text-xs text-amber-600 dark:text-amber-400 font-medium">
                  {cameraError}
                </p>
              </div>
            )}

            {/* Controls Bar */}
            <div className="flex flex-wrap items-center justify-between gap-3 border-t border-border bg-surface p-3">
              <div className="flex items-center gap-2">
                <button
                  type="button"
                  onClick={() => setIsScanning(!isScanning)}
                  className={`btn text-xs font-semibold ${
                    isScanning
                      ? isEntry
                        ? "border-emerald-500/50 text-emerald-600 dark:text-emerald-400"
                        : "border-rose-500/50 text-rose-600 dark:text-rose-400"
                      : "text-muted"
                  }`}
                >
                  {isScanning ? "● Auto-Detect ON" : "○ Auto-Detect Paused"}
                </button>

                <button
                  type="button"
                  onClick={() => analyzeFrame()}
                  disabled={processing}
                  className="btn text-xs"
                >
                  Snap Frame
                </button>
              </div>

              <div className="flex items-center gap-2">
                <input
                  ref={fileInputRef}
                  type="file"
                  accept="image/*"
                  onChange={handleFileUpload}
                  className="hidden"
                />
                <button
                  type="button"
                  onClick={() => fileInputRef.current?.click()}
                  className="btn text-xs"
                >
                  📁 Test Photo
                </button>

                {candidatePlate && !autoSave && (
                  <button
                    type="button"
                    onClick={() => submitToDatabase(candidatePlate)}
                    disabled={processing}
                    className="btn-primary text-xs"
                  >
                    {isEntry ? "Check-In" : "Check-Out"} #{candidatePlate}
                  </button>
                )}
              </div>
            </div>
          </div>

          {/* Quick Manual Plate Simulation Bar */}
          <div className="card space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-xs font-semibold uppercase tracking-wider text-muted flex items-center gap-1.5">
                <Icon name="car" className="h-4 w-4" />
                Manual Plate Input / Instant Simulation
              </span>
              <span className="text-xs text-muted">Type any plate number to test scan</span>
            </div>

            <form onSubmit={handleManualSubmit} className="flex gap-2">
              <input
                type="text"
                value={manualPlate}
                onChange={(e) => setManualPlate(formatPlateAsYouType(e.target.value))}
                placeholder="e.g. DL-1C-AA-1111, GJ-01-AB-1234"
                maxLength={16}
                autoCapitalize="characters"
                autoComplete="off"
                className="input flex-1 font-mono uppercase tracking-wider font-semibold"
              />
              <button
                type="submit"
                disabled={processing || !manualPlate.trim()}
                className={`btn font-semibold text-xs whitespace-nowrap cursor-pointer ${
                  isEntry
                    ? "bg-emerald-600 text-white hover:bg-emerald-700"
                    : "bg-rose-600 text-white hover:bg-rose-700"
                }`}
              >
                {isEntry ? "Simulate Entry (Fill Slot)" : "Simulate Exit (Empty Slot)"}
              </button>
            </form>
          </div>

          {/* Configuration Card */}
          <div className="card space-y-4">
            <h2 className="text-xs font-semibold uppercase tracking-wider text-muted">
              Active Gate Station Settings
            </h2>

            <div className="grid gap-3 sm:grid-cols-2">
              <label className="block">
                <span className="label">
                  Assigned {isEntry ? "Entry" : "Exit"} Gate *
                </span>
                <select
                  className="input"
                  value={selectedGate}
                  onChange={(e) => setSelectedGate(Number(e.target.value))}
                >
                  {currentGates.map((g) => (
                    <option key={g.value} value={g.value}>
                      {g.label}
                    </option>
                  ))}
                </select>
              </label>

              {isEntry && (
                <label className="block">
                  <span className="label">Default Vehicle Type</span>
                  <select
                    className="input"
                    value={selectedType}
                    onChange={(e) => setSelectedType(Number(e.target.value))}
                  >
                    {vehicleTypes.map((t) => (
                      <option key={t.value} value={t.value}>
                        {t.label}
                      </option>
                    ))}
                  </select>
                </label>
              )}
            </div>

            <div className="grid gap-3 sm:grid-cols-2">
              {devices.length > 1 && (
                <label className="block">
                  <span className="label">Camera Device</span>
                  <select
                    className="input"
                    value={selectedDeviceId}
                    onChange={(e) => setSelectedDeviceId(e.target.value)}
                  >
                    {devices.map((d, idx) => (
                      <option key={d.deviceId || idx} value={d.deviceId}>
                        {d.label || `Camera ${idx + 1}`}
                      </option>
                    ))}
                  </select>
                </label>
              )}

              <div className="flex items-center gap-3 pt-6">
                <label className="flex cursor-pointer items-center gap-2 text-sm font-medium">
                  <input
                    type="checkbox"
                    checked={autoSave}
                    onChange={(e) => setAutoSave(e.target.checked)}
                    className="h-4 w-4 rounded border-border accent-accent"
                  />
                  Auto-process immediately upon camera plate detection
                </label>
              </div>
            </div>
          </div>
        </div>

        {/* Sidebar: Recent Activity & Slot Changes */}
        <div className="space-y-4">
          <div className="card space-y-3">
            <div className="flex items-center justify-between">
              <h2 className="font-semibold text-sm">Gate Activity Feed</h2>
              <span className="badge badge-blue">{recentActivities.length} events</span>
            </div>

            {recentActivities.length === 0 ? (
              <p className="py-6 text-center text-sm text-muted">
                No vehicles scanned this session. Aim camera at a plate or use the manual input above.
              </p>
            ) : (
              <div className="space-y-2.5 max-h-[500px] overflow-y-auto pr-1">
                {recentActivities.map((t) => (
                  <div
                    key={t.id}
                    className="rounded-xl border border-border bg-surface-2/60 p-3 text-xs space-y-2 transition-all duration-150 hover:bg-surface-2 hover:shadow-xs hover:border-accent/30 animate-reveal"
                  >
                    <div className="flex items-center justify-between">
                      <LicensePlate plate={t.registrationNo} ticketNo={t.ticketNo} size="sm" />
                      {t.action === "ENTRY" ? (
                        <span className="inline-flex items-center gap-1 rounded-md bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 px-2 py-0.5 font-semibold text-[11px]">
                          🟢 ENTRY
                        </span>
                      ) : (
                        <span className="inline-flex items-center gap-1 rounded-md bg-rose-500/10 text-rose-600 dark:text-rose-400 px-2 py-0.5 font-semibold text-[11px]">
                          🔴 EXIT
                        </span>
                      )}
                    </div>

                    {t.status === "SUCCESS" && t.action === "ENTRY" && (
                      <div className="space-y-1 text-muted">
                        <div className="flex items-center justify-between">
                          <span>
                            Slot: <strong className="text-foreground">{t.slotNo}</strong> ({t.zoneName})
                          </span>
                          <span className="text-[11px] font-semibold text-rose-500 bg-rose-500/10 px-1.5 py-0.5 rounded">
                            FILLED → OCCUPIED
                          </span>
                        </div>
                        <div className="flex items-center justify-between text-[11px]">
                          <span>Ticket #{t.ticketNo}</span>
                          <Link href="/tickets" className="text-accent hover:underline">
                            View Ticket →
                          </Link>
                        </div>
                      </div>
                    )}

                    {t.status === "SUCCESS" && t.action === "EXIT" && (
                      <div className="space-y-1 text-muted">
                        <div className="flex items-center justify-between">
                          <span>
                            Slot: <strong className="text-foreground">{t.slotNo}</strong> ({t.zoneName})
                          </span>
                          <span className="text-[11px] font-semibold text-emerald-600 dark:text-emerald-400 bg-emerald-500/10 px-1.5 py-0.5 rounded">
                            EMPTIED → AVAILABLE
                          </span>
                        </div>
                        {t.matchType === "FUZZY" && (
                          <div className="text-[11px] text-accent font-medium bg-accent-soft/40 px-2 py-0.5 rounded">
                            ✨ Auto-matched from scan &ldquo;{t.scannedReg}&rdquo; ({t.matchConfidence}% confidence)
                          </div>
                        )}
                        <div className="flex items-center justify-between text-[11px]">
                          <span>Fee: ₹{t.amountPaid}</span>
                          <span className="text-muted">{t.time}</span>
                        </div>
                      </div>
                    )}

                    {t.status === "ALREADY_PARKED" && (
                      <p className="text-[11px] text-amber-600 dark:text-amber-400">
                        Already in Slot {t.slotNo} (Ticket #{t.ticketNo})
                      </p>
                    )}

                    {t.status === "NOT_PARKED" && (
                      <div className="space-y-1.5">
                        <p className="text-[11px] text-rose-500 font-medium">
                          No exact active ticket found for {t.registrationNo}.
                        </p>
                        {t.suggestions && t.suggestions.length > 0 && (
                          <div className="rounded-lg bg-surface p-2 border border-border/80 space-y-1">
                            <span className="text-[10px] uppercase font-semibold text-muted block">
                              Did you mean one of these parked vehicles?
                            </span>
                            {t.suggestions.map((s) => (
                              <button
                                key={s.ticket_no}
                                type="button"
                                onClick={() => submitExitByTicket(s.ticket_no)}
                                className="flex w-full items-center justify-between rounded-md px-2 py-1 bg-surface-2 hover:bg-accent hover:text-white transition text-[11px] text-left cursor-pointer"
                              >
                                <span>
                                  <strong className="font-mono">{s.registration_no}</strong> (Slot {s.slot_no})
                                </span>
                                <span className="font-semibold text-[10px]">
                                  {s.similarity}% match · Exit →
                                </span>
                              </button>
                            ))}
                          </div>
                        )}
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}
          </div>

          <div className="card space-y-2 text-xs text-muted">
            <h3 className="font-semibold text-foreground flex items-center gap-1.5">
              <Icon name="badge" className="h-4 w-4 text-accent" />
              Automated Slot State Logic
            </h3>
            <ul className="space-y-2 list-none pt-1">
              <li className="flex items-start gap-2">
                <span className="h-2 w-2 rounded-full bg-emerald-500 mt-1 shrink-0" />
                <span>
                  <strong>Entry Scan:</strong> Matches plate, allocates best slot in zone, marks slot <code className="text-rose-500 font-bold">OCCUPIED</code>, issues ticket.
                </span>
              </li>
              <li className="flex items-start gap-2">
                <span className="h-2 w-2 rounded-full bg-rose-500 mt-1 shrink-0" />
                <span>
                  <strong>Exit Scan:</strong> Finds active ticket, calculates duration & tariff, completes ticket, and marks slot <code className="text-emerald-500 font-bold">AVAILABLE (EMPTY)</code>.
                </span>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}
