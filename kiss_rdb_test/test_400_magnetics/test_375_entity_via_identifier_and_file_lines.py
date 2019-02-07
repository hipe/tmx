import _common_state  # noqa: F401
from kiss_rdb_test import structured_emission as selib
from modality_agnostic.memoization import (
    dangerous_memoize as shared_subject,
    memoize,
    )
import unittest


class _CommonCase(unittest.TestCase):

    def expect_no_comment(self, an_s):
        return self._expect_yes_no_comment(False, an_s)

    expect_no_comment_easy = expect_no_comment

    def expect_yes_comment(self, an_s):
        return self._expect_yes_no_comment(True, an_s)

    expect_yes_comment_easy = expect_yes_comment

    def _expect_yes_no_comment(self, comment_expected_yes_no, an_s):
        listener = selib.debugging_listener() if False else None
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

    def run_build_vendor_value_index(self, listener):
        _ = self.given_entity_body_lines()
        _mde = _MDE_via_body_lines_string_using_hack(_)
        return _comment_tester_via(_mde, listener)

    def run_vendor_parse(self, listener):
        _body_string = self.given_entity_body_lines()
        return _vendor_parse(_body_string, listener)

    def partitions_via_identifier(self, id_s):

        listener = selib.debugging_listener() if False else None
        # set the above to true if it's failing and trying to emit, to debug

        _all_lines = self.given_lines()
        return _subject_module().attributes_via_identifier_and_file_lines(
                id_s, _all_lines, listener)  # noqa: E501

    def expect_reason(self, reason):
        _actual_reason = self.reason_via_expect_input_error()
        self.assertEqual(_actual_reason, reason)

    def reason_via_expect_input_error(self):
        return self.structure_via_expect_input_error()['reason']

    def structure_via_expect_input_error(self):
        chan, structurer = self._expect_one_emisson_given_run()
        self.assertEqual(chan, ('error', 'structure', 'input_error'))
        return structurer()

    def _expect_one_emisson_given_run(self):
        def listener(*a):
            nonlocal count
            nonlocal last_emission
            if 0 < count:
                self.fail('more than one emission')
            count += 1
            last_emission = a
        count = 0
        last_emission = None
        x = self.given_run(listener)
        if not count:
            self.fail('expected one emission, had none')
        self.assertIsNone(x)
        *chan, payloader = last_emission
        chan = tuple(chan)
        return (chan, payloader)


class Case100_not_at_end_of_file(_CommonCase):

    def test_010_the_identifier_is_in_there(self):
        self.assertEqual(self.entity_partitions()['identifier_string'], 'B')

    def test_020_the_attributes_are_in_there(self):
        self.assertTrue(_in_file_attributes in self.entity_partitions())

    def test_030_the_first_one_is_the_one_that_was_resulted(self):
        o = self.entity_partitions()[_in_file_attributes]
        self.assertEqual(o['see-me'], 'do see me')

    @shared_subject
    def entity_partitions(self):
        return self.partitions_via_identifier('B')

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


# #todo: cover at end of file


class Case125_invalid_toml_gets_thru_coarse_parse_then_parse_fail(_CommonCase):

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
        return self.structure_via_expect_input_error()

    def given_run(self, listener):
        return self.run_vendor_parse(listener)

    def given_entity_body_lines(self):
        return """
        love-potion = number-nine
        """


class Case175_trick_the_coarse_parse_with_valid_toml(_CommonCase):

    def test_100_in_general_say_toml_not_simple_enough(self):
        _expect = 'toml not simple enough'
        self.assertEqual(self._general_and_specific()[0], _expect)

    def test_100_in_specific_say_this_thing_snuck_through(self):
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


class Case225_array_not_suported_yet(_CommonCase):

    def test_100(self):
        self.expect_toml_type_not_supported('array')

    def given_run(self, listener):
        return self.run_comment_test_expecting_failure(listener)

    def given_attribute(self):
        return 'array'


class Case275_inline_tables_not_suported_yet(_CommonCase):

    def test_100(self):
        self.expect_toml_type_not_supported('inline table')

    def given_run(self, listener):
        return self.run_comment_test_expecting_failure(listener)

    def given_attribute(self):
        return 'inline-table'


class Case325_the_easy_cases(_CommonCase):

    def test_325_bool_no_comment(self):
        self.expect_no_comment_easy('bool-no-comment')

    def test_375_bool_yes_comment(self):
        self.expect_yes_comment_easy('bool-yes-comment')

    def test_425_int_no_comment(self):
        self.expect_no_comment_easy('int-no-comment')

    def test_475_int_yes_comment(self):
        self.expect_yes_comment_easy('int-yes-comment')

    def test_525_float_no_comment(self):
        self.expect_no_comment_easy('float-no-comment')

    def test_575_float_yes_comment(self):
        self.expect_yes_comment_easy('float-yes-comment')

    def test_625_datetime_no_comment(self):
        self.expect_no_comment_easy('datetime-no-comment')

    def test_675_datetime_yes_comment(self):
        self.expect_yes_comment_easy('datetime-yes-comment')


class Case725_literal_string_not_yet_supported(_CommonCase):

    def test_100(self):
        self.expect_toml_type_not_supported('literal string')

    def given_run(self, listener):
        return self.run_comment_test_expecting_failure(listener)

    def given_attribute(self):
        return 'single-line-literal-string'


class Case775_multi_line_literal_string_not_yet_supported(_CommonCase):

    def test_100(self):
        self.expect_toml_type_not_supported('multi-line literal string')

    def given_run(self, listener):
        return self.run_comment_test_expecting_failure(listener)

    def given_attribute(self):
        return 'multi-line-literal-string'


class Case825_multi_line_basic_not_yet_supported(_CommonCase):

    def test_100(self):
        self.expect_toml_type_not_supported('multi-line basic string')

    def given_run(self, listener):
        return self.run_comment_test_expecting_failure(listener)

    def given_attribute(self):
        return 'multi-line-basic-string'


class Case875_the_hard_but_money_cases(_CommonCase):

    # these are ones where we parse the string by hand and it works

    def test_875_NAME_ME(self):
        self.expect_no_comment('basic-string-050-simple')

    def test_925_NAME_ME(self):
        self.expect_yes_comment('basic-string-000-empty')

    def test_975_escape(self):
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

    # #todo: these forms broke in python
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


_in_file_attributes = 'in_file_attributes'
_no_listener = None


if __name__ == '__main__':
    unittest.main()

# #born.
