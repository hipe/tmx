from modality_agnostic import lazy


def apply_CUD_attributes_request_to_MDE___(mde, req, eenc, listener, C_or_U):

    # this is the counterpart to [#865] "Implementing our comment policy".

    # eenc = entity encoder
    # qits = "Qualified Items", a tail-anchored excerpt list

    if not __check_for_necessary_presence_or_absence(mde, req, C_or_U, listener):  # noqa: E501
        return

    problems = []

    # --
    cud = ('create_attribute', 'update_attribute', 'delete_attribute')
    by_verb = {k: [] for k in cud}
    for cmpo in req.components:
        by_verb[cmpo.edit_component_key].append(cmpo)
    creates, updates, deletes = (by_verb[verb] for verb in cud)
    has_creates = len(creates)
    has_updates = len(updates)
    has_deletes = len(deletes)
    # --

    if 'create_attribute' == C_or_U:
        created_or_updated = 'created'
        mutate_orig = True
    else:
        assert('update_attribute' == C_or_U)
        mde = mde.BUILD_MUTABLE_COPY__()  # lose access to orginal here
        created_or_updated = 'updated'
        mutate_orig = False

    checker = __U_and_D_comment_proximity_checkerer(problems, mde, listener)

    # (interesting: order is UCD elsewhere for reasons, but DUC here)

    # -- DELETEs first

    if has_deletes:
        check = checker()
        if not check:
            return
        for delete in deletes:
            if not check(delete):
                return
        if len(problems):
            _emit_comment_proximity_problems(problems, listener)  # (Case4226)
            return
        __flush_deletes(mde, deletes)

    # -- UPDATEs in middle

    if has_updates:
        check = checker()
        if not check:
            return
        for update in updates:
            if not check(update):
                return
        if len(problems):
            _emit_comment_proximity_problems(problems, listener)  # (Case4227)
            return

    # -- CREATEs at end

    if has_creates:
        tup = __crazy_create_validation_and_preparation(mde, creates, listener)
        if tup is None:
            return
        i, groups, apnds, qits = tup
    elif has_updates:  # ick/meh
        i, groups, apnds, qits = (None, (), (), None)  # (Case4232)

    if has_creates or has_updates:
        if not __apply_C_and_U(
                i, mde, groups, apnds, qits, updates, eenc, listener):
            return

    # Any failure should have short-circuited out by now.
    # At this point, success is guaranteed (Case4234).

    _UCDs = (updates, creates, deletes)
    from kiss_rdb.magnetics_.CUD_attributes_request_via_tuples \
        import emit_edited_ as func
    eid = mde.identifier.to_string()
    func(listener, _UCDs, eid, created_or_updated)

    if mutate_orig:
        return True
    else:
        return mde


# == CRAZY INSERTION (CREATE) ALGORITHM

def __crazy_create_validation_and_preparation(mde, creates, listener):

    qits = __longest_tail_anchored_run_of_attribute_body_blocks_in_order(mde)

    groups, appends = __determine_insertion_groupings(qits, creates)

    i = __head_OK_excerpt_index(qits, mde)

    if not __check_comment_proximity_for_inserts(i, groups, qits, listener):
        return

    return (i, groups, appends, qits)


def __check_comment_proximity_for_inserts(hed_ok_i, groups, qits, listener):
    """checking for comment proximity of inserts has very different "ground

    conditions" than that of the others (done #here1).

    each insertion group is defined in terms of an existing attribute block
    to insert above. as such there is never a need to check that the
    insertion will touch a comment line below. however it's always necessary
    to check for such a touch above.

    for the appends, we don't need to check for comment line proximity
    *as a validation* provided we do the trick #here2.
    """

    problems = []

    # qit = qualified item

    def check(qits_i, inserts):
        assert(qits_i)
        blk_above = qits[qits_i - 1].body_block
        if not blk_above.is_discretionary_block:
            assert(blk_above).is_attribute_block
            return

        if hed_ok_i == qits_i:  # #here4
            return

        if not _is_comment_line(blk_above.discretionary_block_lines[-1]):
            return

        # (Case4230)
        problems.append((inserts[0], (True, False, False)))  # as #here3

    itr = iter(groups)

    for qits_i, inserts in itr:  # #once
        # the TL;DR: is "don't look for the element before the first element".
        # detail: when making the excerpt (upwards) we consumed comment lines
        # greedily (see "greedy"). so it's not possible for an excerpt line
        # to be at offset zero in the excerpt list and also have comments
        # above it (because they would have been consumed and the topmost
        # contiguous such comment would be at zero instead.)

        if 0 != qits_i:
            check(qits_i, inserts)
        break

    for qits_i, inserts in itr:
        check(qits_i, inserts)

    if len(problems):
        _emit_comment_proximity_problems(problems, listener)
        return _not_ok

    return _okay


