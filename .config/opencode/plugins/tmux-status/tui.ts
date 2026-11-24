// OpenCode plugin: rename the tmux window based on session status.
// - Prepends a status emoji when OpenCode is working or idle
// - Preserves the original window name
//
// OpenCode V2 plugin API. This lives in the TUI part so it runs inside the
// terminal client that owns the pane: process.env.TMUX_PANE identifies the
// window to rename, and the router tells us which session belongs to this pane
// (the server is shared by every client, so raw events are not enough).

import { spawnSync } from "node:child_process";
import { Plugin } from "@opencode/plugin/tui";

const PANE = process.env.TMUX_PANE || "";

// OpenCode V2 does not emit session.status / session.idle in practice; a run is
// bracketed by session.execution.* with inbox.delivered marking a new prompt.
const WORKING_EVENTS = new Set([
  "session.execution.started",
  "session.retry.scheduled",
  "session.inbox.delivered",
]);
const IDLE_EVENTS = new Set([
  "session.execution.succeeded",
  "session.execution.interrupted",
  "session.execution.failed",
]);

function tmux(args: string[]) {
  try {
    return spawnSync("tmux", args, { encoding: "utf8" });
  } catch {
    return null;
  }
}

function windowID(): string {
  const res = tmux(["display-message", "-p", "-t", PANE, "#{window_id}"]);
  return res && res.stdout ? res.stdout.trim() : "";
}

function getTmuxWindowName(): string {
  const res = tmux(["display-message", "-p", "-t", PANE, "#{window_name}"]);
  const name = res && res.stdout ? res.stdout.trim() : "";
  return name.replace(/^[⏳✅] /, "");
}

function setTmuxWindowName(name: string) {
  // Target the window that contains this pane; a bare rename-window would hit
  // whichever client tmux considers current.
  const id = windowID();
  if (!id) return;
  tmux(["rename-window", "-t", id, name]);
}

function rootOf(ctx: any, roots: Map<string, string>, sessionID: string) {
  if (!sessionID) return "";
  const known = roots.get(sessionID);
  if (known) return known;
  try {
    const root = ctx.data.session.root(sessionID);
    if (root) {
      roots.set(sessionID, root);
      return root;
    }
  } catch {
    // fall through
  }
  return sessionID;
}

function currentRoot(ctx: any, roots: Map<string, string>) {
  try {
    const route = ctx.ui.router.current();
    if (!route || route.type !== "session" || !route.sessionID) return "";
    return rootOf(ctx, roots, route.sessionID);
  } catch {
    return "";
  }
}

export default Plugin.define({
  id: "tmux-status.tui",
  setup(ctx: any) {
    if (!PANE) return;

    const roots = new Map<string, string>();
    let originalName = "";

    function setWorking() {
      if (!originalName) originalName = getTmuxWindowName();
      setTmuxWindowName(`⏳ ${originalName}`);
    }

    function setIdle() {
      if (!originalName) originalName = getTmuxWindowName();
      setTmuxWindowName(`✅ ${originalName}`);
      originalName = "";
    }

    const stop = ctx.data.listen((payload: any) => {
      try {
        const event = payload && payload.details;
        if (!event) return;
        const type = event.type;
        const data = event.data || {};

        if (type === "session.created") {
          const id = data.sessionID;
          if (!id) return;
          roots.set(id, data.parentID ? rootOf(ctx, roots, data.parentID) : id);
          return;
        }

        const working = WORKING_EVENTS.has(type);
        const idle = IDLE_EVENTS.has(type);
        if (!working && !idle) return;

        const root = currentRoot(ctx, roots);
        if (!root || data.sessionID !== root) return;

        if (working) setWorking();
        else setIdle();
      } catch {
        // not in tmux / weird window state: ignore
      }
    });

    return () => {
      try {
        stop();
      } catch {
        // ignore
      }
    };
  },
});
