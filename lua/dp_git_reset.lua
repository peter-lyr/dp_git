local M = {}

local B = require 'dp_base'

function M.reset_hard()
  if B.is_sure 'git reset --hard' then
    B.done_append_default(function()
      B.set_timeout(100, function()
        vim.cmd 'e!'
      end)
    end)
    B.system_run('asyncrun', 'git reset --hard')
  end
end

function M.reset_hard_clean()
  if B.is_sure 'git reset --hard && git clean -fd' then
    B.done_append_default(function()
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
    if not B.is_sure 'Sure to del all of them' then
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
  'output'
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
  vim.command(f"""lua require'dp_base'.notify_info('del {c} Done!')""")
  vim.command(f"""lua require'nvim-tree.api'.tree.reload()""")
EOF
]]
end

require 'which-key'.register {
  ['<leader>ggr'] = { function() M.reset_hard() end, 'git.push: reset_hard', mode = { 'n', 'v', }, silent = true, },
  ['<leader>ggD'] = { function() M.clean_ignored_files_and_folders() end, 'git.push: clean_ignored_files_and_folders', mode = { 'n', 'v', }, silent = true, },
  ['<leader>ggd'] = { function() M.reset_hard_clean() end, 'git.push: reset_hard_clean', mode = { 'n', 'v', }, silent = true, },
}

return M
