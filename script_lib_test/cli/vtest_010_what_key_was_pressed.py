from script_lib_test import curses_yikes_support as support


def CLI_(sin, sout, serr, argv, fxser):

    with support.open_curses_session() as o:
        _main(o.stdscr, o.curses)

    serr.write("Good job, I'm back out her in test 010\n")
    return 0


def _main(stdscr, curses):
    # Hotkeys:
    # [X] FIRST: render any one line of text anywhere
    # [X] then: figure out what the width of the screen is
    # [X] then: give yourself a fixed, hardcoded width of this width to work w
    # [X] then: write your own word-wrap again from scratch, just do it coward
    # [X] then: figure out how to read keypresses
    # [X] then: use what you learned in a previous lesson to write a flash msg
    # [X] then: report what key was hit
    # [X] then: exit when a good key is hit

    def normalize_row(msg):
        assert '\n' not in msg
        leng = len(msg)
        extra = w - leng
        if 0 == extra:
            return msg
        if 0 < extra:
            return ''.join((msg, ' ' * extra))
        return msg[0: w]

    w = 70  # ROWS, LINES

    flash_message = None
    stdscr.addstr(1, 1, "Enter any key ('q' to quit):")

    from datetime import datetime
    datetime_now = datetime.now

    while True:
        if flash_message:
            stdscr.addstr(0, 1, normalize_row(flash_message))
        else:
            stdscr.addstr(0, 1, normalize_row(''))
        s = stdscr.getkey()
        if 'q' == s:
            break
        when = datetime_now().strftime('%H:%M:%S')
        flash_message = f"Key pressed was {s!r} at {when}"

# #born
