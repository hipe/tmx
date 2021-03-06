from modality_agnostic.test_support.common import \
    dangerous_memoize_in_child_classes as shared_subject_in_child_classes
from unittest import TestCase as unittest_TestCase, main as unittest_main
from os.path import dirname as dn, join as path_join


class CommonCase(unittest_TestCase):

    @property
    @shared_subject_in_child_classes
    def end_state(self):
        return self.build_end_state()

    def build_end_state(self):
        opn = self.build_convoluted_opn()
        coll_path = '/fake/DIRRO'

        from kiss_rdb.storage_adapters_.eno import \
            EXPERIMENTAL_caching_collection as func
        coll = func(coll_path, do_load_schema_from_filesystem=False, opn=opn)
        ci = coll.custom_functions

        from modality_agnostic import ModalityAgnosticErrorMonitor as cls
        mon = cls(None)

        wow = ci.AUDIT_TRAIL_FOR('ABC', mon, opn=opn)
        return tuple(wow)

    def build_convoluted_opn(self):
        entries = self.given_fixture_system_response()
        lines = self.given_current_file_lines()
        return build_convoluted_opn(lines, entries)


class Case4857_250_wahoo(CommonCase):

    def test_010_result_is_sexps_with_entity_snapshots_and_entity_edits(self):
        es = self.end_state
        assert 2 < len(es)
        itr = (sx[0] for sx in es)
        assert 'entity_snapshot' == next(itr)
        for k in itr:
            assert 'entity_edit' == k
            assert 'entity_snapshot' == next(itr)

    def test_030_entity_snapshot_has_entity_lines_and_core_attributes(self):
        es = self.end_state[0][1]
        assert es.entity_lines
        assert es.core_attributes

    def test_050_entity_edit_has_hunk_and_hunk_header_and_entity_diff(self):
        ee = self.end_state[1][1]
        assert ee.hunk
        assert ee.hunk_header_AST
        assert ee.entity_diff

    def test_070_from_AST_get_author_datetime_SHA_all_strings(self):
        hh_AST = self.end_state[1][1].hunk_header_AST
        assert hh_AST.author
        assert hh_AST.datetime_string
        assert isinstance(hh_AST.SHA, str)

    def test_090_get_commit_message_as_lines(self):
        hh_AST = self.end_state[1][1].hunk_header_AST
        lines = hh_AST.message_lines
        assert 1 < len(lines)
        sig = tuple('N' if '    \n' == line else 'C' for line in lines)
        self.assertSequenceEqual(sig, 'C N C C'.split())
        self.assertEqual(lines[0], '    Commit number 5.\n')

    def test_110_the_core_attributes_look_correct_over_time(self):
        dcts = tuple(sx[1].core_attributes for sx in self.end_state[0::2])
        dcts = dcts[:3]  # ignore any last (first) one for now

        act = tuple(tuple(sorted(dct.keys())) for dct in dcts)
        exp = (
            ('bodicum', 'paramzo_three', 'paramzo_two'),
            ('bodicum', 'faramzo', 'paramzo_three', 'paramzo_two'),
            ('bodicum', 'faramzo', 'paramzo_one', 'paramzo_two'))
        self.assertSequenceEqual(act, exp)

    def test_130_the_oldest_core_attributes_will_always_be_empty_dict(self):
        dct = self.end_state[-1][1].core_attributes
        assert isinstance(dct, dict)
        assert 0 == len(dct)

    def test_150_you_could_do_statistics_on_diff_lines_like_this(self):
        counts = {}
        ee = self.end_state[1][1]
        for typ, line in ee.hunk.hunk_body_line_sexps:
            counts[typ] = counts.get(typ, 0) + 1
        act = tuple((k, counts[k]) for k in sorted(counts.keys()))
        exp = (('context_line', 12), ('remove_line', 2))
        self.assertSequenceEqual(act, exp)

    def test_170_wow_look_at_all_the_things_you_have_in_an_entity_diff(self):
        ed = self.end_state[3][1].entity_diff

        ar = ed.attributes_removed
        self.assertSequenceEqual(tuple(ar.keys()), ('paramzo_one',))
        assert 'one' == ar['paramzo_one']

        aa = ed.attributes_added
        self.assertSequenceEqual(tuple(aa.keys()), ('paramzo_three',))
        assert 'three' == aa['paramzo_three']

        ac = ed.attributes_changed
        act = tuple(sorted(ac.keys()))
        self.assertSequenceEqual(act, ('bodicum', 'paramzo_two'))

    def test_190_when_change_is_from_wordlike_to_wordlike_you_get_values(self):
        ed = self.end_state[3][1].entity_diff
        ac = ed.attributes_changed
        typ, *rest = ac['paramzo_two']
        assert 'wordlike_values' == typ
        self.assertSequenceEqual(rest, ('two', 'two ver two'))

    def test_210_when_change_is_from_multiline_to_multiline_you_get_diff(self):
        ed = self.end_state[3][1].entity_diff
        ac = ed.attributes_changed
        typ, act = ac['bodicum']
        assert 'ndiff' == typ
        exp = (
            '  body line 1\n',
            '+ body line 1.5\n',
            '  body line 2')  # 👀 note no trailing newline, this is typical
        self.assertSequenceEqual(act, exp)

    def given_fixture_system_response(_):
        return 'fixture-system-responses', '010-git-log'

    def given_current_file_lines(_):
        """In production, the state of the filesystem (not VCS) is used
        (probably) to determine the HEAD state of the entity. (Not sure if
        we consider this a bug or not yet. It's definitely more KISS, less
        stable than somehow getting a HEAD version of a file with unversioned
        changes; but that feels like a real bad ROI right now to look at.)

        For use to simluate this in test, we use the "source" of the
        test fixture, even though it's not formally part of the fixture. meh.
        """

        # Use the same file used to make the fixture system response
        path = path_join(test_dir, 'fixture_system_response_sources',
                         '010-timeline-one', 'file-snapshot-5.eno')
        with open(path) as fh:
            return fh.readlines()


def build_convoluted_opn(lines, entries):

    def opn(cmd):
        assert isinstance(cmd, tuple)
        assert ('git', 'log') == cmd[:2]

        path = path_join(test_dir, *entries, 'stdout-lines.txt')

        with open(path) as fh:
            for line in fh:
                yield 'sout', line

        yield 'returncode', 0

    def BoT_kwargs_via(path):
        assert '/fake/DIRRO/entities/A/B.eno' == path
        return {'path': path, 'lines': lines}

    opn.body_of_text_keyword_args_via_path = BoT_kwargs_via
    return opn


test_dir = dn(dn(__file__))


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))


if __name__ == '__main__':
    unittest_main()

# #born
