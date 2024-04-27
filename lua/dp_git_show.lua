local M = {}

local B = require 'dp_base'

local git_push = require 'dp_git_push'

function M.lazygit()
  B.system_run('start', 'lazygit')
end

function M.git_browser()
  local _, url = git_push.get_git_remote_url()
  if B.is(url) then
    B.system_run('start silent', 'start https://%s', url)
  end
end

function M.graph_asyncrun()
  B.system_run('asyncrun', 'git log --all --graph --decorate --oneline')
end

function M.graph_start()
  B.system_run('start', 'git log --all --graph --decorate --oneline && pause')
end

function M.show_commit_history()
  B.ui_sel(git_push.get_commit_history(), 'Show Commit History', function() end)
end

require 'which-key'.register {
  ['<leader>go'] = { name = 'git.show', },
  ['<leader>gol'] = { function() M.lazygit() end, 'git.lazy: lazygit', mode = { 'n', 'v', }, silent = true, },
  ['<leader>gob'] = { function() M.git_browser() end, 'git.push: browser', mode = { 'n', 'v', }, silent = true, },
  ['<leader>goh'] = { function() M.show_commit_history() end, 'git.push: show_commit_history', mode = { 'n', 'v', }, silent = true, },
  ['<leader>gog'] = { name = 'git.show.graph', },
  ['<leader>gogs'] = { function() M.graph_start() end, 'git.push: graph_start', mode = { 'n', 'v', }, silent = true, },
  ['<leader>goga'] = { function() M.graph_asyncrun() end, 'git.push: graph_asyncrun', mode = { 'n', 'v', }, silent = true, },
}

return M
