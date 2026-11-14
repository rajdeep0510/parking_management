/**
 * Utility functions for Automatic Number Plate Recognition (ANPR)
 * and Fuzzy License Plate Matching.
 */

export const VALID_INDIAN_STATES = new Set([
  "AN", "AP", "AR", "AS", "BR", "CG", "CH", "DD", "DL", "DN", "GA", "GJ",
  "HP", "HR", "JH", "JK", "KA", "KL", "LA", "LD", "MH", "ML", "MN", "MP",
  "MZ", "NL", "OD", "OR", "PB", "PY", "RJ", "SK", "TN", "TR", "TS", "UK",
  "UP", "UT", "WB"
]);

/**
 * Standard Indian license plate patterns:
 * 1. State: 2 letters (State) + 1-2 digits (RTO) + 1-3 letters + 4 digits (e.g., GJ-01-AB-1234, RJ-14-CY-0002)
 * 2. BH (Bharat) Series: 2 digits (Year) + BH + 4 digits + 1-2 letters (e.g., 22BH1234AA)
 */
export const PLATE_REGEX_INDIAN = /^[A-Z]{2}[0-9]{1,2}[A-Z]{1,3}[0-9]{4}$/;
export const PLATE_REGEX_BH = /^[0-9]{2}BH[0-9]{4}[A-Z]{1,2}$/;
export const PLATE_REGEX_GENERAL = /^[A-Z0-9]{6,12}$/;

/**
 * Cleans a string to uppercase alphanumeric characters only.
 */
export function cleanPlateString(str: string): string {
  return (str || "").toUpperCase().replace(/[^A-Z0-9]/g, "");
}

/**
 * Cleans raw OCR text and extracts a standardized license plate number.
 * Uses anchor detection (state codes, BH series) and noise-stripping.
 */
export function extractPlateNumber(rawText: string): { plate: string; isValid: boolean; format: string } | null {
  if (!rawText) return null;

  // Split lines and inspect each line or entire cleaned string
  const lines = rawText.split(/\r?\n/).map((l) => l.trim()).filter(Boolean);
  const candidates: string[] = [];

  for (const line of lines) {
    const cleaned = cleanPlateString(line);
    if (cleaned.length >= 6 && cleaned.length <= 14) {
      candidates.push(cleaned);
    }
  }

  const fullCleaned = cleanPlateString(rawText);
  if (fullCleaned.length >= 6 && fullCleaned.length <= 14) {
    candidates.push(fullCleaned);
  }

  // 1. Try finding State Code plate inside candidate strings (even with edge noise like IND or bracket)
  for (const cand of candidates) {
    // Check if cand starts with or contains state code
    for (let i = 0; i <= cand.length - 8; i++) {
      const stateCandidate = cand.slice(i, i + 2);
      if (VALID_INDIAN_STATES.has(stateCandidate)) {
        const sub = cand.slice(i);

        // Check Delhi format specifically: DL + district(1-14) + class(C,S,P,R...) + series + number
        if (stateCandidate === "DL") {
          const dlMatch = sub.match(/^DL([1-9]|1[0-4])([A-Z])([A-Z]{1,2})([0-9]{4})/);
          if (dlMatch) {
            const formatted = formatIndianPlate(dlMatch[0]);
            return { plate: formatted, isValid: true, format: "State Plate (DL)" };
          }
        }

        // Try exact match or normalized match
        const match = sub.match(/^([A-Z]{2})([0-9]{1,2})([A-Z]{1,3})([0-9]{4})/);
        if (match) {
          const formatted = formatIndianPlate(`${match[1]}${match[2].padStart(2, "0")}${match[3]}${match[4]}`);
          return { plate: formatted, isValid: true, format: `State Plate (${match[1]})` };
        }

        // Try with positional error correction
        const corrected = fixCommonPlateOcrErrors(sub);
        if (stateCandidate === "DL") {
          const dlCorrMatch = corrected.match(/^DL([1-9]|1[0-4])([A-Z])([A-Z]{1,2})([0-9]{4})/);
          if (dlCorrMatch) {
            const formatted = formatIndianPlate(dlCorrMatch[0]);
            return { plate: formatted, isValid: true, format: "State Plate (DL - Corrected)" };
          }
        }

        const matchCorrected = corrected.match(/^([A-Z]{2})([0-9]{1,2})([A-Z]{1,3})([0-9]{4})/);
        if (matchCorrected) {
          const formatted = formatIndianPlate(
            `${matchCorrected[1]}${matchCorrected[2].padStart(2, "0")}${matchCorrected[3]}${matchCorrected[4]}`
          );
          return { plate: formatted, isValid: true, format: `State Plate (${matchCorrected[1]} - Corrected)` };
        }
      }
    }

    // 2. Try finding BH series plate: 2 digits + BH + 4 digits + 1-2 letters
    const bhMatch = cand.match(/([0-9]{2})BH([0-9]{3,4})([A-Z]{1,2})/);
    if (bhMatch) {
      const normalizedDigits = bhMatch[2].padStart(4, "0");
      const plate = `${bhMatch[1]}BH${normalizedDigits}${bhMatch[3]}`;
      return { plate, isValid: true, format: "BH Series" };
    }

    // Also check with character substitution for BH
    const candCorrected = fixCommonPlateOcrErrors(cand);
    const bhMatchCorr = candCorrected.match(/([0-9]{2})BH([0-9]{3,4})([A-Z]{1,2})/);
    if (bhMatchCorr) {
      const normalizedDigits = bhMatchCorr[2].padStart(4, "0");
      const plate = `${bhMatchCorr[1]}BH${normalizedDigits}${bhMatchCorr[3]}`;
      return { plate, isValid: true, format: "BH Series (Corrected)" };
    }
  }

  // 3. Fallback: Standard general alphanumeric plate (7-11 chars with letters and numbers)
  for (const cand of candidates) {
    const hasLetters = /[A-Z]/.test(cand);
    const hasNumbers = /[0-9]/.test(cand);
    if (cand.length >= 6 && cand.length <= 11 && hasLetters && hasNumbers) {
      return {
        plate: cand,
        isValid: true,
        format: "General Plate",
      };
    }
  }

  return null;
}

