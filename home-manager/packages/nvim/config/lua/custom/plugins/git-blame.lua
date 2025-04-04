vim.api.nvim_set_keymap('n', '<Leader>gb', ':GitBlameToggle <CR>', { silent = true, noremap = true })
vim.api.nvim_set_keymap('n', '<Leader>gc', ':GitBlameOpenCommitURL <CR>', { silent = true, noremap = true })
return {
  'f-person/git-blame.nvim',
}
