import re


# inc = _IndexedNotecard
# idoc = _IndexedDocument

def dereference_footnotes__(mixed_children, lineno, inc, idoc, listener):
    """an ad-hoc specialty function that is the main workhorse for merging

    footnotes. assert that the mixed children of the structured line have
    the pattern:

        s o s [ o s [..]]

    where the `s`'s are strings and the `o`'s are a footnote reference AST.
    """

    a = []

    mixed_itr = iter(mixed_children)
    dct = inc.footnote_url_via_local_identifier

    def add_string(s):
        assert(isinstance(s, str))  # #[#022]
        a.append(s)

    add_string(next(mixed_itr))

    for ast in mixed_itr:
        assert('local footnote reference' == ast.symbol_name)
        # (if you get ambitious and have more than just this, refactor obv

        local_id = ast.local_identifier
        if local_id not in dct:
            __whine_about_bad_footnote_ref(
                    listener, local_id, lineno, inc, idoc)
            return
        _url = dct[local_id]
        _final_id = idoc.final_footnote_identifier_via_url[_url]
        a.append(_FootnoteReference(ast.label_text, _final_id))

        add_string(next(mixed_itr))

    return tuple(a)


def any_structured_via_line__(line):
    # (this is wholly concerned with finding footnote references so it's here)

    md_itr = re.finditer(footnote_reference_regex_, line)
    for first_md in md_itr:  # once
        break
    if first_md is None:
        return

    # (Case122)

    def unpeek():
        yield first_md
        for md in md_itr:
            yield md

    # this could deffo false match, like "`[xx][yy]`" (in backtics) :#here1
    # this is why we need proper parsing one day #open [#882.F]

    a = []
    cursor = 0

    for md in unpeek():
        begin, end = md.span(0)
        a.append(line[cursor:begin])  # even if the empty string
        a.append(_LocalFootnoteReference(md[1], md[2]))
        cursor = end

    a.append(line[cursor:])  # even if empty string

    import pho.models_
    return pho.models_.StructuredContentLine__(tuple(a))


footnote_reference_regex_ = re.compile(
        r'\[([^\]]+)\]'
        r'\[([^\]]+)\]'
        )


# == models & associated trivial builder functions

# -- footnote reference (2 kinds)

class _FootnoteReference:

    def __init__(self, lt, li):
        self.label_text = lt
        self.identifier_string = li

    def to_string(self):
        _1 = self.label_text
        _2 = self.identifier_string
        return f'[{_1}][{_2}]'

    symbol_name = 'footnote reference'


class _LocalFootnoteReference:
    def __init__(self, lt, li):
        self.label_text = lt
        self.local_identifier = li
    symbol_name = 'local footnote reference'


# -- footnote definition (2 kinds)

def any_definition_via_line(line):
    md = _footnote_definition_rx.match(line)
    if md is None:
        return
    _post_match = md.string[md.span()[1]:]
    return _LocalFootnoteDefinition(md[1], _post_match)  # `post_match`


_footnote_definition_rx = re.compile(r'^\[([0-9a-zA-Z_]+)\]: *')


class _FootnoteDefinition:

    def __init__(self, id_s, s):
        self.identifier_string = id_s
        self.url_probably = s

    def to_lines(self):
        _1 = self.identifier_string
        _2 = self.url_probably
        yield f'[{_1}]: {_2}'


class _GlobalFootnoteDefinition(_FootnoteDefinition):

    symbol_name = 'footnote definition'


class _LocalFootnoteDefinition(_FootnoteDefinition):

    symbol_name = 'local footnote definition'


footnote_definition_via = _GlobalFootnoteDefinition


# == whiners

def __whine_about_bad_footnote_ref(listener, local_id, lineno, inc, idoc):

    _iid = inc.notecard_identifier_string

    a = tuple(fnd.identifier_string for fnd in inc.footnote_definitions)

    if len(a):
        _these = ', '.join(a)
        but_what = f'(had: {_these})'
    else:
        but_what = 'but no footnotes are defined'

    _msg = (
            f'in document {repr(_iid)} '
            f'on body line {lineno}, '
            f'it references a footnote {repr(local_id)} '
            f'{but_what}'
            )

    cover_me(_msg)


# ==

def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')

# #abstracted.
