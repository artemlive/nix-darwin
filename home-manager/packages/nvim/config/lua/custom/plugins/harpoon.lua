return {
  'ThePrimeagen/harpoon',
  event = 'VeryLazy',
  config = function()
    require('harpoon').setup {
      menu = {
        width = vim.api.nvim_win_get_width(0) - 4,
      },
    }
    local mark = require 'harpoon.mark'
    local ui = require 'harpoon.ui'

    vim.keymap.set('n', '<leader>a', mark.add_file, { desc = 'Harpoon: Add File' })
    vim.keymap.set('n', '<leader>e', ui.toggle_quick_menu, { desc = 'Harpoon: Toggle Menu' })
    vim.keymap.set('n', '<C-n>', function()
      ui.nav_next()
    end, { desc = 'Harpoon: Next File' })
    vim.keymap.set('n', '<C-p>', function()
      ui.nav_prev()
    end, { desc = 'Harpoon: Previous File' })
  end,
}
