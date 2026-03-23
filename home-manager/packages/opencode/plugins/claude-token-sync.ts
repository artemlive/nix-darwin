import type { Plugin } from "@opencode-ai/plugin"
import { readFileSync, writeFileSync, existsSync, mkdirSync } from "fs"
import { join } from "path"
import { execSync } from "child_process"
import { homedir, platform } from "os"

const KEYCHAIN_SERVICE = "Claude Code-credentials"
const AUTH_JSON_PATH = join(homedir(), ".local", "share", "opencode", "auth.json")
const LOG_PREFIX = "[claude-token-sync]"

// Debounce: don't refresh more than once per 30 seconds
let lastRefreshTime = 0
const REFRESH_COOLDOWN_MS = 30_000

interface ClaudeOAuthData {
  accessToken: string
  refreshToken: string
  expiresAt: number
  scopes?: string[]
  subscriptionType?: string
  rateLimitTier?: string
}

interface ClaudeCredentials {
  claudeAiOauth: ClaudeOAuthData
}

interface AuthJson {
  [key: string]: {
    type: string
    refresh?: string
    access?: string
    expires?: number
    key?: string
  }
}

function log(msg: string) {
  console.log(`${LOG_PREFIX} ${msg}`)
}

function warn(msg: string) {
  console.warn(`${LOG_PREFIX} ${msg}`)
}

// ---------------------------------------------------------------------------
// Cross-platform credential reading
// ---------------------------------------------------------------------------

/**
 * Resolve the path to Claude Code's .credentials.json file.
 * Used on Windows and Linux (macOS uses Keychain as primary, file as fallback).
 */
function getCredentialsFilePath(): string {
  const configDir = process.env.CLAUDE_CONFIG_DIR || join(homedir(), ".claude")
  return join(configDir, ".credentials.json")
}

/**
 * Read credentials from the .credentials.json file (Windows, Linux, macOS fallback).
 */
function readCredentialsFile(): ClaudeCredentials | null {
  const credPath = getCredentialsFilePath()
  try {
    if (!existsSync(credPath)) {
      return null
    }
    const raw = readFileSync(credPath, "utf-8").trim()
    // The file may have trailing whitespace or commas from the CLI
    const cleaned = raw.replace(/,\s*$/, "")
    const data = JSON.parse(cleaned) as ClaudeCredentials
    if (!data.claudeAiOauth?.accessToken || !data.claudeAiOauth?.refreshToken) {
      return null
    }
    return data
  } catch {
    return null
  }
}

/**
 * Read credentials from macOS Keychain.
 */
function readKeychainCredentials(): ClaudeCredentials | null {
  try {
    const raw = execSync(
      `security find-generic-password -s "${KEYCHAIN_SERVICE}" -w 2>/dev/null`,
      { encoding: "utf-8", timeout: 5000 }
    ).trim()

    const data = JSON.parse(raw) as ClaudeCredentials
    if (!data.claudeAiOauth?.accessToken || !data.claudeAiOauth?.refreshToken) {
      return null
    }
    return data
  } catch {
    return null
  }
}

/**
 * Extract Claude OAuth credentials – works on macOS, Windows, and Linux.
 *
 * macOS: Keychain (primary) -> .credentials.json (fallback)
 * Windows: .credentials.json
 * Linux: .credentials.json
 */
function extractClaudeCredentials(): ClaudeCredentials | null {
  const os = platform()

  if (os === "darwin") {
    // macOS: try Keychain first, fall back to file
    const fromKeychain = readKeychainCredentials()
    if (fromKeychain) return fromKeychain
    const fromFile = readCredentialsFile()
    if (fromFile) {
      log("Read credentials from .credentials.json (Keychain unavailable)")
      return fromFile
    }
    warn("No Claude Code credentials found. Run 'claude /login' first.")
    return null
  }

  // Windows & Linux: read from file
  const fromFile = readCredentialsFile()
  if (fromFile) return fromFile

  const credPath = getCredentialsFilePath()
  if (os === "win32") {
    warn(`No credentials at ${credPath}. Run 'claude /login' first.`)
  } else {
    warn(`No credentials at ${credPath}. Run 'claude /login' first.`)
  }
  return null
}

// ---------------------------------------------------------------------------
// auth.json management
// ---------------------------------------------------------------------------

function readAuthJson(): AuthJson {
  try {
    if (existsSync(AUTH_JSON_PATH)) {
      return JSON.parse(readFileSync(AUTH_JSON_PATH, "utf-8"))
    }
  } catch {}
  return {}
}

