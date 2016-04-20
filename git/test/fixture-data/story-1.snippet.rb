[
  {
    command: ["git", "status", "--ignored", "--untracked-files=all", "-z", "--", "modified.file"],
    exitstatus: 0,
    stdout_lines: [
      " M fazoozle/modified.file\u0000",
    ],
  },
  {
    command: ["git", "status", "--ignored", "--untracked-files=all", "-z", "--", "not-there.file"],
    exitstatus: 0,
  },
  {
    command: ["git", "status", "--ignored", "--untracked-files=all", "-z", "--", "unchanged.file"],
    exitstatus: 0,
  },
  {
    command: ["git", "status", "--ignored", "--untracked-files=all", "-z", "--", "unversioned-A.file"],
    exitstatus: 0,
    stdout_lines: [
      "?? fazoozle/unversioned-A.file\u0000",
    ],
  },
  {
    command: ["git", "status", "--ignored", "--untracked-files=all", "-z", "--", "unversioned-B.file"],
    exitstatus: 128,
    stderr_lines: [
      "fatal: Not a git repository (or any of the parent directories): .git\n",
    ],
  },
]
