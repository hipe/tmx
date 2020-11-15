from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subj_in_child_classes, \
        dangerous_memoize as shared_subject
import unittest


class CommonCase(unittest.TestCase):

    @property
    @shared_subj_in_child_classes
    def end_state_custom_index(self):
        from pho_test.graph_support import build_custom_index as func
        return func(self.end_state_output_lines)

    @property
    def end_state_output_lines(self):
        tup = self.end_state.end_result
        assert isinstance(tup, tuple)
        return tup

    @property
    @shared_subj_in_child_classes
    def emission_lines(self):
        return self.build_emission_lines()

    def build_emission_lines(self):
        return tuple(self.emission('emi').payloader())

    def emission(self, ekey):
        return self.end_state.emissions[ekey]

    @property
    @shared_subj_in_child_classes
    def end_state(self):
        from pho_test.issues_support import build_end_state_for as func
        return func(self, self.given_run)

    def given_run(self, readme, opn, listener):
        func = subject_module().issues_collection_via_
        ic = func(readme, listener, opn)
        kw = {}
        if self.do_show_group_nodes:
            kw['show_group_nodes'] = True

        if (eids := self.given_target_these):
            kw['targets'] = eids

        lines = ic.to_graph_lines(**kw)
        if not self.do_debug:
            return tuple(lines)

        result_lines, is_first = [], [None]
        from sys import stdout as sout, stderr as serr
        for line in lines:
            if is_first:
                serr.write('\n')
                is_first.pop()
            serr.write('DEBUG: ')
            serr.flush()
            sout.write(line)
            sout.flush()
            result_lines.append(line)
        return tuple(result_lines)

    def expected_num_rewinds(_):
        return 0

    given_target_these = None
    do_show_group_nodes = False
    do_debug = False


CommonCase.is_first = True  # meh


class Case3900_no_iden_or_no_body(CommonCase):

    def test_050_emits_severl(self):
        assert self.end_state

    def test_075_says_totall_blank_issues(self):
        act = self.all_these_lines[0]
        exp = 'Strange - totally blank issues: [#123], [#127].'
        self.assertEqual(act, exp)

    def test_100_say_rows_dont_have_identifier(self):
        act = self.all_these_lines[1]
        exp = "Rows don't have an identifier on lines 7, 9"
        self.assertEqual(act, exp)

    @shared_subject
    def all_these_lines(self):
        return tuple(self.emission('emi2').payloader())

    def given_lines(_):
        yield '| fella | main tag | content |\n'
        yield '|---|---|---|\n'
        yield '|[#129]   ||fellow dello\n'
        yield '|[#127]   ||\n'
        yield '|[#125.Z] ||deploy alpha version\n'
        yield '|[#123]\n'
        yield '|\n'
        yield '|[#120]   ||chimmy jimmy #choo\n'
        yield '||haha\n'
        yield 'something else'

    def expected_emissions(_):
        yield 'info', 'expression', 'no_participating_issues'
        yield 'notice', 'expression', 'notice', 'as', 'emi2'


class Case3903_when_no_deep_tags(CommonCase):

    def test_050_emits(self):
        assert self.end_state

    def test_100_explains_in_general(self):
        act, = self.emission('emi1').payloader()
        self.assertEqual(act, 'No participating issues found.')

    def test_120_splays_no_deep_tags(self):
        act, = self.emission('emi2').payloader()
        exp = 'These issues had tags but no deep tags: [#125], [#126].'
        self.assertEqual(act, exp)

    def test_140_splays_no_deep_tags(self):
        act, = self.emission('emi3').payloader()
        exp = 'This issue had no tags at all: [#125.5].'
        self.assertEqual(act, exp)

    def test_150_did_output_some_lines(self):
        lines = self.end_state_output_lines
        self.assertEqual(lines[0], 'digraph g {\n')

    def given_lines(_):
        yield '| IDEn | MAIn TAg | CONTENt |\n'
        yield '|---|---|---|\n'
        yield '|[#126]|#eg| froo froo\n'
        yield '|[#125.5]|    | no tags\n'
        yield '|[#125]|#hole| Matey Patatey\n'

    def expected_emissions(_):
        yield 'info', 'expression', 'no_participating_issues', 'as', 'emi1'
        yield 'debug', 'expression', 'no_participating_issues', 'as', 'emi2'
        yield 'debug', 'expression', 'no_participating_issues', 'as', 'emi3'


