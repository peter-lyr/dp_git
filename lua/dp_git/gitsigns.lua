-- Copyright (c) 2024 liudepei. All Rights Reserved.
-- create at 2024/04/07 17:01:41 Sunday

local M = {}

local sta, B = pcall(require, 'dp_base')

if not sta then return print('Dp_base is required!', debug.getinfo(1)['source']) end

return M
