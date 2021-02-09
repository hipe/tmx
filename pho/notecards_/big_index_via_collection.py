"""
(22 months later, waiting for everything to finally settle after
"documents can have child documents", then EDIT #todo)

(21 months later we decided to demarcate documents with a boolean flag
attribute. but we may still use this for integrity checks..)


this is all an experiment. the idea is that with the "big index"

(built below), we can "flatten" our whole collection into an ordered
series of notecards demarcated (dynamically) into documents. for larger
and larger collections we could hypothetically recurse this approach
outward to other familiar idioms like chapters, parts (part I, part II
etc), books, small libraries with ad-hoc categories, etc.

also we like the idea of making was constitutes a "document" be
configurable; like maybe it's as small as what can fit on a printed page,
or maybe it's very large like that oldschool internet html documentation
like the guides on tldp.org.

let's see what it's like:

  - for now, every notecard that doesn't specify a `parent`, let's
    make that notecard become the head notecard for a document. this is
    currently the sole means by which we demarcate the boundaries between
    documents (but in the future we'd like to change this, in two ways).
    (this is now the provision :[#883.4] discussed more below at #here1.)

  - (for one thing, this current approach doesn't effect an order for
    the documents.)

  - currently the relationships we support (`parent` and `previous`)
    suggest a tree with ordered nodes. we need to specify something more
    formal eventually, but for now we'll assert a graph that doesn't cycle:
    each notecard can be in one and only one document, and ..

    one possibility is that this:         represents this:

               node                             node
             /                               /   |   \
            /                              /     |     \
         child <- child <- child         child child child

    but the problem becomes:

              node
              /   \
             /     \
            /     child A <- child <- child
           /
        child B <- child

    how do we decide who comes first betwen the "child A" and "child B"
    clusters? (the illustration is deceiving. there is no stored ordering
    information in this regard.)

    our answer will be doubly linked lists, where parent also specifies
    its list of children (in order)

  - one idea we want to preserve is that of using a unified algorithm
    for "flattening" any node, so that the same rationale for baking a
    document goes into baking its sections and so on.


# On Data Integrity

This doubles as a verification for the data integrity of the collection.
There are known holes in our integrity check. See [#882.K].


# Under the New New Way:

"New way" was the introduction of the "hierarchical containter type" field,
which was optional and whose only valid value was "document". The only rule
for this used to be "documents can't be nested".

Now we're changing that (experimentally, of course) to target our shiny
new "strict nav tree" plugin for pelican, for which we want to avoid
"no-content branch nodes", or just boring "index" style branch-node
pages.

Experimentally, every node in a *document tree* will be EITHER:

- a "dewey" node
- a document node
- a section-esque node ("section node" for short)

A node is a "dewey" node if it and ALL of the zero or more nodes above it up
to the root are *not* document nodes. (The name is from the decimal system,
relating as it does to higher-level taxonomics.)

A section-esque node is any node anywhere under a document node that
is not itself a document node.

A document node may seat under another document node IFF that parent-child
relationship is immediate. So documents may be arbitrarily deeply nested
within documents, but each non-top-level document's parent must be a
document. A document cannot be a child of a section-esque node.

For now we do not proscribe any suggested ordering convention for
documents-versus-sections in a row of siblings: they can be freely intermixed.
It's tempting to say "documents should be at the end, after sections"; but
note such an ordering wouldn't affect generated document trees; and we can
see an advantage of a node "popping in and out" of document-ness (based on
volume of content, for example) all the while keeping some sort of narratively
significant ordering with its siblings.
"""


from dataclasses import dataclass as _dataclass


# == BEGIN narrative facilitator

def _narrative_property(attr):  # #[#510.6] custom memoizer decorator
    def decorator(orig_f):
        def use_f(self):
            val = getattr(self, attr, None)
            if val is not None:
                return val
            val = orig_f(self)
            if val is None:
                raise self._stop()
            setattr(self, attr, val)
            return val
        return property(use_f)
    return decorator


# ti = tree index


