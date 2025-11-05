return {
  'pwntester/octo.nvim',
  requires = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'ibhagwan/fzf-lua',
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    require('octo').setup {
      mappings_disable_default = false,
      default_merge_method = 'squash',
      default_delete_branch = true,
    }
  end,
  keys = {
    { '<leader>gp', '<cmd>Octo pr list<CR>', desc = 'List PRs (Octo)' },
    { '<leader>gP', '<cmd>Octo pr search<CR>', desc = 'Search PRs (Octo)' },
    { '<leader>gS', '<cmd>Octo search<CR>', desc = 'Search (Octo)' },
    { '<leader>gC', '<cmd>Octo pr create draft<cr>', desc = '[G]it Pull Request [C]reate' },
    { '<leader>gR', '<cmd>Octo pr ready<cr>', desc = '[G]it Pull Request [R]eady' },

    { '<localleader>a', '', desc = '+assignee (Octo)', ft = 'octo' },
    { '<localleader>c', '', desc = '+comment/code (Octo)', ft = 'octo' },
    { '<localleader>l', '', desc = '+label (Octo)', ft = 'octo' },
    { '<localleader>i', '', desc = '+issue (Octo)', ft = 'octo' },
    { '<localleader>r', '', desc = '+react (Octo)', ft = 'octo' },
    { '<localleader>p', '', desc = '+pr (Octo)', ft = 'octo' },
    { '<localleader>pr', '', desc = '+rebase (Octo)', ft = 'octo' },
    { '<localleader>ps', '', desc = '+squash (Octo)', ft = 'octo' },
    { '<localleader>v', '', desc = '+review (Octo)', ft = 'octo' },
    { '<localleader>g', '', desc = '+goto_issue (Octo)', ft = 'octo' },
    { '@', '@<C-x><C-o>', mode = 'i', ft = 'octo', silent = true },
    { '#', '#<C-x><C-o>', mode = 'i', ft = 'octo', silent = true },
  },
  config = function()
    require('octo').setup {}
  end,
}
