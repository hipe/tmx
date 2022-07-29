"""This module is a catch-all for small html-rendering component functions
that are needed by more than one client (in the founding case, needed
internally by this library and also by an external client).
"""


def build_navigation_component(links):
    def render(_, margin, indent):
        return _html_lines_for_nav_links(links, margin, indent)
    render.component_label = None
    return render


# == Plural (nav links, buttons)

def _html_lines_for_nav_links(link_pairs, margin, indent):
    for label, params in link_pairs:
        for line in _html_lines_for_nav_link(label, params, margin, indent):
            yield line


def html_lines_for_buttons(button_pairs, margin, indent):
    for label, params in button_pairs:
        for line in _html_lines_for_button(label, params, margin, indent):
            yield line


# == Singular (nav link, button)

def _html_lines_for_nav_link(label, params, margin, indent):
    if False:  # #todo keeping the below for reference for now (searchable)
        from urllib.parse import urlencode
        url_tail = ''.join(('?', urlencode(params)))
    if 'nav_link_url' != params[0]:
        raise RuntimeError(f"Where? {params[0]!r}")
    url_tail, = params[1:]
    assert '/' == url_tail[0]
    use_label = _html_escape(label)  # this isn't giving &nbsp; to each space
    yield f'{margin}<a href="{url_tail}">{use_label}</a>\n'


def _html_lines_for_button(label, directive_sexp, margin, indent):
    assert 'button_url' == directive_sexp[0]  # for now the only way.
    url_tail, = directive_sexp[1:]
    yield f'{margin}<form method="GET" action="{url_tail}">\n'
    m2 = f"{margin}{indent}"
    use_label = _html_escape(label)
    yield f'{m2}<input type="submit" value="{use_label}" />\n'
    yield f'{margin}</form>\n'


# == Insane experiment (repeated)

def _html_escape(s):
    assert _html_escape.is_first_call
    _html_escape.is_first_call = False
    from sys import modules as _
    self_module = _[__name__]
    from html import escape as func
    self_module._html_escape = func
    return _html_escape(s)


_html_escape.is_first_call = True

# #abstracted
