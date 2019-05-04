from _common_state import (
        debugging_listener as _debugging_listener,
        unindent as _unindent,
        )
from modality_agnostic.memoization import dangerous_memoize as shared_subject
import unittest


class _CommonCase(unittest.TestCase):

    def _expect_LTACOR(self, how_many, *identifier_strings):
        _actual = _subject_module()._length_of_longest_tail_anchored_contiguous_ordered_run(identifier_strings)  # noqa: E501
        self.assertEqual(_actual, how_many)

    def _same_because_sho_madjozi_not_found_in_entity(self):
        _actual = self._two_parts()[1]
        self.assertEqual(_actual, " because 'sho-madjozi' not found in entity")

    def _same_suggestion_use_this_one_not_that_one(self):
        _actual = self._three_parts()[2]
        self.assertEqual(_actual, "use 'SHO-madjozi' not 'sho-madjozi'")

    def _same_because_reason_exact_match(self):
        _actual = self._three_parts()[1]
        self.assertEqual(_actual, ' because names must match exactly')

    def expect_reason(self, msg=None):

        chan, sct = self.expect_error_structure()
        self.assertEqual(chan, ('error', 'structure', 'request_error'))  # ..
        reason = sct['reason']
        if msg is None:
            return reason
        else:
            self.assertEqual(reason, msg)

    def expect_error_structure(self):

        count = 0
        chan = None
        emit = None

        def listener(*a):
            nonlocal count
            count += 1
            if 1 < count:
                raise Exception('had more than one emission')
            nonlocal chan
            nonlocal emit
            *chan, emit = a

        x = self.given_run(listener)

        if 1 != count:
            raise Exception('expected emission')

        self.assertIsNone(x)

        chan = tuple(chan)
        sct = emit()
        return (chan, sct)

    def expect_big_success(self):
        listener = None  # _DEBUGGING_LISTENER
        _mde = self.run_CUD_attributes(listener)
        _act = list(o.line for o in _mde.TO_BODY_LINE_OBJECT_STREAM())
        _exp = list(_unindent(self.expect_entity_body_lines()))
        self.assertSequenceEqual(_act, _exp)

    def run_CUD_attributes(self, listener):

        this_listener = None  # _DEBUGGING_LISTENER

        mde = _MDE(self.given_entity_body_lines(), this_listener)
        assert(mde)

        req = _request_via_tuples(self.given_request_tuples(), this_listener)
        assert(req)

        x = req.edit_mutable_document_entity_(mde, listener)
        if x is not None:
            self.assertEqual(x, True)
            return mde

    def _DEBUGGING_LISTENER(self):
        return _debugging_listener()


class Case011_when_request_empty(_CommonCase):

    def test_100_reason(self):
        self.expect_reason('request was empty')

    def given_run(self, listener):
        return _request_via_tuples((), listener)


class Case034_strange_verbs(_CommonCase):

    def test_100_reason(self):
        self.expect_reason('unrecognized verb(s): (fiz, bru-zuz)')

    def given_run(self, listener):
        return _request_via_tuples(
            (('fiz', 'a'), ('delete', 'x'), ('bru-zuz', 'x')), listener)


class Case057_wrong_looking_attribute_name(_CommonCase):

    def test_100_input_error(self):
        chan, sct = self.expect_error_structure()
        self.assertEqual(chan, ('error', 'structure', 'input_error'))
        self.assertEqual(sct['position'], 9)
        self.assertEqual(sct['line'], 'xxe-sesf-')  # ick/meh

    def given_run(self, listener):
        return _request_via_tuples((
            ('create', 'foo-bar', '1'),
            ('create', 'xxe-sesf-', '1'),
            ('create', '^___^', '1'),
            ), listener)


class Case080_duplicate_names_within_request(_CommonCase):

    def test_100_reason(self):
        _actual = self._two_parts()[0]
        self.assertTrue(' more than once ' in _actual)

    def test_200_detail(self):
        _actual = self._two_parts()[1]
        self.assertEqual(_actual, "'foo-bar' appeared twice")

    @shared_subject
    def _two_parts(self):
        _rsn = self.expect_reason()
        return _rsn.split(' and ')

    def given_run(self, listener):
        return _request_via_tuples((
            ('create', 'foo-bar', '1'),
            ('update', 'biz-baz', '1'),
            ('delete', 'foo-bar'),
            ), listener)


