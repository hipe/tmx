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
        self.assertEqual(_actual, 7)

    def test_240_these_7_notecards_produced_only_4_documents(self):
        them = self.custom_index.document_titles
        count = len(them)
        self.assertEqual(count, 4)

    def test_300_all_the_bookmarks_came_out(self):
        _actual = self.custom_index.lines_that_define_bookmarks
        self.assertEqual(len(_actual), 7)

    @property
    def lines_that_expressed_headings(self):
        return self.custom_index.lines_that_express_the_notecard_heading

    @shared_subject
    def custom_index(self):
        return custom_index_via_big_index(_big_index_one(), self)


_this_range = range(52, 60)
# #history-B.4 lowered min by 7 because less blank lines
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
        from modality_agnostic import write_only_IO_proxy as func
        spy = func(
                write=writes.append,
                on_OK_exit=lambda: None)

        _big_index = _big_index_one()

        def run(listener):
            from pho.SSG_adapters_.hugo import func
            return func(
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


def custom_index_via_big_index(big_index, tc):
    signal = define_signals('document_title', 'line')

    if tc.do_debug:
        subscribe_to_signals_for_debugging(signal)

    kw = {'doc_titles': [], 'total_line_count': 0,
          'lines_that_express_the_notecard_heading': [],
          'lines_that_define_bookmarks': []}

    subscribe_to_signals_for_work(kw, signal)

    send_doc_title_signal = signal('document_title').send
    send_line_signal = signal('line').send

    def visit_doc(doc):
        send_doc_title_signal(doc.document_title)
        for line in doc.TO_LINES():
            send_line_signal(line)

    for doc in big_index.TO_DOCUMENT_STREAM():
        visit_doc(doc)

    return _CustomIndex(
        kw['total_line_count'],
        kw['lines_that_express_the_notecard_heading'],
        kw['lines_that_define_bookmarks'], kw['doc_titles'])


def subscribe_to_signals_for_work(memo, signal):

    def on_doc_title(dt):
        memo['doc_titles'].append(dt)
    signal('document_title').connect(on_doc_title)

    def on_line(line):
        char = line[0]
        if '#' == char:
            memo['lines_that_express_the_notecard_heading'].append(line)
        elif '[' == char:  # meh
            memo['lines_that_define_bookmarks'].append(line)
        memo['total_line_count'] += 1
    signal('line').connect(on_line)


def subscribe_to_signals_for_debugging(signal):

    def on_doc_title(dt):
        w(f"\n\ndoc title: {dt}\n")
    signal('document_title').connect(on_doc_title)

    def on_line(line):
        w(f"     line: {line}")
    signal('line').connect(on_line)

    from sys import stderr
    w = stderr.write


class _CustomIndex:
    def __init__(self, _1, _2, _3, _4):
        self.total_line_count = _1
        self.lines_that_express_the_notecard_heading = _2
        self.lines_that_define_bookmarks = _3
        self.document_titles = _4


@lazy
def _big_index_one():
    listener = throwing_listenerer()
    from pho.notecards_ import big_index_via_collection as lib
    _coll = collection_one()
    return lib.big_index_via_collection(_coll, listener)


# == BEGIN hackishly duplicate a small portion of `blinker`, as a treat

def define_signals(*ks):

    dct = {}
    for k in ks:
        assert k not in dct
        dct[k] = _Signal(k)

    return dct.__getitem__


class _Signal:
    def __init__(self, k):
        self._receivers = []

    def connect(self, receiver):
        self._receivers.append(receiver)

    def send(self, mixed):
        for recv in self._receivers:
            recv(mixed)

# == END


def xx(*aa):
    raise RuntimeError(f"sure, whatever: {aa!r}")


if __name__ == '__main__':
    unittest.main()

# #history-B.4
# #history-A.1
# #born.