/**
 * Formats a clean alphanumeric plate into standard readable format with hyphens.
 * e.g.,
 * - Delhi: DL1CAA1111 -> DL-1C-AA-1111
 * - Standard State: GJ01AB1234 -> GJ-01-AB-1234, RJ14CY0002 -> RJ-14-CY-0002
 * - Bharat Series: 22BH1234AA -> 22-BH-1234-AA
 */
export function formatIndianPlate(clean: string): string {
  const c = cleanPlateString(clean);
  if (!c) return "";

  // 1. Delhi Plate format: DL + (1-14) + Class Letter (C, S, P, R, etc.) + Series + 4 Digits
  // e.g. DL1CAA1111 -> DL-1C-AA-1111
  const dlMatch = c.match(/^DL([1-9]|1[0-4])([A-Z])([A-Z]{1,2})([0-9]{4})$/);
  if (dlMatch) {
    const [, dist, vClass, series, num] = dlMatch;
    return `DL-${dist}${vClass}-${series}-${num}`;
  }

  // 2. Bharat Series: 22BH1234AA -> 22-BH-1234-AA
  const bhMatch = c.match(/^([0-9]{2})BH([0-9]{4})([A-Z]{1,2})$/);
  if (bhMatch) {
    const [, yr, num, series] = bhMatch;
    return `${yr}-BH-${num}-${series}`;
  }

  // 3. Standard State Plate: 2 letters + 1-2 digits + 1-3 letters + 4 digits
  // e.g. GJ01AB1234 -> GJ-01-AB-1234, RJ14CY0002 -> RJ-14-CY-0002
  const stdMatch = c.match(/^([A-Z]{2})([0-9]{1,2})([A-Z]{1,3})([0-9]{4})$/);
  if (stdMatch) {
    const [, state, rto, series, num] = stdMatch;
    return `${state}-${rto.padStart(2, "0")}-${series}-${num}`;
  }

  // 4. Fallback: try as-you-type formatting
  return formatPlateAsYouType(c);
}

