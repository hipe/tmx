"""
This is the most complicated thing ever. It's a deep-groove hack for a
pet-project edge case: given a file that changed, see if you can resolve
one document that changed.

Pairing sections with their changes (in before & after file):

- Take the file diff as reported by the VCS along with the file itself,
  and get *two* "expanded diffs" (see): one forward and one reverse
- Given the change runs of the expanded diffs, find each section that
  participates in change and pair it with the runs that overlap it
  (called "intersections" or "inters" for short).

Low-level basics & pragmatics:

- For each section on both sides, error out if section line depth != 1.
  (This is a re-assertion of spec but meh.) #ting1
- For each section on both sides, skip with notice if not entity section.
  (Assume that one thing, again reassertion of spec but meh.) #ting2

Determining section deletes/adds/updates:

- A section is deleted IFF in the befores, the section has an "inters"
  that fully covers it and where all changes are "remove lines". The afters
  do not directly reflect deleted entities, because we filtered for only
  changes that intersect the sections in the *reference* (after) file, and
  deleted entities are not in the after file. 👈 #ting4👇
- A section is added IFF in the afters [same language as the above point].
  Note that the corresponding changes will "remove lines" (not add) same as
  in the previous point. This is because the afters is paired with changes
  from the reverse patch (that is, changes that get you from the after to
  the before) so for section added, remove lines to get back to the before.
- For all other sections (that is, sections that were neither added nor
  deleted (so, updated)), we expect that we will always find these in
  pairs: lines added appear as inserts in the forward patch and removes in
  the reverse patch and so on. (Remember "edits" are represented as the
  coupling of removes and adds.) Probably we'll assert this assumption for
  the zero or more such sections we find. #ting5

Reorderings not allowed:

- If a file edit were to includes section reorderings, these would
  superficially look (moslty) like entity removes and adds. Although (with
  a deterministic amount of development work) we could reconstruct a
  line-by-line diff of each entity after normalizing out reorderings; such
  a stunt would fly directly in the face of one of the founding novelties
  of kiss-rdb: use plain-old VCS as directly as possible to record change.
  As such, we will probably soft-assert order as we traverse both sides. #ting3

What are we doing? Also, what about entity deletes?

- In the end for now, imagine the goal case being ONE, OR MORE entity
  sections that were added or edited. The reason we don't target max one
  such entity early on is that it's conceivable that multiple entities hold
  edits or were added that are all part of the same document. Maybe it
  results in a set of multiple documents. We will let caller handle it.
- Consider entity delete: to our main use case, our job it to determine
  what document(s) have been added/removed/updated given a single file
  diff. Entity delete suggests a document update. (Other possibilities:
  it wasn't part of a document (so do nothing/undefined); or it was last
  notecard in the document, in which case imagine document delete, another
  case we leave undefined for now.)
- In any case, the problem with deletes is that our argument diff file
  shows the difference between the *previous* state and the *current*
  state. Using our massive stack here, we can know the EID's of deleted
  entities, but it's perhaps absurd to ask for a whole  document hierarchy
  against a past collection state. Hence we can't reasonably know what
  document a deleted entity was a part of. At least, this is far out
  of this scope of reactively handling file edits. As such, what it
  amounts to is we soft-fail on all deletes, with an explanation that
  somewho distills all of the above down to a sentence or two. #ting6
"""

from collections import namedtuple as _nt
import re as _re


def abstract_document_via_file_with_changes(path, listener=None):
    def main():
        coll_path = _collection_path_via_file_path(path)
        eids = eids_via()
        ncid, = eids  # only because #here4
        bcoll = bcoll_via(coll_path)
        ncs = NCs_via(ncid, bcoll)
        return bcoll.abstract_document_via_notecards(ncs, listener)

    def NCs_via(ncid, coll):
        for nc, depth in do_NCs_via(ncid, coll, listener):
            yield nc

    def eids_via():
        eids = _EIDS_via_file_with_changes(path, listener)
        if eids is None:
            raise _Stop()
        return eids

    def bcoll_via(coll_path):
        # failure seems somewhat unlikely
        from pho import read_only_business_collection_via_path_ as func
        return func(coll_path, listener)

    from .abstract_document_via_notecards import \
        document_notecards_in_order_via_any_arbitrary_start_node_ as do_NCs_via

    try:
        return main()
    except _Stop:
        pass


func = abstract_document_via_file_with_changes


# == BEGIN weird experiment: could be replaced with one regex

