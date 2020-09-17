from pho_test.common_initial_state import collection_one, throwing_listenerer
from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject, lazy
import unittest


class CommonCase(unittest.TestCase):
    do_debug = False


# Case1530-Case1610


class Case1530_basics(CommonCase):

    def test_100_collection_builds(self):
        self.assertIsNotNone(collection_one())

    def test_200_big_index_builds(self):
        self.assertIsNotNone(_big_index_one())


class Case1540_whole_document_tree_from_first_collection(CommonCase):

    def test_100_some_lines_were_made(self):
        num = self.custom_index.total_line_count
        self.assertLess(100, num)
        self.assertLess(num, 120)

    def test_220_every_notecard_heading_was_expressed_somehow(self):
        _actual = len(self.lines_that_expressed_headings)
        self.assertEqual(_actual, 6)

    def test_240_these_7_notecards_produced_only_4_documents(self):
        _lines = self.lines_that_expressed_headings

        count = 0
        for line in _lines:
            if 'DOC TITLE' in line:
                count += 1

        self.assertEqual(count, 4)

    def test_300_all_the_bookmarks_came_out(self):
        _actual = self.custom_index.lines_that_define_bookmarks
        self.assertEqual(len(_actual), 7)

    @shared_subject
    def lines_that_expressed_headings(self):
        return self.custom_index.lines_that_express_the_notecard_heading

    @shared_subject
    def custom_index(self):
        return custom_index_via_big_index(_big_index_one())


_this_range = range(59, 60)
# #history-A.1 bumped max by 1 because of unknown change


class Case1580_generate_one_document(CommonCase):

    def test_100_wrote_the_lines_probably(self):
        self.assertIn(len(self['writes']), _this_range)

    def test_125_the_lines_ARE_newline_terminated_probably(self):
        _ = self['writes']
        self.assertEqual(_[0][-1], '\n')
        self.assertEqual(_[-1][-1], '\n')

    def test_150_the_frontmatter_is_there(self):
        _ = self['writes']
        self.assertEqual(_[0], '---\n')
        self.assertEqual(_[3], '---\n')  # ..

    def test_200_resulted_in_true_for_OK(self):
        self.assertTrue(self['result_value'] is True)  # like this, it matters

    def test_300_emitted_a_summary(self):
        o = self.ad_hoc_end_state
        chan = o['channel']
        sct = o['payloader_BE_CAREFUL_HOT']()

        self.assertSequenceEqual(chan, ('info', 'structure', 'wrote_files'))

        import re
        md = re.match(
                r'^wrote 1 of 1 files \((\d+) lines, ~(\d+) bytes\)$',
                sct['message'])

        self.assertIn(int(md[1]), _this_range)
        self.assertIn(int(md[2]), range(1000, 1200))

    def __getitem__(self, k):
        return self.ad_hoc_end_state[k]

    @shared_subject
    def ad_hoc_end_state(self):

        writes = []
        from modality_agnostic import write_only_IO_proxy
        spy = write_only_IO_proxy(
                write=writes.append,
                on_OK_exit=lambda: None)

        _big_index = _big_index_one()

        def run(listener):
            from pho.magnetics_.document_tree_via_notecard import (
                    document_tree_via_notecard)

            return document_tree_via_notecard(
                    out_tuple=('open_output_filehandle', spy),
                    notecard_IID_string='48R',
                    big_index=_big_index,
                    be_recursive=False,
                    force_is_present=False,
                    is_dry_run=False,
                    listener=listener)

        import modality_agnostic.test_support.common as em

        listener, emissions = em.listener_and_emissions_for(self, limit=1)
        x = run(listener)
        emi, = emissions

        return {'result_value': x,
                'writes': writes,
                'channel': emi.channel,
                'payloader_BE_CAREFUL_HOT': emi.payloader}


def custom_index_via_big_index(big_index):

    if True:  # meh

        listener = throwing_listenerer()
        doc_itr = big_index.TO_DOCUMENT_STREAM(listener)
        is_first = True

        from modality_agnostic.test_support.common import Counter
        total_line_counter = Counter()
        lines_that_express_the_notecard_heading = []
        lines_that_define_bookmarks = []

        def echo(line):

            # FOR DEBUGGING:
            # print(line)

            total_line_counter.increment()

            if not len(line):
                return

            if 'FRAG' in line:
                lines_that_express_the_notecard_heading.append(line)
            elif '[' == line[0]:
                lines_that_define_bookmarks.append(line)

        """SO:
        we originally developed the below code as a quick-and-dirty visual
        confirmation but then repurposed it so that it's used to hackishly
        gather statistics (totals) on types of lines, for testing.

        we aren't gonna refactor it yet because we anticipate a pretty big
        overhaul at .#open :[#882.D] which will make testing this less hacky.
        """

        for doc in doc_itr:
            if is_first:
                is_first = False
            else:
                echo('')
                echo('')

            echo(f'DOC TITLE: {doc.document_title}')

            for line in doc.TO_LINES(listener):
                echo(line)

        return _CustomIndex(
                total_line_counter.value,
                lines_that_express_the_notecard_heading,
                lines_that_define_bookmarks)


class _CustomIndex:
    def __init__(self, _1, _2, _3):
        self.total_line_count = _1
        self.lines_that_express_the_notecard_heading = _2
        self.lines_that_define_bookmarks = _3


@lazy
def _big_index_one():
    listener = throwing_listenerer()
    from pho.magnetics_ import big_index_via_collection as lib
    _coll = collection_one()
    return lib.big_index_via_collection(_coll, listener)


if __name__ == '__main__':
    unittest.main()

# #history-A.1
# #born.
