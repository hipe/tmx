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
    sct_itr = _collz(recfile)['Capability'].where(listener=listener)
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
        for html in _html_lines_for_buttons(buttons, margin, indent):
            yield html
        # == END

    render_buttons.component_label = None
    render_buttons.component_TD_element_class = 'the_buttons_tabledata'

    _add_safely(ar, '_b', render_buttons)

    from kiss_rdb.storage_adapters.html.view_via_formal_entity import \
            create_entity_renderer as func
    lines = func(fe, additional_renderers=ar)(ent)
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
    from kiss_rdb.storage_adapters.html.view_via_formal_entity import \
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


@command
def process_form(_, sout, serr, stack):
    """usage: {prog_name} RECFILE FENT *FORM_ARGS

    Description: experiment
    For CREATE *and* UPDATE wow!
    """

    # We have to do these two positionals by hand because we parse our own
    recfile = stack.pop()
    fent_name = stack.pop()
    coll = _collz(recfile)[fent_name]

    # Convert params from the weird lua-friendly (bridge-friendly) encoding
    # into a params dictionary
    # while changing key names from "snake store key" to "use key"
    form_values = {}
    while len(stack):
        k, v = stack.pop().split(':', 1)  # ..
        # (at #history-C.3, got rid of name convention conversion)
        v = v.strip()  # (Maybe supposed to happen at layer above but why trust)
        form_values[k] = v  # might clobber

    # Go
    custom_listener, WHAT = _build_listener_custom_to_this_module(serr)

    # == BEGIN break this up when the dust settles

    is_UPDATE_not_CREATE = 'ID' in form_values
    # (:#here2 experiment: determine this from this)

    if is_UPDATE_not_CREATE:
        eid = form_values.pop('ID')

        def param_direcs():
            # Assume `strip` happened above. See [#867.I] about below semantics
            for k, v in form_values.items():
                if len(v):
                    yield k, ('SET_ATTRIBUTE', v)
                else:
                    yield k, ('DELETE_ANY_EXISTING_ATTRIBUTE',)
        param_direcs = {k: v for k, v in param_direcs()}

        # (roo = result of operation)
        roo = coll.update_entity(eid, param_direcs, custom_listener)

        if roo:
            assert 'result_of_CREATE_or_UPDATE' == roo[0]
            assert 'result_of_UPDATE' == roo[1]

        # For now, high-level UI choice: for this one type of case,
        # turn a success into a failure (sort of):
        if roo and 'UPDATE_was_no_op' == roo[2]:
            WHAT[0].append("Everthing was unchanged. No values need updating.")
            roo = None

        if roo:
            assert 'UPDATE_succeeded' == roo[2]
            these_args = 'UPDATE', eid
            # (disregarding ordered prepared direcs. not nec to make redirect)
    else:
        roo = coll.create_entity(form_values, custom_listener)
        if roo:
            assert 'result_of_CREATE_or_UPDATE' == roo[0]
            assert 'result_of_CREATE' == roo[1]
            assert 'CREATE_succeeded' == roo[2]
            these_args = 'CREATE', roo[3]  # just realized this will need the new ID eventually

    if not roo:
        # If it failed, assume messages were written to WHAT and re-show form
        fe = coll.EXPERIMENTAL_HYBRIDIZED_FORMAL_ENTITY_(custom_listener)
        return _do_show_form(sout, form_values, fe, coll, custom_listener, WHAT)

    # An attempt is made to handle successes of *both* CREATE and UPDATE
    # here in one place but..

    # VERY EXPERIMENTAL complicated API for deciding where to redirect to
    action_name, use_params = coll.dataclass.AFTER_CREATE_OR_UPDATE_EXPERIMENTAL(*these_args)

    def url():
        yield '/?action=', action_name
        if not use_params:
            return
        import re
        for k, v in use_params.items():
            assert re.match('^[a-zA-Z0-9]+$', v)  # or urlencode whatever
            yield '&', k, '=', v
    url = ''.join(s for row in url() for s in row)
    # == END
    sout.write(f"redirect {url}\n")  # #here1
    return 0


