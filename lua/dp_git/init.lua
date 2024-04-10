-- Copyright (c) 2024 liudepei. All Rights Reserved.
-- create at 2024/04/07 16:50:37 Sunday

local M = {}

local sta, B = pcall(require, 'dp_base')

if not sta then return print('Dp_base is required!', debug.getinfo(1)['source']) end

if B.check_plugins {
      'folke/which-key.nvim',
      'dp_telescope',
      -- 'lewis6991/gitsigns.nvim',
      'peter-lyr/gitsigns.nvim',
      'tpope/vim-fugitive',
    } then
  return
end

B.merge_other_functions(M, {
  require 'dp_git.gitsigns',
  require 'dp_git.gitpush',
})

M.defaults = {
  ['<leader>'] = {
    k = { function() return M.leader_k() end, 'git.signs: prev_hunk', expr = true, mode = { 'n', 'v', }, },
    j = { function() return M.leader_j() end, 'git.signs: next_hunk', expr = true, mode = { 'n', 'v', }, },
    g = {
      name = 'git',
      ['a'] = { function() M.addcommitpush() end, 'git.push: addcommitpush', mode = { 'n', 'v', }, silent = true, },
      ['b'] = { function() M.git_browser() end, 'git.push: browser', mode = { 'n', 'v', }, silent = true, },
      ['c'] = { function() M.commit_push() end, 'git.push: commit_push', mode = { 'n', 'v', }, silent = true, },
      ['l'] = { function() M.lazygit() end, 'git.lazy: lazygit', mode = { 'n', 'v', }, silent = true, },
      ['p'] = { function() M.pull() end, 'git.push: pull', mode = { 'n', 'v', }, silent = true, },
      ['<c-0>'] = { function() M.addcommitpush_parentheses() end, 'git.push: addcommitpush parentheses', mode = { 'n', 'v', }, silent = true, },
      ['<c-4>'] = { function() M.addcommitpush_cWORD() end, 'git.push: addcommitpush cWORD', mode = { 'n', 'v', }, silent = true, },
      ['<c-\'>'] = { function() M.addcommitpush_single_quote() end, 'git.push: addcommitpush single_quote', mode = { 'n', 'v', }, silent = true, },
      ['<c-]>'] = { function() M.addcommitpush_bracket() end, 'git.push: addcommitpush bracket', mode = { 'n', 'v', }, silent = true, },
      ['<c-`>'] = { function() M.addcommitpush_back_quote() end, 'git.push: addcommitpush back_quote', mode = { 'n', 'v', }, silent = true, },
      ['<c-a>'] = { function() M.addall() end, 'git.push: addall', mode = { 'n', 'v', }, silent = true, },
      ['<c-e>'] = { function() M.addcommitpush_cword() end, 'git.push: addcommitpush cword', mode = { 'n', 'v', }, silent = true, },
      ['<c-l>'] = { function() M.addcommitpush_curline() end, 'git.push: addcommitpush curline', mode = { 'n', 'v', }, silent = true, },
      ['<c-p>'] = { function() M.pull_all() end, 'git.push: pull_all', mode = { 'n', 'v', }, silent = true, },
      ['<c-s-.>'] = { function() M.addcommitpush_angle_bracket() end, 'git.push: addcommitpush angle_bracket', mode = { 'n', 'v', }, silent = true, },
      ['<c-s-\'>'] = { function() M.addcommitpush_double_quote() end, 'git.push: addcommitpush double_quote', mode = { 'n', 'v', }, silent = true, },
      ['<c-s-]>'] = { function() M.addcommitpush_brace() end, 'git.push: addcommitpush brace', mode = { 'n', 'v', }, silent = true, },
      --
      ['d'] = { function() M.diffthis() end, 'git.signs: diffthis', mode = { 'n', }, silent = true, },
      ['e'] = { function() M.toggle_deleted() end, 'git.signs: toggle_deleted', mode = { 'n', 'v', }, silent = true, },
      ['r'] = { function() M.reset_hunk_v() end, 'git.signs: reset_hunk_v', mode = { 'v', }, silent = true, },
      ['s'] = { function() M.stage_hunk_v() end, 'git.signs: stage_hunk_v', mode = { 'v', }, silent = true, },
      ['u'] = { function() M.undo_stage_hunk() end, 'git.signs: undo_stage_hunk', mode = { 'n', }, silent = true, },
      g = {
        name = 'git.push',
        ['<c-g>'] = { function() M.graph_start() end, 'git.push: graph_start', mode = { 'n', 'v', }, silent = true, },
        ['C'] = { function() M.clone() end, 'git.push: clone', mode = { 'n', 'v', }, silent = true, },
        ['D'] = { function() M.clean_ignored_files_and_folders() end, 'git.push: clean_ignored_files_and_folders', mode = { 'n', 'v', }, silent = true, },
        ['a'] = { function() M.addcommitpush(nil, 1) end, 'git.push: addcommitpush commit_history_en', mode = { 'n', 'v', }, silent = true, },
        ['c'] = { function() M.commit_push(nil, 1) end, 'git.push: commit_push commit_history_en', mode = { 'n', 'v', }, silent = true, },
        ['d'] = { function() M.reset_hard_clean() end, 'git.push: reset_hard_clean', mode = { 'n', 'v', }, silent = true, },
        ['g'] = { function() M.graph_asyncrun() end, 'git.push: graph_asyncrun', mode = { 'n', 'v', }, silent = true, },
        ['h'] = { function() M.show_commit_history() end, 'git.push: show_commit_history', mode = { 'n', 'v', }, silent = true, },
        ['r'] = { function() M.reset_hard() end, 'git.push: reset_hard', mode = { 'n', 'v', }, silent = true, },
        ['s'] = { function() M.push() end, 'git.push: push', mode = { 'n', 'v', }, silent = true, },
        ['v'] = { function() M.init() end, 'git.push: init', mode = { 'n', 'v', }, silent = true, },
      },
      m = {
        name = 'git.signs',
        ['b'] = { function() M.blame_line() end, 'git.signs: blame_line', mode = { 'n', 'v', }, },
        ['d'] = { function() M.diffthis_l() end, 'git.signs: diffthis_l', mode = { 'n', 'v', }, },
        ['p'] = { function() M.preview_hunk() end, 'git.signs: preview_hunk', mode = { 'n', 'v', }, },
        ['r'] = { function() M.reset_buffer() end, 'git.signs: reset_buffer', mode = { 'n', 'v', }, },
        ['s'] = { function() M.stage_buffer() end, 'git.signs: stage_buffer', mode = { 'n', 'v', }, },
        t = {
          name = 'git.signs.more',
          ['b'] = { function() M.toggle_current_line_blame() end, 'git.signs: toggle_current_line_blame', mode = { 'n', 'v', }, },
          ['d'] = { function() M.toggle_deleted() end, 'git.signs: toggle_deleted', mode = { 'n', 'v', }, },
          ['l'] = { function() M.toggle_linehl() end, 'git.signs: toggle_linehl', mode = { 'n', 'v', }, },
          ['n'] = { function() M.toggle_numhl() end, 'git.signs: toggle_numhl', mode = { 'n', 'v', }, },
          ['s'] = { function() M.toggle_signs() end, 'git.signs: toggle_signs', mode = { 'n', 'v', }, },
          ['w'] = { function() M.toggle_word_diff() end, 'git.signs: toggle_word_diff', mode = { 'n', 'v', }, },
        },
      },
    },
  },
  g = {
    name = 'git.push',
    ['<c-0>'] = { function() M.addcommitpush_parentheses() end, 'git.push: addcommitpush parentheses', mode = { 'n', 'v', }, silent = true, },
    ['<c-4>'] = { function() M.addcommitpush_cWORD() end, 'git.push: addcommitpush cWORD', mode = { 'n', 'v', }, silent = true, },
    ['<c-\'>'] = { function() M.addcommitpush_single_quote() end, 'git.push: addcommitpush single_quote', mode = { 'n', 'v', }, silent = true, },
    ['<c-]>'] = { function() M.addcommitpush_bracket() end, 'git.push: addcommitpush bracket', mode = { 'n', 'v', }, silent = true, },
    ['<c-`>'] = { function() M.addcommitpush_back_quote() end, 'git.push: addcommitpush back_quote', mode = { 'n', 'v', }, silent = true, },
    ['<c-e>'] = { function() M.addcommitpush_cword() end, 'git.push: addcommitpush cword', mode = { 'n', 'v', }, silent = true, },
    ['<c-l>'] = { function() M.addcommitpush_curline() end, 'git.push: addcommitpush curline', mode = { 'n', 'v', }, silent = true, },
    ['<c-s-.>'] = { function() M.addcommitpush_angle_bracket() end, 'git.push: addcommitpush angle_bracket', mode = { 'n', 'v', }, silent = true, },
    ['<c-s-\'>'] = { function() M.addcommitpush_double_quote() end, 'git.push: addcommitpush double_quote', mode = { 'n', 'v', }, silent = true, },
    ['<c-s-]>'] = { function() M.addcommitpush_brace() end, 'git.push: addcommitpush brace', mode = { 'n', 'v', }, silent = true, },
  },
  ['<leader>gr'] = { function() M.reset_hunk() end, 'git.signs: reset_hunk', mode = { 'n', }, silent = true, },
  ['<leader>gs'] = { function() M.stage_hunk() end, 'git.signs: stage_hunk', mode = { 'n', }, silent = true, },
  ag = { ':<C-U>Gitsigns select_hunk<CR>', 'git.signs: select_hunk', mode = { 'o', 'x', }, silent = true, },
  ig = { ':<C-U>Gitsigns select_hunk<CR>', 'git.signs: select_hunk', mode = { 'o', 'x', }, silent = true, },
}

function M.setup(options)
  require 'which-key'.register(vim.tbl_deep_extend('force', {}, M.defaults, options or {}))
end

return M
