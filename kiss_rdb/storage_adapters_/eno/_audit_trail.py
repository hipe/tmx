from dataclasses import dataclass as _dataclass


# eid = entity identifier (string)
# ci = collection implementation
# mon = monitor (listener)
# opn = inject a function for mocking responses from `git log`, probably
# .#todo when they are function arguments, the above should be etc

def audit_trail_via_EID_and_collection_implementation_(eid, ci, mon, opn=None):
    """Given the arguments, produce an interator of sexps

    of the form:

        ('entity_snapshot', …)

            [ ('entity_edit', …), ('entity_snapshot', …) […] ]

    I.e., one or more entity snapshots, each with an entity edit in between.
    It goes in reverse chronological order (like `git log` does), so you'll
    start from the entity as it is right now, and go backwards in time.

    (Note each edit is presented in its "forward" form, expressing the patch
    and change in the expected, forwards-in-time way, despite the big stream
    going backwards. This is exactly as it is reading output from `git log`.)

    If the entity only has one "snapshot" (relevant commit) in the collection,
    then the result stream will have one element total, being one snapshot
    and no edits.

    Behavior is undefined if you have relevant unversioned changes in your
    collection; like if you created the entity but didn't version it yet, or
    you have unversioned edits to the entity. (It will almost certainly fail,
    hopefully spectacularly, hopefully not silently.)

    (Eventually we'll probably want to fail cleanly on this. If we really had
    to we could etc, parse `git diff`, but yuck.)

    (It's worth mentioning that the reason this will probably fail is because,
    although a VCS is self-consistent, we use the working tree to get the
    current snapshot. Probably we could etc, get the pristine file from
    HEAD somehow but yuck.)

    There is no facility for generating an audit trail for an entity that
    was once in the collection but is no longer there (by EID); that is,
    for an entity that is deleted. Although the entity still "exists" in its
    various snapshots in the VCS, we are not interesting in dealing with
    this use case presently.
    """

    """(EXPERIMENTALLY writing this as a huge stack of small-ish functions
    that all write their return values to the same locally global scope.

    So far the CONSs to this technique:
    - You don't see the high-level overview of what's going on until the end…
    - The individual functions can't be exposed for isolated testing
    """

    def main():
        build_entity_snapshot = _build_build_entity_snapshot(eid, ci, mon)
        entity_lines_now = body_of_text.lines[start_LO:stop_LO]

        # (the first entity snapshot we build, we don't need to build it like
        # the others because we already parsed the whole document in retrieval)

        snap = _EntitySnapshot(entity_lines_now, retr.entity.core_attributes)
        assert snap.core_attributes is not None  # until it is

        yield 'entity_snapshot', snap

        latter_snap = snap  # we are going back in time, it's not prev it's lat

        chain_is_intact = True

        for hunk in hunks_iterator:
            hdr = hunk.to_git_hunk_run_header_AST()  # doin it early and always

            these_lines = tuple(hunk.REVERT_LINES(entity_lines_now))
            # (WOW REAllY AMAZING)
            entity_lines_now = these_lines

            snap = build_entity_snapshot(entity_lines_now)

            if chain_is_intact:
                if snap.core_attributes is None:
                    def lines():
                        return (lines.reason,)
                    lines.reason = snap.core_attributes_failure_reason
                    listener('notice', 'expression', 'breaking_chain', lines)
                    chain_is_intact = False
                    ent_diff = None
                else:
                    ent_diff = snap.CREATE_ENTITY_DIFF(latter_snap)

            yield 'entity_edit', _EntityEdit(ent_diff, hdr, hunk)

            yield 'entity_snapshot', snap
            latter_snap = snap

    def build_hunks_iterator():
        from text_lib.diff_and_patch import \
            next_hunk_via_line_scanner as func, scanner_via_iterator

        scn = scanner_via_iterator(output_lines_of_git_log)
        if scn.empty:
            return
        yield func(scn)
        while scn.more:
            # expect a blank line because git puts one between the last hunk
            # line and the next nerfulous derfulous line. which is fine
            assert '\n' == scn.peek
            scn.advance()
            yield func(scn)

    def build_output_lines_of_git_log():
        from kiss_rdb.vcs_adapters.git import \
            open_git_subprocess_ as open_process, \
            split_path_for_git_ as split

        # (if you decide it makes us nervous not knowing project root:)
        # `git rev-parse --show-toplevel`

        path = body_of_text.path
        cwd, entry = split(path)

        L_opt = f'-L{start_LO+1},{stop_LO}:{entry}'
        cmd_tail = 'log', '--follow', L_opt, '--', entry

        serr_lines_cache = []

        for k, x in open_process(cmd_tail, cwd=cwd, opn=opn):
            if 'sout' == k:
                yield x  # a line
                continue
            if 'serr' == k:
                if serr_lines_cache:
                    xx(f"fun, flush cache and stop: {x!r}")
                serr_lines_cache.append(x)
                continue
            assert 'returncode' == k
            returncode = x

        if not serr_lines_cache:
            assert 0 == returncode  # it's up to vendor, tho
            return

        assert 0 != returncode  # it's up to vendor, tho

        def details():
            dct = {'returncode': returncode}
            dct['reason'] = f"from git: {reason}"
            return dct
        reason, = serr_lines_cache
        listener('error', 'structure', 'vendor_subprocess_failed', details)
        raise stop()

    def line_offsets_and_lines():
        el = retr.entity_section

        from . import start_line_offset_via_vendor_element_ as func
        start_LO = func(el)
        bot = retr.body_of_text
        all_file_lines = bot.lines
        from ._blocks_via_path import line_index_via_lines_ as func
        line_index = func(all_file_lines)
        stop_LO = line_index.stop_line_offset_of_vendor_element(el)

        # Advance the end pointer to include whitespace because why not
        last_LO = len(all_file_lines)
        while stop_LO < last_LO and '\n' == all_file_lines[stop_LO]:
            stop_LO += 1

        return start_LO, stop_LO, bot

    def resolve_entity_retrieval():
        # Resolve an entity "retrieval" from the identifier

        retr, = ci.entity_retrievals((iden,), mon)
        if retr.entity:
            return retr
        raise stop()

    def resolve_identifier():
        idener = ci.build_identifier_function_(listener)  # might change sig to
        if (iden := idener(eid)):
            return iden
        raise stop()

    stop = _Stop
    try:
        listener = (mon and mon.listener)
        iden = resolve_identifier()
        retr = resolve_entity_retrieval()
        start_LO, stop_LO, body_of_text = line_offsets_and_lines()
        output_lines_of_git_log = build_output_lines_of_git_log()
        hunks_iterator = build_hunks_iterator()
        for sx in main():  # unwind the traversal while you are in the catch
            yield sx
    except stop:
        pass


