"""this is all an experiment. the idea is that with the "big index"

(built below), we can "flatten" our whole collection into an ordered
series of fragments demarcated (dynamically) into documents. for larger
and larger collections we could hypothetically recurse this approach
outward to other familiar idioms like chapters, parts (part I, part II
etc), books, small libraries with ad-hoc categories, etc.

also we like the idea of making was constitutes a "document" be
configurable; like maybe it's as small as what can fit on a printed page,
or maybe it's very large like those old school internet html documenation
like the guides on tldp.org.

let's see what it's like:

  - for now, every fragment that doesn't specify a `parent`, let's
    make that fragment become the head fragment for a document. this is
    currently the sole means by which we demarcate the boundaries between
    documents (but in the future we'd like to change this, in two ways).

  - (for one thing, this current approach doesn't effect an order for
    the documents.)

  - currently the relationships we support (`parent` and `previous`)
    suggest a tree with ordered nodes. we need to specify something more
    formal eventually, but for now we'll assert a graph that doesn't cycle:
    each fragment can be in one and only one document, and ..

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

  - one idea we want to preserve is that of using a unified algorithm
    for "flattening" any node, so that the same rationale for baking a
    document goes into baking its sections and so on.
"""


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

        self._ordered_fragment_IIDs = []

        self._local_head_IID = iid
        self._relationship = relationship
        self._collection_traversal = coll_trav
        self._listener = listener

    def execute(self):

        # check that we are not cycling (IMPORTANT!)

        _ok = self.__register_descent()
        if not _ok:
            return

        # the body copy of the fragment itself comes before its associates

        self._ordered_fragment_IIDs.append(self._local_head_IID)

        # if there is a fragment that says it comes immediately after us..

        _ok = self.__then_add_immediate_next()
        if not _ok:
            return

        # for all the fragments that call this fragment a parent,..

        _ok = self.__then_do_something_crazy_for_children()
        if not _ok:
            return

        # finish

        self._collection_traversal.stack.pop()
        res = tuple(self._ordered_fragment_IIDs)
        del self._ordered_fragment_IIDs
        return res

    def __then_do_something_crazy_for_children(self):

        ct = self._collection_traversal
        prev_for = self._big_index.prev_for

        # for all the fragments that call this fragment a parent,..

        child_iids = self._big_index.children_of.get(
                self._local_head_IID, None)

        if child_iids is None:
            return _okay

        # for each child, try to get an ordering of *it's* child etc ID's

        frags_via_frag = {}
        use_child_iids = []

        for iid in child_iids:
            # we have the [#883.4] hacky provision that we delineate documents
            # by determinging head nodes as nodes without parents. were this
            # not the case, we could require that a node can have MAX ONE of
            # a parent or a previous (ie mutually exclusive but not required).
            # since we cannot require that, for nodes that hold both relation-
            # ships, we see previous-ness as having a stronger affinity than
            # parent-child, and we ASSUME that the node will be expressed that
            # way instead. (otherwise we cycle) yikes

            if iid in prev_for:
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
                self._ordered_fragment_IIDs.append(iid)

        return _okay

    def __then_add_immediate_next(self):
        # if a fragment points back to this fragment calling it "previous",..

        a = self._big_index.nexts_for.get(self._local_head_IID, None)
        if a is None:
            return _okay

        if 1 != len(a):
            return self.__when_mutliple(a)

        my_next, = a

        iid_a = self._collection_traversal.ordered_IIDs_for(
                my_next, 'the next fragment of that', self._listener)

        if iid_a is None:
            return

        out = self._ordered_fragment_IIDs

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
        cover_me(_msg)

    def __pieces_for_when_circular(self):
        for relationship, iid in self._collection_traversal.stack:
            yield f'while in {relationship} {repr(iid)}, '
        _iid = self._local_head_IID
        yield f'was about to descend into {repr(_iid)} '
        yield 'but we had recursed in to it already'

    def __when_hack_failed(self, frag_count, frags_that_have_this_frag_count):
        _iid = self._local_head_IID
        _these = ', '.join(frags_that_have_this_frag_count)
        cover_me(
                f'the children of {_iid} ({_these}) '
                f'each have exactly {frag_count} fragment(s). '
                'no basis by which to decide order. use prev intead.')

    def __when_mutliple(self, a):
        _these = ', '.join(a)
        _iid = self._local_head_IID
        cover_me(f"{_iid} has multiple calling it previous: ({_these})")

    # -- end whiners

    @property
    def _big_index(self):
        return self._collection_traversal.big_index


def big_index_via_collection(collection, listener):
    """writing this exactly as we are thinking of it...

    """

    # THESE

    frag_via_iid = {}
    ids_of_frags_with_no_parent = []
    children_of = {}
    nexts_for = {}
    prev_for = {}
    refs = []  # unresolved references

    # so..

    from pho.magnetics_ import (
            document_fragment_via_definition as frag_lib)

    id_itr = collection.to_identifier_stream(listener)
    for iid in id_itr:
        _iid_s = iid.to_string()
        _dct = collection.retrieve_entity(_iid_s, listener)
        frag = frag_lib.document_fragment_via_definition(listener, **_dct)
        if frag is None:
            return

        iid = frag.identifier_string
        parent_id = frag.parent_identifier_string
        prev_id = frag.previous_identifier_string

        if parent_id is None:
            if frag.heading is None:
                cover_me('need headings for these')  # :[#883.2]
            ids_of_frags_with_no_parent.append(iid)
        else:
            _touch_list(children_of, parent_id).append(iid)
            refs.append(('parent_identifier_string', iid))

        if prev_id is not None:
            assert(iid not in prev_for)
            prev_for[iid] = prev_id
            _touch_list(nexts_for, prev_id).append(iid)
            refs.append(('previous_identifier_string', iid))

        frag_via_iid[iid] = frag

    for (which, iid) in refs:
        frag = frag_via_iid[iid]
        remote_id = getattr(frag, which)
        if remote_id not in frag_via_iid:
            cover_me(f'{iid} has {which} that is noent: {remote_id}')

    return _BigIndex(
            ids_of_frags_with_no_parent,
            children_of,
            nexts_for,
            prev_for,
            frag_via_iid,
            )


class _BigIndex:

    def __init__(
            self,
            ids_of_frags_with_no_parent,
            children_of,
            nexts_for,
            prev_for,
            frag_via_iid,
            ):

        self.ids_of_frags_with_no_parent = ids_of_frags_with_no_parent
        self.children_of = children_of
        self.nexts_for = nexts_for
        self.prev_for = prev_for
        self.frag_via_iid = frag_via_iid

    def TO_DOCUMENT_STREAM(self, listener):

        if 0 == len(self.ids_of_frags_with_no_parent):
            cover_me('either empty index or circular refs')

        ct = _CollectionTraversal(self)

        frag_via_iid = self.frag_via_iid

        from .document_via_fragments import Document_

        for iid in self.ids_of_frags_with_no_parent:

            """order the fragments. can fail

            this is the whole key thing

            this is so cool
            """

            a = ct.ordered_IIDs_for(iid, 'document head fragment', listener)
            if a is None:
                cover_me('it is as the prophecy foretold')

            _frags = tuple(frag_via_iid[iid] for iid in a)

            yield Document_(_frags)


def _touch_list(dct, key):  # there's got to be a better idiom
    if key in dct:
        return dct[key]
    a = []
    dct[key] = a
    return a


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


_okay = True

# #born.
