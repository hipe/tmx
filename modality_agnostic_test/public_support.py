from modality_agnostic.memoization import lazy


@lazy
def empty_command_module():
    import types
    ns = types.SimpleNamespace()
    setattr(ns, 'PARAMETERS', None)

    class DoYouSeeMe:
        pass
    setattr(ns, 'Command', DoYouSeeMe)
    return ns

# #born.
