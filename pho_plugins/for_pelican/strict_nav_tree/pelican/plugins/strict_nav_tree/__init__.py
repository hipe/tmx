from pelican.contents import Article as pelican_Article
from dataclasses import dataclass as _dataclass


"""
EXPERIMENTALLY: We render a pseudo-expandable-collapsable tree of *arbitrary*
depth for website navigation (a "nav tree").

Here's a whirlwind introduction to our "nav-tree theory", intermixed
with requirements and features:

First; a requirement, an anti-requirement, and a design decision:

1) The underlying data must itself be a tree; i.e., every node in your site
   site graph data structure must have exactly one parent, except for your
   root node. Children have order.

2) There is no constraint on the max depth of your tree. This plugin will
   render well-formed and valid HTML for trees of any depth. (But you will
   hit some practical limits at some point, depending on the user agent etc.)

3) We chose not to give a visual representation of the root node of the site
   (the index/home page); because it effectively "wastes" one level of depth
   in a world of limited screen real-estate. As it works out, this is a
   non-issue because a link to the site itself is always rendered by a template
   elsewhere in our frontier theme (just because that's what the default theme
   does, is show the title of the site somewhere and makes it a link).

Two axioms of all nav trees, as we see it:

4) Every *branch* node (nodes with children) in your graph, when represented
   visually, must "splay" all its top-level children when it is "selected"
   (i.e., when it is the current page you are on) (otherwise how would
   you navigate to all the nodes of the site?).

5) There must be some discrete visual representation of which node you are
   "on" (if any) of the nodes displayed. (The only time you are not "on"
   one of the nodes visible in your nav is when you're at the root node,
   given (3).)

As a corollary of (3) and (4),

6) All level-1 nodes (nodes that are immediate children of the root node)
   are displayed at all times, no matter where you are on the site (that is,
   the root is always "splayed"). This follows from there being no visual
   representation of a root node to click to expand; but also it feels more
   natural, appearing and behaving like most other nav trees out in the wild
   in this regard.

This one is an interesting intersection of UX and practical vectors:

7) We do not accomodate for "pure" branch nodes; that is, every branch node
   (node with children) will also have content of its own. This sort of stems
   from the fact that we represent our document trees using vendor frontmatter
   residing in individual articles -- parent-child relationships are
   represented through a `Children` component frontmatter, frontmatter which
   is de-facto already associated with an article (with content).
   But also this produces better UX because we never produce for a branch
   node just a blank page staring back at you with nothing but nav.
   This affects the nav tree because it will never have a branch node that is
   not also "clickable". Given this, this now leads to our intuitive-most
   solution for (5): The only node in the visible nav tree that isn't
   clickable is the page you are on.

Now, as a corollary of (2),

8) IFF necessary there's a "depth trail" of links showing the trail
   between the root and the node you are on. There is no depth trail when
   you're on the root node, a level-1 one, or a level-2 node (probably
   as a corollary of several of these points).

New in this edition (#history-B.4) we have the tree "unfurled" to *two*
levels of depth hard-codedly.


For a tree unfurled to only to one level of depth, conceptually, here
is the data that goes in to the nav tree:
    - 0-N top-level nodes before
    - 0-N the depth-trail, each node clickable
    - one of:
      - IF you're ON a leaf node
        - IF depth trail is 0 length
          - the leaf you're on (not clickable)
        - OTHERWISE (the sibling splay):
          - 0-N nodes before
          - the leaf you're on (not clickable)
          - 0-N nodes after
      - OTHERWISE (and you're ON a branch node):
        - the branch you're on (not clickable)
        - splay its 1-N cx, each is clickable
    - (don't forget to close tags for each item in depth trail)
    - 0-N top-level nodes after


EXPERIMENTALLY We can distill it down to:
    - 0-N top-level nodes before
    - 0-N the depth trail
    - 0-N sibling nodes before you
    - 0 or 1 the node you're on
    - 0-N your children nodes
    - 0-N sibiling nodes after you
    - 0-N top-level nodes after
"""


def _go_ham(generator):  # #testpoint

    do_single = generator.settings.get('DO_SINGLE_DEPTH_NAV_TREE', False)

    def build_getter(k):
        # For each article, we build the nav tree only lazily: If you have
        # 100 articles, that's 100 nav-trees you have to build, each
        # requiring various traversals and link constructions...

        def func():
            if func.x is None:
                func.x = build_nav_tree(k)
            return func.x
        func.x = None
        return func

    big_index = _build_big_index(generator.articles, build_getter)

    if do_single:
        build_nav_tree = _build_build_nav_tree_for_single_deep(big_index)
    else:
        build_nav_tree = _build_build_nav_tree_for_double_deep(big_index)