/**
 * Automatically formats user input dynamically as they type into the standard Indian license plate format.
 * Examples:
 * - dl1caa1111 -> DL-1C-AA-1111
 * - gj01ab1234 -> GJ-01-AB-1234
 * - rj14cy0002 -> RJ-14-CY-0002
 * - 22bh1234aa -> 22-BH-1234-AA
 */
export function formatPlateAsYouType(val: string): string {
  if (!val) return "";
  const raw = val.toUpperCase().replace(/[^A-Z0-9]/g, "");
  if (!raw) return "";

  let formatted = "";

  // 1. Bharat Series (BH): starts with 2 digits (e.g. 22BH...)
  if (/^[0-9]{2}BH/.test(raw) || (/^[0-9]{2}/.test(raw) && raw.length <= 4 && (raw[2] === "B" || !raw[2]))) {
    const p1 = raw.slice(0, 2);
    const rest1 = raw.slice(2);
    if (!rest1) {
      formatted = p1;
    } else {
      const p2 = rest1.slice(0, 2);
      const rest2 = rest1.slice(2);
      if (!rest2) {
        formatted = `${p1}-${p2}`;
      } else {
        const p3 = rest2.slice(0, 4);
        const rest3 = rest2.slice(4, 6);
        formatted = rest3 ? `${p1}-${p2}-${p3}-${rest3}` : `${p1}-${p2}-${p3}`;
      }
    }
  } else {
    // 2. State plates:
    const p1 = raw.slice(0, 2);
    const rest1 = raw.slice(2);
    if (!rest1) {
      formatted = p1;
    } else {
      let p2 = "";
      let rest2 = "";

      // Delhi: 1-14 followed by vehicle class letter (e.g. DL1C..., DL3C...)
      if (p1 === "DL") {
        const dlMatch = rest1.match(/^([1-9]|1[0-4])([A-Z])(.*)$/);
        if (dlMatch) {
          p2 = dlMatch[1] + dlMatch[2];
          rest2 = dlMatch[3];
        }
      }

      // Standard RTO: 1-2 digits (e.g. 01, 14, 27)
      if (!p2) {
        const stdMatch = rest1.match(/^([0-9]{1,2})(.*)$/);
        if (stdMatch) {
          p2 = stdMatch[1];
          rest2 = stdMatch[2];
        } else {
          p2 = rest1.slice(0, 2);
          rest2 = rest1.slice(2);
        }
      }

      if (!rest2) {
        formatted = `${p1}-${p2}`;
      } else {
        const seriesMatch = rest2.match(/^([A-Z]{1,3})([0-9]*.*)$/);
        if (seriesMatch) {
          const p3 = seriesMatch[1];
          const p4 = seriesMatch[2].slice(0, 4);
          formatted = p4 ? `${p1}-${p2}-${p3}-${p4}` : `${p1}-${p2}-${p3}`;
        } else {
          const numOnlyMatch = rest2.match(/^([0-9]{1,4})/);
          if (numOnlyMatch) {
            formatted = `${p1}-${p2}-${numOnlyMatch[1]}`;
          } else {
            formatted = `${p1}-${p2}-${rest2.slice(0, 6)}`;
          }
        }
      }
    }
  }

  // Preserve trailing hyphen if user explicitly typed it at a natural segment boundary
  if (val.endsWith("-") && !formatted.endsWith("-") && (raw.length === 2 || raw.length === 4 || raw.length === 6)) {
    return `${formatted}-`;
  }

  return formatted;
}

/**
 * Fixes common character substitutions where letters appear where numbers should be or vice-versa.
 */
