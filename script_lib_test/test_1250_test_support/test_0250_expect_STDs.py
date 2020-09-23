"""cover the "expect STD's" library

The corresponding asset module states the subject's objective and scope.

for these tests in this file, our general goals are:

  - cover at least one success path (Case0243)

  - cover that failure is expressed appropriately for all of these:

    - when the actual number of lines exceeds the expected number. (Case0246)

    - when the actual number of lines comes up short. (Case0249)

    - when an actual line is written to the "wrong" stream
      (viz STDOUT not STDERR, or the other one) (Case0252)

    - (the kinds of content failure discussed next.)

  - allow modeling of content expectation (and cover failure thereof) via:

    - fixed string (Case0255)
    - regexp (Case0258)
    - the absence of content expectation (various cases)

the test cases (and the test methods within them) are written in an
intentional order, reflected in both the test case names and the test
methods names so that simpler, less dependent (less complicated) failure
will happen earlier. (more at [#006.regression-order]). the test methods
are idempotent and NOT interdependent!

finally, it is neither here nor there that these are "meta-tests", i.e that
they are tests for covering a testing library. the distinction is pure
novelty: testing is just testing; we approach it the same even if the
system-under-test is itself a testing library. (but see more N-meta antics
#here2.)
"""

from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes_2 as shared_subj_in_children
import unittest


class CommonCase(unittest.TestCase):

    def expect_message(self, msg):
        self.assertEqual(self.end_state['reason'], msg)

    def expect_performance_performs(self):
        self.assertTrue(self.end_state)

    @property  # ..
    @shared_subj_in_children
    def end_state(self):
        def run(use_tc):
            sout, serr, done = self.build_three(use_tc)
            io_via_shortcode = {'o': sout, 'e': serr}
            try:
                for short, line in self.given_actual_writes():
                    io_via_shortcode[short].write(line)
                done()
            except _Stop:
                pass
        which = self.given_expecting_success_or_failure()
        is_easy = ('failure', 'success').index(which)
        if is_easy:
            run(None)
            return 'no see succeeded'
        run(spy_tc := _SingleFailExpecter())
        return {'reason': spy_tc.finish().message}

    def build_three(self, use_tc):
        exps = self.given_expectations()
        return subject_module().stdout_and_stderr_and_done_via(exps, use_tc)

    def given_expectations(self):
        return (('STDERR', x) for x in self.given_stderr_expectations())

    def given_expecting_success_or_failure(_):
        return 'failure'


class Case0243_success_path(CommonCase):

    def test_050_subject_module_loads(self):
        self.assertIsNotNone(subject_module())

    def test_070_performance_perfoms(self):
        self.expect_performance_performs()

    def given_expecting_success_or_failure(_):
        return 'success'

    def given_actual_writes(_):
        yield 'e', newline
        yield 'e', newline

    def given_stderr_expectations(_):
        yield
        yield


class Case0246_one_too_many(CommonCase):

    def test_070_performance_perfoms(self):
        self.expect_performance_performs()

    def test_080_message_looks_good(self):
        self.expect_message("expecting no more lines but this line was outputted on STDERR - ohai\n")  # noqa E501

    def given_actual_writes(_):
        yield 'e', newline
        yield 'e', newline
        yield 'e', "ohai\n"

    def given_stderr_expectations(_):
        yield
        yield


class Case0249_one_too_few(CommonCase):

    def test_070_performance_perfoms(self):
        self.expect_performance_performs()

    def test_080_message_looks_good(self):
        self.expect_message('at end of input, expecting any line on STDERR')

    def given_actual_writes(_):
        yield 'e', newline

    def given_stderr_expectations(_):
        yield
        yield


# Case0250  # #midpoint


class Case0252_err_not_out_or_out_not_err(CommonCase):

    def test_070_performance_perfoms(self):
        self.expect_performance_performs()

    def test_080_message_looks_good(self):
        self.expect_message("expected line on STDERR, had STDOUT: cha cha\n")

    def given_actual_writes(_):
        yield 'o', "cha cha\n"
        yield 'o', "no see\n"

    def given_stderr_expectations(_):
        yield
        yield


