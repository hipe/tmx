# it's tempting to put this in the model for the fella but we do so much
# with double-linked lists and other stuff that we do it here

_FORMALS = {  # [#822.M]
    'parent': {'editable': True, 'LL': True},
    'previous': {'editable': True, 'LL': True},
    'identifier': {'reason': 'identifiers are appointed to you'},
    'natural_key': {'editable': 'on_create', 'reason': 'permanant for life'},
    'heading': {'editable': True},
    'document_datetime': {'reason': 'for now, datetime is always generated'},
    'body': {'editable': True},
    'children': {'editable': True, 'LL': True},
    'next': {'editable': True, 'LL': True},
    'annotated_entity_revisions': {'reason': 'is read-only'},
}


def prepare_edit_(eid_tup, mixed, busi_coll, listener):
    ifc, do_revalidate = (None, False)  # ifc = index file change
    additionally = None

    ent_cud_type, *rest = eid_tup

    # If update or delete, retrieve the entity being updated or deleted
    if ent_cud_type in ('update_entity', 'delete_entity'):
        eid, = rest
        bent = busi_coll.retrieve_notecard(eid, listener)
        if bent is None:
            return
        attr_cud_tups = mixed
        del(mixed)

    # If update, things are mostly straightforward
    if 'update_entity' == ent_cud_type:
        do_revalidate = True

    # If create, do a bunch of special work
    elif 'create_entity' == ent_cud_type:
        assert(not len(rest))
        these = _prepare_for_create(mixed, busi_coll, listener)
        if these is None:
            return
        ifc, bent, attr_cud_tups = these
        do_revalidate = True

    # If delete, update any pointbacks in other entities accordingly
    else:
        assert('delete_entity' == ent_cud_type)

        # Deleting the entity itself is straightforward (just skip the section)
        # but update the remotes by adding explicit edit_attribute entries
        # (so it's handled the same as an update entity)

        assert(not len(attr_cud_tups))
        these = _prepare_for_delete(bent, busi_coll, listener)
        if these is None:
            return
        ifc, attr_cud_tups = these

        def additionally(uows):
            # in case there were no foreign keys that got deleted above, touch
            uows.will_delete_entity(eid)  # 'delete_entity'

    if (two := _partition_attribute_CUD_tups(attr_cud_tups, listener)) is None:
        return
    LLs, non_LLs = two

    from pho.magnetics_.units_of_work import UnitsOfWorkForEntity
    uows = UnitsOfWorkForEntity(ent_cud_type, bent, busi_coll, listener)

    try:
        for cud in LLs.values():
            _add_units_of_work_for_linked_list_edit(uows, cud)

        for cud in non_LLs.values():
            _add_unit_of_work_for_primitive_attribute(uows, cud)

    except _Stop:
        return

    if additionally:
        additionally(uows)

    if do_revalidate and not _revalidate(bent, listener):
        return

    class prepared_edit:  # #class-as-namespace
        index_file_change = ifc
        units_of_work = uows.release_prepared_edits()
        main_business_entity = bent

    return prepared_edit


def _prepare_for_create(mixed, busi_coll, listener):

    # Reserve a new entity identifier for the entity to create
    eidr = busi_coll.IMPLEMENTATION_.custom_functions\
        .RESERVE_NEW_ENTITY_IDENTIFIER(listener)
    if eidr is None:
        return  # full
    eid = eidr.identifier_string

    # We can't construct a business entity without the minimum core
    # attributes, which we use hardcoded default values for here for now.

    # For those default values that don't get overwritten by request
    # values, make sure these too get written to storage.

    # We accomplish this by merging the request values over the default
    # values here, which can have the effect of default values redundantly
    # getting written to the business object, which is fine.

    def starter_attributes():
        yield 'heading', '«your heading here»'
        yield 'body', '«your body here»'

    req_values = {k: v for k, v in mixed.items()}
    del(mixed)
    min_core_attrs = {}
    for k, v in starter_attributes():
        if k not in req_values:
            req_values[k] = v
        min_core_attrs[k] = v

    # Build a business object for the entity we are creating
    bent = busi_coll.entity_via_definition_(eid, min_core_attrs, listener)

    # THE WORST make it not set again because of the check #here5
    for k in min_core_attrs.keys():
        setattr(bent, k, None)

    # Flatten the request values
    attr_cud_tups = tuple(('create_attribute', k, v) for k, v in req_values.items())  # noqa: E501

    return eidr, bent, attr_cud_tups