function fixCommonPlateOcrErrors(text: string): string {
  const chars = text.split("");
  if (chars.length < 8) return text;

  // Characters 2 and 3 should usually be digits in Indian plates
  if (chars[2] === "O" || chars[2] === "Q" || chars[2] === "D") chars[2] = "0";
  if (chars[2] === "I" || chars[2] === "L") chars[2] = "1";
  if (chars[2] === "Z") chars[2] = "2";
  if (chars[2] === "S") chars[2] = "5";
  if (chars[2] === "B") chars[2] = "8";

  if (chars[3] === "O" || chars[3] === "Q" || chars[3] === "D") chars[3] = "0";
  if (chars[3] === "I" || chars[3] === "L") chars[3] = "1";
  if (chars[3] === "Z") chars[3] = "2";
  if (chars[3] === "S") chars[3] = "5";
  if (chars[3] === "B") chars[3] = "8";

  // Last 4 characters should be digits
  for (let i = chars.length - 4; i < chars.length; i++) {
    if (chars[i] === "O" || chars[i] === "D" || chars[i] === "Q") chars[i] = "0";
    if (chars[i] === "I" || chars[i] === "L") chars[i] = "1";
    if (chars[i] === "Z") chars[i] = "2";
    if (chars[i] === "S") chars[i] = "5";
    if (chars[i] === "B") chars[i] = "8";
  }

  return chars.join("");
}

// Optical confusion sets (characters that frequently look identical under camera angles/glare)
const OCR_CONFUSIONS = [
  new Set(["Y", "V"]),
  new Set(["O", "0", "D", "Q"]),
  new Set(["I", "1", "L", "T"]),
  new Set(["B", "8"]),
  new Set(["S", "5"]),
  new Set(["Z", "2"]),
  new Set(["U", "V"]),
  new Set(["C", "G"]),
];

function areConfusable(c1: string, c2: string): boolean {
  if (c1 === c2) return true;
  for (const s of OCR_CONFUSIONS) {
    if (s.has(c1) && s.has(c2)) return true;
  }
  return false;
}

/**
 * Calculates OCR-weighted Levenshtein distance between two plates.
 * Common optical errors (e.g. Y vs V, 8 vs B, 0 vs O) carry a very low penalty (0.2).
 */
export function ocrPlateDistance(s1: string, s2: string): number {
  const a = cleanPlateString(s1);
  const b = cleanPlateString(s2);
  const m = a.length;
  const n = b.length;
  if (m === 0) return n;
  if (n === 0) return m;

  const dp: number[][] = Array.from({ length: m + 1 }, () => new Array(n + 1).fill(0));
  for (let i = 0; i <= m; i++) dp[i][0] = i;
  for (let j = 0; j <= n; j++) dp[0][j] = j;

  for (let i = 1; i <= m; i++) {
    for (let j = 1; j <= n; j++) {
      let cost = 1.0;
      if (a[i - 1] === b[j - 1]) {
        cost = 0;
      } else if (areConfusable(a[i - 1], b[j - 1])) {
        cost = 0.2; // Minor OCR confusion penalty
      }
      dp[i][j] = Math.min(
        dp[i - 1][j] + 1,       // deletion
        dp[i][j - 1] + 1,       // insertion
        dp[i - 1][j - 1] + cost // substitution
      );
    }
  }
  return dp[m][n];
}

/**
 * Returns a normalized similarity score between 0.0 (no match) and 1.0 (exact match).
 */
export function calculatePlateSimilarity(s1: string, s2: string): number {
  const a = cleanPlateString(s1);
  const b = cleanPlateString(s2);
  if (!a || !b) return 0;
  if (a === b) return 1.0;
  const maxLen = Math.max(a.length, b.length);
  const dist = ocrPlateDistance(a, b);
  return Math.max(0, 1 - dist / maxLen);
}

export type ActiveTicketMatchCandidate = {
  ticket_no: number;
  slot_id: number;
  slot_no: string;
  zone_name: string;
  vehicle_id: number;
  registration_no: string;
  entry_time: string;
  similarity: number;
  matchType: "EXACT" | "FUZZY";
};

/**
 * Searches a list of currently active tickets for the best match against a scanned plate.
 * Handles exact matches, formatting differences, and OCR character confusions.
 */
