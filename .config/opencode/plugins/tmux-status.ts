// OpenCode plugin: Rename tmux window based on session status
// - Prepends a status emoji when OpenCode is working or idle
// - Preserves the original window name
async function getTmuxWindowName($): Promise<string> {
  try {
    const result = await $`tmux display-message -p ${'#W'}`.quiet()
    return result.text().trim().replace(/^[⏳✅] /, "")
  } catch {
    return ""
  }
}

async function setTmuxWindowName($, name) {
  try {
    await $`tmux rename-window ${name}`.quiet()
  } catch {
    // not in tmux, ignore
  }
}

export const TmuxStatusPlugin = async ({ $ }) => {
  let originalName = ""

  return {
    event: async ({ event }) => {
      if (event.type === "session.status") {
        if (!originalName) {
          originalName = await getTmuxWindowName($)
        }
        await setTmuxWindowName($, `⏳ ${originalName}`)
      }
      if (event.type === "session.idle") {
        if (!originalName) {
          originalName = await getTmuxWindowName($)
        }
        await setTmuxWindowName($, `✅ ${originalName}`)
        originalName = ""
      }
    },
  }
}
