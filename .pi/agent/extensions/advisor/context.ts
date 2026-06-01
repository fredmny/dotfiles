/**
 * Extracts recent conversation context from the session to include
 * alongside the question sent to the advisor subprocess.
 */

/** Characters included in "relevant" and "full" strategies before truncation. */
const MAX_CONTEXT_CHARS = 8_000;

/** Number of message pairs included in "relevant" mode. */
const RELEVANT_MESSAGE_COUNT = 10;

type SessionEntry = {
  type: string;
  message?: {
    role: string;
    content: Array<{ type: string; text?: string }>;
  };
};

export function extractContext(
  sessionManager: { getBranch(): unknown[] },
  strategy: "full" | "relevant" | "minimal",
): string {
  if (strategy === "minimal") return "";

  const entries = sessionManager.getBranch() as SessionEntry[];
  const messages: Array<{ role: string; text: string }> = [];

  for (const entry of entries) {
    if (entry.type !== "message" || !entry.message) continue;
    const { role, content } = entry.message;
    if (role !== "user" && role !== "assistant") continue;

    const text = content
      .filter((p) => p.type === "text" && p.text)
      .map((p) => p.text as string)
      .join("\n")
      .trim();

    if (text) messages.push({ role, text });
  }

  // Drop the last message — it's the current prompt being sent to the advisor
  const candidate = messages.slice(0, -1);
  const selected =
    strategy === "relevant" ? candidate.slice(-RELEVANT_MESSAGE_COUNT) : candidate;

  if (selected.length === 0) return "";

  const formatted = selected
    .map((m) => `[${m.role}]:\n${m.text}`)
    .join("\n\n---\n\n");

  if (formatted.length <= MAX_CONTEXT_CHARS) return formatted;

  // Keep the most recent content when truncating
  const truncated = formatted.slice(formatted.length - MAX_CONTEXT_CHARS);
  const breakPoint = truncated.indexOf("\n");
  const clean = breakPoint > 0 ? truncated.slice(breakPoint + 1) : truncated;
  return "[…earlier context omitted…]\n\n" + clean;
}
