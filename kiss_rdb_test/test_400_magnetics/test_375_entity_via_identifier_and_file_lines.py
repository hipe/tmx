import _common_state  # noqa: F401
from kiss_rdb_test import structured_emission as selib
from modality_agnostic.memoization import (
    dangerous_memoize as shared_subject,
    memoize,
    )
import unittest


class _CommonCase(unittest.TestCase):

    # -- comment yes/no

    def expect_no_comment(self, an_s):
        return self._expect_yes_no_comment(False, an_s)

    expect_no_comment_easy = expect_no_comment

    def expect_yes_comment(self, an_s):
        return self._expect_yes_no_comment(True, an_s)

    expect_yes_comment_easy = expect_yes_comment

    def _expect_yes_no_comment(self, comment_expected_yes_no, an_s):
        listener = selib.debugging_listener() if False else _no_listener
        ok, actual_yes_or_no = self._run_comment_test(an_s, listener)
        self.assertEqual(ok, True)
        self.assertEqual(actual_yes_or_no, comment_expected_yes_no)

    def expect_toml_type_not_supported(self, which):
        _expect_message = f"no support (yet) for toml's '{which}' type"
        self.expect_reason(_expect_message)

    def run_comment_test_expecting_failure(self, listener):
        _an_s = self.given_attribute()
        ok, x = self._run_comment_test(_an_s, listener)
        self.assertIsNone(x)
        self.assertEqual(ok, False)

    def _run_comment_test(self, an_s, listener):
        _tester = _comment_tester_one()  # abstract 2 #hook-out when necessary
        ok, x = _tester(an_s, listener)
        return (ok, x)

    def vendor_parse_expecting_failure(self):
        return self._expecting_failure(self.run_vendor_parse)

    def run_build_vendor_value_index(self, listener):
        _ = self.given_entity_body_lines()
        _mde = _MDE_via_body_lines_string_using_hack(_)
        return _comment_tester_via(_mde, listener)

    def run_vendor_parse(self, listener):
        _body_string = self.given_entity_body_lines()
        return _vendor_parse(_body_string, listener)

    # -- retrieve

    def error_structure_has_identifier_string(self, id_s):
        _actual = self.error_structure_at('identifier_string')
        self.assertEqual(_actual, id_s)

    def tells_you_it_might_be_out_of_order(self):
        self.assertTrue(self._might_be_out_of_order_yes_no())

    def tells_you_it_was_NOT_out_of_order(self):
        self.assertFalse(self._might_be_out_of_order_yes_no())

    def _might_be_out_of_order_yes_no(self):
        return self.error_structure_at('might_be_out_of_order')

    def expect_not_found_input_error_type(self):
        _actual = self.error_structure_at('input_error_type')
        self.assertEqual(_actual, 'not_found')

    def expect_entity_has_this_identifier(self, id_s):
        otl = self.open_table_line_object()
        self.assertEqual(otl.identifier_string, id_s)
        self.assertEqual(otl.table_type, 'attributes')

    def expect_attribute_line_has_name(self, al, nm):
        self.assertEqual(al.attribute_name.name_string, nm)

    def expect_is_blank_line_object(self, lo):
        self.assertFalse(lo.is_attribute_line or lo.is_comment_line)
        self.assertEqual(lo.line, '\n')

    def open_table_line_object(self):
        return self.entity()._open_table_line_object

    def body_component_at(self, idx):
        return self.body_block_index()[idx]

    def build_body_block_index(self):
        return tuple(self.entity().TO_BODY_LINE_OBJECT_STREAM())

    def retrieve_expecting_failure(self):
        return self._expecting_failure(self.run_retrieve)

    def retrieve_expecting_success(self):
        listener = selib.debugging_listener() if False else _no_listener
        return self.run_retrieve(listener)

    def run_retrieve(self, listener):
        _id_s = self.given_identifier()
        _all_lines = self.given_lines()

        return _subject_module().entity_via_identifier_and_file_lines(
                _id_s, _all_lines, listener)

    # -- general negative

    def expect_reason(self, reason):
        _actual_reason = self.reason_via_expect_input_error()
        self.assertEqual(_actual_reason, reason)

    def reason_via_expect_input_error(self):
        return self.structure_via_expect_input_error()['reason']

    def error_structure_at(self, nm):
        return self.error_structure()[nm]

    def structure_via_expect_input_error(self):
        return self._expecting_failure(self.given_run)

    def _expecting_failure(self, run):
        chan, structurer = self._expect_one_emisson_given_run(run)
        self.assertEqual(chan, ('error', 'structure', 'input_error'))
        return structurer()

    # -- possibly shared support

    def _expect_one_emisson_given_run(self, run):
        def listener(*a):
            nonlocal count
            nonlocal last_emission
            if 0 < count:
                self.fail('more than one emission')
            count += 1
            last_emission = a
        count = 0
        last_emission = None
        x = run(listener)
        if not count:
            self.fail('expected one emission, had none')
        self.assertIsNone(x)
        *chan, payloader = last_emission
        chan = tuple(chan)
        return (chan, payloader)