def _prepare_for_delete(bent, busi_coll, listener):

    # Make the patch to remove the identifier from the index
    ifc = busi_coll.IMPLEMENTATION_.custom_functions\
        .REMOVE_IDENTIFIER_FROM_INDEX(bent.identifier_string, listener)
    if ifc is None:
        return  # full

    def yes(k, attr):
        # Disregard this field if the formal argument is not a foreign key
        if not attr.get('LL'):
            return
        # Disregard this field if its value is not set
        if attribute_values.get(k) is None:
            return
        return True

    attribute_values = bent.to_core_attributes()

    def do(k):
        return ('delete_attribute', k)

    attr_cud_tups = tuple(do(k) for k, fa in _FORMALS.items() if yes(k, fa))

    return ifc, attr_cud_tups


def _revalidate(ent, listener):
    from .notecard_via_definition import \
            validate_and_normalize_core_attributes_
    ca = ent.to_core_attributes()
    dct = validate_and_normalize_core_attributes_(
            ent.identifier_string, ca, listener)
    return dct is not None


def _add_units_of_work_for_linked_list_edit(uows, cud):
    use_attr = 'prext' if cud.dattr in ('previous', 'next') else cud.dattr
    _add_units_of_work(uows, use_attr, cud)


def _add_unit_of_work_for_primitive_attribute(uows, cud):
    _add_units_of_work(uows, 'primitive', cud)


def _add_units_of_work(uows, use_attr, cud):
    f = _operations[f'{cud.verb}_{use_attr}'].operation_function
    f(uows, uows.entity_identifier_string, cud)  # #here4


def _partition_attribute_CUD_tups(attr_cud_tups, listener):
    LLs = {}
    non_LLs = {}
    cp = _CUD_parser()
    for cud_tup in attr_cud_tups:
        cud = cp.parse_CUD(cud_tup)
        if cud is None:
            continue  # big flex
        (LLs if cud.formal.get('LL') else non_LLs)[cud.dattr] = cud
    if cp.has_errors:
        cp.express_errors_into(listener)
        return
    return LLs, non_LLs


# == Constants that might be default values in some functions/methods

_integrity = 'existing_data_integrity_error'
_argument_error = 'edit_argument_error'


# == Functions to be attached as methods to UoW writers (insulate these from..)

def _resolve_children(o, destination_attr, received_value):
    if isinstance(received_value, str):  # #[#022]
        raise TypeError(f"can't be string any more {repr_(received_value)}")

    cx = tuple(o.retrieve(eid) for eid in received_value)
    eid = o.entity_identifier_string
    no = tuple(i for i in range(0, len(cx)) if eid == cx[i].identifier_string)

    def attribute_noun_phrase_and_category():
        anp = destination_attr.replace('_', ' ')
        dct = {'requested_remotes': _argument_error,
               'existing_remotes': _integrity}
        cat = dct[destination_attr]
        return anp, cat

    if len(no):
        anp, cat = attribute_noun_phrase_and_category()
        o.stop(f"{anp} cannot include o '{eid}'", cat)

    if len(set(received_value)) < len(received_value):
        anp, cat = attribute_noun_phrase_and_category()
        o.stop(f"{anp} cannot include duplicates{repr_(received_value)}")

    setattr(o, destination_attr, cx)


def _ensure_existing_remotes_point_back(o):  # #here2

    if o.is_plural:
        remotes = o.existing_remotes
    else:
        remotes = (o.existing_remote,)

    def bad(i):
        existing_eid = getattr(remotes[i], attr)
        if my_eid == existing_eid:
            return
        return i, existing_eid

    my_eid = o.entity_identifier_string
    dattr, attr = o.complementaries()
    bads = tuple(x for i in range(0, len(remotes)) if (x := bad(i)))

    if not len(bads):
        return

    for i, existing_eid in bads:
        remote = remotes[i]
        msg = (f"'{remote.identifier_string}'"
               f" should have {dattr} of '{my_eid}'"
               f" but had '{existing_eid}'")
        o.emit_error_expression_line(msg, _integrity)
    raise _the_stop_exception


