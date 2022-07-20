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


_doc = __doc__


def _CLI(sin, sout, serr, argv):
    # made for the first time at #history-C.1
    def usage_lines():
        yield "usage: {{prog_name}} [-n] COLLECTION_PATH\n"  # [#857.13] [#608.20]

    def docstring_for_help(invo):
        for line in invo.description_lines_via_docstring(_doc):
            yield line
        yield '\n'
        yield "Option:\n"
        yield "  -n    dry run\n"

    from script_lib.via_usage_line import build_invocation
    invo = build_invocation(
            sin, sout, serr, argv, usage_lines=tuple(usage_lines()),
            docstring_for_help_description=docstring_for_help)
    rc, pt = invo.returncode_or_parse_tree()
    if rc is not None:
        return rc
    dct = pt.values
    is_dry = dct.get('-n', False)
    listener = _CLI_listener(serr)
    create_collection(dct['collection_path'], listener, is_dry)
    return 33 if listener.did_error else 0


def CLI_for_abstract_schema_via_recinf_(sin, sout, serr, argv):  # 1x
    """description: derive abstract schema from recinfo lines

    example file: kiss_rdb_test/fixture-directories/2969-rec/0176-recinf-of-previous.lines
    """

    # only client at writing:
    #     kiss_rdb/storage_adapters_/rec/abstract_schema_via_recinf.py

    # this is here and not in the other file because we want it out of the
    # main flow - this will only be used in development, whereas the other
    # file will "run hot"

    # == BEGIN #history-C.1
    def usage_lines():
        yield "usage: {{prog_name}} FILE\n"
        yield "usage: <produce-recinf-lines> | {{prog_name}} -\n"  # [#857.13]

    from script_lib.via_usage_line import build_invocation
    invo = build_invocation(
            sin, sout, serr, argv, usage_lines=tuple(usage_lines()),
            docstring_for_help_description=\
            CLI_for_abstract_schema_via_recinf_.__doc__)
    rc, pt = invo.returncode_or_parse_tree()
    if rc is not None:
        return rc

    if pt.values:
        filename, = pt.values.values()
        fh = open(filename)
    else:
        fh = sin
    # == END

    listener = _CLI_listener(serr)
    from kiss_rdb.storage_adapters.rec.abstract_schema_via_recinf import \
            abstract_schema_via_recinf_lines as func
    with fh:
        abs_sch = func(fh, listener)

    if abs_sch is None:
        return 3
    w = sout.write
    for line in abs_sch.to_sexp_lines():
        w(line)
    return 0


def _CLI_listener(serr):
    def listener(*emi):
        severity, shape, *ignored, lineser = emi
        assert 'expression' == shape
        if 'error' == severity:
            listener.did_error = True
        w = serr.write
        for line in lineser():
            w(line)
            if '\n' not in line:
                w('\n')
    listener.did_error = False
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

# #history-C.2: "engine" not hand-written
# #history-C.1: spike CLI for sibling concern
# #born
