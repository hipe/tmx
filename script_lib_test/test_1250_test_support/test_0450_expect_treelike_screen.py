"""expect treelike screen

this is #meta-testing
"""

from script_lib import Exception as MyException
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        lazy)
import unittest


class _NormalLinerCase(unittest.TestCase):

    # -- assertion

    def _this_many_lines(self, num):
        _s_a = self.lines()
        self.assertEqual(num, len(_s_a))


class Case0437_empty_string(_NormalLinerCase):

    def test_010_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_020_zero_lines(self):
        self._this_many_lines(0)

    @shared_subject
    def lines(self):
        return line_tuple_via_big_string('')  # EMPTY_S


class Case0440_one_string_no_newline(_NormalLinerCase):

    def test_010_loads(self):
        self.assertIsNotNone(_subject_module())

    def test_020_one_line__content_OK(self):
        self.assertSequenceEqual(self.lines(), ('foo',))

    @shared_subject
    def lines(self):
        return line_tuple_via_big_string('foo')


class Case0443_one_string_yes_newline(_NormalLinerCase):

    def test_010_one_line__content_OK(self):
        self.assertSequenceEqual(self.lines(), ('foo\n',))

    @shared_subject
    def lines(self):
        return line_tuple_via_big_string("foo\n")


class Case0446_blank_lines_inside(_NormalLinerCase):

    def test_010_three_lines__content_OK(self):
        self.assertSequenceEqual(self.lines(), ('foo\n', '\n', 'bar\n'))

    @shared_subject
    def lines(self):
        return line_tuple_via_big_string("foo\n\nbar\n")


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


class Case0449_scanner_via_iterator(_CommonCase):

    def test_020_empty_knows_it_is_empty(self):
        _scn = self._build_empty()
        self.assertFalse(_scn.has_current_token)

    def test_030_do_not_ask_for_current_token_on_empty_scanner(self):
        _scn = self._build_empty()
        e = None
        try:
            _scn.current_token
        except AttributeError as _e:
            e = _e
        _ = "'_scanner_via_iterator' object has no attribute 'current_token'"
        self.assertEqual(_, str(e))

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
        self.assertSequenceEqual(act_num_a, num_a)

    def _build_empty(self):
        return self._subject_function(_empty_iterator())

    @property
    def _subject_function(self):
        return _subject_module()._scanner_via_iterator


# Case0450  # #midpoint


class Case0452_nonplural_inputs(_CommonCase):

    def test_010_zero_lines(self):
        _x = _tree_via_lines(_empty_iterator())
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


class Case0455_these_errors(_CommonCase):

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
            _tree_via_lines(iter([input_s]))
        except MyException as _e:
            e = _e
        self.assertEqual(exp_s, str(e))


class Case0458_two_lines_no_indent(_CommonCase):

    def test_010_tree_builds(self):
        self.assertIsNotNone(self._tree)

    def test_020_this_is_NOT_seen_as_two_toplevel_items_but_multiple_lines_of_a_section(self):  # noqa: E501
        t = self._tree
        self._assertThisManyChildren(2, t)
        _act = [self._styled_content_string(x) for x in self._children_of(t)]
        self.assertSequenceEqual(_act, ('one', 'two'))

    @property
    @shared_subject
    def _tree(self):
        _doc_s = """
            one
            two
        """
        return _tree_via_docstring(_doc_s)


class Case0461_introduce_less_indent(_CommonCase):

    def test_010_tree_builds(self):
        self.assertIsNotNone(self._tree)

    def test_020_structure(self):
        actual = debugging_strings_for_tree(self._tree)
        expected = deindented_strings("""
            one
            > two
            > > three
            > four
        """)
        self.assertSequenceEqual(actual, expected)

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


class Case0464_first_target_case(_CommonCase):

    def test_010_tree_builds(self):
        self.assertIsNotNone(self._tree)

    def test_020_structure(self):
        actual = debugging_strings_for_tree(self._tree)
        expected = deindented_strings("""
            very first line

            desc line one
            desc line two
            desc line three

            header of this one section
            > item one
            > > subdesc line 1.two
            > > subdesc line 1.three
            > item two
            > item three
            > > subdesc line 3.two
            > >
            header of this other section
            > one fellow
        """)
        self.assertSequenceEqual(actual, expected)

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


def debugging_strings_for_tree(tree):
    return tuple(_debugging_strings_recurse(tree, 0))


def _debugging_strings_recurse(tree, depth):
    deeper = depth + 1
    for node in tree.children:
        if node.is_terminal:
            yield _string_via_terminal(node, depth)
            continue

        yield _string_via_terminal(node.head_line, depth)

        for string in _debugging_strings_recurse(node, deeper):
            yield string


def _string_via_terminal(terminal, depth):
    pieces = ['>' for _ in range(0, depth)]
    s = terminal.styled_content_string
    if s is not None:
        pieces.append(s)
    return ' '.join(pieces)


def _tree_via_docstring(doc_s):
    _lines = deindented_lines(doc_s)
    return _tree_via_lines(_lines)


def _tree_via_lines(lines):
    return _subject_module().tree_via_lines(lines)


def deindented_lines(big_string):
    from script_lib import deindented_lines_via_big_string_
    return deindented_lines_via_big_string_(big_string)


def deindented_strings(big_string):
    from script_lib import deindented_strings_via_big_string_
    return tuple(deindented_strings_via_big_string_(big_string))


def line_tuple_via_big_string(big_string):
    from script_lib import lines_via_big_string
    return tuple(lines_via_big_string(big_string))


@lazy
def _empty_iterator():
    return iter(())


def _subject_module():
    import script_lib.test_support.expect_treelike_screen as x
    return x


if __name__ == '__main__':
    unittest.main()

# #history-A.1 (as referenced)
# #born.
