from pho_test.common_initial_state import \
        read_only_business_collection_one as collection_one, \
        throwing_listenerer
from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject, lazy
import unittest
from collections import namedtuple as _nt


class CommonCase(unittest.TestCase):
    do_debug = False


# Case1530-Case1610


"""
"Big Index" was created initially (and exists still) mainly to answer the
question "what are all the documents in the collection?".

The old answer [away at [#882.D]] {is|was} simply "every notecard
*without* a parent is a document". This definition of document was a shortcut
made while proving the concept that content living as a notecard can be output
as a document through an SSG. This shortcut prevented us from scaling to meet
the current scope

The dream is "dynamic taxonomification" (based only on content volume and
rubrics) but that has drawbacks for our target use case

The new way is the "hierarchichal container type" field

The old way didn't directly represent document order. We hacked around this
by leveraging the old-way SSG (hugo) mechanism of "articles" which required
"datetimes", from which the vendor SSG derives order for our documents

The new way erases this hacky reliance. Now the node order facilited by
our data-model determines document order (normally), and we are no longer
required to represent date-times on document head notecards

(This change occurred both because the old way is bad and also because in
the new way, we're targeting pelican whose _pages_ (maybe hugo has an
equivalent?) seem like a better fit than "articles"; and pages don't derive
order from timestamps (but then how?))
"""


def higher_level_end_state(attr):  # #decorator
    def decorator(orig_f):
        def use_f(self):
            two_tup_plus = getattr(self, attr)
            return {k: v for k, v in two_tup_plus.to_node_tree_index_items()}
        return use_f
    return decorator


