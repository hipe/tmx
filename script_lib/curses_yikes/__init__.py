def _build_this_crazy_context_manager():  # #testpoint
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


class MyException_(RuntimeError):
    pass

# #born tiny
