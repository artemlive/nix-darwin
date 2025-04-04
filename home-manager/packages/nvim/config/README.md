# Kickstart Neovim Configuration

This repository contains my personal Neovim configuration. This configuration leverages the power of various Neovim plugins managed with `lazy.nvim`.
It's based on the kickstart repo by TJ DeVries.
## Features

- **Leader Key**: `<space>` set as the leader key for command shortcuts.
- **Nerd Font Integration**: Enhanced UI with Nerd Fonts for better iconography in plugins.
- **Enhanced UI**: Various UI improvements including mouse support, clipboard integration, and aesthetic enhancements.
- **Smart Case Searching**: Intelligent case-insensitive searching that switches to case-sensitive if the search pattern includes uppercase letters.
- **Split Management**: Improved split navigation and management.
- **Code Navigation**: Enhanced code navigation using Treesitter and LSP.
- **Development Utilities**: Integrated terminal, Git signs, and document/comment highlighting.

## Plugins

### File and Project Management
- **Neo-tree.nvim**: File explorer with support for Nerd Fonts and various custom integrations.
- **Telescope.nvim**: Extensible fuzzy finder for searching files, symbols, commands, and more.

### Coding and Syntax
- **Treesitter**: Syntax highlighting and language-specific features powered by tree-sitter grammars.
- **Toggleterm.nvim**: Seamless integration of terminal windows within the Neovim editor.

### User Interface
- **Bufferline.nvim**: Enhanced buffer line that allows easy navigation between multiple files.
- **Colortheme**: Manage and apply color themes to the Neovim editor.

### Development Utilities
- **Auto-session.lua**: Manages sessions automatically, saving and restoring your editor state.
- **Treesitter-context.lua**: Displays contextual information about the code block currently visible.

### Diagnostics and Git
- **Gitsigns.nvim**: Adds git related info in the gutter (e.g., added, modified lines) and other handy git utilities.

### Key Mapping and Shortcuts
- **Which-key.nvim**: Displays available keybindings in a popup. Configured to trigger with the leader key or automatically during typing.

## Installation

1. Ensure you have Neovim installed.
2. Clone this repository into your Neovim configuration directory:

   ```bash
   git clone https://github.com/your-username/your-repository ~/.config/nvim

