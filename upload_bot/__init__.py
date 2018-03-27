"""(experimental place for things like these)"""


def _():  # (scope)
    """python normally adds the dirname of the entrypoint file to sys.path..

    we do *not* want that. in our case we want to add one up from that.
    """

    from os import path
    dirname = path.dirname
    import sys

    sub_project_dir = dirname(path.abspath(__file__))
    project_dir = dirname(sub_project_dir)

    a = sys.path
    current_head_path = a[0]

    if sub_project_dir == current_head_path:
        """CLOBBER the path that python automatically added - we don't want
        it to be there (lest we make unstable assumptions). #[#204]
        """
        a[0] = project_dir
        print("done!")
    elif project_dir != current_head_path:
        raise Exception('strange - what is up with sys.path')


_()


class Exception(Exception):

    def __init__(self, s, *items):
        if 0 == len(items):
            msg = s
        else:
            msg = s.format(*items)
        super().__init__(msg)

# born.