function writeAuthJson(auth: AuthJson) {
  const dir = join(homedir(), ".local", "share", "opencode")
  if (!existsSync(dir)) {
    mkdirSync(dir, { recursive: true })
  }
  writeFileSync(AUTH_JSON_PATH, JSON.stringify(auth, null, 2))
}

// ---------------------------------------------------------------------------
// Token helpers
// ---------------------------------------------------------------------------

function isTokenExpiring(expiresAt: number): boolean {
  const buffer = 5 * 60 * 1000 // 5 minutes
  return expiresAt <= Date.now() + buffer
}

/**
 * Sync Claude tokens: extract from OS credential store and update opencode.
 * Returns true if tokens were updated.
 */
async function syncTokens(
  client: any,
  force = false
): Promise<boolean> {
  const now = Date.now()
  if (!force && now - lastRefreshTime < REFRESH_COOLDOWN_MS) {
    log("Skipping refresh (cooldown active)")
    return false
  }

  const creds = extractClaudeCredentials()
  if (!creds) return false

  const { accessToken, refreshToken, expiresAt } = creds.claudeAiOauth

  // Check if tokens actually changed
  const currentAuth = readAuthJson()
  const currentAccess = currentAuth.anthropic?.access
  if (!force && currentAccess === accessToken) {
    log("Tokens already in sync")
    return false
  }

  // If the token is about to expire, try to trigger a Claude CLI refresh
  if (isTokenExpiring(expiresAt)) {
    log("Token is expiring soon – attempting Claude CLI refresh...")
    try {
      const cmd = platform() === "win32"
        ? 'claude /login --auto 2>nul || echo ok'
        : 'claude /login --auto 2>/dev/null || true'
      execSync(cmd, { encoding: "utf-8", timeout: 30000 })
      // Re-read after refresh
      const refreshed = extractClaudeCredentials()
      if (refreshed && refreshed.claudeAiOauth.accessToken !== accessToken) {
        return syncTokens(client, true)
      }
    } catch {
      warn("Could not auto-refresh Claude token")
    }
  }

  // Write to auth.json on disk
  currentAuth.anthropic = {
    type: "oauth",
    refresh: refreshToken,
    access: accessToken,
    expires: expiresAt,
  }
  writeAuthJson(currentAuth)

  // Update opencode live via SDK
  try {
    await client.auth.set({
      path: { id: "anthropic" },
      body: {
        type: "oauth",
        refresh: refreshToken,
        access: accessToken,
        expires: expiresAt,
      },
    })
    log("Tokens synced (credentials -> auth.json + SDK)")
  } catch {
    log("Tokens written to auth.json (SDK update failed – will apply on restart)")
  }

  lastRefreshTime = Date.now()
  return true
}

// ---------------------------------------------------------------------------
// Error detection
// ---------------------------------------------------------------------------

function isRateLimitOrAuthError(error: any): boolean {
  const msg = typeof error === "string" ? error : JSON.stringify(error)
  const lower = msg.toLowerCase()
  return (
    lower.includes("429") ||
    lower.includes("rate limit") ||
    lower.includes("too many requests") ||
    lower.includes("overloaded") ||
    lower.includes("unauthorized") ||
    lower.includes("401") ||
    lower.includes("invalid_token") ||
    lower.includes("invalid bearer token") ||
    lower.includes("token expired") ||
    lower.includes("authentication")
  )
}

// ---------------------------------------------------------------------------
// Plugin export
// ---------------------------------------------------------------------------

export const ClaudeTokenSync: Plugin = async ({ client }) => {
  log(`Initializing (${platform()})...`)
  await syncTokens(client, true)

  return {
    event: async ({ event }: { event: any }) => {
      // 429 / auth errors -> refresh tokens
      if (event.type === "session.error") {
        const errorData = event.properties || event
        if (isRateLimitOrAuthError(errorData)) {
          log("Detected rate-limit / auth error – refreshing tokens...")
          const updated = await syncTokens(client)
          if (updated) {
            log("Tokens refreshed. Retry your prompt.")
          } else {
            log("Tokens unchanged. The rate limit may be temporary – wait and retry.")
          }
        }
      }

      // Sync on new session in case tokens drifted
      if (event.type === "session.created") {
        const creds = extractClaudeCredentials()
        if (creds) {
          const currentAuth = readAuthJson()
          if (currentAuth.anthropic?.access !== creds.claudeAiOauth.accessToken) {
            log("Token drift detected on session start, syncing...")
            await syncTokens(client)
          }
        }
      }
    },
  }
}
