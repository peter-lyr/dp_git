local M = {}

local B = require 'dp_base'

M.source = B.getsource(debug.getinfo(1)['source'])
M.lua = B.getlua(M.source)

M.svn_tmp_gitkeep_py = B.getcreate_file(B.file_parent(M.source), 'svn_tmp.gitkeep.py')
M.svn_multi_root_py = B.getcreate_file(B.file_parent(M.source), 'svn-multi_root.py')

M.commit_history_en = nil
M.pull_all_prepared = nil

M.timeout = 60 * 60 * 24

function M.get_info(info)
  info = B.cmd_escape(info)
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

function M.addcommitpush_do(info)
  if info and #info > 0 then
    B.set_timeout(10, function()
      info = M.get_info(info)
      B.notify_info_append('addcommitpush: ' .. info)
      B.system_run('asyncrun', {
        'git add -A',
        'git status',
        'git commit -m "%s"',
        'git push',
      }, info)
    end)
  end
end

function M.addcommitpush(info, commit_history_en)
  pcall(vim.call, 'ProjectRootCD')
  local result = vim.fn.systemlist { 'git', 'status', '-s', }
  if #result > 0 then
    B.notify_info({ 'git status -s', vim.loop.cwd(), table.concat(result, '\n'), }, M.timeout)
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
  B.setreg()
  M.addcommitpush(vim.g.curline)
end

function M.addcommitpush_single_quote()
  B.setreg()
  M.addcommitpush(vim.g.single_quote)
end

function M.addcommitpush_double_quote()
  B.setreg()
  M.addcommitpush(vim.g.double_quote)
end

function M.addcommitpush_parentheses()
  B.setreg()
  M.addcommitpush(vim.g.parentheses)
end

function M.addcommitpush_bracket()
  B.setreg()
  M.addcommitpush(vim.g.bracket)
end

function M.addcommitpush_brace()
  B.setreg()
  M.addcommitpush(vim.g.brace)
end

function M.addcommitpush_back_quote()
  B.setreg()
  M.addcommitpush(vim.g.back_quote)
end

function M.addcommitpush_angle_bracket()
  B.setreg()
  M.addcommitpush(vim.g.angle_bracket)
end

function M.addcommitpush_cword()
  B.setreg()
  M.addcommitpush(vim.fn.expand '<cword>')
end

function M.addcommitpush_cWORD()
  B.setreg()
  M.addcommitpush(vim.fn.expand '<cWORD>')
end

function M.commit_push_do(info)
  if info and #info > 0 then
    B.set_timeout(10, function()
      info = M.get_info(info)
      B.notify_info_append('commit_push: ' .. info)
      B.system_run('asyncrun', {
        'git commit -m "%s"',
        'git push',
      }, info)
    end)
  end
end

function M.commit_push(info, commit_history_en)
  pcall(vim.call, 'ProjectRootCD')
  local result = vim.fn.systemlist { 'git', 'diff', '--staged', '--stat', }
  if #result > 0 then
    B.notify_info({ 'git diff --staged --stat', vim.loop.cwd(), table.concat(result, '\n'), }, M.timeout)
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
    B.notify_info({ 'git diff --staged --stat', vim.loop.cwd(), table.concat(result, '\n'), }, M.timeout)
    if not info then
      M.commit_history_en = commit_history_en
      M.get_commit_and_do('commit info (just commit): ', M.commit_do)
    end
    M.commit_do(info)
  else
    vim.notify 'no staged'
  end
end

function M.Git_commit()
  vim.cmd 'Git commit'
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

