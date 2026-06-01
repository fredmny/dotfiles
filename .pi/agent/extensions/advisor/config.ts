/**
 * Configuration types and loader for the Advisor extension.
 *
 * Users edit config.json next to this file. All fields are optional —
 * missing ones fall back to CONFIG_DEFAULTS.
 */

import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";

export interface AdvisorConfig {
  /** Advisor model in "provider/model-id" format. e.g. "anthropic/claude-opus-4-5" */
  advisorModel: string;

  /** Thinking level applied to the advisor model during auto-route turns. */
  advisorThinking: "off" | "minimal" | "low" | "medium" | "high" | "xhigh";

  /** Input prefix that auto-routes the full turn to the advisor model. Set "" to disable. */
  triggerPrefix: string;

  /** Case-insensitive regex patterns on user input that trigger auto-routing. */
  autoRoutePatterns: string[];

  /** Show a confirmation dialog before each tool-based advisor call. */
  confirmBeforeCall: boolean;

  /** System prompt injected into advisor tool calls and auto-routed turns. */
  advisorSystemPrompt: string;

  /**
   * How much prior conversation to include when the advisor tool is invoked:
   *   "minimal"  – only what the LLM passes in the tool params
   *   "relevant" – last ~10 user/assistant message pairs
   *   "full"     – entire session history (may be expensive)
   */
  contextStrategy: "full" | "relevant" | "minimal";

  /** Show per-call and cumulative token/cost stats in tool output and status bar. */
  showUsageStats: boolean;

  /**
   * Max USD to spend on advisor tool calls in a single session.
   * null means unlimited. Auto-route turns are not counted (they use the main session).
   */
  sessionBudget: number | null;
}

export const CONFIG_DEFAULTS: AdvisorConfig = {
  advisorModel: "anthropic/claude-opus-4-5",
  advisorThinking: "high",
  triggerPrefix: ">>",
  autoRoutePatterns: [],
  confirmBeforeCall: false,
  advisorSystemPrompt:
    "You are a senior technical advisor. Provide thorough, well-reasoned analysis. " +
    "Be precise, actionable, and focus on correctness over brevity.",
  contextStrategy: "relevant",
  showUsageStats: true,
  sessionBudget: null,
};

export function loadConfig(extensionDir: string): AdvisorConfig {
  const configPath = join(extensionDir, "config.json");
  if (!existsSync(configPath)) return { ...CONFIG_DEFAULTS };
  try {
    const raw = JSON.parse(readFileSync(configPath, "utf-8")) as Partial<AdvisorConfig>;
    return { ...CONFIG_DEFAULTS, ...raw };
  } catch {
    return { ...CONFIG_DEFAULTS };
  }
}
