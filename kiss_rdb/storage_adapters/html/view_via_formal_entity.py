"""
WISHLIST/WATCHLIST/ISSUES/CONCERNS:
* All throughout this, tablism is hard-coded for now. From the beginning, the
  plan was *not* to hard-code tablism; but at first pass, it "felt" too
  abstracted (obtuse, hard-to-follow) already, so we left the hard-coding in.

This module,
- created *after* the sibling for EDIT
- abstracted from a not-over-abstracted hard-coded thing
..became the de-facto *and* de-jure home of the concept of "component renderer"
- Then retroactively this concept back-pollinated the UPDATE sibling
- Throughout this is the concept of "baking" (preparing a function that will
  then be called successively, for example across several entities or
  the several values in a "column" (field))

A Component renderer:
- is basically a function that produces lines (but see the rest)
- hackishly has a `label` property shoved right on to it
- its result must be an iterator of html "lines" (but see the rest)
"""


def create_entity_renderer__(fe, view_pipelines=None, additional_renderers=None):
    assert(view_pipelines is None or isinstance(view_pipelines, dict))
    assert(additional_renderers is None or isinstance(additional_renderers, dict))

    def component_renderers():
        for fa in fe.to_formal_attributes():
            cr = component_renderer_via_formal_attribute(fa)
            if view_pipelines and (vpl := view_pipelines.get(_attr(fa))):
                cr = vpl(cr, fa)
            yield fa.column_name, cr

        for k, cr in (additional_renderers.items() if additional_renderers else ()):
            if not hasattr(cr, 'component_label'):
                xx(f"oops, you forgot to add `component_label` to {k!r}")
            yield k, cr

    component_renderers = {k: v for k, v in component_renderers()}
    return entity_renderer_via_component_renderers(component_renderers)


def entity_renderer_via_component_renderers(component_renderers):
    assert isinstance(component_renderers, dict)  # changed from iterable
    def render_entity(ent, margin='', indent='  '):
        yield f'{margin}<table>\n'
        table_row_lines_for = _build_table_row_lineser(ent, margin, indent)
        for cr in component_renderers.values():
            for line in table_row_lines_for(cr):
                yield line
        yield f'{margin}</table>\n'
    return render_entity


def _build_table_row_lineser(ent, margin, indent):
    m2 = f'{margin}{indent}'  # the level of indent you use for <tr>
    m3 = f'{m2}{indent}'  # the level of indent children might use

    def table_row_lines_for_CR(cr):
        # Output (sort of) the label
        def pcs():
            yield m2, '<tr>'
            td_attrs = {}
            if (label := cr.component_label):  # expect lots of errors lol
                yield '<th>', h(label), '</th>'
            else:
                td_attrs['colspan'] = '2'
            if (CSS_class := getattr(cr, 'component_TD_element_class', None)):
                assert '"' not in CSS_class
                td_attrs['class'] = CSS_class
            _td = ' '.join(('', *(f'{k}="{v}"' for k, v in td_attrs.items())))
            yield (f'<td{_td}>',)
        pcs = list(s for row in pcs() for s in row)

        # Output the value
        itr = cr(ent, m3, indent)
        line1 = next(itr, None)
        if line1 is None:
            # No output is a popular choice for component renderers. No-op
            pass
        elif 0 == len(line1):
            xx('where?')  # munge this into the above case if it's okay
        elif '\n' == line1[-1]:
            # Assume multiline output from the component renderer
            pcs.append('\n')
            yield ''.join(pcs)
            yield line1
            for line in itr:
                assert len(line) and '\n' == line[-1]
                yield line
            pcs.clear()
            pcs.append(m2)  # tricky, start the line off right
        else:
            # Assume a plain old string from the component renderer
            pcs.append(line1)
            assert not next(itr, False)
        pcs.append('</td></tr>\n')
        yield ''.join(pcs)
    h = _html_escape_function()
    return table_row_lines_for_CR


