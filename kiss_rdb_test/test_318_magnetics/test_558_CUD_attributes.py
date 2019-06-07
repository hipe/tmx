import _common_state  # noqa: F401
from kiss_rdb_test import CUD as CUD_support
from modality_agnostic.memoization import dangerous_memoize as shared_subject
import unittest


class _CommonCase(CUD_support.CUD_BIG_SUCCESS_METHODS, unittest.TestCase):

    def _same_because_sho_madjozi_not_found_in_entity(self):
        _actual = self._two_parts()[1]
        self.assertEqual(_actual, " because 'sho-madjozi' not found in entity")

    def _same_suggestion_use_this_one_not_that_one(self):
        _actual = self._three_parts()[2]
        self.assertEqual(_actual, "use 'SHO-madjozi' not 'sho-madjozi'")

    def _same_because_reason_exact_match(self):
        _actual = self._three_parts()[1]
        self.assertEqual(_actual, ' because names must match exactly')


class Case405_011_when_request_empty(_CommonCase):

    def test_100_reason(self):
        self.expect_reason('request was empty')

    def given_run(self, listener):
        return _request_via_tuples((), listener)


class Case405_034_strange_verbs(_CommonCase):

    def test_100_reason(self):
        self.expect_reason('unrecognized verb(s): (fiz, bru-zuz)')

    def given_run(self, listener):
        return _request_via_tuples(
            (('fiz', 'a'), ('delete', 'x'), ('bru-zuz', 'x')), listener)


class Case405_057_wrong_looking_attribute_name(_CommonCase):

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


class Case405_080_duplicate_names_within_request(_CommonCase):

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


class Case405_102_names_too_similar_within_request(_CommonCase):

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


class Case405_125_cannot_create_when_attributes_already_exist(_CommonCase):

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

    def given_request_tuples(self):
        return (('create', 'foo-fani', 'x'),)

    def given_entity_body_lines(self):
        return """
        foo-fani = "mum"
        """


class Case405_148_cannot_delete_because_attributes_not_found(_CommonCase):

    def test_100_reason(self):
        _actual = self._two_parts()[0]
        self.assertEqual(_actual, "can't delete")

    def test_200_detail(self):
        self._same_because_sho_madjozi_not_found_in_entity()

    @shared_subject
    def _two_parts(self):
        _rsn = self.expect_reason()
        return _split_because_hack(_rsn)

    def given_request_tuples(self):
        return (('delete', 'sho-madjozi'),)

    def given_entity_body_lines(self):
        return """
        # comment

        prop-1 = x

        # comment 2
        prop-2 = 123.45
        """


class Case405_170_cannot_delete_because_attributes_not_exact_match(_CommonCase):  # noqa: E501

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

    def given_request_tuples(self):
        return (('delete', 'sho-madjozi'),)

    def given_entity_body_lines(self):
        return """
        SHO-madjozi = xx
        """


class Case405_193_cannot_update_because_attributes_not_found(_CommonCase):

    def test_100_reason(self):
        _actual = self._two_parts()[0]
        self.assertEqual(_actual, "can't update")

    def test_200_detail(self):
        self._same_because_sho_madjozi_not_found_in_entity()

    @shared_subject
    def _two_parts(self):
        _rsn = self.expect_reason()
        return _split_because_hack(_rsn)

    def given_request_tuples(self):
        return (('update', 'sho-madjozi', 'q'),)

    def given_entity_body_lines(self):
        return """
        aa = bb
        """


class Case405_216_cannot_update_because_attributes_not_exact_match(_CommonCase):  # noqa: E501

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

    def given_request_tuples(self):
        return (('update', 'sho-madjozi', 'q'),)

    def given_entity_body_lines(self):
        return """
        SHO-madjozi = xx
        """


class Case405_239_cannot_delete_because_comment_line_above(_CommonCase):

    def test_100_unable_says_verb_and_name_of_attribute(self):
        _actual = self._two_parts()[0]
        self.assertEqual(_actual, "cannot delete 'ab-fab' attribute line")

    def test_200_reason_explains_line_above(self):
        _actual = self._two_parts()[1]
        self.assertEqual(_actual, 'line touches comment line above')

    @shared_subject
    def _two_parts(self):
        return self.expect_reason().split(' because ')

    def given_request_tuples(self):
        return (('delete', 'ab-fab'),)

    def given_entity_body_lines(self):
        return """
        chab-tab = 123
        # comment line above
        ab-fab = 123
        """


class Case405_261_cannot_update_because_comment_line_below(_CommonCase):

    def test_100_unable_says_verb_and_name_of_attribute(self):
        _actual = self._two_parts()[0]
        self.assertEqual(_actual, "cannot update 'ab-fab' attribute line")

    def test_200_reason_explains_line_below(self):
        _actual = self._two_parts()[1]
        self.assertEqual(_actual, 'line touches comment line below')

    @shared_subject
    def _two_parts(self):
        return self.expect_reason().split(' because ')

    def given_request_tuples(self):
        return (('update', 'ab-fab', 'qq'),)

    def given_entity_body_lines(self):
        return """
        chab-tab = 123
        ab-fab = 456
        # comment line below
        """


class Case405_284_cannot_update_because_attribute_line_has_comment(_CommonCase):  # noqa: E501

    def test_100_unable(self):
        _actual = self._two_parts()[0]
        self.assertEqual(_actual, "cannot update 'ab-fab' attribute line")

    def test_200_reason_uses_pronoun_with_antecedent(self):
        _actual = self._two_parts()[1]
        self.assertEqual(_actual, 'it has comment')

    @shared_subject
    def _two_parts(self):
        return self.expect_reason().split(' because ')

    def given_request_tuples(self):
        return (('update', 'ab-fab', 'qq'),)

    def given_entity_body_lines(self):
        return """
        ab-fab = 124  # it's 124 because qq
        """


class Case405_307_aggregate_multiple_comment_based_failures(_CommonCase):

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


class Case405_330_cannot_create_because_comment_line_above(_CommonCase):

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


class Case405_352_can_update_idk(_CommonCase):

    # this almost touches #multi-line

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


class Case405_375_can_delete(_CommonCase):

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


class Case405_404_can_create_when_comment_line_at_tail(_CommonCase):

    # this tests for #multi-line but is not

    def test_100_everything(self):
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


class Case405_443_can_create_when_comment_line_at_head_of_excerpt(_CommonCase):

    def test_100_everything(self):
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


class Case405_466_create_into_truly_empty(_CommonCase):

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


class Case405_489_create_into_empty_with_comments(_CommonCase):

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


def _request_via_tuples(aa, bb):
    return CUD_support.request_via_tuples(aa, bb)


# ==

def _subject_module():
    from kiss_rdb.magnetics_ import CUD_attributes_via_request as _
    return _


def cover_me():
    raise Exception('cover me')


if __name__ == '__main__':
    unittest.main()


# #history-A.1: begin small changes for big overhaul for multi-line strings
# #born.