class Case3906_too_deep_wrong_nonterminal(CommonCase):

    def test_050_emits(self):
        assert self.end_state

    def test_075(self):
        msgs = self.emission('emi1').payloader()
        msg, = msgs
        exp = 'Needed identifier (e.g. "[#123]"). Had: \'"#126"\''
        self.assertEqual(msg, exp)

    def test_100_says(self):
        msgs = self.emission('emi2').payloader()
        msg, = msgs
        exp = "Tag too deep on line 4: '#after:[#124]:flam'"
        self.assertEqual(msg, exp)

    def given_lines(_):
        yield '| fella | main tag | content |\n'
        yield '|---|---|---|\n'
        yield '|[#125]|#part-of:"#126"|\n'
        yield '|[#124]|#after:[#124]:flam\n'

    def expected_emissions(_):
        yield 'error', 'expression', 'parse_error', 'as', 'emi1'
        yield 'error', 'expression', 'tags_too_deep', 'as', 'emi2'


class Case3907_strange(CommonCase):

    def test_050_emits(self):
        assert self.end_state

    def test_075_message(self):
        act = self.all_these_lines[0]
        exp = "Unrecognized deep tag on line 3: '#cachokie-dokey'"
        self.assertEqual(act, exp)

    def test_100_message_groups_by_tag_and_splays_line_numbers(self):
        act = self.all_these_lines[1]
        exp = "Unrecognized deep tag on lines 4, 6: '#fizzy'"
        self.assertEqual(act, exp)

    @shared_subject
    def all_these_lines(self):
        return tuple(self.emission('emi2').payloader())

    def given_lines(_):
        yield '| fella | main tag | content |\n'
        yield '|---|---|---|\n'
        yield '|[#127]|#cachokie-dokey:dizzy|\n'
        yield '|[#125]|#fizzy:dizzy|\n'
        yield '|[#123]|whatever\n'
        yield '|[#121]|#fizzy:dazzy\n'

    def expected_emissions(_):
        yield 'info', '?+'
        yield 'notice', 'expression', 'unrecognized_deep_tags', 'as', 'emi2'


class Case3915_fail_to_parse_identifier_one(CommonCase):

    def test_050_emits(self):
        emis = self.end_state.emissions
        sct1, sct2 = (emis[k].payloader() for k in ('emi1', 'emi2'))
        self.assertIn('zoobie', sct1['line'])
        self.assertIn('ziffer', sct2['line'])

    def given_lines(_):
        yield '| fella | main tag | content |\n'
        yield '|---|---|---|\n'
        yield '|[#125]|#part-of:[#zoobie]\n'
        yield '|[#124]|#after:[#ziffer]\n'
        yield '|[#122]|#after:[#125]\n'  # change this to bad fwd ref and break

    def expected_emissions(_):
        yield 'error', 'structure', 'input_error', 'as', 'emi1'
        yield 'error', 'structure', 'input_error', 'as', 'emi2'


class Case3916_fail_to_parse_identifier_two(CommonCase):

    def test_050_emits_parse_error(self):
        sct = self.emission('emi1').payloader()
        missing = {'expecting', 'position', 'line'} - set(sct.keys())
        assert not missing

    def given_lines(_):
        yield '| fella | main tag | content |\n'
        yield '|---|---|---|\n'
        yield '|[#123]|#after:[#zib.zub]\n'

    def expected_emissions(_):
        yield 'error', 'structure', 'input_error', 'as', 'emi1'


class Case3918_unresolved_references(CommonCase):

    def test_050_emits(self):
        assert self.end_state

    def test_075_does_crazy_line_thing(self):
        fmt = 'Node referenced but never defined on line {}: {!r}'
        line1, line2 = tuple(self.end_state.emissions['emi'].payloader())
        self.assertEqual(line1, fmt.format('3', '[#123.1]'))
        self.assertEqual(line2, fmt.format('4', '[#124]'))

    def given_lines(_):
        yield '| fella | main tag | content |\n'
        yield '|---|---|---|\n'
        yield '|[#125]|#part-of:[#123.1]\n'
        yield '|[#122]|#after:[#124]\n'

    def expected_emissions(_):
        yield 'error', 'expression', 'unresolved_issue_references', 'as', 'emi'


r""" Has a cycle:

        A
       / \
      B   C

          [!!F!!]
              \
               D
              / \
             E   F
                  \
                [!!D!!]
"""


