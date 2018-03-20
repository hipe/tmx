"""holy jeez why is this so complicated :[#204]:

above all, we want our `sys.path`-hacking nonsense to be unobtrustive

  - we want it to be clear what's going on when reading code

  - we acknowledge now that we don't know the right way to do this,
    and so we've got to anticipate that we'll fix this in the future,
    so we want to leave an "upgrade path" to that in our work near it.

  - and although this is ugly, at least it's an improvement on all the
    copy-paste boilerplate mess we had before #history-A.1.

imagine this tree:

    whole_universe_project/
        subproj_one/
        subproj_two/
        subproj_two_test/
            __init__.py                # "file A"
            test_100_la_la/
                __init__.py            # "file B"
                test_050_chu_chah.py
so:
  - when a single test file is the entrypoint (such as `[etc]_chu_chah.py`),
    *first* "file B" is imported (evaluated), *then* (because "file B"
    does it explicitly), "file A" is evaluted.

  - weirdly, when we run the whole test suite (`subproj_two_test`),
    the order that the files are evaluated is the same -
    "file B" *then* "file A"



More In-depth Analysis of the Problem:

what we're aiming to solve is the problem of how module imports work *for*
our own files *from* our own files in our project:

without what we do here, module imports for our own files will either
be broken or not broken based on what assumptions we make in the file
and whether we are running for production or running unit tests.

what we've been able to ascertain so far is that *the entrypoint file's
parent directory* is added automatically to the `sys.path`. what we mean
by "entrypoint file":

  - when you are running the server for production, the entrypoint file
    is `grep_dump/server.py` (FOR NOW).

  - when you are running a single test file, the entrypoint file is that file.

  - when you are running the test suite for the project, the entrypoint file
    is *this file* (or one like it) (AND IT DOES SOME OTHER STUFF).

so ordinarily:

  - when running under production, `sys.path` will have `grep_dump/`
    (but not the below thing).

  - when running tests, `sys.path` will have `grep_dump_test/text_XX_YY/`
    (but not the above thing).

this poses a problem because it means we will get different behavior in
regards to how we would import baed on what context we're running under.



Towards a Solution:

there are a few variables we can play with, including:

  - should we assume the exact same `sys.path` for testing as we have
    for production runtime? (as it is it's not exactly the same, because
    someone somewhere is adding '' when we run the test suite.)

  - (related to above) when we import modules for tests, should we prefer
    "fully qualified" names (that go from the top of our project) or
    ones that are sub-project-local, etc?

  - [same question but for our "asset" files (main code files)]



Our Current Solution:

a deeper confouding detail is that our test file *does* import our "file B"
when we are running the test suite and does *not* when we are just running
a single file.

"""

def _():  # (keep lvars in a scope - do not "accidentally" export them)

    import os
    import sys

    path = os.path
    dirname = path.dirname

    top_test_dir = dirname(path.abspath(__file__))
    project_dir = dirname(top_test_dir)

    a = sys.path
    current_head_path = a[0]

    if project_dir == current_head_path:
        pass  # assume individual test file was the entrypoint
    else:
        raise Exception('design me - no problem')

    writable_tmpdir = path.join(top_test_dir, 'writable-tmpdir')

    return (writable_tmpdir,)

writable_tmpdir, = _()

# #history-A.1 - change from empty to hack sys.path
