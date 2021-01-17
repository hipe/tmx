"""
## Synopsis

Given the "after" file and a patch file expressing "the" changes to that
file, produce two lists of "classifed lines" (conceptually).



## Justification and patch theory

Context diffs are the patch lingua-franca (with good reason); but they do
not quickly answer the question "Does this given line I'm on right now have
changes (or the boundary above it or below it)?".

An "after" file and its patch file imply *four* files: the two just mentioned,
and also a "before" file and finally the reverse patch file (that is, a patch
that gets you *from* the "after" file *to* the "before" file).

Given an "after" file and the patch that got it there, we produce *two*
"expanded" patch files: one forward and one reverse.

An "expanded" patch file is the patch file coupled with its referant file:
It's a series of "runs", each run representing a continuous … run of ZERO
or more lines in the referent file, and that run's corresponding instructions:
either "replace_lines" or "no_change". "replace_lines" has ZERO or more
accompanying lines to be used in the replacement.

A "replace_lines" run that stipulates a zero-with range of lines in the
referent (e.g "from start offset 7 to stop offset 7") and nonzero replacement
lines; this is how you express "insert lines".

Conversely, if you model a "replace_lines" run that has a nonzero run of
lines in the referent, and zero lines in the replacement; this is in effect
"delete lines".

With these two resultant "expanded patch" files, we have the lines of the
before file coupled with a forward patch, and the lines of the after file
coupled with the reverse patch, which we want for reasons. (Our designation
of one being "before/forward" and the other being "after/reverse"; these
designations are are purely pragmatic. Both are structurally of the same
types and have the same capabilities.)
"""


def two_expanded_diffs_via_patch_file_and_after_file(diff_lines, after_lines):
    fwd_patch_runs, rev_patch_runs = [], []
    for which, start, stop, exi_lines, repl_lines in _work(diff_lines, after_lines):  # noqa: E501
        if 'forward_patch' == which:
            use = fwd_patch_runs
        else:
            assert 'reverse_patch' == which
            use = rev_patch_runs
        use.append((start, stop, exi_lines, repl_lines))
    return _Expanded(tuple(fwd_patch_runs)), _Expanded(tuple(rev_patch_runs))


func = two_expanded_diffs_via_patch_file_and_after_file


class _Expanded:
    def __init__(self, runs):
        self._runs = runs

    def to_applied_lines(self):
        for typ, run in self.to_classified_runs():
            if 'no_change' == typ:
                use = run[2]  # #here1
            elif 'remove_lines' == typ:
                continue
            else:
                assert 'insert_lines' == typ
                use = run[3]  # #here1
            for line in use:
                yield line

    def to_reference_lines(self):
        for typ, run in self.to_classified_runs():
            if 'no_change' == typ:
                use = run[2]  # #here1
            elif 'remove_lines' == typ:
                use = run[2]  # #here1
            else:
                assert 'insert_lines' == typ
                continue
            for line in use:  # #here1
                yield line

    def to_classified_runs(self):
        assert_offset = 0
        for run in self._runs:
            start, stop, exi, repl = run

            # Make sure each next start is at the last stop
            assert assert_offset == start

            # Make sure each start is before or at each stop
            assert start <= stop

            assert_offset = stop

            num = stop - start

            if exi is None:
                assert 0 == num  # there is no 'replace_lines'
                assert len(repl)
                yield 'insert_lines', run
            else:
                assert num
                assert num == len(exi)
                if repl is None:
                    yield 'no_change', run
                else:
                    assert 0 == len(repl)
                    yield 'remove_lines', run


def _work(diff_lines, after_lines):
    file_patch, = _file_patches_via_patch_lines(diff_lines)
    count, line_scn = _counter_and_scanner_via_iterator(after_lines)
    bcounter = _Counter()

    for hunk in file_patch.hunks:
        for tup in _work_hunk(hunk, bcounter, count, line_scn):
            yield tup

    if line_scn.empty:
        return

    def flush():
        while line_scn.more:
            yield line_scn.next()

    before_offset = bcounter.value
    after_offset = count()
    lines = tuple(flush())
    bstop = before_offset + len(lines)

    yield 'forward_patch', before_offset, bstop, lines, None
    yield 'reverse_patch', after_offset, count(), lines, None


def _work_hunk(hunk, bcounter, count, line_scn):
    _ = (i-1 for i in hunk.to_the_four_integers())
    before_begin, before_end, after_begin, after_end = _
    before_offset = bcounter.value
    after_offset = count()

    # Output the zero or more lines that are unchanged up to the next hunk
    num = after_begin - after_offset
    if num:
        exi = tuple(line_scn.next() for _ in range(0, num))
        bstop = before_offset + num
        yield 'forward_patch', before_offset, bstop, exi, None
        yield 'reverse_patch', after_offset, after_begin, exi, None
        before_offset = bstop
        after_offset = count()
        assert after_begin == after_offset

    # Each run
    asserty_line_run = _build_asserty_line_run(line_scn)
    for run in hunk.runs:
        cn = run.category_name
        patch_lines = run.lines

        if 'context_lines' == cn:
            leng = len(patch_lines)
            bstop = before_offset + leng
            stop = after_offset + leng
            lines = asserty_line_run(patch_lines)
            yield 'forward_patch', before_offset, bstop, lines, None
            yield 'reverse_patch', after_offset, stop, lines, None
            assert stop == count()
            before_offset = bstop
            after_offset = stop
            continue

        if 'add_lines' == cn:
            stop = after_offset + len(patch_lines)
            lines = asserty_line_run(patch_lines)
            yield 'forward_patch', before_offset, before_offset, None, lines
            yield 'reverse_patch', after_offset, stop, lines, ()
            assert stop == count()
            after_offset = stop
            continue

        assert 'remove_lines' == cn
        lines = tuple(line[1:] for line in patch_lines)
        bstop = before_offset + len(lines)
        yield 'forward_patch', before_offset, bstop, lines, ()
        yield 'reverse_patch', after_offset, after_offset, None, lines
        before_offset = bstop

    bcounter.update(before_offset)


def _build_asserty_line_run(line_scn):
    def asserty_line_run(lines):
        return tuple(do_asserty_line_run(lines))

    def do_asserty_line_run(lines):
        for line in lines:
            have_line_content = line[1:]
            assert_line_content = line_scn.next()
            assert assert_line_content == have_line_content
            yield have_line_content
    return asserty_line_run


def _file_patches_via_patch_lines(lines):
    from text_lib.diff_and_patch import \
            file_patches_via_unified_diff_lines as func
    return tuple(func(lines))


def _counter_and_scanner_via_iterator(itr):
    from text_lib.magnetics.scanner_via import \
        scanner_via_iterator as func, MUTATE_add_counter
    scn = func(itr)
    count = MUTATE_add_counter(scn)
    return count, scn


class _Counter:  # #[#510.13] a counter
    def __init__(self):
        self.value = 0

    def update(self, new_value):
        assert self.value < new_value
        self.value = new_value


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #born
