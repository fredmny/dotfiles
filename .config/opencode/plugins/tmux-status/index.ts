export default {
  id: "tmux-status",
  setup() {
    // The window renamer runs in the TUI part (tui.ts) so it targets the pane
    // that owns each session. Nothing to do in the shared server.
  },
}