class Case1505_the_only_New_Way_case(CommonCase):

    def test_010_expanded_children_from_one(self):
        es = self.end_state_for_one
        pool = es.children_of  # SINFUL we are about to mutate a shared subject
        for parent_eid, cx_eids in self.expected_expanded_children():
            act = pool.pop(parent_eid)
            self.assertSequenceEqual(act, cx_eids)
        assert 0 == len(pool)

    def test_020_overall_depth_from_one(self):
        act = self.end_state_for_one.overall_depth
        assert 5 == act

    def test_030_this_document_depth_minmax_from_the_one(self):
        act = self.end_state_for_one.document_depth_minmax
        self.assertSequenceEqual(act, (1, 2))

    def expected_expanded_children(_):
        yield 'A', ('E', 'Gd')
        yield 'E', ('Hd', 'Jd')
        yield 'Hd', ('K',)
        yield 'Gd', ('P', 'Q')
        yield 'P', ('U', 'V')
        yield 'Q', ('W', 'X')
        yield 'X', ('Y',)

    def test_310_if_you_wanted_all_unaffiliated_trees(self):
        def condition(tree_index):
            return tree_index.document_depth_minmax is None
        act = self.trees_via_condition(condition)
        exp = 'B', 'F', 'L', 'N'
        self.assertSequenceEqual(act, exp)

    def test_320_if_you_wanted_all_unaffiliated_terminal_notecards(self):
        def condition(tree_index):
            yes1 = tree_index.document_depth_minmax is None
            yes2 = 1 == tree_index.overall_depth
            return yes1 and yes2
        act = self.trees_via_condition(condition)
        exp = 'F', 'L'
        self.assertSequenceEqual(act, exp)

    def test_330_if_you_wanted_all_document_trees(self):
        act = self.trees_via_condition(lambda ti: ti.document_depth_minmax)
        exp = '1d', 'A', 'M', 'Zd'
        self.assertSequenceEqual(act, exp)

    def test_340_each_document_tree_knows_the_range_of_depths_of_its_documents(self):  # noqa: E501
        this = self.end_state_for_all_higher_level
        o = {k: this[k].document_depth_minmax for k in ('1d', 'A', 'M', 'Zd')}
        self.assertSequenceEqual(o['1d'], (0, 0))
        self.assertSequenceEqual(o['Zd'], (0, 0))
        self.assertSequenceEqual(o['M'], (1, 1))
        self.assertSequenceEqual(o['A'], (1, 2))

    def trees_via_condition(self, test):
        this = self.end_state_for_all_higher_level
        return tuple(sorted(k for k, v in this.items() if test(v)))

    def test_610_PIECEMEAL(self):
        # The main thing here is that it worked (because it exercises a thing)
        built, cache = self.end_state_for_piecemeal
        act = tuple(sorted(built.keys()))
        self.assertSequenceEqual(act, ('E', 'Gd'))
        assert 12 == len(cache)

    @shared_subject
    def end_state_for_piecemeal(self):
        """As disvoered in the below endstate, we have to have the identifiers
        be *not* of the whole collection so we hit reassignment.
        """

        bcoll = self.fake_collection
        eids = 'Q', 'Gd', 'K', 'E'
        return subject_function_for_many()(eids, bcoll, None)

    @shared_subject
    @higher_level_end_state('end_state_for_all')
    def end_state_for_all_higher_level(self):
        pass

    @shared_subject
    def end_state_for_all(self):
        """
        Because our fake collection produces identifiers in file-order, you
        tend to get node-tree roots before you get non-roots. In fact, you
        always will. And this is absolutely not how trees are in production
        (by design). So we reverse the identifiers here, to try and trigger
        "reassignment"

        (This explanation presupposes you have a deep understanding of the
        pseudocode in the asset file, and even still it's a doozer 🥴)

        This lead us to discover an unexpected property of our indexing:
        reassignments will never happen as long as you're traversing every
        identifier: every node with a parent is postponed until after every
        node *without* a parent (a root node). Each root node exists as its
        own isolated graph, and when it gets indexed, every node and every sub-
        tree is already "in the correct place", so reassigments never happen

        So what we discovered is that reassignments only happen if you're
        using a partial list of identifiers; and some of those identifiers
        are sub-trees inside larger trees that later identifiers are the
        root of. Whew! That is how we arrived at the set-up above
        """

        bcoll = self.fake_collection
        eids = bcoll._coll.TO_EIDS_FOR_TEST()

        peek = tuple(reversed(eids))
        eids = iter(peek)
        return subject_function_for_many()(eids, bcoll, None)

    @shared_subject
    def end_state_for_one(self):
        ncs = self.fake_collection
        itr = subject_function_for_one()('A', ncs, None)
        func = subject_module().higher_level_functions().tree_index_via
        return func('A', itr)

    @shared_subject
    def fake_collection(self):
        from pho_test.fake_collection import omg_fake_bcoll_via_lines as func
        return func(self.given_collection())

    def given_collection(_):
        yield r"                  A               "
        yield r"     B           / \              "
        yield r"    / \         /   \      Zd     "
        yield r"   C   D       /     E            "
        yield r"              /     / \           "
        yield r"     F       Gd    Hd  Jd         "
        yield r"            / \    |              "
        yield r"           /   \   K   L   M      "
        yield r"    N     /     \         / \     "
        yield r"   /     P       Q       Rd  Sd   "
        yield r"  T     / \     / \               "
        yield r"       U   V   W   X              "
        yield r"                    \             "
        yield r"                     Y    1d      "


class Case1530_basics(CommonCase):

    def test_100_collection_builds(self):
        self.assertIsNotNone(collection_one())

    def test_200_big_index_builds(self):
        self.assertIsNotNone(_big_index_one())


class Case1540_whole_document_tree_from_first_collection(CommonCase):

    def test_100_some_lines_were_made(self):
        num = self.custom_index.total_line_count

        self.assertLess(86, num)
        # (at #history-B.6 no more frontmatter in custom index. away soon)

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


_this_range = range(48, 60)
# #history-B.6 lowered min by 4 becase no more frontmatter
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
        for line in doc.TO_HOPEFULLY_AGNOSTIC_MARKDOWN_LINES():
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
    return collection_one().build_big_index_OLD_(throwing_listenerer())


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


def subject_function_for_many():
    func = subject_module().big_index_for_many
    return func


def subject_function_for_one():
    func = subject_module().big_index_for_one
    return func


def subject_module():
    import pho.notecards_.big_index_via_collection as module
    return module


def xx(*aa):
    leng = len(aa)
    if 0 == leng:
        msg = None
    elif 1 == leng:
        msg, = aa
    else:
        msg = repr(aa)
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))


if __name__ == '__main__':
    unittest.main()

# #history-B.6
# #history-B.5 insert/spike for new big index via hierarchical container type
# #history-B.4
# #history-A.1
# #born.
