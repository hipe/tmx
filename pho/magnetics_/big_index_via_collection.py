"""this is all an experiment. the idea is that with the "big index"

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


def big_index_via_collection(collection, listener):

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
    from pho.magnetics_.notecard_via_definition import notecard_via_definition
    for iden in idens:
        iid_s = iden.to_string()
        ent = collection.retrieve_entity(iid_s, listener)
        if ent is None:
            xx(f'maybe this decode error thing in {repr(iid_s)}')
        dct = ent.to_dictionary_two_deep_as_storage_adapter_entity()
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

    def TO_DOCUMENT_STREAM(self, listener):

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

        frag_of = self.notecard_of

        _frags = tuple(frag_of[iid] for iid in a)

        from .document_via_notecards import Document_

        return Document_(_frags)


def _touch_list(dct, key):  # there's got to be a better idiom
    if key in dct:
        return dct[key]
    a = []
    dct[key] = a
    return a


def xx(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


_okay = True

# #born.