class Case102_names_too_similar_within_request(_CommonCase):

    def test_100_reason(self):
        _actual = self._two_parts()[1]
        self.assertTrue(' are too similar ' in _actual)

    def test_200_oxford_AND(self):
        _actual = self._two_parts()[0]
        self.assertEqual(_actual, "'xx-zz', 'xxz-z' and 'xx-ZZ'")

    @shared_subject
    def _two_parts(self):
        _rsn = self.expect_reason()
        return _split_hack(' are ', _rsn)

    def given_run(self, listener):
        return _request_via_tuples((
            ('delete', 'xx-zz'),
            ('delete', 'blink-182'),
            ('delete', 'xxz-z'),
            ('delete', 'xx-ZZ'),
            ), listener)


class Case125_cannot_create_when_attributes_already_exist(_CommonCase):

    def test_100_reason(self):
        _actual = self._right()
        self.assertTrue(' already exist' in _actual)

    def test_200_items(self):
        _actual = self._two_parts()[0]
        _expected = "can't create attribute 'foo-fani'"  # ..
        self.assertEqual(_actual, _expected)

    def test_300_suggestion(self):
        _actual = self._right()
        self.assertTrue(' (use update?)' in _actual)

    def test_400_reason_did_pronoun_and_verb_agreement(self):
        _actual = self._right()
        self.assertTrue(' it already exists ' in _actual)

    def _right(self):
        return self._two_parts()[1]

    @shared_subject
    def _two_parts(self):
        _rsn = self.expect_reason()
        return _split_because_hack(_rsn)

    def given_run(self, listener):
        return self.run_CUD_attributes(listener)

    def given_request_tuples(self):
        return (('create', 'foo-fani', 'x'),)

    def given_entity_body_lines(self):
        return """
        foo-fani = "mum"
        """


class Case148_cannot_delete_because_attributes_not_found(_CommonCase):

    def test_100_reason(self):
        _actual = self._two_parts()[0]
        self.assertEqual(_actual, "can't delete")

    def test_200_detail(self):
        self._same_because_sho_madjozi_not_found_in_entity()

    @shared_subject
    def _two_parts(self):
        _rsn = self.expect_reason()
        return _split_because_hack(_rsn)

    def given_run(self, listener):
        return self.run_CUD_attributes(listener)

    def given_request_tuples(self):
        return (('delete', 'sho-madjozi'),)

    def given_entity_body_lines(self):
        return """
        # comment

        prop-1 = x

        # comment 2
        prop-2 = 123.45
        """


class Case170_cannot_delete_because_attributes_not_exact_match(_CommonCase):

    def test_100_context(self):
        _actual = self._three_parts()[0]
        self.assertEqual(_actual, "can't delete attributes")

    def test_200_reason(self):
        self._same_because_reason_exact_match()

    def test_300_suggestion(self):
        self._same_suggestion_use_this_one_not_that_one()

    @shared_subject
    def _three_parts(self):
        return _same_three_split(self.expect_reason())

    def given_run(self, listener):
        return self.run_CUD_attributes(listener)

    def given_request_tuples(self):
        return (('delete', 'sho-madjozi'),)

    def given_entity_body_lines(self):
        return """
        SHO-madjozi = xx
        """


class Case193_cannot_update_because_attributes_not_found(_CommonCase):

    def test_100_reason(self):
        _actual = self._two_parts()[0]
        self.assertEqual(_actual, "can't update")

    def test_200_detail(self):
        self._same_because_sho_madjozi_not_found_in_entity()

    @shared_subject
    def _two_parts(self):
        _rsn = self.expect_reason()
        return _split_because_hack(_rsn)

    def given_run(self, listener):
        return self.run_CUD_attributes(listener)

    def given_request_tuples(self):
        return (('update', 'sho-madjozi', 'q'),)

    def given_entity_body_lines(self):
        return """
        aa = bb
        """


class Case216_cannot_update_because_attributes_not_exact_match(_CommonCase):

    def test_100_context(self):
        _actual = self._three_parts()[0]
        self.assertEqual(_actual, "can't update attributes")

    def test_200_reason(self):
        self._same_because_reason_exact_match()

    def test_300_suggestion(self):
        self._same_suggestion_use_this_one_not_that_one()

    @shared_subject
    def _three_parts(self):
        return _same_three_split(self.expect_reason())

    def given_run(self, listener):
        return self.run_CUD_attributes(listener)

    def given_request_tuples(self):
        return (('update', 'sho-madjozi', 'q'),)

    def given_entity_body_lines(self):
        return """
        SHO-madjozi = xx
        """


