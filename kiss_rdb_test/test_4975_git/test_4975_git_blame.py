from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subj_in_child_classes, \
        dangerous_memoize as shared_subject
import unittest


class CommonCase(unittest.TestCase):

    @property
    def end_state_reason(self):
        return self.end_state_emission.payloader()['reason']

    @property
    def end_state_existstatus(self):
        return self.end_state_emission.payloader()['exitstatus']

    @property  # away one day
    @shared_subj_in_child_classes
    def end_state_emission(self):
        import modality_agnostic.test_support.common as em
        listener, emissions = em.listener_and_emissions_for(self)
        path, func = self.given_path_and_fixture()
        x = subject_function(path, listener=listener, opn=func)
        emi, = emissions
        assert x is None
        return emi

    do_debug = False


class Case_4969_yes(CommonCase):

    def test_100_loads(self):
        self.assertTrue(subject_module())

    def test_200_builds(self):
        self.assertTrue(self.subject_index)

    def test_300_datetime_for_line(self):
        bi = self.subject_index
        dt = bi.datetime_for_lineno(3)
        act = dt.strftime(_DATETIME_FORMAT)
        self.assertEqual(act, '2020-09-18 06:51:11 -0400')
        for lineno in range(1, 6):
            bi.datetime_for_lineno(lineno)

    @shared_subject
    def subject_index(self):
        path, func = self.given_path_and_fixture()
        return subject_function(path, opn=func)

    def given_path_and_fixture(self):
        return 'fake-path-one', fake_path_one


class Case_4971_no_ent(CommonCase):

    def test_100_emission(self):
        act = self.end_state_emission.channel
        exp = 'error', 'structure', 'issue_from_subprocess'
        self.assertSequenceEqual(act, exp)

    def test_200_reason(self):
        act = self.end_state_reason
        exp = ("fatal: cannot stat path 'zzobie-doobie-doo.zib': "
               "No such file or directory\n")  # "\n" for now #here1
        self.assertEqual(act, exp)

    def test_300_exitstatus(self):
        self.assertEqual(self.end_state_existstatus, 128)

    def given_path_and_fixture(self):
        # return do_it_live_HERE_FOR_REFERENCE(), None
        return 'fake-path-two', fake_path_two


class Case_4970_not_versioned(CommonCase):

    def test_100_emission(self):
        act = self.end_state_emission.channel
        exp = 'error', 'structure', 'issue_from_subprocess'
        self.assertSequenceEqual(act, exp)

    def test_200_reason(self):
        act = self.end_state_reason
        exp = "fatal: no such path 'z/times' in HEAD\n"  # #here1
        self.assertEqual(act, exp)

    def test_300_exitstatus(self):
        self.assertEqual(self.end_state_existstatus, 128)

    def given_path_and_fixture(self):
        # return do_it_live_HERE_FOR_REFERENCE(), None
        return 'fake-path-three', fake_path_three


def fake_path_three(path):
    yield 'serr', "fatal: no such path 'z/times' in HEAD\n"
    yield 'returncode', 128


def fake_path_two(path):
    line = ("fatal: cannot stat path 'zzobie-doobie-doo.zib': "
            "No such file or directory\n")
    yield 'serr', line
    yield 'returncode', 128


def fake_path_one(path):
    assert 'fake-path-one' == path
    yield 'sout', '^7111fdc (Hans Zim 2020-09-18 06:51:11 -0400 1) orig ln 1\n'
    yield 'sout', '6977d313 (Hans Zim 2020-09-18 06:51:12 -0400 2) new line\n'
    yield 'sout', '^7111fdc (Hans Zim 2020-09-18 06:51:11 -0400 3) orig ln 2\n'
    yield 'sout', '^7111fdc (Hans Zim 2020-09-18 06:51:11 -0400 4) orig ln 3\n'
    yield 'sout', '6977d313 (Hans Zim 2020-09-18 06:51:12 -0400 5) added\n'
    yield 'returncode', 0


def do_it_live_HERE_FOR_REFERENCE():
    return 'z/times'  # exists but not versioned
    return 'zzobie-doobie-doo.zib'  # doesn't exist
    from kiss_rdb import __path__ as omg
    sub_proj, = omg
    from os.path import dirname, join
    return join(dirname(sub_proj), 'kiss-rdb-doc', 'README.md')


def subject_function(*a, **kw):
    return subject_module().blame_index_via_path(*a, **kw)


def subject_module():
    import kiss_rdb.vcs_adapters.git as mod
    return mod


_DATETIME_FORMAT = '%Y-%m-%d %H:%M:%S %z'


if __name__ == '__main__':
    unittest.main()

# #born
