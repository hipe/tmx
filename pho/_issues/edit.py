import re as _re


def open_issue(readme, dct, listener, be_verbose=False, opn=None):
    opened = _open_file(readme, 'r+', opn, listener)  # #here2
    if opened is None:
        return
    with opened as fh:
        tup = _provision_identifier(opn, fh, listener)
        if tup is None:
            return

        def lines_for_verbose():
            # (when someting doesn't work right, turning verbose on can help)
            yield f'means: {typ}'
            yield f'identifier: {iden.to_string()}'
            x = ic.collection.MIXED_COLLECTION_IDENTIFIER  # [#882.G]
            if hasattr(x, 'name'):
                x = x.name
            yield f'collection identifier: {x}'
            yield f'schema field names: {schema.field_name_keys!r}'

        typ, iden, schema, ic = tup  # #here1
        listener('verbose', 'expression', lines_for_verbose)
        return _do_open_issue(fh, typ, iden, schema, ic, dct, listener)


def _do_open_issue(fh, typ, iden, schema, ic, dct, listener):

    coll = ic.collection

    # This algorithm is necessarily two-pass: you have to traverse the whole
    # collection once to provision the identifier (you don't know what it will
    # be until you've reached the end); and then you have to traverse all the
    # lines of the file again to rewrite it (while doing an update or create).

    # (Side note, this is why in "eno" collections we keep an index file of
    # allocated ID's so we don't have to traverse the whole coll to provision.)

    # If we hated the idea of parsing the whole file twice we would cache all
    # the line sexps in to memory; but A) we don't, B) we would have to
    # overstuff the already bursting core module of our storage adapter to
    # accomodate constructing a collection from a tuple of pre-parsed sexps
    # (we have already hacked it to do the following stunt), and C) parsing
    # the file again (in two redundant passes) is more memory efficient and
    # and "scalable" (lol) to unimaginably, impractically huge collections.

    # However, opening and closing the same file twice in one operation is
    # a bridge too far for us. So:

    # fh.seek(0)  # #here3
    # ☝️ ACTUALLY [#873.26] vendor does this automatically now #history-B.4

    # Validate the keys of the create or update dict
    iden_key, *allowed_keys = schema.field_name_keys  # assume [#871.1]
    extra_keys = set(dct.keys()) - set(allowed_keys)
    if extra_keys:
        xx(f"key(s) in new ent not in MD table schema: {extra_keys!r}")

    # Validate content
    ok = _validate_content(dct, allowed_keys, listener)
    if not ok:
        return

    # Either create or update

    do_create = ('tagged_hole', 'major_hole', 'minor_hole').index(typ)
    if do_create:
        use_dct = {k: v for k, v in dct.items()}
        use_dct[iden_key] = iden.to_string()  # reparse it again ick/meh
        return coll.create_entity(use_dct, listener)

    # If the provision strategy was 'tagged_hole' it means you're updating an
    # existing row that was tagged with `#hole`. It's convention that when we
    # turn a row into a `#hole` we blank out the `content` field. Such a field
    # must get `create_attribute` not `update_attribute` because we are adding
    # a value to the field where before there was none. If the content field
    # wasn't already blank it will emit soft failure.

    use_dct = {k: '' for k in allowed_keys}
    use_dct.update(dct)
    d_or_u = {k: 'update_attribute' for k in allowed_keys}
    d_or_u['content'] = 'create_attribute'  # for this one field, assume blank
    edt = tuple((d_or_u[k], k, use_dct[k]) for k in allowed_keys)
    eid = iden.to_string()  # meh
    return coll.update_entity(eid, edt, listener)


def _validate_content(dct, allowed_keys, listener):
    errs = []
    for k in allowed_keys:
        s = dct.get(k)
        if s is None:
            continue
        maxi = 77  # the widest cel in the README at #history-B.3 lol
        over = len(s) - maxi
        if 0 < over:
            msg = f'is too long (max {maxi} chars. over by {over})'
            errs.append((k, msg))
            continue
        # regex? or no
    if not errs:
        return True

    def lineser():
        for k, predicate in errs:
            use = k.replace('_', '_')
            yield f"'{use}' {predicate}"
    listener('error', 'expression', 'cell_content_error', lineser)


