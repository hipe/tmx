# from modality_agnostic.test_support.common import lazy
# dangerous_memoize_in_child_classes as shared_subject_in_children, \
import unittest
import re


class CommonCase(unittest.TestCase):

    def go(self):
        h, w = self.given_height(), self.given_width()
        aca = ACA_via(ACA_def_one())
        cca = concretize(h, w, aca)

        emis = self.given_emissions()
        if emis:
            cfa = cca['flash_area']
            from script_lib.curses_yikes import Emission_ as emi_via
            emis = (emi_via(tup) for tup in emis)
            cfa.receive_emissions(emis)

        act = tuple(cca.to_rows())
        act = tuple(content_only(s, w) for s in act)
        exp = tuple(self.expected_row_contents())
        self.assertSequenceEqual(act, exp)

    def given_height(_):
        return 2

    def given_width(_):
        return 38


class Case7720_from_initial_state(CommonCase):

    def test_100_renders_blank_lines(self):
        self.go()

    def expected_row_contents(_):
        yield ''
        yield ''

    def given_emissions(_):
        return None


class Case7722_renders_a_short_message(CommonCase):

    def test_100_works(self):
        self.go()

    def expected_row_contents(_):
        yield ''
        yield 'Ohai mami: hallo hi there'

    def given_emissions(_):
        yield 'info', 'expression', 'ohai_mami', lambda: ('hallo hi there',)


class Case7724_multiple_messages(CommonCase):

    def test_100_word_wraps_and_munges(self):
        self.go()

    def expected_row_contents(_):
        yield 'Hullo 1: Hello I am line one. Hello I'
        yield 'am line two. Good job: Hello I am l[…]'

    def given_emissions(_):
        def lines():
            yield "Hello I am line one"
            yield "Hello I am line two"
        yield 'info', 'expression', 'hullo_1', lines

        def lines():
            yield "Hello I am line three, a brother from a different mother"
        yield 'info', 'expression', 'good_job', lines


class Case7726_if_varying_levels_of_severity(CommonCase):

    def test_100_groups_by_severity_and_only_shows_most_severe(self):
        self.go()

    def expected_row_contents(_):
        # also note messages are enhanced because serious
        yield 'Error: invalid value: Oh noes this bad'
        yield 'thing happened! Error: chip chewey:[…]'

    def given_emissions(_):
        def lines():
            yield "Hello I'm just a chill friendly info."
        yield 'info', 'expression', 'no_see', lines

        def lines():
            yield "Oh noes this bad thing happened"
        yield 'error', 'expression', 'invalid_value', lines

        def lines():
            yield "Hello I'm just a chill friendly info."
        yield 'verbose', 'expression', 'no_see', lines

        def lines():
            yield "Oh noes this other bad thing happened"
        yield 'error', 'expression', 'chip_chewey', lines


def content_only(row, w):
    assert w == len(row)
    return rx.match(row)[1]


# unlike strip(), leave the leading blank spaces (IFF there's content)
rx = re.compile(r'([ ]*[^ ](?:.*[^ ])?|)[ ]*\Z')


def ACA_def_one():
    yield 'flash_area', 'starting_height', 2


def concretize(h, w, aa, listener=None):
    return support_lib().concretize(h, w, aa, listener)


def ACA_via(x):
    func = support_lib().function_for_building_abstract_compound_areas()
    return func(x)


def support_lib():
    from script_lib_test import curses_yikes_support as module
    return module


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))


if __name__ == '__main__':
    unittest.main()

# #born
