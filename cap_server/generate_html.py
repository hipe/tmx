#!/usr/bin/env -S python3 -W error::::

"""Introduction

This whole "backend" to our "web app" serves a practical purpose and a loftier,
more experimental purpose.

The practical purse is: be the frontier app of the "capabilities server".
What a capabilities server *is* is as-yet undocumented XX.

The lofier purpose: We want to see how far we can go with one of the grand
experiments of "app flow": Can you model the backend of a web-app as simply
a CLI that outputs html?
"""


# == Pattern definitions:
#    These are the special slots in our routes (url's).
#    Here is where we define their patterns, else 404.

def _pattern_definitions(placeholder_name):
    if 'EID' == placeholder_name:  # EID = entity identifier
        return '^[A-Z0-9]+$'


# == Endpoints

from app_flow.routing import begin_endpointer_EXPERIMENTAL as func
endpoint = func(_pattern_definitions)


@endpoint('/ping/')
def ping(sout, serr):
    """usage: {prog_name}

    description: ohai hello
    """
    sout.write("hello from the python backend!\n")
    return 0


@endpoint('/test/UI/')
def test_UI(sout, serr):
    """usage: {prog_name}

    description: static html page to test the stylesheet
    """

    def these():
        yield "<ul><li>list item 1</li><li>List Item 2</li></ul>\n"

    w = stdout.write
    for line in _wrap_lines_commonly(these()):
        w(line)

    return 0


@endpoint('/', GET_params={'index_style':'tree'})
def tree(sout, serr, recfile):
    """usage: {prog_name} RECFILE

    description: See the full "capabilities tree".
    (This is the predecessor to "table", which will show more information.)
    You can click into each individual capability to see more.
    (Originally based off the documentation (website) for recutils.)
    """

    return _tree_or_table(sout, serr, _inner_html_lines_for_tree, recfile)


@endpoint('/')
def table(sout, serr, recfile):
    """usage: {prog_name} RECFILE

    description: Probably the preferred index rendering, at the moment.
    """

    return _tree_or_table(sout, serr, _inner_html_lines_for_table, recfile)


def _tree_or_table(sout, serr, inner_lineser, recfile):

    write = sout.write
    listener = _common_listener(serr)
    colz = _collz(recfile)
    sct_itr = colz['Capability'].where(listener=listener)
    lines = inner_lineser(sct_itr, colz, listener)
    for line in _wrap_lines_commonly(lines):
        write(line)

    return (3 if listener.did_error else 0)


@endpoint('/capability/{EID}/')
def view_capability(sout, serr, recfile, EID):
    """usage: {prog_name} RECFILE EID

    Description: (unnecessary line until next line is sorted out)
    This includes things like XX and XX.
    """

    # == TODO imagine if this was a generic function, not specific to capability

    write = sout.write
    listener = _common_listener(serr)
    collz = _collz(recfile)
    coll = collz['Capability']
    ent = coll.retrieve_entity(EID, listener)
    if ent is None:
        return 3  # #error-with-no-output #FIXME
    # (fe = formal entity)
    fe = coll.EXPERIMENTAL_HYBRIDIZED_FORMAL_ENTITY_(listener)

    ar = {}  # ar = additional renderers

    from app_flow.common_html import build_navigation_component as func
    _add_safely(ar, '_top_nav', func(_top_nav_from_view_cap()))

    _add_safely(ar, '_THE_MIDDLE_', None)  # divide top and bottom lol

    # Build a custom renderer to render all the notes
    def render_notes(same_ent, margin, indent):
        itr = ent.RETRIEVE_NOTES(listener)
        for note in (itr or ()):
            for line in render_note(note, margin, indent):
                yield line

    render_notes.component_label = 'Notes'

    render_note = _build_note_renderer(collz, listener)

    _add_safely(ar, '_n', render_notes)

    # Build a custom renderer for the buttons
    def render_buttons(same_ent, margin, indent):
        buttons = _buttons_for_capability(ent)
        assert buttons  # one day maybe dynamically off
        # == BEGIN will move
        from app_flow.common_html import html_lines_for_buttons as func
        for html in func(buttons, margin, indent):
            yield html
        # == END

    render_buttons.component_label = None
    render_buttons.component_TD_element_class = 'the_buttons_tabledata'

    _add_safely(ar, '_b', render_buttons)

    # Experimental pipeline thing
    vp = coll.dataclass.VIEW_PIPELINES

    from app_flow.view_via_formal_entity import \
            create_entity_renderer__ as func
    _ = func(fe, additional_renderers=ar, view_pipelines=vp)
    lines = _(ent)
    for line in _wrap_lines_commonly(lines):
        write(line)

    return (3 if listener.did_error else 0)


