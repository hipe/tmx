"""this module contains:

it contains:

  - implementation of RETRIEVE as a flip-flop from one to another actions. (!)

  - a byzantine expanse of support code for dealing with detecting whether
    attribute blocks have comments in them, for a safeguard feature.

history:

  - at #history-A.3 this lost hosting of contact with the vendor-parsing lib
  - at #history-A.2 this module became home to RETRIEVE

wishlist:

  - OCD: the RETRIEVE of every non-final doc ent creates a wasted TSLO.
    this could be "fixed" by creating a new actions that sends a stop instead.
"""


from .identifiers_via_file_lines import (  # also as grammar_lib belo
        not_ok, okay, stop,
        )
import re


def entity_via_identifier_and_file_lines(id_s, all_lines, listener):
    """RETRIEVE a document entity given an identifier string and file lines.

    behavior:
      - stop at first match
      - stop searching at first greater than
    """

    return _Main(id_s, all_lines, listener).main()


class _Main:
    """the implementation of the above.

    implementaton:
      - compose a higher-level line-stream parser from a lower-level one
      - amazingly, our state machine allows us to HOT-SWAP the actions #histA4
    """

    def main(self):

        self.find_the_first_table_start_line_equal_or_greater()

        if not self.OK or not self.found:
            return

        self.change_the_parse_actions()

        for appendable_table_block in self._item_itr:  # once
            break

        return appendable_table_block  # (Case253) (again)

    def __init__(self, id_s, all_lines, listener):

        # build our parser "by hand" so we have a handle on the parse state

        from . import identifiers_via_file_lines as grammar_lib

        mon = grammar_lib.ErrorMonitor_(listener)

        _sm = grammar_lib.state_machine_

        ps = _sm.build_parse_state(
                listener=mon.listener,
                actions_class=grammar_lib.Actions_for_ID_Traversal_Non_Validating_,  # noqa: E501
                )

        self._item_itr = ps.items_via_all_lines_(all_lines)

        self._parse_state = ps
        self._target_IID_string = id_s
        self._monitor = mon

    def change_the_parse_actions(self):
        """this is the craziest thing...

        CHANGE THE PARSE ACTIONS MID PARSE (Case253)
        """

        # hack a new parse actions to be as if it has started w/ the new table
        ts = self._table_start
        del(self._table_start)
        from . import blocks_via_file_lines as block_lib
        actions = block_lib.ActionsForCoarseBlockParse_(self._parse_state)
        actions.begin_table_with_(ts)

        # inject into into the LIVE PARSE STATE OMG
        def f(distinct_transition_name):
            return getattr(actions, distinct_transition_name)
        self._parse_state.RECEIVE_ACTION_VIA_TRANSITION_NAME(f)

    def find_the_first_table_start_line_equal_or_greater(self):

        self.found = False
        did_break = False

        target_id_s = self._target_IID_string

        for ts in self._item_itr:
            curr_id_s = ts.identifier_string

            # if exact match (string comparison!), you are done
            if target_id_s == curr_id_s:
                self.found = True
                did_break = True
                break

            # as soon as you ecounter one identifier that is "greater"
            # (numerically or lexically, same thing) than your target, then
            # you don't need to keep searching because you won't ever find it.

            if target_id_s < curr_id_s:
                did_break = True
                break

            """(assume a valid file; i.e., valid identifiers of uniform depth &
            same depth as target. it is in this way that an out-of-order file
            will make some of its entities unretrievable and so is corrupt. but
            per [#864] broad provision 3 it's out-of-scope to check these here.
            here we just assume the file is well-formed & ordered.)
            """

        if not self._monitor.ok:
            # e.g an error in parsing the file. something emitted so it's
            # ugly to also emit that the entity was not found.
            return

        if not self.found:
            _emit_not_found(
                    listener=self._use_listener(),
                    did_traverse_whole_file=not did_break,
                    identifier_string=self._target_IID_string)
            self.OK = False
            return

        if 'attributes' != ts.table_type:
            # future feature 1 - meta tables (Case282)
            _emit_table_type_not_yet_implemented(self._use_listener(), ts)
            self.OK = False
            return

        self._table_start = ts
        self.OK = True

    def _use_listener(self):
        # emit into this listener to get context enhancement
        return self._parse_state.listener


def comment_tester_via_body_blocks_(body_blocks, listener):
    """implement exactly what [#866] exists to describe.

    given a table block, result (if successful) is a function. the function
    is described below, where it is defined.
    """

    # is the would-be document entity (that coarse parsed) actually toml?

    def to_body_line_stream():
        for bb in body_blocks:
            for line in bb.to_line_stream():
                yield line
    _big_string = ''.join(to_body_line_stream())
    dct = _vendor_parse(_big_string, listener)
    if dct is None:
        return  # (Case290)

    # does it look like the coarse parse parsed it correctly?

    if not __check_name_sets(dct, body_blocks, listener):
        return

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

        attr_blk = KV_block_via_attr_name_string[an_s]

        def the_easy_way():
            _yes_no = '#' in attr_blk.line  # straight from the pseudocode
            return (okay, _yes_no)  # #here1

        x = dct[an_s]  # "vendor value"

        if isinstance(x, str):
            # step into the fun part of the problem.
            return __yes_no_string_attribute_line_has_commment(attr_blk, listener)  # noqa: E501
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

    KV_block_via_attr_name_string = {blk.attribute_name_string: blk for blk in body_blocks if blk.is_attribute_block}  # noqa: E501
    import datetime

    return yes_no_attribute_line_has_comment


