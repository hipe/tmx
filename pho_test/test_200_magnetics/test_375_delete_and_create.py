from pho_test.common_initial_state import \
        business_collection_one, listener_and_emissions
from modality_agnostic.memoization import \
        dangerous_memoize as shared_subject
from unittest import TestCase, main as unittest_main


def patch_at_N(n):  # #decorator
    def decorator(orig_f):
        def use_f(self):
            patch_file = self.big_patchfile.patches[n]

            from script_lib.magnetics.file_patches_via_unified_diff_lines \
                import file_patches_via_unified_diff_lines
            _2 = file_patches_via_unified_diff_lines(patch_file.diff_lines)
            _1 = patch_file

            class these_two:  # #class-as-namespace
                patch_file = _1
                file_patch, = tuple(_2)
            return these_two

        return use_f
    return decorator


class CommonCase(TestCase):

    @property
    @patch_at_N(0)
    def the_first_patch(self):
        pass

    @property
    @patch_at_N(1)
    def the_second_patch(self):
        pass

    @property
    @patch_at_N(2)
    def the_third_patch(self):
        pass

    @property
    @patch_at_N(3)
    def the_fourth_patch(self):
        pass


class Case375_everything(CommonCase):

    def test_100_the_index_patch_takes_out_the_two_lines(self):
        hunk, = self.the_first_patch.file_patch.hunks  # one hunk
        run, = hunk.to_remove_lines_runs()
        self.assertSequenceEqual(run.lines, ('- 8\n', '-W (2)\n'))

    def test_200_removes_the_pointback_from_its_previous(self):
        fp = self.the_second_patch.file_patch
        self.assertEqual(fp.mmm_line[-11:-1], 'es/4/8.eno')
        hunk, = fp.hunks  # one hunk
        run, = hunk.to_remove_lines_runs()  # one run
        self.assertSequenceEqual(run.lines, ('-next: 8W2\n', '-\n'))

    def test_300_removes_the_entity_itself(self):
        fp = self.the_third_patch.file_patch
        hunk, = fp.hunks
        run, = hunk.to_remove_lines_runs()  # one run
        self.assertIn(len(run.lines), range(25, 45))

    def test_400_removes_the_pointback_from_its_next(self):
        fp = self.the_fourth_patch.file_patch
        self.assertEqual(fp.mmm_line[-11:-1], 'es/P/B.eno')
        hunk, = fp.hunks  # one hunk
        run, = hunk.to_remove_lines_runs()  # one run
        self.assertSequenceEqual(run.lines, ('-parent: 8W2\n',))

    @property
    @shared_subject
    def big_patchfile(self):
        listener, emissions = listener_and_emissions()
        busi_coll = business_collection_one()
        bpf = busi_coll._big_patchfile_for_delete('8W2', listener)
        assert(not len(emissions))
        return bpf


if __name__ == '__main__':
    unittest_main()

# #born