class NarrativeFacilitator:
    """Experimental high-level facilitator for "narrative"-style code

    The purpose is to allow us to write dense "main" code that reads like
    algorithm pseudocode, while encapsulating commmon boilerplate.

    Unlike most of our modern-day objects, this one is highly stateful.
    Every participating business value is evaluated lazily and memoized.
    When it fails to resolve, the argument "stop" exception is raised.
    Clients always catch this following the the same idiomatic pattern.
    Such exceptions will be raised repeatedly on repeated dereferencings.
    """

    def __init__(self, ncid, collection_path, listener, stop):
        self._NCID = ncid
        self._collection_path = collection_path
        self._listener, self._stop = listener, stop
        self._notecardness_is_known = False

    # Actions: whiners

    def complain_about_no_container(self):
        def lines():
            yield f"Notecard '{self._NCID}' is not part of a document or document hierarchy"  # noqa: E501
        self._listener('error', 'expression', 'notecard_not_under_container', lines)  # noqa: E501

    # High-level conditions

    @property
    def node_is_specified_and_document_tree(self):
        return 'my_state_1_node_is_dewey_node' == self._private_index[0]

    @property
    def node_is_specified_and_part_of_document(self):
        return 'my_state_2_node_is_part_of_document' == self._private_index[0]

    # (possibly mutating) Getters (as appropriate for condition)

    def PROCURE_EXACTLY_ONE_DOCUMENT_TREE(self):
        # bcoll = buisiness collection (distinct from coll (kiss-rdb storage))
        bcoll = self._read_only_collection
        bi = bcoll.build_big_index_(self._listener)
        ks = tuple(bi.built.keys())
        # ks = ('ABC', 'DEF', 'GHI', * 'sf sef sef efs fsef sef efsfe'.split())
        if 1 != len(ks):
            _when_not_one_node_tree(self._listener, ks, bcoll)
            raise self._stop()
        (k, ti), = bi.to_node_tree_index_items()

        assert ti.business_entity_cache is None  # the worst, meh
        ti.business_entity_cache = bi.cache

        return ti

    def RELEASE_DOCUMENT_TREE_INDEX(self):
        tup = self._release_thing()
        typ = tup[0]
        assert 'my_state_1_node_is_dewey_node' == typ
        ti, = tup[1:]
        return ti

    def RELEASE_CONTEXTUALIZED_ABSTRACT_DOCUMENT(self):
        itr = self._release_this_one_iterator()
        two = next(itr)  # YIKES
        ptup, ad = two
        if ad is None:
            return
        return ptup, ad

    def RELEASE_CONTEXTUALIZED_ABSTRACT_DOCUMENTS_RECURSIVE(self):
        return self._release_this_one_iterator()  # #hi.

    def _release_this_one_iterator(self):
        bcoll = self._read_only_collection
        tup = self._release_thing()
        typ = tup[0]
        assert 'my_state_2_node_is_part_of_document' == typ

        listener = self._throwing_listener  # not sure

        subtyp = tup[1]
        if 'by_way_of_tree_index' == subtyp:
            ti, = tup[2:]
            return ti.ABSTRACT_DOCUMENTS(bcoll, listener)

        assert 'by_way_of_look_up' == subtyp
        xx('have fun, will be easy, is third value')
        # ncs = (nc for (nc, depth) in x)  # ignoring depth for now
        # return bcoll.abstract_document_via_notecards(ncs, listener)

    def _release_thing(self):
        res = self._my_personal_index_value
        del self._my_personal_index_value
        return res

    @_narrative_property('_my_personal_index_value')
    def _private_index(self):
        eid = self._NCID
        if eid is None:
            return ('my_state_4_node_was_not_specified',)

        # Build the big index under the node
        bcoll = self._read_only_collection
        itr = big_index_for_one(eid, bcoll, self._listener)
        if itr is None:
            raise self._stop()
        func = higher_level_functions().tree_index_via
        tree_index = func(eid, itr)

        ddmm = tree_index.document_depth_minmax
        if ddmm is None:
            # This node is not a document, no documents within the tree.
            # We try this older "look up" way second because if it fails
            # it emits and doing it second allows us not to hack a listener
            return self._look_upwards()

        shallowest_depth, deepest_depth = ddmm
        if 0 == shallowest_depth:
            return 'my_state_2_node_is_part_of_document', 'by_way_of_tree_index', tree_index  # noqa: E501

        assert 0 < shallowest_depth
        return 'my_state_1_node_is_dewey_node', tree_index

    def _look_upwards(self):
        from .abstract_document_via_notecards import \
            document_notecards_in_order_via_any_arbitrary_start_node_ as func

        itr = func(self._NCID, self._read_only_collection, self._listener)
        if itr is None:
            # was gonna be 'my_state_3_node_has_no_documents_above_or_below'
            raise self._stop()

        return 'my_state_2_node_is_part_of_document', 'by_way_of_look_up', itr

    @property
    def notecard_NOT_USED(self):

        # Return cached value if we already resolve it (None ok)
        # (can't use normal memoizer because none is valid :/)
        if self._notecardness_is_known:
            return self._notecard
        if self._NCID is None:
            self._notecardness_is_known, self._notecard = True, None
            return

        # Resolve the notecard via the EID
        bcoll = self._read_only_collection
        nc = bcoll.retrieve_notecard(self._NCID, self._listener)
        if nc is None:
            raise self._stop()

        # Memoize it
        self._notecardness_is_known, self._notecard = True, nc
        return self._notecard

    @_narrative_property('_bcoll')
    def _read_only_collection(self):
        from pho import read_only_business_collection_via_path_ as func
        return func(self._collection_path, listener=self._listener)

    @_narrative_property('_TL')
    def _throwing_listener(self):
        def use_listener(sev, *rest):
            listener(sev, *rest)
            if 'error' == sev:
                raise self._stop()
        listener = self._listener
        assert listener
        return use_listener

    @property
    def read_only_business_collection(self):
        return self._bcoll

