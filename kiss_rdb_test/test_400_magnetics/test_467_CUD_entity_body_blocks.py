import _common_state  # noqa: F401
from kiss_rdb_test import structured_emission as selib
from modality_agnostic.memoization import dangerous_memoize as shared_subject
import unittest

unindent = selib.unindent

"""
(subject under test explained exhaustively in [#865] CUD for attributes)

the objective & scope of this test file is actually focused well enough, but
it can seem muddled until you get through this backstory:

  - based on the name of the counterpart asset this tries to cover (its
    subject module, something like "entity_via_identifier_and_file_lines"),
    one might expect this test to cover entity RETRIEVE;

  - but the main asset provided by that magnet is actually the all-important
    "mutable document entity" itself. so how do you cover that? well:

  - we set out to cover the line-level CUD operations exposed by that mutable
    model, an API that for a time we thought would speak in terms of line
    offsets (when relevant) (e.g insert this line before this other line,
    delete this line at offset X, etc.), before we realized that using IID's
    was a preferable way to refer to existing body blocks. although this
    line-offset-centric view is no longer in the asset, it endures in some of
    the tests here.

  - during implementation, we realized that what we were really doing was
    just developing our chosen implementation: the doubly-linked list. this,
    then, abstracted out into its own module & tests. so when we returned to
    this test file, it became mostly an integration test between the mutable
    document entity and its underlying doubly-linked list. (this is
    reflected in how short the asset file is at writing: 267 LOC)

see also a long note below about the test case ordering locally.

also, during renames we renamed this with a hint toward the future
(undocumented).
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
        lo = mde.procure_line_object__(line, listener)
        self.fail() if lo is None else None
        _iid = _internal_identifer_via_body_line_offset(offset, mde)
        mde.insert_line_object(lo, _iid)
        return mde

    def given_run_appending(self, line, listener):
        mde = self._build_doc_ent(listener)
        lo = mde.procure_line_object__(line, listener)
        self.fail() if lo is None else None
        mde.append_line_object(lo)
        return mde

    def given_run_deleting_at_offset(self, offset, listener):
        mde = self._build_doc_ent(listener)
        _iid = _internal_identifer_via_body_line_offset(offset, mde)
        x = mde._delete_line_object_via_iid(_iid)
        x.line  # eek / meh
        return mde

    def _build_doc_ent(self, listener):
        _given = self.given_lines()
        return _doc_entity_via_lines(_given, listener)

    def failure_triple_given_run(self):
        def listener(*a):
            nonlocal chan, emit, count
            count += 1
            if 1 < count:
                raise Exception('too many emissions')
            *chan, emit = a
            chan = tuple(chan)
        count = 0
        chan = None
        emit = None
        _given = self.given_lines()
        x = _doc_entity_via_lines(_given, listener)
        if 1 != count:
            raise Exception('did not emit')
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


class Case000_empty(_CommonCase):

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


class Case050_all_three_kinds_of_lines(_CommonCase):

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


class Case060_index_gist_collision_in_entity(_CommonCase):

    def test_100_expect_run_failed_to_produce_value(self):
        self.expect_run_failed_to_produce_value()

    def test_200_expect_the_usual_channel(self):
        self.expect_the_usual_channel()

    def test_300_has_the_whole_line(self):
        self.expect_structure_value('line', 'BIFFB-on-ZO10 = 123\n')

    def test_310_does_NOT_have_line_number(self):
        self.expect_no_structure_value('lineno')

    def test_320_has_position(self):
        self.expect_structure_value('position', 13)

    def test_330_has_expecting(self):
        self.expect_structure_value('expecting', 'available name')

    def test_340_has_reason_that_shows_both_names(self):
        self.expect_structure_value(
                'reason',
                (
                    "new name 'biff-BON-zo-10' too similar to "
                    "existing name 'BIFFB-on-ZO10'"
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


class Case100_append_to_empty(_CommonCase):

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


class Case110_append_to_non_empty(_CommonCase):

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


class Case120_insert_at_head(_CommonCase):

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


class Case130_insert_into_mid(_CommonCase):

    def test_100_test_edit(self):
        self.expect_edit()

    def expect_these_body_lines_AFTER_edit(self):
        return """
        # comment first
        # comment second
        # comment third
        """

    def given_run(self, listener):
        _line = '# comment second\n'
        return self.given_run_inserting_before_offset(_line, 1, listener)

    def given_lines(self):
        return unindent("""
        # comment first
        # comment third
        """)


# == DELETES


"""a compuctionary note on test case ordering:

  - (the below is now superseded by [#867] in terms of theoretical rigor,
    however our order here (append, insert, delete) actually concurs with the
    order proferred there (that is, same conclusion for different reasons).)

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
"""


class Case200_delete_at_head_to_make_non_empty(_CommonCase):

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


class Case210_delete_from_mid_to_make_non_empty(_CommonCase):

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
        # line 2
        # line 3
        """)


class Case230_delete_from_tail_to_make_non_empty(_CommonCase):

    def test_100_test_edit(self):
        self.expect_edit()

    def expect_these_body_lines_AFTER_edit(self):
        return """
        # line 1
        # line 2
        """

    def given_run(self, listener):
        return self.given_run_deleting_at_offset(2, listener)

    def given_lines(self):
        return unindent("""
        # line 1
        # line 2
        # line 3
        """)


class Case240_delete_to_make_empty(_CommonCase):

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


def _internal_identifer_via_body_line_offset(offset, mde):

    i = -1
    for iid in mde._LL.TO_IID_STREAM():
        i += 1
        if offset == i:
            found_iid = iid
            break

    return found_iid  # will raise UnboundLocalError if not found shrug


def _doc_entity_via_lines(given, listener=None):
    return _subject_module().mutable_document_entity_via_identifer_and_body_lines(  # noqa: E501
            given, 'A', 'meta', listener)


def _body_line_gen(mde):
    for lo in mde._LL.to_item_stream():
        yield lo.line


def _subject_module():
    from kiss_rdb.magnetics_ import entity_via_open_table_line_and_body_lines as _  # noqa: E501
    return _


def cover_me():
    raise Exception('cover me')


if __name__ == '__main__':
    unittest.main()

# #born.
