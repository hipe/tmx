from kiss_rdb_test.markdown_storage_adapter import \
        collection_via_resource
from kiss_rdb_test.storage_adapter_canon import \
        produce_agent as produce_storage_adapter_canon_agent
from kiss_rdb_test.common_initial_state import \
        pretend_resource_and_controller_via_KV_pairs
from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subj_in_children, \
        dangerous_memoize as shared_subject
import unittest
import re


canon = produce_storage_adapter_canon_agent()


class CommonCase(unittest.TestCase):

    # == Assertion components

    def reason(self):  # must be used with _flush_reason_early
        return self.end_state['reason']

    def build_file_patch(self):
        lines = self.end_state['diff_lines']
        from text_lib.diff_and_patch import \
            file_patches_via_unified_diff_lines as func
        file_patch, = tuple(func(lines))
        return file_patch

    # == Build End state

    @property
    @shared_subj_in_children
    def end_state(self):
        fh, done = self.build_collection_resource_and_done()

        self.collection = collection_via_resource(fh)

        es = self.given_run()

        if self.do_flush_reason_early:
            _flush_reason_early(es)  # not sure if still nec

        if done:
            done(self)

        if self.is_expecting_diff_lines:
            # #provision [#857.8] [#857.10] [#857.11]
            es['diff_lines'] = tuple(es['result_value'].diff_lines)  # ..

        return es

    def given_run(self):
        return self.canon_case.build_end_state(self)

    def given_collection(self):
        x = self.collection
        del self.collection
        return x

    def build_collection_resource_and_done(self):
        itr = self.given_collection_via()
        fh, mc = pretend_resource_and_controller_via_KV_pairs(itr)
        return fh, (mc and mc.done)

    @property
    def canon_case(self):
        return self.target_canon_case()

    is_expecting_diff_lines = False
    do_flush_reason_early = False
    do_debug = False


# (Case2606) not found because too deep gone b.c freeform idens #history-B.4


class Case2609_entity_not_found(CommonCase):

    def test_100_result_is_none(self):
        self.canon_case.confirm_result_is_none(self)

    def test_200_emitted_accordingly(self):
        self.canon_case.confirm_emitted_accordingly(self)

    def given_identifier_string(self):
        return 'AB2'

    def given_collection_via(self):
        yield 'pretend_file', pretend_file_ordinary

    def target_canon_case(self):
        return canon.case_of_entity_not_found


class Case2612_retrieve_OK(CommonCase):

    def test_100_the_entity_is_retrieved_and_looks_OK(self):
        self.canon_case.confirm_entity_is_retrieved_and_looks_ok(self)

    def given_identifier_string(self):
        return 'B9H'

    def given_collection_via(self):
        yield 'pretend_file', pretend_file_ordinary

    def target_canon_case(self):
        return canon.case_of_retrieve_OK


class Case2641_delete_but_entity_not_found(CommonCase):

    def test_100_result_is_none(self):
        self.canon_case.confirm_result_is_none(self)

    def test_200_emitted_accordingly(self):
        self.canon_case.confirm_emitted_accordingly(self)

    def given_collection_via(self):
        yield 'pretend_file', pretend_file_ordinary
        yield 'pretend_writable', True

    def given_identifier_string(self):
        return 'AB2'

    def target_canon_case(self):
        return canon.case_of_delete_but_entity_not_found


class Case2644_delete_OK_resulting_in_non_empty_collection(CommonCase):

    def test_100_result_is_a_custom_structure(self):
        self.canon_case.confirm_result_is_the_structure_for_delete(self)

    def test_200_emitted_accordingly(self):
        self.canon_case.confirm_emitted_accordingly(self)

    def test_300_now_collection_doesnt_have_that_entity(self):
        # self.canon_case.confirm_entity_no_longer_in_collection(self)
        fp = self.build_file_patch()  # one file patch
        hunk, = fp.hunks  # with one hunk
        run, = hunk.to_remove_lines_runs()  # with one run of removed lines
        line, = run.lines  # with one line
        self.assertEqual(line, "-|  B9H ||   | hi i'm B9H |  hey i'm B9H\n")

    def CONFIRM_THIS_LOOKS_LIKE_THE_DELETED_ENTITY(self, ent):
        dct = canon.yes_value_dictionary_of(ent)
        self.assertEqual(dct['thing_A'], "hi i'm B9H")
        self.assertEqual(dct['thing_B'], "hey i'm B9H")

        # #provision [#857.9] for now, maybe EID is included, maybe not
        # self.assertEqual(len(dct), 2)

    def given_run(self):
        return self.canon_case.build_end_state_for_delete(self, 'B9H')

    def given_collection_via(self):
        yield 'pretend_file', pretend_file_ordinary
        yield 'pretend_writable', True

    def target_canon_case(self):
        return canon.case_of_delete_OK_resulting_in_non_empty_collection

    is_expecting_diff_lines = True


