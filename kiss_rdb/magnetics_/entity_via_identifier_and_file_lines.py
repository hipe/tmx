from .identifiers_via_file_lines import (
        ErrorMonitor_,
        not_ok, okay, stop,
        )
import re


"""mainly, be the soul point of contact with the vendor parsing library"""

"""secondarily, a hack for parsing strings to detect in-line comments."""

"""new in this commit, house RETRIEVE (at #history-A.2)"""


def entity_via_identifier_and_file_lines(id_s, all_lines, listener):
    """RETRIEVE a document entity given an identifier string and file lines.

    behavior:
      - stop at first match
      - stop searching at first greater than

    implementation:
      - compose a higher-level line-stream parser from a lower-level one
      - state machine trick of flipping-on line recording
      - one day we will need to expose it maybe
      - functional because we can
    """

    def main():
        tup = validate_for_one_attributes_table()
        if tup is None:
            return
        otl, lines = tup

        from .entity_via_open_table_line_and_body_lines import (
                mutable_document_entity_via_open_table_line_and_body_lines as entity_via)  # noqa: E501
        return entity_via(otl, lines, listener)

    def validate_for_one_attributes_table():
        # (mostly placeholder logic for future feature 1)

        a = contiguous_tables()
        if a is None:
            return

        length = len(a)
        if 1 == length:
            first = a[0]
        elif 2 == length:
            first, second = a
        else:
            __emit_too_many_adjacent_same_identifiers(length, id_s, listener)
            return  # (Case282)

        signature = tuple(tup[0].table_type for tup in a)  # #here3

        if ('attributes',) == signature:
            result = first
        elif ('meta', 'attributes') == signature:
            cover_me()  # future feature 1
        elif ('meta',) == signature:
            cover_me()  # future feature 1
        else:
            # ('attributes', 'meta')
            # ('attributes', 'attributes')
            # ('meta', 'meta')
            cover_me()  # invalid file

        return result

    def contiguous_tables():
        # it's too gross to try to validate well-formedness while messing
        # with capturing body lines. so all we do here is "scoop" all
        # contiguous table-sections from the current point that also have
        # the ID. validate next.

        found_otl = None
        might_be_out_of_order = False
        for otl in otl_itr:
            curr_id_s = otl.identifier_string
            if id_s == curr_id_s:
                found_otl = otl
                break
            if id_s < curr_id_s:
                might_be_out_of_order = True
                break

        if not monitor.ok:
            return  # e.g not well-formed file

        if found_otl is None:
            __emit_not_found(might_be_out_of_order, id_s, listener)
            return

        # the last line that was consumed abve is the first line that matched
        # the argument ID (the open-table line). record the subsequent lines.
        # only once we have begun parsing can we get the parse state (for now)

        parse_state = parse_state_pointer.release_value()

        lines = []

        def f():
            lines.append(parse_state.line)

        parse_state.on_line_do_this(f)

        gulps = []
        do_exclude_last_line = True

        def swallow():
            if do_exclude_last_line:
                lines.pop()
            gulps.append((found_otl, lines))  # :#here3

        do_swallow = True
        for otl in otl_itr:
            swallow()  # once you've gotten to whatever next table
            if id_s == otl.identifier_string:
                found_otl = otl
                lines = []
                continue
            do_swallow = False  # because you traversed and swallowed above
            break

        # we got past the above loop either because there were no more
        # open-table lines OR because (more likely) we found an open table
        # line that didn't match exactly the ID for which we are scooping
        # adjacent tables. whether or not we have to do one extra trailing
        # swallow depends on which.

        if do_swallow:
            do_exclude_last_line = False  # (Case272)
            swallow()

        return gulps

    monitor = ErrorMonitor_(listener)  # see

    # -- begin gross hack to be able to reach in and get parse state

    parse_state_pointer = _Pointer()

    def actionser(ps):
        parse_state_pointer.set_value(ps)
        pa = lower_lib.Actions_for_ID_Traversal_Non_Validating_(ps)

        def f(name):
            return getattr(pa, name)
        return f

    from . import identifiers_via_file_lines as lower_lib
    otl_itr = lower_lib.parse_(all_lines, actionser, monitor.listener)

    # -- end

    return main()