func = audit_trail_via_EID_and_collection_implementation_


def _create_entity_diff(before_snap, after_snap):
    # (realized this isn't tied to a snapshot strongly)

    def do(snap):
        dct = snap.core_attributes
        return set(dct.keys()), dct

    before_set, before_dct = do(before_snap)
    after_set, after_dct = do(after_snap)

    in_both = before_set & after_set
    removed_keys = sorted(before_set - in_both)
    added_keys = sorted(after_set - in_both)
    in_both = sorted(in_both)

    attributes_removed = {k: before_dct[k] for k in removed_keys}
    attributes_added = {k: after_dct[k] for k in added_keys}

    attributes_changed = {}

    for k in in_both:
        before_val = before_dct[k]
        after_val = after_dct[k]
        if before_val == after_val:
            continue
        # (i forgot how type works in eno)
        before_is_multi = '\n' in before_val
        after_is_multi = '\n' in after_val

        if not (before_is_multi or after_is_multi):
            attributes_changed[k] = 'wordlike_values', before_val, after_val
            continue

        before_lines = before_val.splitlines(keepends=True)
        after_lines = after_val.splitlines(keepends=True)
        from difflib import ndiff
        wow = tuple(ndiff(before_lines, after_lines))
        attributes_changed[k] = 'ndiff', wow

    return _EntityDiff(
        attributes_removed=(attributes_removed or None),
        attributes_added=(attributes_added or None),
        attributes_changed=(attributes_changed or None))