# == END


def big_index_for_many(argument_ncids, bcoll, listener):
    """Any series of one or more unique identifiers of the collection (in

    any order but no repeats) can produce one or more "node trees" where:

    - every identifier in the argument stream is somewhere in one of the
      result trees
    - every identifer of every root of every tree in the result set
      corresponds to one of the identifiers in the argument stream (but not
      necessarily the reverse)
    - none of the nodes in the result trees appear more than once anywhere
      in the result (which is to say the trees are disjoint — you will not
      have a tree that ends up being a parent or child tree of a later tree
      in the result set).

    Since the result trees are disjoint, they have no spatial (or otherwise)
    relationship to each other and you should not infer meaning to the order
    they appear in the ressult structure.
    """

    coll_path = bcoll.collection_path  # out here until [#882.G]
    num, x = _peek_length_of_iterator(argument_ncids)
    if 0 == num:
        # #cover-me (developed visually)
        def lines():
            yield f"empty or non-existent collection: {coll_path!r}"
        listener('error', 'expression', 'empty_or_notent_collection', lines)
        return
    if 1 == num:
        xx("fine but just be advised this looks like many not one")
    assert 2 == num
    return _big_index_when_many(x, bcoll, listener)


def _peek_length_of_iterator(itr):  # [#510.17] a common thing
    for first in itr:  # once
        for second in itr:  # once
            def rebuilt():
                yield first
                yield second
                for item in itr:
                    yield item
            return 2, rebuilt()
        return 1, first
    return 0, None


