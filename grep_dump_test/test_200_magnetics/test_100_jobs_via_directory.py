from grep_dump_test.common_initial_state import (
        writable_tmpdir)
import unittest
import os
p = os.path

from modality_agnostic.memoization import (  # noqa: E402
        dangerous_memoize as shared_subject)


class Case050_MinimalPairShowingInferiorityOfFunctionBasedContextManagers(
        unittest.TestCase):
    """(so...)

    all we are really doing here is writing unit tests to affirm behavior
    of a language feature/the standard library. BUT

    we want these tests to exist as a tracker on the behavior itself, so
    that we're notified (by way of test failure) if it ever changes BECAUSE

    it seems that part of the point of context managers is that it's a more
    readable alternative to wrapping things in try/except blocks and having
    `ensure` clauses. (it is.)

    insomuch as there's a "design pull" towards readability, the
    `@contextmanager` decorator seems to try and further this effort
    (making it ostensibly a compelling choice for most context managers) BUT

    as we discovered only after going "all in" with this approach, this
    technique has a serious shortcoming that the author feels should possibly
    warrant its removal form the stdlib:

    when you construct your context-managers using this technique, the
    would-be `__exit__` function is not guaranteed to be called as it is
    when using the class form. (perhaps it can be no other way).


    furthering the design pull of readability even more, the `@contextmanager`
    decorator allows such constructs to be even more concise. (you're in
    effect writing two code blocks with one.) HOWEVER, a thing we didn't know
    until we bumped into it is that [see note #here1 below].
    """

    def test_010_function_based_context_manager_does_not_run_cleanup(self):
        """(see comment at the end)"""

        o = DidBeforeDidAfter()

        from contextlib import contextmanager

        @contextmanager
        def get_busy():
            o.did_before = True
            yield
            o.did_after = True

        did_during, caught_this_exception = self._same(get_busy())

        self.assertTrue(o.did_before and did_during and caught_this_exception)

        self.assertFalse(o.did_after)  # 👈👈👈 NOTE!!!
        # if an exception is thrown within the `yield` above, the
        # cleanup section is not run. this is contrary to what is expected
        # (subjectively)

    def test_020_class_based_context_manager_DOES_ensure_cleanup(self):

        o = DidBeforeDidAfter()

        class MyDoohah:
            def __enter__(self):
                o.did_before = True

            def __exit__(self, *_):
                o.did_after = True

        did_during, caught_this_exception = self._same(MyDoohah())

        self.assertTrue(o.did_before and did_during and caught_this_exception)

        self.assertTrue(o.did_after)  # 👈 LOOK! it's opposite of the above

    def _same(self, context_manager):

        did_during = False
        caught_this_exception = False

        try:
            with(context_manager):
                did_during = True
                raise _ThisException('xx')
        except _ThisException:
            caught_this_exception = True

        return (did_during, caught_this_exception)


class _ThisException(Exception):  # (only used above)
    pass


