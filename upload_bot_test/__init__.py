"""[#204] explains it all (cousin file in diff sub-project, same location)"""


def _():  # (a scope for lvars - don't accidentally export any names)

    import os
    import sys

    path = os.path
    dirname = path.dirname

    _top_test_dir = dirname(path.abspath(__file__))
    _project_dir = dirname(_top_test_dir)

    a = sys.path
    _current_head_path = a[0]

    if _project_dir == _current_head_path:
        pass  # assume individual test file was the entrypoint
    else:
        raise Exception('design me - no problem')


_()

# #born.
