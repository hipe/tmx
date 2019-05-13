import _common_state  # noqa: E401
from kiss_rdb_test import structured_emission as se_lib
import unittest


from modality_agnostic.memoization import (  # noqa: E402
        dangerous_memoize as shared_subject,
        )


_CommonCase = unittest.TestCase


class Case100_works(_CommonCase):

    def test_100_loads(self):
        self.assertIsNotNone(_subject_function())

    def test_200_works(self):
        _these = {'fn': 'Xx', 'ln': 'Yy'}
        _lines = _subject_function()(
                _these, "hello $fn $ln\n", lambda x: x, None)
        a = []
        for line in _lines:
            a.append(line)

        self.assertEqual(a, ["hello Xx Yy\n"])


class Case200_fails(_CommonCase):

    def test_100_channel(self):
        chan = self._channel_and_lines()[0]
        self.assertEqual(
                chan, ('error', 'expression', 'missing_required_doohahs'))

    def test_200_message(self):
        lines = self._channel_and_lines()[1]
        line, = lines  # assert exactly one
        self.assertEqual(
                line, 'set these environment variables: (Qfn, Qln)')

    @shared_subject
    def _channel_and_lines(self):

        def run(listener):
            return _subject_function()(
                    data_source={'no': 'see'},
                    template_big_string="hello $fn $ln\n",
                    data_source_key_via_template_variable_name=lambda x: f'Q{x}',  # noqa: E501
                    listener=listener)

        chan, payloader = se_lib.one_and_none(run, self)
        _lines = payloader()
        return (chan, _lines)


def _subject_function():
    import script.lines_via_template as _
    return _._lines_via


if __name__ == '__main__':
    unittest.main()

# #born.
