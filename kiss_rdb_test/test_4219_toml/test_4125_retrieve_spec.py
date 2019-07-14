from kiss_rdb_test.common_initial_state import (
        TSLO_via,
        debugging_listener as _debugging_listener,
        unindent as _unindent)
from kiss_rdb.storage_adapters_.toml.entities_via_collection import (
        table_block_via_lines_and_table_start_line_object_)
from modality_agnostic.test_support import structured_emission as se_lib
from modality_agnostic.memoization import (
    dangerous_memoize as shared_subject,
    memoize,
    )
import unittest


# NOTE canon for retrieve is covered in that one file


class _CommonCase(unittest.TestCase):

    # -- comment yes/no

    def expect_no_comment(self, an_s):
        return self._expect_yes_no_comment(False, an_s)

    expect_no_comment_easy = expect_no_comment

    def expect_yes_comment(self, an_s):
        return self._expect_yes_no_comment(True, an_s)

    expect_yes_comment_easy = expect_yes_comment

    def _expect_yes_no_comment(self, comment_expected_yes_no, an_s):
        listener = _debugging_listener() if False else _no_listener
        ok, actual_yes_or_no = self._run_comment_test(an_s, listener)
        self.assertEqual(ok, True)
        self.assertEqual(actual_yes_or_no, comment_expected_yes_no)

    def expect_toml_type_not_supported(self, which):
        _expect_message = f"no support (yet) for toml's '{which}' type"
        _sct = self.emission_payload_via_run_expecting_channel(
                self.given_run,
                'error', 'structure', 'input_error')  # #here1
        _actual_reason = _sct['reason']
        self.assertEqual(_actual_reason, _expect_message)

    def run_comment_test_expecting_failure(self, listener):
        _an_s = self.given_attribute()
        ok, x = self._run_comment_test(_an_s, listener)
        self.assertIsNone(x)
        self.assertEqual(ok, False)

    def _run_comment_test(self, an_s, listener):
        _tester = _comment_tester_one()  # abstract 2 #hook-out when necessary
        ok, x = _tester(an_s, listener)
        return (ok, x)

    # -- retrieve

    def error_structure_has_identifier_string(self, id_s):
        _actual = self.error_structure_at('identifier_string')
        self.assertEqual(_actual, id_s)

    def tells_you_it_DID_traverse_whole_file(self):
        self.assertTrue(self._did_traverse_whole_file())

    def tells_you_it_did_NOT_traverse_whole_file(self):
        self.assertFalse(self._did_traverse_whole_file())

    def _did_traverse_whole_file(self):
        return self.error_structure_at('did_traverse_whole_file')

    def expect_not_found_input_error_type(self):
        _actual = self.error_structure_at('input_error_type')
        self.assertEqual(_actual, 'not_found')

    def expect_entity_has_this_identifier(self, id_s):
        tsl = self.table_start_line_object()
        self.assertEqual(tsl.identifier_string, id_s)
        self.assertEqual(tsl.table_type, 'attributes')

    def expect_attribute_line_has_name(self, al, nm):
        self.assertEqual(al.attribute_name_string, nm)

    def expect_block_is_blank_line(self, blk):
        self.assertTrue(blk.is_discretionary_block)
        line, = blk.discretionary_block_lines
        self.assertEqual(line, '\n')

    def table_start_line_object(self):
        return self.entity()._table_start_line_object

    def body_component_at(self, idx):
        return self.body_block_index()[idx]

    def build_body_block_index(self):
        return self.entity()._body_blocks

    def retrieve_expecting_success(self):
        listener = _debugging_listener() if False else _no_listener
        return self.run_retrieve(listener)

    def error_structure_at(self, nm):
        return self.error_structure()[nm]

    def emission_payload_expecting_entity_not_found(self):
        return self.emission_payload_expecting_channel(
                'error', 'structure', 'entity_not_found')

    def emission_payload_expecting_generic_error(self):
        return self.emission_payload_expecting_channel(
                'error', 'structure', 'input_error')  # #here1

    def emission_payload_expecting_channel(self, *chan):
        return self.emission_payload_via_run_expecting_channel(
                self.run_retrieve, *chan)

    def emission_payload_via_run_expecting_channel(self, run, *chan):  # #c/p
        actual_channel, structurer = se_lib.one_and_none(self, run)
        self.assertSequenceEqual(actual_channel, chan)
        return structurer()

    def run_retrieve(self, listener):
        _id_s = self.given_identifier()
        _all_lines = self.given_lines()

        return _subject_module().entity_via_identifier_and_file_lines(
                _id_s, _all_lines, listener)


