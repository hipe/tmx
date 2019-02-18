def apply_CUD_attributes_request_to_MDE___(mde, req, listener):

    # (long explanation extracted into [#865] "in-depth code explanation")

    # qits = "Qualified Items", a tail-anchored excerpt list

    if not __check_for_necessary_presence_or_absence(mde, req, listener):
        return

    problems = []

    # --
    cud = ('create', 'update', 'delete')
    by_verb = {k: [] for k in cud}
    for cmpo in req.components:
        by_verb[cmpo.lowercase_verb_string].append(cmpo)
    creates, updates, deletes = (by_verb[verb] for verb in cud)
    has_creates = len(creates)
    has_updates = len(updates)
    has_deletes = len(deletes)
    # --

    checker = __U_and_D_comment_proximity_checkerer(problems, mde, listener)

    # -- DELETEs first

    if has_deletes:
        check = checker()
        if not check:
            return
        for delete in deletes:
            if not check(delete):
                return
        if len(problems):
            _emit_comment_proximity_problems(problems, listener)  # (Case239)
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
            _emit_comment_proximity_problems(problems, listener)  # (Case261)
            return

    # -- CREATEs at end

    if has_creates:
        tup = __crazy_create_validation_and_preparation(mde, creates, listener)
        if tup is None:
            return
        i, groups, apnds, qits = tup
    elif has_updates:  # ick/meh
        i, groups, apnds, qits = (None, (), (), None)  # (Case352)

    if has_creates or has_updates:
        if not __apply_C_and_U(i, mde, groups, apnds, qits, updates, listener):
            return

    return _okay  # whenever failure happened, we short circuited (Case404)


# == CRAZY INSERTION (CREATE) ALGORITHM

def __crazy_create_validation_and_preparation(mde, creates, listener):

    qits = __longest_tail_anchored_run_of_line_objects_with_attrs_in_order(mde)

    groups, appends = __determine_insertion_groupings(qits, creates)

    i = __head_OK_excerpt_index(qits, mde)

    if not __check_comment_proximity_for_inserts(i, groups, qits, listener):
        return

    return (i, groups, appends, qits)


def __check_comment_proximity_for_inserts(hed_ok_i, groups, qits, listener):
    """checking for comment proximity of inserts has very different "ground

    conditions" than that of the others (done #here1).

    each insertion group is defined in terms of an existing attribute line
    to insert above. as such there is never a need to check that the
    insertion will touch a comment line below. however it's always necessary
    to check for such a touch above.

    for the appends, we don't need to check for comment line proximity
    *as a validation* provided we do the trick #here2.
    """

    problems = []

    def check(qits_i, inserts):
        if qits[qits_i - 1].line_object.is_comment_line and hed_ok_i != qits_i:
            problems.append((inserts[0], (True, False, False)))  # as #here3

    itr = iter(groups)

    for qits_i, inserts in itr:
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
    else:
        return _okay


def __head_OK_excerpt_index(qits, mde):
    """if the excerpt (always tail-anchored) is also head-anchored and has

    head-anchored comment lines (ergo so does the document entity body),
    then we can overcome the comment line proximity problem with the same
    trick we use #here2 :#here4
    """

    head_iid = mde._LL.head_IID()
    if head_iid is None:
        return  # empty document entity

    # somehow we know that a non-empty mde implies a non-empty excerpt

    # is the first item of the excerpt also the first item of the mde?
    if head_iid != qits[0].IID:
        return

    # is the first item (of both) a comment line?
    if not qits[0].line_object.is_comment_line:
        return

    # is there an attribute line in affnity with these comment lines?
    idx = None
    for i in range(1, len(qits)):
        lo = qits[i].line_object
        if lo.is_comment_line:
            continue
        if lo.is_attribute_line:
            idx = i
        break

    return idx


