"""This module is called "forming" because it XX into a verb

History:

at #abstraction, this was left mostly intact as XX
"""


def process_form(
        out,  # an open filestream to write to (usually STDOUT)
        qualified_EID,  # ('parent_EID', EID) or ('updatee_EID', EID)
        verb_stem,  # 'CREATE' or 'UPDATE'
        form_args,  # straightforward name-value pairs in a dictionary
        form_action,  # the string - a url path ("tail")
        line_nester,  # (when not redirect) output lines go thru this
        label_for_CANCEL,  # probably will broaden to a FORM_STYLESHEET
        collection,  # used to actually UPDATE or CREATE the entity
        listener  # must be the special one, with UI Messages structure
    ):

    values = _EXPERIMENTAL_Common_Value_Derivations(form_action, label_for_CANCEL)
    ui_msgs = listener.UI_messages  # ..

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
            listener(*emi)

        # (roo = result of operation)
        roo = collection.update_entity(eid, param_direcs, use_listener)

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
            pass  # used to make nav links
    else:
        assert 'CREATE' == verb_stem
        # The incoming form args need these mutations to be CREATE params:
        #   - Add 'parent' (EID) (which was embedded in the url) #here7

        typ, eid = qualified_EID
        assert 'parent_EID' == typ
        assert 'parent' not in form_args
        form_args['parent'] = eid
        roo = collection.create_entity(form_args, listener)
        if roo:
            assert 'result_of_CREATE_or_UPDATE' == roo[0]
            assert 'result_of_CREATE' == roo[1]
            assert 'CREATE_succeeded' == roo[2]
            these_args = 'CREATE', roo[3]  # just realized this will need the new ID eventually
        else:
            # (used to make nav links here)
            form_args.pop('parent')
            # (don't put this in hidden form arg in repop #here7)

    if not roo:
        # If it failed, assume messages were written to ui_msgs and re-show form

        fe = collection.EXPERIMENTAL_HYBRIDIZED_FORMAL_ENTITY_(listener)
        return _do_show_form(
                out=out, form_args=form_args, derived_values=values,
                form_action=form_action, line_nester=line_nester,
                formal_entity=fe, collection=collection, listener=listener)

    # An attempt is made to handle successes of *both* CREATE and UPDATE
    # here in one place but..

    out.write(f"redirect {values.parent_UI_node_url()}\n")
    return 0


def show_form(
        out,  # an open filestream to write to (usually STDOUT)
        qualified_EID,  # ('parent_EID', EID) or ('updatee_EID', EID)
        verb_stem,  # 'CREATE' or 'UPDATE'
        form_action,  # the string - a url path ("tail")
        line_nester,  # output lines go thru this before writing to `out`
        label_for_CANCEL,  # probably will broaden to a FORM_STYLESHEET
        formal_entity,  # derive the form structure from this formal entity
        collection,  # used to retrieve existing entity when UPDATE
        listener  # must be the special one, with UI Messages structure
    ):

    values = _EXPERIMENTAL_Common_Value_Derivations(form_action, label_for_CANCEL)

    if 'UPDATE' == verb_stem:
        typ, eid = qualified_EID
        assert 'updatee_EID' == typ
        ent = collection.retrieve_entity(eid, listener)
        assert ent  # for now
        from app_flow.form_via_formal_entity import \
                EXPERIMENTAL_populate_form_values as func
        _ = func(ent, formal_entity, listener)
        outgoing_form_values = {k: v for k, v in _}
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

    _do_show_form(
            out=out, form_args=outgoing_form_values, derived_values=values,
            form_action=form_action, line_nester=line_nester,
            formal_entity=formal_entity,
            collection=collection, listener=listener)


def _do_show_form(
        out, form_args, derived_values, form_action,
        line_nester, formal_entity, collection, listener):

    assert '/' == form_action[0]  # should be url tail

    # == BEGIN XX
    _ = _build_additional_renderers(derived_values)
    additional_renderers = {k: v for k, v in _}
    # == END

    # If it has VALUE_FACTORIES, take those attrs out
    # (we could put this knowledge in the downstream function, but why)
    fattrs = formal_entity.to_formal_attributes()
    VF_dct = getattr(collection.dataclass, 'VALUE_FACTORIES', None)
    if VF_dct:
        fattrs = _filter_out_these(fattrs, VF_dct)

    def model_class_via_name(fent_name):
        _ = collection.collectioner[fent_name]  # key error okay
        return _.dataclass

    from app_flow.form_via_formal_entity import \
            html_form_via_SOMETHING_ON_THE_MOVE as func
    lines = func(
            FORMAL_ATTRIBUTES=fattrs,
            action=form_action, form_values=form_args,
            model_class_via_name=model_class_via_name,
            additional_renderers=additional_renderers,
            ui_msgs=listener.UI_messages, listener=listener)
    w = out.write
    for line in line_nester(lines):
        w(line)
    return 0


# == Nav-links and buttons (html rendering)

def _build_additional_renderers(values):
    from app_flow.common_html import build_navigation_component as func
    yield '_top_nav', func(_common_nav_links(values))
    yield '_THE_MIDDLE_', None


def _common_nav_links(values):
    yield values.label_for_CANCEL(), ('nav_link_url', values.parent_UI_node_url())

# == Listeners

def build_UI_wired_listener(serr):
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
    custom_listener.UI_messages = ui_msgs
    return custom_listener


# == Internal data structures & similar (all EXPERIMENTAL)

def memoized(func):  # #decorator
    def use_func(self):
        if name_key not in self._memoized_values:
            self._memoized_values[name_key] = func(self)
        return self._memoized_values[name_key]
    name_key = func.__name__
    return use_func


class _UI_Messages:
    # might either become named tuple or go back to before #history-C.4

    def __init__(self):
        self.general, self.specific = [], {}

    def __iter__(self):
        return iter((self.general, self.specific))


class _EXPERIMENTAL_Common_Value_Derivations:

    def __init__(self, form_action, label_for_CANCEL):
        self._form_action = form_action
        self._label_for_CANCEL = label_for_CANCEL
        self._memoized_values = {}

    @memoized
    def parent_UI_node_url(self):
        from app_flow.routing import \
            parent_UI_node_url_via_form_action_EXPERIMENTAL as func
        return func(self._form_action)
        # (#here1:route-name:view_capability)

    def label_for_CANCEL(self):
        return self._label_for_CANCEL


# == Lower-level support

def _line_writer_via_write_function(w):
    def write_line(line):
        w(line)
        if 0 == len(line) or '\n' != line[-1]:
            w('\n')
    return write_line


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

# #abstraction
