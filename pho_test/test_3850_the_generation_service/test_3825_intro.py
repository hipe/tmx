import pho_test.generation_service_support as support
from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subject_in_children
import unittest


class ConfigCase(unittest.TestCase):

    # == Assertions

    def expect_expected_output_lines(self):
        exp = tuple(self.expected_output_lines())
        es = self.end_state
        act, rc = es  # #here1
        self.assertSequenceEqual(act, exp)
        assert 0 == rc

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
        fake_env = self.given_environment()
        conf = conf_defnf(fake_env, listener=None)
        config = support.config_via_definition(conf, filesystem=fs)
        cmd = self.given_command()

        from modality_agnostic.test_support.common import \
            listener_and_emissions_for as func
        listener, emis = func(self)

        rc = config.EXECUTE_COMMAND(cmd, listener)

        def nl(s):
            if '\n' in s:
                raise RuntimeError(f'where: {s!r}')
            return f"{s}\n"

        olines = tuple(nl(s) for emi in emis for s in emi.payloader())
        done()
        return olines, rc  # #here1

    def given_environment(self):
        path = self.given_intermediate_directory()
        return {'PHO_PELICAN_INTERMEDIATE_DIR': path}

    do_debug = False


class Case3805_build_this_config(ConfigCase):

    def test_100_builds(self):
        assert self.config

    def test_120_path_of_thing_looks_a_way(self):
        c = self.config
        c = c._components[same_key]
        from os.path import join as _path_join
        exp = _path_join('zz', same_key)
        assert c.path == exp

    def given_config(_):

        yield same_key, 'SSG_intermediate_directory'

        def defn():
            yield 'SSG_adapter', 'peloogan'
            yield 'path', '[favorite temp dir]', same_key
        yield defn

        yield 'favorite_temp_dir', 'filesystem_path', 'zz'


class Case3809_ls_directory_from_command(ConfigCase):

    def test_100_runs(self):
        assert self.end_state

    def test_200_output(self):
        self.expect_expected_output_lines()

    def expected_output_lines(_):
        yield f'{ind}file1.txt\n'
        yield f'{ind}file2.txt\n'

    def given_filesystem_interactions(self):

        same_path = pretend_path

        # Hit the FS once to determine what commands are exposed
        yield 'pretend_os_stat_mode', same_path, 'existing_directory'

        # Hit the FS after we determine no-ent because w
        yield 'pretend_listdir', same_path, ('file1.txt', 'file2.txt')

    def given_command(_):
        return 'pooli_intermed_dir.ls'

    def given_config_definition_function(_):
        return this_one_example()

    def given_intermediate_directory(_):
        return pretend_path


class Case3814_show(ConfigCase):

    def test_100_runs(self):
        assert self.end_state

    def test_200_output(self):
        self.expect_expected_output_lines()

    def expected_output_lines(_):
        same_path = pretend_path
        yield '(config for generation):\n'
        yield '  main_pooligan_gen_controller (SSG controller):\n'
        yield '    source directory: pooli_intermed_dir\n'
        yield '  pooli_intermed_dir (intermediate directory):\n'
        yield f"    path: '{same_path}'\n"
        yield '    status: exists_and_is_not_directory\n'

    def given_filesystem_interactions(self):
        same_path = pretend_path
        yield 'pretend_os_stat_mode', same_path, 'is_file_not_directory'

    def given_command(_):
        return 'show'

    def given_config_definition_function(_):
        return this_one_example()

    def given_intermediate_directory(_):
        return pretend_path


class Case3817_create_directory_from_command(ConfigCase):

    def test_100_runs(self):
        assert self.end_state

    def test_200_output(self):
        self.expect_expected_output_lines()

    def expected_output_lines(_):
        same_path = pretend_path
        yield f'{ind}mkdir {same_path}\n'

    def given_filesystem_interactions(self):
        same_path = pretend_path

        # Hit the FS once to determine what commands are exposed
        yield 'pretend_os_stat_mode', same_path, 'no_ent'

        # Hit the FS again when a command comes (that matched the above)
        yield 'pretend_mkdir', same_path

    def given_command(_):
        return 'pooli_intermed_dir.create_directory'

    def given_config_definition_function(_):
        return this_one_example()

    def given_intermediate_directory(_):
        return pretend_path


class Case3820_generate_a_single_file(ConfigCase):

    def test_100_generated_ARGV_is_probably_OK(self):
        conf = self.build_config()
        argv = self.given_performance(conf)
        assert all(isinstance(x, str) for x in argv)
        self.assertIn(len(argv), range(20, 24))  # or whatever

    def build_config(self):
        intermed_dir = real_FS_intermed_dir_eg_01
        fake_env = {'PHO_PELICAN_INTERMEDIATE_DIR': intermed_dir}
        conf_defnf = self.given_config_definition_function()
        conf_defn = conf_defnf(fake_env, listener=None)
        return support.config_via_definition(conf_defn)

    def given_performance(self, conf):  # imagine
        comp = conf.get_component_('main_pooligan_gen_controller')
        return comp._procure_ARGV_for_generate_single_file('one-two-three.md')

    def given_config_definition_function(_):
        return this_one_example()


def this_one_example():
    from pho_test.examples.example_1000_generation_conf import \
        generation_service_config as result
    return result


real_FS_intermed_dir_eg_01 = 'pho_tasks/tasks-data/pelican-intermed-dir-example-01'  # noqa: E501
same_key = 'peloogan_intermed_dir'
pretend_path = '/fake-fs/fake-intermed-dir'

ind = ''


if __name__ == '__main__':
    unittest.main()

# #born
