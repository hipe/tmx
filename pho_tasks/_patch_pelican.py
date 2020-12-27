# At writing, this file contains nothing but "tasks" that tell you how to
# apply particular patches to your pelican installation. This is so hacky
# and rough that we don't go any further in automating it than that, but
# these "tasks" are here such as they are as a placeholder for the idea.


def patch_pelican_for_generate_selected(c):
    return _write_these_lines(_lines_for_generate_selected())


def patch_pelican_for_write_selected(c):
    return _write_these_lines(_lines_for_write_selected())


def _write_these_lines(lines):
    from sys import stdout as out
    w = out.write
    for line in lines:
        w(line)


def _lines_for_generate_selected():
    return _lines_via_big_string(_generate_selected_big_string)


def _lines_for_write_selected():
    return _lines_via_big_string(_write_selected_big_string)


def _lines_via_big_string(big_string):
    from re import finditer
    itr = (md[0] for md in finditer(r'[^\n]*\n', big_string))
    assert "\n" == next(itr)  # every big string in this file
    return itr


_generate_selected_big_string = """
We apply this patch in exactly the same way we apply the other one.

Assume this patch requires that the other patch has already been applied:

Although the two patches don't depend on each other functionally, they both
effect the same file, so the latter patch is made assuming the lines and
line numbers of the end state of the first patch yikes.

Follow the instructions for the "patch-pelican-for-write-selected" task. Then:

    cd ~/src/pelican
    patch -p1 < [mono repo dir]/pho_tasks/tasks-data/patch-pelican-for-generate-selected.diff
    popd

That's it!
"""  # noqa: E501


_write_selected_big_string = """
NOTE: for now just read the end of this
    https://github.com/getpelican/pelican/issues/2678

Don't read the rest of this. it's just here for posterity for now

This is too much to put in to a proper task, especially because
ideally we'll get this patch accepted in to pelican, but we have made it look
like it's a task for consistency and taxonomic aesthetics.

The issue is that pelican has a bug (github issue #2678 (which went stale))
where its `--write-selected` feature silently fails.

The fix is only three or four lines of code that need changing, so what we
do for now is keep these changes in a patch and apply the patch to a known
stable version of pelican.

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
