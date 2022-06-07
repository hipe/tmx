# (remember that longterm we don't want to do it this way)
"""LOOK



"""

# == Public API functions
#    (shrunk down to one function at #history-C.3)

def collections_via_recfile_(main_recfile):
    def dataclasserer(colz):
        # If you ever feel that the model is "too big" to load all the model
        # every time any dataclass is needed, we can complicate this
        return _build_datamodel(colz).__getitem__

    def renames(fent_name):
        if 'Capability' == fent_name:
            return ('NativeCapability', {'EID': 'ID', 'children_EIDs': 'Child'})
        if 'Note' == fent_name:
            return (None, {'parent_EID': 'Parent', 'body_lines': 'Body'})
    from kiss_rdb.storage_adapters_.rec import LAZY_COLLECTIONS as func
    colz = func(main_recfile, 'Capability', dataclasserer, renames)
    return colz


def _build_datamodel(collections):
    export = _build_exporter()
    from dataclasses import dataclass

    @export
    @dataclass
    class Capability:
        label: str
        EID: str
        implementation_status: str = None
        native_URL: str = None
        children_EIDs: tuple['Capability'] = ()

        def RETRIEVE_NOTES(self, listener):
            return collections['Note'].where(
                {'parent': self.EID}, order_by='ordinal', listener=listener)

        def AFTER_CREATE_OR_UPDATE_EXPERIMENTAL(which, eid):
            assert 'UPDATE' == which  # ..
            # (at writing, Capability's are never CREATE'd, BUT THIS WILL CHANGE)
            return 'view_capability', {'eid': eid}

        @property
        def FAKE_RANDOM_implementation_status(self):
            return random_implementation_state()

        FORM_ACTION_EXPERIMENTAL = 'edit_capability'  # no

    random_implementation_state = _build_randomer()

    def generate_next_ordinal(colz, listener):
      return 7654321

    @export
    @dataclass
    class Note:
        parent_EID: str
        ordinal: int
        body_lines: tuple[str]

        VALUE_FACTORIES = {'ordinal': generate_next_ordinal}
        FORM_ACTION_EXPERIMENTAL = 'add_note'

        def AFTER_CREATE_OR_UPDATE_EXPERIMENTAL(which, sanitized_params):
            assert 'CREATE' == which
            # (notes only ever get created, never updated)
            return 'view_capability', {'eid': sanitized_params['parent']}

    return export.dictionary


# == Support (& Legacy - kept in position for history)

def _build_randomer():
    def random_implementation_state():
        f = random_float()
        if f < 0.30:
            return
        if f < 0.55:
            return 'might_implement_eventually'
        if f < 0.90:
            return 'wont_implement_or_not_applicable'
        return 'is_implemented'

    from random import random as random_float
    return random_implementation_state


def _build_exporter():
    def export(class_or_function):
        k = class_or_function.__name__
        assert k not in dct
        dct[k] = class_or_function
        return class_or_function
    dct = {}
    export.dictionary = dct
    return export


def xx(msg=None):
    raise RuntimeError(''.join(('oops', *((': ', msg) if msg else ()))))

# #history-C.3 (as noted)
# #history-C.2 enter "via dataclass"
# #history-C.1 changed main model class from namedtuple to dataclass
# #born
