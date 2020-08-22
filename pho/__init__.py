def notecards_via_path(ncs_path, listener):
    def rng(pool_size):
        from random import randrange
        return randrange(1, pool_size)  # avoid 222 #open [#867.V]

    coll = collection_via_path_(ncs_path, listener, rng)
    if coll is None:
        return
    return _Notecards(coll)


class _Notecards:  # #testpoint

    def __init__(self, coll):
        self._coll = coll

    def update_notecard(self, eid_tup, cuds, listener):
        assert('existing_entity' == eid_tup[0])
        return self._create_update_or_delete_notecard(eid_tup, cuds, listener)

    def create_notecard(self, dct, listener, is_dry):
        cuds = tuple(('create_attribute', k, v) for k, v in dct.items())
        eid_tup = ('please_create_entity',)
        return self._create_update_or_delete_notecard(
                eid_tup, cuds, listener, is_dry=is_dry)

    def _create_update_or_delete_notecard(
            self, eid_tup, cuds, listener, is_dry=False):

        edit = self._prepare_edit(eid_tup, cuds, listener)
        if edit is None:
            return
        ci = self._coll.COLLECTION_IMPLEMENTATION

        order = (  # somewhere else, or not #track [#882.M]
          'parent', 'previous', 'natural_key', 'heading', 'document_datetime',
          'body', 'children', 'next', 'annotated_entity_revisions')

        eidr = edit.EID_reservation
        EID_reservation_dct = eidr.to_dictionary() if eidr else None

        bent = ci.BATCH_UPDATE(
            EID_reservation=EID_reservation_dct,
            entities_units_of_work=edit.units_of_work,
            main_business_entity=edit.main_business_entity,
            is_dry=is_dry, order=order, listener=listener)

        if bent is None:
            return
        ent_dct = bent.to_dictionary_two_deep_as_storage_adapter_entity()
        return self._notecard_via_any_entity(ent_dct, listener)

    def _prepare_edit(self, eid_tup, cuds, listener):  # #testpoint
        from .magnetics_.edited_notecard_via_request_and_notecards \
                import prepare_edit_
        return prepare_edit_(eid_tup, cuds, self, listener)

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
        return self.entity_via_definition_(nid_s, core_attributes, listener)

    def entity_via_definition_(self, nid_s, core_attributes, listener):
        from .magnetics_.document_fragment_via_definition import \
            document_fragment_via_definition as notecard_via_definition
        return notecard_via_definition(nid_s, core_attributes, listener)

    def to_identifier_stream(self, listener):
        return self._coll.to_identifier_stream(listener)

    @property
    def IMPLEMENTATION_(self):
        return self._coll


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


def collection_via_path_(collection_path, listener, rng=None):
    from kiss_rdb import collectionerer
    return collectionerer().collection_via_path(
            collection_path=collection_path,
            random_number_generator=rng, listener=listener)


HELLO_FROM_PHO = "hello from pho"

# #history-A.1: archive all C, swift and PythonKit experiments
# #born.
