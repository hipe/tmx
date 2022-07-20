from unittest import TestCase as unittest_TestCase, main as unittest_main


class CommonCase(unittest_TestCase):

    def expect_success(self):
        res, emis = self._result_and_emissions()
        assert 0 == len(emis)

        lines = []
        lines_itr = res.to_sexp_lines()
        if self.do_debug:
            from sys import stdout
            w = stdout.write
            w('\n(DEBUGGING ON):\n')
        for line in lines_itr:
            if self.do_debug:
                w(line)
            lines.append(line)

        assert 15 == len(lines)  # ..

    def _result_and_emissions(self):
        listener = build_recording_listener_for(self)
        tail = self.given_fixture_file()
        from os.path import join as j
        path = j('kiss_rdb_test', 'fixture-directories', '2969-rec', tail)
        with open(path) as fh:
            res = subject_module().abstract_schema_via_recinf_lines(fh, listener)
        return res, tuple(listener.emissions)

    do_debug = False


class Case2895_ohai(CommonCase):

    def test_100_expect_success(self):
        self.expect_success()

    def given_fixture_file(self):
        return '0176-recinf-of-previous.lines'


def build_recording_listener_for(tc):
    def listener(*emi):
        *chan, lineser = emi
        w = None
        if tc.do_debug:
            from sys import stderr
            w = stderr.write
        if w:
            w(repr(chan))
            w('\n')

        lines = []
        for line in lineser():
            if w:
                w(f'  {chan[0]} (do_debug): ')
                w(line)
                if '\n' not in line:
                    w('\n')
            lines.append(line)
        listener.emissions.append((chan, tuple(lines)))

    listener.emissions = []
    return listener


def subject_module():
    from kiss_rdb.storage_adapters.rec import \
            abstract_schema_via_recinf as mod
    return mod


if __name__ == '__main__':
    unittest_main()

# #born
