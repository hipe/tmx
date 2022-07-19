from unittest import TestCase as unittest_TestCase, main as unittest_main

class UsageLineScannerCase(unittest_TestCase):

    def expect(self, *expected_terms):
        itr = subject_module()._formal_arguments_via_usage_line(self.given_usage_line)
        def actual_terms():
            for fa in itr:
                label = fa.label
                if fa.is_glob:
                    yield f'*{label}'
                else:
                    yield label
        actual_terms = tuple(actual_terms())
        self.assertSequenceEqual(expected_terms, actual_terms)


class Case5088_none(UsageLineScannerCase):

    def test_010_none(self):
        self.expect()

    given_usage_line = 'usage: {prog_name}'


class Case5090_one(UsageLineScannerCase):

    def test_010_none(self):
        self.expect('FOO_123')

    given_usage_line = 'usage: {prog_name} FOO_123'


class Case5092_two(UsageLineScannerCase):

    def test_010_none(self):
        self.expect('FOO_123', '456_BAR')

    given_usage_line = 'usage: {prog_name} FOO_123 456_BAR'


class Case5094_this(UsageLineScannerCase):

    def test_010_none(self):
        self.expect('FOO', 'BAR', '*BAZ')

    given_usage_line = 'usage: {prog_name} FOO BAR *BAZ'


def subject_module():
    from script_lib import docstring_based_command as mod
    return mod


if '__main__' ==  __name__:
    unittest_main()

# #born
