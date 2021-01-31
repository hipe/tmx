"""
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
"""


# bcoll = buisiness collection (as distinct from coll, kiss-rdb storage collec)


# == BEGIN

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
        if self._NCID is None:
            return False
        return 'this_is_a_document_tree_index' == self._my_personal_index[0]

    @property
    def node_is_specified_and_part_of_document(self):
        if self._NCID is None:
            return False
        return 'these_are_notecards' == self._my_personal_index[0]

    # (possibly mutating) Getters (as appropriate for condition)

    def PROCURE_EXACTLY_ONE_DOCUMENT_TREE(self):
        bcoll = self._read_only_collection
        bi = bcoll.build_big_index_NEW_(self._listener)
        ks = tuple(bi.built.keys())
        # ks = ('ABC', 'DEF', 'GHI', * 'sf sef sef efs fsef sef efsfe'.split())
        if 1 != len(ks):
            _when_not_one_node_tree(self._listener, ks, bcoll)
            raise self._stop()
        (k, ti), = bi.to_node_tree_index_items()

        assert ti.business_entity_cache is None  # the worst, meh
        ti = ti._replace(business_entity_cache=bi.cache)

        return ti

    def RELEASE_DOCUMENT_TREE(self):
        typ, x = self._release_thing()
        assert 'this_is_a_document_tree_index' == typ
        return x

    def RELEASE_ABSTRACT_DOCUMENT(self):
        typ, x = self._release_thing()
        assert 'these_are_notecards' == typ
        ncs = (nc for (nc, depth) in x)  # ignoring depth for now
        from .abstract_document_via_notecards import \
            abstract_document_via_notecards_iterator_ as func
        return func(ncs)

    def _release_thing(self):
        typ, x = self._my_personal_index_value
        del self._my_personal_index_value
        return typ, x

    @_narrative_property('_my_personal_index_value')
    def _my_personal_index(self):
        eid = self._NCID
        assert eid is not None

        # Build the big index under the node
        bcoll = self._read_only_collection
        itr = big_index_for_one(eid, bcoll, self._listener)
        # ..
        func = higher_level_functions().tree_index_via
        tree_index = func(eid, itr)

        ddmm = tree_index.document_depth_minmax
        if ddmm is None:
            # This node is not a document, no documents within the tree.
            # We try this older "look up" way second because if it fails
            # it emits and doing it second allows us not to hack a listener
            return self._ting_ting()

        return 'this_is_a_document_tree_index', tree_index

    def _ting_ting(self):
        from .abstract_document_via_notecards import \
            document_notecards_in_order_via_any_arbitrary_start_node_ as func

        itr = func(self._NCID, self._read_only_collection, self._listener)
        if itr is None:
            raise self._stop()
        return 'these_are_notecards', itr

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
        res = wrapped_descend(node, yn)
        if yn:
            res = (('document_depth_minmax', (0, 0)), *res)  # #here3
        else:
            res = tuple(res)
        eid = node.identifier_string
        assert eid not in built
        built[eid] = res

    def WRAP(vendor_descend):
        def use_descend(node, yn):
            eid = node.identifier_string
            if eid in built:
                return built.pop(eid)
            if eid in seen:
                xx('hmmmm think very hard')
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

    def main():
        argument_node = retrieve(argument_EID)
        is_doc = _is_document(argument_node)

        if is_doc:
            yield 'document_depth_minmax', (0, 0)  # #here3

        descend = _build_descender(retrieve)
        for k, v in descend(argument_node, is_doc):
            yield k, v
        yield 'business_entity_cache', seen

    def retrieve(eid):
        if eid in seen:
            xx(f"Is graph cycling vertically? already seen: {eid!r}")
        bent = do_retrieve(eid)
        seen[eid] = bent
        return bent

    do_retrieve = _build_retriever(bcoll, listener)
    seen = {}
    return main()


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
        yield 'protected', '_named_tuple_for_big_index', _BigIndex_NEW_WAY

    def to_node_tree_index_items(self):
        return ((k, tree_index_via(k, tup))
                for k, tup in self.built.items())

    def tree_index_via(root_EID, items):
        slots, cx_of = {k: None for k in simple_fields}, {}
        for k, val in items:
            if 'expanded_children' == k:
                parent_eid, cx_eids = val
                assert parent_eid not in cx_of
                cx_of[parent_eid] = cx_eids
                continue
            assert slots[k] is None
            slots[k] = val
        return _TreeIndex(root_EID, children_of=cx_of, **slots)

    from collections import namedtuple as _nt

    _BigIndex_NEW_WAY = _nt('_BigIndex_NEW_WAY', ('built', 'cache'))
    _BigIndex_NEW_WAY.to_node_tree_index_items = to_node_tree_index_items

    simple_fields = """
        document_depth_minmax overall_depth business_entity_cache
    """.split()

    _TreeIndex = _nt('_TreeIndex', ('root_EID', *simple_fields, 'children_of'))

    def TO_ABSTRACT_DOCUMENTS(self):
        return _abstract_documents_via_tree_index(self)

    def count(self):
        return sum(len(v) for v in self.children_of.values()) + 1

    _TreeIndex.TO_ABSTRACT_DOCUMENTS = TO_ABSTRACT_DOCUMENTS
    _TreeIndex.to_node_count = count

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