class Case4116_simplified_typical_retrieve_in_mid(_CommonCase):

    def test_100_runs(self):
        self.assertIsNotNone(self.entity())

    def test_233_table_start_line_components_look_good(self):
        self.expect_entity_has_this_identifier('BB')

    def test_266_table_start_line_LINE_looks_good(self):
        _expected = '[item.BB.attributes]\n'
        self.assertEqual(self.table_start_line_object().line, _expected)

    def test_300_yeah_i_got_attributes(self):
        al = self.body_component_at(0)
        self.expect_attribute_line_has_name(al, 'prop-1')
        al = self.body_component_at(1)
        self.expect_attribute_line_has_name(al, 'prop-2')

    def test_400_trailing_blank_lines(self):
        self.expect_block_is_blank_line(self.body_component_at(2))

    @shared_subject
    def body_block_index(self):
        return self.build_body_block_index()

    @shared_subject
    def entity(self):
        return self.retrieve_expecting_success()

    def given_identifier(self):
        return 'BB'

    def given_lines(self):
        return _given_ABC_lines()


class Case4117_not_found(_CommonCase):

    def test_100_input_error_type_is_not_found(self):
        self.expect_not_found_input_error_type()

    def test_200_the_error_structure_has_the_ID_string(self):
        self.error_structure_has_identifier_string('BBCC')

    def test_300_tells_you_it_did_NOT_traverse_whole_file(self):
        self.tells_you_it_did_NOT_traverse_whole_file()

    def test_400_reason_is_straightforward(self):
        _actual = self.error_structure_at('reason')
        self.assertEqual(_actual, "'BBCC' not found")

    @shared_subject
    def error_structure(self):
        return self.emission_payload_expecting_entity_not_found()

    def given_identifier(self):
        return 'BBCC'

    def given_lines(self):
        return _given_ABC_lines()


class Case4118_not_found_anywhere(_CommonCase):

    def test_300_tells_you_it_traversed_the_whole_thing(self):
        self.assertTrue(self.error_structure_at('did_traverse_whole_file'))

    def test_400_reason_is_worded_slightly_differently(self):
        _actual = self.error_structure_at('reason')
        self.assertEqual(_actual, "'DD' not in file")

    @shared_subject
    def error_structure(self):
        return self.emission_payload_expecting_entity_not_found()

    def given_identifier(self):
        return 'DD'

    def given_lines(self):
        return _given_ABC_lines()


class Case4120_at_head(_CommonCase):

    def test_300_attributes(self):
        a = self.body_block_index()
        self.assertEqual(a[0].line, "prop-1 = 123\n")
        self.assertEqual(a[1].line, 'prop-2 = "value aa"\n')

    def test_400_trailing_blank_lines(self):
        a = self.body_block_index()
        self.expect_block_is_blank_line(a[2])
        self.assertEqual(len(a), 3)

    @shared_subject
    def body_block_index(self):
        return self.build_body_block_index()

    def entity(self):
        return self.retrieve_expecting_success()

    def given_identifier(self):
        return 'AA'

    def given_lines(self):
        return _given_ABC_lines()


class Case4121_at_tail(_CommonCase):

    def test_300_attributes(self):
        a = self.body_block_index()
        self.assertEqual(a[0].line, "prop-1 = 345\n")
        self.assertEqual(a[1].line, 'prop-2 = "value cc"\n')

    def test_400_notrailing_blank_lines(self):
        a = self.body_block_index()
        self.assertEqual(len(a), 2)

    @shared_subject
    def body_block_index(self):
        return self.build_body_block_index()

    def entity(self):
        return self.retrieve_expecting_success()

    def given_identifier(self):
        return 'CC'

    def given_lines(self):
        return _given_ABC_lines()


@memoize
def _given_ABC_lines():
    return tuple(_unindent("""
    [item.AA.attributes]
    prop-1 = 123
    prop-2 = "value aa"

    [item.BB.attributes]
    prop-1 = 234
    prop-2 = "value bb"

    [item.CC.attributes]
    prop-1 = 345
    prop-2 = "value cc"
    """))


