"""expect treelike screen

this is #meta-testing
"""

import os, sys, unittest

# boilerplate
_ = os.path
path = _.dirname(_.dirname(_.dirname(_.abspath(__file__))))
a = sys.path
if a[0] != path:
    a.insert(0, path)
# end boilerplate


from game_server_test import helper
shared_subject = helper.shared_subject


import game_server
memoize = game_server.memoize


class _NormalLinerCase(unittest.TestCase):

    # -- assertion

    def _this_many_lines(self, num):
        _s_a = self._lines()
        self.assertEqual(num, len(_s_a))

    def _lines_via_big_string(self, big_s):
        _iter = _subject_module().line_stream_via_big_string(big_s)
        return [ x for x in _iter ]


class Case010_empty_string(_NormalLinerCase):

    def test_010_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_020_zero_lines(self):
        self._this_many_lines(0)

    @shared_subject
    def _lines(self):
        return self._lines_via_big_string('')  # EMPTY_S


class Case020_one_string_no_newline(_NormalLinerCase):

    def test_010_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_020_one_line__content_OK(self):
        _s_a = self._lines()
        self.assertEqual(['foo'], _s_a)

    @shared_subject
    def _lines(self):
        return self._lines_via_big_string('foo')


class Case030_one_string_yes_newline(_NormalLinerCase):

    def test_010_one_line__content_OK(self):
        _s_a = self._lines()
        self.assertEqual(["foo\n"], _s_a)

    @shared_subject
    def _lines(self):
        return self._lines_via_big_string("foo\n")


class Case040_blank_lines_inside(_NormalLinerCase):

    def test_010_three_lines__content_OK(self):
        _s_a = self._lines()
        self.assertEqual(["foo\n", "\n", "bar\n"], _s_a)

    @shared_subject
    def _lines(self):
        return self._lines_via_big_string("foo\n\nbar\n")


class _CommonCase(unittest.TestCase):

    def _assertStyledContentString(self, exp_s, terminal):
        _act_s = self._styled_content_string(terminal)
        self.assertEqual(exp_s, _act_s)

    def _styled_content_string(self, ch):
        self.assertTrue(ch.is_terminal)  # catch this early
        return ch.styled_content_string

    def _nth_child(self, offset, t):
        return t.children[offset]

    def _assertThisManyChildren(self, num, t):
        self.assertFalse(t.is_terminal)  # catch this early
        self.assertEqual(num, len(t.children))

    def _children_of(self, t):
        # (give ourselves room to change this aspect (privatize, etc))
        return t.children


class Case110_scanner_via_iterator(_CommonCase):

    def test_020_empty_knows_it_is_empty(self):
        _scn = self._build_empty()
        self.assertFalse(_scn.has_current_token)

    def test_030_do_not_ask_for_current_token_on_empty_scanner(self):
        _scn = self._build_empty() ; e = None
        try:
            _scn.current_token
        except AttributeError as _e:
            e = _e
        self.assertEqual("'_scanner_via_iterator' object has no attribute 'current_token'", str(e))

    def test_040_one_item(self):
        self._same_fam(123)

    def test_050_two_items(self):
        self._same_fam(456, 789)

    def _same_fam(self, *num_a):
        scn = self._subject_function(iter(num_a))
        act_num_a = []
        while scn.has_current_token:
            act_num_a.append(scn.current_token)
            scn.advance_by_one_token()
        self.assertEqual([x for x in num_a], act_num_a)

    def _build_empty(self):
        return self._subject_function(_empty_iterator())

    @property
    def _subject_function(self):
        return _subject_module()._scanner_via_iterator


class Case210_nonplural_inputs(_CommonCase):

    def test_010_zero_lines(self):
        _x = _tree_via_line_stream(_empty_iterator())
        self.assertIsNone(_x)

    def test_020_one_line_builds(self):
        self.assertIsNotNone(self._tree)

    def test_025_one_line_parses_as_if_expecting_branch_node(self):
        t = self._tree
        self._assertThisManyChildren(1, t)
        _ch = self._nth_child(0, t)
        self._assertStyledContentString('ohai only line', _ch)

    @property
    @shared_subject
    def _tree(self):
        _doc_s = """
            ohai only line
        """
        return _tree_via_docstring(_doc_s)


class Case220_these_errors(_CommonCase):

    def test_010_a_blank_line_with_extra_whitespace(self):
        self._expect_this_one_error_from_this_one_line(
            "blank line with trailing whitespace is frowned upon: ' \\n'",
            " \n",
        )

    def test_020_tabs_no_can_do_for_now(self):
        self._expect_this_one_error_from_this_one_line(
            'tabs are gonna be annoying because math',
            "\tohai\n",
        )

    def _expect_this_one_error_from_this_one_line(self, exp_s, input_s):
        e = None
        try:
            _tree_via_line_stream(iter([input_s]))
        except game_server.Exception as _e:
            e = _e
        self.assertEqual(exp_s, str(e))


class Case230_cover_edge__end_of_input_during_branch(_CommonCase):

    def test_010_tree_builds(self):
        self.assertIsNotNone(self._tree)

    def test_020_this_is_NOT_seen_as_two_toplevel_items_but_multiple_lines_of_a_section(self):
        t = self._tree
        self._assertThisManyChildren(1, t)
        t, = self._children_of(t)
        _act = [ self._styled_content_string(x) for x in self._children_of(t) ]
        _exp = [ 'one', 'two' ]
        self.assertEqual(_exp, _act)

    @property
    @shared_subject
    def _tree(self):
        _doc_s = """
            one
            two
        """
        return _tree_via_docstring(_doc_s)


