def notecards_via_path(ncs_path, listener):
    coll = collection_via_path_(ncs_path, listener)
    if coll is None:
        return
    return _Notecards(coll)


class _Notecards:  # #testpoint

    def __init__(self, coll):
        self._coll = coll

    def update_notecard(self, ncid, cuds, listener):
        edit = self._prepare_edit(ncid, cuds, listener)
        return self._send_the_edit_to_the_collection(edit, listener)

    def _prepare_edit(self, ncid, cuds, listener):  # #testpoint
        from .magnetics_.edited_notecard_via_request_and_notecards \
                import prepare_edit_
        return prepare_edit_(ncid, cuds, self, listener)

    def retrieve_notecard(self, ncid, listener):
        ent_dct = self._coll.retrieve_entity(ncid, listener)
        return self._notecard_via_any_entity(ent_dct, listener)

    def retrieve_notecard_via_identifier(self, iden, listener):
        ent_dct = self._coll.retrieve_entity_via_identifier(iden, listener)
        return self._notecard_via_any_entity(ent_dct, listener)

    def _notecard_via_any_entity(self, ent_dct, listener):
        if ent_dct is None:
            return
        nid_s, core_attributes = _validate_entity_dictionary_names(** ent_dct)
        from .magnetics_.document_fragment_via_definition import \
            document_fragment_via_definition as notecard_via_definition
        return notecard_via_definition(nid_s, core_attributes, listener)

    def to_identifier_stream(self, listener):
        return self._coll.to_identifier_stream(listener)


def _validate_entity_dictionary_names(identifier_string, core_attributes):
    return identifier_string, core_attributes


def repr_(value):
    def do_repr():
        return ''.join((': ', repr(value)))

    if not isinstance(value, str):
        assert(isinstance(value, tuple))  # ..
        return do_repr()

    if len(value) <= _SOMEWHAT_LESS_THAN_A_LINES_WIDTH:  # meh
        return do_repr()

    return ''


_SOMEWHAT_LESS_THAN_A_LINES_WIDTH = 60


# == stowaway support for magnetics

def big_index_via_collection_(coll, listener):
    from pho.magnetics_.big_index_via_collection import \
            big_index_via_collection
    return big_index_via_collection(coll, listener)


def collection_via_path_(collection_path, listener):
    from kiss_rdb import collectionerer
    return collectionerer().collection_via_path(collection_path, listener)


HELLO_FROM_PHO = "hello from pho"

# #history-A.1: archive all C, swift and PythonKit experiments
# #born.
