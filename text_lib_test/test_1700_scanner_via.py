from doctest import DocTestSuite
import unittest


def load_tests(loader, tests, ignore):  # (this is a unittest API hook-in)
    tests.addTests(DocTestSuite(subject_module()))
    return tests


class CommonCase(unittest.TestCase):

    def expect_A_B_testing(self, scn):
        self.assertEqual(scn.empty, False)
        self.assertEqual(scn.next(), 'A')
        self.assertEqual(scn.more, True)
        self.assertEqual(scn.peek, 'B')
        self.assertEqual(scn.next(), 'B')
        self.assertEqual(scn.empty, True)
        self.assertEqual(scn.more, False)


class Case1650_via_universal_function(CommonCase):

    def test_050_long_story(self):
        # (started as doctest but didn't work b.c idk)
        def func():
            if not len(stack):
                return False, None
            return True, stack.pop()
        stack = ['B', 'A']
        scn = self.subject_function()(func)
        self.expect_A_B_testing(scn)

    def subject_function(_):
        return subject_module()._scanner_via_universal_function


class Case1655_via_list(CommonCase):

    def test_050_long_story(self):
        scn = self.subject_function()(('A', 'B'))
        self.expect_A_B_testing(scn)

    def subject_function(_):
        return subject_module().scanner_via_list


class Case1658_advance_observer(CommonCase):

    def test_050_too_complicated_for_doctest(self):
        scnlib = subject_module()
        scn = scnlib.scanner_via_iterator(iter(('line1', 'line2')))

        def advance_lineno():
            scn.lineno += 1
        scn.lineno = 0
        scnlib.MUTATE_add_advance_observer(scn, advance_lineno)
        self.assertEqual(0, scn.lineno)
        assert 'line1' == scn.next()
        self.assertEqual(1, scn.lineno)
        assert 'line2' == scn.next()
        self.assertEqual(2, scn.lineno)
        assert scn.empty


def subject_module():
    import text_lib.magnetics.scanner_via as module
    return module


if __name__ == '__main__':
    unittest.main()

# #born
