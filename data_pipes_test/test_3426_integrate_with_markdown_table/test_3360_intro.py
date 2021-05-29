from data_pipes_test.common_initial_state import collection_via
from kiss_rdb_test.common_initial_state import publicly_shared_fixture_file
from modality_agnostic.test_support.common import \
        throwing_listener, dangerous_memoize as shared_subject
import modality_agnostic.test_support.common as em
import unittest
from dataclasses import dataclass


# == Test Case Precursors

def custom_dangerous_memoize(orig_f):  # #[#507.10] child class memoizer
    def use_f(tc):
        if not tc.do_memoize:
            return orig_f(tc)
        cls = tc.__class__
        attr = '_DP_evil_'
        if not hasattr(cls, attr):
            setattr(cls, attr, {})
        dangerous = getattr(cls, attr)
        k = orig_f.__name__
        if k not in dangerous:
            dangerous[k] = orig_f(tc)
        return dangerous[k]
    return property(use_f)


class CommonCase(unittest.TestCase):

    # -- assist in test assertions

    def this_one_business_object_row(self):
        return self.items[1]

    @property
    def items(self):
        return self.end_state.business_row_ASTs_tuple

    # -- build end state

    @custom_dangerous_memoize
    def end_state(self):
        return self.build_end_state(throwing_listener)

    def build_end_state_SORT_OF_expecting_ONE_emission(self):
        li, done = em.listener_and_done_via(self.expected_emissions(), self)
        es = self.build_end_state(li)
        assert not es.did_succeed
        emis_dct = done()
        emi, = emis_dct.values()
        return emi

    def build_end_state(self, lisn):
        sorted_far_dcts = self.given_far_dictionaries()
        mixed_near = self.given_markdown()
        two_keyerers = self.given_two_keyerers()
        return end_state_via(sorted_far_dcts, mixed_near, two_keyerers, lisn)

    # -- defaults to build end state

    def given_markdown(_):
        return common_markdown_file

    def given_two_keyerers(_):
        pass

    do_memoize = True  # #OCD
    do_debug = False


# == Test Cases

class Case3353DP_far_field_names_have_to_be_subset_of_near_field_names(CommonCase):  # noqa: E501

    def test_020_it_just_throws_a_key_error(self):
        emi = self.build_end_state_SORT_OF_expecting_ONE_emission()
        msg, = emi.to_messages()
        exp = "Unrecognized attributes ('chalupa fupa', 'propecia alameda')"
        self.assertIn(exp, msg)

    def expected_emissions(_):
        yield 'error', '?+', 'as', 'this_emi'

    def given_far_dictionaries(_):
        return case_010_far_dictionaries()

    do_memoize = False


class Case3356DP_adds_only(CommonCase):

    def test_002_does_not_fail(self):
        assert self.end_state

    def test_020_head_lines_count(self):
        assert 3 == len(self.end_state.leading_non_table_lines_tuple)

    def test_030_schema(self):
        assert self.end_state.complete_schema

    def test_040_main_lines_count(self):
        assert 3 == len(self.end_state.business_row_ASTs_tuple)

    def test_050_the_first_and_last_items_are_as_in_the_original(self):

        items = self.items

        _line_one = line_via_row(items[0])
        _line_two = line_via_row(items[-1])

        self.assertEqual(_line_one, "|one|two|three|\n")
        self.assertEqual(_line_two, "| four | five | six\n")

    def test_060_the_new_one_was_added(self):
        """
        test_060_the_new_one_was_added #open [#459.J]:
        this test (although small in codesize) is overloaded. if you
        refactor this test, consider breaking it up to test these separately:

          - that original widths are respected when possible
          - that blank cels also get padded appropriately (Case1718DP)
          - what happens with content overflow (Case3359DP)
        """

        items = self.items
        row = items[1]

        pcs = split_row_line(row)

        self.assertEqual(pcs[0], '|3A')  # "one" in example row
        self.assertEqual(pcs[1], '|')  # "two" in example row
        self.assertEqual(pcs[2], '|choo choo')  # "three" in example row

        self.assertEqual(row.has_endcap, True)

        # we are avoiding testing the details of alignment
        # self.assertEqual(_actual_line, "|3A |   |choo choo|\n")
        # because those are (Case2478KR) (Case2479KR)

    def test_070_tail_lines_count(self):
        assert 4 == len(self.end_state.trailing_non_table_lines_tuple)

    def given_far_dictionaries(_):
        return case_100_far_dictionaries()


class Case3359DP_MERGE(CommonCase):

    def test_010_does_not_fail(self):
        assert self.end_state

    def test_020_the_after_content_is_right(self):
        items = self.items
        self.assertEqual(len(items), 2)
        row = items[1]

        t = value_strings(row)

        self.assertEqual(t[0], 'four')
        self.assertEqual(t[1], '5')
        self.assertEqual(t[2], 'six')
        self.assertEqual(row.has_endcap, False)

        # avoid testing alignments here, but:
        self.assertEqual(line_via_row(row), '|four|  5| six\n')
        # this touches on alignment not specified (Case2481KR)

    def given_far_dictionaries(_):
        return case_200_far_dictionaries()