def __head_OK_excerpt_index(qits, mde):
    """if the excerpt (always tail-anchored) is also head-anchored and has

    head-anchored comment lines (ergo so does the document entity body),
    then we can overcome the comment line proximity problem with the same
    trick we use #here2 :#here4
    """

    # qit = qualified item

    head_iid = mde._LL.head_IID()
    if head_iid is None:
        return  # empty document entity

    # somehow we know that a non-empty mde implies a non-empty excerpt

    first_qitem = qits[0]

    # is the first item of the excerpt also the first item of the mde?
    if head_iid != first_qitem.IID:
        return

    # is the first item (of both) a comment line?

    is_comment = False
    if first_qitem.body_block.is_discretionary_block:
        _first_line = first_qitem.body_block.discretionary_block_lines[0]
        is_comment = _is_comment_line(_first_line)

    if not is_comment:
        return

    # find the any offset of the first block that is an attribute block (why?)
    offset = None
    for i in range(1, len(qits)):
        blk = qits[i].body_block
        if blk.is_discretionary_block:
            continue
        assert(blk.is_attribute_block)
        offset = i
        break

    return offset


def __determine_insertion_groupings(qits, creates):
    """you have a list of *one* or more CREATE request components and *zero*

    or more blocks constituting a tail-anchored excerpt of the
    existing document entity.

    as touched on in [#866], this "excerpt" is the longest tail-anchored run
    of the document entity's body blocks where the blocks that are attribute
    blocks have names in alphabetical order relative to each other.

    (the blocks that are not attribute blocks (so, discretionary blocks)
    are included greedily in this excerpt (so, both upwards and downwards).)

    into this excerpt we look for the one or more "insertion points" where
    we can insert a "group" of insertion requests; such that in the final
    would-be modified excerpt, the attribute blocks (new/old/modified all)
    are are still in order and our comments provision is observed.

    you are solving for not only the insertion points but groupings.

    we attempt something similar "interleaving" algorithm described in [#447].
    """

    # qits = qualified items

    i_a = tuple(i for i in range(0, len(qits)) if qits[i].body_block.is_attribute_block)  # noqa: E501

    o_a = sorted(creates, key=lambda o: o.attribute_name.name_string)

    if not len(i_a):
        # when there are no attributes in the entity, just append (Case4236)
        return ((), tuple(o_a))  # no groups, all appends

    doc_scn = _scanner_via_list(i_a)
    req_scn = _scanner_via_list(o_a)

    def current_req_s():
        return req_scn.peek.attribute_name.name_string

    def current_doc_s():
        return qits[doc_scn.peek].body_block.attribute_name_string

    groups = []  # list of tuples of (qits offset, insertion requests)
    group = []
    appends = ()

    def add_to_group():
        group.append(req_scn.next())

    def roll_over_line_and_maybe_group():
        if len(group):
            swallow_group()
        doc_scn.advance()

    def swallow_group():
        groups.append((doc_scn.peek, tuple(group)))
        group.clear()

    doc_s = current_doc_s()
    req_s = current_req_s()

    while True:

        if req_s < doc_s:
            add_to_group()
            if req_scn.empty:
                if len(group):
                    swallow_group()
                break
            req_s = current_req_s()
            continue

        assert(doc_s < req_s)

        roll_over_line_and_maybe_group()
        if doc_scn.empty:
            # when you reach the end of the excerpt & you still have inserts
            # (CREATEs) to make, this is where appends come from. (Case4234)

            a = [req_scn.next()]
            while req_scn.more:
                a.append(req_scn.next())
            appends = tuple(a)
            break

        doc_s = current_doc_s()

    return (groups, appends)


