def patch_pelican(c):
    from sys import stdout as out
    w = out.write
    for line in _these_lines():
        w(line)


def _these_lines():
    from re import finditer
    return (md[0] for md in finditer(r'[^\n]*\n', _doc))


_doc = """This is too much to put in to a proper task, especially because
ideally we'll get this patch accepted in to pelican, but we have made it look
like it's a task for consistency and taxonomic aesthetics.

The issue is that pelican has a bug (github issue #2678 (which went stale))
where its `--write-selected` feature silently fails.

Here is what we did to fix it:
Check out latest stable pelican so we can hack it and use git to see diffs:

    cd ~/src
    git clone https://github.com/getpelican/pelican.git
    cd pelican
    git checkout tags/4.5.3

(The above line serves to annotate which version we had at writing. If the
head of the project is at a new version when you read this (likely), it may
be that this issue is already fixed, or that our patch won't work against it.)

    patch -p1 < [mono repo dir]/pho_tasks/tasks-data/patch-pelican.diff
    popd ; popd

(Now you are back in your mono repo dir)

Now we want the pelican that we load in our code to be our hacked version:

If you're feeling ballsy:

    rm -rf my-venv/lib/python3.8/site-packages/pelican

Now, make the above instead be a symlink to the hacked version:

    ln -s ~/src/pelican my-venv/lib/python3.8/site-packages/pelican

That's all for now!
"""

# #born
