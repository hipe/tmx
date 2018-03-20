"""
EXPERIMENT

    jobs/
        lock-me
        items/

COMING SOON:
    - pool
"""

from grep_dump._magnetics.rm_minus_rf_via_directory import (  # [#204]
        rm_minus_rf_via_directory
        )
import fcntl
import os
p = os.path


class Jobser:
    """called "jobser" because it makes jobs..

    make temporary directories ("job directories") for arbitrary use.

    its interface is "session oriented" with a stateful, particular interface:
    after constructing it, you must call `enter` *once*, do your work, and
    be sure to call `exit` *once* (if you want the cleanup too).

    assume:
        - that `dir_path` refers to an existent directory
        - that the file called `lock-me` exists as a child under that
        - that the directory (or any file) called `items` does NOT
          under that directory exist

    discussion:
        this used to (#history-A.1) actually implement the with-statement
        interface, but the client's requirements were such that we cannot
        place the whole lifecycle of the subject within a with-statement
        context.
    """

    def __init__(self, dir_path, wrapper_class, listener):
        self._mutex_for_enter = None
        self._dir_path = dir_path
        self._wrapper_class = wrapper_class
        self._listener = listener

    def enter(self):
        del self._mutex_for_enter
        self.__lock_the_lockfile()
        self.__make_the_directory()
        self._next_job_number = 1
        self._mutex_for_exit = None

    def __make_the_directory(self):
        self._items_dir = p.join(self._dir_path, 'items')
        os.mkdir(self._items_dir)

    def __lock_the_lockfile(self):
        """(notes:)

          - you don't need to open the file for 'w' to get the lock we want

          - exclusive lock and nonblocking lock: say (1) "i want to be the
            only one with the lock" and (2) "fail now if i can't have it"
            the lock is relesed when the IO is closed.
        """

        self._lockfile_filehandle = open(p.join(self._dir_path, 'lock-me'))
        fcntl.flock(self._lockfile_filehandle, fcntl.LOCK_EX|fcntl.LOCK_NB)

    def begin_job(self):
        # NOTE - gonna change this to a pool
        num = self._next_job_number
        self._next_job_number = num + 1
        job_dir = p.join(self._items_dir, str(num))
        os.mkdir(job_dir)
        _tuple = _Job(job_dir, num)
        _mixed = self._wrapper_class(_tuple)
        return _mixed

    def exit(self):
        """(this does cleanup after you are done caring about all jobs..)

        it would probably be best if the process concerned with the job
        itself did the removal..
        """

        del self._mutex_for_exit  # early sanity check - destroy max once.

        listener = self._listener
        for uow in rm_minus_rf_via_directory(self._items_dir):
            uow.execute_emitting_into(listener)

        self._lockfile_filehandle.close()
        del self._lockfile_filehandle



class _Job:
    """(this is NOT a base class. it exists to be passed as an argument ..)

    ..to a dedicated job class for its construction.
    """

    def __init__(self, dir_path, num):
        self.path = dir_path
        self.job_number = num


# #history-A.1: had to de-abstract with-statement context (a re-arch).
# #born.