def __longest_tail_anchored_run_of_attribute_body_blocks_in_order(mde):

    # (we originally wrote this w/ list comprehensions but, reasons)

    cache = []

    def add_to_cache(iid, blk):  # blk = line object
        cache.append(_QualifiedItem(iid, blk))

    ll = mde._LL
    item_via_IID = ll.item_via_IID

    # -- iterator to traverse each IID from back to front

    def IIDs_in_reverse():
        iid = ll.tail_IID()
        while iid is not None:
            yield iid
            iid = ll.prev_IID_via_IID(iid)

    # -- alter the above iterator to yield only IIDs of attr lines AND..

    def IIDs_of_attribute_lines_in_reverse():
        for iid in IIDs_in_reverse():
            blk = item_via_IID(iid)
            if blk.is_attribute_block:
                yield iid
            else:
                add_to_cache(iid, blk)  # BE CAREFUL

    # -- with the iterator above

    def identifier_string_of(blk):
        return blk.attribute_name_string

    itr = IIDs_of_attribute_lines_in_reverse()

    # the MDE could have zero attribute blocks.
    # if it has at least one, add it to the list and note its name

    for iid in itr:  # #once
        blk = item_via_IID(iid)
        add_to_cache(iid, blk)  # any MDE with at least one attr, yes
        prev = identifier_string_of(blk)  # establish what to compare others to
        break

    for iid in itr:  # IF THERE'S MORE THAN ONE attr line,
        blk = item_via_IID(iid)
        curr = identifier_string_of(blk)
        if prev < curr:
            break  # NOTE you didn't cache the out-of-order item
        add_to_cache(iid, blk)
        prev = curr  # now, use this new string to make the next compare

    return tuple(reversed(cache))  # or as needed


class _QualifiedItem:
    def __init__(self, iid, body_block):
        self.IID = iid  # IID = internal identifier (for linked lists)
        self.body_block = body_block


# == CHECK FOR COMMENT LINES ABOVE, ON, AND BELOW

def __U_and_D_comment_proximity_checkerer(problems, mde, listener):

    @lazy
    def checker():

        from . import entity_via_identifier_and_file_lines as ent_lib

        body_blocks = tuple(mde.to_body_block_stream_as_MDE_())

        two_for_has_comment_via = ent_lib.comment_tester_via_body_blocks_(
                body_blocks, listener)
        if two_for_has_comment_via is None:
            return

        offset_via_gist = __build_offset_via_gist(body_blocks, listener)

        last_offset = len(body_blocks) - 1

        def check(cmpo):  # :#here1

            is_comment_above = False
            is_comment_on_line = False
            is_comment_below = False

            attr_name = cmpo.attribute_name
            gist = attr_name.name_gist
            body_block_offset = offset_via_gist[gist]

            # is there a comment above?
            if body_block_offset:
                if _last_line_is_comment(body_blocks[body_block_offset - 1]):
                    is_comment_above = True

            # is there a comment below?
            if body_block_offset != last_offset:
                if _first_line_is_comment(body_blocks[body_block_offset + 1]):
                    is_comment_below = True

            # does this line contain a comment? (Case4226).

            # NOTE bc gists are guaranteed unique per request, no need to cache
            ok, yes = two_for_has_comment_via(attr_name.name_string, listener)
            if not ok:
                return

            if yes:
                is_comment_on_line = yes  # hi.

            if is_comment_above or is_comment_on_line or is_comment_below:
                _3 = (is_comment_above, is_comment_on_line, is_comment_below)
                problems.append((cmpo, _3))  # :#here3

            return _okay
        return check
    return checker


def _last_line_is_comment(blk):
    if not blk.is_discretionary_block:
        return False
    return _is_comment_line(blk.discretionary_block_lines[-1])


def _first_line_is_comment(blk):
    if not blk.is_discretionary_block:
        return False
    return _is_comment_line(blk.discretionary_block_lines[0])


def _is_comment_line(line):
    return '#' == line[0]  # #[#867.F]


def __build_offset_via_gist(body_blocks, listener):

    # make this function
    gist_via_s = _blocks_lib().attribute_name_functions_().name_gist_via_name

    def gist_of(blk):
        return gist_via_s(blk.attribute_name_string, listener)

    # make this index
    _ = ((i, body_blocks[i]) for i in range(0, len(body_blocks)))
    return {gist_of(blk): i for (i, blk) in _ if blk.is_attribute_block}


def _emit_comment_proximity_problems(problems, listener):
    sp_a = []
    from text_lib.magnetics import via_words as ox
    for cmpo, (above, on, below) in problems:
        bc_join = []
        if above or below:
            and_join = []
            if above:
                and_join.append('above')
            if below:
                and_join.append('below')
            _ = ox.oxford_AND(iter(and_join))
            bc_join.append(f'line touches comment line {_}')
        if on:
            bc_join.append('it has comment')

        _ = ox.oxford_join(iter(bc_join), ' and because ')
        _verb_lexeme = _verb_lexeme_via_key[cmpo.edit_component_key]
        _ = (f'cannot {_verb_lexeme} '
             f'{repr(cmpo.attribute_name.name_string)} '
             f'attribute line because {_}')
        sp_a.append(_)

    _emit_request_error_via_reason('. '.join(sp_a), listener)


