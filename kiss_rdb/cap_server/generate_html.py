#!/usr/bin/env -S python3 -W error::::

from script_lib.docstring_based_command import build_new_decorator as _BND


def _CLI(sin, sout, serr, argv):
    """backend endpoints for our capability server,

    exposed (here) as CLI commands. Pass "-h" to the specific commands.
    """

    # == BEGIN #history-C.2

    def usage_lines():
        yield "usage: {{prog_name}} COMMAND [command args..]\n"  # #[#857.13]

    def docstring_for_help_description(invo):
        for line in invo.description_lines_via_docstring(_CLI.__doc__):
            yield line
        for line in lines_for_description_of_commands():
            yield line

    import re
    help_rx = re.compile(r'^--?h(?:e(?:lp?)?)?\Z')

    def lines_for_description_of_commands():
        lines = []
        e = lines.append
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
        "kiss-rdb-doc/recfiles/857.12.recutils-capabilities.rec\n"
        )
        return lines

    from script_lib.via_usage_line import build_invocation
    invo = build_invocation(
            sin, sout, serr, argv,
            usage_lines=usage_lines(),
            docstring_for_help_description=docstring_for_help_description)

    rc, pt = invo.returncode_or_parse_tree()
    if rc is not None:
        return rc
    dct = pt.values
    stack = invo.argv_stack
    prog_name = lambda: invo.program_name
    del pt
    command_arg = dct.pop('command')
    assert not dct

    # ==

    e = serr.write

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
    _ = None  # (historic value of stderr)
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
def test_UI(_, sout, serr):
    """usage: {prog_name}

    description: static html page to test the stylesheet
    """

    def these():
        yield "<ul><li>list item 1</li><li>List Item 2</li></ul>\n"

    w = stdout.write
    for line in _wrap_lines_commonly(these()):
        w(line)

    return 0


@command
def tree(_, sout, serr, recfile):
    """usage: {prog_name} RECFILE

    description: See the full "capabilities tree".
    (This is the predecessor to "table", which will show more information.)
    You can click into each individual capability to see more.
    (Originally based off the documentation (website) for recutils.)
    """

    return _tree_or_table(sout, serr, _inner_html_lines_for_tree, recfile)


@command
def table(_, sout, serr, recfile):
    """usage: {prog_name} RECFILE

    description: Probably the preferred index rendering, at the moment.
    """

    return _tree_or_table(sout, serr, _inner_html_lines_for_table, recfile)


def _tree_or_table(sout, serr, inner_lineser, recfile):

    write = sout.write
    listener = _common_listener(serr)

    from kiss_rdb.cap_server.model_ import TRAVERSE_COLLECTION as func
    sct_itr = func(recfile, listener)
    lines = inner_lineser(sct_itr, listener)
    for line in _wrap_lines_commonly(lines):
        write(line)

    return (3 if listener.did_error else 0)


@command
def view_capability(_, sout, serr, recfile, EID):
    """usage: {prog_name} RECFILE EID

    Description: (unnecessary line until next line is sorted out)
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
    # Not caring about templates or frameworks for now

    if not lines:  # prettier for caller
        return

    yield """<!doctype html>\n<head>\n<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="chrome=1">
<title>Minimal by Steve Smith</title>
<link rel="stylesheet" href="vendor-themes/orderedlist-minimal-cb00000/stylesheets/styles.css">
"""

    if False:  # don't waste the network request if we're not using it
        yield """
<link rel="stylesheet" href="vendor-themes/orderedlist-minimal-cb00000/stylesheets/pygment_trac.css">
"""

    yield """