class Case0255_content_mismatch_when_string(CommonCase):

    def test_070_performance_perfoms(self):
        self.expect_performance_performs()

    def test_080_message_looks_good(self):
        self.expect_message("expected (+), had (-):\n+ bar\n- biz\n")

    def given_actual_writes(_):
        yield 'e', "foo\n"
        yield 'e', "biz\n"

    def given_stderr_expectations(_):
        yield "foo\n"
        yield "bar\n"


class Case0258_content_mismatch_when_regexp(CommonCase):

    def test_070_performance_perfoms(self):
        self.expect_performance_performs()

    def test_080_message_looks_good(self):
        self.expect_message("expected to match regexp (+), had (-):\n+ /^baz$/\n-  baz\n")  # noqa: E501

    def given_actual_writes(_):
        yield 'e', "bif\n"
        yield 'e', " baz\n"

    def given_stderr_expectations(_):
        import re
        yield re.compile('^bif$')
        yield re.compile('^baz$')


# == Arities (definition errors)

class Case0260_strange_arity(CommonCase):

    def test_010_bad(self):
        with self.assertRaises(subject_exception_class()) as cm:
            self.build_three(None)
        exp = "Unrecognized keyword 'zib_zub'. Expecting one of"
        act, = cm.exception.args
        self.assertIn(exp, act)

    def given_expectations(_):
        yield 'zib_zub', 'STDERR'


class Case0261_cant_have_multiple_special_arities(CommonCase):

    def test_010_bad(self):
        with self.assertRaises(subject_exception_class()) as cm:
            self.build_three(None)
        exp = "Had 'zero_or_one' at end but also 'one_or_more' at stack offset 2"  # noqa: E501
        act, = cm.exception.args
        self.assertIn(exp, act)

    def given_expectations(_):
        yield 'one_or_more', 'STDERR'
        yield 'STDERR'
        yield 'zero_or_one', 'STDERR'


class Case0262_special_arities_must_be_anchored_to_end(CommonCase):

    def test_010_bad(self):
        with self.assertRaises(subject_exception_class()) as cm:
            self.build_three(None)
        exp = "Had 'zero_or_one' at stack offset 1"
        act, = cm.exception.args
        self.assertIn(exp, act)

    def given_expectations(_):
        yield 'zero_or_one', 'STDERR'
        yield 'STDERR'


# == Arities (in use)

class Case0263_one_or_more_failure_because_zero(CommonCase):

    def test_010_performance_perform(self):
        self.expect_performance_performs()

    def test_020_message_looks_good(self):
        exp = "at end of input, expecting any line on STDERR"
        self.expect_message(exp)

    def given_actual_writes(_):
        return ()

    def given_expectations(_):
        yield 'one_or_more', 'STDERR'


class Case0264_one_or_more_success_because_three(CommonCase):

    def test_010_performance_perform(self):
        self.expect_performance_performs()

    def given_actual_writes(_):
        yield 'e', 'A\n'
        yield 'e', 'B\n'
        yield 'e', 'C\n'

    def given_expectations(_):
        yield 'one_or_more', 'STDERR'

    def given_expecting_success_or_failure(_):
        return 'success'


class Case0265_zero_or_one_failure_because_two(CommonCase):

    def test_010_performance_perform(self):
        self.expect_performance_performs()

    def test_020_message_looks_good(self):
        exp = "expecting no more lines but this line was outputted on STDOUT - B\n"  # noqa: E501
        self.expect_message(exp)

    def given_actual_writes(_):
        yield 'o', 'A\n'
        yield 'o', 'B\n'

    def given_expectations(_):
        yield 'zero_or_one', 'STDOUT'


class Case0266_zero_or_one_success_because_zero(CommonCase):

    def test_010_performance_perform(self):
        self.expect_performance_performs()

    def given_actual_writes(_):
        return ()

    def given_expectations(_):
        yield 'zero_or_one', 'STDOUT'

    def given_expecting_success_or_failure(_):
        return 'success'