def _big_index_when_many(argument_ncids, bcoll, listener):
    """since it's MORE THAN ONE notecard we are big-indexing:

    - for each identifier,
      - if it's "seen" (recursed), skip
      - retrieve node from a caching layer but don't mark it as seen
      - if it has a parent, add it to the "postponed" queue (because
        if one of its parents appears later in the argument EIDs,
        it will get indexed there.)
      - otherwise, call our "descend" function, adding it to "seen"..
      - the result of this (not just node but tree index) should go
        in to a "built" hash..

    - for each identifier in the postponed queue,
      - if it's "seen", skip
      - again call our "descend" function,  adding it to "seen".
      - the result of this (not just node but tree index) goes into a
        "built" hash...

    - each value of the "built" hash is now your result
    """

    def main():
        postponed = []
        for eid in argument_ncids:
            if eid in seen:
                continue
            node = retrieve(eid)
            if node.parent_identifier_string is not None:
                postponed.append(eid)
                continue
            descend(node)

        for eid in postponed:
            if eid in seen:
                continue
            descend(retrieve(eid))
        return higher_level_functions()._named_tuple_for_big_index(built, cache)  # noqa: E501

    def descend(node):
        yn = _is_document(node)
        my_type = 'doc' if yn else 'dewey'  # #here2
        itr = wrapped_descend(node, my_type)
        res = tuple(_complicated_descend(itr, yn))
        eid = node.identifier_string
        assert eid not in built
        built[eid] = res

    def WRAP(vendor_descend):
        def use_descend(node, yn):
            eid = node.identifier_string
            if eid in built:
                return built.pop(eid)
            if eid in seen:
                xx(f'hmmmm think very hard: {eid!r}')
            seen.add(eid)
            return vendor_descend(node, yn)
        return use_descend

    def retrieve(eid):
        node = cache.get(eid)
        if node:
            return node
        node = do_retrieve(eid)
        if 100 < len(cache):
            xx("cache is getting big, consider etc")
        cache[eid] = node
        return node

    do_retrieve = _build_retriever(bcoll, listener)
    wrapped_descend = _build_descender(retrieve, WRAP)
    built, seen, cache = {}, set(), {}
    return main()


def big_index_for_one(argument_EID, bcoll, listener):
    """(If we're only indexing one notecard, we can bypass lots of moving

    parts: we don't do "reassignment"; we just depth-first traverse the
    tree ensuring we never see any node more than once, while determining
    depth etc.)

    - start a "seen" set
    - add the argument eid to the "seen" set
    - note whether or not the argument node is a document
    - you should never retrieve the same eid more than once
    """

    def retrieve(eid):
        if eid in seen:
            xx(f"Is graph cycling vertically? already seen: {eid!r}")
        bent = do_retrieve(eid)
        if bent is None:
            return
        seen[eid] = bent
        return bent

    do_retrieve = _build_retriever(bcoll, listener)
    seen = {}

    # ==

    argument_node = retrieve(argument_EID)
    if argument_node is None:
        return

    def main():
        is_doc = _is_document(argument_node)
        my_type = 'doc' if is_doc else 'dewey'  # #here2
        descend = _build_descender(retrieve)
        itr = descend(argument_node, my_type)
        for k, v in _complicated_descend(itr, is_doc):
            yield k, v
        yield 'business_entity_cache', seen

    return main()


def _complicated_descend(itr, is_doc):
    # trying to implement "document depth minmax" while maintaining streaming 🙃

    itr = _do_complicated_descend(itr)
    future = next(itr)
    for k, v in itr:
        yield k, v
    ddm = _combine_DDM(is_doc, future())
    if ddm:
        yield 'document_depth_minmax', ddm


def _combine_DDM(is_doc, dmm):
    if dmm:
        start, stop = dmm
        if is_doc:
            return 0, stop
        return dmm
    if is_doc:
        return 0, 0


def _do_complicated_descend(itr):
    def future():
        return dmm
    yield future
    dmm = None
    for k, x in itr:
        if 'document_depth_minmax' == k:
            assert dmm is None
            dmm = x
            continue
        yield k, x


# ==

def higher_level_functions():
    o = higher_level_functions
    if o.x is None:
        o.x = _define_higher_level_functions()
    return o.x


higher_level_functions.x = None  # #[#510.4] custom memoizer


