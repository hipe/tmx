from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subj_in_children, \
        throwing_listener, lazy
import modality_agnostic.test_support.common as em
import unittest


class CommonCase(unittest.TestCase):

    def check_the_comparisions(self):
        f = memoized_parser()
        left, right = tuple(f(s) for s in self.given_these_two())
        hash_daggit_pool = {
            '<=': lambda: left <= right,
            '<': lambda: left < right,
            '>=': lambda: left >= right,
            '>': lambda: left > right,
            '!=': lambda: left != right,
            '==': lambda: left == right}
        for token, exp in self.expect_these_comparisions():
            act = hash_daggit_pool.pop(token)()
            self.assertEqual(act, exp)
        assert not len(hash_daggit_pool)

    def unparses(self):
        act = self.end_state_identifier.to_string()
        self.assertEqual(act, self.given_string())

    @property  # AWA
    @shared_subj_in_children
    def end_state_emission(self):
        print("MAKING IT")
        lstn, done = em.listener_and_done_via(self.expected_emissions(), self)
        cstack = self.given_context_stack()
        parser = subject_function()(lstn, (lambda: cstack if cstack else None))
        x = parser(self.given_string())
        emi = done()
        assert x is None
        assert 1 == len(emi)
        return emi['first_emission']

    def given_context_stack(_):
        pass

    @property  # away one day
    @shared_subj_in_children
    def end_state_identifier(self):
        return memoized_parser()(self.given_string())

    do_debug = False


class Case3850_parse_minimal(CommonCase):

    def test_100_loads(self):
        self.assertTrue(subject_function())

    def test_200_unparses(self):
        self.unparses()

    def given_string(_):
        return '[#051]'


class Case3851_six_comparisons_when_simple_less_than(CommonCase):

    def test_100_six_comparisions(self):
        self.check_the_comparisions()

    def given_these_two(_):
        return '[#052]', '[#053]'

    def expect_these_comparisions(_):
        yield '<=', True
        yield '<', True
        yield '>=', False
        yield '>', False
        yield '!=', True
        yield '==', False


class Case3852_six_comparisons_when_simple_equal(CommonCase):

    def test_100_six_comparisions(self):
        self.check_the_comparisions()

    def given_these_two(_):
        return '[#054]', '[#054]'

    def expect_these_comparisions(_):
        yield '<=', True
        yield '<', False
        yield '>=', True
        yield '>', False
        yield '!=', False
        yield '==', True


class Case3853_parse_compound(CommonCase):

    def test_100_loads(self):
        self.assertTrue(subject_function())

    def test_200_unparses(self):
        self.unparses()

    def given_string(_):
        return '[#056.Q]'


class Case3854_these_have_different_surface_form_and_same_deep_val(CommonCase):

    def test_100_six_comparisions(self):
        self.check_the_comparisions()

    def given_these_two(_):
        return '[#056.Z]', '[#056.26]'

    def expect_these_comparisions(_):
        yield '<=', True
        yield '<', False
        yield '>=', True
        yield '>', False
        yield '!=', False
        yield '==', True


class Case3855_compound_always_comes_after_simple(CommonCase):

    def test_100_six_comparisions(self):
        self.check_the_comparisions()

    def given_these_two(_):
        return '[#056.1]', '[#056]'

    def expect_these_comparisions(_):
        yield '<=', False
        yield '<', False
        yield '>=', True
        yield '>', True
        yield '!=', True
        yield '==', False


class Case3856_this_parse_error(CommonCase):

    def test_100_channel(self):
        self.end_state_emission

    def test_200_reason_and_details(self):
        emi = self.end_state_emission
        deets = emi.payloader()
        self.assertEqual(deets['expecting'], "'end of string'")
        self.assertEqual(deets['position'], 8)
        self.assertEqual(deets['path'], 'zoo-zah.ohi')
        self.assertEqual(deets['lineno'], 3)

    def given_string(_):
        return '[#056.Q] '

    def given_context_stack(_):
        return ({'path': 'zoo-zah.ohi'}, {'lineno': 3})

    def expected_emissions(_):
        yield 'error', 'structure', 'input_error', 'as', 'first_emission'


@lazy
def memoized_parser():
    return subject_function()(throwing_listener)


def subject_function():
    from pho._issues import build_identifier_parser_ as func
    return func


if __name__ == '__main__':
    unittest.main()

# #born