def COMMENT_TESTER_VIA_MDE(mde, listener):
    """implement exactly what [#866] exists to describe.

    given a mutable document entity `mde`, result (if successful) is a
    function. the function is described below, where it is defined.
    """

    line_objects = tuple(mde.TO_BODY_LINE_OBJECT_STREAM())
    build_listener = listener
    del(listener)

    # is the would-be document entity (that coarse parsed) actually toml?

    _big_string = ''.join(lo.line for lo in line_objects)
    dct = _vendor_parse(_big_string, build_listener)
    if dct is None:
        return  # (Case290)

    # does it look like the coarse parse parsed it correctly?

    if not __check_name_sets(dct, line_objects, build_listener):
        return  # (Case297)

    def yes_no_attribute_line_has_comment(an_s, listener):
        """attempt to indicate whether or not an attribute line has a comment.

        attribute name string `an_s` is the "key" string of a key-value
        (attribute) line assumed to exist in the mutuable document entity we
        were constructed around.

        the result is meant to indicate whether the key-value line has an
        inline comment (that is, on the same line).

        because there are more than zero ways this request can be impossible
        to carry out, result is a two-tuple with the familiar semantics of
        the first component signifying ok/not-ok and the second component
        signfiying the payload if ok: in our case a boolean indicating
        whether or not there is a comment on the line.

        :#here1 tags all the places that effect this return shape.
        """

        def the_easy_way():
            _yes_no = '#' in line_object().line  # straight from the pseudocode
            return (okay, _yes_no)  # #here1

        def line_object():
            return line_object_via_ANS[an_s]

        x = dct[an_s]  # "vendor value"

        if isinstance(x, str):
            # step into the fun part of the problem.
            return __zomg_parse_the_string(line_object(), listener)
        elif isinstance(x, bool):  # NOTE test bool before int! is-a
            return the_easy_way()  # (Case316) (Case322)
        elif isinstance(x, int):
            return the_easy_way()  # (Case328) (Case334)
        elif isinstance(x, float):
            return the_easy_way()  # (Case341) (Case347)
        elif isinstance(x, datetime.datetime):
            return the_easy_way()  # (Case353) (Case359)
        elif isinstance(x, list):
            return _toml_type_not_supported('array', listener)  # (Case303)
        elif hasattr(x, 'items'):  # don't reach deep into. (Case309)
            return _toml_type_not_supported('inline table', listener)
        else:
            assert(False)  # that's all the types there is according to the doc

    line_object_via_ANS = {lo.attribute_name.name_string: lo for lo in line_objects if lo.is_attribute_line}  # noqa: E501
    import datetime

    return yes_no_attribute_line_has_comment


def __zomg_parse_the_string(line_object, listener):
    # the most interesting part of all this. what [#866] was created for.
    # all of this is a hack and should go away after etc.

    line = line_object.line
    position = line_object.position_of_start_of_value

    md = _open_quote.match(line, position)
    multi_basic, basic, multi_literal, literal = md.groups()  # #here2
    position = md.end()

    # arbitrarily we'll order these in descending order of expected difficulty

    def _not_yet(type_s):
        sct = _struct_for_toml_type_not_supported(type_s)
        sct['line'] = line
        sct['position'] = position
        _emit_input_error_via_structurer(lambda: sct, listener)
        return stop  # #here1

    if multi_basic is not None:
        return _not_yet('multi-line basic string')  # (Case378)

    elif multi_literal is not None:
        return _not_yet('multi-line literal string')  # (Case366)

    elif literal is not None:
        return _not_yet('literal string')  # (Case372)

    assert(basic)

    # now you know you have a basic string that was parsed by toml..
    # (we might go ahead and assume there must be a close-quote somewhere
    # on this line.)
    # step along each of the zero or more characters in the body of the
    # surface string looking for the first '"' that isn't escaped.

    # simple string: (Case381)  empty string: (Case391)

    while True:
        # advance over any boring characters
        md = _ordinary_run.match(line, position)
        if md is not None:
            position = md.end()

        # (it's possible there were no boring chars to advance over, like
        # in empty string or a run of more than one interesting parts.)

        c = line[position]

        if '"' == c:  # yay! we found the end of the surface string
            position += 1
            break

        # this is a bold declaration: we know the surface form of the string
        # is on one line because this is basic not multi-line basic. we know
        # we are still in the string because we haven't found the close quote.
        # we advanced over any ordinary characters above. therefor (right?)
        # the only thing this could possibly be is an escape sequence:

        assert('\\' == c)  # (Case397)
        position += 1

        md = _escape_tail.match(line, position)

        # we don't care what the escape sequence was actually about! woot
        position = md.end()
    # --

    # assume that every line ends in a '\n' and every '\n' occurs only there.

    # for most lines at this point, `position` points to this newline. BUT:

    # if the line did not end immediately after the close quote, then
    # the only "reasonable" thing that could be after it is a comment.
    # we may be jerks about trailing whitespace here .. or maybe not ..

    _md = _at_end_of_line.match(line, position)
    ws, octothorp = _md.groups()

    if octothorp is None:
        if ws is None:
            return _there_is_no_comment
        else:
            # we're not jerks about it. be consistent with the "easy" things
            return _there_is_no_comment
    else:
        return _there_is_a_comment


_open_quote = re.compile(r'(""")|(")' r"|(''')|(')")  # #here2


# directly from the toml doc: "Any Unicode character may be used except
# those that must be escaped: quotation mark, backslash, and the control
# characters (U+0000 to U+001F, U+007F"

_ordinary_run = re.compile(r'[^"\\\u0000-\u001F\u007F]+')