class Case253_simplified_typical_retrieve_in_mid(_CommonCase):

    def test_100_runs(self):
        self.assertIsNotNone(self.entity())

    def test_233_open_table_line_components_look_good(self):
        self.expect_entity_has_this_identifier('BB')

    def test_266_open_table_line_LINE_looks_good(self):
        _expected = '[item.BB.attributes]\n'
        self.assertEqual(self.open_table_line_object().line, _expected)

    def test_300_yeah_i_got_attributes(self):
        al = self.body_component_at(0)
        self.expect_attribute_line_has_name(al, 'prop-1')
        al = self.body_component_at(1)
        self.expect_attribute_line_has_name(al, 'prop-2')

    def test_400_trailing_blank_lines(self):
        self.expect_is_blank_line_object(self.body_component_at(2))

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


class Case259_not_found(_CommonCase):

    def test_100_input_error_type_is_not_found(self):
        self.expect_not_found_input_error_type()

    def test_200_the_error_structure_has_the_ID_string(self):
        self.error_structure_has_identifier_string('BBCC')

    def test_300_tells_you_if_it_might_be_because_out_of_order(self):
        self.tells_you_it_might_be_out_of_order()

    def test_400_reason_is_straightforward(self):
        _actual = self.error_structure_at('reason')
        self.assertEqual(_actual, "'BBCC' not found")

    @shared_subject
    def error_structure(self):
        return self.retrieve_expecting_failure()

    def given_identifier(self):
        return 'BBCC'

    def given_lines(self):
        return _given_ABC_lines()


class Case263_not_found_anywhere(_CommonCase):

    def test_300_tells_you_it_traversed_the_whole_thing(self):
        self.assertFalse(self.error_structure_at('might_be_out_of_order'))

    def test_400_reason_is_worded_slightly_differently(self):
        _actual = self.error_structure_at('reason')
        self.assertEqual(_actual, "'DD' not in file")

    @shared_subject
    def error_structure(self):
        return self.retrieve_expecting_failure()

    def given_identifier(self):
        return 'DD'

    def given_lines(self):
        return _given_ABC_lines()


class Case266_at_head(_CommonCase):

    def test_300_attributes(self):
        a = self.body_block_index()
        self.assertEqual(a[0].line, "prop-1 = 123\n")
        self.assertEqual(a[1].line, 'prop-2 = "value aa"\n')

    def test_400_trailing_blank_lines(self):
        a = self.body_block_index()
        self.expect_is_blank_line_object(a[2])
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