class Case2647_delete_OK_resulting_in_empty_collection(CommonCase):

    def test_100_result_is_a_custom_structure(self):
        self.canon_case.confirm_result_is_the_structure_for_delete(self)

    def test_200_emitted_accordingly(self):
        self.canon_case.confirm_emitted_accordingly(self)

    def test_300_the_collection_is_empty_afterwards(self):
        # self.canon_case.confirm_the_collection_is_empty(self)
        fp = self.build_file_patch()  # one file patch
        hunk, = fp.hunks  # with one hunk
        run, = hunk.to_remove_lines_runs()  # with one run of removed lines
        line, = run.lines  # with one line
        self.assertEqual(line, "-| B9K | xx | | zz |\n")

    def CONFIRM_THIS_LOOKS_LIKE_THE_DELETED_ENTITY(self, ent):
        dct = canon.yes_value_dictionary_of(ent)
        self.assertEqual(dct['thing_1'], 'xx')
        self.assertEqual(dct['thing_A'], 'zz')

        # #provision [#857.9] for now, maybe EID is included, maybe not
        # self.assertEqual(len(dct), 2)

    def given_run(self):
        return self.canon_case.build_end_state_for_delete(self, 'B9K')

    def given_collection_via(self):
        yield 'pretend_file', pretend_file_one_entity
        yield 'pretend_writable', True

    def target_canon_case(self):
        return canon.case_of_delete_OK_resulting_in_empty_collection

    is_expecting_diff_lines = True


class Case2676_create_but_something_is_invalid(CommonCase):

    def test_100_result_is_none(self):
        self.canon_case.confirm_result_is_none(self)

    def test_200_emitted_accordingly(self):
        self.canon_case.confirm_emitted_accordingly(self)

    def CONFIRM_THE_REASON_SAYS_WHAT_IS_WRONG_WITH_IT(self, reason):
        rec, ic = (getattr(re, attr) for attr in ('compile', 'IGNORECASE'))
        rxs = "unrecognized attribute[()s:]* '?thing_C'?"
        self.assertRegex(reason, rec(rxs, ic))
        self.assertRegex(reason, rec(r'\bdid you mean\b', ic))

    def test_600_also_says_table_name(self):
        self.assertIn(' in "table uno"', self.reason())

    def test_620_also_says_path_name(self):
        self.assertIn('n pretend-file/2536-for-ID-traversal.md', self.reason())

    def test_640_also_says_line_number(self):
        self.assertEqual(self.reason()[-12:], 'versal.md:1)')
        # (at #history-B.6 this changed from line 2 to line 1 because now
        # we count the any header line as the start of the table)

    def dictionary_for_create_with_something_invalid_about_it(self):
        return {'i_de_n_ti_fier_zz': 'B9I',
                'thing_1': '123.45',  # was other primitives B4 #history-B.1
                'thing_A': 'True',
                'thing_C': 'false'}

    def given_collection_via(self):
        yield 'pretend_file', pretend_file_ordinary
        yield 'pretend_writable', True

    def target_canon_case(self):
        return canon.case_of_create_but_something_is_invalid

    do_flush_reason_early = True


