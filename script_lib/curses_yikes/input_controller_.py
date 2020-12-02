"""
As far as we can forsee for now, the lifecycle of our clients will go
something like this:

    while True:
        render all the parts of the screen that need rendering
        block waiting for input

        if input didn't map to any known thing (was invalid)
            express a message about this (to flash)
            continue

        if input was a request to quit
            break

        given the valid input, dispatch [something] to the affected components
        (components themselves might soft error, later for that)
        (for now there's a 1-to-1 map b components affected and visual change)
        somehow keep track of which components need a redraw


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
components... All of this is now documented in [#608.L]
"""


from script_lib.curses_yikes import \
        Emission_ as _emission, MultiPurposeResponse_ as _multi_response
from collections import namedtuple as _nt
import re


_input_response = _multi_response
_change_response = _input_response


class InputController__:

    def __init__(
            self,
            directional_controller, business_buttonpress_controller,
            buttons_area):

        frame = _controller_frame(
            directional_controller, business_buttonpress_controller)

        self._controller_stack = [frame]

        self._buttons_area = buttons_area

    def receive_keypress(self, keycode):
        # Is the keypress an arrow key? Use the frame's direction controller
        if keycode in _arrow_keys:
            # DC = direction controller
            return self._top_frame.DC.receive_directional_key_press(keycode)

        # Does the keypress look like a business keypress?
        if not (_lowercase_alpha.match(keycode) or _enter == keycode):
            return self._say_does_nothing(keycode)

        # Does the keypress correspond to one of the currently showing buttons?
        bc = self._buttons_area  # bc = buttons controller
        tup = bc.type_and_label_of_button_via_keycode__(keycode)
        if tup is None:
            return self._say_does_nothing(keycode)
        typ, label = tup

        # Is the keypress for a static button?
        if 'static' == typ:
            if 'q' == keycode:  # hardcoded for now
                return _response_for_quit()
            reason = "waiting to implement statics until dynamics API is est."
            xx(f"{reason} {keycode!r}")
        assert 'dynamic' == typ

        # Since this was a dynamic button, it must correspond to a transition
        # BBC = buttonpress business controller
        return self._top_frame.BBC.receive_business_buttonpress(label)

    def _say_does_nothing(self, k):
        # We could map the key strings to prettier labels but why
        def lines():
            yield f"Does nothing: {k!r}"
        return listener('info', 'expression', 'key_does_nothing', lines)

    def apply_changes(self, changes):
        tup = tuple(self._responses_from_apply_changes(changes))
        return tup[0].__class__.MERGE_RESPONSES_EXPERIMENT_(tup)

    def _responses_from_apply_changes(self, changes):

        for change in changes:
            stack = list(reversed(change))
            which_controller = stack.pop()

            # == FROM eventually
            if 'input_controller' == which_controller:
                typ = stack.pop()
                assert 'apply_transition' == typ
                yield self._do_apply_transition(* reversed(stack))

            elif 'selection_controller' == which_controller:
                yield self._top_frame.DC.apply_change(stack)

            elif 'buttons_controller' == which_controller:
                ba = self._buttons_area
                if ba is None:
                    continue  # allow CCA w/o buttons during testing
                    # #todo we could unwind this
                yield ba.apply_change(stack)

            else:
                raise RuntimeError(f"oops: {which_controller!r}")

            # == TO

    def _do_apply_transition(self, k, trans_name):
        return self._top_frame.BBC.apply_transition(k, trans_name)

    @property
    def _top_frame(self):
        return self._controller_stack[-1]


_controller_frame = _nt('CF', ('DC', 'BBC'))


def BUSINESS_BUTTONPRESS_CONTROLLER_VIA_(selection_controller, cx):

    def receive_business_buttonpress(label):
        curr_k = selection_controller.key_of_currently_selected_component
        ca = cx[curr_k]
        if not ca.state.transition_via_transition_name(label):
            frm = ca.state.state_name
            reason = f"no transition {label!r} from {frm!r}"
            raise RuntimeError(reason)
        changes = (('input_controller', 'apply_transition', curr_k, label),)
        return _input_response(changes=changes)

    def apply_transition(k, trans_name):

        # Dereference the transition by name and traverse it
        ca = cx[k]
        trans = ca.state.transition_via_transition_name(trans_name)
        afn = trans.action_function_name
        ca.state.accept_transition(trans)  # before? after?

        # If the component's FFSA didn't have an action associated with this
        # transition, you are done (and assume it changed visually)
        if afn is None:
            return _change_response(changed_visually=(k,))

        # Call the action as implemented by the component
        resp = getattr(ca, afn)()  # args?
        if not resp:
            xx(f"whoopsie: now, must result in response {k!r} {afn!r}")
        resp.changes  # assert interface now, just for sanity for now
        return resp

    locs = locals()
    return _busi_buti_conti(** {k: locs[k] for k in _busi_buti_conti._fields})


_busi_buti_conti = _nt(
    '_busi_buti_cont', ('receive_business_buttonpress', 'apply_transition'))


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


# == Local constants

_arrow_keys = set('KEY_UP KEY_RIGHT KEY_DOWN KEY_LEFT'.split())
_enter = '\n'
_lowercase_alpha = re.compile(r'[a-z]\Z')


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #born
