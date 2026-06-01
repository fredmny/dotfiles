/**
 * Advisor Mode Extension
 *
 * Gives the working model access to a more powerful "advisor" model for
 * complex reasoning tasks — analogous to Claude Code's advisor mode.
 *
 * TWO MECHANISMS
 * ──────────────
 * 1. advisor tool  — The worker LLM explicitly calls it when it needs deep
 *    analysis. The advisor runs in an isolated subprocess (separate context
 *    window, its own system prompt). Great for targeted queries during a
 *    long coding session without contaminating the main context.
 *
 * 2. Auto-route (>> prefix / patterns)  — A user-typed prefix (default ">>")
 *    or configured regex patterns cause the *entire* turn to run on the
 *    advisor model via pi.setModel(). The advisor sees full tool access,
 *    history, and the real context. After the turn ends, the worker model
 *    is restored automatically.
 *
 * QUICK START
 * ───────────
 *   /advisor model anthropic/claude-opus-4-5   # set advisor
 *   >> design the authentication system         # route full turn to advisor
 *   /advisor stats                             # see usage & cost
 *   Ctrl+Shift+A                               # toggle auto-route prefix on/off
 *
 * CONFIGURATION
 * ─────────────
 *   Edit ~/.pi/agent/extensions/advisor/config.json (see config.ts for all fields).
 *   Runtime changes (via /advisor subcommands) are in-memory; they reset on /reload.
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { getMarkdownTheme } from "@earendil-works/pi-coding-agent";
import { Container, Markdown, Spacer, Text } from "@earendil-works/pi-tui";
import { StringEnum } from "@earendil-works/pi-ai";
import { Type } from "typebox";
import { dirname } from "node:path";
import { fileURLToPath } from "node:url";

import { loadConfig, CONFIG_DEFAULTS, type AdvisorConfig } from "./config.ts";
import { runAdvisorCall } from "./advisor-client.ts";
import { extractContext } from "./context.ts";
import { createUsageTracker, type UsageTracker, type CallUsage } from "./usage.ts";

// ─── Constants ───────────────────────────────────────────────────────────────

const EXTENSION_DIR = dirname(fileURLToPath(import.meta.url));
const USAGE_ENTRY_TYPE = "advisor-usage";

// ─── Tool result details shape (used for typed rendering) ────────────────────

interface AdvisorToolDetails {
  status: "calling" | "streaming" | "done" | "error" | "cancelled" | "budget_exceeded";
  model?: string;
  question?: string;
  format?: string;
  error?: string;
  usage?: { inputTokens: number; outputTokens: number; cost: number };
  sessionUsage?: { callCount: number; totalCost: number };
}

// ─── Extension factory ───────────────────────────────────────────────────────

export default function advisorExtension(pi: ExtensionAPI): void {
  let config: AdvisorConfig = loadConfig(EXTENSION_DIR);
  let usage: UsageTracker = createUsageTracker();

  // Auto-route state — lives only for the duration of one agent run
  let autoRoutePending = false;
  let autoRoutingActive = false;
  let savedWorkerModel: { provider: string; id: string } | null = null;
  let savedWorkerThinking: string | null = null;

  // ── CLI flag: --advisor <provider/model-id> ─────────────────────────────

  pi.registerFlag("advisor", {
    description: 'Override the advisor model for this session (e.g. --advisor anthropic/claude-opus-4-5)',
    type: "string",
  });

  const flagModel = pi.getFlag("advisor") as string | undefined;
  if (flagModel) config.advisorModel = flagModel;

  // ── Session lifecycle ───────────────────────────────────────────────────

  pi.on("session_start", async (_event, ctx) => {
    // Re-read config from disk (supports /reload picking up edits)
    config = loadConfig(EXTENSION_DIR);
    if (flagModel) config.advisorModel = flagModel; // CLI flag wins over config.json

    // Rebuild usage from persisted entries so stats survive compaction
    usage = createUsageTracker();
    for (const entry of ctx.sessionManager.getEntries()) {
      const e = entry as { type: string; customType?: string; data?: unknown };
      if (e.type === "custom" && e.customType === USAGE_ENTRY_TYPE) {
        usage.restore(e.data as Parameters<typeof usage.restore>[0]);
      }
    }

    updateStatus(ctx);
  });

  pi.on("session_shutdown", async () => {
    // Always reset transient auto-route state on teardown
    autoRoutePending = false;
    autoRoutingActive = false;
    savedWorkerModel = null;
    savedWorkerThinking = null;
  });

  // ── Auto-route: intercept user input ───────────────────────────────────

  pi.on("input", async (event) => {
    const { triggerPrefix, autoRoutePatterns } = config;

    if (triggerPrefix && event.text.startsWith(triggerPrefix)) {
      autoRoutePending = true;
      return {
        action: "transform" as const,
        text: event.text.slice(triggerPrefix.length).trimStart(),
      };
    }

    if (autoRoutePatterns.length > 0) {
      const matched = autoRoutePatterns.some((p) => {
        try {
          return new RegExp(p, "i").test(event.text);
        } catch {
          return false;
        }
      });
      if (matched) autoRoutePending = true;
    }

    return { action: "continue" as const };
  });

  // ── model_select: keep footer status in sync when model changes ──────────

  pi.on("model_select", async (_event, ctx) => {
    // Fires when we call pi.setModel() ourselves, or when user switches via
    // Ctrl+P. Either way, recalculate the footer so it stays accurate.
    updateStatus(ctx);
  });

  // ── Auto-route: switch model before the agent loop starts ──────────────

  pi.on("before_agent_start", async (event, ctx) => {
    if (!autoRoutePending) return;
    autoRoutePending = false;

    const parts = config.advisorModel.split("/");
    const provider = parts[0];
    const modelId = parts.slice(1).join("/");

    if (!provider || !modelId) {
      ctx.ui.notify(
        `Advisor: invalid model "${config.advisorModel}" — expected "provider/model-id". ` +
          `Run /advisor model <id> to fix.`,
        "error",
      );
      return;
    }

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const registry = (ctx as any).modelRegistry;
    const advisorModel = registry?.find?.(provider, modelId);
    if (!advisorModel) {
      ctx.ui.notify(
        `Advisor: model "${config.advisorModel}" not found. ` +
          `Check pi --list-models and run /advisor model <id>.`,
        "error",
      );
      return;
    }

    // Save worker state for restoration after this agent run
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const currentModel = (ctx as any).model as { provider?: string; id?: string } | undefined;
    if (currentModel?.provider && currentModel?.id) {
      savedWorkerModel = { provider: currentModel.provider, id: currentModel.id };
    }
    savedWorkerThinking = pi.getThinkingLevel();

    const switched = await pi.setModel(advisorModel);
    if (!switched) {
      ctx.ui.notify(
        `Advisor: no API key available for "${config.advisorModel}"`,
        "error",
      );
      savedWorkerModel = null;
      savedWorkerThinking = null;
      return;
    }

    if (config.advisorThinking !== "off") {
      pi.setThinkingLevel(config.advisorThinking as Parameters<typeof pi.setThinkingLevel>[0]);
    }

    autoRoutingActive = true;
    ctx.ui.setStatus("advisor-active", `🔮 advisor → ${modelId}`);
    // Widget below the editor — impossible to miss during the turn
    ctx.ui.setWidget(
      "advisor-turn",
      (_tui, theme) =>
        new Text(
          theme.fg("accent", "🔮 Advisor turn") +
            theme.fg("muted", ` — ${modelId}`) +
            theme.fg("dim", "  (Ctrl+C to abort)"),
          0,
          0,
        ),
      { placement: "belowEditor" },
    );
    // Replace the default "Working…" spinner label
    ctx.ui.setWorkingMessage(`🔮 ${modelId}…`);
    ctx.ui.notify(`Routing to advisor: ${config.advisorModel}`, "info");

    if (config.advisorSystemPrompt.trim()) {
      return { systemPrompt: event.systemPrompt + "\n\n" + config.advisorSystemPrompt };
    }
  });

  // ── Auto-route: restore worker model after the agent run completes ──────

  pi.on("agent_end", async (_event, ctx) => {
    if (!autoRoutingActive) return;
    autoRoutingActive = false;

    ctx.ui.setStatus("advisor-active", undefined);
    ctx.ui.setWidget("advisor-turn", undefined);
    ctx.ui.setWorkingMessage(); // restore default

    if (savedWorkerModel) {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const registry = (ctx as any).modelRegistry;
      const workerModel = registry?.find?.(savedWorkerModel.provider, savedWorkerModel.id);
      if (workerModel) {
        await pi.setModel(workerModel);
        ctx.ui.notify(
          `Returned to ${savedWorkerModel.provider}/${savedWorkerModel.id}`,
          "info",
        );
      }
      savedWorkerModel = null;
    }

    if (savedWorkerThinking !== null) {
      pi.setThinkingLevel(savedWorkerThinking as Parameters<typeof pi.setThinkingLevel>[0]);
      savedWorkerThinking = null;
    }
  });

  // ── advisor tool ─────────────────────────────────────────────────────────

  pi.registerTool({
    name: "advisor",
    label: "Advisor",
    description: [
      "Consult a more powerful advisor model for complex reasoning tasks.",
      "Runs in an isolated subprocess with its own context window.",
      "Use for: architecture decisions, security reviews, complex debugging, multi-step planning.",
      "Do NOT use for simple file reads, routine edits, or factual lookups — handle those directly.",
    ].join(" "),
    promptSnippet: "Consult a more powerful model for deep reasoning and complex analysis",
    promptGuidelines: [
      "Use advisor for architectural decisions, security reviews, complex debugging, or multi-step planning that benefits from deeper reasoning.",
      "Do NOT use advisor for simple file reads, routine edits, or factual questions — handle those directly.",
      "When calling advisor, make the question self-contained; include relevant code, constraints, or error messages in context.",
      "After advisor responds, proceed with implementation using the provided guidance.",
    ],
    parameters: Type.Object({
      question: Type.String({
        description:
          "Clear, self-contained question or task for the advisor. Include all relevant details.",
      }),
      context: Type.Optional(
        Type.String({
          description:
            "Additional context: relevant code snippets, constraints, prior decisions, error messages.",
        }),
      ),
      format: Type.Optional(
        StringEnum(["analysis", "plan", "review", "decision"] as const, {
          description:
            "Expected response type: analysis, plan, review, or decision. Helps the advisor tailor its output.",
        }),
      ),
    }),

    async execute(_toolCallId, params, signal, onUpdate, ctx) {
      // ── Budget gate ──────────────────────────────────────────────────────
      if (config.sessionBudget !== null && usage.totalCost >= config.sessionBudget) {
        return {
          content: [
            {
              type: "text" as const,
              text:
                `Advisor session budget ($${config.sessionBudget.toFixed(2)}) exhausted. ` +
                `Spent so far: $${usage.totalCost.toFixed(4)}. ` +
                `Run /advisor reset to clear, or /advisor budget off to remove the limit.`,
            },
          ],
          details: { status: "budget_exceeded" } as AdvisorToolDetails,
        };
      }

      // ── Confirmation gate ────────────────────────────────────────────────
      if (config.confirmBeforeCall && ctx.hasUI) {
        const preview =
          params.question.slice(0, 120) +
          (params.question.length > 120 ? "…" : "");
        const ok = await ctx.ui.confirm(
          "Call Advisor?",
          `Model: ${config.advisorModel}\n\nQuestion: ${preview}`,
        );
        if (!ok) {
          return {
            content: [{ type: "text" as const, text: "Advisor call cancelled." }],
            details: { status: "cancelled" } as AdvisorToolDetails,
          };
        }
      }

      // ── Build prompt ─────────────────────────────────────────────────────
      const conversationContext = extractContext(ctx.sessionManager, config.contextStrategy);
      const prompt = buildAdvisorPrompt(params, conversationContext);

      onUpdate?.({
        content: [{ type: "text" as const, text: "Consulting advisor…" }],
        details: { status: "calling", model: config.advisorModel } as AdvisorToolDetails,
      });

      // ── Call advisor subprocess ──────────────────────────────────────────
      const result = await runAdvisorCall({
        prompt,
        model: config.advisorModel,
        systemPrompt: config.advisorSystemPrompt,
        cwd: ctx.cwd,
        signal,
        onProgress: (text) => {
          onUpdate?.({
            content: [{ type: "text" as const, text }],
            details: { status: "streaming", model: config.advisorModel } as AdvisorToolDetails,
          });
        },
      });

      // ── Handle failure ───────────────────────────────────────────────────
      if (!result.success) {
        return {
          content: [
            {
              type: "text" as const,
              text: `Advisor error: ${result.error ?? "unknown error"}`,
            },
          ],
          details: {
            status: "error",
            error: result.error,
            model: config.advisorModel,
          } as AdvisorToolDetails,
        };
      }

      // ── Record usage and persist ─────────────────────────────────────────
      if (result.usage) {
        usage.record(result.usage as CallUsage);
        pi.appendEntry(USAGE_ENTRY_TYPE, usage.toData());
        updateStatus(ctx);
      }

      return {
        content: [{ type: "text" as const, text: result.response }],
        details: {
          status: "done",
          model: result.model ?? config.advisorModel,
          question: params.question,
          format: params.format,
          usage: result.usage,
          sessionUsage: { callCount: usage.callCount, totalCost: usage.totalCost },
        } as AdvisorToolDetails,
      };
    },

    renderCall(args, theme) {
      const format = args.format ? theme.fg("muted", ` [${args.format}]`) : "";
      const question = args.question
        ? args.question.length > 80
          ? `${args.question.slice(0, 80)}…`
          : args.question
        : "…";
      return new Text(
        theme.fg("toolTitle", theme.bold("advisor")) + format + "\n  " + theme.fg("dim", question),
        0,
        0,
      );
    },

    renderResult(result, { expanded }, theme) {
      const details = result.details as AdvisorToolDetails | undefined;
      const status = details?.status;

      // Loading / streaming
      if (!status || status === "calling" || status === "streaming") {
        const msg =
          result.content[0]?.type === "text"
            ? result.content[0].text
            : "Consulting advisor…";
        return new Text(theme.fg("warning", `⏳ ${msg}`), 0, 0);
      }

      if (status === "budget_exceeded") {
        return new Text(theme.fg("error", "⚠ Advisor session budget exhausted"), 0, 0);
      }

      if (status === "cancelled") {
        return new Text(theme.fg("muted", "— Advisor call cancelled"), 0, 0);
      }

      if (status === "error") {
        return new Text(
          theme.fg("error", `✗ Advisor error: ${details?.error ?? "unknown"}`),
          0,
          0,
        );
      }

      // Done
      const responseText =
        result.content[0]?.type === "text" ? result.content[0].text : "";
      const modelShort =
        (details?.model ?? config.advisorModel).split("/").pop() ?? "advisor";
      const callN = details?.sessionUsage?.callCount;
      const badge = callN != null ? theme.fg("dim", ` #${callN}`) : "";

      if (expanded) {
        const mdTheme = getMarkdownTheme();
        const container = new Container();

        container.addChild(
          new Text(
            theme.fg("success", "✓ ") +
              theme.fg("toolTitle", theme.bold("Advisor")) +
              theme.fg("muted", ` (${modelShort})`) +
              badge,
            0,
            0,
          ),
        );

        if (details?.question) {
          container.addChild(new Spacer(1));
          container.addChild(new Text(theme.fg("muted", "── Question"), 0, 0));
          container.addChild(new Text(theme.fg("dim", details.question), 0, 0));
        }

        container.addChild(new Spacer(1));
        container.addChild(new Text(theme.fg("muted", "── Response"), 0, 0));
        container.addChild(new Markdown(responseText.trim(), 0, 0, mdTheme));

        if (details?.usage && config.showUsageStats) {
          const u = details.usage;
          const parts: string[] = [];
          if (u.inputTokens) parts.push(`↑${u.inputTokens.toLocaleString()}`);
          if (u.outputTokens) parts.push(`↓${u.outputTokens.toLocaleString()}`);
          if (u.cost) parts.push(`$${u.cost.toFixed(4)}`);
          if (parts.length > 0) {
            container.addChild(new Spacer(1));
            container.addChild(new Text(theme.fg("dim", parts.join("  ")), 0, 0));
          }
        }

        return container;
      }

      // Collapsed
      const lines = responseText.split("\n").filter((l) => l.trim());
      const preview = lines.slice(0, 4).join("\n");
      const remaining = lines.length - 4;

      let text =
        theme.fg("success", "✓ ") +
        theme.fg("toolTitle", theme.bold("Advisor")) +
        theme.fg("muted", ` (${modelShort})`) +
        badge;

      text += "\n" + theme.fg("toolOutput", preview);

      if (remaining > 0) {
        text +=
          "\n" +
          theme.fg(
            "muted",
            `  … ${remaining} more line${remaining > 1 ? "s" : ""} (Ctrl+O to expand)`,
          );
      }

      if (config.showUsageStats && details?.usage?.cost) {
        text += "\n" + theme.fg("dim", `$${details.usage.cost.toFixed(4)}`);
      }

      return new Text(text, 0, 0);
    },
  });

  // ── /advisor command ─────────────────────────────────────────────────────

  pi.registerCommand("advisor", {
    description:
      "Advisor mode. Subcommands: stats, model [id], thinking [level], budget [amount|off], prefix [str|off], reset, help",
    handler: async (args, ctx) => {
      const parts = (args ?? "").trim().split(/\s+/).filter(Boolean);
      const sub = parts[0] ?? "stats";

      switch (sub) {
        case "stats":
        case "": {
          showStats(ctx);
          break;
        }

        case "model": {
          if (parts[1]) {
            config.advisorModel = parts[1];
            updateStatus(ctx); // clear any stale warning immediately
            ctx.ui.notify(`Advisor model set to: ${config.advisorModel}`, "info");
          } else {
            ctx.ui.notify(`Current advisor model: ${config.advisorModel}`, "info");
          }
          break;
        }

        case "thinking": {
          if (parts[1]) {
            config.advisorThinking = parts[1] as AdvisorConfig["advisorThinking"];
            ctx.ui.notify(`Advisor thinking level: ${config.advisorThinking}`, "info");
          } else {
            ctx.ui.notify(
              `Advisor thinking level: ${config.advisorThinking}`,
              "info",
            );
          }
          break;
        }

        case "budget": {
          if (parts[1] === "off" || parts[1] === "none") {
            config.sessionBudget = null;
            updateStatus(ctx);
            ctx.ui.notify("Session budget removed (unlimited)", "info");
          } else if (parts[1]) {
            const amount = parseFloat(parts[1]);
            if (!isNaN(amount) && amount > 0) {
              config.sessionBudget = amount;
              updateStatus(ctx);
              ctx.ui.notify(`Session budget set to $${amount.toFixed(2)}`, "info");
            } else {
              ctx.ui.notify(
                "Invalid amount. Example: /advisor budget 2.00",
                "error",
              );
            }
          } else {
            ctx.ui.notify(
              config.sessionBudget !== null
                ? `Session budget: $${config.sessionBudget.toFixed(2)}`
                : "No session budget (unlimited)",
              "info",
            );
          }
          break;
        }

        case "prefix": {
          if (parts[1] === "off" || parts[1] === "none") {
            config.triggerPrefix = "";
            ctx.ui.setStatus("advisor-prefix", undefined);
            ctx.ui.notify("Auto-route prefix disabled", "info");
          } else if (parts[1]) {
            config.triggerPrefix = parts[1];
            ctx.ui.notify(
              `Auto-route prefix set to: "${config.triggerPrefix}"`,
              "info",
            );
          } else {
            ctx.ui.notify(
              config.triggerPrefix
                ? `Auto-route prefix: "${config.triggerPrefix}"`
                : "Auto-route prefix disabled",
              "info",
            );
          }
          break;
        }

        case "reset": {
          usage = createUsageTracker();
          updateStatus(ctx);
          ctx.ui.notify("Advisor usage stats reset", "info");
          break;
        }

        case "help": {
          ctx.ui.notify(
            [
              "Advisor mode commands:",
              "  /advisor              — show session stats",
              `  /advisor model <id>   — set advisor model (current: ${config.advisorModel})`,
              `  /advisor thinking <l> — thinking level off/minimal/low/medium/high/xhigh (current: ${config.advisorThinking})`,
              `  /advisor budget <$>   — set max USD/session for tool calls, e.g. 2.00 or off (current: ${config.sessionBudget ?? "unlimited"})`,
              `  /advisor prefix <str> — auto-route prefix, e.g. >> or off (current: "${config.triggerPrefix || "disabled"}")`,
              "  /advisor reset        — reset session usage counters",
              "",
              "Auto-route: start your message with the prefix to route the full turn to the advisor.",
              "            Advisor tool: ask the LLM to use the advisor tool for isolated deep analysis.",
              "Shortcut:   Ctrl+Shift+A toggles the auto-route prefix on/off.",
            ].join("\n"),
            "info",
          );
          break;
        }

        default: {
          ctx.ui.notify(
            `Unknown subcommand: "${sub}". Run /advisor help for usage.`,
            "error",
          );
        }
      }
    },
  });

  // ── Ctrl+Shift+A: toggle auto-route prefix ──────────────────────────────

  pi.registerShortcut("ctrl+shift+a", {
    description: "Toggle advisor auto-route prefix on/off",
    handler: async (ctx) => {
      // Use the on-disk config's prefix as the canonical "enabled" value
      const defaultPrefix =
        loadConfig(EXTENSION_DIR).triggerPrefix || CONFIG_DEFAULTS.triggerPrefix;

      if (config.triggerPrefix) {
        config.triggerPrefix = "";
        ctx.ui.setStatus("advisor-prefix", undefined);
        ctx.ui.notify("Advisor auto-route disabled", "info");
      } else {
        config.triggerPrefix = defaultPrefix;
        ctx.ui.notify(
          `Advisor auto-route enabled — prefix: "${defaultPrefix}"`,
          "info",
        );
        ctx.ui.setStatus("advisor-prefix", `advisor: "${defaultPrefix}"`);
      }
    },
  });

  // ── Helpers ──────────────────────────────────────────────────────────────

  function updateStatus(ctx: ExtensionContext): void {
    const modelConfigured = Boolean(config.advisorModel && config.advisorModel.includes("/"));

    if (!modelConfigured) {
      ctx.ui.setStatus("advisor", "⚠ advisor: run /advisor model <provider/id>");
      return;
    }

    const modelShort = config.advisorModel.split("/").pop() ?? config.advisorModel;

    if (usage.callCount === 0) {
      // Always visible once configured — users know the advisor is ready
      ctx.ui.setStatus("advisor", `🔮 ${modelShort}`);
      return;
    }

    const parts = [`🔮 ${modelShort}`, `${usage.callCount}×`];

    if (config.showUsageStats && usage.totalCost > 0) {
      parts.push(`$${usage.totalCost.toFixed(4)}`);
    }

    if (config.sessionBudget !== null) {
      parts.push(`/ $${config.sessionBudget.toFixed(2)}`);
    }

    ctx.ui.setStatus("advisor", parts.join(" · "));
  }

  function showStats(ctx: ExtensionContext): void {
    const lines = [
      `Advisor model:   ${config.advisorModel}`,
      `Thinking level:  ${config.advisorThinking}`,
      `Context strategy: ${config.contextStrategy}`,
      `Auto-route prefix: "${config.triggerPrefix || "disabled"}"`,
      "",
    ];

    if (usage.callCount === 0) {
      lines.push("No advisor tool calls this session.");
    } else {
      lines.push(`Tool calls this session: ${usage.callCount}`);
      lines.push(
        `Tokens:  ↑${usage.totalInputTokens.toLocaleString()} in  ↓${usage.totalOutputTokens.toLocaleString()} out`,
      );
      if (usage.totalCacheRead > 0 || usage.totalCacheWrite > 0) {
        lines.push(
          `Cache:   ${usage.totalCacheRead.toLocaleString()} read  ${usage.totalCacheWrite.toLocaleString()} write`,
        );
      }
      if (usage.totalCost > 0) {
        lines.push(`Cost:    $${usage.totalCost.toFixed(4)}`);
      }
      if (config.sessionBudget !== null) {
        const remaining = Math.max(0, config.sessionBudget - usage.totalCost);
        lines.push(
          `Budget:  $${usage.totalCost.toFixed(4)} / $${config.sessionBudget.toFixed(2)} ($${remaining.toFixed(4)} remaining)`,
        );
      }
    }

    ctx.ui.notify(lines.join("\n"), "info");
  }


}

// ─── Prompt assembly (module-level, no state) ─────────────────────────────────

function buildAdvisorPrompt(
  params: { question: string; context?: string; format?: string },
  conversationContext: string,
): string {
  const sections: string[] = [];

  if (conversationContext) {
    sections.push("## Conversation Context\n\n" + conversationContext);
  }

  if (params.context) {
    sections.push("## Additional Context\n\n" + params.context);
  }

  sections.push("## Question\n\n" + params.question);

  if (params.format) {
    const formatInstructions: Record<string, string> = {
      analysis:
        "Provide a thorough technical analysis covering pros, cons, risks, and a clear recommendation.",
      plan: "Provide a concrete step-by-step implementation plan with explicit actions and acceptance criteria.",
      review:
        "Provide a structured review identifying specific issues, risks, and actionable improvement suggestions.",
      decision:
        "Analyze the available options and provide a clear, justified recommendation with reasoning.",
    };
    const instruction = formatInstructions[params.format];
    if (instruction) {
      sections.push("## Expected Format\n\n" + instruction);
    }
  }

  return sections.join("\n\n");
}
