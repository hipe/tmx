from _common_state import (
        MDE_via_lines_and_table_start_line_object,
        TSLO_via,
        unindent,
        )
from modality_agnostic.test_support import structured_emission as se_lib
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        memoize,
        )
import unittest


"""
this module tests:
the CUD of body blocks ({ attribute | discretionary }) in/from a doc entity.

things like:

  - gist-ing will whine on existing names too similar
  - append to { empty | not empty }
  - insert at { head | mid }
  - delete at/from { head | mid | tail } to make non-empty
  - delete to make empty

trivia: midway through the initial development of this test file,
we realized we needed to develop our doubly-linked list alon.

see also a long note below about the test case ordering locally #here1.
"""


class _CommonCase(unittest.TestCase):

    def expect_no_structure_value(self, key):
        if key in self.structure():
            raise Exception(f'unexpected key present: {key}')

    def expect_structure_value(self, key, value):
        _actual = self.structure()[key]
        self.assertEqual(_actual, value)

    def expect_the_usual_channel(self):
        _chan = self.subject_failure_triple()[1]
        self.assertEqual(_chan, ('error', 'structure', 'input_error'))

    def expect_run_failed_to_produce_value(self):
        self.assertIsNone(self.subject_failure_triple()[0])

    def expect_edit(self):
        _expect = unindent(self.expect_these_body_lines_AFTER_edit())
        _mde = self.given_run(None)  # ..
        self._expect_doc_ent_body_lines(_mde, _expect)

    def given_run_inserting_before_offset(self, line, offset, listener):
        mde = self._build_doc_ent(listener)
        blk = _block_via_line(line, mde, listener)
        _iid = _internal_identifier_via_component_offset(offset, mde)
        mde.insert_body_block(blk, _iid)
        return mde

    def given_run_appending(self, line, listener):
        mde = self._build_doc_ent(listener)
        blk = _block_via_line(line, mde, listener)
        _ok = mde.append_body_block(blk, None)
        assert(_ok)
        return mde

    def given_run_deleting_at_offset(self, offset, listener):
        mde = self._build_doc_ent(listener)
        _iid = _internal_identifier_via_component_offset(offset, mde)
        x = mde._delete_block_via_iid(_iid)
        # -- begin make contact as assert. maybe types would help #[#008.D]
        x.is_attribute_block
        x.is_discretionary_block
        # --
        return mde

    def _build_doc_ent(self, listener):
        _given = self.given_lines()
        return _doc_entity_via_lines(_given, listener)

    def failure_triple_given_run(self):
        listener, emissioner = se_lib.listener_and_emissioner_for(self)
        _given = self.given_lines()
        x = _doc_entity_via_lines(_given, listener)
        chan, emit = emissioner()
        return (x, chan, emit)

    def expect_lines_before_edit(self):
        _big_s = self.expect_these_lines_before_edit()
        _expected_lines_gen = unindent(_big_s)
        self._expect_doc_ent_lines(self.subject(), _expected_lines_gen)

    def _expect_doc_ent_lines(self, mde, exp_lines_gen):
        _actual_lines_gen = mde.to_line_stream()
        self._expect_lines(_actual_lines_gen, exp_lines_gen)

    def _expect_doc_ent_body_lines(self, mde, exp_lines_gen):
        _actual_lines_gen = _body_line_gen(mde)
        self._expect_lines(_actual_lines_gen, exp_lines_gen)

    def expect_body_lines_before_edit(self):
        _big_s = self.expect_these_body_lines_before_edit()
        _expected_lines_gen = unindent(_big_s)
        _actual_lines_gen = _body_line_gen(self.subject())
        self._expect_lines(_actual_lines_gen, _expected_lines_gen)

    def _expect_lines(self, actual_lines_gen, expected_lines_gen):
        _expected_lines_tup = tuple(expected_lines_gen)
        _actual_lines_tup = tuple(actual_lines_gen)
        self.assertEqual(_actual_lines_tup, _expected_lines_tup)

    def expect_builds(self):
        self.assertIsNotNone(self.subject())


# == 000's: INTRO, BASICS