def __determine_insertion_groupings(qits, creates):
    """you have a list of *one* or more CREATE request components and *zero*

    or more line objects constituting a tail-anchored excerpt of the
    existing document entity.

    the tail-anchored excerpt is (as touched on in [#866]) the longest run of
    document lines anchored to the end of the document entity that have
    their attribute lines going in order with respect to each other, and
    include any interceding or bordering runs of comment/whitespace ("c/ws")
    lines; i.e the matching of c/ws lines is "greedy" in both directions.

    for "normal" cases we find the one or more "insertion points" in the list
    of *lines* into each of we insert a "group" of insertion requests; such
    that in the final would-be modified lines of the excerpt, the attribute
    lines are still in order and our comments provision is observed.

    you are solving for not only the insertion points but groupings.

    we attempt something similar "interleaving" algorithm described in [#407].
    """

    i_a = tuple(i for i in range(0, len(qits)) if qits[i].line_object.is_attribute_line)  # noqa: E501

    o_a = sorted(creates, key=lambda o: o.attribute_name.name_string)

    if not len(i_a):
        # when there are no attributes in the entity, just append (Case466)
        return ((), tuple(o_a))  # no groups, all appends

    doc_scn = _Scanner(i_a)
    req_scn = _Scanner(o_a)

    def current_req_s():
        return req_scn.value.attribute_name.name_string

    def current_doc_s():
        return qits[doc_scn.value].line_object.attribute_name.name_string

    groups = []  # list of tuples of (qits offset, insertion requests)
    group = []
    appends = ()

    def add_to_group():
        group.append(req_scn.value)
        req_scn.advance()

    def roll_over_line_and_maybe_group():
        if len(group):
            swallow_group()
        doc_scn.advance()

    def swallow_group():
        groups.append((doc_scn.value, tuple(group)))
        group.clear()

    doc_s = current_doc_s()
    req_s = current_req_s()

    while True:

        if req_s < doc_s:
            add_to_group()
            if req_scn.eos:
                if len(group):
                    swallow_group()
                break
            req_s = current_req_s()
            continue

        assert(doc_s < req_s)

        roll_over_line_and_maybe_group()
        if doc_scn.eos:
            # when you reach the end of the excerpt & you still have inserts
            # (CREATEs) to make, this is where appends come from. (Case404)

            a = [req_scn.value]
            req_scn.advance()
            while not req_scn.eos:
                a.append(req_scn.value)
                req_scn.advance()
            appends = tuple(a)
            break

        doc_s = current_doc_s()

    return (groups, appends)


def __longest_tail_anchored_run_of_line_objects_with_attrs_in_order(mde):

    # (we originally wrote this w/ list comprehensions but, reasons)

    cache = []

    def add_to_cache(iid, lo):  # lo = line object
        cache.append(_QualifiedItem(iid, lo))

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
            lo = item_via_IID(iid)
            if lo.is_attribute_line:
                yield iid
            else:
                add_to_cache(iid, lo)  # BE CAREFUL

    # -- with the iterator above

    def identifier_string_of(lo):
        return lo.attribute_name.name_string

    itr = IIDs_of_attribute_lines_in_reverse()

    for iid in itr:  # IF THERE'S AT LEAST ONE attribute line
        lo = item_via_IID(iid)
        add_to_cache(iid, lo)  # any MDE with at least one attr, yes
        prev = identifier_string_of(lo)  # establish what to compare others to
        break

    for iid in itr:  # IF THERE'S MORE THAN ONE attr line,
        lo = item_via_IID(iid)
        curr = identifier_string_of(lo)
        if prev < curr:
            break  # NOTE you didn't cache the out-of-order item
        add_to_cache(iid, lo)
        prev = curr  # now, use this new string to make the next compare

    return tuple(reversed(cache))  # or as needed


class _QualifiedItem:
    def __init__(self, iid, line_object):
        self.IID = iid  # IID = internal identifier (for linked lists)
        self.line_object = line_object


# == CHECK FOR COMMENT LINES ABOVE, ON, AND BELOW