def _collection_path_via_file_path(path):
    # Note to the future: refactor this to one regex if you hate it

    scn = _custom_scanner(path)

    # Assert that the tailmost element looks like the file entry
    assert _re.match(r'[A-Z0-9]\.eno\Z', scn.peek)
    scn.advance()

    # Keep going up the path while the directories look like this
    while _re.match(r'[A-Z0-9]\Z', scn.peek):
        scn.advance()

    return path[0:scn.cursor]


def _custom_scanner(path):  # #experiment
    scn = _scanner_via_iterator(_custom_iterator(path))
    assert scn.more

    def advance():
        orig_advance()
        hack()
    orig_advance = scn.advance
    scn.advance = advance

    def hack():
        scn.cursor, scn.peek = scn.peek
    hack()
    return scn


def _custom_iterator(path):
    # scan over each component of a path FROM END TO BEGINNING. also cursor

    from os.path import sep
    cursor = len(path)
    sep_len = len(sep)

    while True:  # it's custom
        next_cursor = path.rindex(sep, 0, cursor)
        yield next_cursor, path[next_cursor+sep_len:cursor]
        cursor = next_cursor

# == END


def _EIDS_via_file_with_changes(path, listener, opn=None):  # #testpoint

    def main():
        patch_lines = resolve_one_or_more_patch_lines()
        fwd, rev = resolve_extended_patches(patch_lines)
        bpairs, apairs = _sections_with_changes(fwd, rev)
        before_tris, after_tris = _entity_sects_only(bpairs, apairs, listener)
        dd, aa, uu = _deletes_adds_updates(before_tris, after_tris, listener)
        _check_no_deletes_min_1_adds_and_updates(dd, aa, uu, listener)
        eids = tuple(munge_them_right_here(aa, uu))
        _check_max_1_for_now(eids, listener)  # #here4
        return eids

    def munge_them_right_here(aa, uu):
        for tri in aa:
            yield tri[2]  # #here2

        for dtri in uu:
            yield dtri[1][2]  # #here3 then #here2

    def resolve_extended_patches(patch_lines):
        from text_lib.diff_and_patch.classified_lines_via_patch import func
        with open(path) as lines:
            fwd, rev = func(patch_lines, lines)
            return fwd, rev

    def resolve_one_or_more_patch_lines():
        from kiss_rdb.vcs_adapters.git import git_diff as func
        rc, patch_lines = func(path, listener, opn=opn)
        if rc:
            raise stop()  # assume something emitted
        if not patch_lines:
            def these_lines():
                yield "file is noent, is not in the repo or has no changes:"
                yield path
            listener('notice', 'expression', 'no_diff', these_lines)
            raise stop()
        return patch_lines

    stop = _Stop
    try:
        return main()
    except stop:
        pass


def _check_max_1_for_now(eids, listener):
    """We can imagine an algorithm that resolves one or more documents from
    multiple notecards with changes; BUT it's probably not worth it for now
    """

    leng = len(eids)
    if 1 == leng:
        return
    doc = _check_max_1_for_now.__doc__
    lines_lol = tuple(md[1] for md in _re.finditer(r'([^ \n][^\n]*)\n', doc))

    def lines():
        yield "Won't attempt to resolve document from this because"
        yield f"more than one notecard changed ({', '.join(eids)})."
        yield ''.join(('(', lines_lol[0]))
        for line in lines_lol[1:-1]:
            yield line
        yield ''.join((lines_lol[-1], ')'))
    listener('error', 'expression', 'max_one_changed_notecard_for_now', lines)
    raise _Stop()


def _check_no_deletes_min_1_adds_and_updates(deletes, adds, updates, listener):

    # Check no deletes
    if deletes:
        def lines():  # #ting6
            _ = ', '.join(eids)
            yield f"We detected one or more entity deletes ({_})."
            yield "But we don't attempt to determine the affected document from deletes:"  # noqa: E501
            yield "rebuilding document hierarchies from past collection states is too crazy"  # noqa: E501
        eids = tuple(tri[2] for tri in deletes)  # #here2
        listener('error', 'expression', 'cannot_handle_deletes', lines)
        raise _Stop()

    # Check at least one add or update
    if 0 == (len(adds) + len(updates)):
        def lines():
            yield "Any changes to the file were not in entity sections. Nothing to do."  # noqa: E501
        listener('info', 'expression', 'no_changes', lines)
        raise _Stop()