# tl = throwing listener


def _provision_identifier(away_soon, fh, listener):  # #testpoint

    def main():
        typ, iden = traverse_whole_collection()

        if 'last_iden_tagged_as_hole' == typ:
            return 'tagged_hole', iden

        if 'last_iden_with_real_major_hole_above_it' == typ:
            new_iden = _increment_identifier(iden, 'major')  # (Case3880)
            return 'major_hole', new_iden

        if 'last_iden_with_real_minor_hole_above_it' == typ:
            new_iden = _increment_identifier(iden, 'minor', numerals_not_let)
            return 'minor_hole', new_iden  # (Case3882)

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

        from text_lib.magnetics.scanner_via import \
            scanner_via_iterator as func
        scn = func(ents)

        # If using a limiter range, advance past the ceiling limit
        # (ceiling is physically above floor in the file, and comes first,
        # because lower line numbers have higher identifier numbers)

        while scn.more and is_over_limiter_ceiling(scn.peek.identifier):
            scn.advance()

        while scn.more:
            ent = scn.peek
            iden = ent.identifier

            # If using a limiter range, stop when you hit the floor limit
            if is_under_limiter_floor(iden):
                break

            if tagged_as_hole(ent):
                last_iden_tagged_as_hole = iden
            was_under_branch = branch
            jump_distance, branch = compare(above_iden, iden, branch)
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

                ok = True
                yes1 = not numerals_not_let
                yes2 = iden.has_sub_component and 14 == iden.minor_integer
                if yes1 and yes2:
                    # YIKES if you're about to say that 14 (aka "N") has a
                    # minor hole above it AND you're doing letters not numerals
                    # then don't say it, because that would be 15 (aka "O")
                    # and we don't use that letter because it looks like "0".
                    # Take this check out and see that this "false hole"
                    # exists everywhere in our collections.

                    def lines():
                        yield "(won't use 'O' because it looks like '0')"
                    listener('info', 'expression', 'skipping_O', lines)

                    ok = False

                if was_under_branch and branch:
                    if ok:
                        last_iden_with_real_minor_hole_above_it = iden
                elif branch:  # new at writing. experiment.
                    # begining of the world to compound: minor hole
                    if ok:
                        last_iden_with_real_minor_hole_above_it = iden
                else:
                    last_iden_with_real_major_hole_above_it = iden
            above_iden = iden
            scn.advance()

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
        s = ent.core_attributes.get(main_tag_key)
        if s is None:
            return
        return rx.match(s)

    rx = _re.compile(r'(?:^| )#hole\b')

    def compare(above_iden, iden, is_under_branch):
        if is_under_branch:
            if iden.has_sub_component:
                jump_distance = minor_dist(above_iden, iden)
            else:
                jump_distance = major_dist(above_iden, iden)
                is_under_branch = False
        elif iden.has_sub_component:
            if above_iden.has_sub_component:
                jump_distance = minor_dist(above_iden, iden)
                is_under_branch = True
            else:
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

    tl = _build_throwing_listener(stop, listener)

    # This spaghetti was cooked down to a reduction sauce over hours:
    # The file was opened #here2.
    # Leave it open because we rewind it #here3. With this
    # open filehandle, traverse the collection just far enough to get the
    # schema and the first example row. Then, WHILE STILL INSIDE THE TRAVERSAL,
    # do our main work which is to come up with a provisioned identifer
    # (while remembering what provision strategy (type name string) we used)

    try:
        ic = _issues_collection_via(fh, tl, away_soon)
        coll = ic.collection
        with coll.open_schema_and_RAW_entity_traversal(tl) as (sch, ents):

            limiter = _parse_interstitials(
                sch.interstitial_lines, sch.identifier_class_, tl)
            is_over_limiter_ceiling, is_under_limiter_floor, \
                numerals_not_let = _limiter_funcs_and_ting(limiter)
            del limiter

            assert 'main_tag' == sch.field_name_keys[1]  # or w/e
            main_tag_key = 'main_tag'

            # Resolve a first entity row, assuming it's an e.g row, and:
            first_ent = None
            for first_ent in ents:
                break
            if first_ent is None:
                xx("no example row")  # #cover-me
            eg_iden = first_ent.identifier

            if eg_iden.has_sub_component:
                pass  # hi. visually. #cover-me
            else:
                pass  # hi.

            two = main()
        if two is None:
            return
        typ, iden = two
        return typ, iden, sch, ic  # #here1
    except stop:
        pass