def _build_build_nav_tree_for_double_deep(big_index):

    def build_nav_tree(key):
        trail_upwards = big_index.build_trail_upwards(key)
        depth = len(trail_upwards)
        if depth:
            assert 'index' == trail_upwards[-1]

        if 2 < depth:
            kw = {k: v for k, v in case_deep(trail_upwards, key)}
            return _DoubleDeepNavTreeDeeplySelected(**kw)

        if 2 == depth:
            kw = {k: v for k, v in case_level_two(trail_upwards, key)}
            return _DoubleDeepNavTreeSecondLevelNodeSelected(**kw)

        if 1 == depth:
            kw = {k: v for k, v in case_level_one(key)}
            return _DoubleDeepNavTreeTopNodeSelected(**kw)

        assert 0 == depth
        kw = {k: v for k, v in case_level_zero()}
        return _DoubleDeepNavTreeNothingSelected(**kw)

    def case_deep(trail, key):

        kw = level_one_and_two_dict(trail)
        cx = kw.pop('second_level_children')
        nb, here, na = nodes_before_here_nodes_after(*trail[-3:-1], cx)
        yield 'second_level_nodes_before', nb
        yield 'second_level_nodes_after', na

        title, url = here
        yield 'silo_second_level_node_title', title
        yield 'silo_second_level_node_url', url

        # You either do or don't have children
        ch_ks = children_of.get(key)

        # Skip the root, skip the first level, skip the 2nd. that's 3
        use_trail_ks = list(reversed(trail[:-3]))  # (zero length OK)

        for k, v in kw.items():  # common, shared boilerplate things
            yield k, v

        # If you do have children,
        if ch_ks:
            # # Put yourself on the depth trail
            # use_trail_ks.append(k)
            yield 'depth_trail', title_and_urls(use_trail_ks)

            yield 'sibling_nodes_before', None  # explicit for now

            yield 'current_node_title', article_via_key[key].title

            # Splay all your children
            yield 'children_of_current_node', title_and_urls(ch_ks)

            yield 'sibling_nodes_after', None  # explicit for now
            return

        # Since you don't have children, splay your siblings

        level_N_key = trail[0]  # (trail is backwards, 0 is key of your parent)
        ks = children_of[level_N_key]
        ks_before, _, ks_after = split_into_three(ks.index(key), ks)

        yield 'depth_trail', title_and_urls(use_trail_ks)  # 0 length OK

        yield 'sibling_nodes_before', title_and_urls(ks_before)
        yield 'current_node_title', article_via_key[key].title
        yield 'children_of_current_node', None  # make it explicit for now
        yield 'sibling_nodes_after', title_and_urls(ks_after)

    def case_level_two(trail, k):
        kw = level_one_and_two_dict(trail)
        cx = kw.pop('second_level_children')

        nb, here, na = nodes_before_here_nodes_after(k, trail[0], cx)
        yield 'sibling_nodes_before', nb
        yield 'sibling_nodes_after', na

        title, _url = here
        yield 'current_node_title', title

        ch_ks = children_of.get(k)
        if ch_ks:
            use = title_and_urls(ch_ks)
        else:
            use = None
        yield 'children_of_current_node', use

        for k, v in kw.items():
            yield k, v

    def case_level_one(k):
        kw = sawtooth_dict(k)
        title, _url, cx = kw.pop('here_three')

        yield 'current_node_title', title
        yield 'children_of_current_node', cx
        for k, v in kw.items():
            yield k, v

    def case_level_zero():
        yield 'double_deep_nodes', sawteeth

    # == Shared between level 2 and level 3

    def level_one_and_two_dict(trail):
        kw = sawtooth_dict(trail[-2])  # -1 is 'index', -2 is level_1_key
        title, url, cx = kw.pop('here_three')
        kw['silo_top_node_title'] = title
        kw['silo_top_node_url'] = url
        kw['second_level_children'] = cx
        return kw

    def sawtooth_dict(level_one_key):
        return {k: v for k, v in do_sawtooth_dict(level_one_key)}

    def do_sawtooth_dict(level_one_key):
        i = offset_via_level_one_key[level_one_key]
        bef, mid, aft = split_into_three(i, sawteeth)

        yield 'double_deep_nodes_before', bef
        yield 'here_three', mid
        yield 'double_deep_nodes_after', aft

    # ==

    def nodes_before_here_nodes_after(level_Np1_key, level_N_key, cx):
        ch_ks = children_of[level_N_key]
        i = ch_ks.index(level_Np1_key)
        return split_into_three(i, cx)

    def split_into_three(i, tup):
        return tup[:i], tup[i], tup[(i+1):]

    def title_and_urls(keys):
        return tuple(title_and_url(k) for k in keys)

    def title_and_url(k):
        article = article_via_key[k]
        return article.title, article.url

    root_key, children_of, parent_of, article_via_key = big_index
    level_one_keys = children_of[root_key]
    offset_via_level_one_key = {k: i for i, k in enumerate(level_one_keys)}

    # == FROM

    build = _make_sawtooth_builder(children_of, title_and_url)
    sawteeth = tuple(build(k) for k in level_one_keys)

    # == TO

    return build_nav_tree