class Case3362DP_what_if_no_business_attrs_besides_ID(CommonCase):
    # Even though there is nothing to do, this sync happens [#458.7]

    def test_100_whoopsie_the_changed_cell_takes_on_the_EG_styling(self):
        ast1, ast2 = self.end_state.business_row_ASTs_tuple
        act_line = ast2.to_line()
        self.assertEqual(act_line, '| zub   | x2\n')  # not the example format

    def given_far_dictionaries(_):
        yield {'col_A': 'zub'}

    def given_markdown(_):
        return ('|Col A|Col B|\n',
                '|-----|-----|\n',
                '| zib   |   x1   |\n',
                '|   zub | x2\n')

    do_memoize = False


class Case3365DP_custom_keyers(CommonCase):

    def test_100_the_NOT_updated_business_cel_stays_as_is(self):
        self.assertEqual(self.end_cel_strings[2], '| six\n')

    def test_200_the_YES_updated_business_cel_has_the_example_width(self):
        # (Case2479KR) (align left) is also exhibited
        self.assertEqual(self.end_cel_strings[1], '|  5')

    def test_300_crucially_the_natural_key_IS_updated(self):
        self.assertEqual(self.end_cel_strings[0], '|  FOUR  ')

    @shared_subject
    def end_cel_strings(self):
        row = self.this_one_business_object_row()
        tup = split_row_line(row)
        assert 3 == len(tup)
        return tup

    def given_far_dictionaries(_):
        yield {
                    'field_name_one': '  FOUR  ',
                    'field_2': '5',
        }

    def given_two_keyerers(_):
        return common_two_keyerers()


class Case3368_in_this_case_mono_value_does_YES_update(CommonCase):
    # [#458.7] when natural keys are different, take the far value

    def test_100_the_cell_with_no_attribute_in_far_stream_is_untouched(self):
        self.assertEqual(self.row_pieces[1], '| x2\n')

    def test_200_identifier_cell_has_surface_value_of_far_string(self):
        vs = value_string_via_piece(self.row_pieces[0])
        self.assertEqual(vs, 'zUb')  # instead of ZuB

    def test_300_takes_formatting_from_example_row(self):
        fi = formatting_imprint_via_piece(self.row_pieces[0])
        self.assertEqual(fi, '| xxx  ')

    @shared_subject
    def row_pieces(self):
        row = self.this_one_business_object_row()
        return split_row_line(row)

    def given_far_dictionaries(_):
        yield {'col_A': 'zUb'}

    def given_markdown(_):
        return ('|Col A|Col B|\n',
                '|-----|-----|\n',
                '| zib  |   x1   |\n',
                '|      ZuB   | x2\n')

    def given_two_keyerers(_):
        return common_two_keyerers()


# == Inline Test Fixtures

def case_010_far_dictionaries():
    yield {
                    'field_name_one': 'adonga zebronga',
                    'chalupa fupa': 'zack braff',
                    'propecia alameda': 'ohai kauaii',
    }


def case_100_far_dictionaries():
    yield {
                    'field_name_one': '3A',
                    'cha_cha': 'choo choo',
    }


def case_200_far_dictionaries():
    yield {
                    'field_name_one': 'four',
                    'field_2': '5',
    }


common_markdown_file = '0100-hello.md'


# == Test Assertion Support

def value_string_via_piece(pc):
    end = len(pc) - 1
    if '\n' == pc[end - 1]:
        end -= 1
    return pc[1:end].strip()


def formatting_imprint_via_piece(pc):
    import re
    md = re.match(r'^(\|[ ]*)[^ ](?:.*[^ ])?([ ]*\n?)\Z', pc)
    left_pad_plus, right_pad_plus = md.groups()
    return f"{left_pad_plus}xxx{right_pad_plus}"


def split_row_line(row):
    import re
    return re.split(r'(?<=.)(?=\|)', line_via_row(row))  # #[#873.24]


def value_strings(row):
    rang = range(0, row.cell_count)
    return tuple(row.cell_at_offset(i).value_string for i in rang)


def line_via_row(row):
    return row.to_line()


# == End State Support (would be better in its own module)

def end_state_via(sorted_far_dcts, mixed_near, two_keyerers, lisn):
    # (rewrite for enter document scanner at #history-B.2)
    # (got rid of redundant impl of [#459.2] sync) at #history-B.1)
    # (rewritten to be less crazy at #history-A.4)

    itr = end_state_components(sorted_far_dcts, mixed_near, two_keyerers, lisn)
    dct = {k: v for k, v in itr}

    # (snip handling for beginning_of_file end_of_file)

    if not dct['did_succeed']:
        return DID_NOT_SUCCEED

    dct.pop('did_succeed')
    return EndState(**dct)