def _build_note_renderer(collz, listener):

    coll = collz['Note']
    fe = coll.EXPERIMENTAL_HYBRIDIZED_FORMAL_ENTITY_(listener)

    # Do a complicated way of saying "render all attrs but these"
    pool = {k: None for k in ('Parent', 'Ordinal')}

    def fattrs():
        for fa in fe.to_formal_attributes():
            k = fa.column_name
            if k in pool:
                pool.pop(k)
                continue
            yield fa
        assert not pool
    fattrs = tuple(fattrs())

    # Let's try this
    from app_flow.view_via_formal_entity import \
            component_renderer_via_formal_attribute as func
    component_renderers = tuple(func(fa) for fa in fattrs)
    def render_note(ent, margin, indent):
        yield "<!-- WOW BEGIN A NOTE -->\n"
        m2 = f'{margin}{indent}'
        first = True
        for cr in component_renderers:
            if first:
                first = False
            else:
                yield f'{margin}<br>\n'  # EEK. probably never see
            for line in cr(ent, m2, indent):
                yield line
        yield "<!-- WOW END A NOTE -->\n"
    return render_note


@endpoint('/capability/{EID}/edit/', http_method='POST')
def edit_capability(sout, serr, recfile, eid, form_args):
    """usage: {prog_name} RECFILE EID *FORM_ARGS"""

    return _process_form(
            sout, serr, form_args=form_args,
            qualified_EID=('updatee_EID', eid), verb_stem='UPDATE',
            form_action=f'/capability/{eid}/edit/',  # #here6
            fent_name='Capability', recfile=recfile)


@endpoint('/capability/{EID}/notes/add/', http_method='POST')
def add_note(sout, serr, recfile, eid, form_args):
    """usage: {prog_name} RECFILE EID *FORM_ARGS"""

    return _process_form(
            sout, serr, form_args=form_args,
            qualified_EID=('parent_EID', eid), verb_stem='CREATE',
            form_action=f'/capability/{eid}/notes/add/',  # #here6
            fent_name='Note', recfile=recfile)


def _process_form(
        sout, serr, form_args, qualified_EID, verb_stem,
        form_action, fent_name, recfile):

    """
    Description: experiment
    For CREATE *and* UPDATE wow!
    """

    def formal_entityer():
        return coll.EXPERIMENTAL_HYBRIDIZED_FORMAL_ENTITY_(listener)

    coll = _collz(recfile)[fent_name]

    from app_flow.forming import process_form, build_UI_wired_listener

    listener = build_UI_wired_listener(serr)

    return process_form(
            out=sout, qualified_EID=qualified_EID, verb_stem=verb_stem,
            form_args=form_args, form_action=form_action,
            line_nester=_wrap_lines_commonly, label_for_CANCEL=_label_for_CANCEL,
            formal_entityer=formal_entityer,
            collection=coll, listener=listener)


@endpoint('/capability/{EID}/edit/')
def _(sout, serr, recfile, eid):
    """usage: {prog_name} RECFILE EID"""

    return _show_form(
            sout, serr, qualified_EID=('updatee_EID', eid), verb_stem='UPDATE',
            form_action=f'/capability/{eid}/edit/',  # #here6
            fent_name='Capability', recfile=recfile)


@endpoint('/capability/{EID}/notes/add/')
def _(sout, serr, recfile, eid):
    """usage: {prog_name} RECFILE EID"""

    return _show_form(
            sout, serr, qualified_EID=('parent_EID', eid), verb_stem='CREATE',
            form_action=f'/capability/{eid}/notes/add/',  # #here6
            fent_name='Note', recfile=recfile)


def _show_form(
        sout, serr, qualified_EID, verb_stem,
        form_action, fent_name, recfile):
    """
    Description: The dream of form generation, not yet fully realized..
    """

    coll = _collz(recfile)[fent_name]

    from app_flow.forming import show_form, build_UI_wired_listener
    listener = build_UI_wired_listener(serr)

    fe = coll.EXPERIMENTAL_HYBRIDIZED_FORMAL_ENTITY_(listener)
    # (experimental - wiring a listener on form GENERATION for reasons)
    return show_form(
        out=sout, qualified_EID=qualified_EID, verb_stem=verb_stem,
        form_action=form_action,
        line_nester=_wrap_lines_commonly, label_for_CANCEL=_label_for_CANCEL,
        formal_entity=fe, collection=coll, listener=listener)


def _common_listener(serr):
    write_line = _line_writer_via_write_function(serr.write)
    return _listener_via_line_receiver(write_line)


def _line_writer_via_write_function(w):  # there is an at-writing copy-paste
    def write_line(line):
        w(line)
        if 0 == len(line) or '\n' != line[-1]:
            w('\n')
    return write_line


def _listener_via_line_receiver(recv_line):
    def listener(*emission):
        *chan, payloader = emission
        if 'error' == chan[0]:
            listener.did_error = True

        if 'expression' == chan[1]:
            for line in payloader():
                recv_line(line)
        else:
            recv_line(repr(chan))

    listener.did_error = False  # #watch-the-world-burn
    return listener


# == HTML lol