def component_renderer_via_formal_attribute(fa, attr=None):
    cr = _begin_component_renderer_via_formal_attribute(fa, attr)
    cr.component_label = fa.identifier_for_purpose(_label_purpose)
    return cr


def _begin_component_renderer_via_formal_attribute(fa, attr):

    if attr is None:  # experimental, only an option for hacks
        attr = _attr(fa)

    tm = fa.type_macro
    base_type = tm.LEFTMOST_TYPE

    if 'text' == base_type:  # 'line' or 'text' ('paragraph' doesn't happen now)
        if 'url' == tm.string:
            return _build_URL_renderer(attr)
        return _build_the_most_common_component_renderer(attr)

    if 'tuple' == base_type:
        return _build_tuple_component_renderer(attr, tm)

    if 'int' == base_type:  # ..
        return _build_int_component_renderer(attr)

    if 'instance_of_class' == base_type:
        return _build_the_most_common_component_renderer(attr)  # ..

    xx(f"have fun: {tm.string!r}")


def _build_tuple_component_renderer(attr, tm):
    if (args := tm.generic_alias_args_):
        arg, = args
        if arg is str:
            return _build_paragraph_renderer(attr)
        if isinstance(arg, str):
            # [#872.H] string is a "fent", just flat list EID's for now
            return _build_list_of_ents_component_renderer(attr)
    xx(f"first time seen: {tm.string!r}")


def _build_list_of_ents_component_renderer(attr):

    def html_lines_for_component_via_entity(ent, margin, indent):  # #here1
        use_val = getattr(ent, attr) or ()
        itr = iter(use_val)

        def pieces():
            first = next(itr, None)
            if first is None:
                return
            yield h(first)
            for nonfirst in itr:
                yield '&nbsp;'
                yield h(nonfirst)

        use_val = ''.join(pieces())
        """(before #abstraction we used to return no lines on no children.
        Then before #history-C.1 we changed it to yield one empty line,
        then (at that history) we changed it back)
        """
        if 0 == len(use_val):
            return
        yield use_val  # #here2 no newline at end
    h = _html_escape_function()
    return html_lines_for_component_via_entity


def _build_URL_renderer(attr):
    def html_lines_for(ent, margin, indent):
        url = getattr(ent, attr)
        if not url:
            return
        yield f'{margin}<a href="{url}">{h(url)}</a>\n'
    h = _html_escape_function()
    return html_lines_for


def _build_paragraph_renderer(attr):
    def html_lines_for_component_via_entity(ent, margin, indent):  # #here1
        for line in getattr(ent, attr):  # ..
            # XXX there's a few things to explain here:
            assert '\n' == line[-1]
            escaped = h(line[:-1])
            yield f'{escaped}</br>\n'  # #here2 YES newline at end
    h = _html_escape_function()
    return html_lines_for_component_via_entity


def _build_the_most_common_component_renderer(attr):
    def html_lines_for_component_via_entity(ent, margin, indent):  # #here1
        x = getattr(ent, attr)
        if x is None:
            return
        assert isinstance(x, str)
        yield h(x)  # #here2 no newline at end
    h = _html_escape_function()
    return html_lines_for_component_via_entity


def _build_int_component_renderer(attr):
    def html_lines_for_component_via_entity(ent, margin, indent):  # #here1
        x = getattr(ent, attr)
        if x is None:
            return
        assert isinstance(x, int)
        yield h(str(x))  # #here2 no newline at end
    h = _html_escape_function()
    use_label = h(label)
    return html_lines_for_component_via_entity


# == Support

def _attr(fa):
    return fa.identifier_for_purpose(_DK_FN_PURPOSE)


def _html_escape_function():
    from html import escape as func
    return func


_label_purpose = ('label',)
_DK_FN_PURPOSE = ('DATACLASS_FIELD_NAME_PURPOSE_',)


def xx(msg=None):
    head = "finish this/cover this/oops"
    raise RuntimeError(''.join((head, *((': ', msg) if msg else ()))))

# #history-C.1
# #abstraction