# == CHECK FOR NECESSARY PRESENCE OR ABSENCE

def __check_for_necessary_presence_or_absence(mde, req, C_or_U, listener):

    def add_problem(typ, cmpo, blk=None):
        problems.append((typ, cmpo, blk))

    problems = []

    for cmpo in req.components:
        an = cmpo.attribute_name
        blk = mde.any_block_via_gist__(an.name_gist)
        if cmpo.attribute_must_already_exist_in_entity:

            # it must already exist in entity..

            if blk is None:  # .. but no such attr by gist
                add_problem('missing', cmpo)  # (Case4221)
            else:
                # .. and is found by gist

                surface_requested_name = an.name_string
                surface_existent_name = blk.attribute_name_string

                if surface_requested_name == surface_existent_name:
                    pass  # win! maybe you can UPDATE/DELETE this (Case4226)
                else:
                    add_problem('missing', cmpo, blk)
        elif blk is None:
            # it must not already exist in entity and was not found by gist
            pass  # win! maybe you can CREATE this component (Case4230)
        else:
            # it must not already exist in entity but was found by gist
            add_problem('collision', cmpo, blk)  # (Case4077)

    if len(problems):
        def structurer():
            return __complain_about_presence_problems(problems, C_or_U)
        listener('error', 'structure', 'cannot_update', structurer)
        return _not_ok
    else:
        return _okay


def __complain_about_presence_problems(problems, C_or_U):
    """each problem is ('collision'|'missing', cmpo [,blk])"""

    via_verb = {}

    for colli_or_miss, cmpo, blk in problems:
        verb = cmpo.edit_component_key
        if verb in via_verb:
            a = via_verb[verb][1]
        else:
            a = []
            via_verb[verb] = (cmpo.__class__, colli_or_miss, a)
        a.append((cmpo, blk))  # include blk as none for (Case4220)

    long_sp_a = []
    for verb, (cls, colli_or_miss, arg_a) in via_verb.items():

        _ = _function_name_via_presence_problem_type[colli_or_miss]
        sp_a = getattr(cls, _)(arg_a)

        long_sp_a += sp_a

    _long_reason = '. '.join(long_sp_a)
    return {'reason': _long_reason}


_function_name_via_presence_problem_type = {
        'collision': 'sentence_phrases_for_collisions',
        'missing': 'sentence_phrases_for_missings',
        }


# == APPLYs/FLUSHes


def __apply_C_and_U(
        head_ok_i, mde, groups, appends, qits, updates, eenc, listener):

    """each insertion group is defined in terms of an existing attribute block

    to insert before and a list of UNSANITIZED insertion requests. because
    doubly linked list and we're using internal identifiers, we can make the
    insertions in head-to-tail order without screwing up what the internal
    identifiers mean.

    (there is some "penalty" for long insertion groups because rewiring, meh.)

    appends are what they sound like (and penalty same, meh). but also
    """

    blk_via = __make_new_blocks(updates, groups, appends, eenc, listener)
    if blk_via is None:
        return

    def new_attr(compo):
        return blk_via[compo.attribute_name.name_string]

    for qits_i, inserts in groups:

        iid = qits[qits_i].IID

        if head_ok_i == qits_i:
            # finish #here4 (Case4235)
            # don't insert before the attribute line, insert before
            # the top comment (which must be the top of the world item)

            iid = mde.insert_body_block(_blank_line(), qits[0].IID)

        # within each insertion group we *do* have to do the insertions in
        # reverse order b.c insertions are expressed in ref to item after

        for insert in reversed(inserts):
            iid = mde.insert_body_block(new_attr(insert), iid)

    # if the group of appends touches a comment line (so, a tail-anchored one)
    # we can do a trick only available for {head|tail}-anchored comment lines
    # which is insert a blank line to avoid unintended association. :#here2
    # (only at head an tail do you know that your comment-line-touching
    # insertion does not break an association.)

    if len(appends) and len(qits) and _first_line_is_comment(qits[-1].body_block):  # noqa: E501
        mde.append_body_block(_blank_line())  # (Case4234), (Case4134)

    for append in appends:
        mde.append_body_block(new_attr(append))  # (Case4234)

    for update in updates:
        mde.replace_attribute_block__(new_attr(update))  # (Case4232)

    return _okay


