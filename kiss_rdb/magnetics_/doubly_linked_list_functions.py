def build_new_doubly_linked_list():
    return _DoublyLinkedList()


class _DoublyLinkedList:

    def __init__(self):
        _write_lower_level_methods(self)
        self._head_IID = None
        self._tail_IID = None

    def to_item_stream(self):
        item_via_IID = self.item_via_IID
        for iid in self.to_internal_identifier_stream():
            yield item_via_IID(iid)

    def to_internal_identifier_stream(self):  # #testpoint
        next_IID_via_IID = self.next_IID_via_IID
        iid = self._head_IID
        while iid is not None:
            yield iid
            iid = next_IID_via_IID(iid)

    def head_IID(self):
        return self._head_IID

    def tail_IID(self):
        return self._tail_IID


def _write_lower_level_methods(attrs):
    """
    functional w/ closures for encapsulation
    """

    items = [None]  # just for sanity & challenge, this way 0 is never an IID
    holes = []

    prev_dct = {}
    next_dct = {}

    def append_item(item):

        iid = provision_IID()
        items[iid] = item

        old_tail = attrs._tail_IID  # None ok
        attrs._tail_IID = iid

        if old_tail is None:
            attrs._head_IID = iid  # detroit become non empty (Case1369)
        else:
            next_dct[old_tail] = iid  # append to non-empty (Case1371)

        prev_dct[iid] = old_tail  # None ok
        next_dct[iid] = None

        return iid

    def insert_item_before_item(item, right_iid):
        assert(right_iid)  # #[008.D]

        iid = provision_IID()
        items[iid] = item

        old_prev = prev_dct[right_iid]  # None ok
        prev_dct[right_iid] = iid
        prev_dct[iid] = old_prev  # None ok

        if old_prev is None:
            attrs._head_IID = iid  # insert at head (Case1373)
        else:
            next_dct[old_prev] = iid  # insert into mid (Case1375)

        next_dct[iid] = right_iid
        return iid

    def provision_IID():
        if len(holes):
            # delete then add (Case1385)
            iid = holes.pop()
        else:
            iid = len(items)
            items.append(None)  # weee
        return iid

    def delete_item(iid):
        item = items[iid]
        holes.append(iid)
        items[iid] = None

        old_prev = prev_dct.pop(iid)
        old_next = next_dct.pop(iid)

        if old_prev is None:  # delete at head (Case4097)
            attrs._head_IID = old_next  # None ok
        else:  # if i had a previous update its next (Case1379)
            next_dct[old_prev] = old_next  # None ok

        if old_next is None:  # delete at tail (Case1381)
            attrs._tail_IID = old_prev  # None ok
        else:  # if i had a next update its previous (Case4097)
            prev_dct[old_next] = old_prev  # None ok

        # detroit become empty is (Case1377)

        return item

    def replace_item(iid, item):
        old_item = items[iid]
        items[iid] = item
        return old_item

    o = attrs
    o.append_item = append_item
    o.insert_item_before_item = insert_item_before_item
    o.item_via_IID = items.__getitem__
    o.next_IID_via_IID = next_dct.__getitem__
    o.prev_IID_via_IID = prev_dct.__getitem__
    o.delete_item = delete_item
    o.replace_item = replace_item

# #born.