class Case240_cover_edge__indet_to_indet(_CommonCase):

    def test_010_tree_builds(self):
        self.assertIsNotNone(self._tree)

    def test_020_look_upon_this_beautiful_structure(self):
        # if you refactor and this test is cumbersome, consider #here1
        t = self._tree
        self._assertThisManyChildren(1, t)
        one_t, = self._children_of(t)
        self._assertThisManyChildren(3, one_t)
        one, two_t, four = self._children_of(one_t)
        self._assertThisManyChildren(2, two_t)
        two, three = self._children_of(two_t)
        self._assertStyledContentString('one', one)
        self._assertStyledContentString('two', two)
        self._assertStyledContentString('three', three)
        self._assertStyledContentString('four', four)

    @property
    @shared_subject
    def _tree(self):
        _doc_s = """
            one
              two
                three
              four
        """
        return _tree_via_docstring(_doc_s)


class Case250_first_target_case(_CommonCase):  # #coverpoint1.1

    def test_010_tree_builds(self):
        self.assertIsNotNone(self._tree)

    def test_020_section_one_is_itself_terminal(self):
        t = self._tree
        self._assertThisManyChildren(4, t)
        section_one = self._nth_child(0, t)
        self._assertStyledContentString('very first line', section_one)

    def test_030_section_four_EXPERIMENTAL_FLATNESS(self):
        _section_four = self._nth_child(3, self._tree)
        self._assert_all_terminals(_section_four,
            'header of this other section',
            'one fellow',
        )

    def test_040_section_two_consists_of_three_terminals(self):
        _section_two = self._nth_child(1, self._tree)
        self._assert_all_terminals(_section_two,
            'desc line one',
            'desc line two',
            'desc line three',
        )

    def test_050_section_three_EXPERMENTAL_FLATNESS_FURTHER(self):
        section_three = self._nth_child(2, self._tree)
        self._assertThisManyChildren(4, section_three)
        _1, _2, _3, _4 = self._children_of(section_three)
        self._assertStyledContentString('header of this one section', _1)
        self._assertStyledContentString('item two', _3)

        # at first glance we don't love what's going on here: look how
        # 'item one' and 'item three' look structurally similar in the
        # input, but in the parse tree they are structurally different.

        # the trick seems to be that there must be at least 2 items
        # to justify making a branch node.

        self._assert_all_terminals(_4,
            'item three',
            'subdesc line 3.two',
        )

        self._assertThisManyChildren(2, _2)
        one, the_rest = self._children_of(_2)
        self._assertStyledContentString('item one', one)
        self._assert_all_terminals(the_rest,
            'subdesc line 1.two',
            'subdesc line 1.three',
        )

    def _assert_all_terminals(self, br, *s_a):
        _act = [self._styled_content_string(x) for x in self._children_of(br)]
        self.assertEqual(list(s_a), _act)

    @property
    @shared_subject
    def _tree(self):
        _doc_s = """
            very first line

            desc line one
            desc line two
            desc line three

            header of this one section
              item one
                subdesc line 1.two
                subdesc line 1.three
              item two
              item three
                subdesc line 3.two

            header of this other section
              one fellow
        """
        return _tree_via_docstring(_doc_s)


def _line_stream_for_testing_via_tree(tree):  # :#here1

    # (near #history-A.1 this seemed to work. but it is not covered.)

    def _scanner_via_branch(branch):
        return _scanner_via_iterator(iter(branch.children))
    _scanner_via_iterator = _subject_module()._scanner_via_iterator

    stack = [ _scanner_via_branch(tree) ]

    def f():
        return g()

    def g():
        frm = stack[-1]
        use_stack_depth = len(stack) - 1
        while not frm.current_token.is_terminal:
            frm = _scanner_via_branch(frm.current_token)
            stack.append(frm)
            use_stack_depth += 1

        term = frm.current_token

        while True:
            frm.advance_by_one_token()
            if frm.has_current_token:
                break
            stack.pop()
            if len(stack) is 0:
                nonlocal g
                g = lambda: None
                break
            frm = stack[-1]

        return ('> ' * use_stack_depth) + term.styled_content_string

    class _Wtf:
        def __init__(self):
            self._function = f

        def __iter__(self):
            return self

        def __next__(self):
            x = self._function()
            if x is None:
                del self._function
                raise StopIteration
            else:
                return x

    return iter(_Wtf())


def _tree_via_docstring(doc_s):
    _line_stream = _line_stream_via_docstring(doc_s)
    return _tree_via_line_stream(_line_stream)


def _tree_via_line_stream(line_stream):
    return _subject_module().tree_via_line_stream(line_stream)


def _line_stream_via_docstring(big_s):
    """de-indent our doc-strings"""

    import re
    match = re.search('^\n([ ]+)', big_s)
    _how_many_spaces = len(match[1])

    _yikes_re_s = '(?:[ ]{%d}|)([^\n]*\n)' % _how_many_spaces

    iter = re.finditer(_yikes_re_s, big_s)
    next(iter)  # skip the very first "\n" that is right after the """

    return (match[1] for match in iter)


@memoize
def _empty_iterator():
    return iter(())


def _subject_module():
    import game_server_test.expect_treelike_screen as x
    return x


if __name__ == '__main__':
    unittest.main()

# #history-A.1 (as referenced)
# #pending-rename: move to 'meta-tests'
# #born.
