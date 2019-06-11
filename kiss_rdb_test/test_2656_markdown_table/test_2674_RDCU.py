from kiss_rdb_test.common_initial_state import (
        pretend_file_via_path_and_big_string,
        )
from kiss_rdb_test import storage_adapter_canon
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        memoize,
        )
import unittest


canon = storage_adapter_canon.produce_agent()


class _CommonCase(unittest.TestCase):

    def reason(self):  # must be used with _flush_reason_early
        return self.end_state()['reason']


class Case2606_entity_not_found_because_identifier_too_deep(_CommonCase):

    def test_100_result_is_none(self):
        self._canon_case.confirm_result_is_none(self)

    def test_200_emitted_accordingly(self):
        self._canon_case.confirm_emitted_accordingly(self)

    @shared_subject
    def end_state(self):
        return self._canon_case.build_end_state(self)

    def subject_collection(self):
        return _collection_empty_wont_mutate()

    @property
    def _canon_case(self):
        return canon.case_of_entity_not_found_because_of_too_deep_identifier


class Case2609_entity_not_found(_CommonCase):

    def test_100_result_is_none(self):
        self._canon_case.confirm_result_is_none(self)

    def test_200_emitted_accordingly(self):
        self._canon_case.confirm_emitted_accordingly(self)

    @shared_subject
    def end_state(self):
        return self._canon_case.build_end_state(self)

    def subject_collection(self):
        return _collection_ordinary_wont_mutate()

    @property
    def _canon_case(self):
        return canon.case_of_entity_not_found


class Case2641_delete_but_entity_not_found(_CommonCase):

    def test_100_result_is_none(self):
        self._canon_case.confirm_result_is_none(self)

    def test_200_emitted_accordingly(self):
        self._canon_case.confirm_emitted_accordingly(self)

    @shared_subject
    def end_state(self):
        return self._canon_case.build_end_state(self)

    def subject_collection(self):
        return _collection_ordinary_will_mutate()  # but actually won't

    @property
    def _canon_case(self):
        return canon.case_of_delete_but_entity_not_found


class Case2644_delete_OK_resulting_in_non_empty_collection(_CommonCase):

    def test_100_result_is_the_deleted_entity(self):
        self._canon_case.confirm_result_is_the_deleted_entity(self)

    def test_200_emitted_accordingly(self):
        self._canon_case.confirm_emitted_accordingly(self)

    def test_300_now_collection_doesnt_have_that_entity(self):
        self._canon_case.confirm_entity_no_longer_in_collection(self)

    def CONFIRM_THIS_LOOKS_LIKE_THE_DELETED_ENTITY(self, ent):
        dct = canon.yes_value_dictionary_of(ent)
        self.assertEqual(dct['thing-A'], "hi i'm B9H")
        self.assertEqual(dct['thing-B'], "hey i'm B9H")
        self.assertEqual(len(dct), 2)

    @shared_subject
    def end_state(self):
        return self._canon_case.build_end_state_for_delete(self, 'B9H')

    def subject_collection(self):
        return _collection_ordinary_will_mutate()

    @property
    def _canon_case(self):
        return canon.case_of_delete_OK_resulting_in_non_empty_collection


class Case2647_delete_OK_resulting_in_empty_collection(_CommonCase):

    def test_100_result_is_the_deleted_entity(self):
        self._canon_case.confirm_result_is_the_deleted_entity(self)

    def test_200_emitted_accordingly(self):
        self._canon_case.confirm_emitted_accordingly(self)

    def test_300_the_collection_is_empty_afterwards(self):
        self._canon_case.confirm_the_collection_is_empty(self)

    def CONFIRM_THIS_LOOKS_LIKE_THE_DELETED_ENTITY(self, ent):
        dct = canon.yes_value_dictionary_of(ent)
        self.assertEqual(dct['thing-1'], 'xx')
        self.assertEqual(dct['thing-A'], 'zz')
        self.assertEqual(len(dct), 2)

    @shared_subject
    def end_state(self):
        return self._canon_case.build_end_state_for_delete(self, 'B9K')

    def subject_collection(self):
        return _collection_of_one_entity_will_mutate()

    @property
    def _canon_case(self):
        return canon.case_of_delete_OK_resulting_in_empty_collection


class Case2676_create_but_something_is_invalid(_CommonCase):

    def test_100_result_is_none(self):
        self._canon_case.confirm_result_is_none(self)

    def test_200_emitted_accordingly(self):
        self._canon_case.confirm_emitted_accordingly(self)

    def CONFIRM_THE_REASON_SAYS_WHAT_IS_WRONG_WITH_IT(self, reason):
        self.assertIn("the field 'thing-C' does not appear", reason)

    def test_600_also_says_table_name(self):
        self.assertIn(' in "table uno"', self.reason())

    def test_620_also_says_path_name(self):
        self.assertIn('n pretend-file/2536-for-ID-traversal.md', self.reason())

    def test_640_also_says_line_number(self):
        self.assertEqual(self.reason()[-11:], 'versal.md:2')

    @shared_subject
    def end_state(self):
        return _flush_reason_early(self._canon_case.build_end_state(self))

    def dictionary_for_create_with_something_invalid_about_it(self):
        return {
                'thing-1': 123.45,
                'thing-A': True,
                'thing-C': 'false',
                }

    def subject_collection(self):
        return _collection_ordinary_wont_mutate()

    @property
    def _canon_case(self):
        return canon.case_of_create_but_something_is_invalid