def _build_build_entity_snapshot(arg_EID, ci, mon):

    def build_entity_snapshot(entity_lines):
        bot = body_of_text_via(lines=entity_lines)
        dct, reason = these_via_body_of_text(bot)
        return _EntitySnapshot(entity_lines, dct, reason)

    def these_via_body_of_text(bot):
        lines = bot.lines
        if 0 == len(lines):
            # (every entity will have no line when you're etc
            return _empty_dict, None
        line = lines[0]
        if '#' != line[0]:
            reason = f"Doesn't look like eno section line: {line!r}"
            return None, reason

        # WOULD FAIL IF IT"S NOT VALID ENO
        docu = ci.eno_document_via_(body_of_text=bot)
        # fr = file_reader_via(docu, bot, ci, mon)

        # WOULD FAIL IF THE RUN OF ENO DOESN"T LOOK LIKE THIS
        sects = tuple(tokenized_sections(docu, bot, listener))
        leng = len(sects)
        assert leng
        if 1 == leng:
            (typ, eid, sect_el), = sects
            if arg_EID != eid:
                reason = (f"NOTICE: When auditing {arg_EID!r} it flipped to"
                          f" {eid!r}. Skipping this entity snapshot.")
                return None, reason
        else:
            _say_ting(listener, sects, arg_EID)
            found = False
            for typ, eid, sect_el in sects:
                if arg_EID == eid:
                    found = True
                    break
            assert found

        ent = entity_via(
            sect_el, identifier=None,
            correct_old_key_names=True, monitor=mon)

        return ent.core_attributes, None

    from . import \
        tokenized_sections_ as tokenized_sections, \
        read_only_entity_via_section_ as entity_via, \
        body_of_text_ as body_of_text_via

    listener = mon.listener

    return build_entity_snapshot


def _say_ting(listener, sects, arg_EID):
    def lines():
        yield (f"NOTICE: Found {len(sects)} sections on audit for {arg_EID} "
               f"({these}), attempting to find the correct one")
    eids = tuple(three[1] for three in sects)
    these = ', '.join(eids)
    listener('notice', 'expression', 'ting_ting', lines)


@_dataclass
class _EntityEdit:
    entity_diff: object
    hunk_header_AST: object
    hunk: object

    def to_summary_lines(self, margin=''):
        yield f"{margin}Entity edit:\n"
        these = (getattr(self, k) for k in self._fields)
        these = (o for o in these if o)
        ch_m = f"{margin}  "
        for line in (line for o in these for line in o.to_summary_lines(ch_m)):
            yield line

    _fields = 'entity_diff', 'hunk_header_AST', 'hunk'


@_dataclass
class _EntityDiff:
    attributes_removed: dict
    attributes_added: dict
    attributes_changed: dict

    def to_summary_lines(self, margin=''):
        yield f"{margin}Entity diff:\n"
        did = False
        for k in self._fields:
            v = getattr(self, k)
            if not v:
                continue
            did = True
            label = _my_title(k)
            desc = ''.join(('(', ', '.join(v.keys()), ')'))
            yield f"{margin}  {label}: {desc}\n"
        if did:
            return
        yield f"{margin}  (empty diff)\n"

    _fields = 'attributes_removed', 'attributes_added', 'attributes_changed'


@_dataclass
class _EntitySnapshot:
    entity_lines: tuple
    core_attributes: dict = None
    core_attributes_failure_reason: str = None

    def CREATE_ENTITY_DIFF(self, after):
        return _create_entity_diff(self, after)

    def to_summary_lines(self):
        if self.core_attributes:
            desc_attrs = f" {len(self.core_attributes)} attrs"
        elif (s := self.core_attributes_failure_reason):
            desc_attrs = f" (no attrs because {s})"
        else:
            desc_attrs = ''
        n = len(self.entity_lines)
        yield f"Entity snapshot: {n} line(s){desc_attrs}\n"


def _my_title(k):
    words = k.split('_')
    words[0] = words[0].title()
    return ' '.join(words)


class _Stop(RuntimeError):
    pass


_empty_dict = {}


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #born
