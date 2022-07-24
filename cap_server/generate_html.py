#!/usr/bin/env -S python3 -W error::::

"""Introduction

This whole "backend" to our "web app" serves a practical purpose and a loftier,
more experimental purpose.

The practical purse is: be the frontier app of the "capabilities server".
What a capabilities server *is* is as-yet undocumented XX.

The lofier purpose: We want to see how far we can go with one of the grand
experiments of "app flow": Can you model the backend of a web-ap as simply
a CLI that outputs html?
"""


# == Pattern definitions:
#    These are the special slots in our routes (url's).
#    Here is where we define their patterns, else 404.

def _pattern_definitions(placeholder_name):
    if 'EID' == placeholder_name:
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

    _add_safely(ar, '_top_nav', _build_top_nav(_top_nav_from_view_cap()))

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
        for html in _html_lines_for_buttons(buttons, margin, indent):
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

    return _do_process_form(
            sout, serr, form_args=form_args,
            qualified_EID=('updatee_EID', eid), verb_stem='UPDATE',
            form_action=f'/capability/{eid}/edit/',  # #here6
            fent_name='Capability', recfile=recfile)


@endpoint('/capability/{EID}/notes/add/', http_method='POST')
def add_note(sout, serr, recfile, eid, form_args):
    """usage: {prog_name} RECFILE EID *FORM_ARGS"""

    return _do_process_form(
            sout, serr, form_args=form_args,
            qualified_EID=('parent_EID', eid), verb_stem='CREATE',
            form_action=f'/capability/{eid}/notes/add/',  # #here6
            fent_name='Note', recfile=recfile)


