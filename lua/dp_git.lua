-- Copyright (c) 2024 liudepei. All Rights Reserved.
-- create at 2024/04/07 16:50:37 Sunday

local M = {}

local sta, B = pcall(require, 'dp_base')

if not sta then return print('Dp_base is required!', debug.getinfo(1)['source']) end

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
  ['<leader>g'] = { name = 'git', },
}

require 'dp_git_signs'
require 'dp_git_push'
require 'dp_git_show'
require 'dp_git_reset'
require 'dp_git_stash'
require 'dp_git_diffview'

return M
