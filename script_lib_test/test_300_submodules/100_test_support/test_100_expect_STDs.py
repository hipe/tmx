"""cover the "expect STD's" library

the module this test file covers (the "subject") is mirrored in the
file's name. see that corresponding asset file for a statement of the
subject's objective and scope.

for these tests in this file, our general goals are:

  - cover at least one success path (case 01)

  - cover that failure is expressed appropriately for all of these:

    - when the actual number of lines exceeds the expected number. (case 02)

    - when the actual number of lines comes up short. (case 03)

    - when an actual line is written to the "wrong" stream
      (viz STDOUT not STDERR, or the other one) (case 04)

    - (the kinds of content failure discussed next.)

  - allow modeling of content expectation (and cover failure thereof) via:

    - fixed string (case 05)
    - regexp (case 06)
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

import _init  # noqa: F401

from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject)
import unittest


class _CaseMethods:

    def _performance_performs(self):
        self.assertIsNotNone(self._performance())

    def _two_stderr_line_certain_regexp_expectation(self):
        import re

        def f():
            yield re.compile('^bif$')
            yield re.compile('^baz$')
        return self._build_expectation(f)

    def _two_stderr_line_certain_string_expectation(self):
        def f():
            yield "foo\n"
            yield "bar\n"
        return self._build_expectation(f)

    def _two_stderr_line_any_string_expectation(self):
        def f():
            yield
            yield
        return self._build_expectation(f)

    def _build_expectation(self, f):
        return self._subject_module().expect_stderr_lines(f())

    def _subject_module(self):
        import script_lib.test_support.expect_STDs as x
        return x


class Case01_success_path(_CaseMethods, unittest.TestCase):

    def test_050_subject_module_loads(self):
        self.assertIsNotNone(self._subject_module())

    def test_060_subject_builds(self):
        self.assertIsNotNone(self._expectation())

    def test_070_performance_perfoms_without_failing(self):
        self._performance()

    @shared_subject
    def _performance(self):
        _exp = self._expectation()
        perf = _exp.to_performance_under(None)
        perf.stderr.write(newline)
        perf.stderr.write(newline)
        perf.finish()

    def _expectation(self):
        return self._two_stderr_line_any_string_expectation()


class Case02_one_too_many(_CaseMethods, unittest.TestCase):

    def test_070_performance_perfoms(self):
        self._performance_performs()

    def test_080_message_looks_good(self):
        _actual = self._performance()
        self.assertEqual(
         _actual.message,
         "expecting no more lines but this line was outputted on STDERR - ohai\n")  # noqa E501

    @shared_subject
    def _performance(self):
        exp = _SingleFailExpecter()
        _exp = self._expectation()
        perf = _exp.to_performance_under(exp)
        io = perf.stderr
        io.write(newline)
        io.write(newline)
        io.write("ohai\n")
        # perf.finish()  nah, pretend `fail` raised an exception
        return exp.finish()

    def _expectation(self):
        return self._two_stderr_line_any_string_expectation()


class Case03_one_too_few(_CaseMethods, unittest.TestCase):

    def test_070_performance_perfoms(self):
        self._performance_performs()

    def test_080_message_looks_good(self):
        _actual = self._performance()
        self.assertEqual(
            _actual.message,
            'at end of input, expecting any line on STDERR')

    @shared_subject
    def _performance(self):
        exp = _SingleFailExpecter()
        _exp = self._expectation()
        perf = _exp.to_performance_under(exp)
        io = perf.stderr
        io.write(newline)
        perf.finish()
        return exp.finish()

    def _expectation(self):
        return self._two_stderr_line_any_string_expectation()


class Case04_err_not_out_or_out_not_err(_CaseMethods, unittest.TestCase):

    def test_070_performance_perfoms(self):
        self._performance_performs()

    def test_080_message_looks_good(self):
        _actual = self._performance()
        self.assertEqual(
            _actual.message,
            "expected line on STDERR, had STDOUT: cha cha\n")

    @shared_subject
    def _performance(self):
        exp = _SingleFailExpecter()
        _exp = self._expectation()
        perf = _exp.to_performance_under(exp)
        perf.stderr.write(newline)
        perf.stdout.write("cha cha\n")
        return exp.finish()

    def _expectation(self):
        return self._two_stderr_line_any_string_expectation()


class Case05_content_mismatch_when_string(_CaseMethods, unittest.TestCase):

    def test_070_performance_perfoms(self):
        self.assertIsNotNone(self._performance())

    def test_080_message_looks_good(self):
        _actual = self._performance()
        self.assertEqual(
            _actual.message,
            "expected (+), had (-):\n+ bar\n- biz\n")

    @shared_subject
    def _performance(self):
        exp = _SingleFailExpecter()
        _exp = self._expectation()
        perf = _exp.to_performance_under(exp)
        io = perf.stderr
        io.write("foo\n")
        io.write("biz\n")
        return exp.finish()

    def _expectation(self):
        return self._two_stderr_line_certain_string_expectation()


class Case06_content_mismatch_when_regexp(_CaseMethods, unittest.TestCase):

    def test_070_performance_perfoms(self):
        self._performance_performs()

    def test_080_message_looks_good(self):
        _actual = self._performance()
        self.assertEqual(
            _actual.message,
            "expected to match regexp (+), had (-):\n+ /^baz$/\n-  baz\n")

    @shared_subject
    def _performance(self):
        exp = _SingleFailExpecter()
        _exp = self._expectation()
        perf = _exp.to_performance_under(exp)
        io = perf.stderr
        io.write("bif\n")
        io.write(" baz\n")
        return exp.finish()

    def _expectation(self):
        return self._two_stderr_line_certain_regexp_expectation()


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

    def finish(self):
        if not self.did:
            raise Exception('did not fail')
        return self


newline = "\n"

if __name__ == '__main__':
    unittest.main()
