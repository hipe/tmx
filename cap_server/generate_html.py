#!/usr/bin/env -S python3 -W error::::

def endpoint(route_string, http_method=None, GET_params=None):  # #decorator
    """The decorator for defining endpoints ("command" functions)

    probably similar to something in flask..
    """

    def decorator(func):
        func.command = None  # for #here5
        args = [route_string, (func,)]
        # (If you don't wrap the function, it binds to some guy :#here3)

        if http_method:
            args.append(http_method)
        if GET_params:
            assert not http_method  # the func syntax overloads the position
            args.append(GET_params)
        route_definitions.append(args)
        # return nothing. we never call the functions directly

    route_definitions = endpoint._defs_volatile
    return decorator

endpoint._defs_volatile = []


def _pattern_definitions(placeholder_name):
    if 'EID' == placeholder_name:
        return '^[A-Z0-9]+$'


def _CLI(sin, sout, serr, argv):

    stack = list(reversed(argv))
    program_name = stack.pop()

    # (Throw a stop as soon as someone emits an error)
    # (Eventually this should emit a 500 error or w/e but why)
    def listener(severity, shape, *rest):
        assert 'expression' == shape
        lines = tuple(rest[-1]())
        for line in lines:
            if 0 == len(line) or '\n' != line[-1]:
                line = f'{line}\n'
            serr.write(line)
        if 'error' != severity:
            return
        if 0 == listener.returncode:
            listener.returncode = 123
        raise _Stop()
    listener.returncode = 0

    def main():
        # Parse the CLI into fparams and bparams (framework p. and business p.)
        parse_tree = _parse_ARGV_into_fparams_and_bparams(stack, listener)

        # Consume those parts of the fparams needed to resolve the endpoint func
        resp = _consume_params_for_matcher_call(parse_tree, listener)

        if not resp.OK:
            sout.write(f"{resp.message}\n")  # EXPERIMENTAL
            return resp.some_returncode % 256  # we can't

        if not resp.had_trailing_slash:
            xx('we want to correct these somehow')

        parse_tree.url_pattern_values = resp.parse_tree  # abuse. ick/meh

        endpoint_func, = resp.route_associated_value  # #here3 func is wrapped

        # Use the endpoint function's docstring-based signature to parse params
        from script_lib.docstring_based_command import \
                command_of_function as func
        command = func(endpoint_func)
        terms = _scanner_via_iter(command.to_formal_arguments())  # #here5
        del command

        # Every endpoint function takes at least these
        args = [sout, serr]

        # For each next "normal" term, you must resolve it somehow
        if terms.more:
            resolvers = build_resolvers_scanner()

        while terms.more and not terms.peek.is_glob:
            # We're pop off each next remaining resolver until we find one
            while True:
                if resolvers.empty:
                    xx("as the prophecy foretold. unexpected here: {terms.peek.label!r}")

                if resolvers.peek[0] == terms.peek.label:
                    break

                resolvers.advance()

            # If you got here, you have a lineup with term and resolver
            term = terms.next()
            _, resolver_func = resolvers.next()
            args.append(resolver_func(parse_tree))

        if terms.more:
            assert terms.peek.is_glob
            glob_term = terms.next()
            assert terms.empty  # can't have '*FOO *FOO' in syntax

            # There is magic here - not matter what the syntax calls it,
            # it's the form args (bparams)
            form_args = parse_tree.bparams
            parse_tree.bparams = None
            args.append(form_args)

        # We should have unloaded everything now
        if parse_tree.bparams:
            xx('bparams were passed but not consumed by endpoint function')

        if parse_tree.url_pattern_values:
            xx('the url had pattern matchers not consumed by the endpoint func')

        parse_tree.fparams.pop('collection', None)  # if not already consumed
        if parse_tree.fparams:
            xx('not sure this is bad - ununsed fparams')

        return endpoint_func(*args)  # you should be proud

    def build_resolvers_scanner():
        return _scanner_via_iter(each_term_resolver_pair())

    def each_term_resolver_pair():
        yield 'RECFILE', resolve_recfile
        yield 'EID', resolve_EID

    def resolve_EID(parse_tree):
        return parse_tree.url_pattern_values.pop('EID')

    def resolve_recfile(parse_tree):
        return parse_tree.fparams.pop('collection')  # note label change

    rc = None
    try:
        rc = main()
    except _Stop:
        pass

    return listener.returncode if rc is None else rc


def _consume_params_for_matcher_call(parse_tree, listener):
    fparams = parse_tree.fparams

    # Like a madman, let's consume the fparams
    use_url_tail = fparams.pop('url')
    use_http_method = fparams.pop('http_method')

    # This is HIGHLY EXPERIMENTAL -- is routing expected to consume fully
    # the GET params, or should it just consume what it wants?
    if parse_tree.bparams and 'GET' == use_http_method:
        use_GET_params = parse_tree.bparams
        parse_tree.bparams = None
    else:
        use_GET_params = None

    # messy and expensive as CLI, especially as CLI that's also backend #here4
    defs = endpoint._defs_volatile
    del endpoint._defs_volatile
    from app_flow.routing import matcher_via_routes as func
    matcher = func(defs, _pattern_definitions)
    return matcher.match(use_url_tail, use_http_method, use_GET_params)


def _parse_ARGV_into_fparams_and_bparams(stack, listener):
    from app_flow.server_CLI import parse_argv as func
    return func(stack, listener)


# == OLD CLI BELOW


