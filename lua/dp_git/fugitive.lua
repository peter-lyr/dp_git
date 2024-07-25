local M = {}

local B = require 'dp_base'

function M.fugitive_toggle()
  if vim.o.ft == 'fugitive' then
    vim.cmd 'close'
  else
    vim.cmd 'G'
    B.set_timeout(10, function()
      vim.cmd 'set winfixheight'
      vim.api.nvim_win_set_height(0, 13)
    end)
  end
end

require 'which-key'.register {
  ['<leader>g<leader>'] = { function() M.fugitive_toggle() end, 'git.fugitive: toggle', mode = { 'n', 'v', }, silent = true, },
}

return M
