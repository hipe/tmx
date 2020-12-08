"""
(about four days into this project it occured to us that maybe it's possibly
more than just a tiny windowing toolkit for curses (maybe we would want to
use it in a tiny REPL that doesn't need ncurses, maybe we could use it as
an "interface description language" to generate interfaces in arbitrary
other modalities..) so we thought it would be prudent to keep *all*
interactions with curses proper in its own abstraction layer. As it works out
this is also all the stuff that doesn't get covered 🙃)
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
    ic = cca.to_EXPERIMENTAL_input_controller__()
    flash = cca['flash_area']  # #[#608.2.C] for now required, magic name

    # Use this dict as a mutable struct, throughout the whole lifetime
    all_ks = tuple(cca.to_component_keys())  # #here1
    redraw_me = {k: True for k in all_ks}  # draw all components the 1st time
    unexpressed_emissions = []

    def flush_any_emissions_into_flash(do_redraw):
        if 0 == len(unexpressed_emissions):
            return False
        tup = tuple(unexpressed_emissions)
        unexpressed_emissions.clear()
        flash.receive_emissions(tup)
        if do_redraw:
            # (in case you want to force the redraw early, like before modals..
            redraw_component('flash_area')
        return True

    def redraw_component(k):
        harness = cca.HARNESS_AT(k)
        _redraw_harness(harness, stdscr)

    def flag_for_next_redraw(k):
        redraw_me[k]  # validate name
        redraw_me[k] = True

    # (the remaining logic started as pseudocode in input_controller_)

    stay_running = True
    while stay_running:

        # Flush unflushed emissions into flash (before redraw (before block))
        if flush_any_emissions_into_flash(do_redraw=False):
            flag_for_next_redraw('flash_area')  # for OCD do them in order

        # Redraw each component that needs it (before block)
        for k in (k for k, yn in redraw_me.items() if yn):
            redraw_me[k] = False  # writing to the dict you're traversing yikes
            redraw_component(k)

        # Block waiting for input, then let input controller process it
        keycode = stdscr.getkey()
        resp = ic.receive_keypress(keycode)

        # A response can have changes and applying changes creates another
        # response that can have more changes and so on (experimentally).
        # This happens non-interactively (we don't block for user input in
        # the middle of a changes chain (unless host directive does..)).

        while stay_running:
            # Add emissions to queue (before quit from host directives)
            if (emis := resp.emissions):
                for emi in emis:
                    unexpressed_emissions.append(emi)

            # Add component names that changed visually to pending thing
            # (input responses should not have these but change responses shou)
            if (keys := resp.changed_visually):
                for k in keys:
                    flag_for_next_redraw(k)

            # If no changes, repeat main loop to flush emissions and block
            changes = resp.changes
            if not changes:  # allow maybe empty list, because merged
                break  # break out of the loop that processes responses

            # We have changes to apply.

            # For now, let's not intermix host directives and others in the
            # same response (push this to the class #todo), because otherwise
            # several cans of worms are opened up..

            if 'host_directive' == changes[0][0]:
                assert all('host_directive' == change[0] for change in changes)
                stay_running, resp = _process_host_directives(
                    changes, cca, stdscr, curses)
            else:
                resp = ic.apply_changes(changes)
                _assert_looks_like_response(resp)

            # loop around to process this response now
    return {
        'unexpressed_emissions': tuple(unexpressed_emissions),
    }


def _process_host_directives(host_directives, cca, stdscr, curses):

    resps = []
    for typ, direc, *args in host_directives:
        assert 'host_directive' == typ

        if 'enter_text_field_modal' == direc:
            resps.append(_EMACS_THING_EXPERIMENT(cca, *args, stdscr, curses))
            continue

        if 'quit' == direc:
            return False, None  # stop immediately

        raise RuntimeError(f"host directive? {direc!r}")

    return True, resps[0].__class__.MERGE_RESPONSES_EXPERIMENT_(resps)


def _EMACS_THING_EXPERIMENT(cca, k, stdscr, curses):
    from curses.textpad import Textbox, rectangle

    harness = cca.HARNESS_AT(k)
    comp = harness.concrete_area

    span_x, span_w = comp.value_span_x_and_width_for_modal_
    harn_y = harness.harness_y__
    harn_x = harness.harness_x__

    screen_y = harn_y
    screen_x = harn_x + span_x

    # Write our message to the flash
    fa_harness = cca.HARNESS_AT('flash_area')  # magic name #[#608.2.C]
    fa = fa_harness.concrete_area
    fa.receive_message("Enter text. Ctrl-G submits, Ctrl-C cancels Ctrl-H backspaces")  # noqa: E501
    _redraw_harness(fa_harness, stdscr)

    # Create the window that the textbox will be constrained by
    span_h = 1
    editwin = curses.newwin(span_h, span_w, screen_y, screen_x)

    # Will draw the bounding rectangle around the thing #here2
    # (goofing round, needs work)
    rectangle(stdscr, screen_y-1, screen_x-1, screen_y+1, screen_x+span_w)
    stdscr.refresh()  # show our flash message and the rectangle

    # Enter the edit mode of the textbox until user submits or cancels
    box = Textbox(editwin)
    message = _message_or_none_via_textbox(box)
    fa.clear_flash_area()  # ..
    _redraw_harness(fa_harness, stdscr)  # 😢

    comp_resp = comp.receive_new_value_from_modal_(message)

    # If there's an above component and a below component, needs redraw #here2
    keys = tuple(_any_above_and_self_and_any_below(cca, k))
    resp_via = comp_resp.__class__
    my_resp = resp_via(changed_visually=keys)
    return resp_via.MERGE_RESPONSES_EXPERIMENT_((comp_resp, my_resp))


def _message_or_none_via_textbox(box):

    # Let the user edit until Ctrl-G is struck.
    try:
        box.edit()
    except KeyboardInterrupt:
        return

    # Get resulting contents
    return box.gather()


def _any_above_and_self_and_any_below(cca, k):
    # (we make an index like this in the focus controller too, #watch)
    all_ks = tuple(cca.to_component_keys())  # redund #here1
    offset = all_ks.index(k)
    if 0 != offset:
        yield all_ks[offset - 1]
    yield k
    if offset != (len(all_ks) - 1):
        yield all_ks[offset + 1]


def _redraw_harness(harness, stdscr):
    for y, x, row in harness.TO_SCREEN_ROWS():
        stdscr.addstr(y, x, row)


def _assert_looks_like_response(resp):
    assert resp
    resp.changes  # assert interface #[#022]


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #born
