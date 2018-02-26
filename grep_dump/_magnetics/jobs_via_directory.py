"""
EXPERIMENT

    jobs/
        lock-me
        items/

COMING SOON:
    - pool
"""

from contextlib import contextmanager

import os
p = os.path


@contextmanager
def session(
        dir_path,
        wrapper_class,
        listener,
        ):
    """a jobs dir session as a context manager (to be used with `with`)..

    at construction time, assert (tacitly) the following:

        - that `dir_path` refers to an existent directory
        - that the file called `lock-me` exists as a child under that
        - that the directory (or any file) called `items` does NOT
          under that directory exist
    """

    from grep_dump._magnetics.rm_minus_rf_via_directory import (
            rm_minus_rf_via_directory as rm_rf,
            )

    with _locked_IO_via_path(p.join(dir_path, 'lock-me')):

        items_dir = p.join(dir_path, 'items')

        os.mkdir(items_dir)

        yield _Jobser(items_dir, wrapper_class)

        for uow in rm_rf(items_dir):
            uow.execute_emitting_into(listener)


class _Jobser:
    """(called "jobser" because it makes jobs..)"""

    def __init__(self, items_dir, wrapper_class):
        self._items_dir = items_dir
        self._next_job_number = 1
        self._wrapper_class = wrapper_class

    def begin_job(self):
        # NOTE - gonna change this to a pool
        num = self._next_job_number
        self._next_job_number = num + 1
        job_dir = p.join(self._items_dir, str(num))
        os.mkdir(job_dir)
        _tuple = _NamedTuple(job_dir, num)
        _mixed = self._wrapper_class(_tuple)
        return _mixed


class _NamedTuple:
    def __init__(self, dir_path, num):
        self.path = dir_path
        self.job_number = num


@contextmanager
def _locked_IO_via_path(lock_path):

    import fcntl

    with open(lock_path) as io:  # it appears we don't need to open it for 'w'

        fcntl.flock(io, fcntl.LOCK_EX | fcntl.LOCK_NB)
        # exclusive lock and nonblocking lock: say (1) "i want to be the
        # only one with the lock" and (2) "fail now if i can't have it"

        yield
        # we don't even pass the IO - it's just a semaphore.

    # closing the IO (not shown) releases the lock

# #born.