def _define_higher_level_functions():
    """We are adamant (for now) that the result of indexing a single node tree
    be a *stream* (iterator) of name-value pairs that might go in to making an
    index; it's up to the client to consume this stream and cherry-pick (or
    otherwise process) the elements in a manner appropriate to the use case.
    Having said that, here's an example all-purpose ting
    """

    def export():
        yield 'public', 'tree_index_via', tree_index_via
        yield 'public', 'pretend_big_index', pretend_big_index
        yield 'protected', '_named_tuple_for_big_index', _BigIndex

    def to_node_tree_index_items(self):
        return ((k, tree_index_via(k, tup))
                for k, tup in self.built.items())

    def pretend_big_index(root_EID, items):
        ti = tree_index_via(root_EID, items)
        return _NOT_SURE(root_EID, ti)

    def tree_index_via(root_EID, items):
        slots, cx_of = {k: None for k in simple_fields}, {}
        for k, val in items:
            if 'expanded_children' == k:
                parent_eid, cx_eids = val
                assert parent_eid not in cx_of
                cx_of[parent_eid] = cx_eids
                continue
            if slots[k] is not None:
                xx(f"wasn't expecting there to already be a {k!r}")
            slots[k] = val
        return _TreeIndex(root_EID, children_of=cx_of, **slots)

    from collections import namedtuple as _nt

    _BigIndex = _nt('_BigIndex', ('built', 'cache'))
    _BigIndex.to_node_tree_index_items = to_node_tree_index_items

    simple_fields = """
        document_depth_minmax overall_depth business_entity_cache
    """.split()

    pub_dct, prot_dct = {}, []
    for visi, k, v in export():
        if 'public' == visi:
            pub_dct[k] = v
            continue
        assert 'protected' == visi
        prot_dct.append((k, v))

    cls = _nt('_FX', pub_dct.keys())
    for k, v in prot_dct:
        setattr(cls, k, v)  # BE CAREFUL
    return cls(** pub_dct)


@_dataclass
class _TreeIndex:
    root_EID: str
    document_depth_minmax: tuple
    overall_depth: int
    children_of: dict
    business_entity_cache: dict

    def ABSTRACT_DOCUMENTS(self, bcoll, listener):
        return _abstract_documents_via_tree_index(self, bcoll, listener)

    def to_node_count(self):
        return sum(len(v) for v in self.children_of.values()) + 1


class _NOT_SURE:  # #todo away this
    def __init__(self, eid, ti):
        self._result = ((eid, ti),)

    def to_node_tree_index_items(self):
        return self._result

    @property
    def cache(self):
        return self._result[0][1].business_entity_cache


def _abstract_documents_via_tree_index(ti, bcoll, listener):
    """
    This is the essential [#882.D] document-within-document implementation/
    late integrity check. 19½ months after project birth (at #history-B.6)
    it's much more complicated, as complicated as this:
    """

    def recurse(node, parent_ptup):  # ptup = path tuple
        if _is_document(node):
            return recurse_into_document(node, parent_ptup)
        return recurse_into_dewey(node, parent_ptup)

    def recurse_into_dewey(node, parent_ptup):
        eid = node.identifier_string
        cx = cx_of.get(eid)
        if cx is None:
            xx(f"strange: {eid!r} is a dewey node with no children? maybe OK")

        this_ptup = ptup_plus(node, parent_ptup)
        for ch_k in cx:
            for directive in recurse(cache[ch_k], this_ptup):
                yield directive

    def recurse_into_document(node, parent_ptup):

        # Because we're insane we stream the section nodes into the abstract
        # document maker while accumulating the child documents; rather than
        # partition-flushing the stream ourselves into two lists.

        def flatten():
            yield node
            for k, ch_node in do_recurse_into_document(node.identifier_string):
                if 'section_esque_node' == k:
                    yield ch_node
                    continue
                assert 'child_document' == k
                child_document_head_nodes.append(ch_node)

        child_document_head_nodes = []

        this_ptup = ptup_plus(node, parent_ptup)

        ad = bcoll.abstract_document_via_notecards(flatten(), listener)
        if not ad:
            yield this_ptup, None
            return  # or we could stay and do children [#882.V]

        child_document_head_nodes = tuple(child_document_head_nodes)
        ad.CHILDREN_DOCUMENT_HEAD_NODES = child_document_head_nodes
        yield parent_ptup, ad

        for ch_node in child_document_head_nodes:
            for ptup, ad in recurse_into_document(ch_node, this_ptup):
                yield ptup, ad

    def do_recurse_into_document(k):
        if (cx := cx_of.get(k)) is None:
            return
        for ch_k in cx:
            ch_node = cache[ch_k]
            if _is_document(ch_node):
                yield 'child_document', ch_node
                continue
            yield 'section_esque_node', ch_node
            for k, v in recurse_assert_no_children(ch_k):
                yield k, v

    def recurse_assert_no_children(k):
        if (cx := cx_of.get(k)) is None:
            return
        for ch_k in cx:
            ch_node = cache[ch_k]
            if _is_document(ch_node):
                xx(f"{k!r} (section-esque) can't have child {ch_k!r} (document)")  # noqa: E501
            yield 'section_esque_node', ch_node
            for k, v in recurse_assert_no_children(ch_k):
                yield k, v

    def ptup_plus(node, ptup):
        slug = _slug_via_heading_EXPERIMENTAL(node.heading)
        if not len(slug):
            xx(f"can't make slug from heading: {node.heading!r}")
        return (*ptup, slug)

    cx_of = ti.children_of
    cache = ti.business_entity_cache
    return recurse(cache[ti.root_EID], ())


