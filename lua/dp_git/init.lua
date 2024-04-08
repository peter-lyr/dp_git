-- Copyright (c) 2024 liudepei. All Rights Reserved.
-- create at 2024/04/07 16:50:37 Sunday

local M = {}

local sta, B = pcall(require, 'dp_base')

if not sta then return print('Dp_base is required!', debug.getinfo(1)['source']) end

if B.check_plugins {
      'folke/which-key.nvim',
    } then
  return
end

B.merge_other_functions(M, {
  require 'dp_git.gitsigns',
})

M.defaults = {
  ['<leader>'] = {
    k = { function() return M.leader_k() end, 'git.signs: prev_hunk', expr = true, mode = { 'n', 'v', }, },
    j = { function() return M.leader_j() end, 'git.signs: next_hunk', expr = true, mode = { 'n', 'v', }, },
    -- g = {
    --   name = 'git',
    -- },
  },
}

function M.setup(options)
  require 'which-key'.register(vim.tbl_deep_extend('force', {}, M.defaults, options or {}))
end

return M