class Case2679_create_OK_into_empty_collection(CommonCase):  # #here2

    def test_100_result_is_custom_structure(self):
        self.canon_case.confirm_result_is_custom_structure_for_create(self)

    def test_200_emitted_accordingly(self):
        self.canon_case.confirm_emitted_accordingly(self)

    def test_300_now_collection_doesnt_have_that_entity(self):
        # self.canon_case.confirm_entity_now_in_collection(self)
        fp = self.build_file_patch()  # one file patch
        hunk, = fp.hunks  # with one hunk
        run, = hunk.to_add_lines_runs()  # with one run of added lines
        line, = run.lines  # with one line
        self.assertEqual(line, '+| 123 ||3.14||\n')

    def given_collection_via(self):
        yield 'pretend_file', pretend_file_empty
        yield 'pretend_writable', True
        yield 'expect_num_rewinds', 1  # rewinds 1x b.c confirms coll empty 1st

    def target_canon_case(self):
        return canon.case_of_create_OK_into_empty_collection

    is_expecting_diff_lines = True


class Case2682_create_OK_into_non_empty_collection(CommonCase):

    def test_100_result_is_custom_structure(self):
        self.canon_case.confirm_result_is_custom_structure_for_create(self)

    def test_200_emitted_accordingly(self):
        self.canon_case.confirm_emitted_accordingly(self)

    def test_300_now_collection_doesnt_have_that_entity(self):
        # self.canon_case.confirm_entity_now_in_collection(self)
        fp = self.build_file_patch()  # one file patch

        lines = tuple(s for hunk in fp.hunks for run in hunk.runs for s in run.lines)  # noqa: E501
        lines = lines[-3:]
        expect = (
            " | -2.717 | x2\n",
            "+|-2.718||false||\n",
            " | -2.719 | x4\n")
        self.assertSequenceEqual(lines, expect)

    def given_collection_via(self):
        yield 'pretend_file', pretend_file_ordinary_take_2
        yield 'pretend_writable', True

    def target_canon_case(self):
        return canon.case_of_create_OK_into_non_empty_collection

    is_expecting_diff_lines = True


class Case2710_update_but_entity_not_found(CommonCase):

    def test_100_result_is_none(self):
        self.canon_case.confirm_result_is_none(self)

    def test_200_emitted_accordingly(self):
        self.canon_case.confirm_emitted_accordingly(self)

    def test_600_reason_contains_number_of_lines(self):
        self.assertIn('(saw 3 entities)', self.reason())

    def request_tuple_for_update_that_will_fail_because_no_ent(self):
        return 'NSE', (('update_attribute', 'thing_1', 'no see'),)

    def given_collection_via(self):
        yield 'pretend_file', pretend_file_ordinary
        yield 'pretend_writable', True

    def target_canon_case(self):
        return canon.case_of_update_but_entity_not_found

    do_flush_reason_early = True


class Case2713_update_but_attribute_not_found(CommonCase):

    def test_100_result_is_none(self):
        self.canon_case.confirm_result_is_none(self)

    def test_200_emitted_accordingly(self):
        self.canon_case.confirm_emitted_accordingly(self)

    def given_request_tuple_for_update_that_will_fail_because_attr(self):
        return 'B9H', (('update_attribute', 'thing_1', 'no see'),)

    def given_collection_via(self):
        yield 'pretend_file', pretend_file_ordinary
        yield 'pretend_writable', True

    def target_canon_case(self):
        return canon.case_of_update_but_attribute_not_found


# == HERE

