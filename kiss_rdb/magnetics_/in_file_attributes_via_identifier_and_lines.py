from .items_via_toml_file import (
        not_ok, okay, stop, nothing,
        )
from . import items_via_toml_file as trav_lib
import re

"""mainly, be the soul point of contact with the vendor parsing library"""

"""secondarily, a hack for parsing strings to detect in-line comments."""


def in_file_attributes_via(id_s, all_lines, listener):

    def actionser(ps):
        def f(name):
            return getattr(actions, name)
        actions = _ActionsforRetrieveWithInFileAttributes(id_s, ps)
        return f

    _ = trav_lib.parse_(all_lines, actionser, listener)

    did_find = False
    for partitions_dct in _:
        did_find = True
        break  # per [#864.provision-3.1] stop at the first one

    if did_find:
        return partitions_dct
    else:
        cover_me()


class _ActionsforRetrieveWithInFileAttributes:

    def __init__(self, id_s, parse_state):
        self._on_section_start = self._on_section_start_while_searching
        self._identifier_string = id_s
        self._ps = parse_state

    def on_section_start(self):
        return self._on_section_start()

    def _on_section_start_while_searching(self):
        o = self._ps
        tup = trav_lib.item_section_line_via_line_(o.line, o.listener)
        if tup is None:
            return stop

        # we are not validating. we are simply waiting for that first section
        # line that is of the right type and a matching ID string

        id_s, which = tup
        if 'attributes' == which:
            if self._identifier_string == id_s:
                self._wahoo_change_modes()
                return nothing
            else:
                return nothing
        elif 'meta' == which:
            return nothing
        else:
            sanity()

    def _wahoo_change_modes(self):
        self._on_section_start = self._on_section_start_while_consuming
        ps = self._ps
        lines_of_interest = [ps.line]

        def f():
            lines_of_interest.append(ps.line)
        ps.on_line_do_this(f)
        self._lines_of_interest = lines_of_interest

    def _on_section_start_while_consuming(self):
        self._lines_of_interest.pop()  # wee
        return self._same_close()

    def at_end_of_input(self):
        cover_me()
        return self._same_close()

    def _same_close(self):
        del self._on_section_start
        _line_list = self._lines_of_interest
        _big_string = ''.join(_line_list)
        x = _entity_dict_via_entity_big_string(_big_string, self._ps.listener)
        if x is None:
            cover_me()
        return (okay, x)


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
        return  # (Case125)

    # does it look like the coarse parse parsed it correctly?

    if not __check_name_sets(dct, line_objects, build_listener):
        return  # (Case175)

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
            return the_easy_way()  # (Case325) (Case375)
        elif isinstance(x, int):
            return the_easy_way()  # (Case425) (Case475)
        elif isinstance(x, float):
            return the_easy_way()  # (Case525) (Case575)
        elif isinstance(x, datetime.datetime):
            return the_easy_way()  # (Case625) (Case675)
        elif isinstance(x, list):
            return _toml_type_not_supported('array', listener)  # (Case225)
        elif hasattr(x, 'items'):  # don't reach deep into. (Case275)
            return _toml_type_not_supported('inline table', listener)  # (Case)
        else:
            sanity()  # that's all the types there is, right? according to etc

    line_object_via_ANS = {lo.attribute_name.to_name_string(): lo for lo in line_objects if lo.is_attribute_line}  # noqa: E501
    import datetime

    return yes_no_attribute_line_has_comment


def __zomg_parse_the_string(line_object, listener):
    # the most interesting part of all this. what [#866] was created for.
    # all of this is a hack and should go away after etc.

    line = line_object.line

    # we wish we had the position of the start of the value instead of etc
    line_object._CHANGE_THIS_HERE
    position = re.match('[a-zA-Z0-9-]+ = ', line).end()

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
        return _not_yet('multi-line basic string')  # (Case825)

    elif multi_literal is not None:
        return _not_yet('multi-line literal string')  # (Case775)

    elif literal is not None:
        return _not_yet('literal string')  # (Case725)

    assert(basic)

    # now you know you have a basic string that was parsed by toml..
    # (we might go ahead and assume there must be a close-quote somewhere
    # on this line.)
    # step along each of the zero or more characters in the body of the
    # surface string looking for the first '"' that isn't escaped.

    # empty string: (Case925)  simple string: (Case875)

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

        None if '\\' == c else sanity()  # (Case975)
        position += 1

        md = _escape_tail.match(line, position)

        sanity() if md is None else None

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

    by_coarse = set(o.attribute_name.to_name_string() for o in line_objects if o.is_attribute_line)  # noqa: E501
    by_vendor = set(dct.keys())
    extra_by_coarse = by_coarse - by_vendor
    extra_by_vendor = by_vendor - by_coarse

    if len(extra_by_coarse):
        def f():  # (Case175)
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
    None if 'item' == item_key else sanity()
    item = dct[item_key]
    id_string, = item.keys()
    item_partitions = item[id_string]
    attrs_key, = item_partitions.keys()
    None if 'attributes' == attrs_key else sanity()

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


def cover_me():
    raise Exception('cover me')


def sanity():
    raise Exception('sanity')

# #pending-rename: come up with something more .. idiomatic, like "document entity attributes via identifier" or somesuch  # noqa: E501
# #history-A.1: spike hand-written surface-string string parser
# #born.
