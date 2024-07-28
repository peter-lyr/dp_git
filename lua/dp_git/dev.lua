-- Copyright (c) 2024 liudepei. All Rights Reserved.
-- create at 2024/06/21 22:03:46 Friday

local B = require 'dp_base'

-- 等待官方修复bug
-- -- Generates a directory name from a Git URI.
-- -- If `branch` is given, it will be suffixed with "#branch"
-- -- "https://github.com/example/repo.git" => "github.com__example__repo"
-- local function git_uri_to_dir_name(uri, branch)
--   local dir_name =
--     uri:gsub("/+$", ""):gsub(".*://", ""):gsub("/", "__"):gsub(".git$", "")
--   if branch and branch ~= "" then
--     dir_name = dir_name .. "#" .. branch:gsub("/", "__")
--   end
--   return dir_name
-- end
--
-- change to:
--
-- -- Generates a directory name from a Git URI.
-- -- If `branch` is given, it will be suffixed with "#branch"
-- -- "https://github.com/example/repo.git" => "github.com__example__repo"
-- local function git_uri_to_dir_name(uri, branch)
--   local dir_name =
--     uri:gsub("/+$", ""):gsub(".*://", ""):gsub("/", "__"):gsub(".git$", ""):gsub(":", "__")
--   if branch and branch ~= "" then
--     dir_name = dir_name .. "#" .. branch:gsub("/", "__")
--   end
--   return dir_name
-- end

require 'git-dev'.setup {
  ephemeral = false,
  read_only = false,
  repositories_dir = B.rep_slash(vim.fn.stdpath 'cache' .. '/git-dev'),
  git = {
    base_uri_format = 'git@github.com:%s.git',
  },
  verbose = true,
}

require 'which-key'.register {
  ['<leader>gb'] = { function() require 'git-log'.check_log() end, 'git.dev: check_log', mode = { 'n', 'v', }, silent = true, },
}