class Case010_DirectoriesGetCreatedAndDestoryed(unittest.TestCase):
    """(discussion)

    there is potential for confusion because there's two different reasons
    (and places) that we create/destroy directories: one is within the
    purview of the subject facility, and the other is at the purview of
    testing.

    near #here1 is where we create/destory a directory for testing.
    because the rmdir call will fail for all cases other than the directory
    existing and being empty, this codepoint tacitly covers these cases.
    """

    def test_010_magnet_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_020_everything_gets_destroyed(self):
        # (this test is tacit. we only know it works because #here1)
        self.assertIsNotNone(self._story_outcome)

    def test_030_job_directories_were_created(self):
        count = 0
        for (_, bef, aft) in self._directory_tuples:
            count += 1
            self.assertFalse(bef)
            self.assertTrue(aft)
        self.assertLessEqual(2, count)

    def test_040_job_numbers_are_assigned_in_order(self):

        itr = (x[0] for x in self._directory_tuples)

        num = next(itr)
        count = 1
        for num2 in itr:
            count += 1
            diff = num2 - num
            self.assertEqual(1, diff)
            num2 = num

        self.assertLessEqual(2, count)

    def test_050_job_numbers_start_at_one(self):
        self.assertEqual(1, self._directory_tuples[0][0])

    def test_060_some_infos_were_emitted(self):
        _hi = self._story_outcome['number_of_infos']
        self.assertEqual(3, _hi)

    @property
    def _directory_tuples(self):
        return self._story_outcome['directory_tuples']

    @property
    @shared_subject
    def _story_outcome(self):
        """sadly..

        sadly, we must "see into the future" to anticipate exactly what the
        job directory will be that is created for each job, before we begin
        the job. this means we apply detailed, a priori knowledge to build
        this tuple, like that the job numbers start at '1'. meh
        """

        a = []

        def _get_busy(jobs, jobs_path):

            items_dir = p.join(jobs_path, 'items')

            for s in ('1', '2'):

                exp_path = p.join(items_dir, s)

                did_exist_before = p.exists(exp_path)

                job = jobs.begin_job()

                self.assertEqual(exp_path, job.path)  # sneak this in

                did_exist_after = p.exists(exp_path)

                a.append((job.job_number, did_exist_before, did_exist_after))

        tc = self

        class Listener:
            def __init__(self):
                self.number_of_infos = 0

            def __call__(self, top_channel, *rest):
                tc.assertEqual(top_channel, 'info')
                self.number_of_infos += 1

        listener = Listener()

        with _clean_jobs_dir() as jobs_path:
            with _jobs_session(jobs_path, listener) as jobs:
                _get_busy(jobs, jobs_path)

        return {
                'directory_tuples': a,
                'number_of_infos': listener.number_of_infos,
                }


class Case020_Locking(unittest.TestCase):

    def test_010_locking_ensures_multiple_servers_dont_use_same_jobs_dir(self):

        from modality_agnostic.test_support.structured_emission import (
                one_and_done)

        def recv(chan, payloader):
            self.assertEqual('info', chan[0])

        listener, ran = one_and_done(self, recv)
        e = None

        with _clean_jobs_dir() as jobs_path:

            def build_one():
                return _subject_module().Jobser(jobs_path, _identity, listener)

            outer = build_one()
            outer.enter()
            inner = build_one()

            try:
                inner.enter()
                raise Exception('never reach here')
            except BlockingIOError as _:
                e = _
            finally:
                inner._lockfile_filehandle.close()  # dirty - avoid warning
                outer.exit()

        self.assertEqual('[Errno 35] Resource temporarily unavailable', str(e))
        ran()


class _clean_jobs_dir():
    """(this is the things that establish the prerequisites of the client)"""

    def __enter__(self):
        p = os.path
        self._jobs_dir = p.join(writable_tmpdir(), 'jobs')
        os.mkdir(self._jobs_dir)
        self._lock_me = p.join(self._jobs_dir, 'lock-me')
        _touch(self._lock_me)
        return self._jobs_dir

    def __exit__(self, *_):
        os.remove(self._lock_me)
        os.rmdir(self._jobs_dir)  # :#here1


class _jobs_session:
    """(this used to be the thing but is no longer the thing)"""

    def __init__(self, jobs_path, listener):
        self._jobser = _subject_module().Jobser(jobs_path, _identity, listener)

    def __enter__(self):
        self._jobser.enter()
        return self._jobser

    def __exit__(self, *_):
        x = self._jobser
        del self._jobser
        x.exit()


class DidBeforeDidAfter:
    def __init__(self):
        self.did_before = False
        self.did_after = False


def _touch(path):  # #open [#207.C] how to do this right
    open(path, 'w').close()


def _identity(x):  # IDENTITY_
    return x


def _subject_module():
    import grep_dump._magnetics.jobs_via_directory as x  # #[#204]
    return x


if __name__ == '__main__':
    unittest.main()

# #history-A.1: with-statement context de-abstracted from asset (moved here)
# #born.
