return {
  'lommix/godot.nvim',
  lazy = true,
  cmd = { 'GodotDebug', 'GodotBreakAtCursor', 'GodotStep', 'GodotQuit', 'GodotContinue' },
  -- Path to your Godot executable
  bin = '/Applications/Godot.app/Contents/MacOS/Godot',

  -- DAP configuration
  dap = {
    host = '127.0.0.1',
    port = 6006,
  },

  -- GUI settings for console (passed to nvim_open_win)
  gui = {
    console_config = {
      anchor = 'SW',
      border = 'double',
      col = 1,
      height = 10,
      relative = 'editor',
      row = 99999,
      style = 'minimal',
      width = 99999,
    },
  },

  -- Expose user commands automatically (optional)
  expose_commands = true,
}
