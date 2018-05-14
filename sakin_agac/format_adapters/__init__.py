from modality_agnostic.memoization import (
        lazy,
        )


@lazy
def EVERY_MODULE():
    """result is an iterator over every such module.

    don't let the `lazy` fool you: this function is re-entrant:

    it can be called multiple times, and the filesystem is hit anew each
    time. (so if you weirdly add or remove filesystem nodes at runtime, it
    would get picked up.)
    """

    def f():
        return modules_via_directory_and_mod_name(*main_module_tuple)

    def _ALTERNATE_FOR_REFERENCE():
        # (this worked when it was written.)
        # (it's "proof" that we can support multiple adapter dirs)
        for x in modules_via_directory_and_mod_name(*main_module_tuple):
            yield x
        for x in modules_via_directory_and_mod_name(*other_module_tuple):
            yield x

    def modules_via_directory_and_mod_name(direc, mod_name):

        _this_glob = os_path.join(direc, '*')
        _entries = (os_path.basename(x) for x in glob_glob(_this_glob))

        def stems():
            # before #history-A.1 this used to be an elegant generator
            # expression, and could probably be made one again (a reduce)
            for entry in _entries:
                md = rx.search(entry)
                if md is not None:
                    yield md[1]

        _stems = stems()
        return (importlib.import_module('.%s' % x, mod_name) for x in _stems)

    from os import path as os_path
    dn = os_path.dirname
    import re

    main_dir = dn(__file__)

    main_module_tuple = (main_dir, __name__)

    if False:  # (see related test above)
        these = ('sakin_agac_test', 'format_adapters')
        other_module_tuple = (
                os_path.join(dn(dn(main_dir)), * these),
                '.'.join(these),
                )

    rx = re.compile(r'(^(?!_)[^\.]+)(?:\.py)?$')
    """
    such that:
      - don't match if it starts with an underscore
      - if it has an extension, the extension must be '*.py'
      - fnmatch might be more elegant, but we don't know it yet
    """

    import importlib
    from glob import glob as glob_glob
    return f

# #history-A.1: as referenced
# #born.
