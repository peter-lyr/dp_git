local M = {}

local B = require 'dp_base'

function M.pop()
  pcall(vim.call, 'ProjectRootCD')
  B.notify_info 'git stash pop'
  B.system_run('asyncrun', 'git stash pop')
end

function M.create()
  pcall(vim.call, 'ProjectRootCD')
  B.notify_info 'git stash push --include-untracked'
  local info = vim.fn.input('stash info: ')
  if B.is(info) then
    B.system_run('asyncrun', 'git stash push --include-untracked -m "%s"', info)
  end
end

function M.delete()
  pcall(vim.call, 'ProjectRootCD')
  B.notify_info 'git stash drop'
  B.system_run('asyncrun', 'git stash drop')
end

require 'which-key'.register {
  ['<leader>gi'] = { name = 'git.stash', },
  ['<leader>gip'] = { function() M.pop() end, 'git.stash: pop', mode = { 'n', 'v', }, silent = true, },
  ['<leader>gic'] = { function() M.create() end, 'git.stash: create', mode = { 'n', 'v', }, silent = true, },
  ['<leader>gid'] = { function() M.delete() end, 'git.stash: delete', mode = { 'n', 'v', }, silent = true, },
}

return M