def _OLD_CLI(sin, sout, serr, argv):
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
    if cmd.has_only_positional_args_GONE:
        if (rc := cmd.validate_positionals(stderr, stack, prog_name)):
            return rc
        return cmd.function(_, sout, serr, *reversed(stack))
    return cmd.function(_, sout, serr, stack)


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

    from kiss_rdb.storage_adapters.html.view_via_formal_entity import \
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
    custom_listener, ui_msgs = _build_listener_custom_to_this_module(serr)

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

    listener, ui_msgs = _build_listener_custom_to_this_module(serr)

    fe = coll.EXPERIMENTAL_HYBRIDIZED_FORMAL_ENTITY_(listener)

    # (experimental - wiring a listener on form GENERATION for reasons)

    # == BEGIN NEW
    if 'UPDATE' == verb_stem:
        typ, eid = qualified_EID
        assert 'updatee_EID' == typ
        ent = coll.retrieve_entity(eid, listener)
        assert ent  # for now
        from kiss_rdb.storage_adapters.html.form_via_formal_entity import \
                EXPERIMENTAL_populate_form_values_ as func
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
        fattrs = _filter_out_these(fattrs, VF_dct)

    def model_class_via_name(fent_name):
        _ = coll.collectioner[fent_name]  # key error okay
        return _.dataclass

    from kiss_rdb.storage_adapters.html.form_via_formal_entity import \
            html_form_via_SOMETHING_ON_THE_MOVE_ as func
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
    """TEMPORARY HACK and EXPERIMENTAL:
    This is:
    - a somewhat improvement over other hacks we did before #history-C.5
    - still a hack, probably temporary, just a stand-in for whatever is next

    From the form action (a url tail ("path")) we can derive these:
    - The "verb stem" (`CREATE` or `UPDATE` (from '../add/' or '../edit/')
    - The parent "UI node" (hackishly always at a fixed depth of *two* lol)
      (Think of this as the "referrer" if you like)

    (Currently we only derive the one data element but we could derive more.
    This may seem like a minor point but it's the underpinning of etc)

    In practice, our arguments will be just these:
        /capability/AB/edit/
        /capability/AB/nodes/add/
    """

    pcs = form_action.split('/')
    assert '' == pcs[0]
    assert '' == pcs[-1]
    here_url_components = pcs[1:-1]

    verb_url_entry = here_url_components[-1]
    if 'add' == verb_url_entry:
        # verb_stem = 'CREATE'
        pass
    else:
        assert 'edit' == verb_url_entry
        # verb_stem = 'UPDATE'

    num_components = len(here_url_components)
    assert 2 < num_components and num_components < 5

    return '/'.join(('', *here_url_components[:2], ''))
    # (#here1:route-name:view_capability)


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
    ui_msgs = _UI_Messages()
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
    from kiss_rdb.tree_toolkit import tree_dictionary_via_tree_nodes as func
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

    yield '<table>\n<tr><th>ID</th><th>Label</th><th>State</th><th>&#35; notes</th></tr>\n'
    for line in lines:
        yield line

    if pool:
        def lines():
            yield f"warning: orphan note(s): {tuple(pool.keys())!r}"
        listener('warning', 'expression', 'orphan_notes', lines)
    yield '</table>\n'


def _inner_html_lines_for_tree(recs_itr, _colz_NOT_USED, listener):
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


class _UI_Messages:
    # might either become named tuple or go back to before #history-C.4

    def __init__(self):
        self.general, self.specific = [], {}

    def __iter__(self):
        return iter((self.general, self.specific))


def _scanner_via_iter(itr):  # exists elsewhere too
    class Scanner:
        def next(self):
            item = self.peek
            self.advance()
            return item

        def advance(self):
            item = next(itr, None)
            if item:
                self.peek = item
                return
            del self.peek
            self.more = False

        @property
        def empty(self):
            return not self.more

    scn = Scanner()
    scn.peek = None
    scn.more = True
    scn.advance()
    return scn


def _add_safely(dct, k, val):
    assert k not in dct
    dct[k] = val


# :#here7: EID used to be hidden form var but now is embedded in url #history-C.5
# :#here6: rebuild the same url that was used in our invocation ick
#   - Every one of these is also a #here1
# :#here4: One day we might make this long-running. Change these then (placeheld)
# :#here1: #wish [#872.C]: The dream of fully two-directional routes:
#   - While doing #history-C.5 we re-invented the utility (alla rails, but for
#     us a vaporware nice-to-have) of having each route available to be
#     generated and exposed thru a simple, unique name. We're saving that for
#     a later refactor.
#     Fow now, we create each url "manually" (and with duplication).
#   - Every `button_url` and `nav_link_url` falls under this tag scope too.


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
    from kiss_rdb.cap_server.model_ import collections_via_main_recfile_ as func
    return func(recfile)


def _this_module():
    import sys
    return sys.modules[__name__]


class _Stop(RuntimeError):
    pass


if '__main__' == __name__:
    from sys import stdin, stdout, stderr, argv
    rc = _CLI(stdin, stdout, stderr, argv)
    if isinstance(rc, int):
        exit(rc)
    stdout.write(f"(oops, expected int had {type(rc)} for returncode)\n")

# #history-C.5 overhaul to parse it the new way with "send URL back"
# #history-C.4 (as referenced)
# #history-C.3 (can be temporary)
# #history-C.2: "engine" not hand-written CLI
# #history-C.1: change styling to "minimal" theme
# #born
