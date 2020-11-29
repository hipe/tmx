from script_lib_test import curses_yikes_support as support


def CLI_(sin, sout, serr, argv, fxser):

    res = support.run_compound_area_via_definition(define_compound_area())
    serr.write(f"Good job, back out here in test 020 with result: {res!r}\n")
    return 0


def define_compound_area():
    yield 'nav_area', ('are you ready', 'to party')
    yield 'vertical_filler'
    yield 'flash_area'
    yield 'buttons', buttons_def()


def buttons_def():
    yield 'static_buttons_area', static_buttons_def


def static_buttons_def():
    yield 'my [a]pple', 'your [b]anana'
    yield ('[q]uit',)

# #born
