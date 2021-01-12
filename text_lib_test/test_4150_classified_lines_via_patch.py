from modality_agnostic.test_support.common import \
    dangerous_memoize_in_child_classes as shared_subject_in_child_classes
import unittest


class CommonCase(unittest.TestCase):

    @property
    def forward_extended_patch(self):
        return self.forward_and_reverse_extended_patches[0]

    @property
    def reverse_extended_patch(self):
        return self.forward_and_reverse_extended_patches[1]

    @property
    @shared_subject_in_child_classes
    def forward_and_reverse_extended_patches(self):
        dct = self.given_lines
        patch_lines = iter(dct['patch_lines'])
        after_lines = iter(dct['after_lines'])
        fwd, rev = subject_function()(patch_lines, after_lines)
        return fwd, rev

    @property
    @shared_subject_in_child_classes
    def given_lines(self):
        return {k: v for k, v in self._do_given_lines()}

    def _do_given_lines(self):
        def do(k):
            with open(dct.pop(k)) as fh:
                return tuple(fh)
        dct = {k: v for k, v in self.given_paths()}
        yield 'before_lines', do('before_path')
        yield 'after_lines', do('after_path')
        yield 'patch_lines', do('patch_path')
        assert not dct

    do_debug = True


class Case4145_intro(CommonCase):

    def test_010_module_loads(self):
        assert subject_module()

    def test_020_performs(self):
        assert self.forward_and_reverse_extended_patches

    def test_030_the_applied_of_the_forward_patch_gives_you_after_lines(self):
        act = tuple(self.forward_extended_patch.to_applied_lines())
        exp = self.given_lines['after_lines']
        self.assertSequenceEqual(act, exp)

    def test_040_reference_of_the_forward_patch_gives_you_before_lines(self):
        act = tuple(self.forward_extended_patch.to_reference_lines())
        exp = self.given_lines['before_lines']
        self.assertSequenceEqual(act, exp)

    def test_050_reference_of_the_reverse_patch_gives_you_after_lines(self):
        act = tuple(self.reverse_extended_patch.to_reference_lines())
        exp = self.given_lines['after_lines']
        self.assertSequenceEqual(act, exp)

    def test_060_applied_of_the_reverse_patch_gives_you_before_lines(self):
        act = tuple(self.reverse_extended_patch.to_applied_lines())
        exp = self.given_lines['before_lines']
        self.assertSequenceEqual(act, exp)

    def given_paths(_):
        from os.path import dirname, join
        head = join(dirname(__file__), 'fixture-directories', 'directory-050')
        yield 'before_path', join(head, 'before.txt')
        yield 'after_path', join(head, 'after.txt')
        yield 'patch_path', join(head, 'patch.diff')


def subject_function():
    return subject_module().func


def subject_module():
    import text_lib.magnetics.classified_lines_via_patch as mod
    return mod


if '__main__' == __name__:
    unittest.main()

# #born
