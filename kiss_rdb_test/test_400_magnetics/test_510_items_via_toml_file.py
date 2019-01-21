import _common_state  # noqa: F401
import unittest


class _CommonCase(unittest.TestCase):

    def fail_with_message(self, msg):

        def listener(*args):
            nonlocal count
            count += 1
            if 1 < count:
                raise Exception('no')

            *chan, msgr = args
            self.assertEqual(chan, ['error', 'expression', 'input_error'])
            _lines = list(msgr())
            actual_line, = _lines  # assert only one line, implicitly
            self.assertEqual(msg, actual_line)

        count = 0

        _all_lines = self.given_lines()
        _x = _subject_module()._coarse_items_via_all_lines(_all_lines, listener)  # noqa: E501
        self.assertIsNone(_x)
        self.assertEqual(count, 1)

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


def _subject_module():
    from kiss_rdb.magnetics_ import items_via_toml_file as _
    return _


if __name__ == '__main__':
    unittest.main()

# #born.
