local M = {}

local B = require 'dp_base'

M.word_diff_en = 1
M.word_diff = 1

M.moving = nil

require 'gitsigns'.setup {
  signs                        = {
    add = { text = '+', },
    change = { text = '~', },
    delete = { text = '_', },
    topdelete = { text = '‾', },
    changedelete = { text = '', },
    untracked = { text = '?', },
  },
  signcolumn                   = true,  -- Toggle with `:Gitsigns toggle_signs`
  numhl                        = true,  -- Toggle with `:Gitsigns toggle_numhl`
  linehl                       = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff                    = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir                 = {
    follow_files = true,
  },
  attach_to_untracked          = true,
  current_line_blame           = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts      = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
    virt_text_priority = 100,
  },
  current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
  sign_priority                = 100,
  update_debounce              = 100,
  status_formatter             = nil,   -- Use default
  max_file_length              = 40000, -- Disable if file is longer than this (in lines)
  preview_config               = {
    -- Options passed to nvim_open_win
    border = 'single',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1,
  },
  yadm                         = {
    enable = false,
  },
}

B.aucmd('CursorHold', 'git.signs.CursorHold', {
  callback = function()
    M.moving = nil
    vim.fn.timer_start(500, function()
      vim.schedule(function()
        if not M.moving then
          if M.word_diff_en == 1 then
            M.word_diff = require 'gitsigns'.toggle_word_diff(1)
          end
        end
      end)
    end)
  end,
})

B.aucmd({ 'InsertEnter', 'CursorMoved', }, 'git.signs.InsertEnter', {
  callback = function()
    M.moving = 1
    if M.word_diff then
      M.word_diff = require 'gitsigns'.toggle_word_diff(nil)
    end
  end,
})

function M.toggle_word_diff()
  local temp = require 'gitsigns'.toggle_word_diff()
  if temp == false then
    M.word_diff_en = 0
  else
    M.word_diff_en = 1
  end
end

function M.prev_hunk()
  if vim.wo.diff then
    vim.cmd [[call feedkeys("[c")]]
  end
  require 'gitsigns'.prev_hunk()
end

function M.next_hunk()
  if vim.wo.diff then
    vim.cmd [[call feedkeys("]c")]]
  end
  require 'gitsigns'.next_hunk()
end

function M.temp_map_hunk()
  B.temp_map({
    { 'j', function() M.next_hunk() end, desc = 'git.signs: next_hunk', mode = { 'n', 'v', }, silent = true, },
    { 'k', function() M.prev_hunk() end, desc = 'git.signs: prev_hunk', mode = { 'n', 'v', }, silent = true, },
  }, 'm')
end

function M.leader_j()
  local hunks = require 'gitsigns.actions'.get_hunks()
  if not hunks or #hunks == 0 then
    print 'no hunk'
    return
  end
  M.next_hunk()
  M.temp_map_hunk()
end

function M.leader_k()
  local hunks = require 'gitsigns.actions'.get_hunks()
  if not hunks or #hunks == 0 then
    print 'no hunk'
    return
  end
  M.prev_hunk()
  M.temp_map_hunk()
end

function M.stage_hunk()
  require 'gitsigns'.stage_hunk()
end

function M.stage_hunk_v()
  require 'gitsigns'.stage_hunk { vim.fn.line '.', vim.fn.line 'v', }
end

function M.stage_buffer()
  require 'gitsigns'.stage_buffer()
end

function M.undo_stage_hunk()
  require 'gitsigns'.undo_stage_hunk()
end

function M.reset_hunk()
  require 'gitsigns'.reset_hunk()
end

function M.reset_hunk_v()
  require 'gitsigns'.reset_hunk { vim.fn.line '.', vim.fn.line 'v', }
end

function M.reset_buffer()
  require 'gitsigns'.reset_buffer()
end

function M.preview_hunk()
  require 'gitsigns'.preview_hunk()
end

function M.blame_line()
  require 'gitsigns'.blame_line { full = true, }
end

function M.diffthis()
  require 'gitsigns'.diffthis()