def _slug_via_heading_EXPERIMENTAL(heading):  # repeating something from elsew
    import re
    all_caps = re.compile(r'^[A-Z]+\Z')
    pcs = (s for s in re.split('[^a-zA-Z0-9]+', heading) if len(s))
    pcs = ((s if all_caps.match(s) else s.lower()) for s in pcs)
    return '-'.join(pcs)


def _build_retriever(bcoll, listener):
    def retrieve(eid):
        node = bcoll.retrieve_notecard(eid, listener)
        if node is None:
            return
        assert eid == node.identifier_string  # else something is very wrong
        return node
    return retrieve


def _build_descender(retrieve, WRAP_DESCEND_EXPERIMENTAL=None):
    """
    == this is the start of the "recurse" function ==
      - which requires a "node" argument
      - and an argument of whether or not we are "in" a document

    - (We will not traverse your any siblings (horizontally))
    - If you have zero children:
      - yield that you have an overall depth of 1
      - (whether we ourselves are a document is handled by caller)
      - return

    - Otherwise, for each of your one or more children:
      - assert the current node has no previous (else integrity error)

      - start your overall depth at 1 (this is a "max" number we will add to)

      - while true:
        - if current node is in seen hash, data integrity error
        - add it to the seen hash

        - make a copy of the boolean of whether or not you're under a document
        - if the current node is a document
            - if you are somewhere under a document in this recurse,
              data integrity error
            - update the above boolean to true (it must have been false)
            - do you have an existing dminmax to be returned? if yes:
              - whatever the min was before, set it to 1 now (it could not
                have been zero)
              - leave the max as is
            - otherwise:
              - set dminmax to 1, 1. that is, set both min and max to 1
        - recurse. with the results:
          - did the call result in a document depth minmax?
            - add 1 to each (they are both depths)
            - if we have no dminmax,
              - set it to this
            - otherwise,
              - update our dminmax min and max if necessary in the usual way
          - get the overall depth as reported by the node
          - add one to it.
          - if this is more than your "max" depth above, update your max
        - if current node has next, loop again else break
        - if you have a dminmax, yield that
        - yield your overall depth as that max
    """

    def descend(node, my_type):
        cx = node.children
        if cx is None:
            yield 'overall_depth', 1
            return
        assert len(cx)  # don't store empty lists as empty lists

        my_dminmax = None
        my_overall_depth_so_far_which_is_a_max = 1
        expanded_children_EIDs = []
        for ch in expand_children(cx, node.identifier_string):
            cheid = ch.identifier_string
            expanded_children_EIDs.append(cheid)
            ch_type = _derive_context_aware_type(ch, my_type)
            if 'doc' == ch_type:
                if my_dminmax:
                    my_dminmax[0] = 1
                else:
                    my_dminmax = [1, 1]
            kw = {}
            for k, v in descend(ch, ch_type):
                if 'expanded_children' == k:
                    yield k, v
                    continue
                assert k not in kw
                kw[k] = v
            ch_dminmax = kw.pop('document_depth_minmax', None)
            if ch_dminmax:
                cands = [d+1 for d in ch_dminmax]
                if my_dminmax:
                    if cands[0] < my_dminmax[0]:
                        my_dminmax[0] = cands[0]
                    if my_dminmax[1] < cands[1]:
                        my_dminmax[1] = cands[1]
                else:
                    my_dminmax = cands
            cand = kw.pop('overall_depth') + 1
            if my_overall_depth_so_far_which_is_a_max < cand:
                my_overall_depth_so_far_which_is_a_max = cand

        if my_dminmax:
            yield 'document_depth_minmax', tuple(my_dminmax)

        yield 'overall_depth', my_overall_depth_so_far_which_is_a_max
        ec_val = node.identifier_string, tuple(expanded_children_EIDs)
        yield 'expanded_children', ec_val

    def expand_children(cx, cstacker):
        local_seen = set()  # we've got to check this somewhere else hang
        for ch in do_expand_children(cx, cstacker):
            eid = ch.identifier_string
            if eid in local_seen:
                xx(f"risk of linked list infinite loop cycle: {eid!r}")
            local_seen.add(eid)
            yield ch

    def do_expand_children(cx, peid):  # note [#882.E] will explain
        for eid in cx:
            node = retrieve(eid)
            if node.previous_identifier_string:
                xx(_when_big_problems(node, peid))
            yield node
            neid = node.next_identifier_string
            if neid is None:
                continue

            while True:
                node = retrieve(neid)
                if eid != node.previous_identifier_string:
                    xx(f"prev of {neid!r} should be {eid!r} but is {node.previous_identifier_string!r}")  # noqa: E501
                yield node
                eid = neid
                neid = node.next_identifier_string
                if neid is None:
                    break

    if WRAP_DESCEND_EXPERIMENTAL:
        descend = WRAP_DESCEND_EXPERIMENTAL(descend)

    return descend