r"""
excerpted verbatim from the tom doc:

    For convenience, some popular characters have a compact escape sequence.

        \b         - backspace       (U+0008)
        \t         - tab             (U+0009)
        \n         - linefeed        (U+000A)
        \f         - form feed       (U+000C)
        \r         - carriage return (U+000D)
        \"         - quote           (U+0022)
        \\         - backslash       (U+005C)
        \uXXXX     - unicode         (U+XXXX)
        \UXXXXXXXX - unicode         (U+XXXXXXXX)

this regex, in turn, is derived directly from the above:
"""

_escape_tail = re.compile(r'[btnfr"\\]|u\d{4}|U\d{8}')

# ☝️ this is say, these are the *only* strings that can follow a backslash!


# this is to say, at the end of every line is zero or more whitespace
# characters, and then maybe a comment character. (if it is a comment, we
# absolutely do not get into parsing what comes after it!)

_at_end_of_line = re.compile(r'([\t ]+)?(?:(#)|$)')

_there_is_no_comment = (okay, False)
_there_is_a_comment = (okay, True)


def __check_name_sets(dct, line_objects, listener):
    """per [#866], ensure that the two sets of names are the same"""

    by_coarse = set(o.attribute_name.name_string for o in line_objects if o.is_attribute_line)  # noqa: E501
    by_vendor = set(dct.keys())
    extra_by_coarse = by_coarse - by_vendor
    extra_by_vendor = by_vendor - by_coarse

    if len(extra_by_coarse):
        def f():  # (Case297)
            from .state_machine_via_definition import oxford_AND
            _ = oxford_AND(tuple(repr(s) for s in extra_by_coarse))
            s = '' if 1 == len(extra_by_coarse) else 's'
            _reason = f'toml not simple enough: {_} attribute{s} snuck through'
            return {'reason': _reason}
        _emit_input_error_via_structurer(f, listener)
        return not_ok

    if len(extra_by_vendor):
        cover_me()

    return okay


def _entity_dict_via_entity_big_string(big_string, listener):
    """most of this is validating etc.

    this will expand when we get to [#864.future-feature-1] meta
    """

    dct = _vendor_parse(big_string, listener)
    if dct is None:
        return

    item_key, = dct.keys()
    assert('item' == item_key)
    item = dct[item_key]
    id_string, = item.keys()
    item_partitions = item[id_string]
    attrs_key, = item_partitions.keys()
    assert('attributes' == attrs_key)

    return {
            'identifier_string': id_string,
            'in_file_attributes': item_partitions[attrs_key],
            }


def _vendor_parse(big_string, listener):  # #testpoint
    import toml
    e = None
    try:
        res = toml.loads(big_string)
    except toml.TomlDecodeError as e_:
        e = e_
    # (when the emission throws an exception, it's a bad look unless frame pop)
    if e is None:
        return res
    else:
        # (sad that we can't tell use which line caused the error)
        __emit_toml_decode_error(e, listener)


# == all emissions in one place because why not

def __emit_not_found(might_be_out_of_order, id_s, listener):  # (Case259)
    def f():
        if might_be_out_of_order:
            which = 'not found'  # (Case259)
        else:
            which = 'not in file'  # (Case263)
        return {
                'reason': f'{repr(id_s)} { which }',
                'might_be_out_of_order': might_be_out_of_order,
                'identifier_string': id_s,
                'input_error_type': 'not_found',
                }
    _emit_input_error_via_structurer(f, listener)


def __emit_too_many_adjacent_same_identifiers(length, id_s, listener):

    # weird edge errors don't deserve a lot of lines of code :P
    _ = f'item {repr(id_s)} has {length} adjacent tables (2 is max)'
    _emit_input_error_via_reason(_, listener)


def __emit_toml_decode_error(e, listener):

    # (we looked and there doesn't appear to be any metadata in the exception)
    def f():
        return {'reason': f"toml decode error: {str(e)}"}
    _emit_input_error_via_structurer(f, listener)


def _toml_type_not_supported(type_s, listener):
    def f():
        return _struct_for_toml_type_not_supported(type_s)
    _emit_input_error_via_structurer(f, listener)
    return stop  # #here1


def _struct_for_toml_type_not_supported(type_s):
    return {'reason': f"no support (yet) for toml's '{type_s}' type"}


def _emit_input_error_via_reason(reason, listener):
    _emit_input_error_via_structurer(lambda: {'reason': reason}, listener)


def _emit_input_error_via_structurer(f, listener):
    listener('error', 'structure', 'input_error', f)


class _Pointer:
    """we wouldn't need this experimental weirdness if we were doing the

    work in the context of a class (mutable object); but since this one thing
    is the only place there we need this kind of mutability (set a value from
    within a "callback" (function)); we would rather just have this small
    class than add the cognitive weight of a big one. alternative: `nonlocal`
    """

    def __init__(self):
        self._mutex = None

    def set_value(self, x):
        del self._mutex
        self._value = x

    def release_value(self):
        x = self._value
        del self._value
        return x


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


# #history-A.2: house RETRIEVE
# #history-A.1: spike hand-written surface-string string parser
# #born.
