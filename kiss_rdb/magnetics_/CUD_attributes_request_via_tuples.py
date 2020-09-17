def request_via_tuples(tuples, listener):

    def reason(msg):
        _emit_request_error_via_reason(msg, listener)

    if not len(tuples):
        return reason('request was empty')  # (Case4214)

    from kiss_rdb.storage_adapters_.toml import (
        blocks_via_file_lines as ent_lib)

    gist_via = ent_lib.attribute_name_functions_().name_gist_via_name

    components = []
    name_index = _RequestLocalNameUniquenessValidatorIndex(listener)
    strange_verbs = None
    for tup in tuples:
        verb, attr_name_string, *rest = tup
        if verb not in _component_class_via_verb:
            if strange_verbs is None:
                strange_verbs = {}
            strange_verbs[verb] = None
            continue

        gist = gist_via(attr_name_string, listener)
        if not gist:  # life is easier to fail on the first one, meh
            return  # meh just short circuit b.c emitted (Case4216)

        an = _AttributeName(gist, attr_name_string)

        name_index.see_attribute_name(an)
        _class = _component_class_via_verb[verb]
        _cmpo = _class(an, *rest)
        components.append(_cmpo)

    if strange_verbs is not None:
        _ = ', '.join(strange_verbs.keys())
        return reason(f'unrecognized verb(s): ({_})')  # (Case4215)

    if not name_index.validate_uniqueness_of_names():
        return

    return _CUD_Attributes_Request(components)


class _CUD_Attributes_Request:

    def __init__(self, components):
        assert(components)
        self.components = tuple(components)

    def update_document_entity__(self, de, bs, listener):
        return self._same(de, bs, listener, 'update_attribute')

    def mutate_created_document_entity__(self, mde, bs, listener):
        # #testpoint
        return self._same(mde, bs, listener, 'create_attribute')

    def _same(self, de, bs, listener, create_or_update):
        from kiss_rdb.storage_adapters_.toml import (
                CUD_attributes_via_request as lib)  # #open [#867.Z] !abstractd
        _enc = bs.BUILD_ENTITY_ENCODER(listener)
        return lib.apply_CUD_attributes_request_to_MDE___(
                de, self, _enc, listener, create_or_update)


class _RequestLocalNameUniquenessValidatorIndex:

    def __init__(self, listener):
        self._collisions = {}
        self._had_collision = False
        self._listener = listener

    def see_attribute_name(self, an):
        gist = an.name_gist
        if gist in self._collisions:
            self._collisions[gist].append(an)
            self._had_collision = True
        else:
            self._collisions[gist] = [an]

    def validate_uniqueness_of_names(self):
        if self._had_collision:
            _express_collisions(self._collisions, self._listener)
            return _not_ok
        else:
            return _okay


# -- the component classes


class _CreateAttributeValueUnsanitized:

    def __init__(self, an, uv):
        self.attribute_name = an
        self.unsanitized_value = uv

    def sentence_phrases_for_collisions(tup_a):  # function not method
        sns = []
        for cmpo, blk in tup_a:
            sns.append(blk.attribute_name_string)
        if 1 == len(sns):
            mid = f"attribute {repr(sns[0])} because it already exists"
        else:
            _ = ', '.join(sns)  # no quotes here just because
            mid = f"attributes {_} because they already exist"
        one_sp = f"can't create {mid} in entity (use update?)"
        return (one_sp,)

    edit_component_key = 'create_attribute'
    attribute_must_already_exist_in_entity = False


class _UpdateAttributeValueUnsanitized:

    def __init__(self, an, uv):
        self.attribute_name = an
        self.unsanitized_value = uv

    def sentence_phrases_for_missings(tups):  # function not method
        return _sentence_phrases_for_missings('update', tups)

    edit_component_key = 'update_attribute'
    attribute_must_already_exist_in_entity = True


class _DeleteAttribute:

    def __init__(self, an):
        self.attribute_name = an

    def sentence_phrases_for_missings(tups):  # function not method
        return _sentence_phrases_for_missings('delete', tups)

    edit_component_key = 'delete_attribute'
    attribute_must_already_exist_in_entity = True


_component_class_via_verb = {
        'create_attribute': _CreateAttributeValueUnsanitized,
        'update_attribute': _UpdateAttributeValueUnsanitized,
        'delete_attribute': _DeleteAttribute}


class _AttributeName:

    def __init__(self, gist, s):
        self.name_gist = gist
        self.name_string = s


# == whiners

def _express_collisions(collisions, listener):
    """
    `collisions` is a dictionary whose keys are gists and whose values are
    lists of attribute names. assume at least one of these lists is longer
    than one.

    there's two kinds of collision: surface form collision and gist collision.
    it's axiomatic that two identical surface names will have the same gist.

    as such, if you're looking for surface collisions you'll always find them
    under the same gist. (but there may be multiple sets of surface collison
    under any one gist!) whew..
    """

    more_than_one_count_via_surface_form = {}
    list_of_gist_and_surface_names = []

    for gist, ans in collisions.items():
        if 1 == len(ans):
            continue
        surface_name_count = {}
        for an in ans:
            sn = an.name_string  # surface name
            if sn in surface_name_count:
                surface_name_count[sn] += 1
            else:
                surface_name_count[sn] = 1

        surface_singletons = []
        for sn, count in surface_name_count.items():
            if 1 == count:
                surface_singletons.append(sn)
            else:
                more_than_one_count_via_surface_form[sn] = count

        if len(surface_singletons):
            list_of_gist_and_surface_names.append((gist, surface_singletons))

    has_SF_collision = len(more_than_one_count_via_surface_form)
    has_gist_collision = len(list_of_gist_and_surface_names)

    assert(has_SF_collision or has_gist_collision)

    # (in practice we don't expect these phrase structures to get very
    #  complex, otherwise we would do something more sane/ornate here.)

    and_join = []

    # --
    if has_SF_collision:
        and_join.append(  # (Case4217)
                'an attribute name cannot appear more than once per request')
    for sn, count in more_than_one_count_via_surface_form.items():
        _N_times = 'twice' if 2 == count else f'{count} times'
        and_join.append(f'{repr(sn)} appeared {_N_times}')
    # --

    # --
    for gist, sns in list_of_gist_and_surface_names:
        _ = _oxford_AND(repr(x) for x in sns)  # (Case4218)
        and_join.append(
                f'{_} are too similar to co-exist validly in one request')
    # --

    _reason = ' and '.join(and_join)
    _emit_request_error_via_reason(_reason, listener)


def _sentence_phrases_for_missings(verb, tups):

    inexacts = []
    sns = []

    for cmpo, blk in tups:
        sn = cmpo.attribute_name.name_string
        if blk is None:
            sns.append(sn)
        else:
            _exi_sn = blk.attribute_name_string
            _sp = f'use {repr(_exi_sn)} not {repr(sn)}'
            inexacts.append(_sp)

    sp_a = []

    if len(inexacts):
        _ = f"can't {verb} attributes because names must match exactly"
        sp_a.append(_)
        sp_a += inexacts

    if len(sns):
        if 1 == len(sns):
            mid = repr(sns[0])
        else:
            _ = ', '.join(sns)  # no quotes here just because
            mid = f"({_})"
        sp_a.append(f"can't {verb} because {mid} not found in entity")

    return sp_a


def _emit_request_error_via_reason(msg, listener):
    def structure():
        return {'reason': msg}
    listener('error', 'structure', 'request_error', structure)


def _oxford_AND(itr):
    import kiss_rdb.magnetics.via_collection as ox
    return ox.oxford_AND(itr)


# --

_not_ok = False
_okay = True

# #born.
