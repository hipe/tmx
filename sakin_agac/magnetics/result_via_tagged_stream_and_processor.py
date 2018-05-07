"""birth note:

we are sure (almost) we're gonna want something like this, but we don't
yet know what its full API should be so no tests yet. abstracted at birth.
"""

import sys


def _SELF(tagged_stream, processor):

    current_typ = 'BEGIN'
    current_bound_method = None

    def transition_to(typ):
        nonlocal current_typ
        transition_method_name = 'move_from__%s__to__%s' % (current_typ, typ)
        current_typ = typ

        transition = getattr(processor, transition_method_name)
        if transition is not None:
            return transition()

    for (typ, x) in tagged_stream:

        if current_typ != typ:
            transition_to(typ)
            current_bound_method = getattr(processor, typ)  # subject to change

        current_bound_method(x)

    return transition_to('END')


sys.modules[__name__] = _SELF

# #born.
