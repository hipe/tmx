"""functions (mostly) to help assert over help screeen content at a high level

:[603]
"""

from modality_agnostic.memoization import lazy
import re


def optional_args_index_via_section_index(si):
    return {k: v for k, v in __do_optionals_index(si)}


def section_index_via_unsanitized_strings_(unsanitized_strings):
    lines = _lines_via_unsanitized_strings(unsanitized_strings)
    cx = _tree_via_lines(lines).children
    return {s.label: cx[s.offset] for s in _sections_via_tree_children(cx)}


class BIG_EXPERIMENTAL_SECTION_INDEX:
    def __init__(self, unsanitized_strings):
        lines = _lines_via_unsanitized_strings(unsanitized_strings)
        self.tree = _tree_via_lines(lines)
        _ = _sections_via_tree_children(self.tree.children)
        self.sections = {s.label: s for s in _}


def __do_optionals_index(si):
    against = set(si)
    needles = {'options', 'option'}
    these = needles.intersection(against)
    if not len(these):  # #todo
        needles = {'optional arguments', 'optional argument'}
        these = needles.intersection(against)
    key, = these
    node = si[key]

    assert('option' in node.head_line.styled_content_string)

    for node in node.children:
        _use_n = node if node.is_terminal else node.head_line
        _use_s = _use_n.styled_content_string
        o = __option_line_challenge_mode(_use_s)
        yield o.main_long_switch, o


def positional_args_index_via_section_index(si):
    against = set(si)
    needles = {'arguments', 'sub-commands', 'argument', 'sub-command'}
    these = needles.intersection(against)
    if not len(these):  # #todo
        needles = {'positional arguments', 'positional argument'}
        these = needles.intersection(against)
    key, = these
    cx = si[key].children
    d = {}
    for ch in cx:
        assert(ch.is_terminal)  # else fine but cover
        _use_s = ch.styled_content_string
        _match = re.search('^([^ ]+)[ ]{2,}', _use_s)  # ..
        d[_match[1]] = ch
    return d


def __option_line_challenge_mode(line_s):
    """EXPERIMENT...

    ... if this proves at all useful it should certainly be abstracted.
    """

    def __main():
        out = {}
        out['main_short_switch'] = __parse_any_short()
        out['main_long_switch'] = __parse_long()
        out['args_tail_of_long'] = __parse_any_args()
        out['desc_lines'] = [desc_first_line]
        _my_tuple = __my_named_tuple_for_above()
        return _my_tuple(**out)

    self = _ThisState()
    self.cursor = 0

    def __parse_any_args():
        if self.cursor is not len(haystack_s):
            return _assert_scan('[ =]([^ ].+)$')  # soften if necessary

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
        if match is None:
            return
        _advance_cursor_to(match.end())
        s_a = match.groups()
        leng = len(s_a)
        if leng == 0:
            return match[0]
        assert(leng == 1)
        # if you use groups in your scan regex,
        # you can only have one group'
        return s_a[0]

    def _skip(rx_s):
        match = _match(rx_s)
        if match is not None:
            cursor_ = match.end()
            width = cursor_ - self.cursor
            _advance_cursor_to(cursor_)
            return width

    def _match(rx_s):
        _regex = re.compile(rx_s)
        return _regex.match(haystack_s, self.cursor)

    def __build_assertion_failure_message(f, rx_s):
        _fmt = 'failed to {verb} /{rx_s}/: {excerpt}'
        fname = f.__name__
        match = re.search('_([a-z]+)$', fname)
        if match is None:
            verb = fname
        else:
            verb = match[1]
        if self.cursor >= len(haystack_s):
            excerpt = '[empty string]'
        else:
            excerpt = '«%s»' % haystack_s[self.cursor:]
        return _fmt.format(verb=verb, rx_s=rx_s, excerpt=excerpt)

    def _advance_cursor_to(num):
        self.cursor = num

    _match_obj = re.search('^((?:[^ ]|[ ](?![ ]))+)(?:[ ]{2,}(.+))?$', line_s)
    haystack_s, desc_first_line = _match_obj.groups()

    return __main()


class _ThisState:  # #[#510.2]
    pass


@lazy
def __my_named_tuple_for_above():
    import collections
    return collections.namedtuple('OptionDescLineTree', [
        'main_short_switch',
        'main_long_switch',
        'args_tail_of_long',
        'desc_lines',
    ])


def _sections_via_tree_children(cx):
    for i in range(0, len(cx)):
        node = cx[i]
        if node.is_terminal:
            if node.is_blank_line:
                continue
            s = node.styled_content_string
        else:
            s = node.head_line.styled_content_string
        md = re.match('^([a-z]+(?:[ -][a-z]+)*):', s)
        if md is None:
            continue
        yield _Section(label=md[1], offset=i)


class _Section:
    def __init__(self, label, offset):
        self.label = label
        self.offset = offset


def _tree_via_lines(lines):
    from .expect_treelike_screen import tree_via_lines
    return tree_via_lines(lines)


def _lines_via_unsanitized_strings(unsanitized_strings):

    # in the past we used a vendor library (click) to generate help
    # screens. it (not us) flattened our multi-lines messages and also word-
    # wrapped them (?), such that our helps screens were in ONE BIG STRING.
    # now that this testlib is used against our own generated help screens,
    # we no longer have to turn ONE BIG STRING into a line stream.

    leng = len(unsanitized_strings)
    assert(leng)
    if 1 == leng:  # #todo
        big_string, = unsanitized_strings
        assert(_eol in big_string)
        from script_lib import lines_via_big_string
        return lines_via_big_string(big_string)

    return __sanitized_lines_via_unsanitized_strings(unsanitized_strings)


def __sanitized_lines_via_unsanitized_strings(unsanitized_strings):
    _normal_line_rx = re.compile(r'[^\r\n]*\n\Z')  # _eol
    for unsanitized_string in unsanitized_strings:
        assert(_normal_line_rx.match(unsanitized_string))
        yield unsanitized_string


def _my_exception(msg):  # #copy-pasted
    from script_lib import Exception as MyException
    return MyException(msg)


_eol = '\n'

# #born.
