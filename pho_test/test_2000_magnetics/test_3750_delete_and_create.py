from pho_test.common_initial_state import business_collection_one
from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes_2
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

    @property
    @dangerous_memoize_in_child_classes_2
    def big_patchfile(self):
        listener, emissions = listener_and_emissions()
        busi_coll = business_collection_one()  # ..
        bpf = self.given_work_that_produces_big_patchfile(busi_coll, listener)
        assert(not len(emissions))
        return bpf


class Case3750_delete_entity(CommonCase):

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

    def given_work_that_produces_big_patchfile(self, busi_coll, listener):
        return busi_coll._big_patchfile_for_delete('8W2', listener)


class Case4100_create_entity(CommonCase):

    def test_100_update_the_entity_file(self):
        hunk, = self.the_first_patch.file_patch.hunks  # one hunk
        actual = hunk.these_lines('context', '(', 'remove', 'add', ')', 'context')  # noqa: E501
        expected = (
            '-C (          7)\n',
            '+C (        6 7)\n')
        self.assertSequenceEqual(actual, expected)

    def test_200_appends_self_to_list_of_children(self):
        fp = self.the_second_patch.file_patch
        self.assertEqual(fp.mmm_line[-11:-1], 'es/8/W.eno')
        hunk, = fp.hunks  # one hunk
        actual = hunk.these_lines('context', '(', 'add', ')', 'context')
        self.assertSequenceEqual(actual, ('+- DC6\n',))

    def test_300_adds_the_entity_itself(self):
        fp = self.the_third_patch.file_patch
        hunk, = fp.hunks  # one hunk
        actual = hunk.these_lines('(', 'add', 'context', ')')
        expected = (
            '+# entity: DC6: attributes\n',
            '+parent: 8W2\n',
            '+heading: «your heading here»\n',
            '+body: «your body here»\n',
            '+\n',
            ' # entity: DC7: attributes\n',
            ' heading: heading for (FRAG: DC7)\n',
            ' document_datetime: 2019-05-24 18:41:19-04:00\n')  # ick/meh
        self.assertSequenceEqual(actual, expected)

    def given_work_that_produces_big_patchfile(self, busi_coll, listener):
        values = {'parent': '8W2'}
        return busi_coll._big_patchfile_for_create(values, listener)


if __name__ == '__main__':
    unittest_main()

# #born