def _abstract_documents_via_tree_index(ti):

    def recurse(k, path_head):
        node = cache[k]
        if _is_document(node):
            flat = recurse_nodes_via_node(k)
            ad = AD_via(flat)
            yield path_head, ad
            return

        slug = _slug_via_heading_EXPERIMENTAL(node.heading)
        if not len(slug):
            xx(f"can't make slug from heading: {node.heading!r}")

        ch_path_head = (*path_head, slug)
        for ch_k in cx_of[k]:
            for tup in recurse(ch_k, ch_path_head):
                yield tup

    def recurse_nodes_via_node(k):
        yield cache[k]
        ks = cx_of.get(k)
        if ks is None:
            return
        for ch_k in ks:
            for node in recurse_nodes_via_node(ch_k):
                yield node

    from pho.notecards_.abstract_document_via_notecards import \
        abstract_document_via_notecards_iterator_ as AD_via

    cx_of = ti.children_of
    cache = ti.business_entity_cache
    return recurse(ti.root_EID, ())


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
            xx(f"invalid enitty identifier in reference? {eid!r}")
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

    def descend(node, is_somewhere_under_document):
        cx = node.children
        if cx is None:
            yield 'overall_depth', 1
            return
        assert len(cx)  # don't store empty lists as empty lists

        my_dminmax = None
        my_overall_depth_so_far_which_is_a_max = 1
        expanded_children_EIDs = []
        for ch in expanded_children(cx):
            cheid = ch.identifier_string
            expanded_children_EIDs.append(cheid)

            is_somewhere_under_document_for_ch = is_somewhere_under_document
            if _is_document(ch):
                if is_somewhere_under_document:
                    xx("can't have document inside of document")
                is_somewhere_under_document_for_ch = True
                if my_dminmax:
                    my_dminmax[0] = 1
                else:
                    my_dminmax = [1, 1]
            kw = {}
            for k, v in descend(ch, is_somewhere_under_document_for_ch):
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

    def expanded_children(cx):
        local_seen = set()  # we've got to check this somewhere else hang
        for ch in do_expanded_children(cx):
            eid = ch.identifier_string
            if eid in local_seen:
                xx(f"risk of linked list infinite loop cycle: {eid!r}")
            local_seen.add(eid)
            yield ch

    def do_expanded_children(cx):  # note [#882.E] will explain
        for eid in cx:
            node = retrieve(eid)
            if node.previous_identifier_string:
                xx("data-integrity error: child cannot have previous")

            yield node
            neid = node.next_identifier_string
            if neid is None:
                continue

            while True:
                node = retrieve(neid)
                if eid != node.previous_identifier_string:
                    xx("data-integrity error: next doesn't point back to prev")
                yield node
                eid = neid
                neid = node.next_identifier_string
                if neid is None:
                    break

    if WRAP_DESCEND_EXPERIMENTAL:
        descend = WRAP_DESCEND_EXPERIMENTAL(descend)

    return descend


