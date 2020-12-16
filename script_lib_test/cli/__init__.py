def _formals():
    yield '-h', '--help', 'This screen'
    yield 'test-name', "The test name. Use 'list' to splay all test names"


def _CLI(sin, sout, serr, argv, fxser):
    """regression-friendly visual tests for our ncurses layer.."""

    prog_name = (bash_argv := list(reversed(argv))).pop()
    foz = _foz_via(_formals(), lambda: prog_name)

    vals, es = foz.terminal_parse(serr, bash_argv)
    if vals is None:
        return es
    if vals.get('help'):
        return foz.write_help_into(sout, _CLI.__doc__)

    arg = vals.pop('test_name')
    assert not vals

    import re
    if re.match(r'l(?:s|(?:i(?:st?)?))\Z', arg):
        for tup in _tests():
            sout.write(tup[0])
            sout.write('\n')
        return 0

    if re.match(r'\d+\Z', arg):
        match = _number_based_matcher_via(arg)
    else:
        match = _whole_name_based_matcher(arg)

    matches = []
    count = 0
    for slug, loader in _tests():
        count += 1
        did_fuzzy_match, did_exact_match = match(slug)
        if not did_fuzzy_match:
            continue
        if did_exact_match:
            matches.clear()
        matches.append((slug, loader))
        if did_exact_match:
            break

    leng = len(matches)
    if 0 == leng:
        serr.write(f"No tests match {arg!r} (of {count} seen). Try 'list'\n")
        return 5678
    if 1 < leng:
        serr.write(f"{count} tests match {arg!r}:\n")
        for slug, _ in matches:
            serr.write(f"  - {slug}\n")
        serr.write("Try tightening up the name.\n")
        return 5679
    match, = matches
    slug, loader = match

    ch_argv = (f"{prog_name} {slug}", *reversed(bash_argv))
    cli = loader(slug)
    return cli(sin, sout, serr, ch_argv, fxser)

    sout.write(f'OK: {slug!r}\n')
    return 0


def _number_based_matcher_via(arg):
    def match(slug):
        return (True, True) if arg == slug[0:leng] else (False, False)
    leng = len(arg)
    return match


def _whole_name_based_matcher(arg):
    def match(slug):
        if arg in slug:
            return (True, True) if slug == arg else (True, False)
        else:
            return False, False
    return match


def _tests():
    yield '010-what-key-was-pressed', _load_commonly
    yield '020-buttons-and-flash', _load_commonly
    yield '030-checkboxes-and-fields', _load_commonly
    yield '040-orderable-list-simple', _load_commonly
    yield '050-orderable-list-poly', _load_commonly


def _load_commonly(slug):
    mname = ''.join(('script_lib_test.cli.vtest_', slug.replace('-', '_')))
    from importlib import import_module as func
    return func(mname).CLI_


# ==

def _foz_via(defs, pner, x=None):
    from script_lib.cheap_arg_parse import formals_via_definitions as func
    return func(defs, pner, x)


def cli_for_production():
    from sys import stdin, stdout, stderr, argv
    exit(_CLI(stdin, stdout, stderr, argv, None))


if '__main__' == __name__:
    cli_for_production()

# #born
