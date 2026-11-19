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
  is_guest?: boolean;
};

const SESSION_COOKIE = "parking_session";

/**
 * Predefined demo profiles for instant 1-click evaluation & college vivas.
 */
export const DEMO_PROFILES: Record<string, AuthUser> = {
  gate_entry: {
    account_id: 2,
    staff_id: 2,
    username: "gate_worker",
    display_name: "Gate Operator (Entry Terminal)",
    role: "Gate Operator",
    gate_mode: "ENTRY",
    gate_id: 1,
    gate_name: "G-101",
  },
  gate_exit: {
    account_id: 2,
    staff_id: 2,
    username: "gate_worker",
    display_name: "Gate Operator (Exit Terminal)",
    role: "Gate Operator",
    gate_mode: "EXIT",
    gate_id: 5,
    gate_name: "G-201",
  },
  admin: {
    account_id: 1,
    staff_id: 1,
    username: "admin",
    display_name: "System Administrator",
    role: "Admin",
  },
  supervisor: {
    account_id: 3,
    staff_id: 3,
    username: "supervisor",
    display_name: "Operations Supervisor",
    role: "Supervisor",
  },
  cashier: {
    account_id: 4,
    staff_id: 4,
    username: "cashier",
    display_name: "Cashier Desk",
    role: "Cashier",
  },
  security: {
    account_id: 5,
    staff_id: 5,
    username: "security",
    display_name: "Security Surveillance",
    role: "Security Guard",
  },
  guest: {
    account_id: 999,
    staff_id: null,
    username: "guest_evaluator",
    display_name: "Guest Evaluator",
    role: "Evaluator",
    is_guest: true,
  },
};

/**
 * Validates credentials against the staff_account database table.
 * Lenient for college presentations: handles whitespace, lowercase matching,
 * and demo fallback passwords.
 */
export async function authenticateUser(
  username: string,
  pass: string
): Promise<AuthUser | null> {
  const cleanUsername = username.trim().toLowerCase();
  const cleanPass = pass.trim();

  try {
    const { rows } = await pool.query<AuthUser & { password: string }>(
      `SELECT account_id, staff_id, username, display_name, role, password
         FROM public.staff_account
        WHERE LOWER(username) = $1 AND is_active = true
        LIMIT 1`,
      [cleanUsername]
    );

    const user = rows[0];
    if (!user) {
      // Check if matches a demo profile directly by username
      const demoKey = Object.keys(DEMO_PROFILES).find(
        (k) => DEMO_PROFILES[k].username.toLowerCase() === cleanUsername
      );
      if (demoKey) {
        return DEMO_PROFILES[demoKey];
      }
      return null;
    }

    const storedPass = (user.password || "").trim();

    // Lenient match: exact, or trimmed, or common demo passwords
    const isValid =
      storedPass === cleanPass ||
      cleanPass === "1234" ||
      cleanPass === "admin" ||
      cleanPass === "admin123" ||
      cleanPass === "gate123" ||
      cleanPass === "super123";

    if (!isValid) {
      return null;
    }

    return {
      account_id: user.account_id,
      staff_id: user.staff_id,
      username: user.username,
      display_name: user.display_name,
      role: user.role,
    };
  } catch (err) {
    console.error("Authentication DB error, falling back to demo profiles:", err);
    // If DB has temporary connection hiccup, fall back to matching demo profile
    const match = Object.values(DEMO_PROFILES).find(
      (p) => p.username.toLowerCase() === cleanUsername
    );
    return match ?? null;
  }
}

/**
 * Sets session cookie for the authenticated user.
 * Configured so cookies persist reliably across localhost and deployed cloud hosts.
 */
export async function createSession(user: AuthUser): Promise<void> {
  const cookieStore = await cookies();
  const sessionData = JSON.stringify(user);

  // Set secure only when strictly required; on HTTP/local avoid dropping cookies
  const isSecure =
    process.env.COOKIE_SECURE === "true" ||
    (process.env.NODE_ENV === "production" && process.env.VERCEL === "1");

  cookieStore.set(SESSION_COOKIE, sessionData, {
    httpOnly: true,
    secure: isSecure,
    sameSite: "lax",
    path: "/",
    maxAge: 60 * 60 * 24 * 30, // 30 days
  });
}

/**
 * Creates a 1-click demo session for the given role key.
 */
export async function createDemoSession(roleKey: keyof typeof DEMO_PROFILES): Promise<AuthUser> {
  const profile = DEMO_PROFILES[roleKey] || DEMO_PROFILES.guest;
  await createSession(profile);
  return profile;
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
