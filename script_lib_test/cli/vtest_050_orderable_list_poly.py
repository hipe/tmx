"""The objectives of this visual test (tentative):

- Just like the "mono-" variant, but focus on the poly
- At first, you'll be "locked in" to a rigid flow
- Maybe one day, cancel, edit existing, scroll horizontal
- Don't forget: move, delete, add after label after first add
- Leave name blank. Leave value blank.
- Leading spaces, trailing spaces
"""

from script_lib_test import curses_yikes_support as support


def CLI_(sin, sout, serr, argv, fxser):

    # == BEGIN copy-paste (slight modify)
    res = support.run_compound_area_via_definition(define_compound_area())
    emis = res.pop('unexpressed_emissions')

    if emis:
        for emi in emis:
            for msg in emi.to_messages():
                serr.write(msg)
                serr.write('\n')

    serr.write("(returned from curses subsystem, vtest 050)\n")

    if res:
        serr.write(f"oh? what's this? (vtest 050) {res!r}")

    return 0
    # == END


def define_compound_area():
    yield 'nav_area', ('enjoy_your', 'poly', 'options')
    yield 'orderable_list', 'chim_churry', 'item_class', 'poly_option'
    yield 'flash_area'
    yield 'buttons', buttons_def()


def buttons_def():
    yield 'static_buttons_area', static_buttons_def


def static_buttons_def():
    yield ('[q]uit',)  # implementation for 'q' key is hard-coded

# #born