# == UoW Writer base class

class _UoW_Writer:

    def __init__(self, units_of_work, eid, cud):  # #here4
        assert(isinstance(eid, str))  # #[#011]
        self.entity_identifier_string = eid
        self._CUD = cud
        self._uows = units_of_work
        self.entity = self.retrieve(eid)

    def execute(self):
        self.main()

    # -- Finish line

    def will_update(o):
        o._will_set('update_attribute')

    def will_create(o):
        o._will_set('create_attribute')

    def _will_set(o, attr_cud_type):
        dattr, attr = o.dattr_attr()
        rv = o.requested_value
        o.will_set_in(o.entity, attr_cud_type, dattr, attr, rv)

    def will_delete(o):
        o.will_delete_in(o.entity, *o.dattr_attr())

    def will_set_in(o, entity, attr_cud_type, dattr, attr, value):
        o._uows.will_set_in(entity, attr_cud_type, dattr, attr, value)

    def will_delete_in(o, entity, dattr, attr):
        o._uows.will_delete_in(entity, dattr, attr)

    # -- LL stuff

    def make_changes_in_remotes_in_which_to_update_link(o):
        # for those remotes whose linkbacks we are *updating* to point to us,
        # we must notify their existing linkback (our remote remote) that they
        # no longer have a handle on the entity, by deleting *their* linkback

        my_eid = o.entity_identifier_string
        dattr, attr = o.complementaries()
        oper = _operations[o.complementary_delete_operation_name]

        for remote in o.remotes_in_which_to_update_link:
            cud_tup = ('delete_attribute', dattr)
            oo = o.begin(oper, remote.identifier_string, cud_tup)
            oo.delete_linkback_in_remote()
            o.will_set_in(remote, 'update_attribute', dattr, attr, my_eid)

        o.remotes_in_which_to_update_link = None

    def make_changes_in_remotes_in_which_to_create_link(o):
        my_eid = o.entity_identifier_string
        dattr, attr = o.complementaries()
        for remote in o.remotes_in_which_to_create_link:
            o.will_set_in(remote, 'create_attribute', dattr, attr, my_eid)
        o.remotes_in_which_to_create_link = None

    def make_changes_in_remotes_in_which_to_delete_link(o):
        dattr, attr = o.complementaries()
        for remote in o.remotes_in_which_to_delete_link:
            o.will_delete_in(remote, dattr, attr)
        o.remotes_in_which_to_delete_link = None

    def partition_set_links(o, set_links_in_these_remotes):
        update_link_in_these = []
        create_link_in_these = []

        my_eid = o.entity_identifier_string
        attr = o.complementary_object_attribute_name

        for remote in set_links_in_these_remotes:
            existing_eid = getattr(remote, attr)
            if existing_eid is None:
                create_link_in_these.append(remote)
                continue
            if my_eid == existing_eid:
                eid = remote.identifier_string
                o.integrity(f"'{eid}' already pointed back to '{my_eid}'")
            update_link_in_these.append(remote)

        return tuple(update_link_in_these), tuple(create_link_in_these)

    ensure_existing_remotes_point_back = _ensure_existing_remotes_point_back

    # --

    def begin(self, operation, eid, cud_tup):
        cud = _CUD_parser().CUD_via_tuple(cud_tup)
        return operation._begin_operation(self._uows, eid, cud)

    # -- Resolve various entities

    def resolve_requested_remote(self):
        self.requested_remote = self.retrieve(self.requested_value)

    def resolve_existing_remote(self):
        self.existing_remote = self.retrieve(self.existing_value)

    def retrieve(self, eid):
        ent = self._uows.retrieve(eid)
        if ent is None:
            raise _the_stop_exception
        return ent

    # -- Very basic beginning

    def ensure_is_different(self):
        rv = self.requested_value
        ev = self.existing_value
        if ev != rv:
            return
        self.stop(
            f"existing value of '{self.document_attribute_name}' is"
            f" already set to the requested value{repr_(ev)}")

    def ensure_not_set(self):
        value = self.existing_value
        if value is None:
            return
        self.stop(f"expecting '{self.object_attribute_name}' not to be set")

    def ensure_set(self):
        value = self.existing_value
        if value is not None:
            return
        self.stop(f"expecting '{self.object_attribute_name}' to be set")

    # -- Flow control & support (exception abuse meh)

    def integrity(self, msg):
        self.stop(msg, _integrity)

    def stop(self, msg, cat=_argument_error):
        self.emit_error_expression_line(msg, cat)
        raise _the_stop_exception

    def emit_error_expression_line(self, msg, cat=_argument_error):
        self._uows.listener('error', 'expression', cat, lambda: (msg,))

    # -- Derived properties (& similiar)

    def complementaries(self):
        dattr = self.complementary_document_attribute_name
        attr = self.complementary_object_attribute_name
        return dattr, attr

    def dattr_attr(self):
        return self.document_attribute_name, self.object_attribute_name

    @property
    def requested_value(self):
        return self._CUD.requested_value

    @property
    def existing_value(self):
        return getattr(self.entity, self.object_attribute_name)

    @property
    def document_attribute_name(self):
        return self._CUD.document_attribute_name

    @property
    def object_attribute_name(self):
        return self._CUD.document_attribute_name

    is_plural = False


