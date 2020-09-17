import modality_agnostic.test_support.common as em
from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject
import unittest



class CommonCase(unittest.TestCase):
    do_debug = False


class Case1293_works(CommonCase):

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


class Case1299_fails(CommonCase):

    def test_100_channel(self):
        chan = self.channel_and_lines[0]
        self.assertEqual(
                chan, ('error', 'expression', 'missing_required_doohahs'))

    def test_200_message(self):
        lines = self.channel_and_lines[1]
        line, = lines  # assert exactly one
        self.assertEqual(
                line, 'set these environment variables: (Qfn, Qln)')

    @shared_subject
    def channel_and_lines(self):

        def run(listener):
            return _subject_function()(
                    data_source={'no': 'see'},
                    template_big_string="hello $fn $ln\n",
                    data_source_key_via_template_variable_name=lambda x: f'Q{x}',  # noqa: E501
                    listener=listener)

        listener, emissions = em.listener_and_emissions_for(self, limit=1)
        self.assertIsNone(run(listener))
        emi, = emissions
        return emi.channel, tuple(emi.payloader())


def _subject_function():
    from kiss_rdb.magnetics_ import lines_via_template as _
    return _._lines_via


if __name__ == '__main__':
    unittest.main()

# #born.