@command
def show_form(_, sout, serr, recfile, fent_name, qid):
    """usage: {prog_name} RECFILE FENT_NAME QUALIFIED_EID

    Description: The dream of form generation, not yet fully realized..
    """

    coll = _collz(recfile)[fent_name]

    listener, WHAT = _build_listener_custom_to_this_module(serr)

    fe = coll.EXPERIMENTAL_HYBRIDIZED_FORMAL_ENTITY_(listener)

    kvs = _EXPERIMENTAL_form_values_via_QID(qid, fe, coll, listener)
    form_values = {k: v for k, v in kvs}

    # (experimental - wiring a listener on form GENERATION for reasons)

    return _do_show_form(sout, form_values, fe, coll, listener, WHAT)


def _do_show_form(sout, form_values, fe, coll, listener, WHAT=None):

    fattrs = fe.to_formal_attributes()

    # If it has VALUE_FACTORIES, take those attrs out
    VF_dct = getattr(coll.dataclass, 'VALUE_FACTORIES', None)
    if VF_dct:
        fattrs = _filter_out_these(fattrs, VF_dct)

    form_action = coll.dataclass.FORM_ACTION_EXPERIMENTAL
    from kiss_rdb.storage_adapters.html.form_via_formal_entity import \
            html_form_via_SOMETHING_ON_THE_MOVE_ as func
    lines = func(
        FORMAL_ATTRIBUTES=fattrs,
        action=form_action, form_values=form_values,  # #here1
        WHAT=WHAT, listener=listener)
    w = sout.write
    for line in _wrap_lines_commonly(lines):
        w(line)
    return 0


def _filter_out_these(fattrs, these):
    pool = {k: True for k in these.keys()}
    _DATACLASS_FIELD_NAME_PURPOSE = ('DATACLASS_FIELD_NAME_PURPOSE_',)
    for attr in fattrs:
        use_k = attr.identifier_for_purpose(_DATACLASS_FIELD_NAME_PURPOSE)
        if pool.pop(use_k, False):
            continue
        yield attr
    if pool:
        xx(f'oops: {tuple(pool.keys())!r}')


def _EXPERIMENTAL_form_values_via_QID(qid, fe, coll, listener):
    if ':' in qid:
        typ, rest = qid.split(':', 1)
        if 'EID' == typ:
            ent = coll.retrieve_entity(rest, listener)
            assert ent  # for now
            from kiss_rdb.storage_adapters.html.form_via_formal_entity import \
                    EXPERIMENTAL_populate_form_values_ as func
            for k, v in func(ent, fe, listener):
                yield k, v
        elif 'parent_EID' == typ:
            yield 'parent', rest
        else:
            xx(f"sad, we cannot fail: {typ!r}")
    elif 'none' == qid:
        xx("just an idea")
    else:
        xx(f"failed to parse QID: {qid!r}")


# == Listeners

def _build_listener_custom_to_this_module(serr):
    """Create listener that stores certain emissions to a custom structure.
    Purpose-built for form interaction.

    Discussion: An essential piece of this module, routing emissions either
    to the UI (essential for UX) or to the terminal (critical part of
    developing tooling, seeing the sub-process commands etc.)

    There's a wide variety of emissions across the spectrum from high-level
    to low of every variety of severity. Some may need refinement of how
    they're routed.
    """

    def custom_listener(*emi):
        return handle_emission(emi)

    def handle_emission(emi):
        if 'error' == emi[0]:
            custom_listener.did_error = True
        if 'expression' == emi[1]:
            return handle_expression(emi)
        return handle_strange_emission_shape(emi)

    def handle_strange_emission_shape(emi):
        line = "error-error: can't express " + repr(tuple(emi[:-1]))
        use_emi = 'error', 'expression', 'error_error', lambda: (line,)
        return handle_emission(use_emi)

    def handle_expression(emi):
        # (for now) All expressions targeting a specific field, show to user in UI
        if 'about_field' == emi[2]:
            return handle_expression_about_field(emi)

        # (for now) All errors, show to user in UI
        # (this will be ugly for e.g. the "error_error" above, but UI design is later or never)
        if 'error' == emi[0]:
            return show_this_non_targeted_error_to_user(emi)

        # (for now) All other emissions, just write to terminal or /dev/null
        write_info_lines_to_my_stderr_FOR_NOW(emi)

    def handle_expression_about_field(emi):
        sev, shape, _, WRONG_ATTR_KEY, cat, lineser = emi
        dct = WHAT[1]
        k = WRONG_ATTR_KEY
        if not (lis := dct.get(k)):
            dct[k] = (lis := [])
        lis.append((cat, tuple(lineser())))

    def show_this_non_targeted_error_to_user(emi):
        for line in emi[-1]():
            WHAT[0].append(line)

    def write_info_lines_to_my_stderr_FOR_NOW(emi):
        for line in emi[-1]():
            w(line)

    w = _line_writer_via_write_function(serr.write)
    WHAT = [], {}
    custom_listener.did_error = False
    return custom_listener, WHAT


