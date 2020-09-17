"""this test file corresponds to an isomporphically named asset file..

..that explains everything.
"""

from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject, lazy
import unittest


class _TestCase(unittest.TestCase):

    def expect_exception_message(self, msg):
        _msg = self.exception_tuple[0]
        self.assertEqual(_msg, msg)

    def raises_expected_exception(self):
        self.assertIsNotNone(self.exception_tuple)


def exception_tuple(f):  # (abstraction candidate)

    def g(self):
        from upload_bot.run import Exception as _MyException
        try:
            f(self)
        except _MyException as e_:
            e = e_
        if e is not None:
            return (str(e),)

    return shared_subject(g)


class Case100_Hi(_TestCase):

    def test_010_magentic(self):
        self.assertIsNotNone(_subject_magnetic())


class Case200_X_missing(_TestCase):

    def test_010_raises_expected_exception(self):
        self.raises_expected_exception()

    def test_020_expect_this_message(self):
        _exp = 'missing required doo-hahs: ({})'.format(
                ', '.join([
                    'thing_A',
                    'thing_B',
                    ]))
        self.expect_exception_message(_exp)

    @exception_tuple
    def exception_tuple(self):
        _d = {
                'one_thing': 'x',
                'another_thing': 'y',
                }
        _subject_magnetic()(_d)


class Case300_X_fail_format(_TestCase):

    def test_010_raises_expected_exception(self):
        self.raises_expected_exception()

    def test_020_expect_this_message(self):
        exp = (
                "'thing_A' must match ^A{4}$ (had: 'xx')."
                " 'thing_B' must match ^B{5}$ (had: 'qq')")
        self.expect_exception_message(exp)

    @exception_tuple
    def exception_tuple(self):
        _d = {
                'thing_A': 'xx',
                'thing_B': 'qq',
                }
        _subject_magnetic()(_d)


class Case400_win(_TestCase):

    def test_010_read_values_individually(self):
        o = self.end_collection
        self.assertEqual(o.thing_A, 'AAAA')
        self.assertEqual(o.thing_B, 'BBBBB')

    def test_020_can_iterate_in_this_manner(self):
        these = []
        col = self.end_collection
        for k in col:
            these.append((k, col[k]))
        _exp = [('thing_A', 'AAAA'), ('thing_B', 'BBBBB')]
        self.assertEqual(_exp, these)

    @shared_subject
    def end_collection(self):
        _d = {
                'thing_A': 'AAAA',
                'thing_B': 'BBBBB',
                }
        return _subject_magnetic()(_d)


@lazy
def _subject_magnetic():
    import upload_bot._magnetics.secrets_via_environment_variables as mod
    _requisite_things = {
        'thing_A': mod.regex_based_validator('^A{4}$'),
        'thing_B': mod.regex_based_validator('^B{5}$'),
        }
    return mod._collectioner_via_collection_model(
            collection_model=_requisite_things,
            items_plural='doo-hahs')


if __name__ == '__main__':
    unittest.main()

# #born.