def _make_sawtooth_builder(children_of, title_and_url):
    def build_sawtooth_tooth(key):
        ch_ks = children_of.get(key, ())
        cx = tuple(title_and_url(k) for k in ch_ks)
        return (*title_and_url(key), cx)
    return build_sawtooth_tooth


def _build_build_nav_tree_for_single_deep(big_index):

    def build_nav_tree(k):
        kv = {k: v for k, v in do_build_nav_tree(k)}
        return _SingleDepthNavTree(**kv)

    def do_build_nav_tree(k):

        trail_upwards = big_index.build_trail_upwards_legacy(k)

        # Edge case: root node (not in nav)
        depth = len(trail_upwards)
        if 1 == depth:
            yield 'top_level_nodes_before', of(top_level_keys)
            return

        top_level_k = trail_upwards[-2]  # -1 is always the root artcle no see
        i = top_level_keys.index(top_level_k)  # #here2
        yield 'top_level_nodes_before', of(top_level_keys[:i])
        yield 'top_level_nodes_after', of(top_level_keys[(i+1):])

        cx = children_of.get(k)

        # Are you only one level deep in the nav?
        if 2 == depth:

            # Is the selected node a leaf node?
            if cx is None:
                yield 'current_node_title', ti(top_level_k)
                return

            # You're one level deep and node has children. splay children
            yield 'current_node_title', ti(top_level_k)
            yield 'children_nodes', of(cx)
            return

        # We're somewhere "deep" inside the tree, we have a depth trail
        # (trail upwards does NOT include self, never inclues root article)
        use_trail_ks = tuple(reversed(trail_upwards[1:-1]))
        assert use_trail_ks
        yield 'depth_trail', of(use_trail_ks)

        # If we are a leaf node and not a branch node, render our siblings
        if cx is None:

            # Siblings and self
            parent_k = trail_upwards[1]
            parent_cx = children_of[parent_k]
            i = parent_cx.index(k)
            yield 'sibling_nodes_before', of(parent_cx[:i])
            yield 'current_node_title', ti(k)
            yield 'sibling_nodes_after', of(parent_cx[(i+1):])
            return

        # Otherwise, we're a branch node, render our children
        yield 'current_node_title', ti(k)
        yield 'children_nodes', of(cx)

    def of(keys):
        return tuple(two_for(k) for k in keys)

    def two_for(k):
        article = article_via_key[k]
        return article.title, article.url

    def ti(k):
        return article_via_key[k].title

    root_key, children_of, parent_of, article_via_key = big_index
    top_level_keys = children_of[root_key]
    return build_nav_tree


# == Nav Tree Data Structures (ideally there would be just one)

@_dataclass
class _DoubleDeepNavTreeNothingSelected:
    double_deep_nodes: tuple

    my_silo_type = 'silo_type_nothing_selected'


@_dataclass
class _DoubleDeepNavTreeTopNodeSelected:
    double_deep_nodes_before: tuple
    current_node_title: str
    children_of_current_node: tuple
    double_deep_nodes_after: tuple

    my_silo_type = 'silo_type_top_node_selected'


