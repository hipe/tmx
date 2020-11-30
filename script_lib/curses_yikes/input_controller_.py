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


from script_lib.curses_yikes import \
        Emission_ as _emission, MultiPurposeResponse_ as _multi_response
import re


_input_response = _multi_response
_change_response = _input_response


class InputController_EXPERIMENTAL__:

    def __init__(self, harnesses):
        index = _crazy_index_time(harnesses)
        self._selection_controller = _selection_controller(index, harnesses)
        self._harnesses = harnesses

    def receive_keypress(self, k):
        if k in _directions:
            if k in _horizontal:
                return _do_nothing  # ..
            return self._handle_vertical_selection_change(k)

        if _lowercase_alpha.match(k) or _enter == k:
            return self._attempt_to_dispatch(k)

        return self._say_does_nothing(k)

    def _attempt_to_dispatch(self, keycode):

        # Does the keypress correspond to one of the currently showing buttons?
        bc = self._buttons_controller
        tup = bc.type_and_label_of_button_via_keycode__(keycode)
        if tup is None:
            return self._say_does_nothing(keycode)
        typ, label = tup

        if 'static' == typ:
            if 'q' == keycode:  # hardcoded for now
                return _response_for_quit()
            reason = "waiting to implement statics until dynamics API is est."
            xx(f"{reason} {keycode!r}")
        assert 'dynamic' == typ

        # Since this was a dynamic button, it must correspond to a transition

        # (since this was a dynamic button, a component must be selected)
        k = self._key_of_currently_selected_component
        ca = self._concrete_area(k)
        if not ca.state.transition_via_transition_name(label):
            frm = ca.state.state_name
            reason = f"no transition {label!r} from {frm!r}"
            raise RuntimeError(reason)

        changes = (
            ('input_controller', 'apply_transition', k, label),
        )
        return _input_response(changes=changes)

    def _say_does_nothing(self, k):
        # We could map the key strings to prettier labels but why
        def lines():
            yield f"Does nothing: {k!r}"
        return listener('info', 'expression', 'key_does_nothing', lines)

    def _handle_vertical_selection_change(self, k):
        is_down = _is_down(k)
        return self._selection_controller.receive_up_or_down(is_down)

    def apply_changes(self, changes):
        tup = tuple(self._responses_from_apply_changes(changes))
        return tup[0].__class__.MERGE_RESPONSES_EXPERIMENT_(tup)

    def _responses_from_apply_changes(self, changes):
        for change in changes:
            stack = list(reversed(change))
            which_controller = stack.pop()
            if 'input_controller' == which_controller:
                me = self
            else:
                me = getattr(self, _which_controller[which_controller])
                if me is None:
                    # #todo we could unwind this
                    continue  # allow CCA w/o buttons during testing #here1
            yield me.apply_change(stack)

    def apply_change(self, stack):  # not part of our own public API so to
        typ = stack.pop()
        assert 'apply_transition' == typ
        return self._do_apply_transition(* reversed(stack))

    def _do_apply_transition(self, k, trans_name):
        ca = self._concrete_area(k)
        trans = ca.state.transition_via_transition_name(trans_name)
        afn = trans.action_function_name
        ca.state.accept_transition(trans)  # before? after?

        # #eventually imagine the component's definition including a custom
        # controller function that does some kind of validation and writes
        # to flash on failure, or maybe it leads to other changes in the UI
        # in other components.. What would be great is to pass it a
        # mini-client that manages the writing of the response

        if afn is None:
            return _change_response(changed_visually=(k,))

        resp = getattr(ca, afn)()  # args?
        if not resp:
            xx(f"whoopsie: now, must result in response {k!r} {afn!r}")
        resp.changes  # assert interface
        return resp

    @property
    def _buttons_controller(self):
        # #[#608.2.C] buttons as magic name. CA as controller is experimental
        if 'buttons' not in self._harnesses:
            return  # allow CCA not to have buttons during testing #here1
        return self._concrete_area('buttons')

    @property
    def _key_of_currently_selected_component(self):
        return self._selection_controller.key_of_currently_selected_component

    def _concrete_area(self, k):
        return self._harnesses[k].concrete_area


_which_controller = {
    'buttons_controller': '_buttons_controller',
    'selection_controller': '_selection_controller'
}


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
    interactable_harnesses = tuple(harnesses[k] for k in index.keys_of_interactable_components)  # noqa: E501
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

            sn = harness_via_key[k_].state.state_name_via_transition_name('cursor_enter')  # noqa: E501

            changes = (
                ('selection_controller', 'change_selected', k, k_),
                ('buttons_controller', 'selected_changed', k_, sn),
            )
            return _input_response(changes=changes)

        def apply_change(self, stack):
            m = which_change[stack.pop()]
            return getattr(self, m)(* reversed(stack))

        def _do_change_selected(self, k, k_):
            goodbye = harness_via_key[k]
            hello = harness_via_key[k_]
            goodbye.state.move_to_state_via_transition_name('cursor_exit')
            hello.state.move_to_state_via_transition_name('cursor_enter')
            self.key_of_currently_selected_component = k_
            return _input_response(changed_visually=(k, k_))

    which_change = {'change_selected': '_do_change_selected'}

    return SelectionController()


# == Indexing the components

def _crazy_index_time(harnesses):
    (before := set(locals().keys())).add('before')  # 🙄
    # == BEGIN MAGIC

    keys_of_interactable_components = []

    # == END MAGIC
    index_keys_in_order = tuple(k for k in locals().keys() if k not in before)

    for k, harness in harnesses.items():
        if harness.state is None:
            continue
        keys_of_interactable_components.append(k)

    locs = locals()
    res = {k: locs[k] for k in index_keys_in_order}

    from collections import namedtuple as _nt
    return _nt('_Index', tuple(res.keys()))(**res)


# == Response structure and related (Model-esque)

def _response_for_quit():
    line = 'Goodbye from ncurses yikes®'  # #todo put app name here, or not
    emi = _emission(('info', 'expression', 'goodbye', lambda: (line,)))
    changes = (('host_directive', 'quit'),)
    return _input_response(emissions=(emi,), changes=changes)


def listener(*args):
    # A big hack to make code read more familiarly but BE CAREFUL

    emi = _emission(args)
    emis = (emi,)
    return _change_response(emissions=emis)


_do_nothing = _change_response()


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #born