export function findBestActiveTicketMatch<T extends { registration_no: string }>(
  scannedPlate: string,
  activeTickets: T[],
  minConfidence = 0.70
): { match: T | null; similarity: number; matchType: "EXACT" | "FUZZY" | "NONE"; candidates: (T & { similarity: number })[] } {
  const cleanScanned = cleanPlateString(scannedPlate);
  if (!cleanScanned || activeTickets.length === 0) {
    return { match: null, similarity: 0, matchType: "NONE", candidates: [] };
  }

  // 1. Direct canonical match (ignoring hyphens, spaces, casing)
  for (const t of activeTickets) {
    if (cleanPlateString(t.registration_no) === cleanScanned) {
      return {
        match: t,
        similarity: 1.0,
        matchType: "EXACT",
        candidates: [{ ...t, similarity: 1.0 }],
      };
    }
  }

  // 2. Fuzzy match against all currently parked vehicles
  const scored = activeTickets
    .map((t) => ({
      ...t,
      similarity: calculatePlateSimilarity(cleanScanned, t.registration_no),
    }))
    .sort((a, b) => b.similarity - a.similarity);

  const best = scored[0];
  if (best && best.similarity >= minConfidence) {
    return {
      match: best,
      similarity: best.similarity,
      matchType: "FUZZY",
      candidates: scored.slice(0, 3),
    };
  }

  return {
    match: null,
    similarity: best ? best.similarity : 0,
    matchType: "NONE",
    candidates: scored.slice(0, 3),
  };
}

/**
 * Preprocesses a region of a canvas to enhance character contrast for OCR:
 * - Crops reticle region
 * - Applies grayscale conversion and contrast stretch
 */
export function preprocessCanvasForOcr(
  sourceCanvas: HTMLCanvasElement,
  cropBox: { x: number; y: number; width: number; height: number }
): HTMLCanvasElement {
  const outputCanvas = document.createElement("canvas");
  outputCanvas.width = Math.max(300, cropBox.width * 1.5);
  outputCanvas.height = Math.max(100, cropBox.height * 1.5);

  const ctx = outputCanvas.getContext("2d");
  if (!ctx) return sourceCanvas;

  ctx.drawImage(
    sourceCanvas,
    cropBox.x,
    cropBox.y,
    cropBox.width,
    cropBox.height,
    0,
    0,
    outputCanvas.width,
    outputCanvas.height
  );

  const imgData = ctx.getImageData(0, 0, outputCanvas.width, outputCanvas.height);
  const data = imgData.data;

  // Calculate average luminance
  let totalLuminance = 0;
  for (let i = 0; i < data.length; i += 4) {
    const lum = 0.299 * data[i] + 0.587 * data[i + 1] + 0.114 * data[i + 2];
    totalLuminance += lum;
  }
  const avgLuminance = totalLuminance / (data.length / 4);

  // High-contrast adaptive binarization
  const threshold = Math.min(Math.max(avgLuminance, 85), 165);
  for (let i = 0; i < data.length; i += 4) {
    const lum = 0.299 * data[i] + 0.587 * data[i + 1] + 0.114 * data[i + 2];
    const val = lum > threshold ? 255 : 0;
    data[i] = val;
    data[i + 1] = val;
    data[i + 2] = val;
  }

  ctx.putImageData(imgData, 0, 0);
  return outputCanvas;
}

/**
 * Plays a pleasant synthesizer chime tone using the Web Audio API on successful detection & DB save.
 */
export function playSuccessChime() {
  try {
    const AudioCtx = window.AudioContext || (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext;
    if (!AudioCtx) return;
    const ctx = new AudioCtx();
    const now = ctx.currentTime;

    const osc1 = ctx.createOscillator();
    const gain1 = ctx.createGain();
    osc1.type = "sine";
    osc1.frequency.setValueAtTime(587.33, now); // D5
    osc1.frequency.setValueAtTime(880, now + 0.1); // A5
    gain1.gain.setValueAtTime(0.15, now);
    gain1.gain.exponentialRampToValueAtTime(0.001, now + 0.35);

    osc1.connect(gain1);
    gain1.connect(ctx.destination);
    osc1.start(now);
    osc1.stop(now + 0.35);
  } catch {
    // Ignore audio permission/context errors
  }
}
