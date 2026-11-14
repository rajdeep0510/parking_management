import "server-only";
import { cookies } from "next/headers";
import { pool } from "./db";

export type AuthUser = {
  account_id: number;
  staff_id: number | null;
  username: string;
  display_name: string;
  role: string;
  gate_mode?: "ENTRY" | "EXIT";
  gate_id?: number | null;
  gate_name?: string | null;
};

const SESSION_COOKIE = "parking_session";

/**
 * Validates credentials against the staff_account database table.
 */
export async function authenticateUser(
  username: string,
  pass: string
): Promise<AuthUser | null> {
  const cleanUsername = username.trim().toLowerCase();

  const { rows } = await pool.query<AuthUser & { password: string }>(
    `SELECT account_id, staff_id, username, display_name, role, password
       FROM public.staff_account
      WHERE LOWER(username) = $1 AND is_active = true
      LIMIT 1`,
    [cleanUsername]
  );

  const user = rows[0];
  if (!user) return null;

  // Simple password check
  if (user.password !== pass) {
    return null;
  }

  return {
    account_id: user.account_id,
    staff_id: user.staff_id,
    username: user.username,
    display_name: user.display_name,
    role: user.role,
  };
}

/**
 * Sets session cookie for the authenticated user.
 */
export async function createSession(user: AuthUser): Promise<void> {
  const cookieStore = await cookies();
  const sessionData = JSON.stringify(user);
  cookieStore.set(SESSION_COOKIE, sessionData, {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    path: "/",
    maxAge: 60 * 60 * 24 * 7, // 7 days
  });
}

/**
 * Retrieves the currently logged-in user from the session cookie.
 */
export async function getCurrentUser(): Promise<AuthUser | null> {
  try {
    const cookieStore = await cookies();
    const cookie = cookieStore.get(SESSION_COOKIE);
    if (!cookie?.value) return null;
    return JSON.parse(cookie.value) as AuthUser;
  } catch {
    return null;
  }
}

/**
 * Clears the session cookie.
 */
export async function clearSession(): Promise<void> {
  const cookieStore = await cookies();
  cookieStore.delete(SESSION_COOKIE);
}
