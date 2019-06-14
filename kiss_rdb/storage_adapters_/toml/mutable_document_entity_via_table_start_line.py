def MDE_via_TSLO(tslo):  # mutable document entity via table start line object
    return _MutableDocumentEntity()._init_via_TSLO(tslo)


class _MutableDocumentEntity:
    """
    we follow the double responsibility principle:

    1) expose a mutable list API that the operations can layer on top of.
    the operations are concerned with things like ensuring that the lines
    adjacent to edited lines are not comments. we do not effectuate such
    assurances here but we make them possible with the API we expose.

    2) gist API. help prevent gist collisions, with procurement.
    """

    def __init__(self):
        self._init_mutex = None

    def BUILD_MUTABLE_COPY__(self):

        new_dict, new_LL = _complicated_deep_copy(self._LL)

        # table start line object is immutable. if trailing comment, comes w/

        new_TSLO = self._table_start_line_object

        # --

        return self.__class__()._init_via(new_LL, new_TSLO, new_dict)

    def _init_via_TSLO(self, table_start_line_object):
        from kiss_rdb.magnetics_ import doubly_linked_list_functions as _
        _linked_list = _.build_new_doubly_linked_list()
        return self._init_via(_linked_list, table_start_line_object, {})

    def _init_via(self, linked_list, table_start_line_object, dct):
        del self._init_mutex
        self._LL = linked_list  # #testpoint (attr name)
        self._table_start_line_object = table_start_line_object  # #testpoint
        self._IID_via_gist = dct
        return self

    # -- write

    def delete_attribute_body_block_via_gist__(self, gist):
        _iid = self._IID_via_gist[gist]  # (Case4233)
        self._delete_block_via_iid(_iid)

    def _delete_block_via_iid(self, iid):  # #testpoint

        blk = self._LL.delete_item(iid)
        if _yes_gist(blk):
            # (or keep two dictionaries)
            for gist, this_iid in self._IID_via_gist.items():
                if iid == this_iid:
                    found_gist = gist
                    break
            self._IID_via_gist.pop(found_gist)
        return blk

    def replace_attribute_block__(self, blk):
        _gist = _gist_via_attribute_block(blk)
        _iid = self._IID_via_gist[_gist]
        return self._LL.replace_item(_iid, blk)

    def insert_body_block(self, blk, iid):

        yes = _yes_gist(blk)
        if yes:
            gist = self._gist_yes_check(blk)

        new_iid = self._LL.insert_item_before_item(blk, iid)

        if yes:
            self._IID_via_gist[gist] = new_iid

        return new_iid

    def append_body_block(self, blk, listener=None):

        yes = _yes_gist(blk)
        if yes:
            gist = self._gist_yes_check(blk, listener)
            if gist is None:
                return

        iid = self._LL.append_item(blk)

        if yes:
            self._IID_via_gist[gist] = iid

        return okay

    def _gist_yes_check(self, attr_blk, listener=None):

        gist = _gist_via_attribute_block(attr_blk, listener)
        if gist is None:
            return

        if gist in self._IID_via_gist:
            assert(listener)
            _item = self._LL.item_via_IID(self._IID_via_gist[gist])
            _whine_about_collision(  # (Case4155)
                    listener=listener,
                    new_name=attr_blk.attribute_name_string,
                    existing_name=_item.attribute_name_string,
                    )
            return

        return gist

    # -- read

    def to_yes_value_dictionary_as_storage_adapter_entity(self):
        return self.to_dictionary_two_deep_()['core_attributes']

    def to_dictionary_two_deep_(self):
        from .entity_via_identifier_and_file_lines import (
                dictionary_two_deep_via_entity_line_stream_)
        return dictionary_two_deep_via_entity_line_stream_(self)

    def to_line_stream(self):
        yield self._table_start_line_object.line
        for blk in self.to_body_block_stream_as_MDE_():
            for line in blk.to_line_stream():
                yield line

    def to_body_block_stream_as_MDE_(self):
        return self._LL.to_item_stream()

    def any_block_via_gist__(self, gist):
        if gist in self._IID_via_gist:
            return self._LL.item_via_IID(self._IID_via_gist[gist])

    @property
    def identifier(self):
        return self._table_start_line_object.identifier__()


def _complicated_deep_copy(old_LL):
    """a linked list has reasons why its internal identifiers (integers) are
    internal. when we copy a linked list we may get new identifiers so we
    need to make our gist index again
    """

    new_LL = old_LL.__class__()

    new_dict = {}

    for iid in old_LL.to_internal_identifier_stream():  # just ints

        block = old_LL.item_via_IID(iid)
        new_IID = new_LL.append_item(block)

        if _yes_gist(block):
            _gist = _gist_via_attribute_block(block)
            new_dict[_gist] = new_IID  # iid via gist

    return new_dict, new_LL


def _yes_gist(blk):
    if blk.is_attribute_block:
        return True
    if blk.is_discretionary_block:
        return False
    assert(False)


def _gist_via_attribute_block(attr_blk, listener=None):
    from .blocks_via_file_lines import attribute_name_functions_
    return attribute_name_functions_().name_gist_via_name(
            attr_blk.attribute_name_string, listener)


# == whiners

def _whine_about_collision(listener, new_name, existing_name):
    def structer():
        return {
                'reason': (
                    f'new name {repr(new_name)} too similar to '
                    f'existing name {repr(existing_name)}'),
                'expecting': 'available name',
                }
    listener('error', 'structure', 'input_error', structer)


# ==

okay = True

# #abstracted/#birth
