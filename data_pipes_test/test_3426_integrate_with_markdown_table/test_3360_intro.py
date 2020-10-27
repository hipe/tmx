from data_pipes_test.common_initial_state import collection_via
from kiss_rdb_test.common_initial_state import publicly_shared_fixture_file
from modality_agnostic.test_support.common import \
        throwing_listener, dangerous_memoize as shared_subject
import modality_agnostic.test_support.common as em
import unittest


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

    def _schema_lines_OK(self):
        self.run_length('table_schema_line_ONE_of_two', 1)
        self.run_length('table_schema_line_TWO_of_two', 1)

    def _head_lines_this_many(self, num):
        self.run_length('head_line', num)

    def _tail_lines_this_many(self, num):
        self.run_length('other_line', num)

    def _main_lines_this_many(self, num):
        self.run_length('business_row_AST', num)

    def _items(self):
        return self.business_run().items

    def run_length(self, typ, num):
        actual = self.runs_index[typ].count
        self.assertEqual(actual, num)

    def this_one_business_object_row(self):
        return self.business_run().items[1]

    def business_run(self):
        return self.runs_index['business_row_AST']

    # -- build end state

    @custom_dangerous_memoize
    def runs_index(self):
        return runs_index_via(self.runs)

    @custom_dangerous_memoize
    def runs(self):
        return self.common_run(throwing_listener)

    def build_runs_expecting_emissions(self):
        li, done = em.listener_and_done_via(self.expected_emissions(), self)
        tup = self.common_run(li)
        assert len(tup)  # or not
        emis_dct = done()
        ks = tuple(emis_dct.keys())
        k, = ks
        return emis_dct[k],

    def common_run(self, li):
        sorted_far_dcts = self.given_far_dictionaries()
        mixed_near = self.given_markdown()
        two_keyerers = self.given_two_keyerers()
        runs = runs_via_sync_via(sorted_far_dcts, mixed_near, two_keyerers, li)
        return tuple(runs)

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
        emi, = self.build_runs_expecting_emissions()
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
        self.assertIsNotNone(self.runs)

    def test_020_head_lines_count(self):
        self._head_lines_this_many(3)

    def test_030_schema(self):
        self._schema_lines_OK()

    def test_040_main_lines_count(self):
        self._main_lines_this_many(3)

    def test_050_the_first_and_last_items_are_as_in_the_original(self):

        items = self._items()

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

        items = self._items()
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
        self._tail_lines_this_many(4)

    def given_far_dictionaries(_):
        return case_100_far_dictionaries()


class Case3359DP_MERGE(CommonCase):

    def test_010_does_not_fail(self):
        self.assertIsNotNone(self.runs)

    def test_020_the_after_content_is_right(self):
        items = self._items()
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
        runs = self.runs_index
        act_line = line_via_row(runs['business_row_AST'].items[1])
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

def runs_index_via(runs):
    """in a separate pass, ensure that sections (runs) don't repeat"""

    dct = {}
    for section in runs:
        typ = section.type
        if typ in dct:
            raise Exception('collision')
        dct[typ] = section
    return dct


def runs_via_sync_via(sorted_far_dcts, mixed_near, two_keyerers, listn):
    # (rewritten at #history-A.4 to be less crazy)

    # Chunk the sexps by their type
    sxs = new_sexps_via_sync(sorted_far_dcts, mixed_near, two_keyerers, listn)
    itr = chunks_via(sxs, type_of=lambda s: s[0])
    chunks = tuple(itr)

    # Get rid of these special sexps that don't have payloads
    begin = 1 if 'beginning_of_file' == chunks[0][0] else 0
    end = -1 if 'end_of_file' == chunks[-1][0] else 0
    use_chunks = (chunks[i] for i in range(begin, len(chunks)+end))

    # Produce only the payloads, not the whole sexps, in each chunk
    return (TypeRun(ty, tuple(sx[1] for sx in sxs)) for ty, sxs in use_chunks)


def new_sexps_via_sync(sorted_far_dcts, mixed_near, two_keyerers, listener):
    # (at #history-B.1 got rid of redundant impl of [#459.2] sync)

    # fsfs = far stream for sync

    custom_near, fsfs = these_2_via_these_2(sorted_far_dcts, two_keyerers)

    # Resolve the "Flat Map" injection from the "stream for sync" (from etc)
    assert hasattr(sorted_far_dcts, '__next__')  # does it look like an iterat
    sorted_far_dcts = tuple(sorted_far_dcts)

    from data_pipes_test.sync_support import flat_map_via as func
    flat_map = func(fsfs, build_near_sync_keyer=custom_near)

    # Resolve the sync agent
    sa = sync_agent_via_mixed_near(mixed_near)
    with sa.open_sync_session() as sess:
        for sx in sess.NEW_SEXPS_VIA(flat_map, listener):
            yield sx


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

            from kiss_rdb_test.filesystem_spy import mock_filehandle as func
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
        self.count = len(items)
        self.type = typ
        self.items = items


# == Chunking (experimental, should abstract to DP)

def _identity(x):
    return x


def chunks_via(items, type_of, payload_of=_identity):  # close to #[#508.2]
    def flush(typ):
        tup = tuple(cache)
        cache.clear()
        return typ, tup
    cache = []
    is_changed = build_change_detector()
    for item in items:
        if is_changed(type_of(item)) and len(cache):
            yield flush(is_changed.previous_type)
        cache.append(payload_of(item))
    if len(cache):
        yield flush(is_changed.current_type)


class build_change_detector:  # #[#508.2] chunker #todo make this the one

    def __init__(self, initial_type=None):
        self.current_type = initial_type

    def __call__(self, typ):  # is_changed
        if self.current_type == typ:
            return False
        self.previous_type = self.current_type
        self.current_type = typ
        return True


if __name__ == '__main__':
    unittest.main()

# #history-B.1
# #history-A.4: no more sync-side item-mapping
# #history-A.3: broke symmetry between near and far keyerer
# #history-A.2: default algorithm changed to interfolding and row order changed
# #born.
