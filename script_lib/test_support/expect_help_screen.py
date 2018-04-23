"""functions (mostly) to help asssert over help screeen content at a high level
"""

from modality_agnostic.memoization import (
        memoize,
        )

import re


def optional_args_index_via_section_index(si):
    cx = si['optional arguments'].children
    None if len(cx) == 2 else cover_me('needs work')
    cx = cx[1].children
    d = {}
    for ch in cx:
        None if ch.is_terminal else cover_me('fine but cover')
        _use_s = ch.styled_content_string
        o = __option_line_challenge_mode(_use_s)
        d[o.main_long_switch] = o
    return d


def positional_args_index_via_section_index(si):
    cx = si['positional arguments'].children
    None if len(cx) == 2 else cover_me('needs work')
    xch = cx[1]
    # we can't know the structure of the above beforehand so we normalize it
    # here by promoting terminals to branch node-ishes (#provision #[#014.A])
    if xch.is_terminal:
        cx = [xch]
    else:
        cx = cx[1].children
    d = {}
    for ch in cx:
        None if ch.is_terminal else cover_me('fine but cover')
        _use_s = ch.styled_content_string
        _match = re.search('^([^ ]+)[ ]{2,}', _use_s)  # ..
        d[_match[1]] = ch
    return d


def __option_line_challenge_mode(line_s):
    """EXPERIMENT...

    ... if this proves at all useful it should certainly be abstracted.
    note there is only a single would-be member variable (nonlocal).
    """

    def __main():
        out['main_short_switch'] = __parse_any_short()
        out['main_long_switch'] = __parse_long()
        out['args_tail_of_long'] = __parse_any_args()
        out['desc_lines'] = [desc_first_line]
        _my_tuple = __my_named_tuple_for_above()
        return _my_tuple(**out)

    def __parse_any_args():
        if cursor is not len(haystack_s):
            return _assert_scan('[ ]([^ ].+)$')  # soften if necessary

    def __parse_long():
        return _assert_scan('--[a-z]+(?:-[a-z]+)*')  # ..

    def __parse_any_short():
        s = _scan('-[a-z]')
        if s is not None:
            _assert_skip(',[ ]')
            return s
    # --

    def assertify(f):
        """(decorator...)"""

        def g(rx_s):
            x = f(rx_s)
            if x is None:
                _msg = __build_assertion_failure_message(f, rx_s)
                raise _my_exception(_msg)
            else:
                return x
        return g

    @assertify
    def _assert_scan(rx_s):
        return _scan(rx_s)

    @assertify
    def _assert_skip(rx_s):
        return _skip(rx_s)

    def _scan(rx_s):
        match = _match(rx_s)
        if match is not None:
            _advance_cursor_to(match.end())
            s_a = match.groups()
            num = len(s_a)
            if num is 0:
                return match[0]
            elif num is 1:
                return s_a[0]
            else:
                cover_me(
                      'if you use groups in your scan regex, ' +
                      'you can only have one group')

    def _skip(rx_s):
        match = _match(rx_s)
        if match is not None:
            cursor_ = match.end()
            width = cursor_ - cursor
            _advance_cursor_to(cursor_)
            return width

    def _match(rx_s):
        _regex = re.compile(rx_s)
        return _regex.match(haystack_s, cursor)

    def __build_assertion_failure_message(f, rx_s):
        _fmt = 'failed to {verb} /{rx_s}/: {excerpt}'
        fname = f.__name__
        match = re.search('_([a-z]+)$', fname)
        if match is None:
            verb = fname
        else:
            verb = match[1]
        if cursor >= len(haystack_s):
            excerpt = '[empty string]'
        else:
            excerpt = '«%s»' % haystack_s[cursor:]
        return _fmt.format(verb=verb, rx_s=rx_s, excerpt=excerpt)

    def _advance_cursor_to(num):
        nonlocal cursor
        cursor = num

    _match_obj = re.search('^((?:[^ ]|[ ](?![ ]))+)(?:[ ]{2,}(.+))?$', line_s)
    haystack_s, desc_first_line = _match_obj.groups()

    out = {}
    cursor = 0

    return __main()


@memoize
def __my_named_tuple_for_above():
    import collections
    return collections.namedtuple('OptionDescLineTree', [
        'main_short_switch',
        'main_long_switch',
        'args_tail_of_long',
        'desc_lines',
    ])


def section_index_via_chunks(s_a):

    None if len(s_a) == 1 else cover_me('see me')
    # ☝️ would require a flat map; read: lowlevel stream tooling & testing

    import script_lib.test_support.expect_treelike_screen as mod
    _line_st = mod.line_stream_via_big_string(s_a[0])
    tree = mod.tree_via_line_stream(_line_st)
    cx = tree.children
    node_d = {}
    for node in cx:
        _use_s = __header_line_via_node(node)
        match = re.search('(^[a-z]+(?:[ ][a-z]+)?):', _use_s)
        if match is not None:
            node_d[match[1]] = node

    return node_d


def __header_line_via_node(node):
    if node.is_terminal:
        use_node = node
    else:
        use_node = node.children[0]
    return use_node.styled_content_string


def help_screen_chunks_via_test_case(tc):  # tc=test case

    _cmd = tc.command_module_()

    import script_lib.magnetics.interpretation_via_parse_stepper as _mag

    def _do_debug():
        return tc.do_debug

    def _debug_IO():
        import sys
        return sys.stderr

    mock_IO = _QuickDirty_IO_Mock(_do_debug, _debug_IO)

    _oo = _mag.interpretationer_via_individual_resources(
        ARGV=['ohai', 'my-command', '--help'],
        stdout=None,
        stderr=mock_IO,
    )

    rslt = _oo.interpretation_via_command_stream([_cmd])
    tc.assertFalse(rslt.OK)
    tc.assertEqual(0, rslt.exitstatus)
    return mock_IO.flush_chunks()


class _QuickDirty_IO_Mock():
    """this is an IO mock for a single use-case. there are others like it..

    but this one is ours. (we can of course abstract this as necessary, but
    why?
    """

    def __init__(self, do_debug_f, debug_IO_f):
        self._do_debug_function = do_debug_f
        self._debug_IO_function = debug_IO_f
        self._chunks = []

    def write(self, s):
        if self._do_debug_function():
            io = self._debug_IO_function()
            io.write("(begin help screen chunk)\n")
            io.write(s)
            io.write("(end help screen chunk)\n")
        self._chunks.append(s)
        return len(s)

    def flush_chunks(self):
        s_a = self._chunks
        del self._chunks
        return s_a


def _my_exception(msg):  # #copy-pasted
    from script_lib import Exception as MyException
    return MyException(msg)


def cover_me(s):
    raise Exception('cover me - {}'.format(s))

# #born.
