"""
Quick-and-dirty create a file with the lines that appear as a HEREDOC
at the end of this file.

Mostly as a proof of concept, we have a templating mechanism for those
lines, that leaves some room for improvement.

Error conditions exist for:
- if the file already exists
- if the parent directory for the target file does not exist
"""

import re as _re


def _CLI(sin, sout, serr, argv):
    prog_name, stack = _CLI_common_start(argv)
    serr.write(f"IMPLEMENT ME: '{prog_name()}'\n")
    return 3


def CLI_for_abstract_schema_via_recinf_(sin, sout, serr, argv):
    # this is here and not in the other file because we want it out of the
    # main flow - this will only be used in development, whereas the other
    # file will "run hot"
    prog_name, stack = _CLI_common_start(argv)

    def help_lines():
        yield f"usage: {prog_name()} FILE\n"
        yield f"       <produce-sexp> | {prog_name()} -\n"
        yield '\n'
        yield "description: derive abstract schema from recinfo lines\n"

    if _CLI_common_help_check(stack):
        w = sout.write
        for line in help_lines():
            w(line)
        return 0

    rc, fh = _CLI_resolve_upstream(sin, serr, stack, help_lines)
    if rc is not None:
        return rc

    listener = _CLI_listener(serr)
    from kiss_rdb.storage_adapters_.rec.abstract_schema_via_recinf import \
            abstract_schema_via_recinf_lines as func
    with fh:
        abs_sch = func(fh, listener)

    if abs_sch is None:
        return 3
    w = sout.write
    for line in abs_sch.to_sexp_lines():
        w(line)
    return 0


def _CLI_resolve_upstream(sin, serr, stack, help_lineser):
    w = serr.write
    if len(stack):
        first_arg = stack.pop()
        if len(stack):
            w(f"Unexpected: {stack[-1]!r}\n")
            return 3, None
        elif '-' == first_arg:
            if sin.isatty():
                w("Expecting STDIN when FILE is \"-\"\n")
                return 3, None
            fh = sin
        elif '-' == first_arg[0]:
            w(f"Unrecognized option {first_arg!r}\n")
            return 3, None
        elif not sin.isatty():
            w(f"Can't have STDIN and FILE argument\n")
            return 3, None
        else:
            fh = open(first_arg)
    elif sin.isatty():
        w("Expecting input from STDIN or FILE argument\n")
        return 3, None
    else:
        fh = sin
    return None, fh


def _CLI_common_help_check(stack):
    leng = len(stack)
    if 0 == leng:
        return False
    if _CLI_looks_like_help(stack[-1]):
        return True
    if 1 == leng:
        return False
    return _CLI_looks_like_help(stack[0])


def _CLI_looks_like_help(arg):
    return _re.match('--?h(?:e(?:lp?)?)?$', arg)


def _CLI_common_start(argv):
    stack = list(reversed(argv))
    prog_name_long = stack.pop()

    def prog_name():
        from os.path import basename
        return basename(prog_name_long)

    return prog_name, stack


def _CLI_listener(serr):
    def listener(*emi):
        *chan, lineser = emi
        assert 'expression' == chan[1]
        w = serr.write
        for line in lineser():
            w(line)
    return listener


def create_collection(coll_path, listener, is_dry_run, opn=None):

    if not _re.search(r'\.rec\Z', coll_path):
        return _when_bad_name(listener, coll_path)

    lines = _lines()

    use_open = opn or open
    e = None
    try:
        opened = use_open(coll_path, 'x')
        opened_name = opened.name
    except (FileExistsError, FileNotFoundError) as exe:
        e = exe

    if e:
        return _when_exception(listener, e)

    if is_dry_run:

        def write_line(line):
            did_this = (f"dry wrote line: {line!r}",)
            listener('info', 'expression', 'dry_wrote_line', lambda: did_this)

        opened.close()
        from os import remove as remove_file
        remove_file(coll_path)

        from contextlib import nullcontext as func
        opened = func()

    else:
        write_line = opened.write

    with opened:
        for line in lines:
            write_line(line)

    def lines():
        would_have = '(would have) ' if is_dry_run else ''
        yield f"{would_have}created new recfile collection: {opened_name}"
    listener('info', 'expression', 'wrote_file', lines)


def _lines():
    rx = _re.compile(r'^(?P<one_letter>[PF])[ ](?P<the_rest>.+)\Z', _re.DOTALL)

    from text_lib.magnetics.via_words import lines_via_big_string as func
    for line in func(_HEREDOC):
        if '\n' == line:
            yield line
            continue
        md = rx.match(line)
        if not md:
            raise RuntimeError(f'Oops: {line!r}')
        letter, rest = md.groups()
        if 'P' == letter:
            yield rest
            continue
        assert 'F' == letter  # not like this
        from datetime import datetime
        yuck = datetime.now().strftime('%Y-%m-%d')
        yield rest.format(today_date=yuck)


def _when_exception(listener, e):
    def lines():
        yield f"Can't create collection {e.filename}"
        yield e.__str__()
    listener('error', 'expression', 'cannot_create_collection', lines)


def _when_bad_name(listener, coll_path):
    def lines():
        yield f"collection path name should end in '.rec': {coll_path!r}"
    listener('error', 'expression', 'bad_collection_name', lines)


# F = run this line through .format()
# P = passthru this line


_HEREDOC = """
F # (Auto-generated on {today_date}. OK to remove this line.)
P # Reminder:
P #
P #     recsel file.rec
P #     dp filter-by-tags file.rec '#red' and not '#blue'

P informal_name: Thing 1
P summary: Best for Windows. Designed for making fairly simple changes \
P and spitting out a modified file.
P tags: #OS:windows #OS:mac #OS:linux #basic-features-only #no-because:basic
P sources: 2, 3

P informal_name: Thing 2
P summary: Best for Mac. You can use it for 3D modeling, sculpting, paints, \
P animation, and much more.
P tags: #OS:windows #OS:mac #OS:linux #VFX
P sources: 2, 3

P # #born
"""


if '__main__' == __name__:
    import sys
    exit(_CLI(sys.stdin, sys.stdout, sys.stderr, sys.argv))

# #pending-rename: maybe to "recinf_via_abstract_schema" to mirror the other
# #history-C.1: spike CLI for sibling concern
# #born
