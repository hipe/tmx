"""
As far as we can forsee for now, the lifecycle of our clients will go
something like this:

    render the whole screen
    while True:
        block waiting for input

        if input didn't map to any known thing (was invalid)
            express a message about this (to flash)
            continue

        if input was a request to quit
            break

        given the valid input, dispatch [something] to the affected components
        (components themselves might soft error, later for that)
        (for now there's a 1-to-1 map b components affected and visual change)
        based on the components that changed, redraw those components


Design Objectives Overview

First, before we delve any deeper, it's worth mentioning now that
we attempt to write this in a way that is:

1. Fully decoupled from the curses lib (for now)
2. Fully exposed and decomposed for easy testing from the ground up


Component interactions general and specific

There are at least two kinds of .. components that this controller may have
close familiarity with in its interactions (but maybe not): the flash area
and the buttons area. The flash area will get written to "a lot" and the
buttons will change "a lot".

Besides dispatching "button presses" to the appropriate components,
there's one major responsibilty the controller has (not covered explicitly
in the overview pseudocode): managing the selection of components. Actually
it does sort of fit in to the framework laid down by the pseudocode.

(This feels like a responsibility that should be abstracted out into a
different controller that is somehow injected; BUT this also feels like it
may be early abstraction.)


Objectives in practice

To the end of decomposing this for testing, receiving a keypress results
in a response but does NOT itself change the state of the controller OR
components... (EDIT: say something about accept the response)
"""


import re


class InputController_EXPERIMENTAL__:

    def __init__(self, harnesses):
        index = _crazy_index_time(harnesses)
        self._selection_controller = _selection_controller(index, harnesses)

    def receive_keypress(self, k):
        if k in _directions:
            if k in _horizontal:
                return _do_nothing  # ..
            return self._handle_vertical_selection_change(k)

        if _lowercase_alpha.match(k) or _enter == k:
            return self._attempt_to_dispatch(k)

        return self._say_does_nothing(k)

    def _say_does_nothing(self, k):
        # We could map the key strings to prettier labels but why
        def lines():
            yield f"Does nothing: {k!r}"
        return listener('info', 'expression', 'key_does_nothing', lines)

    def _handle_vertical_selection_change(self, k):
        is_down = _is_down(k)
        return self._selection_controller.receive_up_or_down(is_down)


# == Keys metadata

_up, _down, _left, _right = 'KEY_UP', 'KEY_DOWN', 'KEY_LEFT', 'KEY_RIGHT'
_directions = {_up, _down, _left, _right}
_horizontal = {_left, _right}
_is_down = (_up, _down).index  # 👀


_enter = '\n'
_lowercase_alpha = re.compile(r'[a-z]\Z')


# == Selection controller

def _selection_controller(index, harnesses):

    # Set up initial indexes used all over the place
    interactable_harnesses = tuple(harnesses[i] for i in index.offsets_of_interactable_components)  # noqa: E501
    leng = len(interactable_harnesses)
    keys_in_order = tuple(h.key for h in interactable_harnesses)
    harness_via_key = {h.key: h for h in interactable_harnesses}
    order_offset_via_key = {keys_in_order[i]: i for i in range(0, leng)}
    order_offset_of_bottommost = leng - 1

    # Assert that the topmost interactable component is in the focus state
    top_k = keys_in_order[0]  # ..
    top_h = harness_via_key[top_k]
    rest_h = (harness_via_key[keys_in_order[i]] for i in range(1, leng))
    sn = top_h.state.state_name
    if 'has_focus' != sn:
        xx(f"top compponent ({top_k!r}) must already have focus")

    # Assert that the remaining non-top components are in the initial state
    def must_be_in_initial_state(harness):
        sn = harness.state.state_name
        if 'initial' == sn:
            return True
        xx(f"Not in initial state: '{harness.key}' (state: {sn!r})")
    assert all(must_be_in_initial_state(h) for h in rest_h)

    class SelectionController:
        def __init__(self):
            self.key_of_currently_selected_component = top_k

        def receive_up_or_down(self, is_down):
            k = self.key_of_currently_selected_component
            i = order_offset_via_key[k]
            if is_down:
                if order_offset_of_bottommost == i:
                    return _do_nothing
                desired_order_offset = i + 1
            else:
                if 0 == i:
                    return _do_nothing
                desired_order_offset = i - 1

            k_ = keys_in_order[desired_order_offset]
            changes = (
                (k, 'transition_over', 'cursor_exit'),
                (k_, 'transition_over', 'cursor_enter'))
            return _Response(ok=True, changes=changes)

    return SelectionController()


# == Indexing the components

def _crazy_index_time(harnesses):
    (before := set(locals().keys())).add('before')  # 🙄
    # == BEGIN MAGIC

    offsets_of_interactable_components = []

    # == END MAGIC
    index_keys_in_order = tuple(k for k in locals().keys() if k not in before)

    offset = -1
    for harness in harnesses:
        offset += 1

        if harness.state is None:
            continue

        offsets_of_interactable_components.append(offset)

    locs = locals()
    res = {k: locs[k] for k in index_keys_in_order}

    from collections import namedtuple as _nt
    return _nt('_Index', tuple(res.keys()))(**res)


# == Response structure and related (Model-esque)

def listener(*args):
    # A big hack to make code read more familiarly but BE CAREFUL

    emi = _Emission(args)
    emis = (emi,)
    ok = _severity_is_OK[emi.severity]
    return _Response(ok=ok, emissions=emis)


class _Response:

    def __init__(self, ok, changes=None, emissions=None):
        self.OK = ok
        self.changes = changes
        self.emissions = emissions

    @property
    def do_nothing(self):
        return self.changes is None and self.emissions is None


class _Emission:
    # For now a pared down version of the familiar thing, rewritten

    def __init__(self, tup):
        self.severity, shape, self.category, self.to_messages = tup
        assert 'expression' == shape


_severity_is_OK = {'info': True}


_do_nothing = _Response(ok=True)


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #born