class Case239_cannot_delete_because_comment_line_above(_CommonCase):

    def test_100_unable_says_verb_and_name_of_attribute(self):
        _actual = self._two_parts()[0]
        self.assertEqual(_actual, "cannot delete 'ab-fab' attribute line")

    def test_200_reason_explains_line_above(self):
        _actual = self._two_parts()[1]
        self.assertEqual(_actual, 'line touches comment line above')

    @shared_subject
    def _two_parts(self):
        return self.expect_reason().split(' because ')

    def given_run(self, listener):
        return self.run_CUD_attributes(listener)

    def given_request_tuples(self):
        return (('delete', 'ab-fab'),)

    def given_entity_body_lines(self):
        return """
        chab-tab = 123
        # comment line above
        ab-fab = 123
        """


class Case261_cannot_update_because_comment_line_below(_CommonCase):

    def test_100_unable_says_verb_and_name_of_attribute(self):
        _actual = self._two_parts()[0]
        self.assertEqual(_actual, "cannot update 'ab-fab' attribute line")

    def test_200_reason_explains_line_below(self):
        _actual = self._two_parts()[1]
        self.assertEqual(_actual, 'line touches comment line below')

    @shared_subject
    def _two_parts(self):
        return self.expect_reason().split(' because ')

    def given_run(self, listener):
        return self.run_CUD_attributes(listener)

    def given_request_tuples(self):
        return (('update', 'ab-fab', 'qq'),)

    def given_entity_body_lines(self):
        return """
        chab-tab = 123
        ab-fab = 456
        # comment line below
        """


class Case284_cannot_update_because_attribute_line_has_comment(_CommonCase):

    def test_100_unable(self):
        _actual = self._two_parts()[0]
        self.assertEqual(_actual, "cannot update 'ab-fab' attribute line")

    def test_200_reason_uses_pronoun_with_antecedent(self):
        _actual = self._two_parts()[1]
        self.assertEqual(_actual, 'it has comment')

    @shared_subject
    def _two_parts(self):
        return self.expect_reason().split(' because ')

    def given_run(self, listener):
        return self.run_CUD_attributes(listener)

    def given_request_tuples(self):
        return (('update', 'ab-fab', 'qq'),)

    def given_entity_body_lines(self):
        return """
        ab-fab = 124  # it's 124 because qq
        """


class Case307_aggregate_multiple_comment_based_failures(_CommonCase):

    def test_100_broken_up_into_two_sentences(self):
        self.assertEqual(len(self._two_sentences()), 2)

    def test_100_reason(self):
        _actual = self._two_sentences()[1]

        _expected = (
            "cannot delete 'ab-fab-2' attribute line "
            "because line touches comment line above and below "
            "and because it has comment")

        self.assertEqual(_actual, _expected)

    @shared_subject
    def _two_sentences(self):
        return self.expect_reason().split('. ')

    def given_run(self, listener):
        return self.run_CUD_attributes(listener)

    def given_request_tuples(self):
        return (('delete', 'ab-fab-1'),
                ('delete', 'ab-fab-2'))

    def given_entity_body_lines(self):
        return """
        ab-fab-1 = 123
        # comment line causes 2x trouble
        ab-fab-2 = 123  # in-line comment
        # comment line final
        """


class Case330_cannot_create_because_comment_line_above(_CommonCase):

    def test_100_produces_two_sentences(self):
        self.assertIsNotNone(self._two_sentences())

    def test_200_first_sentence_says_first_component_of_first_group(self):
        return self._same(0, 'dd-dd')

    def test_300_second_sentence_says_only_component_of_second_group(self):
        return self._same(1, 'hh-hh')

    def _same(self, sp_i, id_s):
        _expected = (f"cannot create '{id_s}' attribute line because "
                     "line touches comment line above")
        _actual = self._two_sentences()[sp_i]
        self.assertEqual(_actual, _expected)

    @shared_subject
    def _two_sentences(self):
        _ = self.expect_reason()
        sp1, sp2 = _.split('. ')
        return (sp1, sp2)

    def given_run(self, listener):
        return self.run_CUD_attributes(listener)

    def given_request_tuples(self):
        return (('create', 'dd-dd', '123'),
                ('create', 'ee-ee', '123'),
                ('create', 'hh-hh', '123'),
                )

    def given_entity_body_lines(self):
        # perhaps just visually:
        # 1) make sure both "comment M-C" get swepped up in the excerpt
        # 2) see how a bundle can be made with two
        # 3) see how a possible insertion point is passed over (ff-ff/gg-gg)
        return """
        aa-aa = 123
        bb-bb = 123
        mm-mm = 123
        # comment M-C one
        # comment M-C two
        cc-cc = 123
        # comment C-F
        ff-ff = 123
        gg-gg = 123
        # comment F-I
        ii-ii = 123
        """