def __U_and_D_comment_proximity_checkerer(problems, mde, listener):

    from .entity_via_identifier_and_file_lines import (
            COMMENT_TESTER_VIA_MDE as comment_tester_via)

    def checker():
        two_for_has_comment_via = comment_tester_via(mde, listener)
        if two_for_has_comment_via is None:
            return
        offset_via_gist, line_objects = __build_line_number_index(mde)
        lowest_offset = len(line_objects) - 1

        def check(cmpo):  # :#here1
            is_comment_above = False
            is_comment_on_line = False
            is_comment_below = False

            attr_name = cmpo.attribute_name
            gist = attr_name.name_gist
            line_offset = offset_via_gist[gist]

            # is there a comment above?
            if line_offset:
                if line_objects[line_offset - 1].is_comment_line:
                    is_comment_above = True

            # is there a comment below?
            if line_offset != lowest_offset:
                if line_objects[line_offset + 1].is_comment_line:
                    is_comment_below = True

            # does this line contain a comment? (Case239).

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


def __build_line_number_index(mde):
    line_objects = []
    offset_via_gist = {}

    for lo in mde.TO_BODY_LINE_OBJECT_STREAM():
        if lo.is_attribute_line:
            gist = lo.attribute_name.name_gist
            offset_via_gist[gist] = len(line_objects)
        line_objects.append(lo)

    return (offset_via_gist, line_objects)


def _emit_comment_proximity_problems(problems, listener):
    from . import state_machine_via_definition as en
    sp_a = []
    for cmpo, (above, on, below) in problems:
        bc_join = []
        if above or below:
            and_join = []
            if above:
                and_join.append('above')
            if below:
                and_join.append('below')
            _ = en.oxford_AND(and_join)
            bc_join.append(f'line touches comment line {_}')
        if on:
            bc_join.append('it has comment')

        _ = en.oxford_join(bc_join, ' and because ')

        _ = (f'cannot {cmpo.lowercase_verb_string} '
             f'{repr(cmpo.attribute_name.name_string)} '
             f'attribute line because {_}')
        sp_a.append(_)
    _emit_request_error_via_reason('. '.join(sp_a), listener)


# == CHECK FOR NECESSARY PRESENCE OR ABSENCE

def __check_for_necessary_presence_or_absence(mde, req, listener):

    def add_problem(typ, cmpo, al=None):
        problems.append((typ, cmpo, al))

    problems = []

    for cmpo in req.components:
        an = cmpo.attribute_name
        al = mde.any_attribute_line_via_gist(an.name_gist)
        if cmpo.attribute_must_already_exist_in_entity:

            # it must already exist in entity..

            if al is None:  # .. but no such attr by gist
                add_problem('missing', cmpo)  # (Case148)
            else:
                # .. and is found by gist

                surface_requested_name = an.name_string
                surface_existent_name = al.attribute_name.name_string

                if surface_requested_name == surface_existent_name:
                    pass  # win! maybe you can UPDATE/DELETE this (Case239)
                else:
                    add_problem('missing', cmpo, al)
        elif al is None:
            # it must not already exist in entity and was not found by gist
            pass  # win! maybe you can CREATE this component (Case420)
        else:
            # it must not already exist in entity but was found by gist
            add_problem('collision', cmpo, al)  # (Case125)

    if len(problems):
        __complain_about_presence_problems(problems, listener)
        return _not_ok
    else:
        return _okay


def __complain_about_presence_problems(problems, listener):
    """each problem is ('collision'|'missing', cmpo [,al])"""

    via_verb = {}

    for colli_or_miss, cmpo, al in problems:
        verb = cmpo.lowercase_verb_string
        if verb in via_verb:
            a = via_verb[verb][1]
        else:
            a = []
            via_verb[verb] = (cmpo.__class__, colli_or_miss, a)

        a.append((cmpo, al))  # include al as none for (Case170)

    long_sp_a = []
    for verb, (cls, colli_or_miss, arg_a) in via_verb.items():

        _ = _function_name_via_presence_problem_type[colli_or_miss]
        sp_a = getattr(cls, _)(arg_a)

        long_sp_a += sp_a

    _long_reason = '. '.join(long_sp_a)
    _emit_request_error_via_reason(_long_reason, listener)


_function_name_via_presence_problem_type = {
        'collision': 'sentence_phrases_for_collisions',
        'missing': 'sentence_phrases_for_missings',
        }


