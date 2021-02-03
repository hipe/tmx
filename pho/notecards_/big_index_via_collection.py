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
        bi = bcoll.build_big_index_(self._listener)
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
        yield 'protected', '_named_tuple_for_big_index', _BigIndex

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

    _BigIndex = _nt('_BigIndex', ('built', 'cache'))
    _BigIndex.to_node_tree_index_items = to_node_tree_index_items

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


# == Whiners

def _when_not_one_node_tree(listener, tree_idens, bcoll):
    0 == len(tree_idens) and xx('wahoo')
    from pho.magnetics_.text_via import word_wrap_pieces_using_commas as func

    def lines():
        yield "Multiple node trees, choose one:"
        for line in func(tree_idens, 24):
            yield line
    listener('error', 'expression', 'multiple_node_trees', lines)


def xx(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')

# #history-B.5 remove lots of old way code before hierarchical container type
# #history-B.4
# #born.
