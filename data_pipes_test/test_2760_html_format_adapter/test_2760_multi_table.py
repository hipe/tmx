"""
objectives are severalfold:
    - cover scraping of this one page format
    - cover the beginnings of [#874.4] multi-tablism

we first assert several structural details of the scraping, including whether
the branch boundaries are being detected and emitted.
"""


from data_pipes_test.common_initial_state import \
        production_collectioner, \
        html_fixture, ProducerCaseMethods, passthru_context_manager
from kiss_rdb_test.markdown_table_parsers import \
        table_via_lines, nonblank_line_runs_via_lines
from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject, lazy
import unittest


class CommonCase_OFF:  # #[#459.M]
    pass


class CommonCase(ProducerCaseMethods, unittest.TestCase):

    def build_bespoke_sections(self):
        # experiment - group markdown headers with the next run
        run_with_header = None
        for run in nonblank_line_runs_via_lines(self.output_lines):
            if '#' == run[0][0] and 1 == len(run):
                if run_with_header:
                    yield run_with_header
                run_with_header = run
                continue
            if run_with_header is None:
                yield run
                continue
            use = (*run_with_header, *run)
            run_with_header = None
            yield use

    def build_output_lines(self):

        # Make the "from" collection (around the dictionaries)
        dct_tup = _these_dictionaries()
        from_coll = fake_producer_script_via_dictionary_tuple(dct_tup)

        # Make the "to" collection (around a fake stdout)
        fake_sout, lines = fake_STDOUT_and_lines_for(self)

        collectioner = production_collectioner()

        to_coll = collectioner.collection_via_path(
                fake_sout, format_name='markdown-table')

        # get busy

        from_ci, to_ci = (o.COLLECTION_IMPLEMENTATION for o in (from_coll, to_coll))  # noqa: E501

        sch, ents = from_ci.to_schema_and_entities(None)
        with to_ci.open_pass_thru_receiver_as_storage_adapter(None) as recv:
            if True:
                for ent in ents:
                    assert ent.path
                    assert ent.lineno
                    recv(ent.core_attributes_dictionary_as_storage_adapter_entity)  # noqa: E501
        return tuple(lines)

    do_debug = False


def fake_producer_script_via_dictionary_tuple(dct_tup):  # covered here

    class fake_producer_script:  # #class-as-namespace
        # [#459.17] producer script fake modules (see nearby other)

        def multi_depth_value_dictionary_stream_via_traversal_stream(dcts):
            return dcts

        def open_traversal_stream(listener):
            return passthru_context_manager(dct_tup)

    fake_producer_script.__file__ = __file__

    import data_pipes.format_adapters.producer_script as sa_mod
    from kiss_rdb import collection_via_storage_adapter_and_path as func
    return func(sa_mod, fake_producer_script, None)


class Case2756_test_test(CommonCase):

    def test_050_works(self):
        these = {'foo': 'bar'}, {'foo': 'baz'}
        coll = fake_producer_script_via_dictionary_tuple(these)

        with coll.open_schema_and_entity_traversal(None) as (schema, ents):
            assert schema is None
            ents = tuple(ents)

        act = tuple(ent.core_attributes_dictionary_as_storage_adapter_entity for ent in ents)  # noqa: E501
        self.assertSequenceEqual(act, these)


class Case2757_does_scrape_work(CommonCase):

    def test_010_scrape_works(self):
        self.assertGreaterEqual(len(self.end_dicts), 2)  # meh whatever

    def test_020_an_entity_dictionary_looks_like_this(self):
        dct = self.end_dicts[1]
        self.assertEqual(dct['label'], 'Overview')

    def test_030_these_fellows_are_terminal_items(self):
        _exp = ('Overview',
                'Get Started Overview',
                'Quick Start')
        self.assertSequenceEqual(self.custom_index[1], _exp)

    def test_040_these_fellows_are_the_branch_names(self):
        _exp = ('About Hugo',
                'Getting Started',
                'Maintenance')
        self.assertSequenceEqual(self.custom_index[0], _exp)

    def test_050_pseudo_real_scrape_looks_like_our_raw_dump(self):
        _real = self.end_dicts
        _exp = _these_dictionaries()
        self.assertSequenceEqual(_real, _exp)

    @shared_subject
    def custom_index(self):

        branch_labels = []
        item_labels = []

        for dct in self.end_dicts:
            if '_is_branch_node' in dct:
                branch_labels.append(dct['label'])
            else:
                item_labels.append(dct['label'])

        return branch_labels, item_labels

    @shared_subject
    def end_dicts(self):
        return self.build_dictionaries_tuple_from_traversal_()

    def given_producer_script(self):
        return 'script/producer_scripts/script_180815_hugo_docs.py'

    def cached_document_path(self):
        return html_fixture('0170-hugo-docs.html')