def __yes_no_string_attribute_line_has_commment(attr_blk, listener):
    """
    YIKES
    """

    if attr_blk.is_multi_line_attribute_block:
        return __yes_no_multi_line_string_attribute_block_has_comment(
                attr_blk, listener)
    else:
        return __yes_no_single_line_string_attribute_block_has_comment(
                attr_blk, listener)


def __yes_no_multi_line_string_attribute_block_has_comment(attr_blk, listener):
    """DISCUSSION: oops we wrote this assuming it was possible to have a

    comment after the closing delimiters in a multi-line string. it appears
    that it is not. so now this is just a contact exercise.
    """

    line = attr_blk.last_line__()

    # get everything in the string beyond the last quote
    needle = attr_blk.which_quote___()
    _offset = line.index(needle)
    the_rest = line[(_offset + len(needle)):]

    if '\n' == the_rest:
        return _there_is_no_comment
    else:
        assert(False)


def __yes_no_single_line_string_attribute_block_has_comment(attr_blk, listener):  # noqa: E501

    # the most interesting part of all this. what [#866] was created for.
    # all of this is a hack and should go away after etc.

    line = attr_blk.line
    position = attr_blk.position_of_start_of_value

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
        assert(False)  # this was (Case378), is now elsewhere

    elif multi_literal is not None:
        assert(False)  # this was (Case366)

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
excerpted verbatim from the toml doc:

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


def __check_name_sets(dct, body_blocks, listener):
    """DISCUSSION:

    .#history-A.4 was when we introduced support for multi-line strings.
    before then, if a big string had a line within it that sorta looked like
    a key-value line, it would get false-positive matched as such.

    back then it was necessary to at detect & bork on this case.

    now this particular circumstance is no longer possible (we think!),
    however we leave this intact because it is a good sanity check for our
    coarse-parse hack.

    this is discusseed in [#866]. (Case303)
    """

    by_coarse = set(o.attribute_name_string for o in body_blocks if o.is_attribute_block)  # noqa: E501
    by_vendor = set(dct.keys())
    extra_by_coarse = by_coarse - by_vendor
    extra_by_vendor = by_vendor - by_coarse

    if len(extra_by_coarse):
        cover_me('this became detached and uncoverable')  # (see 2 lines below)

        def f():
            # (used to get hit by (Case297) before #history-A.4. now cannot.)

            from modality_agnostic.magnetics.rotating_buffer_via_positional_functions import (  # noqa: E501
                    oxford_AND_HELLO_FROM_KISS)

            _ = oxford_AND_HELLO_FROM_KISS(tuple(repr(s) for s in extra_by_coarse))  # noqa: E501
            s = '' if 1 == len(extra_by_coarse) else 's'
            _reason = f'toml not simple enough: {_} attribute{s} snuck through'
            return {'reason': _reason}
        _emit_input_error_via_structurer(f, listener)
        return not_ok

    if len(extra_by_vendor):
        cover_me()

    return okay


def entity_dict_via_entity_big_string__(big_string, listener):
    """most of this is validating etc.

    this will expand when we get to [#864.future-feature-1] meta

    (Case711) (retrieve)
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
            'core_attributes': item_partitions[attrs_key],
            }


def _vendor_parse(big_string, listener):  # #testpoint

    from . import schema_via_file_lines as _
    e, res = _.vendor_parse_toml_or_catch_exception__(big_string)

    # (when the emission throws an exception, it's a bad look unless frame pop)
    if e is None:
        return res
    else:
        # (sad that we can't tell use which line caused the error)
        __emit_toml_decode_error(e, listener)


# == all emissions in one place because why not

def _emit_not_found(listener, did_traverse_whole_file, identifier_string):
    def f():
        if did_traverse_whole_file:
            which = 'not in file'  # (Case263)
        else:
            which = 'not found'  # (Case259)
        return {
                'reason': f'{repr(identifier_string)} { which }',
                'did_traverse_whole_file': did_traverse_whole_file,
                'identifier_string': identifier_string,
                'input_error_type': 'not_found',
                }
    _emit_input_error_via_structurer(f, listener)


def _emit_table_type_not_yet_implemented(listener, ts):

    _pos = (1 + len('item') + 1 + len(ts.identifier_string) + 1 + 1) - 1
    # EEW: '['  'item'       '.'  'ABC'                      '.' 'm' off by one

    _tt = ts.table_type

    def f():
        return {
                'reason': f"table type '{_tt}' not yet implemented",
                'position': _pos,
                }
    _emit_input_error_via_structurer(f, listener)


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


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


# #history-A.4: hot-swap actions. data-model change from line- to block-based
# #history-A.3: the integration for parsing toml with vendor lib is moved
# #history-A.2: house RETRIEVE
# #history-A.1: spike hand-written surface-string string parser
# #born.
