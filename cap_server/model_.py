# (remember that longterm we don't want to do it this way)
"""LOOK



"""

# == Public API functions
#    (shrunk down to one function at #history-C.3)

def my_collections_via_main_recfile_(main_recfile):
    def renames(fent_name):
        if 'Capability' == fent_name:
            return ('NativeCapability', {'EID': 'ID', 'children_EIDs': 'Child'})
        if 'Note' == fent_name:
            return (None, {'parent_EID': 'Parent', 'body_lines': 'Body'})
    from kiss_rdb.storage_adapters.rec import collections_via_main_recfile as func
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

        AFTER_CREATE_OR_UPDATE_EXPERIMENTAL = None  # gone at #history-C.5

        VIEW_PIPELINES = {
            'native_URL': lambda cr, fa: _view_pipeline_for_this_one_url(cr, fa, collections)
            # (cr = component renderer; fa = formal attribute)
        }

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
                {'parent': params['parent']}, format='count', listener=listener)
        return num + 1

    @_dataclass()
    class Note:
        parent_EID: str
        ordinal: int
        body_lines: tuple[str]

        VALUE_FACTORIES = {'ordinal': generate_next_ordinal}

        AFTER_CREATE_OR_UPDATE_EXPERIMENTAL = None  # gone at #history-C.5

        def SPECIAL_REPORT():
            # Make a tally, count the notes per item, keyed to item identifier
            # Execution time should scale linearly with the increase in notes
            idens = colz['Note'].where(
                    {}, format='strings',
                    additional_recsel_options=(
                            ('--collapse',), ('--print-values', 'Parent')))
            stats = {}
            for iden_s in idens:
                if iden_s in stats:
                    stats[iden_s] += 1
                else:
                    stats[iden_s] = 1
            return stats

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


def _dataclass():
    from dataclasses import dataclass
    return dataclass


def xx(msg=None):
    raise RuntimeError(''.join(('oops', *((': ', msg) if msg else ()))))

# #history-C.5 url routing introduced some hard-coded assumptions
# #history-C.4 broke model out into individual functions, one for each class
# #history-C.3 (as noted)
# #history-C.2 enter "via dataclass"
# #history-C.1 changed main model class from namedtuple to dataclass
# #born