class Case2716_update_OK(CommonCase):

    def test_100_result_is_a_custom_structure(self):
        self.canon_case.confirm_result_is_custom_structure_for_update(self)

    def test_200_the_before_entity_has_the_before_values(self):
        self.canon_case.confirm_the_before_entity_has_the_before_values(self)

    def test_300_the_after_entity_has_the_after_values(self):
        self.canon_case.confirm_the_after_entity_has_the_after_values(self)

    def test_400_emitted_accordingly(self):
        self.canon_case.confirm_emitted_accordingly(self)

    def test_500_retrieve_afterwards_shows_updated_value(self):
        # self.canon_case.confirm_retrieve_after_shows_updated_value(self)
        # don't assert the line contents because too granular (see next tests)
        self.my_custom_index

    """
    given:

        | i De nTi Fier zz | thing 1  | thing-2 | Thing_A |thing-B|    hi-G|
        |  B9H ||   | hi i'm B9H | hey i'm B9H

    and:    'B9H', (
        ('delete_attribute', 'thing-A'),
        ('update_attribute', 'thing-B', "I'm modified \"thing-B\""),
        ('create_attribute', 'thing-2', "I'm created \"thing-2\""))

    expect these:
      - identifier cel is exactly unchanged (that extra space)
      - thing-1 unchanged (zero width)
      - thing-2 gets created and does *not* inherit those 3 spaces of pad
      - thing-A ("hi i'm..") gets deleted, new cel is zero width
      - thing-B  DOES OR DOES NOT inherit the leading padding
      - the final cel ("hi-G") gets added because it's in the example row
      - still no trailng pipe
    """

    def test_531_padding_of_ID_cel_surface_is_unchanged(self):
        s = self.cell_at(0)
        self.assertEqual(s, '  B9H ')

    def test_594_field_one_is_still_zero_width(self):
        s = self.cell_at(1)
        self.assertEqual(s, '')

    def test_656_field_two_is_created_and_clobbers_the_weird_padding(self):
        s = self.cell_at(2)
        self.assertEqual(s, ' I\'m created "thing_2" ')

    def test_719_deleted_cel_is_now_zero_width(self):
        s = self.cell_at(3)
        self.assertEqual(s, '')

    def test_781_updating_DOES_inherit_the_leading_padding(self):
        s = self.cell_at(4)
        exp = '  I\'m modified "thing_B"'
        self.assertEqual(s.index(exp), 0)

    def test_844_had_endcap_before_so_endcap_after(self):
        line = self.my_custom_index['the_whole_line']
        assert -1 != line.rfind('modified "thing_B"|\n')

    def test_906_that_final_cel_still_isnt_present(self):
        line = self.my_custom_index['the_whole_line']
        import functools
        _count_me = re.findall(r'\|', line)
        _num = functools.reduce(lambda m, x: m + 1, _count_me, 0)
        self.assertEqual(_num, 6)

    def test_969_no_trailing_whitespace_because_no_trailing_pipe(self):
        s = self.cell_at(4)
        exp = 'I\'m modified "thing_B"'
        act = s[-len(exp):]
        self.assertEqual(act, exp)

    def cell_at(self, i):
        return self.my_custom_index['cels'][i]

    @shared_subject
    def my_custom_index(self):

        # == at #history-B.1 change from reading cached lines to reading diff
        fp = self.build_file_patch()  # one file patch
        hunk, = fp.hunks  # one hunk
        _, _, run, _ = hunk.runs  # four runs
        line, = run.lines  # one line on this one
        assert '+' == line[0]
        line = line[1:]
        # ==

        md = re.match(r'^\|((?:[^|\n]*\|){4}[^|\n]*)', line)

        """With this much we are comfortable asserting here in the set-up:
        assert the existence of but do not capture the leading pipe,
        then four times of zero-or-more-not-pipes-then-a-pipe,
        and then as many non-pipes as you can after it. This isolates the
        parts of the production we are sure about from the parts we test.
        """

        cels = md[1].split('|')
        assert(5 == len(cels))

        return {'the_whole_line': line, 'cels': cels}

    def request_tuple_for_update_that_will_succeed(self):
        return 'B9H', (
            ('delete_attribute', 'thing_A'),
            ('update_attribute', 'thing_B', "I'm modified \"thing_B\""),
            ('create_attribute', 'thing_2', "I'm created \"thing_2\""))

    def given_identifier_string(self):
        return 'B9H'

    def given_collection_via(self):
        yield 'pretend_file', pretend_file_ordinary
        yield 'pretend_writable', True

    def target_canon_case(self):
        return canon.case_of_update_OK

    is_expecting_diff_lines = True


# == Test Assertion Support

def _flush_reason_early(es):
    sct = es['payloader']()  # see in storage_adapter_canon
    es['payloader'] = lambda: sct
    es['reason'] = sct['reason']


# == Fixtures

def pretend_file_ordinary():
    # making this line up with the legacy collection perfectly is tricky
    # because in non-tabular formats, adding an arbitrary field to an
    # arbitrary entity is cheap and easy, but tables are .. tabular. SO:
    # here we have added *one* of the ad-hoc fields to test a thing
    # (to get more num_fields than num_original_cels)

    yield 'pretend_path', 'pretend-file/2536-for-ID-traversal.md'
    yield 'big_string', (
        """
        # table uno
        | i De nTi Fier zz | thing 1  | thing-2 | Thing_A |thing-B|    hi-G|
        |---|---|---|---|---|---|
        | HMM |  x | x |x|  x| x
        | B9G
        |  B9H ||   | hi i'm B9H |  hey i'm B9H
        | B9K
        """)
    # 👉 these three 'B9G', 'B9H', 'B9K' must be as if (12, 13, 15)
    # 👉 leave this identifier out: 'NSE' (for No Such Entity)