def _is_document(node):
    return 'document' == node.hierarchical_container_type


class _CollectionTraversal:
    """mainly, maintain a dictionary so we can sanity check for the integrity

    error of cycling. (it would otherwise be bad.)

    this is also the entrypoint for each recursion.
    """

    def __init__(self, bi):
        self.stack = []
        self.seen = set()
        self.big_index = bi

    def ordered_IIDs_for(self, iid, relationship, listener):
        return _OrderedRun(iid, relationship, self, listener).execute()


class _OrderedRun:
    """for this first pass, .. half of this is rando and half is pure, we

    don't know which is which yet.

    for now we apply this principle that the `previous` relationship
    is straightforward and absolute: the node that says it goes after another
    node in this manner is guaranteed to be expressed *immediately* after it,
    or we fail.

    whereas when we don't have a `previous` but only a `parent`, our
    expression is much messier..
    """

    def __init__(self, iid, relationship, coll_trav, listener):

        self._ordered_notecard_IIDs = []

        self._local_head_IID = iid
        self._relationship = relationship
        self._collection_traversal = coll_trav
        self._listener = listener

    def execute(self):

        # check that we are not cycling (IMPORTANT!)

        _ok = self.__register_descent()
        if not _ok:
            return

        # the body copy of the notecard itself comes before its associates

        self._ordered_notecard_IIDs.append(self._local_head_IID)

        # if there is a notecard that says it comes immediately after us..

        _ok = self.__then_add_immediate_next()
        if not _ok:
            return

        # for all the notecards that call this notecard a parent,..

        _ok = self.__then_do_something_crazy_for_children()
        if not _ok:
            return

        # finish

        self._collection_traversal.stack.pop()
        res = tuple(self._ordered_notecard_IIDs)
        del self._ordered_notecard_IIDs
        return res

    def __then_do_something_crazy_for_children(self):

        ct = self._collection_traversal
        prev_of = self._big_index.previous_of

        # for all the notecards that call this notecard a parent,..

        child_iids = self._big_index.children_of.get(
                self._local_head_IID, None)

        if child_iids is None:
            return _okay

        # for each child, try to get an ordering of *it's* child etc ID's

        frags_via_frag = {}
        use_child_iids = []

        for iid in child_iids:
            # we have the #here1 hacky provision that we delineate documents
            # by determining head nodes as nodes without parents. were this
            # not the case, we could require that a node can have MAX ONE of
            # a parent or a previous (ie mutually exclusive but not required).
            # since we cannot require that, for nodes that hold both relation-
            # ships, we see previous-ness as having a stronger affinity than
            # parent-child, and we ASSUME that the node will be expressed that
            # way instead. (otherwise we cycle) yikes

            if iid in prev_of:
                continue
            use_child_iids.append(iid)

            iid_a = ct.ordered_IIDs_for(
                    iid, 'the child of that', self._listener)
            if iid_a is None:
                return

            frags_via_frag[iid] = iid_a

        del child_iids

        # now that you know how many flattened children each child has,
        # you can group each of your children by that number

        ids_via_frag_count = {}
        for iid in use_child_iids:  # traverse again
            _len = len(frags_via_frag[iid])
            _touch_list(ids_via_frag_count, _len).append(iid)

        # here we effect that we want the narrative sub-branches to come out
        # in ASCENDING order of their (coarsely measured) "size". so each
        # next narrative clustering gets progressively more and more involved

        # to make it DESCENDING instead, simply add reversed() to the below

        frag_counts = sorted(ids_via_frag_count.keys())

        for frag_count in frag_counts:
            frags_that_have_this_frag_count = ids_via_frag_count[frag_count]

            if 1 < len(frags_that_have_this_frag_count):
                # this is where the hack falls apart. remember it's all
                # just an experiment

                return self.__when_hack_failed(
                        frag_count, frags_that_have_this_frag_count)

            _iid, = frags_that_have_this_frag_count
            for iid in frags_via_frag[_iid]:
                self._ordered_notecard_IIDs.append(iid)

        return _okay

    def __then_add_immediate_next(self):
        # if a notecard points back to this notecard calling it "previous",..

        my_next = self._big_index.next_of.get(self._local_head_IID)
        if my_next is None:
            return _okay

        iid_a = self._collection_traversal.ordered_IIDs_for(
                my_next, 'the next notecard of that', self._listener)

        if iid_a is None:
            return

        out = self._ordered_notecard_IIDs

        for iid in iid_a:
            out.append(iid)

        return _okay

    def __register_descent(self):

        ct = self._collection_traversal
        iid = self._local_head_IID

        if iid in ct.seen:
            self.__when_circular_reference()
            return

        ct.seen.add(iid)
        ct.stack.append((self._relationship, iid))
        return _okay

    # -- whiners

    def __when_circular_reference(self):
        _msg = ''.join(self.__pieces_for_when_circular())
        xx(_msg)

    def __pieces_for_when_circular(self):
        for relationship, iid in self._collection_traversal.stack:
            yield f'while in {relationship} {repr(iid)}, '
        _iid = self._local_head_IID
        yield f'was about to descend into {repr(_iid)} '
        yield 'but we had recursed in to it already'

    def __when_hack_failed(self, frag_count, frags_that_have_this_frag_count):
        _iid = self._local_head_IID
        _these = ', '.join(frags_that_have_this_frag_count)
        xx(
                f'the children of {_iid} ({_these}) '
                f'each have exactly {frag_count} notecard(s). '
                'no basis by which to decide order. use prev intead.')

    # -- end whiners

    @property
    def _big_index(self):
        return self._collection_traversal.big_index


