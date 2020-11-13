from script_lib.test_support.CLI_canon import\
    CLI_Canon_Assertion_Methods as These
from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject
import unittest


class CommonCase(These, unittest.TestCase):

    def build_end_state(self):
        es = super().build_end_state()
        if not self.do_record_patches:
            return es
        x = self.patch_application_recording
        if not x:
            return es

        class custom_end_state:  # #class-as-namespace
            diff_lines, patch_application_was_dry = x
            lines = es.lines  # keep it simple while we can ..
            returncode = es.returncode

        return custom_end_state

    def given_CLI(self):
        these = ((k, see(self)) for (k, see) in dynamic_mocks)
        dct = {k: v for k, v in these}

        real_CLI = subject_module().CLI

        if not any(dct.values()):
            return real_CLI

        class efx:  # #class-as-namespace  efx = external functions
            pass

        for k, v in dct.items():
            setattr(efx, k, v)

        def use_CLI(si, so, se, argv, none):
            assert none is None
            return real_CLI(si, so, se, argv, efx)
        return use_CLI

    def given_environ(_):
        # (we default to engaging this function b.c it's so commonly needed)
        return the_empty_dict

    def given_input_lines(_):
        pass

    def given_stdin(_):
        pass

    do_record_patches = False
    do_debug = False


class Case3960_help(CommonCase):

    def test_050_everything(self):
        es = self.build_end_state_using_line_expectations()
        assert 0 == es.returncode
        hs = self.help_screen_via_lines(es.lines)
        for k in self.expected_sections():
            assert hs.section_via_key(k)

    def expected_sections(_):
        yield 'usage'
        yield 'description'
        yield 'options'
        yield 'arguments'
        yield 'commands'

    def expected_lines(self):
        yield 'one_or_more', 'STDOUT'

    def given_argv(_):
        return 'ohai', '--help'

    def given_environ(_):
        pass  # assert that the environment isn't used for help


class Case3966_list(CommonCase):
    # This is a broad sketch of a test. Things to note that we might break out:
    #
    # - Weirdly we can get away with naming the fields whatever (for this q)
    # - Example row is not seen, as it should be

    def test_050_everything(self):
        self.expect_success_returncode()

    def expected_lines(self):
        yield 'STDOUT', '|bar|#obun\n'
        yield 'STDOUT', '|baz|#obun\n'

    def given_stdin(self):
        # Things tested visually (nc = not covered):
        # - ending after just one table-looking line (nc)
        # - tables with zero cels is bad (nc)
        # - header row 1 must have endcap (nc)
        # - column counts must be same in first two (nc)

        yield "|aa|bb|\n"
        yield "|--|--|\n"
        yield "|foo|#obun\n"  # example row, not seen
        yield "|bar|#obun\n"
        yield "|bif|#obunn\n"
        yield "|baz|#obun\n"
        yield "|boffo\n"

    def given_argv(_):
        return 'ohai', '--readme=-', 'list', '#obun'


class Case3974PH_close(CommonCase):

    def test_050_succeeds(self):
        self.expect_success_returncode()

    def test_100_diff_lines(self):
        act = tuple(self.end_state.diff_lines)
        act = act[6:8]
        exp = '-|[#124]|wiz kid|x\n', '+|[#124]|#hole|\n'
        self.assertSequenceEqual(act, exp)

    def test_150_dry_run_went_thru(self):
        act = self.end_state.patch_application_was_dry
        self.assertTrue(act)

    def test_200_errput_lines(self):
        act = self.end_state.lines
        exp = tuple(self.expected_lines_more_specifically())
        self.assertSequenceEqual(act, exp)

    def expected_lines_more_specifically(self):
        yield "updated '[#124]' (updated 2 attributes)\n"
        yield 'BEFORE: |[#124]|wiz kid|x\n'
        yield 'AFTER:  |[#124]|#hole|\n'

    def expected_lines(self):
        yield 'one_or_more', 'STDERR'

    def given_input_lines(self):
        # Things tested visually (nc = not covered):
        # - your alignment strings must be min 3 chars (nc)
        # - the cells in the leftmost field must look like an iden
        # - not found looks great
        # - you gotta have the right field names (nc)
        # - example row needs the same number of fields (nc)
        # - content field must have existing value

        yield "|zizzy|Main tag|Content|\n"
        yield "|---|---|---|\n"
        yield "|foo|#obun|foofie\n"  # example row, not seen
        yield "|[#125]|cha cha\n"
        yield "|[#124]|wiz kid|x\n"
        yield "|[#123]|cha cha\n"

    def given_argv(_):
        return 'ohai', '-r', 'pretend.file', 'close', '124', '-n'

    do_record_patches = True


class Case3980_open(CommonCase):

    def test_050_succeeds(self):
        self.expect_success_returncode()

    def test_100_diff_lines(self):
        act = tuple(self.end_state.diff_lines)
        act = act[6:8]
        exp = '-|[#123]|#hole\n', '+|[#123]|#open|chimi churri\n'
        self.assertSequenceEqual(act, exp)

    def test_150_verbose_mode_shows_means_of_allocation_and_identifier(self):
        dct = self.custom_index
        self.assertEqual(dct['means'], 'tagged_hole')
        self.assertEqual(dct['identifier'], '[#123]')

    @shared_subject
    def custom_index(self):
        dct = {}
        other_lines = []
        import re
        rx = re.compile('^([^:]+):[ ](.+)')
        for line in self.end_state.lines:
            md = rx.match(line)
            if md:
                dct[md[1]] = md[2]
            else:
                other_lines.append(line)
        assert 1 == len(other_lines)  # meh. tested above
        return dct

    def expected_lines(self):
        yield 'zero_or_more'

    def given_input_lines(self):
        yield "|zizzy|Main tag|Content|\n"
        yield "|---|---|---|\n"
        yield "|[#124]|x|xx\n"
        yield "|[#123]|#hole\n"
        yield "|[#122]|x\n"

    def given_argv(_):
        return 'ohai', '-r', 'pretend.file', 'open', 'chimi churri', '-v'

    do_record_patches = True


# == Experiment

def dynamic_mock(f):
    dynamic_mocks.append((f.__name__, f))


dynamic_mocks = []


@dynamic_mock
def apply_patch(tc):
    if not tc.do_record_patches:
        return

    def use_apply_patch(diff_lines, is_dry, _listener):
        tc.patch_application_recording = diff_lines, is_dry
        return True
    tc.patch_application_recording = None
    return use_apply_patch


@dynamic_mock
def produce_open_function(tc):
    # (according to right now, you can't ever use the real filesystem)

    lz = tc.given_input_lines()
    if lz is None:
        return

    def opn(path, mode):  # assume yes_lines
        if 'r+' != mode:
            raise RuntimeError(f"fine but cover: '{mode}'")
        assert 'pretend.file' == path

        from modality_agnostic.test_support.mock_filehandle import \
            mock_filehandle_and_mutable_controller_via as func

        # to allow the use of seek() we have to mock it but we ignore `done()`
        fh, _ = func(1, lz, pretend_path=path, pretend_writable=True)
        return fh

    return lambda: opn


@dynamic_mock
def enver(tc):
    env = tc.given_environ()
    if env is None:
        return
    return lambda: env


# ==

def subject_module():
    import pho.cli.commands.issues as module
    return module


the_empty_dict = {}


if __name__ == '__main__':
    unittest.main()

# #born
