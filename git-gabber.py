#!/usr/bin/env python3
# Clone a repository in a temporary directory, open $EDITOR, delete temporary folder.
#
# Credit for the simple idea goes to https://github.com/Jarred-Sumner/git-peek.
#
# Example urls
# https://github.com/username/repo.git
# git@github.com:username/repo.git
# ssh://git@github.com/username/repo.git

import argparse
import os
import re
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Union
from urllib.parse import urlparse


@dataclass
class GitUrl:
    domain: str
    username: str
    repository: str
    full_path: str

    @staticmethod
    def parse(url: str) -> "GitUrl":
        if url.startswith("git@"):
            parts = url.split("@")[1].split(":")
            domain = parts[0]
            path = parts[1]
        else:
            parsed = urlparse(url)
            domain = parsed.netloc
            path = parsed.path.lstrip("/")

        path = re.sub(r"\.git$", "", path)
        username, repo = path.split("/") if "/" in path else ("", path)

        return GitUrl(domain=domain, username=username, repository=repo, full_path=path)


@dataclass
class CLI:
    platypus: bool
    env: str
    editor: str
    url: str

    @staticmethod
    def parse() -> "CLI":
        parser = argparse.ArgumentParser(
            description="Clone a repository and open in $EDITOR"
        )
        parser.add_argument(
            "--platypus",
            action="store_true",
            help="Run as a Platypus script",
        )
        parser.add_argument(
            "--env",
            default="~/.shell/env.sh",
            help="Shell environment file to source",
        )
        parser.add_argument(
            "--editor",
            default=os.environ.get("EDITOR", "$EDITOR"),
            help="Editor to open the repository in (default: $EDITOR)",
        )
        parser.add_argument("url", help="URL of the repository")
        return CLI(**vars(parser.parse_args()))


class Gabber:
    def __init__(self, cli: CLI):
        self.cli = cli

    def info(self, msg):
        if self.cli.platypus:
            print(f"NOTIFICATION:Gabber|{msg}", flush=True)
        else:
            print(f"INFO: {msg}")

    def debug(self, msg):
        if self.cli.platypus:
            # TODO
            pass
        else:
            print(f"DEBUG: {msg}")

    def error(self, msg):
        if self.cli.platypus:
            print(f"ALERT:Gabber|{msg}", flush=True)
        else:
            print(f"ERROR: {msg}")

    def run(
        self, *cmd, **kwargs
    ) -> Union[subprocess.CompletedProcess, subprocess.CalledProcessError]:
        self.debug(" ".join([str(c) for c in cmd]))
        try:
            return subprocess.run(args=cmd, **kwargs, capture_output=True, text=True)
        except subprocess.CalledProcessError as e:
            self.error(f"ERROR: {e.stderr}")
            return e

    def main(self):
        self.debug(self.cli)
        self.cli.url = self.cli.url.replace("gabber://", "https://")
        git_url = GitUrl.parse(self.cli.url)

        brewenv = """
if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
""".strip()

        if (out := self.run(f"{brewenv}\nwhich tmux", shell=True)) is None:
            return
        tmux = out.stdout.strip()
        if not tmux:
            self.error("tmux not found")
            return
        self.debug(f"tmux: {tmux}")

        with tempfile.TemporaryDirectory() as tmpdir:
            dst = Path(tmpdir).joinpath(git_url.repository)
            dst.mkdir()

            if not self.run("git", "clone", "--depth=1", self.cli.url, dst):
                return

            signal = f"gabber-{git_url.repository}"
            neww_script = f"""
{brewenv}
source {self.cli.env}
{tmux} -L default new-window -Pd -n {signal} -c {dst} \
    '{self.cli.editor} {dst}; {tmux} wait -S {signal}'
""".strip()
            if (out := self.run(neww_script, shell=True)) is None:
                return
            neww = out.stdout.strip()
            self.info(f"{self.cli.url} in {neww}")

            if not self.run(tmux, "-L", "default", "wait", signal):
                return
            self.debug(f"done {git_url.full_path}")


if __name__ == "__main__":
    Gabber(CLI.parse()).main()
