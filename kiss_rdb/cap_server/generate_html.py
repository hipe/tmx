#!/usr/bin/env -S python3 -W error::::

from script_lib.docstring_based_command import build_new_decorator as _BND

def _CLI(_, sout, serr, argv):

    def show_usage():
        serr.write(f"usage: {prog_name()} COMMAND [args..]\n")

    def prog_name():
        from os.path import basename
        return basename(raw_prog_name)

    stack = list(reversed(argv))
    raw_prog_name = stack.pop()

    e = serr.write

    if 0 == (leng := len(stack)):
        e("expecting COMMAND\n")
        return 3

    # Maybe show toplevel help
    import re
    help_rx = re.compile(r'^--?h(?:e(?:lp?)?)?\Z')
    if help_rx.match(stack[-1]):
        show_usage()
        e('\n')
        e('commands:\n')
        maxwidth = 0
        for fname in _commands.command_keys():
            width = len(fname)
            if maxwidth < width:
                maxwidth = width
        fmt = f'  %{maxwidth}s  %s\n'
        for fname in _commands.command_keys():
            e(fmt % (fname, _commands[fname].single_line_description))
        e('\n')
        e("example recfile: "
        "kiss_rdb_test/fixture-directories/2969-rec/0150-native-capabilities.rec\n"
        )
        return 0

    # Resolve the command by name
    command_arg = stack.pop()
    cmd = _commands.get(command_arg)
    if not cmd:
        e(f"not a command: {command_arg!r}\n")
        return 3

    # Maybe show help for a specific command
    if len(stack) and help_rx.match(stack[0]):
        for line in cmd.build_doc_lines(prog_name()):
            e(line)
        return 0

    # Validate & send the parameters to the command func
    if cmd.has_only_positional_args:
        if (rc := cmd.validate_positionals(stderr, stack, prog_name)):
            return rc
        return cmd.function(_, sout, serr, *reversed(stack))
    return cmd.function(_, sout, serr, stack)


command = _BND()
_commands = command  # when we use it as a collection and not a decorator

@command
def ping(_, sout, serr):
    """usage: {prog_name}

    description: ohai hello
    """
    sout.write("hello from the python backend!\n")
    return 0


@command
def index(_, sout, serr, recfile):
    """usage: {prog_name} RECFILE

    description: See the full "capabilities tree".
    You can click into each individual capability to see more.
    (Originally based off the documentation (website) for recutils.)
    """

    write = sout.write
    listener = _common_listener(serr)

    from kiss_rdb.cap_server.model_ import TRAVERSE_COLLECTION as func
    sct_itr = func(recfile, listener)
    lines = _inner_html_lines_for_index(sct_itr, listener)
    for line in _wrap_lines_commonly(lines):
        write(line)

    return (3 if listener.did_error else 0)


@command
def view_capability(_, sout, serr, recfile, EID):
    """usage: {prog_name} RECFILE EID

    description: View the details of an individual capability.
    This includes things like XX and XX.
    """

    write = sout.write
    listener = _common_listener(serr)

    from kiss_rdb.cap_server.model_ import RETRIEVE_ENTITY as func
    ent = func(recfile, EID, listener)
    if ent is None:
        return 3  # #error-with-no-output #FIXME

    lines = _inner_html_lines_for_view(ent, listener)
    for line in _wrap_lines_commonly(lines):
        write(line)

    return (3 if listener.did_error else 0)


def _common_listener(serr):
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
    return listener


def _wrap_lines_commonly(lines):
    # We don't love this "style" but we're really trying to avoid any
    # copy-paste structure from GNU recutils documentation (for now):
    # https://www.gnu.org/software/recutils/manual/index.html

    if not lines:  # prettier for caller
        return

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

    for line in lines:
        yield line

    yield '</div>\n</body>\n</html>\n'


def _inner_html_lines_for_view(sct, listener):
    from html import escape as h
    yield "<table>\n"
    yield f"<tr><th>Label</th><td>{h(sct.label)}</td></tr>\n"
    yield f"<tr><th>ID</th><td>{h(sct.EID)}</td></tr>\n"
    pcs = []
    itr = iter(sct.children or ())
    first = None
    for first in itr:
        pcs.append(h(first))
        break
    for nonfirst in itr:
        pcs.append('&nbsp;')
        pcs.append(h(nonfirst))
    if pcs:
        val = ''.join(pcs)
        yield f"<tr><th>children</th><td>{val}</td></tr>\n"
    yield "</table>\n"


def _inner_html_lines_for_index(recs_itr, listener):
    from kiss_rdb.tree_toolkit import tree_dictionary_via_tree_nodes as func
    tree_dct = func(recs_itr, listener)
    if 0 == len(tree_dct):
        return  # ..

    def branch_node_opening_line_for(rec):
        label_html = html_escape(rec.label)
        link_html = label_html  # write me soon
        return f'{link_html}{branch_node_opening_line_string}'

    branch_node_opening_line_string = '<ul class="no-bullet">\n'
    branch_node_closing_line_string = "</ul>\n"

    def leaf_node_line_for(rec):
        label_html = html_escape(rec.label)
        url = f'/?action=view_capability&eid={rec.EID}'
        link_html = f'<a href="{url}">{label_html}</a>'
        return f'<li>{link_html}</li>\n'

    from html import escape as html_escape

    from kiss_rdb.tree_toolkit import lines_via_tree_dictionary as func
    lines = func(
        tree_dct,
        branch_node_opening_line_by=branch_node_opening_line_for,
        branch_node_closing_line_string=branch_node_closing_line_string,
        leaf_node_line_by=leaf_node_line_for,
        listener=listener)

    if not lines:
        return

    yield branch_node_opening_line_string
    for line in lines:
        yield line
    yield branch_node_closing_line_string


if '__main__' == __name__:
  from sys import stdout, stderr, argv
  exit(_CLI(None, stdout, stderr, argv))

# #born
