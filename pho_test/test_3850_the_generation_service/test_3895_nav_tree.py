from modality_agnostic.test_support.common import lazy
from unittest import TestCase as unittest_TestCase, main as unittest_main
from dataclasses import dataclass


class ThisOneMetaclass(type):  # #[#510.16] meta-class boilerplate

    def __new__(cls, class_name, bases=None, dct=None):
        res = type.__new__(cls, class_name, bases, dct)
        if unittest_TestCase != bases[-1]:
            setattr(res, 'test', res.do_test)
        return res


class CommonCase(unittest_TestCase, metaclass=ThisOneMetaclass):

    def do_test(self):
        generator, dct = gen_and_dict(document_tree_ONE, self.do_double_depth)

        article = dct[self.given_current_article]
        nv = article._do_retrieve_nav_tree()

        exp_dct = {k: v for k, v in self.expected_nav_tree()}

        if (exp := exp_dct.pop('current_node_title', None)):
            self.assertEqual(nv.current_node_title, exp)

        for k, v in exp_dct.items():
            act = getattr(nv, k)
            exp = exp_dct[k]
            if act is None or exp is None:
                self.assertEqual(act, exp, k)
                continue
            self.assertSequenceEqual(act, exp_dct[k], k)

    do_double_depth = False


def gen_and_dict(document_tree_func, do_double_depth):
    o = gen_and_dict
    key = document_tree_func.__name__, (True if do_double_depth else False)
    res = o.x.get(key)
    if res is None:
        res = build_gen_and_dict(document_tree_func, do_double_depth)
        o.x[key] = res
    return res


gen_and_dict.x = {}


def build_gen_and_dict(doc_tree_func, do_double_depth):

    # Establish a pristine copy of the articles dict
    articles_dct = doc_tree_func()
    articles_dct = {k: v._copy_this() for k, v in articles_dct.items()}
    # (articles are mutated differently based on which splay depth;
    #  don't mutate the shared, memoized articles)

    # Create a pseudo generator with the right pseudo settings
    generator = PseudoGenerator(tuple(articles_dct.values()))
    settings = _empty_dict if do_double_depth else _dict_for_do_single_depth
    generator.settings = settings

    # Call our plugin
    from pho_plugins.for_pelican.strict_nav_tree.pelican.\
        plugins.strict_nav_tree import _go_ham as func
    res = func(generator)
    assert res is None
    return generator, articles_dct


def document_tree(lines_func):
    def use_f():
        lines = lines_func()
        return {k: v for k, v in _pseudo_articles_via_lines(lines)}
    res = lazy(use_f)
    res.__name__ = lines_func.__name__
    return res


@lazy
def top_level_nodes():
    return tuple((title, url) for title, url, _cx in full_sawtooth)


full_sawtooth = (
    ('About Us', '#', ()),
    ('Favorite Shows', '#', (
        ('GoT', '#'), ('Black Mirror', '#'), ('Girlfriends', '#'))),
    ('Tools', '#', (('3D', '#'),)))


@document_tree
def document_tree_ONE():
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
        yield 'top_level_nodes_before', top_level_nodes()
        yield 'depth_trail', ()
        yield 'sibling_nodes_before', ()
        yield 'current_node_title', None
        yield 'sibling_nodes_after', ()
        yield 'children_nodes', ()
        yield 'top_level_nodes_after', ()


class Case3895_015(CommonCase):

    given_current_article = 'index'
    do_double_depth = True

    def expected_nav_tree(_):
        yield 'double_deep_nodes', full_sawtooth


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


class Case3895_035(CommonCase):

    given_current_article = 'favorite-shows'
    do_double_depth = True

    def expected_nav_tree(_):
        cx = (('GoT', '#'),
              ('Black Mirror', '#'),
              ('Girlfriends', '#'))
        yield 'double_deep_nodes_before', (('About Us', '#', ()),)
        yield 'current_node_title', 'Favorite Shows'
        yield 'children_of_current_node', cx
        yield 'double_deep_nodes_after', (('Tools', '#', (('3D', '#'),)),)


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
        yield 'top_level_nodes_before', top_level_nodes()[:2]
        yield 'depth_trail', (('Tools', '#'),)
        yield 'sibling_nodes_before', ()
        yield 'current_node_title', "3D"
        yield 'sibling_nodes_after', ()
        yield 'children_nodes', \
            (('3DS Max', '#'), ('Maya', '#'), ('Lightwave 3D', '#'))
        yield 'top_level_nodes_after', ()


class Case3895_055(CommonCase):

    given_current_article = '3D'
    do_double_depth = True

    def expected_nav_tree(_):
        cx = (('GoT', '#'), ('Black Mirror', '#'), ('Girlfriends', '#'))
        yield 'double_deep_nodes_before', (
                ('About Us', '#', ()),
                ('Favorite Shows', '#', cx))

        yield 'silo_top_node_title', 'Tools'
        yield 'silo_top_node_url', '#'

        yield 'sibling_nodes_before', ()
        yield 'current_node_title', '3D'

        cx = (('3DS Max', '#'),
              ('Maya', '#'),
              ('Lightwave 3D', '#'))

        yield 'children_of_current_node', cx

        yield 'sibling_nodes_after', ()
        yield 'double_deep_nodes_after', ()


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


class Case3895_065(CommonCase):

    given_current_article = 'maya'
    do_double_depth = True

    def expected_nav_tree(_):
        cx = (('GoT', '#'), ('Black Mirror', '#'), ('Girlfriends', '#'))
        yield 'double_deep_nodes_before', (
                ('About Us', '#', ()),
                ('Favorite Shows', '#', cx))
        yield 'silo_top_node_title', 'Tools'
        yield 'silo_top_node_url', '#'
        yield 'second_level_nodes_before', ()
        yield 'silo_second_level_node_title', '3D'
        yield 'silo_second_level_node_url', '#'
        yield 'depth_trail', ()
        yield 'sibling_nodes_before', (('3DS Max', '#'),)
        yield 'current_node_title', 'Maya'
        yield 'children_of_current_node', None
        yield 'sibling_nodes_after', (('Lightwave 3D', '#'),)
        yield 'second_level_nodes_after', ()
        yield 'double_deep_nodes_after', ()


def document_tree_via_lines(lines):
    return {k: v for k, v in _pseudo_articles_via_lines(lines)}


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


@dataclass
class PseudoArticle:
    title: str
    relative_source_path: str
    children: str

    def _copy_this(self):
        return self.__class__(
            self.title, self.relative_source_path, self.children)

    url = '#'  # we just cover title not this, for now


_dict_for_do_single_depth = {'DO_SINGLE_DEPTH_NAV_TREE': True}
_empty_dict = {}


if '__main__' == __name__:
    unittest_main()

# #born