@_dataclass
class _DoubleDeepNavTreeSecondLevelNodeSelected:
    double_deep_nodes_before: tuple
    silo_top_node_title: str
    silo_top_node_url: str
    sibling_nodes_before: tuple
    current_node_title: str
    children_of_current_node: tuple
    sibling_nodes_after: tuple
    double_deep_nodes_after: tuple

    my_silo_type = 'silo_type_second_level_node_selected'


@_dataclass
class _DoubleDeepNavTreeDeeplySelected:
    double_deep_nodes_before: tuple

    silo_top_node_title: str
    silo_top_node_url: str

    second_level_nodes_before: tuple

    silo_second_level_node_title: str
    silo_second_level_node_url: str

    depth_trail: tuple

    sibling_nodes_before: tuple

    current_node_title: str

    children_of_current_node: tuple

    sibling_nodes_after: tuple

    second_level_nodes_after: tuple

    double_deep_nodes_after: tuple

    my_silo_type = 'silo_type_deeply_selected'


@_dataclass
class _SingleDepthNavTree:
    top_level_nodes_before: tuple = ()
    depth_trail: tuple = ()
    sibling_nodes_before: tuple = ()
    current_node_title: tuple = None
    sibling_nodes_after: tuple = ()
    children_nodes: tuple = ()
    top_level_nodes_after: tuple = ()

    my_silo_type = 'legacy_single_depth_tree'
    # (to be correct there should be several silo types within but meh)


# == Big Index

@_dataclass
class _BigIndex:
    root_key: str
    children_of: dict
    parent_of: dict
    article_via_key: dict

    def build_trail_upwards(self, k):
        return tuple(self._do_build_trail_upwards(k))

    def build_trail_upwards_legacy(self, k):
        return tuple(self._do_build_trail_upwards_legacy(k))

    def _do_build_trail_upwards(self, curr):
        curr = self.parent_of[curr]
        while curr is not None:  # #here1
            yield curr
            curr = self.parent_of[curr]

    def _do_build_trail_upwards_legacy(self, curr):
        while True:
            yield curr
            curr = self.parent_of[curr]
            if curr is None:  # #here1
                break

    def __iter__(self):
        return iter((self.root_key, self.children_of,
                     self.parent_of, self.article_via_key))


def _build_big_index(articles, build_getter):
    # Tricky: traverse every article, *mutating* it by putting this getter
    # on it, while also building the big index

    import re
    rx = re.compile(r'^(.+)\.md\Z')  # meh for now

    parent_of, children_of, article_via_key = {}, {}, {}
    forward_references = {}

    for article in articles:

        md = rx.match(article.relative_source_path)
        k = md[1]

        article._do_retrieve_nav_tree = build_getter(k)  # #testpoint

        # Index the article by its key
        if k in article_via_key:
            raise _MyException(f"Multiple articles with same key: {k!r}")
        article_via_key[k] = article

        # Nothing more to do unless it has children
        s = getattr(article, 'children', None)
        if not s:
            continue

        # Associate parent with children and child with parent
        these = tuple(s.split(' '))
        children_of[k] = these

        for ch_k in these:
            if ch_k in parent_of:
                otr_k = parent_of[ch_k]
                raise _MyException(f"{ch_k!r} is child of both {otr_k!r} and {k!r}")  # noqa: E501
            parent_of[ch_k] = k
            if ch_k in article_via_key:
                continue
            forward_references[ch_k] = k

    # Did any keys appear in lists of children then ended up not existing?
    these = set(forward_references) - set(article_via_key)
    if these:
        these = tuple(sorted(these))  # normalize ordering for tests
        raise _MyException(f"unresolved fwd reference(s): {these!r}")

    # Now that everything is indexed,
    these = tuple(k for k in article_via_key if k not in parent_of)
    if 1 < len(these):
        these = tuple(sorted(these))  # normalize order for tests
        raise _MyException(f"Only one can be root, the others need a parent: {these!r}")  # noqa: E501

    root_key, = these
    parent_of[root_key] = None  # #here1
    return _BigIndex(root_key, children_of, parent_of, article_via_key)


def retrieve_nav_tree(self):
    return self._do_retrieve_nav_tree()


assert not hasattr(pelican_Article, 'nav_tree')
pelican_Article.nav_tree = property(retrieve_nav_tree)


def register():
    from pelican import signals
    signals.article_generator_finalized.connect(_go_ham)


_MyException = RuntimeError


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #history-B.4 double-deep
# #born