def _deletes_adds_updates(before_tris, after_tris, listener):
    deleted_added = [], []
    bchanged_achanged = [], []

    # In a first pass, partition into either {delete|add} or update
    before_tris_after_tris = before_tris, after_tris
    for zero_or_one in range(0, 2):
        for tri in before_tris_after_tris[zero_or_one]:
            (start, stop, _sect), inters = tri[:2]
            typ = _covered_by(start, stop, inters)
            if typ:
                assert 'all_remove_lines' == typ  # #ting4
                deleted_added[zero_or_one].append(tri)
            else:
                bchanged_achanged[zero_or_one].append(tri)

    # In a second pass, verify our assumption #ting5
    def these():
        for zero_or_one in range(0, 2):  # #here2👇
            yield tuple(tri[2] for tri in bchanged_achanged[zero_or_one])

    bchanged_EIDs, achanged_EIDs = these()

    if bchanged_EIDs != achanged_EIDs:
        xx("fascinating. every updated section should be in both before & aft")

    # For the updates, zip together before and after tri because you're insane
    def these():
        for i in range(0, len(bchanged_EIDs)):  # either one
            yield bchanged_achanged[0][i], bchanged_achanged[1][i]  # #here3

    deleted, added = deleted_added
    return tuple(deleted), tuple(added), tuple(these())


def _covered_by(start, stop, inters):
    run = _only_one_run(inters)
    if run is None:
        return
    rstart, rstop, exi, repl = run
    if not (rstart <= start):
        return
    xx("never been run before: determine if change covers section")
    if not (stop <= rstop):
        return
    if exi is None:
        assert len(repl)
        return 'all_insert_lines'
    assert len(exi)
    assert repl is None
    return 'all_remove_lines'


def _only_one_run(inters):  # oops, categorized runs isn't really helpful
    these = []
    if (arr := inters.inside_or_flush):
        these.extend(arr)
    if (dct := inters.overhangs):
        these.extend(dct.values())
    if 1 != len(these):
        return
    return these[0]


def _entity_sects_only(before_pairs, after_pairs, listener):
    section_line_rx = _re.compile(
        r'entity:[ ]?(?P<EID>[A-Z0-9]+):[ ]?attributes\Z')

    two_pairses = before_pairs, after_pairs
    result = ([], [])
    expected_identifier_depth = None

    for zero_or_one in range(0, 2):
        result_tris = result[zero_or_one]
        prev_EID = None
        for pair in two_pairses[zero_or_one]:
            sect = pair[0][2]  # #here1
            line_AST = sect.section_line_AST
            depth, text = line_AST.depth, line_AST.label_text

            # On sections with the wrong depth… #ting1
            if 1 != depth:
                def lines():
                    yield f"Needed section depth of 1 had {depth}:"
                    yield f"    {line_AST.line[:-1]}"
                listener('error', 'expression', 'wrong_section_depth', lines)
                raise _Stop()

            # Skip over sections that don't look like entity sections #ting2
            md = section_line_rx.match(text)
            if md is None:
                if 'document-meta' == text:
                    continue

                def lines():
                    yield f"Doesn't look like entity section: {text!r}. Skipping"  # noqa: E501
                listener('error', 'expression', 'non_entity_section', lines)
                raise _Stop()  # experimental

            # Will check depth and order, except on first ever and local 1st en
            eid = md['EID']
            depth = len(eid)

            # Maybe check depth
            if expected_identifier_depth is None:
                expected_identifier_depth = depth
            elif expected_identifier_depth != depth:
                def lines():
                    yield f"expecting identifier depth of {expected_identifier_depth}: {eid!r}"  # noqa: E501
                listener('error', 'expression', 'identifier_depth', lines)
                raise _Stop()

            # Maybe check order #ting3
            if prev_EID is not None and eid <= prev_EID:
                def lines():
                    yield f"out of order ({prev_EID!r} then {eid!r})"
                listener('error', 'expression', 'out_of_order', lines)
                raise _Stop()

            prev_EID = eid

            result_tris.append((*pair, eid))  # #here2
    return tuple(tuple(arr) for arr in result)


def _sections_with_changes(fwd, rev):

    # Make the "lefts" (the sections in the files)

    before_lines = fwd.to_reference_lines()
    after_lines = rev.to_reference_lines()

    from kiss_rdb.storage_adapters.eno import \
        sections_parsed_coarsely_via_lines as func

    before_sects = func(before_lines)
    after_sects = func(after_lines)

    def sects_with_line_offsets(sects):
        offset = 0
        for sect in sects:
            next_offset = offset + sect.line_count
            yield offset, next_offset, sect
            offset = next_offset

    cbefore_sects = sects_with_line_offsets(before_sects)
    cafter_sects = sects_with_line_offsets(after_sects)

    # Make the "rights" (change runs in the diff)

    def change_runs_of(exte):
        return (run for typ, run in exte.to_classified_runs() if 'no_change' != typ)  # noqa: E501

    before_change_runs = change_runs_of(fwd)
    after_change_runs = change_runs_of(rev)

    # Pair the sections with their overlapping changes

    before_inters = _find_span_intersections(cbefore_sects, before_change_runs)
    after_inters = _find_span_intersections(cafter_sects, after_change_runs)

    # Filter out so you only have the ones with changes

    def only_these(pairs):
        for sect, inters in pairs:
            if inters is None:
                continue
            yield sect, inters

    before_pairs = tuple(only_these(before_inters))
    after_pairs = tuple(only_these(after_inters))
    return before_pairs, after_pairs


