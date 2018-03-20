from __init__ import(
        writable_tmpdir
        )
from contextlib import contextmanager
import unittest
import os
p = os.path

from game_server import (  # noqa: E402
        dangerous_memoize as shared_subject,
        memoize,
        )


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

        def listener(top_channel, *_):
            # (we have tested that these emissions look right in a lowel-
            #  leveled test module. here we just assert that there is no etc)

            if 'info' != top_channel:
                self.fail("expecting 'info' had '{}'".format(top_channel))
            nonlocal number_of_infos
            number_of_infos += 1

        number_of_infos = 0

        with _clean_jobs_dir() as jobs_path:
            with _session(jobs_path, listener) as jobs:
                _get_busy(jobs, jobs_path)

        return {
                'directory_tuples': a,
                'number_of_infos': number_of_infos,
                }


class Case020_Locking(unittest.TestCase):

    def test_010_locking_ensures_multiple_servers_dont_use_same_jobs_dir(self):

        def listener(top_channel, *_):
            nonlocal count
            count += 1
            self.assertEqual('info', top_channel)

        count = 0

        with _clean_jobs_dir() as jobs_path, _session(jobs_path, listener):
            hi = _session(jobs_path, listener)
            try:
                with hi:
                    pass
            except BlockingIOError as _:
                e = _

        self.assertEqual('[Errno 35] Resource temporarily unavailable', str(e))
        self.assertEqual(1, count)


@contextmanager
def _clean_jobs_dir():
    jobs_dir = p.join(writable_tmpdir, 'jobs')
    os.mkdir(jobs_dir)
    lock_me = p.join(jobs_dir, 'lock-me')
    _touch(lock_me)
    yield jobs_dir
    os.remove(lock_me)
    os.rmdir(jobs_dir)  # :#here1


def _session(jobs_path, listener):
    return _subject_module().session(jobs_path, _identity, listener)


def _touch(path):  # #todo how (2/2)
    open(path, 'w').close()


def _identity(x):  # IDENTITY_
    return x


@memoize
def _subject_module():
    import grep_dump._magnetics.jobs_via_directory as x
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