def _limiter_funcs_and_ting(iden_range):
    if iden_range is None:
        return _is_over_ceiling, _is_under_floor, False

    o = iden_range
    start, stop = o.start, o.stop
    incl_start, incl_stop = o.start_is_included, o.stop_is_included

    if incl_stop:
        def is_over_ceiling(iden):
            return stop < iden
    else:
        def is_over_ceiling(iden):
            return stop <= iden

    if incl_start:
        def is_under_floor(iden):
            return iden < start
    else:
        def is_under_floor(iden):
            return iden <= start

    # The default #here4 is to use letters not numerals for new compound
    # identifiers. But you can get it to use numerals instead if you have a
    # limiter range, at least one of the identifiers in that range has a minor
    # component, and all minor components in the range are numerals. whew!

    numerals_not_let = False
    only_these = tuple(idn for idn in (start, stop) if idn.has_sub_component)
    if len(only_these):  # you need at least one
        def yes(idn):
            return _re.match(r'[0-9]+\Z', idn._minor_surface)
        numerals_not_let = all(yes(idn) for idn in only_these)

    return is_over_ceiling, is_under_floor, numerals_not_let


def _is_over_ceiling(iden):
    return False


def _is_under_floor(iden):
    return False


def _increment_identifier(iden, maj_or_min, numerals_not_let=False):
    use_maj, use_minor = iden.major_integer, None

    if 'minor' == maj_or_min:
        as_int = iden.minor_integer + 1
        if numerals_not_let:
            is_letter, string = False, str(as_int)
        else:
            is_letter, string = True, chr(ord('A') - 1 + as_int)
        use_minor = is_letter, string
    else:
        assert 'major' == maj_or_min
        use_maj += 1

    b = iden.include_bracket
    return iden.__class__(use_maj, tail_tuple=use_minor, include_bracket=b)


def close_issue(readme, eid, listener, opn=None):
    def main():
        eid = pre_parse_identifier()
        ic = _issues_collection_via(readme, listener, opn)
        coll = ic.collection
        edit = (('update_attribute', 'main_tag', '#hole'),
                ('update_attribute', 'content', ''))
        ur = coll.update_entity(eid, edit, throwing_listener)

        before, after, _, _ = ur  # [#857.8]

        def lines():
            yield f"BEFORE: {before.to_line()}"
            yield f"AFTER:  {after.to_line()}"
        listener('info', 'expression', 'closed_issue', lines)

        return ur

    def pre_parse_identifier():
        # Give eid's w/o leading '[', '#' a '#' so we can use cust iden class

        if len(eid) and eid[0] in ('[', '#'):
            return eid
        return f'#{eid}'

    class stop(RuntimeError):
        pass

    throwing_listener = _build_throwing_listener(stop, listener)

    try:
        return main()
    except stop:
        pass


def _open_file(path, mode, opn, listener):
    try:
        return (opn or open)(path,  mode)
    except FileNotFoundError as e:
        exc = e
    from kiss_rdb.magnetics_.collection_via_path import emit_about_no_ent as fu
    fu(listener, exc)


def _build_throwing_listener(stop, listener):
    def throwing_listener(sev, *rest):
        listener(sev, *rest)
        if 'error' == sev:
            raise stop()
    return throwing_listener


# == Delegations & Hops

def _parse_interstitials(interstitial_lines, iden_via, throwing_listener):
    if not any('\n' != s for s in interstitial_lines):
        return
    from ._directives import func
    kv = func(interstitial_lines, iden_via, throwing_listener)
    one = kv.pop('our_range', None)
    two = kv.pop('put_new_issues_in_this_range', None)
    assert not kv
    return two or one


def _issues_collection_via(x, listener, opn=None):
    from pho._issues import issues_collection_via_ as func
    return func(x, listener, opn)


# == Smalls

def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))

# #history-B.5 directives
# #history-B.4
# #history-B.3
# #born