# == UoW Writer Base Classes (centered around attributes)

class _Parent_UoW_Writer(_UoW_Writer):

    def append_self_to_children_of_requested_parent(o):
        o.ensure_I_am_in_requested_parents_children_zero_times()
        exi_cx = o.requested_remote.children
        if exi_cx is None:
            exi_cx = ()
            req_cx = (o.entity_identifier_string,)
            cud_tup = ('create_attribute', 'children', req_cx)
            oo = o.begin(create_children, o.requested_value, cud_tup)
            oo.will_create()
        else:
            assert(len(exi_cx))  # ..
            req_cx = (*exi_cx, o.entity_identifier_string)
            cud_tup = ('update_attribute', 'children', req_cx)
            oo = o.begin(update_children, o.requested_value, cud_tup)
            oo.will_update()

    def remove_self_from_children_of_existing_parent(o):
        o.ensure_I_am_in_existing_parents_children_exactly_once()
        tup = o.build_new_children_tuple_for_parent()
        if len(tup):
            o.update_parent_children(tup)
        else:
            o.delete_parent_children()

    def update_parent_children(o, tup):
        cud_tup = ('update_attribute', 'children', tup)
        oo = o.begin(update_children, o.existing_value, cud_tup)
        oo.will_update()

    def delete_parent_children(o):
        cud_tup = ('delete_attribute', 'children')
        oo = o.begin(delete_children, o.existing_value, cud_tup)
        oo.will_delete()

    def build_new_children_tuple_for_parent(o):
        tup = o.existing_parent.children
        here = o.my_offset_in_parent
        o.my_offset_in_parent = None
        return (*tup[0:here], *tup[here+1:])

    def ensure_I_am_in_requested_parents_children_zero_times(o):  # #here2
        leng = len(o.find_offsets_of_self_in_children_of(o.requested_remote))
        if 0 == leng:
            return
        my_eid = o.entity_identifier_string
        o.integrity(f"'{o.requested_value}' already has '{my_eid}' as child")

    def ensure_I_am_in_existing_parents_children_exactly_once(o):  # SIDE EFFEC
        founds = o.find_offsets_of_self_in_children_of(o.existing_parent)
        leng = len(founds)
        if 1 == leng:
            o.my_offset_in_parent, = founds
            return
        eid = o.existing_parent.entity_identifier_string
        my_eid = o.entity_identifier_string
        if 0 == leng:
            o.integriy(f"'{eid}' should have had '{my_eid}' as child")
        o.integrity(f"'{eid}' has MULTIPLE of '{my_eid}' as child")

    def find_offsets_of_self_in_children_of(o, parent):
        tup = parent.children
        if tup is None:
            return ()
        my_eid = o.entity_identifier_string
        return tuple(i for i in range(0, len(tup)) if my_eid == tup[i])

    @property
    def existing_parent(self):
        return self.existing_remote

    complementary_object_attribute_name = 'children'
    complementary_document_attribute_name = 'children'
    object_attribute_name = 'parent_identifier_string'