def func(collection, listener):

    ids_of_frags_with_no_parent_or_previous = []
    unresolved_forward_references_of = {}

    parent_of = {}
    children_of = {}
    previous_of = {}
    next_of = {}

    frag_of = {}

    from modality_agnostic import ModalityAgnosticErrorMonitor
    mon = ModalityAgnosticErrorMonitor(listener)

    # Layer One: check mutual exclusivities etc in each single notecard

    _unsanititized_pass(
            ids_of_frags_with_no_parent_or_previous,
            unresolved_forward_references_of,
            parent_of, children_of, previous_of, next_of, frag_of,
            collection, mon)

    if not mon.OK:
        return

    # Layer Two: unresolved references

    if _complain_about_unresolved_forward_references(
            listener, unresolved_forward_references_of, frag_of):
        return

    del unresolved_forward_references_of

    # Layer Three: ensure double-linkedness

    if _complain_about_bad_double_linkedness_prevs_vs_nexts(
            listener, previous_of, next_of):
        return

    if _complain_about_bad_double_linkedness_parents_vs_children(
            listener, parent_of, children_of):
        return

    return _BigIndex(
            ids_of_frags_with_no_parent_or_previous,
            parent_of, children_of, previous_of, next_of, frag_of)


def _when_not_one_node_tree(listener, tree_idens, bcoll):
    0 == len(tree_idens) and xx('wahoo')
    from pho.magnetics_.text_via import word_wrap_pieces_using_commas as func

    def lines():
        yield "Multiple node trees, choose one:"
        for line in func(tree_idens, 24):
            yield line
    listener('error', 'expression', 'multiple_node_trees', lines)


