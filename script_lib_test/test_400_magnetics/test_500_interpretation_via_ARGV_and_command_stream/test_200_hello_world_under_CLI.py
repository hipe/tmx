import _init  # noqa: F401
from script_lib.test_support.generic_CLI_helper import (
        CLI_CaseMethods,
        ARGV,
)
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        )
import unittest


class Case010_ohai(CLI_CaseMethods, unittest.TestCase):

    def test_010_the_invocation_succeeds(self):
        self.assertTrue(self.magnetic_call_.OK)
        # magnetic_call_succeeds_ (maybe one day)

    def test_020_hello_world_message__is_styled__ends_in_newline(self):
        invo = self.magnetic_call_
        self.assertEqual(1, invo.number_of_lines)
        _exp = "hello \u001B[1;32mworld\u001B[0m!\n"
        self.assertEqual(_exp, invo.first_line)

    @property
    @shared_subject
    def magnetic_call_(self):
        return self.invocation_when_expected_(1, 'STDERR')

    @ARGV
    def ARGV_(self):
        print("\n\n\nDON't FORGET - do DASHES to UNDERSCORES\n\n\n")
        self.do_debug = True
        return ['oh-hello']

    def command_stream_(self):
        from modality_agnostic_test.fixture_directories import (
                _010_cha_cha as mod,
                )
        import modality_agnostic.magnetics.command_stream_via_directory as x
        return x.SELF(mod)


if __name__ == '__main__':
    unittest.main()

# #born.
