local M = {}

local B = require 'dp_base'

function M.fugitive_toggle()
  if vim.o.ft == 'fugitive' then
    vim.cmd 'close'
  else
    vim.cmd 'G'
  end
end

require 'which-key'.register {
  ['<leader>g<leader>'] = { function() M.fugitive_toggle() end, 'git.fugitive: toggle', mode = { 'n', 'v', }, silent = true, },
}

return M