# == APPLYs/FLUSHes


def __apply_C_and_U(head_ok_i, mde, groups, appends, qits, updates, listener):
    """each insertion group is defined in terms of an existing line object

    to insert before and a list of UNSANITIZED insertion requests. because
    doubly linked list and we're using internal identifiers, we can make the
    insertions in head-to-tail order without screwing up what the internal
    identifiers mean.

    (there is some "penalty" for long insertion groups because rewiring, meh.)

    appends are what they sound like (and penalty same, meh). but also
    """

    yikes = __make_new_lines(updates, groups, appends, listener)

    def new_attr(compo):
        return yikes[compo.attribute_name.name_string]

    for qits_i, inserts in groups:

        iid = qits[qits_i].IID

        if head_ok_i == qits_i:  # finish #here4 (Case443)
            # don't insert before the attribute line, insert before
            # the top comment (which must be the top of the world item)

            iid = mde.insert_line_object(_blank_line(), qits[0].IID)

        # within each insertion group we *do* have to do the insertions in
        # reverse order b.c insertions are expressed in ref to item after

        for insert in reversed(inserts):
            iid = mde.insert_line_object(new_attr(insert), iid)

    # if the group of appends touches a comment line (so, a tail-anchored one)
    # we can do a trick only available for {head|tail}-anchored comment lines
    # which is insert a blank line to avoid unintended association. :#here2
    # (only at head an tail do you know that your comment-line-touching
    # insertion does not break an association.)

    if len(appends) and len(qits) and qits[-1].line_object.is_comment_line:
        mde.append_line_object(_blank_line())  # (Case404)

    for append in appends:
        mde.append_line_object(new_attr(append))  # (Case404)

    for update in updates:
        mde.replace_line_object__(new_attr(update))  # (Case352)

    return _okay


def __make_new_lines(updates, groups, appends, listener):
    """use real life vendor toml library to "encode" .."""

    from .entity_via_open_table_line_and_body_lines import attribute_line_via_line  # noqa: E501
    import toml

    yikes = {}
    for update in updates:
        yikes[update.attribute_name.name_string] = update.unsanitized_value
    for _, compos in groups:
        for compo in compos:
            yikes[compo.attribute_name.name_string] = compo.unsanitized_value
    for append in appends:
        yikes[append.attribute_name.name_string] = append.unsanitized_value

    big_s = toml.dumps(yikes)  # ..

    res = {}
    for line in _lines_via_big_string(big_s):
        al = attribute_line_via_line(line, listener)
        if al is None:
            raise Exception("cover me - value couldn't be encoded?")
        res[al.attribute_name.name_string] = al
    return res


def _lines_via_big_string(big_s):  # ..
    pos = 0
    stop_here = len(big_s)
    while True:
        i = big_s.find('\n', pos)
        next_pos = i + 1
        yield big_s[pos:next_pos]
        if stop_here == next_pos:
            break
        pos = next_pos


def __flush_deletes(mde, deletes):
    for delete in deletes:
        _gist = delete.attribute_name.name_gist
        mde.delete_attribute_line_object_via_gist__(_gist)


# == SUPPORT


class _Scanner():
    """
    a … scanner. like an iterator but more low-level & empty-friendly

        scn = _Scanner(('a', 'b', 'c'))
        while not scn.eos:
            yield o.value
            o.advance()
        # (this yields 'a', 'b', and 'c'.)
    """

    def __init__(self, a):
        position = -1
        final_position = len(a) - 1
        self.eos = False
        self.value = None

        def advance():
            nonlocal position
            if final_position == position:
                del(self.advance)
                del(self.value)
                self.eos = True
            else:
                position += 1
                self.value = a[position]
        self.advance = advance
        advance()


def _emit_request_error_via_reason(msg, listener):
    def structure():
        return {'reason': msg}
    listener('error', 'structure', 'request_error', structure)


def _blank_line():
    from .entity_via_open_table_line_and_body_lines import newline_line_object_singleton as _  # noqa: E501
    return _


_not_ok = False
_okay = True

# #born.
