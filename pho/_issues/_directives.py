import re as _re


_directives = {
    'our_range': 'range',
    'put_new_issues_in_this_range': 'range',
}


def func(lines, iden_via_s, throwing_listener):
    """EXPERIMENTAL: despite all our hard work on this utility, still we never
    use it because we get so particular about identifier (re-)allocation:...
    """

    def main():
        kw = {}
        for LHS, RHS in candidates_for_directives():

            if '(' == LHS[0]:  # (this might be required, we don't remember)
                assert ')' == RHS[-1]  # ..
                LHS = LHS[1:]
                RHS = RHS[:-1]

            two = parse_directive(LHS, RHS)
            if two is None:
                continue
            k, v = two
            if k in kw:
                stop_because_clobber(LHS)
            kw[k] = v
        return kw

    def parse_directive(LHS, RHS):

        range_or_iden = iden_via_s(RHS)

        md = _re.search(r'[^A-Za-z ]', LHS)
        if md:
            stop_because(f"directive has invalid character(s), e.g: {md[0]!r}")

        key = LHS.replace(' ', '_').lower()
        which = _directives.get(key)

        if which is None:
            stop_because_not_a_recognized_directive(LHS)

        assert 'range' == which
        if not range_or_iden.is_range:
            stop_because(f"must be range: {range_or_iden.to_string()!r}")

        start, stop = range_or_iden.start, range_or_iden.stop
        if stop < start:
            stop_because(f"range is backwards: {range_or_iden.to_string()!r}")

        return key, range_or_iden

    def candidates_for_directives():
        """Directive lines look this this:

        "I am some words: [#123-456)"

        We do a coarse-parse first-pass so that some lines that look like
        directives but have some little about them off will generate
        directed messages
        """

        for line in lines:
            if '\n' == line:
                continue
            md = _coarse_rx.match(line)
            if md is None:
                continue
            parse_context.line = line
            yield md.groups()

    def stop_because_clobber(LHS):
        stop_because(f"multiple directives with same left hand side: {LHS!r}")

    def stop_because_not_a_recognized_directive(LHS):
        def lines():
            yield f"not a recognized directive: {LHS!r}"
            yield "available directives:"
            for k in _directives.keys():
                yield f"  - {_humanize(k)!r}"
        return stop_because_lines(lines)

    def stop_because(reason):
        def lines():
            line = parse_context.line
            yield f"failed to parse directive line: {line!r}"
            yield f"because {reason}"

        stop_because_lines(lines)

    def stop_because_lines(func):
        throwing_listener('error', 'expression', 'directive_parse_error', func)

    parse_context = main  # #watch-the-world-burn

    return main()


def _humanize(s):
    return ''.join((s[0].upper(), s[1:])).replace('_', ' ')


_coarse_rx = _re.compile(r"""
        (?P<left_hand_side>  [^:]+  )    # one or more not colons
        : [ ]*                           # a colon
        (?P<right_hand_side> [\[(] .+ )  # looks like it might be etc
    """, _re.VERBOSE)

# #born
