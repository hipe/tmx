import _common_state  # noqa: F401
from modality_agnostic.memoization import dangerous_memoize as shared_subject
import unittest


class _CommonCase(unittest.TestCase):

    def fail_with_message(self, msg):
        def recv_messager(msgr):
            actual_line, = list(msgr())  # assert only one line implicitly
            self.assertEqual(msg, actual_line)
        self.run_expecting_input_error_expression(recv_messager)

    def some_line_number_and_line(self):
        o = self.emitted_elements()
        self.assertIsNotNone(o['lineno'])
        self.assertIsNotNone(o['line'])

    def run_expecting_input_error_expression(self, receive_messager):

        self._run_expecting_input_error('expression', receive_messager)

    def run_expecting_structured_input_error(self):

        def recv_payloader(payloader):
            nonlocal freeform_metadata
            freeform_metadata = payloader()
        freeform_metadata = None

        self._run_expecting_input_error('structure', recv_payloader)
        return freeform_metadata

    def _run_expecting_input_error(self, shape, receive_payloader):

        def listener(*args):
            nonlocal count
            count += 1
            if 1 < count:
                raise Exception('more than one emission')
            *chan, payloader = args
            self.assertEqual(chan, ['error', shape, 'input_error'])
            receive_payloader(payloader)

        count = 0
        _x = self._run_via_listener(listener)
        self.assertIsNone(_x)
        self.assertEqual(count, 1)

    def _run_via_listener(self, listener):
        _all_lines = self.given_lines()
        _x = _subject_module()._coarse_items_via_all_lines(_all_lines, listener)  # noqa: E501
        return _x

    def given_lines(self):
        raise Exception('ha ha')


class Case100_truly_blank_file(_CommonCase):

    def test_100_fails_with_this_message(self):
        self.fail_with_message('no lines in input')

    def given_lines(self):
        return ()


class Case120_blank_ish_file(_CommonCase):

    def test_100_fails_with_this_message(self):
        self.fail_with_message('file has no sections (so no entities)')

    def given_lines(self):
        return ('# comment line\n', '# comment line 2\n')


class Case130_whatever_this_is(_CommonCase):

    def test_100_fails_with_this_message(self):

        _expecting = (
            'expecting blank line, '
            'comment line '
            'or section line '
            "at line 3: 'Huh ZAH!\\n'"
        )
        self.fail_with_message(_expecting)

    def given_lines(self):
        return ('# comment line\n', '\n', 'Huh ZAH!\n')


class Case210_not_quite_section_line(_CommonCase):

    def test_100_fails_with_input_error(self):
        self._end_state()

    def test_200_says_expecting(self):
        first_line = self._end_state()[0]
        expected = 'expected close brace and end of line'
        self.assertEqual(first_line, expected)

    def test_300_gives_context__exact_position(self):
        last_lines = self._end_state()[1:]
        _1 = "    '[fun time…'"
        _2 = "     ----^"
        self.assertEqual(last_lines, [_1, _2])

    @shared_subject
    def _end_state(self):
        def recv_msgr(msgr):
            nonlocal lines
            lines = list(msgr())
        lines = None
        self.run_expecting_input_error_expression(recv_msgr)
        return lines

    def given_lines(self):
        return ('# comment line\n', '\n', '[fun time]\n')


class Case220_section_but_no_dots(_CommonCase):

    def test_100_our_first_structured_emisson(self):
        o = self.emitted_elements()
        self.assertEqual(o['expecting'], 'keyword "item"')

    def test_200_points_right_at_the_first_letter(self):
        o = self.emitted_elements()
        self.assertEqual(o['position'], 1)

    def test_300_correct_line_number_and_line(self):
        o = self.emitted_elements()
        self.assertEqual(o['lineno'], 1)
        self.assertEqual(o['line'], '[woot]\n')

    @shared_subject
    def emitted_elements(self):
        return self.run_expecting_structured_input_error()

    def given_lines(self):
        return ('[woot]\n',)


class Case240_wrong_keyword_for_third_component(_CommonCase):

    def test_100_expecting(self):
        o = self.emitted_elements()
        self.assertEqual(o['expecting'], 'keyword "attributes" or "meta"')

    def test_200_points_right_at_the_first_letter_of_the_keyword(self):
        o = self.emitted_elements()
        pos = o['position']
        self.assertEqual(pos, 11)
        self.assertEqual(o['line'][pos:pos+4], 'attr')

    def test_300_some_line_number_and_line(self):
        self.some_line_number_and_line()

    @shared_subject
    def emitted_elements(self):
        return self.run_expecting_structured_input_error()

    def given_lines(self):
        return ('[item.0O1L.attribute]\n',)


class Case250_too_many_components(_CommonCase):

    def test_100_structured_emission(self):
        o = self.emitted_elements()
        self.assertEqual(o['expecting'], "']'")

    def test_200_points_right_at_the_exta_dot(self):
        o = self.emitted_elements()
        pos = o['position']
        self.assertEqual(pos, 21)
        self.assertEqual(o['line'][pos], '.')

    def test_300_some_line_number_and_line(self):
        self.some_line_number_and_line()

    @shared_subject
    def emitted_elements(self):
        return self.run_expecting_structured_input_error()

    def given_lines(self):
        return ('[item.0O1L.attributes.huzzah]\n',)


def _subject_module():
    from kiss_rdb.magnetics_ import items_via_toml_file as _
    return _


def cover_me(msg):
    raise Exception(f'cover me: {msg}')


if __name__ == '__main__':
    unittest.main()

# #born.
