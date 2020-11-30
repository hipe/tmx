"""
The objectives of this visual test (tentative):

- Now that we can have several interactables on the screen, show how key-up
  and key-down can select among them
- Exercise every state of a checkbox. Yesterday we learned there are two
  separate machines: Whether it's checked or not exists independently of
  whether it's selected or not. If we needed to we could try to rework the
  FFSA but we have to wait and see how this feels in practice
- See that checkboxes line up but only within runs
- See that text fields line up but only within runs
- See the dynamic section of hotkeys changing
- See that navigating into and out of the nav area clears and uclears the dyn
- Don't worry about static buttons yet. stick with hard-coded 'q'
- Get the 'form results' back out from the interface
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
    yield 'nav_area', ('eenie_meenie', 'miney_mo', 'lets_go')
    yield 'text_field', 'field_1'
    yield 'checkbox', 'checkbox_1', 'label', 'ohai cb 1'
    yield 'text_field', 'field_2', 'label', 'text field custom label for 2'
    yield 'checkbox', 'checkbox_2', 'label', 'yes yes yall cb 3'
    yield 'horizontal_rule'
    yield 'text_field', 'field_3'
    yield 'checkbox', 'checkbox_3', 'label', 'zip zap'
    yield 'vertical_filler'
    yield 'flash_area'
    yield 'buttons', buttons_def()


def buttons_def():
    yield 'static_buttons_area', static_buttons_def


def static_buttons_def():
    yield 'my [a]pple', 'your [b]anana'
    yield ('[q]uit',)


def imagine_stylesheet():
    """
    If you set the max width or height to a value that's too low for your
    content, you should get the same exception as when the screen is sized
    too small.
    """

    yield 'maxium_height', 28
    yield 'maxium_width', 56
    yield 'horizontal_filler_function', imagine_horizontal_filler_function


def imagine_horizontal_filler_function(available_w, content_w):
    """
    Assume the containing width (a.k.a the "available width") is wider than
    the content width.

    Return an integer between zero and (available - content)
    that tells the renderer where to place the interface horizontally

    - If you want align-left, return 0
    - If you want align right, return (available - content)
    - To get align center you have to do the math/logic yourself to decide
      which way to go on an odd amount of "under by"

    You can do weird adaptive things like keep it at some fixed margin from
    the left up to some width, then click-in to some kind of centering thing

    You can attempt to make it always occupy a fixed percentage of the
    available width, at some fixed percentage placement
    """
    raise RuntimeError('imagine')


# #born