def _do_process_form(
        sout, serr, form_args, qualified_EID, verb_stem,
        form_action, fent_name, recfile):

    """
    Description: experiment
    For CREATE *and* UPDATE wow!
    """

    coll = _collz(recfile)[fent_name]

    # Go
    custom_listener, ui_msgs = MOVING_build_listener_custom_to_this_module(serr)

    # == BEGIN break this up when the dust settles

    parent_UI_node_url = _parent_UI_node_url_via_form_action(form_action)

    def same_nav_links():
        return _form_nav_links_via(parent_UI_node_url)

    if 'UPDATE' == verb_stem:
        typ, eid = qualified_EID
        assert 'updatee_EID' == typ

        def param_direcs():
            # Assume `strip` happened above. See [#867.I] about below semantics
            for k, v in form_args.items():
                if len(v):
                    yield k, ('SET_ATTRIBUTE', v)
                else:
                    yield k, ('DELETE_ANY_EXISTING_ATTRIBUTE',)
        param_direcs = {k: v for k, v in param_direcs()}

        """Filter out these notices when the value is unchanged.
        (If we were a CLI we would want the notice, but, the nature of
        forms is such that the whole "comb" is submitted even if your
        intention is only to change certain attributes)
        """
        def use_listener(*emi):
            if ( 'about_field' == emi[2] and
                 'attribute_is_already_this_value' == emi[4] ):
               return
            custom_listener(*emi)

        # (roo = result of operation)
        roo = coll.update_entity(eid, param_direcs, use_listener)

        if roo:
            assert 'result_of_CREATE_or_UPDATE' == roo[0]
            assert 'result_of_UPDATE' == roo[1]

        # For now, high-level UI choice: for this one type of case,
        # turn a success into a failure (sort of):
        if roo and 'UPDATE_was_no_op' == roo[2]:
            ui_msgs.general.append(
                    "Everything was unchanged. No values need updating.")
            roo = None

        if roo:
            assert 'UPDATE_succeeded' == roo[2]
            these_args = 'UPDATE', eid
            # (disregarding ordered prepared direcs. not nec to make redirect)
        else:
            top_nav_links = same_nav_links()
    else:
        assert 'CREATE' == verb_stem
        # The incoming form args need these mutations to be CREATE params:
        #   - Add 'parent' (EID) (which was embedded in the url) #here7

        typ, eid = qualified_EID
        assert 'parent_EID' == typ
        assert 'parent' not in form_args
        form_args['parent'] = eid
        roo = coll.create_entity(form_args, custom_listener)
        if roo:
            assert 'result_of_CREATE_or_UPDATE' == roo[0]
            assert 'result_of_CREATE' == roo[1]
            assert 'CREATE_succeeded' == roo[2]
            these_args = 'CREATE', roo[3]  # just realized this will need the new ID eventually
        else:
            top_nav_links = same_nav_links()
            form_args.pop('parent')
            # (don't put this in hidden form arg in repop #here7)

    if not roo:
        # If it failed, assume messages were written to ui_msgs and re-show form

        assert top_nav_links
        additional_renderers = {}
        additional_renderers['_top_nav'] = _build_top_nav(top_nav_links)
        additional_renderers['_THE_MIDDLE_'] = None

        fe = coll.EXPERIMENTAL_HYBRIDIZED_FORMAL_ENTITY_(custom_listener)
        return _do_show_form(
                sout, form_args, form_action, fe, coll, custom_listener,
                additional_renderers, ui_msgs)

    # An attempt is made to handle successes of *both* CREATE and UPDATE
    # here in one place but..

    # == END
    sout.write(f"redirect {parent_UI_node_url}\n")
    return 0


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

    listener, ui_msgs = MOVING_build_listener_custom_to_this_module(serr)

    fe = coll.EXPERIMENTAL_HYBRIDIZED_FORMAL_ENTITY_(listener)

    # (experimental - wiring a listener on form GENERATION for reasons)

    # == BEGIN NEW
    if 'UPDATE' == verb_stem:
        typ, eid = qualified_EID
        assert 'updatee_EID' == typ
        ent = coll.retrieve_entity(eid, listener)
        assert ent  # for now
        from app_flow.form_via_formal_entity import \
                EXPERIMENTAL_populate_form_values as func
        outgoing_form_values = {k: v for k, v in func(ent, fe, listener)}
        # #here7: we no longer want the EID in the hidden form vars
        me_go_away = outgoing_form_values.pop('ID')
        assert eid == me_go_away
    else:
        assert 'CREATE' == verb_stem
        # (Before #history-C.5 parent EID was in hidden form field. now in url)
        typ, eid = qualified_EID
        del eid
        outgoing_form_values = {}  # _empty_dict
        # outgoing_form_values = {'parent': eid}

    parent_UI_node_url = _parent_UI_node_url_via_form_action(form_action)
    # (#todo this is redundant with the only other call of it & could be pushed down)

    additional_renderers = {
        '_top_nav': _build_top_nav(_form_nav_links_via(parent_UI_node_url)),
        '_THE_MIDDLE_': None,
    }

    return _do_show_form(
            sout, outgoing_form_values, form_action, fe, coll, listener,
            additional_renderers, ui_msgs)


def _do_show_form(
        sout, form_args, form_action, fe, coll, listener,
        additional_renderers=None, ui_msgs=None):

    assert '/' == form_action[0]  # should be url tail

    # If it has VALUE_FACTORIES, take those attrs out
    # (we could put this knowledge in the downstream function, but why)
    fattrs = fe.to_formal_attributes()
    VF_dct = getattr(coll.dataclass, 'VALUE_FACTORIES', None)
    if VF_dct:
        fattrs = WILL_MOVE_filter_out_these(fattrs, VF_dct)

    def model_class_via_name(fent_name):
        _ = coll.collectioner[fent_name]  # key error okay
        return _.dataclass

    from app_flow.form_via_formal_entity import \
            html_form_via_SOMETHING_ON_THE_MOVE as func
    lines = func(
        FORMAL_ATTRIBUTES=fattrs,
        action=form_action, form_values=form_args,
        model_class_via_name=model_class_via_name,
        additional_renderers=additional_renderers,
        ui_msgs=ui_msgs, listener=listener)
    w = sout.write
    for line in _wrap_lines_commonly(lines):
        w(line)
    return 0


