def build_this_crazy_context_manager_():
    # NOTE We want to move this to the "curses adapter" sibling module soon
    # (this is like the `curses.wrapper` but ..)

    stack, self = _build_this_crazy_stack()

    from contextlib import contextmanager as cm

    @cm
    def cm():
        undo_stack = []
        try:
            while stack:
                item = stack.pop()
                item.do()

                # Don't add `undo` until after the `do` completes successfully
                undo_stack.append(item.undo)

            yield self

        finally:
            while undo_stack:
                undo_stack.pop()()

    return cm()


def _build_this_crazy_stack():
    # borrows heavily from https://docs.python.org/3/howto/curses.html

    def item(cls):  # #
        result.append(cls)  # meh

    result = []

    # Enter the curses session at the beginning; and exit it at the end
    @item
    class _:
        def do():  # "Before doing anything, curses must be initialized"
            self.stdscr = curses.initscr()

        def undo():
            curses.endwin()  # we want this to be called last

    # Turn echoing off while we are in curses. Turn it back on at the end
    @item
    class _:
        def do():
            curses.noecho()  # only show the keys typed when we say so

        def undo():
            curses.echo()

    # React to keys pressed instantly; don't require enter key to be pressed
    @item
    class _:
        def do():
            curses.cbreak()

        def undo():
            curses.nocbreak()

    # Get constants like curses.KEY_LEFT, not multibyte escape sequences
    @item
    class _:
        def do():
            self.stdscr.keypad(True)

        def undo():
            self.stdscr.keypad(False)

    class self:  # #class-as-namespace
        pass

    import curses

    self.curses = curses

    return list(reversed(result)), self


# == Rendering

def _piece_via_has_focus(glyph_plus_space):

    def piece_via_has_focus(has_focus):
        return glyph_plus_space if has_focus else blank_span

    self = piece_via_has_focus

    leng = len(glyph_plus_space)
    assert leng  # or not, whatever
    self.width = leng

    blank_span = ' ' * leng
    self.blank_span = blank_span

    return piece_via_has_focus


piece_via_has_focus_ = _piece_via_has_focus(' 👉 ')  # leading space matters
# piece_via_has_focus_ = _piece_via_has_focus('> ')


def label_via_key_(key):
    s = key.replace('_', ' ')
    return ''.join((s[0].upper(), s[1:]))  # not title()


def calm_name_via_key_(k):  # ..
    return k.replace('_', ' ')


# ==

class StateMachineBasedInteractableComponent_:
    """
    On construction, every participating instance starts as not focused
    It assumes a simple two-state state machine. clients can override
    or judiciously move their states appropriately
    """

    def become_focused(self):
        assert self._has_focus is False
        self._state.move_to_state_via_transition_name('cursor_enter')
        self._has_focus = True

    def become_not_focused(self):
        assert self._has_focus is True
        self._state.move_to_state_via_transition_name('cursor_exit')
        self._has_focus = False

    def RECEIVE_BUTTONPRESS(self, t):
        self._state.move_to_state_via_transition_name(t.condition_name)
        afn = t.action_function_name
        if afn is None:
            return _do_nothing  # if you lost/gain focus, covered?
        return getattr(self, afn)()  # args?

    @property
    def FFSA_AND_STATE_NAME_ONCE_HAS_FOCUS_(self):
        state = self._state
        return state.FFSA, state.state_name_via_transition_name('cursor_enter')

    _has_focus = False

    is_focusable = True


# ==

class MultiPurposeResponse_:

    def __init__(self, emissions=None, changes=None, changed_visually=None):
        self.emissions = emissions
        self.changes = changes
        self.changed_visually = changed_visually

    def MERGE_RESPONSES_EXPERIMENT_(responses):
        leng = len(responses)
        assert leng
        if 1 == leng:
            return responses[0]
        kw = {}
        for resp in responses:
            for attr in _response_fields:
                items = getattr(resp, attr)
                if not items:
                    continue
                if (arr := kw.get(attr)) is None:
                    kw[attr] = (arr := [])
                for item in items:
                    arr.append(item)

        # Each final attributes should be None or non-zero-length tuple
        for k, v in kw.items():
            kw[k] = tuple(v)
        return MultiPurposeResponse_(**kw)

    @property
    def summary(self):  # dev
        return ''.join(('(', *self._summary_pieces(), ')'))

    def _summary_pieces(self):
        chars = 'E', 'C', 'V'
        attrs = 'emissions', 'changes', 'changed_visually'
        for i in range(0, 3):
            if (x := getattr(self, attrs[i])) is None:
                continue
            yield chars[i] * len(x)

    @property
    def do_nothing(self):
        return self.changes is None and self.emissions is None


_do_nothing = MultiPurposeResponse_()
_response_fields = 'emissions', 'changes', 'changed_visually'


class Emission_:
    # For now a pared down version of the familiar thing, rewritten

    def __init__(self, tup):
        self.severity, shape, self.category, self.to_messages = tup
        assert 'expression' == shape

    def to_channel_tail(self):
        return (self.category,)


class WriteOnceMutableStruct_:
    # Experiment: dictionaries are the most powerful data structure but they
    # offer a freedom that becomes a liability for your use case. Make them
    # more strict and less fun by standing this client between you and the
    # dictionary, to manage writes to it
    #
    #   - You can't set a key outside of the defined set (provided at const.)
    #   - You can't write to any key more than once (experimental^2)
    #   - Assert that you didn't forget to write to any keys with `done()`

    def __init__(self, dct):
        self._pool = {k: None for k in dct.keys() if dct[k] is None}
        self._values = dct

    def __setitem__(self, k, v):
        self._pool.pop(k)
        self._values[k] = v

    def done(self):
        if 0 == len(self._pool):
            del self._pool
            return
        reason = ''.join(('oops: ', repr(tuple(self._pool.keys()))))
        raise RuntimeError(reason)


class MutableStruct_:  # see above

    def __init__(self, dct):
        self._values = dct

    def __setitem__(self, k, v):
        self._values[k]  # validate name
        self._values[k] = v


class MyException_(RuntimeError):
    pass

# #history-B.4 moved a lot of little things in
# #born tiny