class Case402_000_empty(_CommonCase):

    def test_100_builds(self):
        self.expect_builds()

    def test_200_expect_lines_before_edit(self):
        self.expect_lines_before_edit()

    def test_200_expect_body_lines_before_edit(self):
        self.expect_body_lines_before_edit()

    def expect_these_body_lines_before_edit(self):
        return """
        """

    def expect_these_lines_before_edit(self):
        return """
        [item.A.meta]
        """

    @shared_subject
    def subject(self):
        return _doc_entity_via_lines(())


class Case402_050_all_three_kinds_of_lines(_CommonCase):

    def test_100_builds(self):
        self.expect_builds()

    def test_200_expect_body_lines_before_edit(self):
        self.expect_body_lines_before_edit()

    def expect_these_body_lines_before_edit(self):
        return """
        foo-bar = BAZ

        # comment line
        """

    @shared_subject
    def subject(self):
        _given = (
                'foo-bar = BAZ\n',
                '\n',
                '# comment line\n',
                )
        return _doc_entity_via_lines(_given)


class Case402_060_index_gist_collision_in_entity(_CommonCase):

    def test_100_expect_run_failed_to_produce_value(self):
        self.expect_run_failed_to_produce_value()

    def test_200_expect_the_usual_channel(self):
        self.expect_the_usual_channel()

    def test_300_does_NOT_have_a_whole_line(self):
        self.expect_no_structure_value('line')  # changed at #history-A.1

    def test_310_does_NOT_have_line_number(self):
        self.expect_no_structure_value('lineno')

    def test_320_does_NOT_have_position(self):
        self.expect_no_structure_value('position')  # changed at #history-A.1

    def test_330_has_expecting(self):
        self.expect_structure_value('expecting', 'available name')

    def test_340_has_reason_that_shows_both_names(self):
        self.expect_structure_value(
                'reason',
                (
                    "new name 'BIFFB-on-ZO10' too similar to "
                    "existing name 'biff-BON-zo-10'"
                ))

    @shared_subject
    def structure(self):
        return self.subject_failure_triple()[2]()

    @shared_subject
    def subject_failure_triple(self):
        return self.failure_triple_given_run()

    def given_run(self, listener):
        _given = self._given_lines()
        return _doc_entity_via_lines(_given, listener)

    def given_lines(self):
        return unindent("""
        biff-BON-zo-10 = 'bangeurs'
        foo-bar = BAZ
        BIFFB-on-ZO10 = 123
        """)


# == REPLACE


# (rien ici)


# == APPENDS/INSERTS


class Case402_100_append_to_empty(_CommonCase):

    def test_100_test_edit(self):
        self.expect_edit()

    def expect_these_body_lines_AFTER_edit(self):
        return """
        # only line
        """

    def given_run(self, listener):
        _line = '# only line\n'
        return self.given_run_appending(_line, listener)

    def given_lines(self):
        return ()


class Case402_110_append_to_non_empty(_CommonCase):

    def test_100_test_edit(self):
        self.expect_edit()

    def expect_these_body_lines_AFTER_edit(self):
        return """
        # comment alpha
        # comment beta
        """

    def given_run(self, listener):
        _line = '# comment beta\n'
        return self.given_run_appending(_line, listener)

    def given_lines(self):
        return unindent("""
        # comment alpha
        """)


class Case402_120_insert_at_head(_CommonCase):

    def test_100_test_edit(self):
        self.expect_edit()

    def expect_these_body_lines_AFTER_edit(self):
        return """
        # comment A
        # comment B
        # comment C
        """

    def given_run(self, listener):
        _line = '# comment A\n'
        return self.given_run_inserting_before_offset(_line, 0, listener)

    def given_lines(self):
        return unindent("""
        # comment B
        # comment C
        """)


class Case402_130_insert_into_mid(_CommonCase):

    def test_100_test_edit(self):
        self.expect_edit()

    def expect_these_body_lines_AFTER_edit(self):
        return """
        aa = "bb"
        # comment second
        # comment third
        """

    def given_run(self, listener):
        _line = '# comment second\n'
        return self.given_run_inserting_before_offset(_line, 1, listener)

    def given_lines(self):
        return unindent("""
        aa = "bb"
        # comment third
        """)


