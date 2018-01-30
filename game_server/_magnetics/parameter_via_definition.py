import game_server
dangerous_memoize = game_server.dangerous_memoize


class SELF:

    def __init__(self,
        description = None,
        default_value = None,
        argument_arity = None,
    ):
        if argument_arity is None:
            argument_arity = _ARITIES.COMMON
        self._argument_arity_range = argument_arity

        self.description = description
        self.default_value = default_value


class _CommonArityKinds:

    @property
    @dangerous_memoize
    def LIST(self):
        return _MyArity(0, None)

    @property
    @dangerous_memoize
    def FLAG(self):
        return range(0, 0)

    @property
    @dangerous_memoize
    def COMMON(self):
        return range(1, 1)


_ARITIES = _CommonArityKinds()
ARITIES = _ARITIES


class _MyArity:
    """(so that we can use None to signify unbound ranges)"""

    def __init__(self, start, stop):
        self.start = start
        self.stop = stop

# #born.