class Case2679_create_OK_into_empty_collection(_CommonCase):

    def test_100_result_is_created_entity(self):
        self._canon_case.confirm_result_is_the_created_entity(self)

    def test_200_emitted_accordingly(self):
        self._canon_case.confirm_emitted_accordingly(self)

    def test_300_now_collection_doesnt_have_that_entity(self):
        self._canon_case.confirm_entity_now_in_collection(self)

    @shared_subject
    def end_state(self):
        return self._canon_case.build_end_state(self)

    def subject_collection(self):
        return _collection_empty_will_mutate()

    @property
    def _canon_case(self):
        return canon.case_of_create_OK_into_empty_collection


class Case2682_create_OK_into_non_empty_collection(_CommonCase):

    def test_100_result_is_created_entity(self):
        self._canon_case.confirm_result_is_the_created_entity(self)

    def test_200_emitted_accordingly(self):
        self._canon_case.confirm_emitted_accordingly(self)

    def test_300_now_collection_doesnt_have_that_entity(self):
        self._canon_case.confirm_entity_now_in_collection(self)

    @shared_subject
    def end_state(self):
        return self._canon_case.build_end_state(self)

    def subject_collection(self):
        return _collection_ordinary_will_mutate()

    @property
    def _canon_case(self):
        return canon.case_of_create_OK_into_non_empty_collection


class Case2710_update_but_entity_not_found(_CommonCase):

    def test_100_result_is_none(self):
        self._canon_case.confirm_result_is_none(self)

    def test_200_emitted_accordingly(self):
        self._canon_case.confirm_emitted_accordingly(self)

    def test_600_reason_contains_number_of_lines(self):
        self.assertIn('(searched 3 line(s))', self.reason())

    @shared_subject
    def end_state(self):
        return _flush_reason_early(self._canon_case.build_end_state(self))

    def request_tuple_for_update_that_will_fail_because_no_ent(self):
        return 'NSE', (('for_now_make_this_bad', 'while-it', 'works'),)

    def subject_collection(self):
        return _collection_ordinary_wont_mutate()

    @property
    def _canon_case(self):
        return canon.case_of_update_but_entity_not_found


class Case2713_update_but_attribute_not_found(_CommonCase):

    def test_100_result_is_none(self):
        self._canon_case.confirm_result_is_none(self)

    def test_200_emitted_accordingly(self):
        self._canon_case.confirm_emitted_accordingly(self)

    @shared_subject
    def end_state(self):
        return self._canon_case.build_end_state(self)

    def request_tuple_for_update_that_will_fail_because_attr(self):
        return 'B9H', (
                ('update_attribute', 'thing-1', 'no see'),
                )

    def subject_collection(self):
        return _collection_ordinary_wont_mutate()

    @property
    def _canon_case(self):
        return canon.case_of_update_but_attribute_not_found