def _find_span_intersections(left_things, right_things):  # #testpoint
    """Given a one-dimensional coordinate space of integers (like line numbers)

    and two streams of non-overlapping spans (non-overlapping in the context
    of the stream), produce one tuple for each item in the left stream where
    it's the item from the stream paired with all the items from the right
    stream that overlap it or touch it.

    The spans in each stream must be in order. An individual span may be
    zero width (but cannot be negative width: its stop must be on or after
    its start).
    """

    left_scn = _scanner_via_iterator(_check_ranges(left_things))
    right_scn = _scanner_via_iterator(_check_ranges(right_things))

    assert left_scn.more
    assert right_scn.more

    while left_scn.more:
        left_start, left_stop = left_scn.peek[:2]

        kissing_before, kissing_after = None, None
        inside_or_flush, overhangs = [], {}

        while right_scn.more:
            right_start, right_stop = right_scn.peek[:2]

            # Is this span totally before the left span?
            if right_stop < left_start:
                right_scn.advance()  # then discard it and keep looking
                continue

            # Is this span totally after the left span?
            if left_stop < right_start:
                break  # then stop looking (assume they're in order)

            # Kissing before?
            if right_stop == left_start:
                assert not kissing_before
                kissing_before = right_scn.next()  # consume it off the scanner
                continue

            # Kissing after?
            if left_stop == right_start:
                assert not kissing_after
                kissing_after = right_scn.peek  # leave it on the scanner
                break  # then stop looking (assume they're in order)

            # Relationship between starts and stops
            start_rel = _relationship(right_start, left_start)
            stop_rel = _relationship(left_stop, right_stop)  # order matters

            # Easy ones:
            # - inside inside: fully inside
            # - equal equal: fully flush (spans equal)
            # - equal inside: flush at start
            # - inside equal: flush at stop

            # Hard ones:
            # - overhang overhang: fully overhanged (enveloped, enshadowed)
            # - {inside|equal} overhang: right overhang
            # - overhang {inside|equal}: left overhang

            sig = ('overhang' == start_rel, 'overhang' == stop_rel)
            tup = _when_overhang[sig]
            if tup is None:
                inside_or_flush.append(right_scn.next())
                continue

            k, do_consume, do_stay = tup

            assert k not in overhangs
            x = right_scn.next() if do_consume else right_scn.peek
            overhangs[k] = x
            if not do_stay:
                break

        has, intersections = False, None
        use_kissing, use_insides, use_overhangs = None, None, None
        if kissing_before or kissing_after:
            use_kissing = kissing_before, kissing_after
            kissing_before, kissing_after = None, None
            has = True

        if inside_or_flush:
            use_insides = tuple(inside_or_flush)
            inside_or_flush.clear()
            has = True

        if overhangs:
            use_overhangs = overhangs
            overhangs = {}
            has = True

        if has:
            intersections = _intersections(
                use_insides, use_overhangs, use_kissing)

        left_thing = left_scn.next()
        yield left_thing, intersections


_when_overhang = {  # key, do consume, do stay
    (False, False): None,
    (False, True): ('at_stop', False, False),
    (True, False): ('at_start', True, True),
    (True, True): ('full', False, False),
}


_intersections = _nt('_Intersections', (
    'inside_or_flush', 'overhangs', 'kissing'))


def _relationship(one, other):
    if one < other:
        return 'overhang'
    if other < one:
        return 'inside'
    assert one == other
    return 'equal'


def _check_ranges(itr):
    tup = next(itr)
    start, prev_stop = tup[:2]
    assert start <= prev_stop
    yield tup
    for tup in itr:
        start, stop = tup[:2]
        assert start <= stop
        assert prev_stop <= start
        yield tup
        prev_stop = stop


class _Stop(RuntimeError):
    pass


def _scanner_via_iterator(itr):
    from text_lib.magnetics.scanner_via import scanner_via_iterator as func
    return func(itr)


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #born
