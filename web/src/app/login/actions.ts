"use server";

import { redirect } from "next/navigation";
import {
  authenticateUser,
  createSession,
  clearSession,
  createDemoSession,
  DEMO_PROFILES,
} from "@/lib/auth";

export type LoginState = {
  error?: string;
};

/**
 * Standard username & password login.
 */
export async function loginAction(
  _prevState: LoginState,
  formData: FormData
): Promise<LoginState> {
  const username = formData.get("username")?.toString() ?? "";
  const password = formData.get("password")?.toString() ?? "";
  const gateMode = (formData.get("gate_mode")?.toString() || "ENTRY") as "ENTRY" | "EXIT";
  const gateIdStr = formData.get("gate_id")?.toString();
  const gateId = gateIdStr ? Number(gateIdStr) : null;
  const gateName = formData.get("gate_name")?.toString() || null;

  if (!username) {
    return { error: "Please enter a username or click any 1-Click Role button." };
  }

  const user = await authenticateUser(username, password);

  if (!user) {
    return {
      error: "Invalid credentials. Tip: click any 1-Click Demo card below for instant sign-in.",
    };
  }

  // Attach gate station selection if Gate Operator or if provided
  user.gate_mode = gateMode;
  user.gate_id = gateId;
  user.gate_name = gateName;

  await createSession(user);

  // Redirect based on role
  if (user.role === "Gate Operator") {
    const params = new URLSearchParams();
    params.set("mode", gateMode);
    if (gateId) params.set("gateId", String(gateId));
    redirect(`/anpr?${params.toString()}`);
  } else if (user.role === "Cashier") {
    redirect("/tickets");
  } else {
    redirect("/dashboard");
  }
}

/**
 * Instant 1-Click login designed for frictionless college vivas & evaluator testing.
 */
export async function directRoleLoginAction(roleKey: string) {
  const profile = await createDemoSession(roleKey as keyof typeof DEMO_PROFILES);

  if (profile.role === "Gate Operator") {
    const mode = profile.gate_mode || "ENTRY";
    const gateId = profile.gate_id || (mode === "ENTRY" ? 1 : 5);
    redirect(`/anpr?mode=${mode}&gateId=${gateId}`);
  } else if (profile.role === "Cashier") {
    redirect("/tickets");
  } else if (profile.role === "Security Guard") {
    redirect("/anpr");
  } else {
    redirect("/dashboard");
  }
}

/**
 * Quick role switcher action for the in-app user navigation.
 */
export async function switchRoleAction(roleKey: string, returnPath?: string) {
  const profile = await createDemoSession(roleKey as keyof typeof DEMO_PROFILES);

  if (returnPath) {
    redirect(returnPath);
  }

  if (profile.role === "Gate Operator") {
    const mode = profile.gate_mode || "ENTRY";
    redirect(`/anpr?mode=${mode}`);
  } else {
    redirect("/dashboard");
  }
}

export async function logoutAction() {
  await clearSession();
  redirect("/login");
}