def _common_listener(serr):
    write_line = _line_writer_via_write_function(serr.write)
    return _listener_via_line_receiver(write_line)


def _line_writer_via_write_function(w):
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
<link rel="stylesheet" href="vendor-themes/orderedlist-minimal-cb00000/stylesheets/styles.css">
"""

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


def _inner_html_lines_for_table(recs_itr, listener):
    from kiss_rdb.tree_toolkit import tree_dictionary_via_tree_nodes as func
    tree_dct = func(recs_itr, _childrener, listener)

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
        indent=0, childrener=_childrener,
        listener=listener)

    if not lines:
        return

    yield '<table>\n<tr><th>ID</th><th>Label</th><th>State</th><th>xx yy zz</th></tr>\n'
    for line in lines:
        yield line
    yield '</table>\n'


def _inner_html_lines_for_tree(recs_itr, listener):
    from kiss_rdb.tree_toolkit import tree_dictionary_via_tree_nodes as func
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


def _childrener(node):
    return node.children_EIDs


def _impl_state_html(rec):
    cache = _impl_state_html.cache
    state = rec.FAKE_RANDOM_implementation_status
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
    url = f'/?action=view_capability&eid={rec.EID}'  # #here1
    return f'<a href="{url}">{label_html}</a>'


def _buttons_for_capability(ent):
    params = {'action': 'edit_capability', 'entity_EID': ent.EID}
    yield 'Edit', params
    params = {'action': 'add_note', 'parent': ent.EID}
    yield 'Add Note', params


def _html_lines_for_buttons(button_pairs, margin, indent):
    for label, params in button_pairs:
        for line in _html_lines_for_button(label, params, margin, indent):
            yield line


def _html_lines_for_button(label, params, margin, indent):
    m2 = f'{margin}{indent}'
    yield f'{margin}<form method="GET" action="/">\n'  # #here1
    for k, v in params.items():
        assert '"' not in v  # one day we will understand the difference
        yield f'{m2}<input type="hidden" name="{k}" value="{v}" />\n'
    yield f'{m2}<input type="submit" value="{label}" />\n'
    yield f'{margin}</form>\n'


def _add_safely(dct, k, val):
    assert k not in dct
    dct[k] = val


# :#here1: [#872.C]: how we generate (or don't generate) urls is weird for now


def _html_escape(msg):  # (experiment in lazy loading)
    assert _html_escape.sanity
    _html_escape.sanity = False
    _this_module()._html_escape = _html_escape_function()
    return _html_escape(msg)


_html_escape.sanity = True


def _html_escape_function():
    from html import escape as func
    return func


def _collz(recfile):
    from kiss_rdb.cap_server.model_ import collections_via_recfile_ as func
    return func(recfile)


def _this_module():
    import sys
    return sys.modules[__name__]


if '__main__' == __name__:
  from sys import stdin, stdout, stderr, argv
  exit(_CLI(stdin, stdout, stderr, argv))

# #history-C.3 (can be temporary)
# #history-C.2: "engine" not hand-written CLI
# #history-C.1: change styling to "minimal" theme
# #born