class Case4122_against_empty(_CommonCase):

    # #wish [#867.G] empty files would tell you they're empty in this case

    def test_100_input_error_type_is_not_found(self):
        self.expect_not_found_input_error_type()

    def test_200_the_error_structure_has_the_ID_string(self):
        self.error_structure_has_identifier_string('FF')

    def test_300_tells_you_it_DID_traverse_whole_file(self):
        self.tells_you_it_DID_traverse_whole_file()

    @shared_subject
    def error_structure(self):
        return self.emission_payload_expecting_entity_not_found()

    def given_identifier(self):
        return 'FF'

    def given_lines(self):
        return ()


class Case4123_meta_not_yet_implemented(_CommonCase):

    def test_100_message(self):
        es = self.emission_payload_expecting_generic_error()

        # [item.B.meta]
        # --------^       (offset 8)

        self.assertEqual(es['position'], 8)
        self.assertEqual(es['reason'], "table type 'meta' not yet implemented")

    def given_identifier(self):
        return 'B'

    def given_lines(self):
        return _unindent("""
        # comment
        [item.A.attributes]
        [item.B.meta]
        [item.B.attributes]
        see-me = "do see me"

        [item.B.attributes]
        see-me = "don't see me"

        """)


class Case4124_duplicate_identifiers_can_get_shadowed(_CommonCase):

    # [#864.provision-3.1]: stop at the first one

    def test_200_table_start_line(self):
        self.expect_entity_has_this_identifier('B')

    def test_300_attributes(self):
        al = self.body_component_at(0)
        self.assertEqual(al.line, 'see-me = "do see me"\n')

    @shared_subject
    def body_block_index(self):
        return self.build_body_block_index()

    @shared_subject
    def entity(self):
        return self.retrieve_expecting_success()

    def given_identifier(self):
        return 'B'

    def given_lines(self):
        return _unindent("""
        # comment
        [item.A.attributes]
        [item.B.attributes]
        see-me = "do see me"

        [item.C.meta]
        [item.B.attributes]
        see-me = "don't see me"

        """)


# Case4125 # #midpoint


class Case4126_invalid_toml_gets_thru_coarse_parse_then_parse_fail(_CommonCase):  # noqa: E501

    """(note we don't actually run this thru a coarse parse)"""

    def test_100_in_general_say_toml_decode_error(self):
        self.assertEqual(self._general_and_specific()[0], 'toml decode error')

    def test_200_in_specific_say_this_one_weird_error(self):
        _expect = "This float doesn't have a leading digit (line 2 column 1 char 1)"  # noqa: E501
        self.assertEqual(self._general_and_specific()[1], _expect)

    @shared_subject
    def _general_and_specific(self):
        return self._structure()['reason'].split(': ')

    @shared_subject
    def _structure(self):
        def run(listener):
            return _vendor_parse(self.given_entity_body_lines(), listener)
        return self.emission_payload_via_run_expecting_channel(
                run, 'error', 'structure', 'input_error')  # #here1

    def given_entity_body_lines(self):
        return """
        love-potion = number-nine
        """


class Case4127_touch_multi_line(_CommonCase):  # #mutli-line-case
    # before #history-A.1, the case around these input lines captured how it
    # was possible to use multi-line strings to "trick" our parser. now that
    # we attempt to support multi-line strings..

    def test_100_EVERYTHING(self):
        body_lines = tuple(_unindent(self.given_entity_body_lines()))
        tb = _table_block_via_body_lines(body_lines)
        one, = tb._body_blocks
        self.assertEqual(one.attribute_name_string, 'love-potion')
        _actual = tuple(one.to_line_stream())
        self.assertSequenceEqual(_actual, body_lines)

    def given_entity_body_lines(self):
        # the below looks like two attributes to the coarse parse but isn't
        return """
        love-potion = '''
        number-nine = "hi"'''
        """


class Case4128_array_not_suported_yet(_CommonCase):

    def test_100(self):
        self.expect_toml_type_not_supported('array')

    def given_run(self, listener):
        return self.run_comment_test_expecting_failure(listener)

    def given_attribute(self):
        return 'array'


class Case4129_inline_tables_not_suported_yet(_CommonCase):

    def test_100(self):
        self.expect_toml_type_not_supported('inline table')

    def given_run(self, listener):
        return self.run_comment_test_expecting_failure(listener)

    def given_attribute(self):
        return 'inline-table'


