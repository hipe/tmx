"""the purpose of this is to drive forward the development of format ..

..adapters with a trivially simple case, one that should probably never
be useful in production.

(specifically it makes a format adapter for an array of dictionaries.)

  - for one thing, if this *is* useful, don't be afraid to move it and
    its test node into the asset tree

  - for another thing, we are currently making this over-broad to work
    with arbitrary different "schema" (more on this later) so it is quite
    anemic at this point.
"""

from sakin_agac.magnetics import (
        format_adapter_via_definition,
        )


_SELF = format_adapter_via_definition(
        item_via_collision=None,  # doing this in tests too
        item_stream_via_native_stream=None,  # will use default
        natural_key_via_object=None,  # this changes per test suite
        )


import sys  # noqa: E402
sys.modules[__name__] = _SELF  # #[#008.G] so module is callable

# #born.