class _Prext_UoW_Writer(_UoW_Writer):

    @property
    def object_attribute_name(self):
        return _OAN_via_prext[self.document_attribute_name]

    @property
    def complementary_document_attribute_name(self):
        return _CDAN_via_prext[self.document_attribute_name]

    @property
    def complementary_object_attribute_name(self):
        return _COAN_via_prext(self.document_attribute_name)

    complementary_delete_operation_name = 'delete_prext'


def _COAN_via_prext(prext):
    return _OAN_via_prext[_CDAN_via_prext[prext]]


_OAN_via_prext = {
    'previous': 'previous_identifier_string',
    'next': 'next_identifier_string'}


_CDAN_via_prext = {
    'previous': 'next',
    'next': 'previous'}


class _Children_UoW_Writer(_UoW_Writer):

    def resolve_requested_remotes(o):
        _resolve_children(o, 'requested_remotes', o.requested_value)

    def resolve_existing_remotes(self):
        _resolve_children(self, 'existing_remotes', self.entity.children)

    def retrieve_all(o, eids):
        return tuple(o.retrieve(eid) for eid in eids)

    complementary_delete_operation_name = 'delete_parent'
    complementary_object_attribute_name = 'parent_identifier_string'
    complementary_document_attribute_name = 'parent'
    is_plural = True


# == UoW Writer extent tracking

def _operation_extenter():

    def uow_writer(cls):  # #decorator
        f = build_operation_function(cls)
        op = _Operation(f, cls)
        operations[cls.__name__] = op
        return op

    def build_operation_function(cls):
        def operation_function(units_of_work, eid, cud):
            cls(units_of_work, eid, cud).execute()  # #here4
        return operation_function

    operations = {}
    return uow_writer, operations


class _Operation:
    def __init__(self, f, c):
        self.operation_function = f
        self.operation_class = c

    def _begin_operation(self, uows, eid, cud):
        # (as it stands, this is only ever used for existing foreign keys..)
        return self.operation_class(uows, eid, cud)  # #here4


uow_writer, _operations = _operation_extenter()


# == UoW Writers

# -- Parent

@uow_writer
class update_parent(_Parent_UoW_Writer):
    def main(o):
        o.ensure_set()
        o.ensure_is_different()
        o.resolve_requested_remote()
        o.resolve_existing_remote()
        o.remove_self_from_children_of_existing_parent()
        o.append_self_to_children_of_requested_parent()
        o.will_update()


@uow_writer
class create_parent(_Parent_UoW_Writer):
    def main(o):
        o.ensure_not_set()
        o.resolve_requested_remote()
        o.append_self_to_children_of_requested_parent()
        o.will_create()


@uow_writer
class delete_parent(_Parent_UoW_Writer):

    def main(o):
        o.delete_linkback_in_remote()
        o.will_delete()

    def delete_linkback_in_remote(o):
        o.ensure_set()
        o.resolve_existing_remote()
        o.remove_self_from_children_of_existing_parent()


# -- Prev / Next ("prext")

@uow_writer
class update_prext(_Prext_UoW_Writer):
    def main(o):
        o.ensure_set()
        o.ensure_is_different()
        o.resolve_requested_remote()
        o.resolve_existing_remote()
        o.ensure_existing_remotes_point_back()
        o.derive_three_categories_of_remote()
        o.make_changes_in_remotes_in_which_to_update_link()
        o.make_changes_in_remotes_in_which_to_create_link()
        o.make_changes_in_remotes_in_which_to_delete_link()
        o.will_update()

    def derive_three_categories_of_remote(o):
        remote = o.requested_remote
        update_in_these, create_in_these = o.partition_set_links((remote,))
        o.remotes_in_which_to_update_link = update_in_these
        o.remotes_in_which_to_create_link = create_in_these
        o.remotes_in_which_to_delete_link = (o.existing_remote,)


