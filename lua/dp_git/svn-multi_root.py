import os
import sys
from multiprocessing import Process

try:
    cmd = f"{sys.argv[1]}"
except:
    cmd = "update"
    # cmd = "clean_update"
    # cmd = "show"
    # cmd = "show-gui"
    cmd = "kill-TortoiseProc.exe"
    # cmd = "clean"

try:
    revision = f"-r {sys.argv[2]}"
except:
    # revision = "-r 3000"
    revision = ""


try:
    cwd = f"-r {sys.argv[3]}"  # 一版不会主动指定
except:
    cwd = os.getcwd()


class Svn:
    def __init__(self, cwd, cmd, revision) -> None:
        self.cwd = cwd
        self.cmd = cmd
        self.revision = revision

        self.clean = [
            "svn cleanup",
            "svn revert --recursive *",
            "svn update --set-depth empty",
        ]
        self.update = [
            f"svn update --set-depth infinity --accept mine-full {revision}",
        ]
        self.show = ["svn info"]
        self.kill_TortoiseProc = ['taskkill /f /im "TortoiseProc.exe"']

        self.just_do_once = False
        if self.cmd in ["kill-TortoiseProc.exe"]:
            self.just_do_once = True

        self.use_multiprocess = False
        if self.cmd in [
            "clean",
            "update",
            "clean_update",
            "show-gui",
        ]:
            self.use_multiprocess = True

        self.do_not_pase = False
        if self.use_multiprocess or self.cmd in ["kill-TortoiseProc.exe"]:
            self.do_not_pase = True

        self.commands = {
            "clean": self.clean,
            "update": self.update,
            "clean_update": self.clean + self.update,
            "show": self.show,
            "show-gui": self.show_gui,
            "kill-TortoiseProc.exe": self.kill_TortoiseProc,
        }

    def show_gui(self, root):
        return [f"tortoiseproc /command:log /path:{root}"]

    def print_head(self, *info):
        info = "= " + " - ".join([*info])
        print("\n" + "=" * len(info))
        print(info)
        print("=" * len(info) + "\n")

    def svn_do(self, root):
        self.print_head(cmd, root)
        command = self.commands[cmd]
        if callable(command):
            command = command(root)
        os.system(
            " && ".join(
                [
                    f"cd /d {root}",
                    *command,
                ]
            )
        )

    def finish(self):
        if self.do_not_pase:
            return
        os.system("pause")

    def start(self):
        roots = []
        for root, dirs, _ in os.walk(self.cwd):
            for dir in dirs:
                if dir == ".svn":
                    roots.append(root)
        self.svn_do(roots[0])
        if self.just_do_once:
            self.finish()
            return
        for root in roots[1:]:
            if self.use_multiprocess:
                Process(target=self.svn_do, args=[root]).start()
            else:
                self.svn_do(root)
            if self.just_do_once:
                self.finish()
                return
        self.finish()


if __name__ == "__main__":
    Svn(cwd, cmd, revision).start()