class Case272_at_tail(_CommonCase):

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
    return tuple(selib.unindent("""
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


class Case278_against_empty(_CommonCase):

    # #wish [#867.G] empty files would tell you they're empty in this case

    def test_100_input_error_type_is_not_found(self):
        self.expect_not_found_input_error_type()

    def test_200_the_error_structure_has_the_ID_string(self):
        self.error_structure_has_identifier_string('FF')

    def test_300_tells_you_it_was_NOT_out_of_order(self):
        self.tells_you_it_was_NOT_out_of_order()

    @shared_subject
    def error_structure(self):
        return self.retrieve_expecting_failure()

    def given_identifier(self):
        return 'FF'

    def given_lines(self):
        return ()


class Case282_too_many_adjacent_same_identifiers(_CommonCase):

    def test_100_message(self):
        es = self.retrieve_expecting_failure()
        _expected = "item 'B' has 3 adjacent tables (2 is max)"
        self.assertEqual(es['reason'], _expected)

    def given_identifier(self):
        return 'B'

    def given_lines(self):
        return selib.unindent("""
        # comment
        [item.A.attributes]
        [item.B.meta]
        [item.B.attributes]
        see-me = "do see me"

        [item.B.attributes]
        see-me = "don't see me"

        """)


class Case284_duplicate_identifiers_can_get_shadowed(_CommonCase):

    # [#864.provision-3.1]: stop at the first one

    def test_200_open_table_line(self):
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
        return selib.unindent("""
        # comment
        [item.A.attributes]
        [item.B.attributes]
        see-me = "do see me"

        [item.C.meta]
        [item.B.attributes]
        see-me = "don't see me"

        """)


class Case290_invalid_toml_gets_thru_coarse_parse_then_parse_fail(_CommonCase):

    """(note we don't actually run this thru a coarse parse)"""

    def test_100_in_general_say_toml_decode_error(self):
        self.assertEqual(self._general_and_specific()[0], 'toml decode error')

    def test_200_in_specific_say_this_one_weird_error(self):
        _expect = "This float doesn't have a leading digit"
        self.assertEqual(self._general_and_specific()[1], _expect)

    @shared_subject
    def _general_and_specific(self):
        return self._structure()['reason'].split(': ')

    @shared_subject
    def _structure(self):
        return self.vendor_parse_expecting_failure()

    def given_entity_body_lines(self):
        return """
        love-potion = number-nine
        """


class Case297_trick_the_coarse_parse_with_valid_toml(_CommonCase):

    def test_100_in_general_say_toml_not_simple_enough(self):
        _expect = 'toml not simple enough'
        self.assertEqual(self._general_and_specific()[0], _expect)

    def test_200_in_specific_say_this_thing_snuck_through(self):
        _expect = "'number-nine' attribute snuck through"
        self.assertEqual(self._general_and_specific()[1], _expect)

    @shared_subject
    def _general_and_specific(self):
        return self.reason_via_expect_input_error().split(': ')

    def given_run(self, listener):
        return self.run_build_vendor_value_index(listener)

    def given_entity_body_lines(self):
        # the below looks like two attributes to the coarse parse but isn't
        return """
        love-potion = '''
        number-nine = "hi"'''
        """


"""the next several cases are ordered such that the "{compound type} not
yet supported" comes first, then the easy cases come second, then the
"multiline strings not yet supported" come third. it may feel like a
narrative disjoint having a break in the "not yet supported" cases; but
the ordering is intentional and reflects the expected relative complexities
of their respective implementations (regression-friendly ordering) because
to detect multiline strings we need to get as far as firing up our ad-hoc
value-expression parser..."""


class Case303_array_not_suported_yet(_CommonCase):

    def test_100(self):
        self.expect_toml_type_not_supported('array')

    def given_run(self, listener):
        return self.run_comment_test_expecting_failure(listener)

    def given_attribute(self):
        return 'array'


class Case309_inline_tables_not_suported_yet(_CommonCase):

    def test_100(self):
        self.expect_toml_type_not_supported('inline table')

    def given_run(self, listener):
        return self.run_comment_test_expecting_failure(listener)

    def given_attribute(self):
        return 'inline-table'


class Case316_the_easy_cases(_CommonCase):

    def test_316_bool_no_comment(self):  # Case316
        self.expect_no_comment_easy('bool-no-comment')

    def test_322_bool_yes_comment(self):  # Case322
        self.expect_yes_comment_easy('bool-yes-comment')

    def test_328_int_no_comment(self):  # Case328
        self.expect_no_comment_easy('int-no-comment')

    def test_334_int_yes_comment(self):  # Case334
        self.expect_yes_comment_easy('int-yes-comment')

    def test_341_float_no_comment(self):  # Case341
        self.expect_no_comment_easy('float-no-comment')

    def test_347_float_yes_comment(self):  # Case347
        self.expect_yes_comment_easy('float-yes-comment')

    def test_353_datetime_no_comment(self):  # Case353
        self.expect_no_comment_easy('datetime-no-comment')

    def test_359_datetime_yes_comment(self):  # Case359
        self.expect_yes_comment_easy('datetime-yes-comment')


class Case366_literal_string_not_yet_supported(_CommonCase):

    def test_100(self):
        self.expect_toml_type_not_supported('literal string')

    def given_run(self, listener):
        return self.run_comment_test_expecting_failure(listener)

    def given_attribute(self):
        return 'single-line-literal-string'


class Case372_multi_line_literal_string_not_yet_supported(_CommonCase):

    def test_100(self):
        self.expect_toml_type_not_supported('multi-line literal string')

    def given_run(self, listener):
        return self.run_comment_test_expecting_failure(listener)

    def given_attribute(self):
        return 'multi-line-literal-string'


class Case378_multi_line_basic_not_yet_supported(_CommonCase):

    def test_100(self):
        self.expect_toml_type_not_supported('multi-line basic string')

    def given_run(self, listener):
        return self.run_comment_test_expecting_failure(listener)

    def given_attribute(self):
        return 'multi-line-basic-string'


class Case384_the_hard_but_money_cases(_CommonCase):

    # these are ones where we parse the string by hand and it works

    def test_384_basic_string_simple(self):  # Case384
        self.expect_no_comment('basic-string-050-simple')

    def test_391_basic_string_empty(self):  # Case391
        self.expect_yes_comment('basic-string-000-empty')

    def test_397_escape(self):  # Case397
        self.expect_yes_comment('basic-string-100-escape')


@memoize
def _comment_tester_one():
    """things to note about this fellow:
        - written so every line passes crude parse (should that be
          necessary. maybe it isnt.)
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
        multi-line-literal-string = '''
        # not comment 1 \u0020'''
        multi-line-basic-string = {orly}
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
    listener = selib.debugging_listener() if True else _no_listener
    mde = _MDE_via_body_lines_string_using_hack(big_s)
    return _comment_tester_via(mde, listener)


def _comment_tester_via(mde, listener):
    return _subject_module().COMMENT_TESTER_VIA_MDE(mde, listener)


def _MDE_via_body_lines_string_using_hack(big_s):
    """
    hmm we don't want to invoke the full power and dependency on the parsing
    logic, so:
    """

    import re
    from kiss_rdb.magnetics_.entity_via_open_table_line_and_body_lines import (
            _MutableDocumentEntity, _AttributeLine,
            _AttributeName, _CommentLine)

    def attribute_name_via_line(line):
        md = re.match('^(?:(#)|([a-z0-9]+(?:-[a-z0-9]+)*) = (.))', line)
        an_s = md[2]
        if an_s is not None:
            _an = _AttributeName(an_s.split('-'))
            return _AttributeLine(_an, md.start(3), line)
        else:
            return _CommentLine(line)

    mde = _MutableDocumentEntity('no open table line object')
    for line in selib.unindent(big_s):
        _line_object = attribute_name_via_line(line)
        mde.append_line_object(_line_object)
    return mde


def _vendor_parse(body_string, listener):
    return _subject_module()._vendor_parse(body_string, listener)


def _subject_module():
    from kiss_rdb.magnetics_ import entity_via_identifier_and_file_lines as _
    return _


def cover_me(msg=None):
    _ = '' if msg is None else f': {msg}'
    raise Exception(f'cover me{_}')


_no_listener = None


if __name__ == '__main__':
    unittest.main()

# #born.