def _complain_about_bad_double_linkedness_parents_vs_children(
        listener, parent_of, children_of):

    did_complain = False

    def child_doesnt_know_about_its_parent():
        complain(
            f"child '{child_iid_s}' must point back up to"
            f" its parent '{parent_iid_s}'")

    def child_has_wrong_parent_id():
        complain(
            f"child '{child_iid_s}'"
            f" its parent is '{remote_parent_iid_s}'"
            f" but it's in the list of '{parent_iid_s}' 's children")

    def parent_doesnt_know_about_children():
        inverted = {}
        for child_iid_s, parent_iid_s in pool.items():
            _touch_list(inverted, parent_iid_s).append(child_iid_s)
        for parent_iid_s, cx in inverted.items():
            if 1 == len(cx):
                _ = f"its child '{cx[0]}'"
            else:
                _ = (f"'{s}'" for s in cx)
                _ = ', '.join(_)
                _ = f"these children: ({_})"
            complain(f"'{parent_iid_s}' doesn\'t know about {_}")

    def complain(msg):  # #has-a-copy-paste
        listener('error', 'expression', 'double_linked_error', lambda: (msg,))

    pool = {k: v for k, v in parent_of.items()}

    for parent_iid_s, cx in children_of.items():
        for child_iid_s in cx:
            if child_iid_s in pool:
                pool.pop(child_iid_s)
            remote_parent_iid_s = parent_of.get(child_iid_s)
            if parent_iid_s == remote_parent_iid_s:
                continue
            did_complain = True
            if remote_parent_iid_s is None:
                child_doesnt_know_about_its_parent()
            else:
                child_has_wrong_parent_id()

    if len(pool):
        did_complain = True
        parent_doesnt_know_about_children()

    return did_complain


def _complain_about_bad_double_linkedness_prevs_vs_nexts(
            listener, previous_of, next_of):

    did_complain = False

    def far_didnt_know():
        complain(
            f"'{curr_id}' has a previous of '{prev_id}'"
            f" but '{prev_id}' has no next")

    def mismatch():
        complain(
            f"'{curr_id}' has a previous of '{prev_id}'"
            " but '{prev_id}' thinks its next is '{far_next_id}'")

    def next_with_no_prev():
        complain(
            f"'{curr_id}' has a next of '{next_id}'"
            f" but '{next_id}' has no previous")

    def complain(msg):  # #has-a-copy-paste
        listener('error', 'expression', 'double_linked_error', lambda: (msg,))

    pool = {k: v for k, v in next_of.items()}

    for curr_id, prev_id in previous_of.items():
        far_next_id = next_of.get(prev_id)
        if far_next_id is None:
            did_complain = True
            far_didnt_know()
            continue
        pool.pop(prev_id)
        if far_next_id == curr_id:
            continue
        did_complain = True
        mismatch()

    for curr_id, next_id in pool.items():
        did_complain = True
        next_with_no_prev()

    return did_complain


def _complain_about_unresolved_forward_references(listener, unreslvd, frag_of):

    def complain(iid_s, rels):
        def lineser():
            but = "but it's not defined anywhere."
            if 1 == len(rels):
                rel, = rels
                _ = as_a_what_by_who(*rel)
                yield f"'{iid_s}' is referenced {_} {but}"
                return

            yield f"'{iid_s}' is referenced {but}"
            for rel in rels:
                _ = as_a_what_by_who(*rel)
                yield f"It's referenced {_}."

        def as_a_what_by_who(curr_iid_s, relationship_type):  # #here2
            return f"as a {relationship_type} by '{curr_iid_s}'"

        listener('error', 'expression', 'unresolved_entity_reference', lineser)

    did_complain = False
    for iid_s, rels in unreslvd.items():
        if iid_s in frag_of:
            continue
        complain(iid_s, rels)
        did_complain = True
    return did_complain