class Case0267_zero_or_one_success_because_one(CommonCase):

    def test_010_performance_perform(self):
        self.expect_performance_performs()

    def given_actual_writes(_):
        yield 'o', 'A\n'

    def given_expectations(_):
        yield 'zero_or_one', 'STDOUT'

    def given_expecting_success_or_failure(_):
        return 'success'


class Case0268_zero_or_more_success_on_zero(CommonCase):

    def test_010_performance_perform(self):
        self.expect_performance_performs()

    def given_actual_writes(_):
        return ()

    def given_expectations(_):
        yield 'zero_or_more', 'STDOUT'

    def given_expecting_success_or_failure(_):
        return 'success'


class Case0269_zero_or_more_success_on_one(CommonCase):

    def test_010_performance_perform(self):
        self.expect_performance_performs()

    def given_actual_writes(_):
        yield 'o', 'A\n'

    def given_expectations(_):
        yield 'zero_or_more', 'STDOUT'

    def given_expecting_success_or_failure(_):
        return 'success'


class Case0270_zero_or_more_success_on_three(CommonCase):

    def test_010_performance_perform(self):
        self.expect_performance_performs()

    def given_actual_writes(_):
        yield 'o', 'A\n'
        yield 'o', 'B\n'
        yield 'o', 'C\n'

    def given_expectations(_):
        yield 'zero_or_more', 'STDOUT'

    def given_expecting_success_or_failure(_):
        return 'success'

# ==

class _SingleFailExpecter:  # :#here2
    """the subject helps us check that test cases fail when we expect them to.

    it does so by serving as a minimally simple proxy for a test case
    (a.k.a "test context" elsewhere) whose only job (in our conception) is
    to expose a method called `fail` that takes a string argument.

      - after our test-case-under-test is run, we check that `fail` was in
        fact called. NOTE the subject does not do this check itself. the
        onus is on the user to do so. this is in part why this is not a
        "mock" proper.

      - the user may furthermore want to assert expectations of content
        for the message string that was passed to `fail`.

      - for now the subject asserts that `fail` is not called more than once
        per test-case-under-test. this forced simplification is in part to
        encourage the good design of only testing one failure at a time.

    NOTE whereas a "real" call to `fail` may (and under `unittest`, yes will)
    raise an exception, we do no such raising here. participating asset code
    must be written relying on no such assumption that logic flow can rely
    on an exception mechanism to drive control flow, an assumption that the
    author believes as a design principle generally. now, philosophy:

    the distinction between testing and meta-testing is generally a novelty:
    we test "asset code" (any code that is not test case code) using the
    same techniques regardless of whether that asset code happens to be part
    of a testing library. this said, as soon as you expose reusable test-
    support code, having coverage for such a library is as important as it
    is for any other asset code. the paradox then becomes: how do you end
    the otherwise never-ending chain of N-meta testing? our answer is: here.

    this single class comprises the entirety of our would-be specialized,
    reusable code dedicated to meta-testing (that is, test-library code
    intended to test test-library code). although we *could* write meta-meta-
    (i.e two-meta) tests to cover this (and end the meta-chain by using *no*
    custom, would-be reusable code); we don't (for now) because of how little
    surface area/complexity there is here.
    """

    def __init__(self):
        self.did = False
        self._mutex = None

    def fail(self, msg):
        del self._mutex  # ensures that the subject didn't fail more than once
        self.did = True
        self.message = msg
        raise _Stop()

    def finish(self):
        if not self.did:
            raise Exception('did not fail')
        return self

    do_debug = False  # look like a test case


class _Stop(RuntimeError):
    pass


def subject_exception_class():
    return subject_module()._ExpectationDefinitionError


def subject_module():
    import script_lib.test_support.expect_STDs as module
    return module


def xx():
    raise RuntimeError('do me')


newline = "\n"


if __name__ == '__main__':
    unittest.main()

# #history-B.1 noteworthy cleanup. added arities
