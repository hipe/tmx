#!/usr/bin/env bash

exit 0

git clone ABC XYZ
for i in master cm-clj ; do git branch -t "$i" origin/$i ; done
git filter-branch --tag-name-filter cat --prune-empty --subdirectory-filter lib/skylab/cull/_clj -- --all
git reset --hard
git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d
git reflog expire --expire=now --all
git gc --aggressive --prune=now