class Case4130_the_easy_cases(_CommonCase):

    def test_316_bool_no_comment(self):
        self.expect_no_comment_easy('bool-no-comment')

    # Case4130.05
    def test_322_bool_yes_comment(self):
        self.expect_yes_comment_easy('bool-yes-comment')

    # Case4127.10
    def test_328_int_no_comment(self):
        self.expect_no_comment_easy('int-no-comment')

    # Case4130.15
    def test_334_int_yes_comment(self):
        self.expect_yes_comment_easy('int-yes-comment')

    # Case4868.20
    def test_341_float_no_comment(self):
        self.expect_no_comment_easy('float-no-comment')

    # Case4868.25
    def test_347_float_yes_comment(self):
        self.expect_yes_comment_easy('float-yes-comment')

    # Case4868.30
    def test_353_datetime_no_comment(self):
        self.expect_no_comment_easy('datetime-no-comment')

    # Case4868.35
    def test_359_datetime_yes_comment(self):
        self.expect_yes_comment_easy('datetime-yes-comment')


class Case4132_literal_string_not_yet_supported(_CommonCase):

    def test_100(self):
        self.expect_toml_type_not_supported('literal string')

    def given_run(self, listener):
        return self.run_comment_test_expecting_failure(listener)

    def given_attribute(self):
        return 'single-line-literal-string'


class Case4133_multi_line(_CommonCase):

    # (#tombstone-A.2 remembers when these were not yet supported)

    def test_372_multi_line_literal_never_has_comment(self):
        self.expect_no_comment_easy('multi-line-literal')

    # Case4133.20
    def test_378_multi_line_basic_never_has_comment(self):
        self.expect_no_comment_easy('multi-line-basic')


class Case4134_the_hard_but_money_cases(_CommonCase):

    # these are ones where we parse the string by hand and it works

    def test_384_basic_string_simple(self):
        self.expect_no_comment('basic-string-050-simple')

    # Case4134.20
    def test_391_basic_string_empty(self):
        self.expect_yes_comment('basic-string-000-empty')

    # Case4134.30
    def test_397_escape(self):
        self.expect_yes_comment('basic-string-100-escape')


@memoize
def _comment_tester_one():
    """things to note about this fellow:
        - written so every line passes crude parse (should that be
          necessary. maybe it isnt.)
        - .#mutli-line strings cannot have comments after them (according
          to our vendor parsing library) so the break the pattern below
        - note the trick we do to get tripple quotes into the multiline string
    """

    orly = '"""'
    return _comment_tester_via_big_string_using_hack(
        f"""
        bool-no-comment = true
        bool-yes-comment = false  # hi
        int-no-comment = +1_000
        int-yes-comment = -3#
        float-no-comment = -3.1415
        float-yes-comment = 6.626e-34  #
        datetime-no-comment = 1979-05-27T07:32:00Z
        datetime-yes-comment = 1979-05-27T07:32:00Z  # HBD TPW
        single-line-literal-string = 'hi'  # ..
        multi-line-literal = '''
        # not comment 1 \u0020'''
        multi-line-basic = {orly}
        # not comment 2 {orly}
        array = [ 1, 2, 3 ]
        inline-table = {{ first = "Tom", last = "Preston-Werner" }}
        basic-string-000-empty = ""  # hi
        basic-string-050-simple = "hi"
        basic-string-100-escape = "the food is \\"safe\\""#
        """
    )

    # #open [#861.D] these datetime forms not supported in python toml
    # datetime-no-comment = 07:32:00
    # datetime-yes-comment = 1979-05-27  # HBD TPW


def _comment_tester_via_big_string_using_hack(big_s):
    _lines = _unindent(big_s)
    listener = _debugging_listener() if True else _no_listener
    _tb = _table_block_via_body_lines(_lines)
    _bb = _tb.to_body_block_stream_as_table_block_()
    # hackishly use this as reader for array
    return _subject_module().comment_tester_via_body_blocks_(_bb, listener)


def _table_block_via_body_lines(lines):

    # use the same parser that parses while files to get just a apendable
    # document entity (table block) from the body lines of an ent

    _ = _table_start_line_object()
    return table_block_via_lines_and_table_start_line_object_(lines, _)


@memoize
def _table_start_line_object():
    return TSLO_via('ABCDE', 'attributes')


def _vendor_parse(body_string, listener):
    return _subject_module()._vendor_parse(body_string, listener)


def _subject_module():
    from kiss_rdb.storage_adapters_.toml import entity_via_identifier_and_file_lines as _  # noqa: E501
    return _


def cover_me(msg=None):
    _ = '' if msg is None else f': {msg}'
    raise Exception(f'cover me{_}')


_no_listener = None


if __name__ == '__main__':
    unittest.main()


# #tombstone-A.2 as referenced
# #history-A.1 adding multi-line support changed some cases
# #born.
