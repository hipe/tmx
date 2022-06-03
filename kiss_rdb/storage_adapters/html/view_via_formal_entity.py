"""
WISHLIST/WATCHLIST/ISSUES/CONCERNS:
* All throughout this, tablism is hard-coded for now. From the beginning, the
  plan was *not* to hard-code tablism; but at first pass, it "felt" too
  abstracted (obtuse, hard-to-follow) already, so we left the hard-coding in.
"""


def create_entity_renderer(fe, additional_renderers=None):
    assert(additional_renderers is None or isinstance(additional_renderers, dict))
    def component_renderers():
        for fa in fe.to_formal_attributes():
            cr = component_renderer_via_formal_attribute(fa)
            yield fa.column_name, cr
        for k, cr in (additional_renderers.items() if additional_renderers else ()):
            yield k, cr

    component_renderers = {k: v for k, v in component_renderers()}
    return entity_renderer_via_component_renderers(component_renderers)


def entity_renderer_via_component_renderers(component_renderers):
    assert isinstance(component_renderers, dict)  # changed from iterable
    def render_entity(ent, margin=''):
        yield f'{margin}<table>\n'
        sub_margin = f'{margin}  '
        for cr in component_renderers.values():
            for line in cr(ent, margin=sub_margin):
                yield line
        yield '</table>\n'
    return render_entity


def component_renderer_via_formal_attribute(fa, label=None):
    attr = fa.IDENTIFIER_FOR_PURPOSE(_DK_FN_PURPOSE)
    tm = fa.type_macro

    if tm.kind_of('text'):  # 'line' or 'text' ('paragraph' doesn't happen now)
        if label is None:
            label = fa.IDENTIFIER_FOR_PURPOSE(_label_purpose)
        return _build_the_most_common_component_renderer(attr, label)

    if tm.kind_of('tuple'):
        if label is None:
            label = _digusting_hotfix_of_label_for_tuple(attr)
        return _build_tuple_component_renderer(attr, label, tm)

    if tm.kind_of('int'):
        if label is None:
            label = fa.IDENTIFIER_FOR_PURPOSE(_label_purpose)
        return _build_int_component_renderer(attr, label)
    xx(f"have fun: {tm.string!r}")


def _digusting_hotfix_of_label_for_tuple(attr):
    # don't use 'Child' as label, use 'Children'
    import re
    eek = attr.split('_')
    if 1 < len(eek) and re.match('^[A-Z]{2}', eek[-1]):
        eek.pop()
    eek[0] = eek[0][0].upper() + eek[0][1:]
    return ' '.join(eek)


def _build_tuple_component_renderer(attr, label, tm):
    if (args := tm.generic_alias_args_):
        arg, = args
        if arg is str:
            return _build_paragraph_renderer(attr, label)
        if isinstance(arg, str):
            pass  # [#872.H]: string is a "fent", just flat list EID's for now
        else:
            xx(f"first time seen: {tm.string!r}")

    def html_lines_for_component_via_entity(ent, margin):  # #here1
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
        # (you could return here on no children. we used to before #abstration)

        yield f"{margin}<tr><th>{use_label}</th><td>{use_val}</td></tr>\n"
    h = _html_escape_function()
    use_label = h(label)
    return html_lines_for_component_via_entity


def _build_paragraph_renderer(attr, label):
    def html_lines_for_component_via_entity(ent, margin):  # #here1
        yield f"{margin}<tr><th>{use_label}</th><td>\n"
        for line in getattr(ent, attr):  # ..
            # (escapting the final newline does nothing. put newline at new end)
            assert '\n' == line[-1]
            escaped = h(line[:-1])
            # (escaping the final 
            yield f'{escaped}</br>\n'
        yield '</td></tr>\n'
        # (you could return here on no children. we used to before #abstration)

    h = _html_escape_function()
    use_label = h(label)
    return html_lines_for_component_via_entity


def _build_the_most_common_component_renderer(attr, label):
    def html_lines_for_component_via_entity(ent, margin):  # #here1
        x = getattr(ent, attr)
        if x is None:
            use_x = ''
        else:
            assert isinstance(x, str)
            use_x = h(x)
        yield f"{margin}<tr><th>{use_label}</th><td>{use_x}</td></tr>\n"
    h = _html_escape_function()
    use_label = h(label)
    return html_lines_for_component_via_entity


def _build_int_component_renderer(attr, label):
    def html_lines_for_component_via_entity(ent, margin):  # #here1
        x = getattr(ent, attr)
        if x is None:
            use_x = ''
        else:
            assert isinstance(x, int)
            use_x = h(str(x))  # ..
        yield f"{margin}<tr><th>{use_label}</th><td>{use_x}</td></tr>\n"
    h = _html_escape_function()
    use_label = h(label)
    return html_lines_for_component_via_entity


# == Support

def _html_escape_function():
    from html import escape as func
    return func


_label_purpose = ('label',)
_DK_FN_PURPOSE = ('DATACLASS_FIELD_NAME_PURPOSE_',)

# #abstraction