class Case2760DP_generate(CommonCase_OFF):

    def test_100_outputs_more_than_one_line(self):
        self.assertLessEqual(1, len(self.output_lines))

    def test_230_first_section_is_frontmaattery(self):
        run = self.bespoke_sections[0]
        self.assertEqual(run[0], '---\n')
        self.assertEqual(run[-1], '---\n')
        self.assertLess(2, len(run))

    def test_260_last_section_is_this_one_footer(self):
        run = self.bespoke_sections[-1]
        self.assertIn('document-meta', run[0])
        self.assertIn('#born', run[-1])

    def test_300_each_table_parses(self):
        self.assertEqual(3, len(self.tables))

    def test_400_table_names_occur_as_markdown_headers(self):
        def big_rx_hack(s):
            return rx.search(s)[0]
        import re
        rx = re.compile(r'[A-Z][A-Za-z ]+')
        _act = tuple(big_rx_hack(table.header_line) for table in self.tables)
        _exp = ('About Hugo', 'Getting Started', 'Maintenance')
        self.assertSequenceEqual(_act, _exp)

    def test_500_all_expected_business_items(self):
        def these():
            for table in self.tables:
                rows = table.business_rows
                if rows is None:
                    continue
                for row in rows:
                    yield row[0].strip()
        _act = tuple(these())
        _exp = ('Overview', 'Get Started Overview', 'Quick Start')
        self.assertSequenceEqual(_act, _exp)

    def test_600_last_table_has_no_items(self):
        self.assertIsNone(self.tables[-1].business_rows)

    def test_700_currently_none_of_the_tables_have_example_rows(self):
        def f(table):
            return False if table.example_row is None else True
        _act = tuple(f(x) for x in self.tables)
        _exp = (False, False, False)
        self.assertSequenceEqual(_act, _exp)

    @shared_subject
    def tables(self):
        return tuple(table_via_lines(tu) for tu in self.bespoke_sections[1:-1])

    @shared_subject
    def bespoke_sections(self):
        return tuple(self.build_bespoke_sections())

    @shared_subject
    def output_lines(self):
        return self.build_output_lines()


@lazy
def _these_dictionaries():
    return tuple(x for x in _yield_these_dictionaries())


def _yield_these_dictionaries():
    def o(path):
        return f'{_url}{path}'
    yield {'_is_branch_node': True, 'label': 'About Hugo'}
    yield {'label': 'Overview', 'url': o('/about/')}
    yield {'_is_branch_node': True, 'label': 'Getting Started'}
    yield {'label': 'Get Started Overview', 'url': o('/getting-started/')}
    yield {'label': 'Quick Start', 'url': o('/getting-started/quick-start/')}
    yield {'_is_branch_node': True, 'label': 'Maintenance', 'url': o('/maintenance/')}  # noqa: E501


def fake_STDOUT_and_lines_for(tc):
    lines = []

    if tc.do_debug:
        def recv_write(line):
            stderr.write(f'DEBUG STDOUT: {line}')
            lines.append(line)
        from sys import stderr
        stderr.write('\n')  # meh
    else:
        recv_write = lines.append

    from modality_agnostic import write_only_IO_proxy as func
    return func(recv_write, on_OK_exit=lambda: None), lines


_url = 'https://gohugo.io'


if __name__ == '__main__':
    unittest.main()

# #history-B.1
# #history-A.1 big spike of ad-hocs
# #born.
