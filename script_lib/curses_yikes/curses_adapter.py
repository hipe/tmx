"""
(about four days into this project it occured to us that maybe it's possibly
more than just a tiny windowing toolkit for curses...)

"""


def run_compound_area_via_definition(defn):

    from script_lib.curses_yikes.compound_area_via_children import \
        abstract_compound_area_via_children_ as func

    abstract_area = func(defn)

    from . import build_this_crazy_context_manager_ as func

    with func() as o:
        return _our_first_ever_input_loop(abstract_area, o.stdscr, o.curses)


def _our_first_ever_input_loop(aca, stdscr, curses):

    # Determine terminal screen height & width and use this
    # (AS-IS for now (almost)) to determine available width & height
    h, w = curses.LINES, curses.COLS
    w -= 1  # this seems universally necessary but wasn't explained anywhere

    # Concretize the abstract area (throws when can't meet constraints)
    cca = aca.concretize_via_available_height_and_width(h, w)

    # Get ready to write and read
    ic = cca.to_EXPERIMENTAL_input_controller()
    flash = cca.CHILD_CONCRETE_AREA('flash_area')  # for now .. required ..
    redraw_me = {k: None for k in cca.to_children_keys()}

    # (the remaining is based directly on pseudocode in _input_controller)

    while True:

        # Redraw children that need to be drawn
        ks = tuple(redraw_me.keys())
        redraw_me.clear()  # paranoia of forgetting
        for k in ks:
            for y, x, row in cca.CHILD_HARNESS(k).TO_SCREEN_ROWS():
                stdscr.addstr(y, x, row)

        # Block waiting for input
        keycode = stdscr.getkey()

        # If quit was requested, HOW
        if 'q' == keycode:
            break

        resp = ic.receive_keypress(keycode)

        # Express these emissions to the flash area (next time around the loop)
        if (emis := resp.emissions):
            redraw_me['flash_area'] = None
            flash.receive_emissions(emis)

        # Apply state changes (order shouldn't matter w/ above. no flash here)
        if (changes := resp.changes):
            ic.apply_changes(changes, redraw_me)

    wat = 'hardcoded nothing'
    return {'wat': wat}


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #born