class Case2716_update_OK(_CommonCase):

    def test_100_result_is_a_two_tuple_of_before_and_after_entities(self):
        self._canon_case.confirm_result_is_before_and_after_entities(self)

    def test_200_the_before_entity_has_the_before_values(self):
        self._canon_case.confirm_the_before_entity_has_the_before_values(self)

    def test_300_the_after_entity_has_the_after_values(self):
        self._canon_case.confirm_the_after_entity_has_the_after_values(self)

    def test_400_emitted_accordingly(self):
        self._canon_case.confirm_emitted_accordingly(self)

    def test_500_retrieve_afterwards_shows_updated_value(self):
        self._canon_case.confirm_retrieve_after_shows_updaed_value(self)

    """
    given:

        | i De nTi Fier zz | thing 1  | thing-2 | Thing_A |thing-B|    hi-G|
        |  B9H ||   | hi i'm B9H | hey i'm B9H

    and:    'B9H', (('delete_attribute', 'thing-A'),
                    ('update_attribute', 'thing-B', "hello I'm etc"),
                    ('create_attribute', 'thing-2', 'xx yy'))

    expect these:
      - identifier cel is exactly unchanged (that extra space)
      - thing-1 unchanged (zero width)
      - thing-2 gets created and does *not* inherit those 3 spaces of pad
      - thing-A ("hi i'm..") gets deleted, new cel is zero width
      - thing-B  DOES OR DOES NOT inherit the leading padding
      - the final cel ("hi-G") still isn't present (delimited)
      - still no trailng pipe
    """

    def test_531_padding_of_ID_cel_surface_is_unchanged(self):
        s = self.cel_at(0)
        self.assertEqual(s, '  B9H ')

    def test_594_field_one_is_still_zero_width(self):
        s = self.cel_at(1)
        self.assertEqual(s, '')

    def test_656_field_two_is_created_and_clobbers_the_weird_padding(self):
        s = self.cel_at(2)
        self.assertEqual(s, ' xx yy ')

    def test_719_deleted_cel_is_now_zero_width(self):
        s = self.cel_at(3)
        self.assertEqual(s, '')

    def test_781_updating_DOES_inherit_the_leading_padding(self):
        s = self.cel_at(4)
        exp = "  hello I'm etc"
        self.assertEqual(s.index(exp), 0)

    def test_844_still_no_trailing_pipe(self):
        line = self.my_custom_index()['the_whole_line']
        last_two = line[-2:]
        self.assertEqual(last_two[1], '\n')  # ..
        self.assertNotEqual(last_two[0], '|')

    def test_906_that_final_cel_still_isnt_present(self):
        line = self.my_custom_index()['the_whole_line']
        import re
        import functools
        _count_me = re.findall(r'\|', line)
        _num = functools.reduce(lambda m, x: m + 1, _count_me, 0)
        self.assertEqual(_num, 5)

    def test_969_no_trailing_whitespace_because_no_trailing_pipe(self):
        s = self.cel_at(4)
        exp = "hello I'm etc"
        act = s[-len(exp):]
        self.assertEqual(act, exp)

    def cel_at(self, i):
        return self.my_custom_index()['cels'][i]

    @shared_subject
    def my_custom_index(self):
        coll = self.end_state()['collection']
        _lines = coll._implementation._entity_lines
        line = _lines[1]
        import re
        md = re.match(r'^\|((?:[^|\n]*\|){4}[^|\n]*)', line)

        """With this much we are comfortable asserting here in the set-up:
        assert the existence of but do not capture the leading pipe,
        then four times of zero-or-more-not-pipes-then-a-pipe,
        and then as many non-pipes as you can after it. This isolates the
        parts of the production we are sure about from the parts we test.
        """

        cels = md[1].split('|')
        assert(5 == len(cels))

        return {
                'the_whole_line': line,
                'cels': cels,
                }

    @shared_subject
    def end_state(self):
        return self._canon_case.build_end_state(self)

    def request_tuple_for_update_that_will_succeed(self):
        return 'B9H', (('delete_attribute', 'thing-A'),
                       ('update_attribute', 'thing-B', "hello I'm etc"),
                       ('create_attribute', 'thing-2', 'xx yy'))

    def subject_collection(self):
        return _collection_ordinary_will_mutate()

    @property
    def _canon_case(self):
        return canon.case_of_update_OK


def _flush_reason_early(es):
    sct = es['payloader_CAUTION_HOT']()  # see in storage_adapter_canon
    es['payloader_CAUTION_HOT'] = lambda: sct
    es['reason'] = sct['reason']
    return es


@memoize
def _collection_ordinary_wont_mutate():
    return _collection_ordinary_will_mutate().FREEZE_HACK()


def _collection_ordinary_will_mutate():

    # making this line up with the legacy collection perfectly is tricky
    # because in non-tabular formats, adding an arbitrary field to an
    # arbitrary entity is cheap and easy, but tables are .. tabular. SO:
    # here we have added *one* of the ad-hoc fields to test a thing
    # (to get more num_fields than num_original_cels)

    return _build_collection_via_path_and_big_string(
        'pretend-file/2536-for-ID-traversal.md',
        """
        # table uno
        | i De nTi Fier zz | thing 1  | thing-2 | Thing_A |thing-B|    hi-G|
        |---|---|---
        | B9G
        |  B9H ||   | hi i'm B9H |  hey i'm B9H
        | B9K
        """)
    # 👉 these three 'B9G', 'B9H', 'B9K' must be as if (12, 13, 15)
    # 👉 leave this identifier out: 'NSE' (for No Such Entity)


def _collection_of_one_entity_will_mutate():
    return _build_collection_via_path_and_big_string(
        'pretend-file/XXXX-one-entity.md',
        """
        | i De nTi Fier zz | thing 1  | thing-2 | Thing_A |thing-B|
        |---|---|---
        | B9K | xx | | zz |
        """)


def _collection_empty_wont_mutate():
    return _collection_empty_will_mutate().FREEZE_HACK()


def _collection_empty_will_mutate():
    return _build_collection_via_path_and_big_string(
        'pretend-file/XXXX-empty-collection.md',
        """
        | i De nTi Fier zz | thing 1  | thing-2 | Thing_A |thing-B| not me |
        |---|---|---
        """)


def _build_collection_via_path_and_big_string(path, big_string):  # #COPY-PASTE
    pfile = pretend_file_via_path_and_big_string(path, big_string)
    from kiss_rdb.storage_adapters_ import markdown_table as lib
    return lib.resolve_collection_via_file(pfile, pfile.path, None)


def do_me():
    raise Exception('do me')


if __name__ == '__main__':
    unittest.main()

# #born.
