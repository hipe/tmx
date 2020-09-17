"""this test file corresponds to an isomporphically named "magnetic" file.

the structure of this test file is almost *entirely* derived from the
[#304.figure-1]. (in fact, that's interesting food for thougt :[#008.F])
"""
from upload_bot._models import filesystem
from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject, lazy
import unittest


class _TestCase(unittest.TestCase):

    def _says_process_is_stale(self):
        self._um(0, '(PID file was stale)')

    def _says_started_server(self):
        self._um(-2, 'starting server ohai')

    def _says_server_is_running(self, num):
        _exp = '(server PID: {})'.format(num)
        self._um(-1, _exp)

    def _um(self, i, msg):
        _exp = self.end_tuple.messages[i]
        self.assertEqual(_exp, msg)


class Case100_yes_yes(_TestCase):

    def test_010_magentic_loads(self):
        self.assertIsNotNone(_subject_magnetic())

    def test_020_says_server_is_running(self):
        self._says_server_is_running(1234)

    @shared_subject
    def end_tuple(self):
        return _against(
                is_there_PID_file=True,
                is_the_process_running=True)


class Case200_no(_TestCase):

    def test_010_says_started_server(self):
        self._says_started_server()

    def test_030_says_server_is_running(self):
        self._says_server_is_running(4567)

    @shared_subject
    def end_tuple(self):
        return _against(is_there_PID_file=False)


class Case300_yes_no(_TestCase):

    def test_010_says_process_is_stale(self):
        self._says_process_is_stale()

    def test_020_says_started_server(self):
        self._says_started_server()

    def test_030_says_server_is_running(self):
        self._says_server_is_running(4567)

    @shared_subject
    def end_tuple(self):
        return _against(
                is_there_PID_file=True,
                is_the_process_running=False)


def _against(
        is_there_PID_file,
        is_the_process_running=None,
        ):

    def listener(*a):
        chan = a[0:-1]
        if ('info', 'expression') != chan:
            raise Exception('meh')

        def write(s):
            msgs.append(s)
        a[-1](write)

    msgs = []

    _fs = _memoized_fake_filesystem()
    _path = '/choopa/dalupa.pid' if is_there_PID_file else '/no/pid'

    # import psutil
    _use_psutil = _MockedPsutil(1234 if is_the_process_running else 9876)

    _subject_magnetic()(
            pid_file_path=_path,
            start_server=_my_start_server,
            psutil=_use_psutil,
            filesystem=_fs,
            listener=listener)

    return _EndTuple(msgs)


def _my_start_server(recv_pid, listener):
    def f(o):
        o('starting server ohai')
    listener('info', 'expression', f)
    recv_pid(4567)


class _EndTuple:
    def __init__(self, msgs):
        self.messages = msgs


@lazy
def _memoized_fake_filesystem():
    fs = filesystem.FakeFilesystem()
    with fs.open('/choopa/dalupa.pid', 'x') as fh:
        fh.write("Process ID of running server: 1234\n")
    return fs


@lazy
def _subject_magnetic():
    import upload_bot._magnetics.webserver_via_pid_file_path as mag
    return mag


class _MockedPsutil:
    """hack out the interface we want to use from `psutil`"""

    def __init__(self, pid):
        self._pid = pid

    def Process(self, pid):
        if pid == self._pid:
            pass
        else:
            raise _MockedPsutil._exceptions.NoSuchProcess('no see')

    class _exceptions:
        class NoSuchProcess(Exception):
            pass


if __name__ == '__main__':
    unittest.main()

# #born.