@lazy
def _blank_line():
    return _blocks_lib().AppendableDiscretionaryBlock_('\n')


def __make_new_blocks(updates, groups, appends, eenc, listener):
    """in order to "encode" the values, use the real life toml library..

    (Case4232)
    """

    # turn everything into two dictionaries,

    tup = __PLAN_VIA(updates, groups, appends, eenc)
    if not tup:
        return

    # ..one dictionary (right) of values we want the toml vendor lib to
    # encode for us directly, and one dict of semi-encoded attribute blocks

    semi_encoded_dct, vendor_lib_dct = tup

    # start by using the vendor lib to parse the one dict to get a big string
    # (remarkably, the empty case just works (Case4257):
    # empty dict -> empty big string -> no lines -> table_block w/ no childs)

    from toml import dumps as toml_dumps  # another #[#867.K]
    _big_s = toml_dumps(vendor_lib_dct)
    _lines = lines_via_big_string_(_big_s)

    # turn the big string into a parsed block

    from . import entities_via_collection as ents_lib
    table_block = ents_lib.table_block_via_lines_and_table_start_line_object_(
            lines=_lines,
            table_start_line_object=None,
            listener=listener)

    # if you have any semi-encoded values to add, add them woot

    for attr_s, semi_encoded_lines in semi_encoded_dct.items():
        # (Case4257)
        table_block.append_multi_line_attribute_block_via_lines__(
                attr_s, semi_encoded_lines)

    # turn the parsed block into

    return {o.attribute_name_string: o for o in table_block.to_body_block_stream_as_table_block_()}  # noqa: E501


def __PLAN_VIA(updates, groups, appends, eenc):

    semi_encoded_dct = {}
    vendor_lib_dct = {}

    def components_flattened():

        for update in updates:
            yield update

        for _, compos in groups:
            for compo in compos:
                yield compo

        for append in appends:
            yield append

    for compo in components_flattened():

        attr_name_s = compo.attribute_name.name_string
        mixed = compo.unsanitized_value

        tup = eenc.semi_encode(mixed, attr_name_s)
        if tup is None:
            return  # (Case4258KR)

        name_value_plan, o = tup

        if 'use vendor lib' == name_value_plan:
            vendor_lib_dct[attr_name_s] = mixed
        else:
            assert('semi-encoded string' == name_value_plan)

            semi_encoded_lines = o.semi_encoded_lines
            num_lines = len(semi_encoded_lines)

            assert(num_lines)  # (Case4258KR) empty string

            if 1 == num_lines:
                if o.has_special_characters:
                    # (Case4259) one line, special chars
                    vendor_lib_dct[attr_name_s] = mixed  # RE-ENCODE
                else:
                    # one line, no special chars (Case4234)
                    vendor_lib_dct[attr_name_s] = mixed  # RE-ENCODE
            elif o.has_special_characters:
                # (Case4260) multiple lines, special chars
                semi_encoded_dct[attr_name_s] = semi_encoded_lines
            else:
                # multiple lines, no special chars (Case4257)
                semi_encoded_dct[attr_name_s] = semi_encoded_lines

    return semi_encoded_dct, vendor_lib_dct


def __flush_deletes(mde, deletes):
    for delete in deletes:
        _gist = delete.attribute_name.name_gist
        mde.delete_attribute_body_block_via_gist__(_gist)


# == whiners

def _emit_request_error_via_reason(msg, listener):
    def structurer():
        return {'reason': msg}
    _emit_request_error(listener, structurer)


def _emit_request_error(listener, structurer):  # one of several
    listener('error', 'structure', 'request_error', structurer)


# ==

_verb_lexeme_via_key = {
        'update_attribute': 'update',
        'create_attribute': 'create',
        'delete_attribute': 'delete'}


def lines_via_big_string_(big_s):  # #[#610]
    import re
    return (md[0] for md in re.finditer('[^\n]*\n|[^\n]+', big_s))


def _scanner_via_list(tup):
    from text_lib.magnetics.scanner_via import scanner_via_list as func
    return func(tup)


def _blocks_lib():
    from . import blocks_via_file_lines as blk_lib
    return blk_lib


_not_ok = False
_okay = True

# #history-A.1
# #born.