end

function M.diffthis_l()
  require 'gitsigns'.diffthis '~'
end

function M.toggle_current_line_blame()
  require 'gitsigns'.toggle_current_line_blame()
end

function M.toggle_deleted()
  require 'gitsigns'.toggle_deleted()
end

function M.toggle_numhl()
  require 'gitsigns'.toggle_numhl()
end

function M.toggle_linehl()
  require 'gitsigns'.toggle_linehl()
end

function M.toggle_signs()
  require 'gitsigns'.toggle_signs()
end

require 'which-key'.register {
  ['<leader>k'] = { function() M.leader_k() end, 'git.signs: prev_hunk', mode = { 'n', 'v', }, },
  ['<leader>j'] = { function() M.leader_j() end, 'git.signs: next_hunk', mode = { 'n', 'v', }, },
  ['<leader>gd'] = { function() M.diffthis() end, 'git.signs: diffthis', mode = { 'n', }, silent = true, },
  ['<leader>ge'] = { function() M.toggle_deleted() end, 'git.signs: toggle_deleted', mode = { 'n', 'v', }, silent = true, },
  ['<leader>gu'] = { function() M.undo_stage_hunk() end, 'git.signs: undo_stage_hunk', mode = { 'n', }, silent = true, },
  ['<leader>gr'] = { function() M.reset_hunk() end, 'git.signs: reset_hunk', mode = { 'n', }, silent = true, },
  ['<leader>gs'] = { function() M.stage_hunk() end, 'git.signs: stage_hunk', mode = { 'n', }, silent = true, },
  ['<leader>gm'] = { name = 'git.signs', },
  ['<leader>gmb'] = { function() M.blame_line() end, 'git.signs: blame_line', mode = { 'n', 'v', }, },
  ['<leader>gmd'] = { function() M.diffthis_l() end, 'git.signs: diffthis_l', mode = { 'n', 'v', }, },
  ['<leader>gmp'] = { function() M.preview_hunk() end, 'git.signs: preview_hunk', mode = { 'n', 'v', }, },
  ['<leader>gmr'] = { function() M.reset_buffer() end, 'git.signs: reset_buffer', mode = { 'n', 'v', }, },
  ['<leader>gms'] = { function() M.stage_buffer() end, 'git.signs: stage_buffer', mode = { 'n', 'v', }, },
  ['<leader>gmt'] = { name = 'git.signs.toggle', },
  ['<leader>gmtb'] = { function() M.toggle_current_line_blame() end, 'git.signs.toggle: toggle_current_line_blame', mode = { 'n', 'v', }, },
  ['<leader>gmtd'] = { function() M.toggle_deleted() end, 'git.signs.toggle: toggle_deleted', mode = { 'n', 'v', }, },
  ['<leader>gmtl'] = { function() M.toggle_linehl() end, 'git.signs.toggle: toggle_linehl', mode = { 'n', 'v', }, },
  ['<leader>gmtn'] = { function() M.toggle_numhl() end, 'git.signs.toggle: toggle_numhl', mode = { 'n', 'v', }, },
  ['<leader>gmts'] = { function() M.toggle_signs() end, 'git.signs.toggle: toggle_signs', mode = { 'n', 'v', }, },
  ['<leader>gmtw'] = { function() M.toggle_word_diff() end, 'git.signs.toggle: toggle_word_diff', mode = { 'n', 'v', }, },
  ag = { ':<C-U>Gitsigns select_hunk<CR>', 'git.signs: select_hunk', mode = { 'o', 'x', }, silent = true, },
  ig = { ':<C-U>Gitsigns select_hunk<CR>', 'git.signs: select_hunk', mode = { 'o', 'x', }, silent = true, },
}

require 'which-key'.register {
  ['<leader>gr'] = { function() M.reset_hunk_v() end, 'git.signs: reset_hunk_v', mode = { 'v', }, silent = true, },
  ['<leader>gs'] = { function() M.stage_hunk_v() end, 'git.signs: stage_hunk_v', mode = { 'v', }, silent = true, },
}

return M
