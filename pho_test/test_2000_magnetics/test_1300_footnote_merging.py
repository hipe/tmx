from pho_test.document_state import \
        SexpCase, final_sexps_via_notecards, \
        all_in_sexps, CaseMetaClass, subject_module
from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subject_in_child_classes
import unittest


class CommonCase(unittest.TestCase):

    def identifiers_of_RSL_definitions(self):
        sa = self.end_state_sexps
        sx = sa.last('RSL_definitions')
        return tuple(sx[1].keys())

    @property
    @shared_subject_in_child_classes
    def end_state_sexps(self):
        return final_sexps_via_notecards(self.given_notecards())


class ReferenceStyleLinkCase(unittest.TestCase, metaclass=CaseMetaClass):

    def definition_for_the_method_called_test():
        return ReferenceStyleLinkCase.will_be_test

    def will_be_test(self):
        given_line = self.given_line()
        mod = subject_module()
        rx = mod._RSL_definition_rx
        md = rx.match(given_line)
        if md is None:
            raise RuntimeError(f"failed to match: {given_line!r}")

        from pho.models_.footnote import _RSL_def_rx_keys as these_keys
        act = {k: md[k] for k in these_keys}
        for k, exp_s in self.expected_parts():
            act_s = act[k]
            self.assertEqual(act_s, exp_s)


# (1200-1390)


class Case1230_introduce_RSL_definition(ReferenceStyleLinkCase):

    def expected_parts(_):
        yield 'margin', '   '
        yield 'link_identifier', 'PDP_15'
        yield 'second_whitespace', '\t\t'
        yield 'link_url', 'hddp://foo.biz/bar'

    def given_line(_):
        return "   [PDP_15]:\t\thddp://foo.biz/bar\n"


class Case1235_RSL_definition_line_with_title(ReferenceStyleLinkCase):

    def expected_parts(_):
        yield 'margin', ''
        yield 'link_identifier', '1'
        yield 'second_whitespace', ' '
        yield 'link_url', '/some/local/link'
        yield 'third_whitespace', ' '
        yield 'single_quoted_insides', "Mom\\'s Spaghetti"

    def given_line(_):
        return "[1]: /some/local/link 'Mom\\'s Spaghetti'\n"


class Case1240_x2(SexpCase):

    def expected_sexps(_):
        yield 'content_run', 1
        yield 'link_definition_run', 2
        yield 'content_run', 1

    def given_lines(_):
        yield '[chim_churry][chip_chewey] is a good reference.\n'
        yield '   [chip_curry]: hddp://xxyyzz.com/haha\n'
        yield '  [2]: hddp://xx.com/foo "ohai yes"\n'
        yield '    [not_chip_curry]: hddp://xxyyzz.com/haha\n'  # 4 indented


class Case1245_footnotes_in_just_one_notecard_will_get_normalized(CommonCase):

    def test_100_RSL_definitions_retain_the_order_they_are_first_encount(self):
        act = self.identifiers_of_RSL_definitions()
        self.assertSequenceEqual(act, ('66', '33', '99'))

    # (deleted a test about RSL definition RHS's retaining order #history-B.4)

    # (deleted a test about footnote numbers starting from one #history-B.4)

    # (deleted a test asserting new RSL idens used in content #history-B.4)

    # (deleted test asserting blank line(s) separating sects #history-B.4)

    def given_notecards(self):
        yield 'el título', (
                "as youths, we enjoyed [McDonald's][99]",
                'and also the',
                'understated elegance of [Burger King][66] and [here][33].',
                '[66]: url_for_bking',
                '[33]: url_for_here',
                '[99]: url_for_mcdo')


class Case1250_footnotes_are_normalized_across_notecards(CommonCase):

    def test_100_only_3_footnotes_down_from_4(self):
        act = self.identifiers_of_RSL_definitions()
        self.assertSequenceEqual(act, ('uno', 'dos', 'ein'))

    def test_200_ids_are_correct(self):
        sa = self.end_state_sexps
        sects = sa.all('section')
        act = tuple(line for sect in sects for line in lines_via_section(sect))
        exp = tuple(self.expected_lines())
        self.assertSequenceEqual(act, exp)

    def expected_lines(_):
        yield 'meet me at the [paris][uno]\n'
        yield 'meet me at the [copenhagen][dos]\n'
        yield "let's meet in [berlin][ein]\n"
        yield "let's meet in [paris][uno]\n"

    def given_notecards(self):
        yield 'el título de frag 1', (
                'meet me at the [paris][uno]',
                'meet me at the [copenhagen][dos]',
                '[uno]: url_for_paris',
                '[dos]: url_for_cph')
        yield 'el título de frag 2', (
                "let's meet in [berlin][ein]",
                "let's meet in [paris][zwei]",
                '[ein]: url_for_berlin',
                '[zwei]: url_for_paris')


class Case1330_what_looks_like_footnotes_in_code_blocks_is_not_pic(CommonCase):

    # (deleted test asserting the AST types of many lines #history-B.4)

    def test_200_the_fenced_code_block_is_just_lines(self):
        sect = self.the_last_section
        cf_run, = all_in_sexps(sect[2], 'code_fence_run')
        act = tuple(lines_via_run_sexp(cf_run))
        exp = tuple(self.expected_code_fence_lines())
        self.assertSequenceEqual(act, exp)

    def test_300_but_this_other_fellow_is_actually_a_footnote_reference(self):
        sect = self.the_last_section
        lines = tuple(lines_via_section(sect))
        act_line = lines[-1]
        exp_line = 'see [mami][orig_iden_for_tchami]\n'
        assert exp_line == act_line

    @property
    def the_last_section(self):
        _, last = self.end_state_sexps.all('section')
        return last

    def expected_code_fence_lines(_):
        yield "```bash\n"
        yield "[mami][tchami]\n"
        yield "```\n"

    def given_notecards(self):
        yield 'sneak in 17 months later', (
                'zib zub',
                '[orig_iden_for_tchami]: url_for_tchami',
                )
        yield 'el título', (
                "here's how: ",
                '```bash',
                '[mami][tchami]',
                '```',
                'see [mami][tchami]',
                '[tchami]: url_for_tchami')


# could cover: footnote reference with bad name raises key error


def lines_via_section(sx):  # NOTE header/headings are ignored
    for cr in sx[2]:
        for line in lines_via_run_sexp(cr):
            yield line


def lines_via_run_sexp(sexp):
    if sexp[0] not in ('content_run', 'code_fence_run'):
        assert()
    for line in sexp[1]:
        yield line


if __name__ == '__main__':
    unittest.main()

# #history-B.4
# #born.
