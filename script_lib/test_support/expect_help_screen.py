"""functions (mostly) to help assert over help screeen content at a high level

:[603]
"""

from modality_agnostic.memoization import lazy
import re


def optional_args_index_via_section_index(si):
    return {k: v for k, v in __do_optionals_index(si)}


def section_index_via_lines(unsanitized_strings):
    _tree = __tree_via_unsanitized_strings(unsanitized_strings)
    return __section_index_via_tree(_tree)


def __do_optionals_index(si):
    against = set(si)
    needles = {'options', 'option'}
    these = needles.intersection(against)
    if not len(these):  # #todo
        needles = {'optional arguments', 'optional argument'}
        these = needles.intersection(against)
    key, = these
    for node in __flatten_the_option_section(si[key]):
        _use_s = node.styled_content_string
        o = __option_line_challenge_mode(_use_s)
        yield o.main_long_switch, o


def __flatten_the_option_section(parent_node):

    _header_node, *cx_nodes = parent_node.children
    assert('option' in _header_node.styled_content_string)

    # this sucks and we are not sure what's going on:
    # if there's only one node then assume it's a branch node with a bunch
    # of children nodes, such that each item is a single-line item.

    if 1 == len(cx_nodes):
        only_node, = cx_nodes
        assert(not only_node.is_terminal)
        for node in only_node.children:
            assert(node.is_terminal)
            yield node

    # otherwise, each item might be single line or multiple line. when
    # multiple line, we only want the first line

    for node in cx_nodes:
        if node.is_terminal:
            yield node
            continue

        # not sure how everything parses any more.
        sub_cx_nodes = node.children

        for sub_node in sub_cx_nodes:
            assert(sub_node.is_terminal)

        yield sub_cx_nodes[0]


def positional_args_index_via_section_index(si):
    against = set(si)
    needles = {'arguments', 'sub-commands', 'argument', 'sub-command'}
    these = needles.intersection(against)
    if not len(these):  # #todo
        needles = {'positional arguments', 'positional argument'}
        these = needles.intersection(against)
    key, = these
    _, node = si[key].children  # else needs work
    # we can't know the structure of the above beforehand so we normalize it
    # here by promoting terminals to branch node-ishes (#provision #[#014.A])
    cx = (node,) if node.is_terminal else node.children
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
        if leng is 0:
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


def __tree_via_unsanitized_strings(unsanitized_strings):

    # the following message is from the future
    # before #history-X.X we were using some vendor library to generate help
    # screens. it (not us) flattened our multi-lines messages and also word-
    # wrapped them (?), such that our helps screens were in ONE BIG STRING.
    # now that this testlib is used against our own generated help screens,
    # we no longer have to turn ONE BIG STRING into a line stream.

    leng = len(unsanitized_strings)
    assert(leng)
    if 1 == leng:  # #todo
        big_string, = unsanitized_strings
        assert('\n' in big_string)
        from .expect_treelike_screen import lines_via_big_string
        sanitized_lines = lines_via_big_string(big_string)
    else:
        sanitized_lines = __sanitized_lines_via_unsanitized_strings(
                unsanitized_strings)

    from .expect_treelike_screen import tree_via_lines
    return tree_via_lines(sanitized_lines)


def __section_index_via_tree(tree):
    cx = tree.children
    node_d = {}
    for node in cx:
        _use_s = __header_line_via_node(node)
        match = re.match('^([a-z]+(?:[ -][a-z]+)*):', _use_s)
        if match is not None:
            node_d[match[1]] = node

    return node_d


def __header_line_via_node(node):
    if node.is_terminal:
        use_node = node
    else:
        use_node = node.children[0]
    return use_node.styled_content_string


def __sanitized_lines_via_unsanitized_strings(unsanitized_strings):
    _normal_line_rx = re.compile(r'[^\r\n]*\n\Z')  # _eol
    for unsanitized_string in unsanitized_strings:
        assert(_normal_line_rx.match(unsanitized_string))
        yield unsanitized_string


def _my_exception(msg):  # #copy-pasted
    from script_lib import Exception as MyException
    return MyException(msg)


def cover_me(s):
    raise Exception('cover me - {}'.format(s))


_eol = '\n'

# #born.