function M.git_keep()
  B.system_run('start silent', { '%s "%s"', }, M.svn_tmp_gitkeep_py, B.get_file_git_root())
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
  B.done_append_default(function()
    M.addcommitpush 's1'
  end)
  B.system_run('asyncrun', {
    B.system_cd(git_root_dir),
    'md "%s"',
    'cd %s',
    'git init --bare',
    'cd ..',
    M.svn_tmp_gitkeep_py,
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

function M.just_init_ignore_all_do(git_root_dir)
  local file_path = B.get_filepath(git_root_dir, '.gitignore')
  file_path:write('*', 'w')
  file_path:write('\r\n!.gitignore', 'a')
  B.system_run('asyncrun', {
    B.system_cd(git_root_dir),
    M.svn_tmp_gitkeep_py,
    'git init',
    'git add .gitignore',
    [[git commit -m ".gitignore"]],
  })
end

function M.just_init_ignore_all()
  B.ui_sel(B.get_file_dirs(B.buf_get_name()), 'git init', function(choice)
    if choice then
      M.just_init_ignore_all_do(choice)
    end
  end)
end

function M.just_init_do(git_root_dir)
  local file_path = B.get_filepath(git_root_dir, 'README.md')
  file_path:write(git_root_dir, 'w')
  B.system_run('asyncrun', {
    B.system_cd(git_root_dir),
    M.svn_tmp_gitkeep_py,
    'git init',
    'git add .',
    [[git commit -m "first commit"]],
  })
end

function M.just_init()
  B.ui_sel(B.get_file_dirs(B.buf_get_name()), 'git init', function(choice)
    if choice then
      M.just_init_do(choice)
    end
  end)
end

function M.addall()
  pcall(vim.call, 'ProjectRootCD')
  B.system_run('asyncrun', 'git add -A')
end

function M.addall_Git_commit()
  M.addall()
  M.Git_commit()
end

function M.pull()
  pcall(vim.call, 'ProjectRootCD')
  B.notify_info 'git pull'
  B.system_run('asyncrun', 'git pull')
end

function M.pull_all_prepare()
  M.pull_all_prepared = 1
  M.repos_dir = { vim.fn.stdpath 'config', }
  local _gits = B.get_dirs_equal('.git', DepeiRepos, { hidden = true, depth = 2, })
  for _, dir in ipairs(_gits) do
    M.repos_dir[#M.repos_dir + 1] = B.file_parent(dir)
  end
end

function M.get_git_remote_url(proj)
  local remote = ''
  if proj then
    remote = vim.fn.system(string.format('cd %s && git remote -v', proj))
  else
    remote = vim.fn.system 'git remote -v'
  end
  local res = B.findall('.*git@([^:]+):([^/]+)/([^ ]+).*', remote)
  local urls = {}
  local type = nil
  if #res == 0 then
    res = B.findall('https://([^ ]+)', remote)
    for _, r in ipairs(res) do
      local url = r
      if not B.is_in_tbl(url, urls) then
        urls[#urls + 1] = url
        type = 'https'
      end
    end
  else
    for _, r in ipairs(res) do
      local url = string.format('%s/%s/%s', unpack(r))
      if not B.is_in_tbl(url, urls) then
        urls[#urls + 1] = url
        type = 'ssh'
      end
    end
  end
  if #urls > 0 then
    return type, string.format('%s', urls[1])
  end
  return type, ''
end

function M.pull_all()
  if not M.pull_all_prepared then
    M.pull_all_prepare()
  end
  local info = ''
  for _, dir in ipairs(M.repos_dir) do
    local type, url = M.get_git_remote_url(dir)
    if type == 'https' then
      B.system_run('start', {
        '%s',
        'git remote remove origin',
        'git remote add origin git@%s:%s',
        'git pull',
      }, B.system_cd(dir), url, string.match(url, '[^/]+/(.+)'))
    else
      B.system_run('start silent', {
        '%s',
        'git pull',
      }, B.system_cd(dir))
    end
    info = info .. dir .. '\n'
  end
  info = info .. 'total ' .. tostring(#M.repos_dir) .. ' git repos'
  B.notify_info { 'git pull_all', info, }
end

function M.clone()
  local dirs = B.uniq_sort(B.merge_tables(
    B.get_file_dirs(B.rep(B.buf_get_name())),
    B.get_path_dir(),
    B.get_my_dirs(),
    B.get_SHGetFolderPath 'desktop',
    B.get_drivers()
  ))
  B.ui_sel(dirs, 'git clone sel a dir', function(proj)
    if not proj then
      return
    end
    local input = vim.fn.input('author/repo [local_repo] to clone: ', 'peter-lyr/')
    local author, repo, local_repo
    if B.is_in_str(' ', input) then
      author, repo, local_repo = string.match(input, '(.+)/([^ ]+) +([^ ]+)')
    else
      author, repo = string.match(input, '(.+)/([^ ]+)')
    end
    if B.is(author) and B.is(repo) then
      B.system_run('start', {
        'cd /d %s',
        'echo %s',
        'echo git clone git@github.com:%s/%s.git ' .. (local_repo or ''),
        'git clone git@github.com:%s/%s.git ' .. (local_repo or ''),
      }, proj, proj, author, repo, author, repo)
    end
  end)
end

require 'which-key'.register {
  ['<leader>gg'] = { name = 'git.push', },
}

require 'which-key'.register {
  ['<leader>ggi'] = { name = 'git.push.init', },
  ['<leader>ggin'] = { function() M.init() end, 'git.push: init', mode = { 'n', 'v', }, silent = true, },
  ['<leader>ggij'] = { function() M.just_init() end, 'git.push: just_init', mode = { 'n', 'v', }, silent = true, },
  ['<leader>ggii'] = { function() M.just_init_ignore_all() end, 'git.push: just_init_ignore_all', mode = { 'n', 'v', }, silent = true, },
}

require 'which-key'.register {
  ['<leader>gp'] = { name = 'git.push.pull', },
  ['<leader>gpc'] = { function() M.pull() end, 'git.push: pull cur', mode = { 'n', 'v', }, silent = true, },
  ['<leader>gpa'] = { function() M.pull_all() end, 'git.push: pull all', mode = { 'n', 'v', }, silent = true, },
}

require 'which-key'.register {
  ['<leader>ga'] = { function() M.addall() end, 'git.push: add all', mode = { 'n', 'v', }, silent = true, },
  ['<leader>gn'] = { function() M.addall_Git_commit() end, 'git.push: addall_Git_commit', mode = { 'n', 'v', }, silent = true, },
}

require 'which-key'.register {
  ['<leader>g\\'] = { function() M.push() end, 'git.push: push', mode = { 'n', 'v', }, silent = true, },
}

require 'which-key'.register {
  ['<leader>gc'] = { function() M.Git_commit() end, 'git.push: Git_commit', mode = { 'n', 'v', }, silent = true, },
}

return M