def _form_nav_links_via(parent_UI_node_url):
    yield _label_for_CANCEL, ('nav_link_url', parent_UI_node_url)


def _parent_UI_node_url_via_form_action(form_action):
    from app_flow.routing import \
        parent_UI_node_url_via_form_action_EXPERIMENTAL as func
    return func(form_action)
    # (#here1:route-name:view_capability)


def WILL_MOVE_filter_out_these(fattrs, these):
    pool = {k: True for k in these.keys()}
    _DATACLASS_FIELD_NAME_PURPOSE = ('DATACLASS_FIELD_NAME_PURPOSE_',)
    for attr in fattrs:
        use_k = attr.identifier_for_purpose(_DATACLASS_FIELD_NAME_PURPOSE)
        if pool.pop(use_k, False):
            continue
        yield attr
    if pool:
        xx(f'oops: {tuple(pool.keys())!r}')


# == Listeners

def MOVING_build_listener_custom_to_this_module(serr):
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
        dct = ui_msgs.specific
        k = WRONG_ATTR_KEY
        if not (lis := dct.get(k)):
            dct[k] = (lis := [])
        lis.append((cat, tuple(lineser())))

    def show_this_non_targeted_error_to_user(emi):
        for line in emi[-1]():
            ui_msgs.general.append(line)

    def write_info_lines_to_my_stderr_FOR_NOW(emi):
        for line in emi[-1]():
            w(line)

    w = _line_writer_via_write_function(serr.write)
    ui_msgs = _MOVING_UI_Messages()
    custom_listener.did_error = False
    return custom_listener, ui_msgs


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

# --

def _build_top_nav(links):
    def render_top_nav(_, margin, indent):
        return _html_lines_for_nav_links(links, margin, indent)
    render_top_nav.component_label = None
    return render_top_nav


def _html_lines_for_nav_links(link_pairs, margin, indent):
    for label, params in link_pairs:
        for line in _html_lines_for_nav_link(label, params, margin, indent):
            yield line


def _html_lines_for_buttons(button_pairs, margin, indent):
    for label, params in button_pairs:
        for line in _html_lines_for_button(label, params, margin, indent):
            yield line


def _html_lines_for_nav_link(label, params, margin, indent):
    if False:  # #todo keeping the below for reference for now (searchable)
        from urllib.parse import urlencode
        url_tail = ''.join(('?', urlencode(params)))
    if 'nav_link_url' != params[0]:
        raise RuntimeError(f"Where? {params[0]!r}")
    url_tail, = params[1:]
    assert '/' == url_tail[0]  # seems to be new in #history-C.5
    use_label = _html_escape(label)  # this isn't giving &nbsp; to each space
    yield f'{margin}<a href="{url_tail}">{use_label}</a>\n'


def _html_lines_for_button(label, directive_sexp, margin, indent):
    assert 'button_url' == directive_sexp[0]  # for now the only way.
    url_tail, = directive_sexp[1:]
    yield f'{margin}<form method="GET" action="{url_tail}">\n'
    m2 = f"{margin}{indent}"
    yield f'{m2}<input type="submit" value="{label}" />\n'
    yield f'{margin}</form>\n'


class _MOVING_UI_Messages:
    # might either become named tuple or go back to before #history-C.4

    def __init__(self):
        self.general, self.specific = [], {}

    def __iter__(self):
        return iter((self.general, self.specific))


def _add_safely(dct, k, val):
    assert k not in dct
    dct[k] = val


# :#here7: EID used to be hidden form var but now is embedded in url #history-C.5
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

# #history-C.6 a great exodous. no more command splay, no more help (for now)
# #history-C.5 overhaul to parse it the new way with "send URL back"
# #history-C.4 (as referenced)
# #history-C.3 (can be temporary)
# #history-C.2: "engine" not hand-written CLI
# #history-C.1: change styling to "minimal" theme
# #born
