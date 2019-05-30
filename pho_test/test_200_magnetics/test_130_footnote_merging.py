from _common_state import cover_me  # noqa: F401
from pho_test import document_state as doc_state_lib
from modality_agnostic.memoization import dangerous_memoize as shared_subject
import unittest


class _CommonCase(unittest.TestCase):

    def to_document_line_ASTs(self):

        _frags = self.given_fragments()
        _state = doc_state_lib.document_state_via_fragments(_frags)

        for sect in _state.sections:
            for ast in sect.body_line_ASTs:
                yield ast


# (120-139)

class Case122_footnotes_in_just_one_fragment_will_get_normalized(_CommonCase):

    def test_100_footnote_defs_have_IDs_in_order_w_respect_to_each_other(self):
        def f(ast):
            self.assertEqual(ast.symbol_name, 'footnote definition')
            return int(ast.identifier_string)
        a = self._the_last_N_line_ASTs()
        int_itr = (f(ast) for ast in a)
        prev_int = next(int_itr)
        for integer in int_itr:
            expected = prev_int + 1
            self.assertEqual(integer, expected)
            prev_int = integer

    def test_200_footnote_defs_preserved_the_order_of_their_entities(self):
        import re
        rx = re.compile(r'^url_for_([^\n]+)\n$')

        def f(ast):
            md = rx.match(ast.url_probably)
            return md[1]
        _actual = tuple(f(ast) for ast in self._the_last_N_line_ASTs())

        self.assertSequenceEqual(_actual, ('bking', 'here', 'mcdo'))

    def test_300_footnote_defs_now_start_at_number_one(self):
        _ast = self._the_last_N_line_ASTs()[0]
        self.assertEqual(_ast.identifier_string, '1')

    def test_400_the_body_copy_now_uses_the_new_IDs_and_they_are_correct(self):

        def f(ast, s, s_):
            self.assertEqual(ast.symbol_name, 'footnote reference')
            self.assertEqual(ast.label_text, s)
            self.assertEqual(ast.identifier_string, s_)

        first, second, third = self.line_ASTs()[0:3]

        self.assertEqual(second.symbol_name, 'content line')
        self.assertEqual(second.line, 'and also the\n')

        self.assertEqual(first.symbol_name, 'structured content line')

        _1, _2, _3 = first.mixed_children

        self.assertEqual(_1, 'as youths, we enjoyed ')

        f(_2, "McDonald's", '3')

        self.assertEqual(_3, '\n')

        a = third.mixed_children
        f(a[1], 'Burger King', '1')
        f(a[3], 'here', '2')

    def test_500_footnote_defs_now_have_some_blank_lines_in_between(self):
        my_set = set()
        for ast in self.line_ASTs()[-5:-3]:
            my_set.add(ast.symbol_name)
        self.assertSequenceEqual(tuple(my_set), ('empty line',))

    @shared_subject
    def _the_last_N_line_ASTs(self):
        return self.line_ASTs()[-3:]

    @shared_subject
    def line_ASTs(self):
        return tuple(self.to_document_line_ASTs())

    def given_fragments(self):
        yield 'el título', (
                "as youths, we enjoyed [McDonald's][99]",
                'and also the',
                'understated elegance of [Burger King][66] and [here][33].',
                '[66]: url_for_bking',
                '[33]: url_for_here',
                '[99]: url_for_mcdo',
                )


class Case125_footnotes_are_normalized_across_fragments(_CommonCase):

    def test_100_only_3_footnotes_down_from_4(self):
        def f(act, exp):
            sn, id_s, url = exp
            self.assertEqual(act.symbol_name, sn)
            self.assertEqual(act.identifier_string, id_s)
            self.assertEqual(act.url_probably, url)

        a1, a2, a3 = self._custom_three()[2]

        e1 = ('footnote definition', '1', 'url_for_paris\n')
        e2 = ('footnote definition', '2', 'url_for_cph\n')
        e3 = ('footnote definition', '3', 'url_for_berlin\n')

        f(a1, e1)
        f(a2, e2)
        f(a3, e3)

    def test_200_ids_are_correct(self):

        def f(act, exp):
            a_s, o, _ = act.mixed_children
            e_s, (sn, tx, id_s) = exp
            self.assertEqual(_, '\n')
            self.assertEqual(a_s, e_s)
            self.assertEqual(o.symbol_name, sn)
            self.assertEqual(o.label_text, tx)
            self.assertEqual(o.identifier_string, id_s)

        ((a1, a2), (a3, a4)) = self._custom_three()[0:-1]

        e1 = ('meet me at the ', ('footnote reference', 'paris', '1'))
        e2 = ('meet me at the ', ('footnote reference', 'copenhagen', '2'))

        e3 = ("let's meet in ", ('footnote reference', 'berlin', '3'))
        e4 = ("let's meet in ", ('footnote reference', 'paris', '1'))

        f(a1, e1)
        f(a2, e2)
        f(a3, e3)
        f(a4, e4)

    @shared_subject
    def _custom_three(self):
        itr = self.to_document_line_ASTs()
        sections = []
        cache = []
        for ast in itr:
            if 'empty line' == ast.symbol_name:
                nxt = next(itr)
                self.assertEqual(nxt.symbol_name, 'empty line')
                sections.append(tuple(cache))
                cache.clear()
                continue
            cache.append(ast)
        sections.append(tuple(cache))
        self.assertEqual(len(sections), 3)
        return sections

    def given_fragments(self):
        yield 'el título de frag 1', (
                'meet me at the [paris][uno]',
                'meet me at the [copenhagen][dos]',
                '[uno]: url_for_paris',
                '[dos]: url_for_cph',
                )
        yield 'el título de frag 2', (
                "let's meet in [berlin][ein]",
                "let's meet in [paris][zwei]",
                '[ein]: url_for_berlin',
                '[zwei]: url_for_paris',
                )


class Case133_what_looks_like_footnotes_in_code_blocks_is_not_pic(_CommonCase):

    def test_100_look_at_this_crazy_thing(self):
        _actual = tuple(ast.symbol_name for ast in self.a())
        _expected = (
                'content line',
                'fenced code block',
                'structured content line',
                'empty line',
                'empty line',
                'footnote definition',
                )
        self.assertSequenceEqual(_actual, _expected)

    def test_200_the_fenced_code_block_is_just_lines(self):
        _actual = self.a()[1]._lines
        _expected = (
            '```bash\n',
            '[mami][tchami]\n',
            '```\n',
            )
        self.assertSequenceEqual(_actual, _expected)

    def test_300_but_this_other_fellow_is_actually_a_footnote_reference(self):
        ast = self.a()[2]
        _1, _2, _3 = ast.mixed_children
        _exp = ('see ', ('footnote reference', 'mami', '1'))
        _act = (_1, (_2.symbol_name, _2.label_text, _2.identifier_string))
        self.assertSequenceEqual(_act, _exp)

    @shared_subject
    def a(self):
        return tuple(self.to_document_line_ASTs())

    def given_fragments(self):
        yield 'el título', (
                "here's how: ",
                '```bash',
                '[mami][tchami]',
                '```',
                'see [mami][tchami]',
                '[tchami]: url_for_tchami',
                )


# could cover: footnote reference with bad name raises key error


if __name__ == '__main__':
    unittest.main()

# #born.
