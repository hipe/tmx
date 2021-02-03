from modality_agnostic.test_support.common import lazy
from unittest import TestCase as unittest_TestCase, main as unittest_main


class ThisOneMetaclass(type):  # #[#510.16] meta-class boilerplate

    def __new__(cls, class_name, bases=None, dct=None):
        res = type.__new__(cls, class_name, bases, dct)
        if unittest_TestCase != bases[-1]:
            setattr(res, 'test', res.do_test)
        return res


class CommonCase(unittest_TestCase, metaclass=ThisOneMetaclass):

    def do_test(self):
        generator, dct = pseudo_generator_and_dictionary_ONE()

        article = dct[self.given_current_article]
        nv = article._do_retrieve_nav_tree()

        exp_dct = {k: v for k, v in self.expected_nav_tree()}

        exp = exp_dct.pop('current_node_title')
        self.assertEqual(nv.current_node_title, exp)

        for k, v in exp_dct.items():
            act = getattr(nv, k)
            self.assertSequenceEqual(act, exp_dct[k], k)


@lazy
def pseudo_generator_and_dictionary_ONE():
    generator, dct = generator_and_etc_via_lines(given_document_tree())
    from pho_plugins.for_pelican.strict_nav_tree.pelican.\
        plugins.strict_nav_tree import _go_ham as func
    res = func(generator)
    assert res is None
    return generator, dct


def given_document_tree():
    yield r"              index                    "
    yield r"              / | \                    "
    yield r"       about_us |  tools               "
    yield r"                |      \               "
    yield r"        favorite_shows  \              "  # see #here1
    yield r"       / |     |         3D            "
    yield r"    GoT  |     |        / |\           "
    yield r"         |     |       /  | \          "
    yield r"  black_mirror |  3DS_max | maya       "
    yield r"               |          |            "
    yield r"            girlfriends  lightwave_3D  "


class Case3895_010_when_youre_on_the_index_node(CommonCase):

    given_current_article = 'index'

    def expected_nav_tree(_):
        yield 'top_level_nodes_before', \
                (('About Us', '#'), ('Favorite Shows', '#'), ('Tools', '#'))
        yield 'depth_trail', ()
        yield 'sibling_nodes_before', ()
        yield 'current_node_title', None
        yield 'sibling_nodes_after', ()
        yield 'children_nodes', ()
        yield 'top_level_nodes_after', ()


class Case3895_020_when_on_leaf_node_at_top_level(CommonCase):

    given_current_article = 'about-us'

    def expected_nav_tree(_):
        yield 'top_level_nodes_before', ()
        yield 'depth_trail', ()
        yield 'sibling_nodes_before', ()
        yield 'current_node_title', "About Us"
        yield 'sibling_nodes_after', ()
        yield 'children_nodes', ()
        yield 'top_level_nodes_after', \
            (('Favorite Shows', '#'), ('Tools', '#'))


class Case3895_030_when_on_branch_node_at_top_level(CommonCase):

    given_current_article = 'favorite-shows'

    def expected_nav_tree(_):
        yield 'top_level_nodes_before', (('About Us', '#'),)
        yield 'depth_trail', ()
        yield 'sibling_nodes_before', ()
        yield 'current_node_title', "Favorite Shows"
        yield 'sibling_nodes_after', ()
        yield 'children_nodes', \
            (('GoT', '#'), ('Black Mirror', '#'), ('Girlfriends', '#'))
        yield 'top_level_nodes_after', (('Tools', '#'),)


class Case3895_040_when_on_leaf_node_one_level_down(CommonCase):

    given_current_article = 'girlfriends'

    def expected_nav_tree(_):
        yield('top_level_nodes_before', (('About Us', '#'),))
        yield 'depth_trail', (('Favorite Shows', '#'),)
        yield 'sibling_nodes_before', (('GoT', '#'), ('Black Mirror', '#'))
        yield 'current_node_title', "Girlfriends"
        yield 'sibling_nodes_after', ()
        yield 'children_nodes', ()
        yield 'top_level_nodes_after', (('Tools', '#'),)


