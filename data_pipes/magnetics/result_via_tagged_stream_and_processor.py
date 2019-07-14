"""birth note:

we are sure (almost) we're gonna want something like this, but we don't
yet know what its full API should be so no tests yet. abstracted at birth.

:[#411]
"""

import sys


def _SELF(tagged_stream, processor):

    self = _ThisState()

    self._current_type = 'BEGIN'
    current_bound_method = None

    def transition_to(typ):
        m = 'move_from__%s__to__%s' % (self._current_type, typ)
        self._current_type = typ

        transition = getattr(processor, m)
        if transition is not None:
            return transition()

    for (typ, x) in tagged_stream:

        if self._current_type != typ:
            transition_to(typ)
            current_bound_method = getattr(processor, typ)  # subject to change

        current_bound_method(x)

    return transition_to('END')


class _ThisState:  # #[#510.2]
    pass


sys.modules[__name__] = _SELF

# #born.
