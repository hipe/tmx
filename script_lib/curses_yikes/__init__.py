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
    def do_nothing(self):
        return self.changes is None and self.emissions is None


_response_fields = 'emissions', 'changes', 'changed_visually'


class Emission_:
    # For now a pared down version of the familiar thing, rewritten

    def __init__(self, tup):
        self.severity, shape, self.category, self.to_messages = tup
        assert 'expression' == shape

    def to_channel_tail(self):
        return (self.category,)


class MyException_(RuntimeError):
    pass

# #born tiny
