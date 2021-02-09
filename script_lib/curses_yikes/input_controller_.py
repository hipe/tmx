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
in the overview pseudocode): managing the focus of components. Actually
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
        Emission_ as _emission, MultiPurposeResponse_ as _response
import re


class InputController__:

    def __init__(
            self,
            directional_controller,
            buttons_area,
            harnesses_experimental):

        # When a business buttonpress (BBP) comes in, the default (defined
        # here) is that the currently focused component handles it (both
        # strokes: receive keypress then apply patch).

        def recv_busi_bp(label):
            return c().receive_business_buttonpress(label)

        def apply_busi_bp(label):
            return c().apply_business_buttonpress(label)

        def c():
            return directional_controller.currently_focused_component

        frame = _controller_frame(
            get_direction_controller=lambda: directional_controller,
            receive_BBP=recv_busi_bp, apply_BBP=apply_busi_bp,
            harnesses_experimental=harnesses_experimental)

        self._controller_stack = [frame]

        self._buttons_area = buttons_area

    def receive_keypress(self, keycode):
        # Is the keypress an arrow key? Use the frame's direction controller
        if keycode in _arrow_keys:
            # DC = direction controller
            return self._DC.receive_directional_key_press(keycode)

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
        return self._top_controller_frame.receive_BBP(label)

    def _say_does_nothing(self, k):
        # We could map the key strings to prettier labels but why
        def lines():
            yield f"Does nothing: {k!r}"
        return listener('info', 'expression', 'key_does_nothing', lines)

    # ==

    def apply_changes(self, changes):
        tup = tuple(self._responses_from_apply_changes(changes))
        resp = tup[0].__class__.MERGE_RESPONSES_EXPERIMENT_(tup)

        # == BEGIN UGLY QUICKFIX
        #    when we have frames, they send back local names. The outer loop
        #    doesn't (and shouldn't) know about frame-local names. Managing
        #    rendering sub-systems ("pads") is way out of our scope.
        #    For now we just render the whole SAC IFF it sent back names

        if resp.changed_visually is None:
            return resp

        if 1 == len(self._controller_stack):
            return resp

        # What are all the keys in the response not in the SAC children?
        all_h = {k: None for k in resp.changed_visually}  # uniqify
        cx = self._DC.CHA_CHA_CHA__
        use_h = {k: None for k in all_h.keys() if k not in cx}

        # If there are keys in the response not in the "use", render whole SAC
        if len(use_h) < len(all_h):
            k = self._controller_stack[-1].SOA_component_key
            use_h[k] = None

        resp.changed_visually = tuple(use_h.keys())  # meh
        # == END
        return resp

    def _responses_from_apply_changes(self, changes):

        for change in changes:
            stack = list(reversed(change))
            which_controller = stack.pop()

            # == FROM eventually
            if 'input_controller' == which_controller:
                typ = stack.pop()
                args = tuple(reversed(stack))
                if 'change_focus' == typ:
                    for resp in self._apply_change_focus(*args):
                        yield resp
                elif 'change_buttons' == typ:
                    yield self._apply_change_buttons(*args)
                elif 'apply_business_buttonpress' == typ:
                    yield self._apply_business_buttonpress(*args)
                elif 'traverse_transition' == typ:
                    yield self._apply_traverse_transition(*args)
                elif 'push_receiver' == typ:
                    yield self._apply_push_receiver(*args)
                elif 'pop_receiver' == typ:
                    yield self._apply_pop_receiver(*args)
                else:
                    xx(f"easy for you my friend: {typ!r}")
            elif 'child_component' == which_controller:
                yield self._apply_change_for_child_component(stack)
            elif 'parent_area' == which_controller:
                typ = stack.pop()
                if 'translate_area' == typ:
                    yield self._bounceback_translate_area(stack)
                else:
                    xx(f"easy for you my friend: {typ!r}")
            else:
                raise RuntimeError(f"oops: {which_controller!r}")
            # == TO

    def _bounceback_translate_area(self, stack):
        # Typically rendering happens by: responses flag those components that
        # need a redraw, then just before the host blocks for input, it asks
        # the root compound area for those components and asks those components
        # for their current rows, then we (somehow) determine screen offsets
        # for the rows and render them to screen.

        # But when it comes to an "emacs field", the component has almost no
        # interest in managing the rendering (or input) itself. It only wants
        # to be able to specify an X and a width and let the host do the rest.
        # Here we translate SAC-space coordinates to screen coords for that..

        these = tuple(stack.pop() for _ in range(0, 7))
        recip, typ, comp_path, h, w, y, x = these

        if 2 < len(self._controller_stack):
            xx("wow how ambitious. do you really want to do this?")

        hh = self._controller_stack[-2].harnesses_experimental
        ah = hh[comp_path[0]]  # 😢
        use_y, use_x = ah.translate_point__(y, x)

        change = recip, typ, comp_path, h, w, use_y, use_x, *reversed(stack)
        return _response(changes=(change,))

    def _apply_change_for_child_component(self, stack):
        which_k = stack.pop()
        meth = stack.pop()

        # (this is more fragile than it needs to be and makes no sense:
        # if the controller frame of the target component is at top, why reach
        # back minus one and ask for the child by name? because the controller
        # frame currently doesn't just have the plain old SAC on hand 🙃)
        ca = self._controller_stack[-2].harnesses_experimental[which_k].concrete_area  # noqa: E501
        return getattr(ca, meth)(* reversed(stack))

    def _apply_push_receiver(self, soa_k):
        """implement the ability for a child component to change the input

        mode so it receives focus and handles directional events itself.
        See section on SACs in [#608.L].

        The details of this (like the interface of the directive, the
        interface of the below methods called) are all HIGHLY EXPERIMENTAL.
        it's just a rough prototyping sketch
        """

        # Get what is probably the component with focus
        # (amazing we get this far (as the I.C) without needing these)
        # (this is the payback for the convenience of string-only directives)
        stack = self._controller_stack
        cx = stack[-1].DC.FOCUSABLE_COMPONENTS__
        c = cx[soa_k]

        # Build and push the new frame
        kw = {k: v for k, v in c.CONTROLLER_FRAME__()}

        # Remove this one thing from it
        cbpk = kw.pop('component_button_page_key_once_has_focus')

        # Add this one thing to it
        kw['SOA_component_key'] = soa_k

        new_frame = _controller_frame(**kw)
        stack.append(new_frame)

        # Assume SAC already focuses its top child when it itself gets focus.
        # But now that we're pushing in to it we gotta change buttons

        # Gotta change the buttons. Assume SAC already had item with focus

        changes = (('input_controller', 'change_buttons', soa_k, cbpk),)
        resp = _response(changes=changes)

        # We're like 99% sure we want to stale the buttons always because
        # that's practically the whole point of pushing in to a new mode is
        # getting new available actions. Otherwise, if not here, where?

        # Redraw the whole SAC (meh) and the buttons,
        assert resp.changed_visually is None  # hack it. meh
        resp.changed_visually = (soa_k, 'buttons')
        return resp

    def _apply_pop_receiver(self, soa_k):
        frame = self._controller_stack.pop()
        assert soa_k == frame.SOA_component_key
        # the SAC should still have focus.
        # in an earlier stroke it should have changed buttons
        return _no_change

    def GIVE_FOCUS_TO_TOPMOST_FOCUSABLE_COMPONENT__(self):
        """
        An implicit premise is that there is is always exactly one component
        with focus (sort of). Imagine an interface where this is not so: What
        should UP or DOWN do if there is no focused component to start with?
        UP or DOWN from where? :[#608.P]

        At first, the solution might seem to be just to automatically give
        focus to first focusable component every time you construct a branch
        component. But what if you have a nested branch component (an SAC) and
        something focusable above it?

        The trick is to give focus to the topmost thing (and what this means
        recursively is a thing); only from the outside of the interface tree
        from somewhere where you know who the root is.

        But this is a heavy lift: changing the focus creates patches and
        we apply those patches recursively here (and see assertions).

        This should only be called before the first render b.c it's not
        integrated with the full input loop w/ r.t `changed_visually`
        """

        k = self._DC.key_of_topmost_focusable_component
        resp = self._DC.change_focus_to(k)
        assert resp.emissions is None
        while True:
            # ignore changed_visually, this is for before first render and SACs
            resp = self.apply_changes(resp.changes)
            assert resp.emissions is None
            if resp.changes is None:
                break

    # cbpk = component button page key lol
    def _apply_change_focus(self, k, butt_k, k_, cbpk):

        # Bounce the focus controller's own patch back to it so it notifies
        # one component of the loss and one of the gain ("cast" the direction
        # controller to a focus controller)
        no = self._DC.apply_change_focus(k, k_)
        assert no is None

        # Change the button area (probably) and notify BBC
        yield self._apply_change_buttons(butt_k, cbpk)

        cv = *(() if k is None else (k,)), k_

        yield _response(changed_visually=cv)

    def _apply_change_buttons(self, k_, cbpk):
        # Notify the buttons so they change the dynamic buttons

        if (ba := self._buttons_area) is None:
            # (for some tests we allow a None button controller :#here1)
            return _no_change

        resp = ba.apply_change_focus(k_, cbpk)
        assert resp
        # (used to do thing here)

        return resp

    def _apply_business_buttonpress(self, label):  # (be just like #here2)
        return self._top_controller_frame.apply_BBP(label)

    def _apply_traverse_transition(self, trans_name, *item_k):
        return self._top_controller_frame.apply_BBP(trans_name, *item_k)

    @property
    def _DC(self):
        return self._top_controller_frame.DC

    @property
    def _top_controller_frame(self):
        return self._controller_stack[-1]


class _controller_frame:
    def __init__(
            self, get_direction_controller, receive_BBP, apply_BBP,
            harnesses_experimental=None, SOA_component_key=None):
        self.get_direction_controller = get_direction_controller
        self.receive_BBP, self.apply_BBP = receive_BBP, apply_BBP
        self.harnesses_experimental = harnesses_experimental
        self.SOA_component_key = SOA_component_key

    @property
    def DC(self):
        return self.get_direction_controller()


# == Response structure and related (Model-esque)

def _response_for_quit():
    line = 'Goodbye from ncurses yikes®'  # #todo put app name here, or not
    emi = _emission(('info', 'expression', 'goodbye', lambda: (line,)))
    changes = (('host_directive', 'quit'),)
    return _response(emissions=(emi,), changes=changes)


def listener(*args):
    # A big hack to make code read more familiarly but BE CAREFUL

    emi = _emission(args)
    emis = (emi,)
    return _response(emissions=emis)


_no_change = _response()


# == Local constants

_arrow_keys = set('KEY_UP KEY_RIGHT KEY_DOWN KEY_LEFT'.split())
_enter = '\n'
_lowercase_alpha = re.compile(r'[a-z]\Z')


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #born
