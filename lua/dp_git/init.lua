-- Copyright (c) 2024 liudepei. All Rights Reserved.
-- create at 2024/04/07 16:50:37 Sunday

local M = {}

local sta, B = pcall(require, 'dp_base')

if not sta then return print('Dp_base is required!', debug.getinfo(1)['source']) end

M.source = B.getsource(debug.getinfo(1)['source'])
M.lua = B.getlua(M.source)

if B.check_plugins {
      'git@github.com:peter-lyr/dp_init',
      'git@github.com:peter-lyr/dp_telescope',
      -- 'lewis6991/gitsigns.nvim',
      'git@github.com:peter-lyr/gitsigns.nvim',
      'folke/which-key.nvim',
      'tpope/vim-fugitive',
      'paopaol/telescope-git-diffs.nvim',
    } then
  return
end

require 'which-key'.register {
  ['<leader>g<f1>'] = { function() B.jump_or_edit(M.source) end, 'open lua: ' .. M.lua, mode = { 'n', 'v', }, silent = true, },
}

require 'which-key'.register {
  ['<leader>g'] = { name = 'git', },
}

require 'dp_git.fugitive'
require 'dp_git.signs'
require 'dp_git.push'
require 'dp_git.show'
require 'dp_git.reset'
require 'dp_git.stash'
require 'dp_git.diffview'
require 'dp_git.dev'

return M
