# 在cwd寻找所有.svn目录，并在它下面创建tmp目录
# 在tmp目录下面创建.gitkeep文件

import os
import sys

cwd = os.getcwd()

if len(sys.argv) > 1:
    temp = sys.argv[1]
    if os.path.isdir(temp):
        cwd = temp

for root, dirs, _ in os.walk(cwd):
    for dir in dirs:
        if dir == ".svn":
            tmp = os.path.join(root, dir, "tmp")
            os.makedirs(tmp, exist_ok=True)
            _gitkeep = os.path.join(tmp, ".gitkeep")
            with open(_gitkeep, "wb") as f:
                f.write(b"")
