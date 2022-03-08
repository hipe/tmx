#!/usr/bin/env -S python3 -W error::::

def _CLI(_, sout, serr, argv):

    def show_usage():
        serr.write(f"usage: {prog_name()} RECFILE\n")

    def prog_name():
        from os.path import basename
        return basename(raw_prog_name)

    stack = list(reversed(argv))
    raw_prog_name = stack.pop()

    if 0 == (leng := len(stack)):
        serr.write("missing argument(s)\n")
        return 3

    import re
    rx = re.compile(r'^--?h(?:e(?:lp?)?)?\Z')
    if rx.match(stack[0]) or (1 < leng and rx.match(stack[-1])):
        show_usage()
        serr.write('\n')
        serr.write("description: this thing is experimental.\n")
        serr.write('\n')
        serr.write("example recfile: "
        "kiss_rdb_test/fixture-directories/2969-rec/0150-native-capabilities.rec\n"
        )
        return 0

    recfile = stack.pop()
    if 0 < len(stack):
        serr.write("too many arguments. expecting one.\n")
        return 3

    def listener(*emission):
        *chan, payloader = emission
        if 'error' == chan[0]:
            listener.did_error = True

        if 'expression' == chan[1]:
            for line in payloader():
                serr.write(line)
                if 0 == len(line) or '\n' != line[-1]:
                    serr.write('\n')
        else:
            serr.write(repr(chan))

    listener.did_error = False  # #watch-the-world-burn

    if isinstance(recfile, str):
        from kiss_rdb.storage_adapters_.rec import OPEN_PROCESS as func
        opened = func(recfile, listener)
    else:
        from contextlib import nullcontext
        opened = nullcontext(recfile)

    write = sout.write
    with opened as lines:
        for line in _html_document_lines_via_recfile_lines(lines, listener):
            write(line)

    return (3 if listener.did_error else 0)


def _html_document_lines_via_recfile_lines(lines, listener):
    # We don't love this "style" but we're really trying to avoid any
    # copy-paste structure from GNU recutils documentation (for now):
    # https://www.gnu.org/software/recutils/manual/index.html
    yield '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">\n'
    yield "<html>\n<head>\n<title>Xyzzy: Some Title</title>\n"

    # Crazy hack of making these CSS lines look inline
    yield '<style type="text/css">\n<!--\n'
    from os.path import dirname as dn, join as jn
    here = jn(dn(__file__), 'doc-root', 'assets', 'css', 'style.css')
    with open(here) as css_lines:
        itr = iter(css_lines)
        for line in itr:
            if "\n" == line:
                break
        for line in itr:
            if "\n" == line:
                break
            yield line

    yield '-->\n</style>\n</head>\n<body lang="en">\n'
    yield '<div class="contents">\n'

    # Core lines
    for line in _core_html_lines(lines, listener):
        yield line

    yield '</div>\n</body>\n</html>\n'


def _core_html_lines(lines, listener):
    from kiss_rdb.cap_server.model_ import \
            capability_record_structures_via_lines as func
    recs_itr = func(lines, listener)
    from kiss_rdb.tree_toolkit import tree_dictionary_via_tree_nodes as func
    tree_dct = func(recs_itr, listener)
    if tree_dct is None:
        return

    def branch_node_opening_line_for(rec):
        label_html = html_escape(rec.label)
        link_html = label_html  # write me soon
        return f'{link_html}{branch_node_opening_line_string}'

    branch_node_opening_line_string = '<ul class="no-bullet">\n'
    branch_node_closing_line_string = "</ul>\n"

    def leaf_node_line_for(rec):
        label_html = html_escape(rec.label)
        link_html = label_html  # write me soon
        return f'<li>{link_html}</li>\n'

    from html import escape as html_escape

    from kiss_rdb.tree_toolkit import lines_via_tree_dictionary as func
    lines = func(
        tree_dct,
        branch_node_opening_line_by=branch_node_opening_line_for,
        branch_node_closing_line_string=branch_node_closing_line_string,
        leaf_node_line_by=leaf_node_line_for)

    yield branch_node_opening_line_string
    for line in lines:
        yield line
    yield branch_node_closing_line_string


if '__main__' == __name__:
  from sys import stdout, stderr, argv
  exit(_CLI(None, stdout, stderr, argv))

# #born
