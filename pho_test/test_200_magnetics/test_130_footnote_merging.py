from _common_state import cover_me  # noqa: F401
from pho_test import document_state as doc_state_lib
from modality_agnostic.memoization import dangerous_memoize as shared_subject
import unittest


class _CommonCase(unittest.TestCase):

    def to_document_line_sexps(self):

        _frags = self.given_fragments()
        _state = doc_state_lib.document_state_via_fragments(_frags)

        for sect in _state.sections:
            for sx in sect.body_line_sexps:
                yield sx


# (120-139)

class Case122_footnotes_in_just_one_fragment_will_get_normalized(_CommonCase):

    def test_100_footnote_defs_have_IDs_in_order_w_respect_to_each_other(self):
        def f(sx):
            self.assertEqual(sx[0], 'footnote definition')
            return int(sx[1])
        a = self._the_last_N_line_sexps()
        int_itr = (f(sx) for sx in a)
        prev_int = next(int_itr)
        for integer in int_itr:
            expected = prev_int + 1
            self.assertEqual(integer, expected)
            prev_int = integer

    def test_200_footnote_defs_preserved_the_order_of_their_entities(self):
        import re
        rx = re.compile(r'^url for ([^\n]+)\n$')

        def f(sx):
            md = rx.match(sx[2])
            return md[1]
        _actual = tuple(f(sx) for sx in self._the_last_N_line_sexps())

        self.assertSequenceEqual(_actual, ('bking', 'here', 'mcdo'))

    def test_300_footnote_defs_now_start_at_number_one(self):
        self.assertEqual(self._the_last_N_line_sexps()[0][1], '1')

    def test_400_the_body_copy_now_uses_the_new_IDs_and_they_are_correct(self):
        first_sx, second_sx, third_sx = self.line_sexps()[0:3]

        self.assertSequenceEqual(second_sx, ('content line', 'and also the\n'))

        self.assertSequenceEqual(first_sx, (
                'parsed content line',
                'as youths, we enjoyed ',
                ('footnote reference', "McDonald's", '3'),
                '\n'))

        self.assertSequenceEqual(third_sx[2][1:], ('Burger King', '1'))
        self.assertSequenceEqual(third_sx[4][1:], ('here', '2'))

    def test_500_footnote_defs_now_have_some_blank_lines_in_between(self):
        my_set = set()
        for sx in self.line_sexps()[-5:-3]:
            my_set.add(sx[0])
        self.assertSequenceEqual(tuple(my_set), ('empty line',))

    @shared_subject
    def _the_last_N_line_sexps(self):
        return self.line_sexps()[-3:]

    @shared_subject
    def line_sexps(self):
        return tuple(self.to_document_line_sexps())

    def given_fragments(self):
        yield 'el título', (
                "as youths, we enjoyed [McDonald's][99]",
                'and also the',
                'understated elegance of [Burger King][66] and [here][33].',
                '[66]: url for bking',
                '[33]: url for here',
                '[99]: url for mcdo',
                )


class Case125_footnotes_are_normalized_across_fragments(_CommonCase):

    def test_100_only_3_footnotes_down_from_4(self):
        a1, a2, a3 = self._custom_three()[2]

        e1 = ('footnote definition', '1', 'url for paris\n')
        e2 = ('footnote definition', '2', 'url for cph\n')
        e3 = ('footnote definition', '3', 'url for berlin\n')

        self.assertSequenceEqual(a1, e1)
        self.assertSequenceEqual(a2, e2)
        self.assertSequenceEqual(a3, e3)

    def test_200_ids_are_correct(self):
        s1, s2 = self._custom_three()[0:-1]

        s1l1, s1l2 = s1
        s2l1, s2l2 = s2

        def f(sx):
            return tuple(sx[1:-1])

        e1 = ('meet me at the ', ('footnote reference', 'paris', '1'))
        e2 = ('meet me at the ', ('footnote reference', 'copenhagen', '2'))

        e3 = ("let's meet in ", ('footnote reference', 'berlin', '3'))
        e4 = ("let's meet in ", ('footnote reference', 'paris', '1'))

        self.assertSequenceEqual(f(s1l1), e1)
        self.assertSequenceEqual(f(s1l2), e2)
        self.assertSequenceEqual(f(s2l1), e3)
        self.assertSequenceEqual(f(s2l2), e4)

    @shared_subject
    def _custom_three(self):
        itr = self.to_document_line_sexps()
        sections = []
        cache = []
        for sx in itr:
            if 'empty line' == sx[0]:
                nxt = next(itr)
                self.assertEqual(nxt[0], 'empty line')
                sections.append(tuple(cache))
                cache.clear()
                continue
            cache.append(sx)
        sections.append(tuple(cache))
        self.assertEqual(len(sections), 3)
        return sections

    def given_fragments(self):
        yield 'el título de frag 1', (
                'meet me at the [paris][uno]',
                'meet me at the [copenhagen][dos]',
                '[uno]: url for paris',
                '[dos]: url for cph',
                )
        yield 'el título de frag 2', (
                "let's meet in [berlin][ein]",
                "let's meet in [paris][zwei]",
                '[ein]: url for berlin',
                '[zwei]: url for paris',
                )


class Case133_what_looks_like_footnotes_in_code_blocks_is_not_pic(_CommonCase):

    def test_100_look_at_this_crazy_thing(self):
        expected = (
                'content line',
                'multi-line code block open',
                'multi-line code block body line',
                'mutli-line code block end',
                'parsed content line',
                'empty line',
                )
        _ = self.a()[0:len(expected)]
        _actual = tuple(sx[0] for sx in _)
        self.assertSequenceEqual(_actual, expected)

    def test_200_doesnt_and_does(self):
        a = self.a()
        self.assertEqual(a[2][1],  '[mami][tchami]\n')
        _exp = ('see ', ('footnote reference', 'mami', '1'))
        self.assertSequenceEqual(a[4][1:3], _exp)

    @shared_subject
    def a(self):
        return tuple(self.to_document_line_sexps())

    def given_fragments(self):
        yield 'el título', (
                "here's how: ",
                '```bash',
                '[mami][tchami]',
                '```',
                'see [mami][tchami]',
                '[tchami]: url for tchami',
                )


# could cover: footnote reference with bad name raises key error


if __name__ == '__main__':
    unittest.main()

# #born.
