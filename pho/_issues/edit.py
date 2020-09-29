import re


def open_issue(readme, dct, listener, opn=None):

    tup = _provision_identifier(readme, listener, opn)
    if tup is None:
        return
    typ, iden, read_fh, schema, ci = tup  # #here1

    # This algorithm is necessarily two-pass: you have to traverse the whole
    # collection once to provision the identifier (you don't know what it will
    # be until you've reached the end); and then you have to traverse all the
    # lines of the file again to rewrite it (while doing an update or create).

    # (Side note this is why is "eno" collections we keep an index of ID's.)

    # If we hated the idea of parsing the whole file twice we would cache all
    # the line sexps in to memory; but A) we don't, B) we would have to
    # overstuff the already bursting core module of our storage adapter to
    # accomodate constructing a collection from a tuple of pre-parsed sexps
    # (we have already hacked it to do the following stunt), and C) parsing
    # the file again (in two redundant passes) is more memory efficient and
    # and "scalable" (lol) to unimaginably, impractically huge collections.

    # However, opening and closing the same file twice in one operation is
    # a bridge too far for us. So:

    read_fh.seek(0)

    # Validate the keys of the create or update dict
    iden_key, *allowed_keys = schema.field_name_keys  # assume [#871.1]
    extra_keys = set(dct.keys()) - set(allowed_keys)
    if extra_keys:
        xx(f"strange key(s): {extra_keys!r}")

    # Validate content
    ok = _validate_content(dct, allowed_keys, listener)
    if not ok:
        read_fh.close()  # YUCK
        return

    # Either create or update
    do_create = ('tagged_hole', 'major_hole', 'minor_hole').index(typ)
    if do_create:
        use_dct = {k: v for k, v in dct.items()}
        use_dct[iden_key] = iden.to_string()  # reparse it again ick/meh
        x = ci.create_entity_as_storage_adapter_collection(use_dct, listener)
        t = (None, x) if x else x
    else:
        use_dct = {k: '' for k in allowed_keys}
        use_dct.update(dct)
        edt = tuple(('update_attribute', k, v) for k, v in use_dct.items())
        t = ci.update_entity_as_storage_adapter_collection(iden, edt, listener)

    read_fh.close()
    return t


def _validate_content(dct, allowed_keys, listener):
    errs = []
    for k in allowed_keys:
        s = dct.get(k)
        if s is None:
            continue
        if 41 < len(s):
            errs.append((k, 'is too long (max 41 chars)'))
            continue
        # regex? or no
    if not errs:
        return True

    def lineser():
        for k, predicate in errs:
            use = k.replace('_', '_')
            yield f"'{use}' {predicate}"
    listener('error', 'expression', 'cell_content_error', lineser)


