# (remember that longterm we don't want to do it this way)
"""LOOK



"""

# == Public API functions

def UPDATE_ENTITY(recfile, fent, param_directives, listener):
    return _collection(recfile, fent).create_entity(param_directives, listener)


def CREATE_ENTITY(recfile, fent, params, listener):
    return _collection(recfile, fent).create_entity(params, listener)


def RETRIEVE_ENTITY(recfile, EID, listener):
    return _collection(recfile, 'Capability').retrieve_entity(EID, listener)


def TRAVERSE_COLLECTION(recfile, listener):
    return _collection(recfile, 'Capability').where(listener=listener)


def _collection(main_recfile, formal_entity_name):
    return _lazy_collection(main_recfile)[formal_entity_name]


def _lazy_collection(main_recfile):
    def dataclasserer(colz):
        # If you ever feel that the model is "too big" to load all the model
        # every time any dataclass is needed, we can complicate this
        return _build_datamodel(colz).__getitem__

    def renames(fent_name):
        if 'Capability' == fent_name:
            return ('NativeCapability', {'EID': 'ID', 'children_EIDs': 'Child'})
        if 'Note' == fent_name:
            return (None, {'body_lines': 'Body'})
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
        native_URL: str = None
        children_EIDs: tuple = ()

        def RETRIEVE_NOTES(self, listener):
            return collections['Note'].where(
                {'parent': self.EID}, order_by='ordinal', listener=listener)

        @property
        def implementation_state(_):
            return random_implementation_state()

    random_implementation_state = _build_randomer()

    @export
    @dataclass
    class Note:
        parent: str
        ordinal: int
        body: tuple[str]

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

# #history-C.2 enter "via dataclass"
# #history-C.1 changed main model class from namedtuple to dataclass
# #born
