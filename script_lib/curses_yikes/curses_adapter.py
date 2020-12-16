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
    offsets_of_non_host_directives = []
    host_direc = None

    def flush_any_emissions_into_flash(do_redraw):
        if 0 == len(unexpressed_emissions):
            return False
        tup = tuple(unexpressed_emissions)
        # unexpressed_emissions.clear()  SO BAD not until #here3
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

    while True:

        # Flush unflushed emissions into flash (before redraw (before block))
        if flush_any_emissions_into_flash(do_redraw=False):
            flag_for_next_redraw('flash_area')  # for OCD do them in order

        # Redraw each component that needs it (before block)
        for k in (k for k, yn in redraw_me.items() if yn):
            redraw_me[k] = False  # writing to the dict you're traversing yikes
            redraw_component(k)

        if host_direc:
            stay_running, resp = _process_host_directives(
                    (host_direc,), cca, stdscr, curses)
            host_direc = None
            if not stay_running:
                assert not resp
                break
        else:
            # Block waiting for input, then let input controller process it
            keycode = stdscr.getkey()
            resp = ic.receive_keypress(keycode)

        # SO BAD wait until after we would have quit to clear it #here3
        unexpressed_emissions.clear()

        # A response can have changes and applying changes creates another
        # response that can have more changes and so on (experimentally).
        # This happens non-interactively (we don't block for user input in
        # the middle of a changes chain (unless host directive does..)).

        while True:
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
            # For now, host directives have stipulations that don't apply to
            # directives addressed to other recipients. At writing there are
            # no host directives that do not either: 1) break out of the whole
            # input loop (like "quit") or 2) block for user input (like
            # "emacs field"). For such directives, it never makes sense to have
            # any directives after them (right?). #open [#607.H] if we stick
            # with this, push this as an assertion up into the response class

            leng = len(changes)
            assert leng  # because checked above. but actually none may be ok
            host_directive_offset = None

            for i in range(0, leng):
                if 'host_directive' == changes[i][0]:
                    if host_directive_offset is None:
                        host_directive_offset = i
                        host_direc = changes[i]
                    else:
                        xx("do you really want multip. host directives in 1..")
                else:
                    offsets_of_non_host_directives.append(i)

            # First, assert that the host directive is placed correctly
            has_hd = host_directive_offset is not None
            has_otr = len(offsets_of_non_host_directives)
            if has_hd and has_otr:
                if host_directive_offset != leng - 1:
                    xx('host directives must be at the end')

            # Then, apply the changes that aren't host directives
            if has_otr:
                if has_hd:
                    changes = tuple(changes[i] for i in offsets_of_non_host_directives)  # noqa: E501
                offsets_of_non_host_directives.clear()
                resp = ic.apply_changes(changes)
                _assert_looks_like_response(resp)
            else:
                resp = _the_empty_response

            # loop around to process this response now
    return {
        'unexpressed_emissions': tuple(unexpressed_emissions),
    }


class _the_empty_response:  # #class-as-namespace
    emissions = None
    changed_visually = None
    changes = None


def _process_host_directives(host_directives, cca, stdscr, curses):

    resps = []
    for typ, direc, *args in host_directives:
        assert 'host_directive' == typ

        if 'enter_emacs_modal' == direc:
            resps.append(_EMACS_THING_EXPERIMENT(cca, stdscr, curses, *args))
            continue

        if 'quit' == direc:
            return False, None  # stop immediately

        raise RuntimeError(f"host directive? {direc!r}")

    return True, resps[0].__class__.MERGE_RESPONSES_EXPERIMENT_(resps)


def _EMACS_THING_EXPERIMENT(cca, stdscr, curses, comp_path, h, w, y, x, *user):
    # (at #history-B.4 we rearranged lyfe so components indicate screen coords)

    from curses.textpad import Textbox, rectangle

    k, child_k = comp_path  # ick/meh
    harness = cca.HARNESS_AT(k)
    comp = harness.concrete_area

    # Write our message to the flash
    fa_harness = cca.HARNESS_AT('flash_area')  # magic name #[#608.2.C]
    fa = fa_harness.concrete_area
    fa.receive_message("Enter text. Ctrl-G submits, Ctrl-C cancels Ctrl-H backspaces")  # noqa: E501
    _redraw_harness(fa_harness, stdscr)

    # Create the window that the textbox will be constrained by
    editwin = curses.newwin(h, w, y, x)

    # Will draw the bounding rectangle around the thing #here2
    # (goofing around, needs work)
    rectangle(stdscr, y-1, x-1, y+h, x+w)
    stdscr.refresh()  # show our flash message and the rectangle

    # Enter the edit mode of the textbox until user submits or cancels
    box = Textbox(editwin)
    text = _text_or_none_via_textbox(box)
    fa.clear_flash_area()  # ..
    _redraw_harness(fa_harness, stdscr)  # 😢

    comp_resp = comp.receive_new_value_from_modal_(child_k, text, *user)

    # If there's an above component and a below component, needs redraw #here2
    keys = tuple(_any_above_and_self_and_any_below(cca, k))
    resp_via = comp_resp.__class__
    my_resp = resp_via(changed_visually=keys)
    return resp_via.MERGE_RESPONSES_EXPERIMENT_((comp_resp, my_resp))


def _text_or_none_via_textbox(box):

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

# #history-B.4
# #born