class Case352_can_update_idk(_CommonCase):

    def test_100_something(self):
        self.expect_big_success()

    def expect_entity_body_lines(self):
        return """
        thing-1 = 123
        thing-2 = 789
        """

    def given_request_tuples(self):
        return (('update', 'thing-2', 789),)

    def given_entity_body_lines(self):
        return """
        thing-1 = 123
        thing-2 = 456
        """


class Case375_can_delete(_CommonCase):

    def test_100_something(self):
        self.expect_big_success()

    def expect_entity_body_lines(self):
        return """
        thing-1 = 123
        # comment

        """

    def given_request_tuples(self):
        return (('delete', 'thing-2'),)

    def given_entity_body_lines(self):
        return """
        thing-1 = 123
        # comment

        thing-2 = 456
        """

# (available: 398)


class Case404_can_create_when_comment_line_at_tail(_CommonCase):

    def test_100_something(self):
        self.expect_big_success()

    def expect_entity_body_lines(self):
        return """
        aa-aa = 123
        bb-bb = 123
        mm-mm = 123
        # comment M-C one
        # comment M-C two
        cc-cc = 123
        dd-dd = 123
        ee-ee = "123"
        ff-ff = 123
        gg-gg = 123
        # comment at end of things

        hh-hh = 123.0
        """

    def given_request_tuples(self):
        return (('create', 'dd-dd', 123),
                ('create', 'ee-ee', '123'),
                ('create', 'hh-hh', 123.0),
                )

    def given_entity_body_lines(self):
        return """
        aa-aa = 123
        bb-bb = 123
        mm-mm = 123
        # comment M-C one
        # comment M-C two
        cc-cc = 123
        ff-ff = 123
        gg-gg = 123
        # comment at end of things
        """


class Case443_can_create_when_comment_line_at_head_of_excerpt(_CommonCase):

    def test_100_something(self):
        self.expect_big_success()

    def expect_entity_body_lines(self):
        return """
        bb-bb = 123
        cc-cc = 123

        # head comment 1
        # head comment 2
        dd-dd = 123
        ee-ee = 123
        ff-ff = 123
        """

    def given_request_tuples(self):
        return (('create', 'bb-bb', 123),
                ('create', 'cc-cc', 123))

    def given_entity_body_lines(self):
        return """
        # head comment 1
        # head comment 2
        dd-dd = 123
        ee-ee = 123
        ff-ff = 123
        """


class Case466_create_into_truly_empty(_CommonCase):

    def test_100_note_it_gets_ordered(self):
        self.expect_big_success()

    def expect_entity_body_lines(self):
        return """
        bb-bb = 123
        cc-cc = 456
        """

    def given_request_tuples(self):
        return (('create', 'cc-cc', 456),
                ('create', 'bb-bb', 123))

    def given_entity_body_lines(self):
        return """
        """


class Case489_create_into_empty_with_comments(_CommonCase):

    def test_100_note_it_gets_ordered(self):
        self.expect_big_success()

    def expect_entity_body_lines(self):
        return """
        # comment 1
        # comment 2

        bb-bb = 123
        cc-cc = 456
        """

    def given_request_tuples(self):
        return (('create', 'cc-cc', 456),
                ('create', 'bb-bb', 123))

    def given_entity_body_lines(self):
        return """
        # comment 1
        # comment 2
        """


def _same_three_split(reason):
    left, rest = _split_because_hack(reason)
    mid, right = rest.split('. ')
    return (left, mid, right)


def _split_because_hack(reason):
    return _split_hack(' because ', reason)


def _split_hack(sep, reason):
    left, right = reason.split(sep)
    return (left, f'{ sep }{ right }')  # ick/meh


def _request_via_tuples(tuples, listener):
    return _ancilliary_subject_module().request_via_tuples(tuples, listener)


def _MDE(entity_body_lines_big_string, lstn):
    from kiss_rdb.magnetics_ import blocks_via_file_lines as _
    _line_gen = _unindent(entity_body_lines_big_string)
    return _.mutable_document_entity_via_identifer_and_body_lines(
            _line_gen, 'A', 'meta', lstn)


def _subject_module():
    from kiss_rdb.magnetics_ import CUD_attributes_via_request as _
    return _


def _ancilliary_subject_module():
    from kiss_rdb.magnetics_ import CUD_attributes_request_via_tuples as _
    return _


def cover_me():
    raise Exception('cover me')


if __name__ == '__main__':
    unittest.main()

# #born.
