from modality_agnostic.memoization import (  # noqa: F401
        memoize,
        )


@memoize
def empty_command_module():
    import types
    ns = types.SimpleNamespace()
    setattr(ns, 'PARAMETERS', None)

    class DoYouSeeMe:
        pass
    setattr(ns, 'Command', DoYouSeeMe)
    return ns

# #born.
