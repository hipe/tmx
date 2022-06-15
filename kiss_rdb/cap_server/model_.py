# (remember that longterm we don't want to do it this way)
"""LOOK



"""

# == Public API functions
#    (shrunk down to one function at #history-C.3)

def collections_via_recfile_(main_recfile):
    def renames(fent_name):
        if 'Capability' == fent_name:
            return ('NativeCapability', {'EID': 'ID', 'children_EIDs': 'Child'})
        if 'Note' == fent_name:
            return (None, {'parent_EID': 'Parent', 'body_lines': 'Body'})
    from kiss_rdb.storage_adapters_.rec import LAZY_COLLECTIONS as func
    return func(main_recfile, 'Capability', _build_datamodel_bridge, renames)


def _build_datamodel_bridge(collections):

    class Bridge:
        def __getitem__(_, fent_name):
            assert fent_name not in _sanity
            _sanity[fent_name] = None
            return _model_class_definitions[fent_name](collections)

        def keys(_):
            return _model_class_definitions.keys()

    return Bridge()


_sanity = {}


def model_class(fent_name):
    def decorator(func):
        _model_class_definitions[fent_name] = func
    return decorator


_model_class_definitions = {}


@model_class('Capability')
def _(collections):
    @_dataclass()
    class Capability:
        label: str
        EID: str
        implementation_status: 'ImplementationStatus' = None
        native_URL: 'url' = None
        children_EIDs: tuple['Capability'] = ()

        def RETRIEVE_NOTES(self, listener):
            return collections['Note'].where(
                {'parent': self.EID}, order_by='ordinal', listener=listener)

        @classmethod
        def AFTER_CREATE_OR_UPDATE_EXPERIMENTAL(_, which, eid):
            assert 'UPDATE' == which  # ..
            # (at writing, Capability's are never CREATE'd, BUT THIS WILL CHANGE)
            return 'view_capability', {'eid': eid}

        VIEW_PIPELINES = {
            'native_URL': lambda cr, fa: _view_pipeline_for_this_one_url(cr, fa, collections)
            # (cr = component renderer; fa = formal attribute)
        }

        @property
        def FAKE_RANDOM_implementation_status(self):
            return random_implementation_state()

        FORM_ACTION_EXPERIMENTAL = 'edit_capability'  # no

    random_implementation_state = _build_randomer()

    return Capability


@model_class('ImplementationStatus')
def _(colz):
    from enum import Enum, unique as unique_enum
    @unique_enum
    class ImplementationStatus(Enum):
        WONT_IMPLEMENT = 'wont_implement_or_not_applicable'
        MIGHT_IMPLEMENT = 'might_implement_eventually'
        IS_IMPLEMENTED = 'is_implemented'

    return ImplementationStatus


@model_class('Note')
def _(colz):

    def generate_next_ordinal(params, listener):
        """The next ordinal is the number of notes under this item plus one.
        So if it has zero notes, the next ordinal is '1' and so on.
        We chose this definition because it is semi-sane and relatiely easy
        to implement (with the vendor's --count option); however if we ever
        get to deleting notes, etc. Also, would be nice to #lock-the-file
        """
        num = colz['Note'].where(
                {'parent': params['parent']}, count=True, listener=listener)
        return num + 1

    @_dataclass()
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

    return Note


@model_class('StringTemplateVariable')
def _(colz):
    @_dataclass()
    class StringTemplateVariable:
        template_variable_name: str
        template_variable_value: str

        @classmethod
        def RETRIEVE_EXTENT(_):
            # Optimization: don't read the whole file just to get one record.
            # This will bite us eventually XX..
            return colz['StringTemplateVariable'].where(
                    additional_recsel_options=(('--number', '0'),))

        IS_IN_MAIN_RECFILE = True

    return StringTemplateVariable


# == Support (& Legacy - kept in position for history)

def _view_pipeline_for_this_one_url(cr, fa, colz):
    """Change the URL string by expanding the template variables.
    This is all EXPERIMENTAL to see how it feels using the database itself
    for templating like this.
    Also EXPERIMENTAL around *the idea* of a "view pipeline".
    Proof of concept, but a little nasty as written
    """

    def use_cr(ent, margin, indent):
        orig_url = ent.native_URL
        if orig_url is None:
            return cr(ent, margin, indent)
        assert use_cr.sanity_once
        use_cr.sanity_once = False
        _ = tuple(colz['StringTemplateVariable'].dataclass.RETRIEVE_EXTENT())
        tv, = _  # assume one for now
        needle = ''.join(('{', tv.template_variable_name, '}'))
        use_url = orig_url.replace(needle, tv.template_variable_value)
        use_ent = ReplacementEntity(use_url)
        return cr(use_ent, margin, indent)
    class ReplacementEntity:
        def __init__(self, x):
            self.native_URL = x
    use_cr.component_label = cr.component_label  # ick/meh
    use_cr.sanity_once = True
    return use_cr


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


def _dataclass():
    from dataclasses import dataclass
    return dataclass


def xx(msg=None):
    raise RuntimeError(''.join(('oops', *((': ', msg) if msg else ()))))

# #history-C.4 broke model out into individual functions, one for each class
# #history-C.3 (as noted)
# #history-C.2 enter "via dataclass"
# #history-C.1 changed main model class from namedtuple to dataclass
# #born