def _derive_context_aware_type(ch, my_type):

    if 'section_esque' == my_type:
        if _is_document(ch):
            xx("can't have document node under section-esque node")

        # Yes, OK: a section can be under another section
        return 'section_esque'

    if 'doc' == my_type:
        if _is_document(ch):
            # Yes, OK: a document can be under another document
            return 'doc'

        # Yes, OK: a section can be under a document
        return 'section_esque'

    assert 'dewey' == my_type
    if _is_document(ch):
        # Yes, OK: a document can be under a dewey
        return 'doc'

    # Yes, OK: a dewey can be under another dewey
    return 'dewey'


def _is_document(node):
    return 'document' == node.hierarchical_container_type


# == Whiners

def _when_not_one_node_tree(listener, tree_idens, bcoll):
    0 == len(tree_idens) and xx('wahoo')
    from pho.magnetics_.text_via import word_wrap_pieces_using_commas as func

    def lines():
        yield "Multiple node trees, choose one:"
        for line in func(tree_idens, 24):
            yield line
    listener('error', 'expression', 'multiple_node_trees', lines)


def _when_big_problems(node, peid):
    return ' '.join(_pieces_for_big_problems(node, peid))


def _pieces_for_big_problems(node, peid):
    meid = node.identifier_string
    prev = node.previous_identifier_string
    yield f"{meid!r} appears in the list of children for {peid!r}"
    yield f"but it has a previous of {prev!r}."
    near_peid = node.parent_identifier_string
    if peid == near_peid:
        return
    yield f"Futhermore, it thinks its parent ID is {near_peid!r}"


def xx(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


""":#here2: doing the New New way right involves knowing the full context
of a node up to the root: if a node is a not-document, you can't know whether
it's a dewey or a section-esque without searching upwards until you find
either a document or the root.

Places marked with this tag indicate places that are vulnerable to such
a mis-characterization of the start node from a recursion; that is, we
will let some invalid document trees through for now.
"""


# #history-B.6 just kidding documents can have documents
# #history-B.5 remove lots of old way code before hierarchical container type
# #history-B.4
# #born.
