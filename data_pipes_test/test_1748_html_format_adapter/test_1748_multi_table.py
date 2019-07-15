"""
objectives are severalfold:
    - cover scraping of this one page format
    - cover the beginnings of [#874.4] multi-tablism

we first assert several structural details of the scraping, including whether
the branch boundaries are being detected and emitted.
"""


from data_pipes_test.common_initial_state import (
        html_fixture,
        ProducerCaseMethods)
from kiss_rdb_test import markdown_table_parsers as parsers
from modality_agnostic.memoization import (
        dangerous_memoize as shared_subject,
        lazy)
import unittest


_CommonCase = unittest.TestCase


class Case1747_does_scrape_work(_CommonCase):

    def test_010_scrape_works(self):
        self.assertGreaterEqual(len(self._dicts()), 2)  # meh whatever

    def test_020_first_fellow_is_metadata(self):
        self._dicts()[0]['_is_sync_meta_data']

    def test_030_these_fellows_are_terminal_items(self):
        _exp = (
                'Overview',
                'Get Started Overview',
                'Quick Start',
                )
        self.assertSequenceEqual(self._custom_index()[1], _exp)

    def test_040_these_fellows_are_the_branch_names(self):
        _exp = (
                'About Hugo',
                'Getting Started',
                'Maintenance',
                )
        self.assertSequenceEqual(self._custom_index()[0], _exp)

    def test_050_pseudo_real_scrape_looks_like_our_raw_dump(self):
        _real = self._dicts()
        _exp = _these_dictionaries()
        self.assertSequenceEqual(_real, _exp)

    @shared_subject
    def _custom_index(self):

        branch_labels = []
        item_labels = []

        itr = iter(self._dicts())
        next(itr)  # we don't again test that this is metadata, just assume

        for dct in itr:
            if '_is_branch_node' in dct:
                branch_labels.append(dct['label'])
            else:
                item_labels.append(dct['label'])

        return branch_labels, item_labels

    @shared_subject
    def _dicts(self):
        return self.build_raw_list_()

    def far_collection_identifier(self):
        return 'script/producer_scripts/script_180815_hugo_docs.py'

    def cached_document_path(self):
        return html_fixture('0170-hugo-docs.html')


class Case1749_gen(_CommonCase):

    def test_100_does_something(self):
        self.assertLessEqual(1, len(self._lines()))

    def test_200_sections_separated_by_one_line(self):
        self.assertEqual(3, len(self._line_sections()))

    def test_300_each_table_parses(self):
        self.assertEqual(3, len(self._tables()))

    def test_400_table_names_occur_as_markdown_headers(self):
        def f(table):
            return table.header_line[4:]
        _act = tuple(f(x) for x in self._tables())
        _exp = ('About Hugo', 'Getting Started', 'Maintenance')
        self.assertSequenceEqual(_act, _exp)

    def test_500_all_expected_business_items(self):
        act = []
        import re
        rx = re.compile(r'^\[([^]]+)\]')
        for table in self._tables():
            rows = table.business_rows
            if rows is not None:
                for row in rows:
                    act.append(rx.match(row[0])[1])

        _exp = ('Overview', 'Get Started Overview', 'Quick Start')
        self.assertSequenceEqual(act, _exp)

    def test_600_last_table_has_no_items(self):
        self.assertIsNone(self._tables()[-1].business_rows)

    def test_700_only_first_table_has_example_row(self):
        def f(table):
            return False if table.example_row is None else True
        _act = tuple(f(x) for x in self._tables())
        _exp = (True, False, False)
        self.assertSequenceEqual(_act, _exp)

    @shared_subject
    def _tables(self):
        def f(lines):
            return parsers.table_via_lines(lines)
        return list(f(x) for x in self._line_sections())

    @shared_subject
    def _line_sections(self):
        return parsers.line_sections_via_lines(self._lines())

    @shared_subject
    def _lines(self):
        _d_a = _these_dictionaries()
        from data_pipes import common_producer_script as mod
        _ = mod.LEGACY_markdown_lib()
        _lines = _._raw_lines_via_collection_identifier(_d_a, __file__)
        return tuple(x for x in _lines)


@lazy
def _these_dictionaries():
    return tuple(x for x in _yield_these_dictionaries())


def _yield_these_dictionaries():
    yield {'_is_sync_meta_data': True, 'natural_key_field_name': 'la_la'}

    def o(path):
        return f'{_url}{path}'

    yield {'_is_branch_node': True, 'label': 'About Hugo'}
    yield {'label': 'Overview', 'url': o('/about/')}
    yield {'_is_branch_node': True, 'label': 'Getting Started'}
    yield {'label': 'Get Started Overview', 'url': o('/getting-started/')}
    yield {'label': 'Quick Start', 'url': o('/getting-started/quick-start/')}
    yield {'_is_branch_node': True, 'label': 'Maintenance', 'url': o('/maintenance/')}  # noqa: E501


_url = 'https://gohugo.io'


if __name__ == '__main__':
    unittest.main()

# #born.