def _wrap_lines_commonly(lines):
    # Not caring about templates or frameworks for now

    if not lines:  # prettier for caller
        return

    yield """<!doctype html>\n<head>\n<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="chrome=1">
<title>Minimal by Steve Smith</title>
<link rel="stylesheet" href="/vendor-themes/orderedlist-minimal-cb00000/stylesheets/styles.css">
"""
    # (above: absolute not relative link when urls got deep #history-C.5)

    if False:  # don't waste the network request if we're not using it
        yield """
<link rel="stylesheet" href="vendor-themes/orderedlist-minimal-cb00000/stylesheets/pygment_trac.css">
"""

    yield """
<style type="text/css">
td.the_buttons_tabledata { text-align: center; }
.the_buttons_tabledata > form { display: inline; }
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


def _inner_html_lines_for_table(recs_itr, colz, listener):
    from app_flow.tree_toolkit import tree_dictionary_via_tree_nodes as func
    tree_dct = func(recs_itr, _childrener, listener)

    if 0 == len(tree_dct):
        return  # ..

    pool = colz['Note'].dataclass.SPECIAL_REPORT()

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

        num = pool.pop(rec.EID, None)
        if num is None:
            other = ''
        elif 1 == num:
            other = '1 note'
        else:
            other = f'{num} notes'

        return ('<tr>'
            f'<td>{rec.EID}</td>'
            f'<td>{label}</td>'
            f'<td>{impl_state}</td>'
            f'<td>{other}</td>'
            '</tr>\n')

    from app_flow.tree_toolkit import lines_via_tree_dictionary as func
    lines = func(
        tree_dct,
        branch_node_opening_line_by=table_row_for,
        branch_node_closing_line_string=None,
        leaf_node_line_by=table_row_for,
        indent=0, childrener=_childrener,
        listener=listener)

    if not lines:
        return

    yield '<table>\n<tr><th>ID</th><th>Label</th><th>State</th><th>&#35; notes</th></tr>\n'
    for line in lines:
        yield line

    if pool:
        def lines():
            yield f"warning: orphan note(s): {tuple(pool.keys())!r}"
        listener('warning', 'expression', 'orphan_notes', lines)
    yield '</table>\n'


def _inner_html_lines_for_tree(recs_itr, _colz_NOT_USED, listener):
    from app_flow.tree_toolkit import tree_dictionary_via_tree_nodes as func
    tree_dct = func(recs_itr, _childrener, listener)
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

    from app_flow.tree_toolkit import lines_via_tree_dictionary as func
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


def _childrener(node):
    return node.children_EIDs


def _impl_state_html(rec):
    cache = _impl_state_html.cache
    state = rec.implementation_status
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


# == Nav links

def _link_and_label_of_record(rec):
    label_html = _html_escape(rec.label)
    url = f'/capability/{rec.EID}/'  # #here1:route-name:view_capability
    return f'<a href="{url}">{label_html}</a>'


_label_for_CANCEL = '⬅️  Cancel'


def _top_nav_from_view_cap():
    yield '⬅️  Index', ('nav_link_url', '/')


# == Buttons

def _buttons_for_capability(ent):
    yield 'Edit', ('button_url', f'/capability/{ent.EID}/edit/')
    yield 'Add Note', ('button_url', f'/capability/{ent.EID}/notes/add/')

# ==

def _add_safely(dct, k, val):
    assert k not in dct
    dct[k] = val


# :#here6: rebuild the same url that was used in our invocation ick
#   - Every one of these is also a #here1
# :#here1: #wish [#872.C]: The dream of fully two-directional routes:
#   - While doing #history-C.5 we re-invented the utility (alla rails, but for
#     us a vaporware nice-to-have) of having each route available to be
#     generated and exposed thru a simple, unique name. We're saving that for
#     a later refactor.
#     Fow now, we create each url "manually" (and with duplication).
#   - Every `button_url` and `nav_link_url` falls under this tag scope too.


# == BEGIN experiment in lazy-loading

def _html_escape(msg):  # (experiment in lazy loading)
    assert _html_escape.sanity
    _html_escape.sanity = False
    _this_module()._html_escape = _html_escape_function()
    return _html_escape(msg)


_html_escape.sanity = True


def _html_escape_function():
    from html import escape as func
    return func


def _this_module():
    import sys
    return sys.modules[__name__]

# == END experiment in lazy-loading


def _collz(recfile):
    from cap_server.model_ import my_collections_via_main_recfile_ as func
    return func(recfile)


if '__main__' == __name__:
    from sys import stdin, stdout, stderr, argv
    from app_flow.server_CLI import web_app_as_CLI_EXPERIMENTAL as func
    rc = func(
        stdin, stdout, stderr, argv,
        endpoint.consume_params_for_matcher_call_EXPERIMENTAL)
    if isinstance(rc, int):
        exit(rc)
    stdout.write(f"(oops, expected int had {type(rc)} for returncode)\n")

# #history-C.7 form processing and custom listeners are abstracted away
# #history-C.6 a great exodous. no more command splay, no more help (for now)
# #history-C.5 overhaul to parse it the new way with "send URL back"
# #history-C.4 (as referenced)
# #history-C.3 (can be temporary)
# #history-C.2: "engine" not hand-written CLI
# #history-C.1: change styling to "minimal" theme
# #born