# == DELETES


"""a note about the rationale behind how we ordered these cases: :#here1

  - in this file, the cases go: (append, insert, delete).

  - [#867] (which was developed after this module) concurs with this order
    (just by happy accident).

  - [#010.6] "regression-friendly ordering" offers that
    all things being equal you
    should put simpler cases before more complex ones (for reasons).

  - DELETEs feel simpler than APPEND/INSERTs: for a DELETE you need only
    reference an existing item as opposed to constructing a new item. you
    need not cover the variety of validation fail cases in creating items.

  - however in the context of doubly-linked-lists, DELETEs are seen as
    _more_ complex because there's more reference re-wiring happening.

  - generally the same "list verb narratives" that we cover over there are
    ones we want to cover here; something like:

        { insert at | delete from } { head | mid | tail | empty }

  - if we go one step futher and use the same _case numbers_ for those test
    cases that have the same story (in this sense), the two suites can track
    each other and also we can reference test cases in code (SMELL) with less
    ambiguity.

  - once we've resolved to use certain numbers, this dictates order. (the
    test runner in effect sorts the test cases by name. the placement of the
    cases in the file has no bearing on the order in which they are run. as
    such it probably minimizes confusion to have the lexical order and file
    placement order be the same.)

  - at .#history-A.1 we "shard" the case numbers here so they are universal.
"""


class Case402_200_delete_at_head_to_make_non_empty(_CommonCase):

    def test_100_test_edit(self):
        self.expect_edit()

    def expect_these_body_lines_AFTER_edit(self):
        return """
        # comment line

        """

    def given_run(self, listener):
        return self.given_run_deleting_at_offset(0, listener)

    def given_lines(self):
        return unindent("""
        foo-bar = BAZ
        # comment line

        """)


class Case402_210_delete_from_mid_to_make_non_empty(_CommonCase):

    def test_100_test_edit(self):
        self.expect_edit()

    def expect_these_body_lines_AFTER_edit(self):
        return """
        # line 1
        # line 3
        """

    def given_run(self, listener):
        return self.given_run_deleting_at_offset(1, listener)

    def given_lines(self):
        return unindent("""
        # line 1
        bb = "line 2"
        # line 3
        """)


class Case402_230_delete_from_tail_to_make_non_empty(_CommonCase):

    def test_100_test_edit(self):
        self.expect_edit()

    def expect_these_body_lines_AFTER_edit(self):
        return """
        # line 1
        bb = "line 2"
        """

    def given_run(self, listener):
        return self.given_run_deleting_at_offset(2, listener)

    def given_lines(self):
        return unindent("""
        # line 1
        bb = "line 2"
        # line 3
        """)


class Case402_240_delete_to_make_empty(_CommonCase):

    def test_100_test_edit(self):
        self.expect_edit()

    def expect_these_body_lines_AFTER_edit(self):
        return """
        """

    def given_run(self, listener):
        return self.given_run_deleting_at_offset(0, listener)

    def given_lines(self):
        return unindent("""
        # the only line
        """)


# == SUPPORT


def _internal_identifier_via_component_offset(offset, mde):

    i = -1
    for iid in mde._LL.TO_IID_STREAM():
        i += 1
        if offset == i:
            found_iid = iid
            break

    return found_iid  # will raise UnboundLocalError if not found shrug


def _doc_entity_via_lines(given, listener=None):
    _ = _table_start_line_object()
    return MDE_via_lines_and_table_start_line_object(given, _, listener)


def _block_via_line(line, mde, listener):
    import kiss_rdb.magnetics_.blocks_via_file_lines as blk_lib
    if '#' == line[0]:  # #[#867.F]
        return blk_lib.AppendableDiscretionaryBlock_(line)
    else:
        cover_me()


@memoize
def _table_start_line_object():
    return TSLO_via('A', 'meta')


def _body_line_gen(mde):
    for blk in mde._LL.to_item_stream():
        for line in blk.to_line_stream():
            yield line


def cover_me():
    raise Exception('cover me')


if __name__ == '__main__':
    unittest.main()

# #history-A.1: when became multi-line
# #born.