<style type="text/css">
.impl-state-unknown     { background-color: none; }
.impl-state-wont        { background-color: lightgray; }
.impl-state-maybe       { background-color: lightblue; }
.impl-state-implemented { background-color: lightgreen; }
</style>
<meta name="viewport" content="width=device-width">
<!--[if lt IE 9]>
<script src="//html5shiv.googlecode.com/svn/trunk/html5.js"></script>
<![endif]-->
</head>
<body>
<div class="wrapper">\n"""

    for line in lines:
        yield line

    yield '</div>\n</body>\n</html>\n'


def _inner_html_lines_for_view(ent, listener):
    from html import escape as h
    yield "<table>\n"
    yield f"<tr><th>Label</th><td>{h(ent.label)}</td></tr>\n"
    yield f"<tr><th>ID</th><td>{h(ent.EID)}</td></tr>\n"
    pcs = []
    itr = iter(ent.children or ())
    first = next(itr, None)
    if first:
        pcs.append(h(first))
    for nonfirst in itr:
        pcs.append('&nbsp;')
        pcs.append(h(nonfirst))
    if pcs:
        val = ''.join(pcs)
        yield f"<tr><th>children</th><td>{val}</td></tr>\n"

    itr = ent.RETRIEVE_NOTES(listener)
    if itr:
        for note in itr:
            yield f"<tr><th>note</th><td>{_html_escape(note.body)}</td></tr>\n"
    yield "</table>\n"


def _inner_html_lines_for_table(recs_itr, listener):
    from kiss_rdb.tree_toolkit import tree_dictionary_via_tree_nodes as func
    tree_dct = func(recs_itr, listener)

    if 0 == len(tree_dct):
        return  # ..

    def table_row_for(rec, depth):
        # Discussion about this current hack for indenting the tree nodes:
        # A CSS way (or something) would be nicer.
        # we googled "unicode wide space" and found:
        # "U+3000 IDEOGRAPHIC SPACE The width of ideographic ( CJK ) characters"
        # The root node is the only node in the tree with a depth of 0, and this
        # node is not itself traversed, or represented directly on screen.
        # As such, '1' is the shallowest depth and we want nodes of the
        # shalloest depth to have no indent at all, hence the subtract 1 below.

        margin = ''.join('&#12288;' for _ in range(0, depth-1))
        label = f'{margin} {_link_and_label_of_record(rec)}'
        impl_state = _impl_state_html(rec)
        other = '(notes here eventually..)'

        return ('<tr>'
            f'<td>{rec.EID}</td>'
            f'<td>{label}</td>'
            f'<td>{impl_state}</td>'
            f'<td>{other}</td>'
            '</tr>\n')

    from kiss_rdb.tree_toolkit import lines_via_tree_dictionary as func
    lines = func(
        tree_dct,
        branch_node_opening_line_by=table_row_for,
        branch_node_closing_line_string=None,
        leaf_node_line_by=table_row_for,
        indent=0,
        listener=listener)

    if not lines:
        return

    yield '<table>\n<tr><th>ID</th><th>Label</th><th>State</th><th>xx yy zz</th></tr>\n'
    for line in lines:
        yield line
    yield '</table>\n'


def _inner_html_lines_for_tree(recs_itr, listener):
    from kiss_rdb.tree_toolkit import tree_dictionary_via_tree_nodes as func
    tree_dct = func(recs_itr, listener)
    if 0 == len(tree_dct):
        return  # ..

    def branch_node_opening_line_for(rec, _depth):
        label_html = _html_escape(rec.label)
        link_html = label_html  # write me soon
        return f'{link_html}{branch_node_opening_line_string}'

    branch_node_opening_line_string = '<ul class="no-bullet">\n'
    branch_node_closing_line_string = "</ul>\n"

    def leaf_node_line_for(rec, _depth):
        link_html = _link_and_label_of_record(rec)
        return f'<li>{link_html}</li>\n'

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


def _impl_state_html(rec):
    cache = _impl_state_html.cache
    state = rec.implementation_state
    h = cache.get(state)
    if h is not None:
        return h
    css_class, state_label = _express_implementation_state(state)
    h = ''.join(
        (f"<span class='{css_class}'>", _html_escape(state_label), '</span>'))
    cache[state] = h
    return h


_impl_state_html.cache = {}


def _express_implementation_state(state):
    if state is None:
        return 'impl-state-unknown', 'unknown'

    if 'might_implement_eventually' == state:
        return 'impl-state-maybe', 'maybe eventually'

    if 'wont_implement_or_not_applicable' == state:
        return 'impl-state-wont', "won't implement"

    if 'is_implemented' == state:
        return 'impl-state-implemented', 'done'
    xx(f"unknown implmentation state: {state!r}")


def _link_and_label_of_record(rec):
    label_html = _html_escape(rec.label)
    url = f'/?action=view_capability&eid={rec.EID}'
    return f'<a href="{url}">{label_html}</a>'


def _html_escape(msg):  # (experiment in lazy loading)
    assert _html_escape.sanity
    _html_escape.sanity = False

    from html import escape as f

    import sys
    sys.modules[__name__]._html_escape = f
    return _html_escape(msg)


_html_escape.sanity = True


if '__main__' == __name__:
  from sys import stdin, stdout, stderr, argv
  exit(_CLI(stdin, stdout, stderr, argv))

# #history-C.2: "engine" not hand-written CLI
# #history-C.1: change styling to "minimal" theme
# #born