def _provision_identifier(readme, listener, opn):  # #testpoint

    def main():
        typ, iden = traverse_whole_collection()

        if 'last_iden_tagged_as_hole' == typ:
            return 'tagged_hole', iden

        if 'last_iden_with_real_major_hole_above_it' == typ:
            new_iden = _increment_identifier(iden, 'major')  # (Case3880)
            return 'major_hole', new_iden

        if 'last_iden_with_real_minor_hole_above_it' == typ:
            new_iden = _increment_identifier(iden, 'minor')  # (Case3882)
            return 'minor_hole', new_iden

        if 'empty_collection' == typ:
            msg = ("Can't provision identifier for an empty collection. "
                   "Need begin point (lowest issue) and end point (example).")
            listener('error', 'expression', 'empty_collection', lambda: (msg,))
            return

        assert 'out_of_space' == typ
        msg = ("Out of space. No holes between " +
               (' and '.join(o.to_string() for o in (iden, eg_iden))))
        listener('error', 'expression', 'out_of_space', lambda: (msg,))

    def traverse_whole_collection():
        last_iden_tagged_as_hole = None
        last_iden_with_real_major_hole_above_it = None
        last_iden_with_real_minor_hole_above_it = None
        above_iden, branch, ent = eg_iden, False, None
        for ent in ents:
            iden = ent.identifier
            if tagged_as_hole(ent):
                last_iden_tagged_as_hole = iden
            was_under_branch = branch
            jump_distance, branch = compare(above_iden, iden, branch)
            above_iden = iden
            assert -1 < jump_distance
            if 0 == jump_distance:
                # The header node at the bottom of a bunch of compound issues
                assert was_under_branch and not branch
            elif 1 == jump_distance:
                pass  # normal tight lyfe
            else:
                assert 0 < jump_distance
                # simple to simple (so was not): major hole
                # compound to compound (so was): minor hole
                # simple to compound (so was not): major hole
                # compound to simple (so was): major hole
                if was_under_branch and branch:
                    last_iden_with_real_minor_hole_above_it = iden
                else:
                    last_iden_with_real_major_hole_above_it = iden

        if (iden := last_iden_tagged_as_hole):
            return 'last_iden_tagged_as_hole', iden
        if (iden := last_iden_with_real_major_hole_above_it):
            return 'last_iden_with_real_major_hole_above_it', iden
        if (iden := last_iden_with_real_minor_hole_above_it):
            return 'last_iden_with_real_minor_hole_above_it', iden
        if ent:
            return 'out_of_space', ent.identifier
        return 'empty_collection', None

    def tagged_as_hole(ent):
        s = ent.core_attributes_dictionary_as_storage_adapter_entity.\
            get(main_tag_key)
        if s is None:
            return
        return rx.match(s)

    rx = re.compile(r'(?:^| )#hole\b')

    def compare(above_iden, iden, is_under_branch):
        if is_under_branch:
            if iden.has_sub_component:
                jump_distance = minor_dist(above_iden, iden)
            else:
                jump_distance = major_dist(above_iden, iden)
                is_under_branch = False
        elif iden.has_sub_component:
            jump_distance = major_dist(above_iden, iden)
            is_under_branch = True
        else:
            jump_distance = major_dist(above_iden, iden)
        return jump_distance, is_under_branch

    def major_dist(above_iden, iden):
        return above_iden.major_integer - iden.major_integer

    def minor_dist(above_iden, iden):
        return above_iden.minor_integer - iden.minor_integer

    class stop(RuntimeError):
        pass

    whine = _md_table_lib().whine_about_file_not_found_
    read_fh = None
    try:
        read_fh = (opn or open)(readme, 'r')
        # the 'r' (although default (?)) is necessary for magic
    except FileNotFoundError as e:
        fnf_err = e
    if read_fh is None:
        whine(listener, fnf_err)
        return

    stopping_listener = _build_throwing_listener(stop, listener)

    try:
        ci = _coll_impl_via(read_fh, stopping_listener, opn)
        itr = _schema_then_entities(ci, stopping_listener)
        cs = next(itr)[2]
        assert 'main_tag' == cs.field_name_keys[1]  # or w/e
        main_tag_key = 'main_tag'
        ents = (sx[1] for sx in itr)
        end_iden = (eg_iden := next(ents).identifier)
        assert not end_iden.has_sub_component
        res_tup = main()
        if res_tup is None:
            read_fh.close()
            return
        return (*res_tup, read_fh, cs, ci)  # #here1
    except stop:
        read_fh.close()
    except AssertionError as e:
        read_fh.close()
        raise e


def _increment_identifier(iden, maj_or_min):
    use_maj, use_minor = iden.major_integer, None

    if 'minor' == maj_or_min:
        use_minor = (False, (iden.minor_integer + 1))  # ick, meh
    else:
        assert 'major' == maj_or_min
        use_maj += 1

    b = iden.include_bracket
    return iden.__class__(use_maj, tail_tuple=use_minor, include_bracket=b)


def close_issue(readme, eid, listener, opn=None):
    def main():
        iden = parse_identifier()
        ci = _coll_impl_via(readme, listener, opn)
        edit = (('update_attribute', 'main_tag', '#hole'),
                ('update_attribute', 'content', ''))
        two = ci.update_entity_as_storage_adapter_collection(
            iden, edit, throwing_listener)
        if two is None:
            return
        before, after = two

        def lines():
            yield f"BEFORE: {before.to_line()}"
            yield f"AFTER:  {after.to_line()}"
        listener('info', 'expression', 'closed_issue', lines)

    def parse_identifier():
        # Give eid's w/o leading '[', '#' a '#' so we can use cust iden class
        use_eid = f"#{eid}" if re.match(r'^(?!=\[|#)', eid) else eid
        from . import build_identifier_parser_ as func
        return func(throwing_listener)(use_eid)

    class stop(RuntimeError):
        pass

    throwing_listener = _build_throwing_listener(stop, listener)

    try:
        main()  # no result except emissions!
    except stop:
        pass


def _schema_then_entities(ci, throwing_listener):
    astack = [
        ('end_of_file', lambda o: o.turn_yield_off()),
        ('table_schema_line_ONE_of_two',),
        ('other_line', lambda o: o.turn_yield_off()),
        ('business_row_AST',),
        ('table_schema_line_TWO_of_two', lambda o: o.turn_yield_on()),
        ('table_schema_line_ONE_of_two',),
        ('head_line',),
        ('beginning_of_file',)]
    return ci.sexps_via_action_stack(astack, throwing_listener)


def _build_throwing_listener(stop, listener):
    def throwing_listener(sev, *rest):
        listener(sev, *rest)
        if 'error' == sev:
            raise stop()
    return throwing_listener


# == Delegations & Hops

def _coll_impl_via(readme, listener, opn):
    from . import coll_impl_via_ as func
    return func(readme, listener, opn)


def _md_table_lib():
    import kiss_rdb.storage_adapters_.markdown_table as module
    return module


# == Smalls

def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))

# #born
