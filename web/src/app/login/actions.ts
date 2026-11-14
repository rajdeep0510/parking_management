"use server";

import { redirect } from "next/navigation";
import { authenticateUser, createSession, clearSession } from "@/lib/auth";

export type LoginState = {
  error?: string;
};

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

  if (!username || !password) {
    return { error: "Please enter both username and password." };
  }

  const user = await authenticateUser(username, password);

  if (!user) {
    return { error: "Invalid username or password. Check credentials." };
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
  } else {
    redirect("/");
  }
}

export async function quickLoginAction(
  username: string,
  pass: string,
  gateMode: "ENTRY" | "EXIT" = "ENTRY",
  gateId?: number
) {
  const user = await authenticateUser(username, pass);
  if (user) {
    user.gate_mode = gateMode;
    user.gate_id = gateId ?? null;
    await createSession(user);

    if (user.role === "Gate Operator") {
      const params = new URLSearchParams();
      params.set("mode", gateMode);
      if (gateId) params.set("gateId", String(gateId));
      redirect(`/anpr?${params.toString()}`);
    } else {
      redirect("/");
    }
  }
}

export async function logoutAction() {
  await clearSession();
  redirect("/login");
}