class Case3895_050_when_on_branch_splay_children_not_sibs(CommonCase):

    given_current_article = '3D'

    def expected_nav_tree(_):
        yield 'top_level_nodes_before', \
            (('About Us', '#'), ('Favorite Shows', '#'))
        yield 'depth_trail', (('Tools', '#'),)
        yield 'sibling_nodes_before', ()
        yield 'current_node_title', "3D"
        yield 'sibling_nodes_after', ()
        yield 'children_nodes', \
            (('3DS Max', '#'), ('Maya', '#'), ('Lightwave 3D', '#'))
        yield 'top_level_nodes_after', ()


class Case3895_060_when_deep_see_depth_trail(CommonCase):

    given_current_article = 'maya'

    def expected_nav_tree(_):
        yield('top_level_nodes_before',
              (('About Us', '#'), ('Favorite Shows', '#')))
        yield 'depth_trail', (('Tools', '#'), ('3D', '#'))
        yield 'sibling_nodes_before', (('3DS Max', '#'),)
        yield 'current_node_title', "Maya"
        yield 'sibling_nodes_after', (("Lightwave 3D", '#'),)
        yield 'children_nodes', ()
        yield 'top_level_nodes_after', ()


def generator_and_etc_via_lines(lines):
    dct = {k: v for k, v in _pseudo_articles_via_lines(lines)}
    generator = PseudoGenerator(tuple(dct.values()))
    return generator, dct


def _pseudo_articles_via_lines(lines):
    from text_lib.magnetics.graph_via_ASCII_art import func
    graph = func(lines)

    # Make the graph identifiers "like_this" look "like-this" and "Like This"
    use_key_via_graph_key, title_via_use_key = {}, {}

    def title(s):
        # (if the piece has any capital letters, retain the casing)
        return s if rx.search(s) else s.title()

    import re
    rx = re.compile('[A-Z]')

    for k in graph.nodes:
        pcs = k.split('_')
        use_key = '-'.join(pcs)
        use_key_via_graph_key[k] = use_key
        title_via_use_key[use_key] = ' '.join(title(s) for s in pcs)

    # Derive the "children of" index from the graph
    children_of = {}
    for ce in graph.to_classified_edges():
        assert ce.is_verticalesque
        assert not (ce.points_to_first or ce.points_to_second)

        parent_k = use_key_via_graph_key[ce.first_node_label]
        ch_k = use_key_via_graph_key[ce.second_node_label]

        if (arr := children_of.get(parent_k)) is None:
            children_of[parent_k] = (arr := [])
        arr.append(ch_k)

    # ==  :#here1: hackishly "correct" the order (ASCII goes line-by-line)
    cx = children_of['index']
    assert 'tools' == cx[1]
    assert 'favorite-shows' == cx[2]
    cx[1] = 'favorite-shows'
    cx[2] = 'tools'
    # ==

    for use_k in sorted(title_via_use_key.keys()):
        # (gonna normalize the order even tho it "shouldn't" matter)

        fake_children_string = None
        cx = children_of.get(use_k)
        if cx:
            fake_children_string = ' '.join(cx)

        title = title_via_use_key[use_k]

        fake_rel_source_path = f"{use_k}.md"
        art = PseudoArticle(title, fake_rel_source_path, fake_children_string)
        yield use_k, art


# == (credit to pelican plugin `similar_posts` and authors)

class PseudoGenerator:
    def __init__(self, articles):
        self.articles = articles


class PseudoArticle:
    def __init__(self, title, path, children_string):
        self.title, self.relative_source_path = title, path
        self.children = children_string

    url = '#'  # we just cover title not this, for now


if '__main__' == __name__:
    unittest_main()

# #born