def _unsanititized_pass(
        ids_of_frags_with_no_parent_or_previous,
        unresolved_forward_references_of,
        parent_of, children_of, previous_of, next_of, frag_of,
        collection, mon):

    def maybe_see(dct, relationship_type):
        def decorator(orig_of):
            @if_not_none
            def use_f(iid_s):
                maybe_see_forward_reference(iid_s, relationship_type)
                dct[curr_iid_s] = iid_s
            return use_f
        return decorator

    def if_not_none(orig_f):
        def use_f(x):
            if x is None:
                return
            orig_f(x)
        return use_f

    @maybe_see(parent_of, 'parent')
    def maybe_see_parent(iid_s):
        pass

    @maybe_see(previous_of, 'previous')
    def maybe_see_previous(iid_s):
        pass

    @maybe_see(next_of, 'next')
    def maybe_see_next(iid_s):
        pass

    @if_not_none
    def maybe_see_children(children):
        for iid_s in children:
            maybe_see_forward_reference(iid_s, 'child')
        children_of[curr_iid_s] = children

    def maybe_see_forward_reference(iid_s, relationship_type):
        if iid_s in frag_of:  # memory optimization, meh
            return

        a = unresolved_forward_references_of.get(iid_s)
        if a is None:
            a = []
            unresolved_forward_references_of[iid_s] = a
        a.append((curr_iid_s, relationship_type))  # :#here2

    for frag in _unordered_notecards_via_collection(collection, mon.listener):

        parent_iid_s = frag.parent_identifier_string
        prev_iid_s = frag.previous_identifier_string
        curr_iid_s = frag.identifier_string
        children_iid_s = frag.children
        next_iid_s = frag.next_identifier_string

        if parent_iid_s is None and prev_iid_s is None:
            ids_of_frags_with_no_parent_or_previous.append(curr_iid_s)

        maybe_see_parent(parent_iid_s)
        maybe_see_previous(prev_iid_s)
        maybe_see_next(next_iid_s)
        maybe_see_children(children_iid_s)

        assert(curr_iid_s not in frag_of)
        frag_of[curr_iid_s] = frag


def _unordered_notecards_via_collection(collection, listener):
    with collection.open_identifier_traversal(listener) as idens:
        for nc in _notecards_via(idens, collection, listener):
            yield nc


def _notecards_via(idens, collection, listener):
    from pho.notecards_.notecard_via_definition import notecard_via_definition
    for iden in idens:
        iid_s = iden.to_string()
        ent = collection.retrieve_entity(iid_s, listener)
        if ent is None:
            xx(f'maybe this decode error thing in {repr(iid_s)}')
        dct = ent.to_dictionary_two_deep()
        nc = notecard_via_definition(**dct, listener=listener)
        if nc is None:
            return
        yield nc


class _BigIndex:

    def __init__(
            self, ids_of_frags_with_no_parent_or_previous,
            parent_of, children_of, previous_of, next_of, frag_of):

        self.ids_of_frags_with_no_parent_or_previous = ids_of_frags_with_no_parent_or_previous  # noqa: E501
        self.parent_of = parent_of
        self.children_of = children_of
        self.previous_of = previous_of
        self.next_of = next_of
        self.notecard_of = frag_of

    def TO_DOCUMENT_STREAM(self, listener=None):

        these = self.ids_of_frags_with_no_parent_or_previous

        if 0 == len(these):
            xx('either empty index or circular refs')

        ct = _CollectionTraversal(self)

        for iid in these:
            doc = self._build_document(iid, ct, listener)
            if not doc:
                xx('not doc')
            yield doc

    def RETRIEVE_DOCUMENT(self, iid_s, listener):

        dct = self.notecard_of
        if iid_s not in dct:
            xx(f'notecard not found: {repr(iid_s)}')

        frag = dct[iid_s]
        parend_iid_s = frag.parent_identifier_string
        if parend_iid_s is not None:
            reason = (f'notecard {repr(iid_s)} is not a document head'
                      f' because has parent {repr(parend_iid_s)}')
            xx(reason)

        ct = _CollectionTraversal(self)
        # even within one document we need to make sure we do not cycle

        return self._build_document(iid_s, ct, listener)

    def _build_document(self, iid_s, collection_traversal, listener):
        # the main thing of eveything

        a = collection_traversal.ordered_IIDs_for(
                iid_s, 'document head notecard', listener)
        if a is None:
            xx('it is as the prophecy foretold')

        notecard_of = self.notecard_of
        notecards = (notecard_of[eid] for eid in a)

        from .abstract_document_via_notecards import \
            abstract_document_via_notecards_iterator_ as func
        return func(notecards)


def _touch_list(dct, key):  # there's got to be a better idiom
    if key in dct:
        return dct[key]
    a = []
    dct[key] = a
    return a


def xx(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


_okay = True

# #history-B.4
# #born.
