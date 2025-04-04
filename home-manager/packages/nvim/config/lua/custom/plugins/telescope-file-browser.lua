return {
  'nvim-telescope/telescope-file-browser.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' },
  config = function()
    vim.keymap.set('n', '<space>fb', function()
      require('telescope').extensions.file_browser.file_browser()
    end)
    vim.keymap.set('n', '<space>fc', function()
      require('telescope').extensions.file_browser.file_browser {
        path = vim.fn.expand '%:p:h', -- Set the path to the directory of the current file
        select_buffer = true, -- Set select_buffer to true
      }
    end)
  end,
}