class Case3920_detect_cycle(CommonCase):

    def test_050_emits(self):
        assert self.end_state

    def test_075_says(self):
        msg, = self.build_emission_lines()
        exp = "These issues are apparently part of a cycle: [#125.F], [#125.D]."  # noqa: E501
        self.assertEqual(msg, exp)

    def given_lines(_):
        yield 'junk\n'
        yield '\n'
        yield '| fella | main tag | content |\n'
        yield '|---|---|---|\n'
        yield '|[#125.F]|hi #part-of:[#125.D]\n'
        yield '|[#125.E]|hi #part-of:[#125.D]\n'
        yield '|[#125.D]|hi #part-of:[#125.F]\n'
        yield '|[#125.C]|hi #part-of:[#125.A]|\n'
        yield '|[#125.B]|hi #part-of:[#125.A]\n'
        yield '|[#125.A]|hi|\n'
        yield '\n'
        yield 'junk'

    def expected_emissions(_):
        yield 'error', 'expression', 'apparent_cycle', 'as', 'emi'


r""" Let's go:

        A        D
       / \      / \
      B   C    E   F
                  / \
                 G   H
"""


class Case3922_money(CommonCase):

    def test_050_did_output_lines(self):
        assert self.end_state_output_lines

    def test_100_there_are_some_nodes(self):
        act = len(self.end_state_custom_index.nodes)
        self.assertEqual(act, 10)

    def test_150_there_are_some_assocs(self):
        act = len(self.end_state_custom_index.assocs_via_node_key)
        self.assertEqual(act, 7)

    def test_200_there_are_some_subgraphs(self):
        act = len(self.end_state_custom_index.subgraphs)
        self.assertEqual(act, 3)

    def test_250_label_content_can_have_quotes_it_gets_escaped(self):
        esi = self.end_state_custom_index
        node = esi.nodes[(125, 4)]
        self.assertIn('\\"hey\\"', node.inside)

    def test_300_same_node_becomes_node_and_subgraph(self):
        self.these_two()

    def test_350_in_subgraph_the_ID_is_at_the_beginning(self):
        _, sg = self.these_two()
        where = sg.escaped.find('[#125.D]')
        self.assertEqual(where, 0)

    def test_400_in_node_the_ID_is_at_the_end(self):
        eid = '[#125.D]'
        node, _ = self.these_two()
        string = node.inside
        where = string.rfind(eid)
        act = where + len(eid) + 1  # plus one for close quote
        self.assertEqual(act, len(string))

    def these_two(self):
        esi = self.end_state_custom_index
        node = esi.nodes[(125, 4)]
        sg = esi.subgraphs[(125, 4)]
        return node, sg

    def given_lines(_):
        yield 'junk\n'
        yield '\n'
        for line in these_lines():
            yield line
        yield '\n'
        yield 'junk'

    def expected_emissions(_):
        return ()

    do_show_group_nodes = True  # became opt-in at #history-B.4


def these_lines():
    if True:
        yield '| fella | main tag | content |\n'
        yield '|---|---|---|\n'
        yield '|[#125.H]|hi #part-of:[#125.F]\n'
        yield '|[#125.G]|hi #part-of:[#125.F]\n'
        yield '|[#125.F]|hi #part-of:[#125.D]\n'
        yield '|[#125.E]|hi #part-of:[#125.D]\n'
        yield '|[#125.D]|hi hello "hey" how are #you halva hummus hecho en m\n'
        yield '|[#125.C]|hi #part-of:[#125.A]\n'
        yield '|[#125.B]|hi #part-of:[#125.A]\n'
        yield '|[#125.A]|hi\n'
        yield '|[#124.B]|I am a jabronus #obun\n'
        yield '|[#124.A]|I am a jumunkus #after:[#124.B]\n'


class Case3924_show_graph_nodes_became_opt_in(CommonCase):

    def test_050_did_output_lines(self):
        assert self.end_state_output_lines

    def test_100_idk(self):
        ci = self.end_state_custom_index
        assert 1 == len(ci.subgraphs)
        assert 2 == len(ci.nodes)

    def given_lines(_):
        yield '| zizzy | main tag | content |\n'
        yield '|---|---|---|\n'
        yield '|[#123.3]|#part-of:[#123.1]\n'
        yield '|[#123.2]|#part-of:[#123.1]\n'
        yield '|[#123.1]|fatoozie\n'

    def expected_emissions(_):
        return ()


class Case3926_target(CommonCase):

    def test_050_did_output_lines(self):
        assert self.end_state_output_lines

    def test_100_tings(self):
        ci = self.end_state_custom_index
        assert 2 == len(ci.subgraphs)
        assert 4 == len(ci.nodes)

    def given_lines(_):
        return these_lines()

    def expected_emissions(_):
        return ()

    given_target_these = '[#125.A]', '[#125.F]'


def subject_module():
    import pho._issues as module
    return module


if __name__ == '__main__':
    unittest.main()

# #history-B.4
# #born