@uow_writer
class create_prext(_Prext_UoW_Writer):
    def main(o):
        o.ensure_not_set()
        o.resolve_requested_remote()
        o.derive_two_categories_of_remote()
        o.make_changes_in_remotes_in_which_to_update_link()
        o.make_changes_in_remotes_in_which_to_create_link()
        o.will_create()

    def derive_two_categories_of_remote(o):
        _1, _2 = o.partition_set_links((o.requested_remote,))
        o.remotes_in_which_to_update_link = _1
        o.remotes_in_which_to_create_link = _2


@uow_writer
class delete_prext(_Prext_UoW_Writer):
    def main(o):
        o.delete_linkback_in_remote()
        o.will_delete()

    def delete_linkback_in_remote(o):
        o.ensure_set()
        o.resolve_existing_remote()
        o.ensure_existing_remotes_point_back()
        o.will_delete_linkback_in_remote()

    def will_delete_linkback_in_remote(o):
        o.will_delete_in(o.existing_remote, *o.complementaries())


# -- Children

@uow_writer
class update_children(_Children_UoW_Writer):

    def main(o):
        o.ensure_set()
        o.ensure_is_different()
        o.resolve_requested_remotes()
        o.resolve_existing_remotes()
        o.ensure_existing_remotes_point_back()
        o.derive_three_categories_of_remote()
        o.make_changes_in_remotes_in_which_to_update_link()
        o.make_changes_in_remotes_in_which_to_create_link()
        o.make_changes_in_remotes_in_which_to_delete_link()
        o.will_update()

    def derive_three_categories_of_remote(o):
        req = set(o.requested_value)
        exi = set(o.existing_value)

        remove_these_eids = exi - req
        add_these_eids = req - exi

        _ = o.retrieve_all(add_these_eids)
        _1, _2 = o.partition_set_links(_)

        o.remotes_in_which_to_update_link = _1
        o.remotes_in_which_to_create_link = _2
        o.remotes_in_which_to_delete_link = o.retrieve_all(remove_these_eids)


@uow_writer
class create_children(_Children_UoW_Writer):

    def main(o):
        o.ensure_not_set()
        o.resolve_requested_remotes()
        o.derive_two_categories_of_remote()
        o.make_changes_in_remotes_in_which_to_update_link()
        o.make_changes_in_remotes_in_which_to_create_link()
        o.will_create()

    def derive_two_categories_of_remote(o):
        _ = o.retrieve_all(o.requested_value)
        _1, _2 = o.partition_set_links(_)
        o.remotes_in_which_to_update_link = _1
        o.remotes_in_which_to_create_link = _2


@uow_writer
class delete_children(_Children_UoW_Writer):
    def main(o):
        o.ensure_set()
        o.resolve_existing_remotes()
        o.ensure_existing_remotes_point_back()
        o.make_changes_in_remotes_in_which_to_delete_link()
        o.will_delete()

    @property
    def remotes_in_which_to_delete_link(o):
        return o.existing_remotes

    @remotes_in_which_to_delete_link.setter  # #todo
    def remotes_in_which_to_delete_link(o, x):
        assert(x is None)
        o.existing_remotes = None


# -- Primitives

@uow_writer
class update_primitive(_UoW_Writer):
    def main(o):
        o.ensure_set()
        o.will_update()


@uow_writer
class create_primitive(_UoW_Writer):
    def main(o):
        o.ensure_not_set()  # #here5
        o.will_create()


@uow_writer
class delete_primitive(_UoW_Writer):
    def main(o):
        o.ensure_set()
        o.will_delete()


def _CUD_parser():
    from pho.magnetics_.units_of_work import CUD_parser_via_formal_entity
    return CUD_parser_via_formal_entity(_FORMALS)


def repr_(value):
    from pho import repr_ as _
    return _(value)


class _Stop(RuntimeError):
    pass


_the_stop_exception = _Stop()

# :#here3: no formalized treatment of handling formal attribute type yet.
# so far, all we do is some ad-hoc hand-parsing of particular fields

# :#here2: There are two known glaring vulnerabilities in our integrity
# checks that pertain to detecting cycles. This is discussed at [#882.K] (see)

# #born
