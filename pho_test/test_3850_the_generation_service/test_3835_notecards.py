from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject, lazy
import unittest
from os.path import join


class FilesCase(unittest.TestCase):

    def perform(self):
        kw = {k: v for k, v in self.given_paths()}
        patch_path, eno_path = kw.pop('patch_path'), kw.pop('after_path')

        def opn(cmd):
            with open(patch_path) as fh:
                for line in fh:
                    yield 'sout', line
            yield 'returncode', 0

        return ancillary_function()(eno_path, None, opn=opn)  # tuple of EIDs


class SpanIntersectionsCase(unittest.TestCase):

    def perform(self):
        func = subject_module()._find_span_intersections
        left_things = self.given_left_things()
        right_things = self.given_right_things()
        return tuple(two for (one, two) in func(left_things, right_things))


class Case3821_find_span_intersections(SpanIntersectionsCase):

    def test_010_an_inside_intersection(self):
        inside, = self.result[0].inside_or_flush
        assert 'fello dello' == inside[2]

    def test_020_a_kiss_one_side(self):
        left, right = self.result[1].kissing
        assert left is None
        assert 'mizzo tizzo' == right[2]

    def test_030_the_other_side_of_a_kiss_is_a_flush(self):
        ting, = self.result[2].inside_or_flush
        assert 'mizzo tizzo' == ting[2]

    def test_040_an_overhang_one_side(self):
        inters = self.result[2]
        ting = inters.overhangs['at_stop']
        assert 'cibo matto' == ting[2]

    def test_050_an_overhang_other_side(self):
        inters = self.result[3]
        ting = inters.overhangs['at_start']
        assert 'cibo matto' == ting[2]

    @shared_subject
    def result(self):
        return self.perform()

    def given_left_things(_):
        yield 0, 5, 'first_thing'
        yield 5, 10, 'second_thing'
        yield 10, 15, 'third_thing'
        yield 15, 20, 'fourth_thing'

    def given_right_things(_):
        yield 1, 4, 'fello dello'
        yield 10, 12, 'mizzo tizzo'
        yield 13, 16, 'cibo matto'


class Case3825_EIDs_with_changes_from_file_with_changes(FilesCase):

    def test_010_shows_that_this_one_entity_changed(self):
        act = self.perform()
        exp = ('PBC',)
        self.assertSequenceEqual(act, exp)

    def given_paths(_):
        head = join(this_one_fixtures_dir(), 'file-with-changes-0100')
        yield 'after_path', join(head, 'after.eno')
        yield 'patch_path', join(head, 'patch.diff')


def this_one_fixtures_dir():
    return join(fixture_directories_dir(), 'files-with-changes')


@lazy
def fixture_directories_dir():
    from os.path import dirname as dn, realpath
    my_test_dir = dn(dn(realpath(__file__)))
    return join(my_test_dir, 'fixture-directories')


def ancillary_function():
    return subject_module()._EIDS_via_file_with_changes


def subject_module():
    import pho.notecards_.abstract_document_via_file_with_changes as module
    return module


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))


if __name__ == '__main__':
    unittest.main()

# #born
