-- Copyright (c) 2024 liudepei. All Rights Reserved.
-- create at 2024/04/07 16:50:37 Sunday

local M = {}

local dp_gitsigns = require 'dp_gitsigns'

M.defaults = {
  ['<leader>'] = {
    k = { function() return dp_gitsigns.leader_k() end, 'git.signs: prev_hunk', expr = true, mode = { 'n', 'v', }, },
    j = { function() return dp_gitsigns.leader_j() end, 'git.signs: next_hunk', expr = true, mode = { 'n', 'v', }, },
    -- g = {
    --   name = 'git',
    -- },
  },
}

function M.setup(options)
  local sta, whichkey = pcall(require, 'which-key')
  if not sta then
    vim.notify 'no which-key found, setup for dp_git failed!'
    return
  end
  whichkey.register(vim.tbl_deep_extend('force', {}, M.defaults, options or {}))
end

return M
