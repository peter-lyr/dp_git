-- Copyright (c) 2024 liudepei. All Rights Reserved.
-- create at 2024/04/08 23:02:25 星期一

local M = {}

local B = require 'dp_base'

M.source = B.getsource(debug.getinfo(1)['source'])
M.lua = B.getlua(M.source)

function M.get_info(info)
  info = string.gsub(info, '"', "'")
  info = string.gsub(info, '#', ' ')
  info = string.gsub(info, '\r', '\n')
  info = string.gsub(info, '\r\n', '\n')
  info = string.gsub(info, ':\n+', '. ')
  info = string.gsub(info, '\n+', '. ')
  info = vim.fn.trim(info)
  return info
end

function M.get_commit_history()
  local f = io.popen 'git log --pretty=format:"%h - %an, %ar :::: %s"'
  if f then
    local commits = {}
    for commit in string.gmatch(f:read '*a', '([%S ]+)') do
      if not B.is_in_tbl(commit, commits) then
        commits[#commits + 1] = commit
      end
    end
    f:close()
    return commits
  end
  return {}
end

function M.show_commit_history() B.ui_sel(M.get_commit_history(), 'Show Commit History', function() end) end

M.commit_history_en = nil

function GitCompletion()
  return B.get_git_modified_files()
end

function M.get_commit_and_do(prompt, callback)
  if M.commit_history_en then
    local commits = M.get_commit_history()
    B.ui_sel(commits, prompt, function(commit)
      if not commit then
        commit = ''
      else
        commit = string.match(commit, '.*:::: (.+)')
      end
      vim.ui.input({ prompt = prompt, default = commit, completion = 'customlist,v:lua.GitCompletion', }, function(input)
        if B.is(input) then
          callback(input)
        end
      end)
    end)
  else
    vim.ui.input({ prompt = prompt, completion = 'customlist,v:lua.GitCompletion', }, function(input)
      if B.is(input) then
        callback(input)
      end
    end)
  end
  M.commit_history_en = nil
end

-- gitpush
function M.addcommitpush_do(info)
  if info and #info > 0 then
    B.set_timeout(10, function()
      info = M.get_info(info)
      B.notify_info_append('addcommitpush: ' .. info)
      B.system_run('asyncrun', 'git add -A && git status && git commit -m "%s" && git push', info)
    end)
  end
end

function M.addcommitpush(info, commit_history_en)
  pcall(vim.call, 'ProjectRootCD')
  local result = vim.fn.systemlist { 'git', 'status', '-s', }
  if #result > 0 then
    B.notify_info { 'git status -s', vim.loop.cwd(), table.concat(result, '\n'), }
    if not info then
      M.commit_history_en = commit_history_en
      M.get_commit_and_do('commit info (Add all and push): ', M.addcommitpush_do)
    end
    M.addcommitpush_do(info)
  else
    vim.notify 'no changes'
  end
end

function M.addcommitpush_curline()
  require 'config.my.imaps'.setreg()
  M.addcommitpush(vim.g.curline)
end

function M.addcommitpush_single_quote()
  require 'config.my.imaps'.setreg()
  M.addcommitpush(vim.g.single_quote)
end

function M.addcommitpush_double_quote()
  require 'config.my.imaps'.setreg()
  M.addcommitpush(vim.g.double_quote)
end

function M.addcommitpush_parentheses()
  require 'config.my.imaps'.setreg()
  M.addcommitpush(vim.g.parentheses)
end

function M.addcommitpush_bracket()
  require 'config.my.imaps'.setreg()
  M.addcommitpush(vim.g.bracket)
end

function M.addcommitpush_brace()
  require 'config.my.imaps'.setreg()
  M.addcommitpush(vim.g.brace)
end

function M.addcommitpush_back_quote()
  require 'config.my.imaps'.setreg()
  M.addcommitpush(vim.g.back_quote)
end

function M.addcommitpush_angle_bracket()
  require 'config.my.imaps'.setreg()
  M.addcommitpush(vim.g.angle_bracket)
end

function M.addcommitpush_cword()
  require 'config.my.imaps'.setreg()
  M.addcommitpush(vim.fn.expand '<cword>')
end

function M.addcommitpush_cWORD()
  require 'config.my.imaps'.setreg()
  M.addcommitpush(vim.fn.expand '<cWORD>')
end

function M.commit_push_do(info)
  if info and #info > 0 then
    B.set_timeout(10, function()
      info = M.get_info(info)
      B.notify_info_append('commit_push: ' .. info)
      B.system_run('asyncrun', 'git commit -m "%s" && git push', info)
    end)
  end
end

function M.commit_push(info, commit_history_en)
  pcall(vim.call, 'ProjectRootCD')
  local result = vim.fn.systemlist { 'git', 'diff', '--staged', '--stat', }
  if #result > 0 then
    B.notify_info { 'git diff --staged --stat', vim.loop.cwd(), table.concat(result, '\n'), }
    if not info then
      M.commit_history_en = commit_history_en
      M.get_commit_and_do('commit info (commit and push): ', M.commit_push_do)
    end
    M.commit_push_do(info)
  else
    vim.notify 'no staged'
  end
end

function M.commit_do(info)
  if info and #info > 0 then
    B.set_timeout(10, function()
      info = M.get_info(info)
      B.notify_info_append('commit: ' .. info)
      B.system_run('asyncrun', 'git commit -m "%s"', info)
    end)
  end
end

function M.commit(info, commit_history_en)
  pcall(vim.call, 'ProjectRootCD')
  local result = vim.fn.systemlist { 'git', 'diff', '--staged', '--stat', }
  if #result > 0 then
    B.notify_info { 'git diff --staged --stat', vim.loop.cwd(), table.concat(result, '\n'), }
    if not info then
      M.commit_history_en = commit_history_en
      M.get_commit_and_do('commit info (just commit): ', M.commit_do)
    end
    M.commit_do(info)
  else
    vim.notify 'no staged'
  end
end

function M.graph_asyncrun()
  B.system_run('asyncrun', 'git log --all --graph --decorate --oneline')
end

function M.graph_start()
  B.system_run('start', 'git log --all --graph --decorate --oneline && pause')
end

function M.git_browser()
  local _, url = B.get_git_remote_url()
  if B.is(url) then
    B.system_run('start silent', 'start https://%s', url)
  end
end

function M.push()
  pcall(vim.call, 'ProjectRootCD')
  local result = vim.fn.systemlist { 'git', 'cherry', '-v', }
  if #result > 0 then
    B.notify_info { 'git cherry -v', vim.loop.cwd(), table.concat(result, '\n'), }
    B.set_timeout(10, function()
      B.system_run('asyncrun', 'git push')
    end)
  else
    vim.notify 'cherry empty'
  end
end

function M.init_do(git_root_dir)
  local remote_name = B.get_fname_tail(git_root_dir)
  if remote_name == '' then
    return
  end
  remote_name = '.git-' .. remote_name
  local remote_dir_path = B.get_dirpath { git_root_dir, remote_name, }
  if remote_dir_path:exists() then
    B.notify_info('remote path already existed: ' .. remote_dir_path.filename)
    return
  end
  local file_path = B.get_filepath(git_root_dir, '.gitignore')
  if file_path:exists() then
    local lines = file_path:readlines()
    if vim.tbl_contains(lines, remote_name) == false then
      file_path:write(remote_name, 'a')
      file_path:write('\r\n.clang-format', 'a')
      file_path:write('\r\n.clangd', 'a')
    end
  else
    file_path:write(remote_name, 'w')
    file_path:write('\r\n.clang-format', 'a')
    file_path:write('\r\n.clangd', 'a')
  end
  B.asyncrun_prepare_add(function()
    M.addcommitpush 's1'
  end)
  B.system_run('asyncrun', {
    B.system_cd(git_root_dir),
    'md "%s"',
    'cd %s',
    'git init --bare',
    'cd ..',
    'git init',
    'git add .gitignore',
    [[git commit -m ".gitignore"]],
    [[git remote add origin "%s"]],
    [[git branch -M "main"]],
    [[git push -u origin "main"]],
  }, remote_name, remote_name, remote_name)
end

function M.init()
  B.ui_sel(B.get_file_dirs(B.buf_get_name()), 'git init', function(choice)
    if choice then
      M.init_do(choice)
    end
  end)
end

function M.addall()
  pcall(vim.call, 'ProjectRootCD')
  B.system_run('asyncrun', 'git add -A')
end

function M.pull()
  pcall(vim.call, 'ProjectRootCD')
  B.notify_info 'git pull'
  B.system_run('asyncrun', 'git pull')
end

M.pull_all_prepared = nil

function M.pull_all_prepare()
  M.pull_all_prepared = 1
  M.repos_dir = { B.nvim_dir, }
  local _gits = B.get_dirs_equal('.git', B.get_repos_dir(), { hidden = true, depth = 2, })
  for _, dir in ipairs(_gits) do
    M.repos_dir[#M.repos_dir + 1] = B.file_parent(dir)
  end
end

function M.pull_all()
  if not M.pull_all_prepared then
    M.pull_all_prepare()
  end
  local info = ''
  for _, dir in ipairs(M.repos_dir) do
    local type, url = B.get_git_remote_url(dir)
    if type == 'https' then
      B.system_run('start', '%s && git remote remove origin && git remote add origin git@%s:%s && git pull', B.system_cd(dir), url, string.match(url, '[^/]+/(.+)'))
    else
      B.system_run('start silent', '%s && git pull', B.system_cd(dir))
    end
    info = info .. dir .. '\n'
  end
  info = info .. 'total ' .. tostring(#M.repos_dir) .. ' git repos'
  B.notify_info { 'git pull_all', info, }
end

function M.reset_hard()
  if B.is_sure 'git reset --hard' then
    B.asyncrun_prepare_add(function()
      B.set_timeout(100, function()
        vim.cmd 'e!'
      end)
    end)
    B.system_run('asyncrun', 'git reset --hard')
  end
end

function M.reset_hard_clean()
  if B.is_sure 'git reset --hard && git clean -fd' then
    B.asyncrun_prepare_add(function()
      B.set_timeout(100, function()
        vim.cmd 'e!'
      end)
    end)
    B.system_run('asyncrun', 'git reset --hard && git clean -fd')
  end
end

function M.clean_ignored_files_and_folders()
  local result = vim.fn.systemlist { 'git', 'clean', '-xdn', }
  if #result > 0 then
    B.notify_info { 'git clean -xdn', vim.loop.cwd(), table.concat(result, '\n'), }
    if B.is_sure 'Sure to del all of them' then
      return
    end
  else
    return
  end
  vim.g.cwd = vim.fn['ProjectRootGet']()
  vim.cmd [[
    python << EOF
import subprocess
import vim
import re
import os
import shutil
cwd = vim.eval('g:cwd')
rm_exclude = [
  '.git-.*',
  '.svn'
]
out = subprocess.Popen(['git', 'clean', '-xdn'], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, cwd=cwd)
stdout, stderr = out.communicate()
if not stderr:
  stdout = stdout.decode('utf-8').replace('\r', '').split('\n')
  c = 0
  for line in stdout:
    res = re.findall('Would remove (.+)', line)
    if res:
      ok = 1
      for p in rm_exclude:
        if re.match(p, res[0]):
          ok = 0
          break
      if ok:
        c += 1
        file = os.path.join(cwd, res[0])
        if re.match('.+/$', res[0]):
          shutil.rmtree(file)
        else:
          os.remove(file)
  vim.command(f"""lua require'base'.notify_info('del {c} Done!')""")
EOF
]]
end

function M.clone()
  local dirs = B.merge_tables(
    B.get_file_dirs(B.rep(B.buf_get_name()))
  )
  B.ui_sel(dirs, 'git clone sel a dir', function(proj)
    if not proj then
      return
    end
    local author, repo = string.match(vim.fn.input('author/repo to clone: ', 'peter-lyr/2023'), '(.+)/(.+)')
    if B.is(author) and B.is(repo) then
      B.system_run('start', [[cd %s & git clone git@github.com:%s/%s.git]], proj, author, repo)
    end
  end)
end

return M
