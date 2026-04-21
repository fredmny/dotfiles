// OpenCode plugin: Rename tmux window based on session status
// - Shows a spinner icon when OpenCode is working
// - Restores the original window name when idle
async function setTmuxWindowName($, name) {
  try {
    await $`tmux rename-window ${name}`
  } catch {
    // not in tmux, ignore
  }
}
export const TmuxStatusPlugin = async ({ $ }) => {
  // Save the original window name on init
  return {
    event: async ({ event }) => {
      if (event.type === "session.status") {
        await setTmuxWindowName($, " ⏳ oc")
      }
      if (event.type === "session.idle") {
        await setTmuxWindowName($, " ✅ oc")
      }
    },
  }
}
