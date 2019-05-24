def document_state_via_fragments(frag_itr):
    from pho.magnetics_.document_via_fragments import Document_
    _fragments = tuple(_frags_via_frag_itr(frag_itr))
    _doc = Document_(_fragments)
    return _DocumentState(_doc)


class _DocumentState:

    def __init__(self, doc):

        self._sections = None

        def sectionser():
            if self._sections is None:
                self._sections = _sections_via_doc(doc)
            return self._sections
        self._sectionser = sectionser

        def titler():
            return doc.document_title
        self._titler = titler

    @property
    def document_title(self):
        return self._titler()

    @property
    def first_section(self):
        return self.section_at(0)

    def section_at(self, i):
        return self.sections[i]

    @property
    def sections(self):
        return self._sectionser()


def _sections_via_doc(doc):
    return tuple(_sections_via_doc_2(doc))


def _sections_via_doc_2(doc):

    sl_itr = doc.to_line_sexps(None)

    # only for the first section, it's possible that there's no header line

    tup = next(sl_itr)

    if 'header' == tup[0]:
        header_SL_for_section = tup
        cache = []
    else:
        header_SL_for_section = None
        cache = [tup]

    for tup in sl_itr:
        if 'header' == tup[0]:
            yield _Section(header_SL_for_section, tuple(cache))
            header_SL_for_section = tup
            cache.clear()
            continue
        cache.append(tup)

    if len(cache) or header_SL_for_section is not None:
        yield _Section(header_SL_for_section, tuple(cache))


class _Section:

    def __init__(self, header_SL, SLs):

        if header_SL is None:
            self.header = None
        else:
            assert('header' == header_SL[0])
            self.header = _Header(*header_SL[1:])

        self.body_line_sexps = SLs


class _Header:
    def __init__(self, depth, mixed_s):
        self.depth = depth
        self.text = mixed_s  # when came from heading, might not have leading


def _frags_via_frag_itr(frag_itr):

    from pho.magnetics_.document_fragment_via_definition import (
            _DocumentFragment,
            )

    for title_s, line_itr in frag_itr:

        _body = ''.join(_add_newline(s) for s in line_itr)

        yield _DocumentFragment(
                identifier_string=None,
                heading=title_s,
                heading_is_natural_key=None,
                body=_body,
                parent=None,
                previous=None,
                )


def _add_newline(s):
    # not needing newlines in the tests make them easier to read
    # but let's add a sanity check because this breaks a deep convention
    assert(0 == len(s) or '\n' != s[-1])
    return f'{s}\n'


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')

# #born.
