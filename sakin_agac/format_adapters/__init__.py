from modality_agnostic.memoization import (
        lazy,
        )


@lazy
def EVERY_MODULE():

    def f():
        _entries = (path.basename(x) for x in glob_glob(_this_glob))
        _stems = (stem for stem in _entries if _this_rx.search(stem))
        return (importlib.import_module('.%s' % x, __name__) for x in _stems)

    from os import path
    import re

    _dir = path.dirname(__file__)
    _this_glob = path.join(_dir, '*')
    _this_rx = re.compile(r'^(?!_)[^\.]+(?:\.py)?$')

    """
    such that:
      - don't match if it starts with an underscore
      - if it has an extension, the extension must be '*.py'
      - fnmatch might be more elegant, but we don't knowt yet
    """

    import importlib
    from glob import glob as glob_glob
    return f


# #born.