def end_state_components(sorted_far_dcts, mixed_near, two_keyerers, listener):

    # fsfs = far stream for sync

    custom_near, fsfs = these_2_via_these_2(sorted_far_dcts, two_keyerers)

    # Resolve the "Flat Map" injection from the "stream for sync" (from etc)
    assert hasattr(sorted_far_dcts, '__next__')  # does it look like an iterat
    sorted_far_dcts = tuple(sorted_far_dcts)

    from data_pipes_test.sync_support import flat_map_via as func
    flat_map = func(fsfs, build_near_sync_keyer=custom_near)

    # Resolve the sync agent
    sa = sync_agent_via_mixed_near(mixed_near)

    yield 'did_succeed', False  # watch
    with sa.open_sync_session() as sess:
        try:
            for k, x in _do_ting(sess, flat_map, listener):
                yield k, x
        except _Stop:
            return
        yield 'did_succeed', True


def _do_ting(sess, flat_map, arg_listener):

    # build_throwing_listener_
    def listener(sev, *rest):
        arg_listener(sev, *rest)
        if 'error' == sev:
            raise _Stop()

    dscn = sess.NEW_DOCUMENT_SCANNER_VIA(flat_map, listener)
    lines = tuple(dscn.release_leading_non_table_lines())
    yield 'leading_non_table_lines_tuple', lines
    yield 'complete_schema', dscn.release_complete_schema()
    asts = tuple(dscn.release_business_row_ASTs_for_modified_document())
    yield 'business_row_ASTs_tuple', asts
    lines = tuple(dscn.release_trailing_non_table_lines())
    yield 'trailing_non_table_lines_tuple', lines


@dataclass
class EndState:
    leading_non_table_lines_tuple: tuple[str]
    complete_schema: object
    business_row_ASTs_tuple: tuple[object]
    trailing_non_table_lines_tuple: tuple[str]
    did_succeed = True


class DID_NOT_SUCCEED:  # #class-as-namespace
    did_succeed = False


def these_2_via_these_2(sorted_far_dcts, two_keyerers):

    sorted_far_dcts = tuple(sorted_far_dcts)

    if len(sorted_far_dcts):
        leftmost_key = next(iter(sorted_far_dcts[0].keys()))

    fsfs = tuple((item[leftmost_key], item) for item in sorted_far_dcts)

    near_keyerer = None
    if two_keyerers:
        near_keyerer, far_keyerer = two_keyerers
        far_keyer = far_keyerer()  # #here1
        fsfs = tuple((far_keyer(k, item), item) for k, item in fsfs)

    return near_keyerer, fsfs


def sync_agent_via_mixed_near(mixed_near):
    opn, path = opn_and_path_via(mixed_near)
    coll = collection_via(path, throwing_listener, opn=opn)
    return coll.dig_for_edit_agent('SYNC_AGENT_FOR_DATA_PIPES')


def opn_and_path_via(mixed_near):
    if isinstance(mixed_near, str):
        path = publicly_shared_fixture_file(mixed_near)
        opn = None
    else:
        assert isinstance(mixed_near, tuple)
        assert isinstance(mixed_near[0], str)

        def opn(my_path, mode):
            assert 'r+' == mode
            assert my_path == path

            if isinstance(mixed_near, tuple):
                lines = iter(mixed_near)
            else:
                raise RuntimeError('easy')
            from modality_agnostic.test_support.mock_filehandle import \
                mock_filehandle as func
            return func(lines, path)
        path = 'my-fake-path.md'
    return opn, path


def value_via_module_path(module_path):  # moved here at #history-B.1
    """
    module path:
        identifier ::= path_esque '.' function_name
        path_esque ::= path_part ( '.' path_part )*
        path_part ::= /^[a-z][a-z0-9_]*$
        function_name ::= /^[a-zA-Z][a-zA-Z0-9_]*$/
    """

    word = '[a-zA-Z][a-zA-Z0-9_]*'  # added uppercase at a historical point
    import re
    rx = re.compile(r'^(%s(?:\.%s)*)\.([a-zA-Z][a-zA-Z0-9_]*)$' % (word, word))
    md = rx.match(module_path)  # ..
    path_esque, value_name = md.groups()

    from importlib import import_module
    mod = import_module(path_esque)  # ..
    return getattr(mod, value_name)  # ..


# == FROM [#459.R] #here1

def common_two_keyerers():
    return common_near_keyerer, common_far_keyerer


def common_near_keyerer(sync_key_normally):
    def use_f(ent):
        sk = sync_key_normally(ent)
        if sk is None:
            return
        return simplify_and_add_guillemets(sk)
    return use_f


def common_far_keyerer():
    return common_far_keyer  # hi.


def common_far_keyer(k, item):
    return simplify_and_add_guillemets(k)


def simplify_and_add_guillemets(k):
    return f'«{k.strip().upper()}»'

# == TO


class TypeRun:
    def __init__(self, typ, items):
        self.type, self.items = typ, items


class _Stop(RuntimeError):
    pass


if __name__ == '__main__':
    unittest.main()


# #history-B.2
# #history-B.1
# #history-A.4: no more sync-side item-mapping
# #history-A.3: broke symmetry between near and far keyerer
# #history-A.2: default algorithm changed to interfolding and row order changed
# #born.
