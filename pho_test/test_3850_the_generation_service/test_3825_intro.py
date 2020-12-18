import pho_test.generation_service_support as support
from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subject_in_children
import unittest


class ConfigCase(unittest.TestCase):

    # == Assertions

    def expect_expected_output_lines(self):
        exp = tuple(self.expected_output_lines())
        es = self.end_state
        act, = es  # #here1
        self.assertSequenceEqual(act, exp)

    # == Set-up

    @property
    @shared_subject_in_children
    def config(self):
        conf_defn = self.given_config()
        return support.config_via_definition(conf_defn)

    @property
    @shared_subject_in_children
    def end_state(self):
        return self.build_end_state()

    def build_end_state(self):
        fs_exp = self.given_filesystem_interactions()
        fs, done = support.BUILD_MOCK_FILESYSTEM(fs_exp)
        conf_defnf = self.given_config_definition_function()
        config = support.config_via_definition(conf_defnf(), filesystem=fs)
        cmd = self.given_command()
        rs = config.EXECUTE_COMMAND(cmd, listener=None)

        if self.do_debug:  # ..
            outputted_lines = []
            for line in rs:
                print(f"DBG: {line!r}")
                outputted_lines.append(line)
            outputted_lines = tuple(outputted_lines)
        else:
            outputted_lines = tuple(rs)

        done()
        return (outputted_lines,)  # #here1

    do_debug = False


class Case3805_build_this_config(ConfigCase):

    def test_100_builds(self):
        assert self.config

    def test_120_path_of_thing_looks_a_way(self):
        c = self.config
        c = c._components['peloogan_intermed_dir']
        assert c.path == 'zz/peloogan_intermed_dir'

    def given_config(_):

        yield 'peloogan_intermed_dir', 'SSG_intermediate_directory'

        def defn():
            yield 'SSG_adapter', 'peloogan'
            yield 'path', '[favorite temp dir]', 'peloogan_intermed_dir'
        yield defn

        yield 'favorite_temp_dir', 'filesystem_path', 'zz'


class Case3809_ls_directory_from_command(ConfigCase):

    def test_100_runs(self):
        assert self.end_state

    def test_200_output(self):
        self.expect_expected_output_lines()

    def expected_output_lines(_):
        yield '  file1.txt\n'
        yield '  file2.txt\n'

    def given_filesystem_interactions(self):

        # Hit the FS once to determine what commands are exposed
        yield 'pretend_os_stat_mode', same_path, 'existing_directory'

        # Hit the FS after we determine no-ent because w
        yield 'pretend_listdir', same_path, ('file1.txt', 'file2.txt')

    def given_command(_):
        return 'pooli_intermed_dir.ls'

    def given_config_definition_function(_):
        return this_one_example()


class Case3814_show(ConfigCase):

    def test_100_runs(self):
        assert self.end_state

    def test_200_output(self):
        self.expect_expected_output_lines()

    def expected_output_lines(_):
        yield '(config for generation):\n'
        yield '  main_pooligan_gen_controller (SSG controller):\n'
        yield '    source directory: pooli_intermed_dir\n'
        yield '  pooli_intermed_dir (intermediate directory):\n'
        yield "    path: 'z/peloogan_intermed_dir'\n"
        yield '    status: exists_and_is_not_directory\n'
        yield '  favorite_temp_dir: z\n'

    def given_filesystem_interactions(self):
        yield 'pretend_os_stat_mode', same_path, 'is_file_not_directory'

    def given_command(_):
        return 'show'

    def given_config_definition_function(_):
        return this_one_example()


class Case3817_create_directory_from_command(ConfigCase):

    def test_100_runs(self):
        assert self.end_state

    def test_200_output(self):
        self.expect_expected_output_lines()

    def expected_output_lines(_):
        yield f'  mkdir {same_path}\n'

    def given_filesystem_interactions(self):
        # Hit the FS once to determine what commands are exposed
        yield 'pretend_os_stat_mode', same_path, 'no_ent'

        # Hit the FS again when a command comes (that matched the above)
        yield 'pretend_mkdir', same_path

    def given_command(_):
        return 'pooli_intermed_dir.create_directory'

    def given_config_definition_function(_):
        return this_one_example()


def this_one_example():
    from pho_test.examples.example_1000_generation_conf import \
        generation_service_config as result
    return result


same_path = 'z/peloogan_intermed_dir'


if __name__ == '__main__':
    unittest.main()

# #born
