"""The objectives of this visual test (tentative):

(EDIT: we are leaving this here as-is to get it in to history because
we wrote it before we began working on the compound component. Eventually
we will probably "correct" it so it reflects the current target featureset,
but (as only details have changed) we think it's interesting to compare/cont.)

- Moving the focus up and down at the outermost level feels like normal,
  but note if there are items in the list, it hops over the whole list
  as a unit, it doesn't give focus to each individual item
- Add an item
- Delete an item
- Edit (the text of) an already-existing item (DEFERRED)
- An item left blank gets automatically deleted
- Editing an existing item and leaving it blank is soft-rejected
- Uniqueness is not guaranteed among items
- Leading/trailing blanks get stripped quietly
- Move an existing item up and down (except when etc). Implementing this
  correctly will be a lot of work for a lot of little reasons

(eventually)
- Insert above any existing item (except when out of space)
- Insert below any existing item (except when out of space)
"""

from script_lib_test import curses_yikes_support as support


def CLI_(sin, sout, serr, argv, fxser):

    res = support.run_compound_area_via_definition(define_compound_area())
    emis = res.pop('unexpressed_emissions')

    if emis:
        for emi in emis:
            for msg in emi.to_messages():
                serr.write(msg)
                serr.write('\n')

    serr.write("(returned from curses subsystem, vtest 030)\n")

    if res:
        serr.write(f"oh? what's this? (vtest 030) {res!r}")

    return 0


def define_compound_area():
    yield 'nav_area', ('enjoy_your', 'orderable_list')
    yield 'orderable_list', 'chim_churry', 'item_class', 'anonymous_text_field'
    yield 'flash_area'
    yield 'buttons', buttons_def()


def buttons_def():
    yield 'static_buttons_area', static_buttons_def


def static_buttons_def():
    yield ('[q]uit',)  # implementation for 'q' key is hard-coded

# #born
