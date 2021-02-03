from pelican.contents import Article as pelican_Article
from collections import namedtuple as _nt


"""
EXPERIMENTALLY: We render a pseudo-expandable-collapsable tree of *arbitrary*
depth for website navigation (a "nav tree"); with these weird


Conceptually, this is the data for the nav:
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

    def build_getter(k):
        # For each article, we build the nav tree only lazily: If you have
        # 100 articles, that's 100 nav-trees you have to build, each
        # requiring various traversals and link construcrtions..

        def func():
            if func.x is None:
                func.x = build_nav_tree(k)
            return func.x
        func.x = None
        return func

    def build_nav_tree(k):
        kv = {k: v for k, v in do_build_nav_tree(k)}
        return _NavTree(**kv)

    def do_build_nav_tree(k):
        trail_upwards = [k]
        curr = k
        while True:
            curr = parent_of[curr]  # #here1
            if curr is None:
                break
            trail_upwards.append(curr)

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

    root_key, children_of, parent_of, article_via_key = \
        _build_big_index(generator.articles, build_getter)
    top_level_keys = children_of[root_key]
    parent_of[root_key] = None  # #here1


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
    return root_key, children_of, parent_of, article_via_key


def _build_nav_tree(these):
    return _NavTree(**{k: v for k, v in these})


_NavTree = _nt(
    '_NavTree', """
        top_level_nodes_before
        depth_trail
        sibling_nodes_before
        current_node_title
        sibling_nodes_after
        children_nodes
        top_level_nodes_after
    """.split(),
    defaults=((), (), (), None, (), (), ())
)


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

# #born
