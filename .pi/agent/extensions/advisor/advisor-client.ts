/**
 * Spawns a pi subprocess in JSON/print mode to run the advisor model
 * in an isolated context window and returns its response + usage stats.
 *
 * Mirrors the pattern established by the built-in subagent extension.
 */

import { spawn } from "node:child_process";
import { mkdtemp, writeFile, unlink, rmdir } from "node:fs/promises";
import { accessSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, basename } from "node:path";

export interface AdvisorCallOptions {
  /** Full prompt text (question + any context already merged in). */
  prompt: string;
  /** "provider/model-id" string, passed verbatim to --model. */
  model: string;
  /** Written to a temp file and passed via --append-system-prompt. */
  systemPrompt: string;
  /** Working directory for the subprocess. */
  cwd: string;
  /** Abort signal — kills the subprocess when triggered. */
  signal?: AbortSignal;
  /** Called with the latest partial response text during streaming. */
  onProgress?: (text: string) => void;
}

export interface AdvisorCallResult {
  success: boolean;
  response: string;
  error?: string;
  usage?: {
    inputTokens: number;
    outputTokens: number;
    cacheRead: number;
    cacheWrite: number;
    cost: number;
  };
  /** The model string reported by the response (may differ from requested). */
  model?: string;
}

/** OS arg limit guard — prompts beyond this are truncated. */
const MAX_PROMPT_CHARS = 32_768;

function getPiInvocation(args: string[]): { command: string; args: string[] } {
  const currentScript = process.argv[1];
  const isBunVirtualScript = currentScript?.startsWith("/$bunfs/root/");

  if (currentScript && !isBunVirtualScript) {
    try {
      accessSync(currentScript);
      return { command: process.execPath, args: [currentScript, ...args] };
    } catch {
      // fall through
    }
  }

  const execName = basename(process.execPath).toLowerCase();
  const isGenericRuntime = /^(node|bun)(\.exe)?$/.test(execName);
  if (!isGenericRuntime) {
    return { command: process.execPath, args };
  }

  return { command: "pi", args };
}

export async function runAdvisorCall(
  options: AdvisorCallOptions,
): Promise<AdvisorCallResult> {
  const { prompt, model, systemPrompt, cwd, signal, onProgress } = options;

  let tmpDir: string | null = null;
  let tmpFile: string | null = null;

  try {
    // Write system prompt to a temp file so it doesn't hit arg-length limits
    if (systemPrompt.trim()) {
      tmpDir = await mkdtemp(join(tmpdir(), "pi-advisor-"));
      tmpFile = join(tmpDir, "system-prompt.md");
      await writeFile(tmpFile, systemPrompt, { encoding: "utf-8", mode: 0o600 });
    }

    const args: string[] = ["--mode", "json", "-p", "--no-session", "--model", model];
    if (tmpFile) {
      args.push("--append-system-prompt", tmpFile);
    }

    const safePrompt =
      prompt.length > MAX_PROMPT_CHARS
        ? prompt.slice(0, MAX_PROMPT_CHARS) + "\n\n[prompt truncated due to length]"
        : prompt;

    args.push(safePrompt);

    const invocation = getPiInvocation(args);

    let finalResponse = "";
    let stderrOutput = "";
    const usage = { inputTokens: 0, outputTokens: 0, cacheRead: 0, cacheWrite: 0, cost: 0 };
    let reportedModel: string | undefined;

    const exitCode = await new Promise<number>((resolve) => {
      const proc = spawn(invocation.command, invocation.args, {
        cwd,
        shell: false,
        stdio: ["ignore", "pipe", "pipe"],
      });

      let buffer = "";

      const processLine = (line: string) => {
        if (!line.trim()) return;
        let event: Record<string, unknown>;
        try {
          event = JSON.parse(line) as Record<string, unknown>;
        } catch {
          return;
        }

        if (event.type === "message_end" && event.message) {
          const msg = event.message as {
            role: string;
            content: Array<{ type: string; text?: string }>;
            usage?: {
              input?: number;
              output?: number;
              cacheRead?: number;
              cacheWrite?: number;
              cost?: { total?: number };
            };
            model?: string;
          };

          if (msg.role === "assistant") {
            const text = msg.content
              .filter((p) => p.type === "text" && p.text)
              .map((p) => p.text as string)
              .join("\n");

            if (text.trim()) {
              finalResponse = text;
              // Fire progress with a leading snippet so the tool row stays informative
              const snippet = text.slice(0, 200) + (text.length > 200 ? "…" : "");
              onProgress?.(snippet);
            }

            if (msg.usage) {
              usage.inputTokens += msg.usage.input ?? 0;
              usage.outputTokens += msg.usage.output ?? 0;
              usage.cacheRead += msg.usage.cacheRead ?? 0;
              usage.cacheWrite += msg.usage.cacheWrite ?? 0;
              usage.cost += msg.usage.cost?.total ?? 0;
            }

            if (msg.model) reportedModel = msg.model;
          }
        }
      };

      proc.stdout.on("data", (chunk: Buffer) => {
        buffer += chunk.toString();
        const lines = buffer.split("\n");
        buffer = lines.pop() ?? "";
        for (const line of lines) processLine(line);
      });

      proc.stderr.on("data", (chunk: Buffer) => {
        stderrOutput += chunk.toString();
      });

      proc.on("close", (code: number | null) => {
        if (buffer.trim()) processLine(buffer);
        resolve(code ?? 0);
      });

      proc.on("error", () => resolve(1));

      if (signal) {
        const abort = () => {
          proc.kill("SIGTERM");
          setTimeout(() => {
            if (!proc.killed) proc.kill("SIGKILL");
          }, 5_000);
        };
        if (signal.aborted) {
          abort();
        } else {
          signal.addEventListener("abort", abort, { once: true });
        }
      }
    });

    if (exitCode !== 0 && !finalResponse) {
      const errMsg =
        stderrOutput.slice(0, 500).trim() ||
        `Advisor process exited with code ${exitCode}`;
      return { success: false, response: "", error: errMsg };
    }

    if (!finalResponse) {
      return { success: false, response: "", error: "Advisor returned no response" };
    }

    return { success: true, response: finalResponse, usage, model: reportedModel };
  } finally {
    if (tmpFile) {
      try {
        await unlink(tmpFile);
      } catch {
        // ignore
      }
    }
    if (tmpDir) {
      try {
        await rmdir(tmpDir);
      } catch {
        // ignore
      }
    }
  }
}