def pretend_file_ordinary_take_2():
    # new at #history-B.1 writing, identifier must be in argument dict

    yield 'pretend_path', 'pretend-file/2682-for-create.md'
    yield 'big_string', (
        """
        # table uno
        | thing 2 | foo fa | thing B | zoo zah |
        |---|---|---|---|
        |||||
        | -2.717 | x2
        | -2.719 | x4
        """)


def pretend_file_one_entity():
    yield 'pretend_path', 'pretend-file/XXXX-one-entity.md'
    yield 'big_string', (
        """
        | i De nTi Fier zz | thing 1  | thing-2 | Thing_A |thing-B|
        |---|---|---|---|---|
        | EG |||||
        | B9K | xx | | zz |
        """)


def pretend_file_empty():
    yield 'pretend_path', 'pretend-file/XXXX-empty-collection.md'
    yield 'big_string', (
        # leftmost field must be in the argument dict or error not under test
        """
        | thing-2 | Thing_A |thing-B| not me |
        |---|---|---|---|
        """)


# == Support

def subject_module():
    import kiss_rdb.storage_adapters_.markdown_table as module
    return module


def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))


""":#here2:
In asserting the main collection story under test, the canon may also apply
additional, auxiliary operations to assert the before state or after state
of the story, in order to assert the expected change the story is supposed to
effect. This happens in at least one canon story and probably more.

For example, the overall purpose of #here1 is to assert that we can create
in to an empty collection. To assert this story, the canon first checks that
the collection starts out with zero items. It does this by traversing the
collection. This sequence of operations presents a challenge because it
violates one of our main rubrics, that our collection object is nominally
[#873.N] single-pass (a.k.a "one-shot") and short- (not long-) running.

We can imagine serveral possible approaches to addressing this challenge,
none of which immediately jump out at us as the best:

- Make canon stories more lax so they don't check collection count in this
  way (i.e., make them "single-pass"-friendly)
- Don't defer to the canon as tightly in stories like these
- Change the collection so it doesn't have a single-pass limitation

For better or worse, as it stands the collection implementation is not strictly
single-pass. It's single-pass per operation, but multiple operations may be
called on a single collection object, because the collection itself is
stateless: it only holds a `path`, a function to `open` the path, and (for
edits) we expose testpoints that produces diff patches, so we only have to test
against generated patches rather than testing against a mutated filesystem.

(At #history-B.5 writing this is not entirely true - now we read from
STDIN-like file resources (read-only and no rewind) which complicates
things here. #[#873.26] whether and how we seek(0))

Now, just because we've decided that multiple-operation "should work" as-is
by collections in production, doesn't mean they will under test. They didn't
at writing because our pretend files themselves have an in-built (implicit)
assertion that the "files" are only traversed (read) once. 2 reasons why:

What we regard as the current best-practice way of representing fixtures in
these stories (for this adapter) is in-file as big-strings: in-file to avoid
the (mental, human) cost of jumping to a real file just to read a few lines,
and big-string rather than lines because it's easier to read and big strings
trivially isomorph with lines here :[#507.11].

Because our design default is always streaming not memory-hog, big strings
are parsed line-by-line on-demand. To support this while being ignorant of it,
pretend files are implemented assuming they are passed an iterator of lines,
which they release by being opened as a context manager (that is, by
implementing `__enter__` and `__exit__`). (In fact, the pretend file doesn't
"know" what its line payload looks like at all. All it does is hold it and
release it.)

But as soon as we want a collection to be able to `open` (and then close) its
`path` multiple times, we can't keep on returning the same pretend path from
`open` over and over, because (as illustrated above) it's stateful and it
exhausts after one traversal.

So, code areas tagged by the tag in our title address this challenge.

This is near [#867.Z] we can't use seek(0) etc on files. just line-by-line
"""


if __name__ == '__main__':
    unittest.main()

# #history-B.6
# #history-B.5
# #history-B.4
# #history-B.1
# #born.
