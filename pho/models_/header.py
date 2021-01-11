def TING_via_TING(section_scn, notecard_scn):
    o = _header_functions()
    md_header_sexp_via_heading = o.md_header_sexp_via_heading
    demote_by_one = o.demote_by_one
    demote_by_two = o.demote_by_two

    heading = None  # although the first notecard had one, pretend it didn't
    while True:  # for each section

        if section_scn.empty:
            xx("notecard with no sections (no body) behavior undefined")

        demote = demote_by_one
        use_hdr_sx = None

        # The first section in the body needs to reconcile heading & header
        hdr_sx, crs = section_scn.next()
        if heading:
            hdr_from_heading = md_header_sexp_via_heading(heading)

            # If heading AND header..
            if hdr_sx:
                # ..then heading in own section with no content runs
                yield 'section', hdr_from_heading, None

                # ..and every header in this body gets demoted by 2
                demote = demote_by_two
                use_hdr_sx = demote(hdr_sx)

            # Otherwise (and heading but no header)..
            else:
                use_hdr_sx = hdr_from_heading  # ..use the heading as header

        # Otherwise, if (no heading but) header
        elif hdr_sx:
            use_hdr_sx = demote(hdr_sx)

        yield 'section', use_hdr_sx, crs

        # For the remaining sections in this body, demote appropriately
        while section_scn.more:
            hdr_sx, crs = section_scn.next()
            use_hdr_sx = hdr_sx and demote(hdr_sx)
            yield 'section', use_hdr_sx, crs

        if notecard_scn.empty:
            break
        heading, section_scn = notecard_scn.next()


def _header_functions():
    if _header_functions._do:  # [#510.4] custom memoizer
        _header_functions._do = False
        for k, f in _build_header_functions():
            setattr(_header_functions, k, f)
    return _header_functions


_header_functions._do = True


def _build_header_functions():  # #here5

    def build_demoter(how_much):
        def demote(sx):
            assert 'header_line' == sx[0]
            mdh = via_line(sx[1])
            mdh = mdh.replace_depth(mdh.depth + how_much)  # #here5
            return 'md_header', mdh
        return demote

    yield 'demote_by_one', build_demoter(1)
    yield 'demote_by_two', build_demoter(2)

    def func(heading):
        # Ever header we make from a heading gets demoted by 1
        return 'md_header', construct(2, '', heading, '')

    yield 'md_header_sexp_via_heading', func

    from pho.magnetics_.abstract_document_via_native_markdown_lines import \
        markdown_header_via_header_line_ as via_line, \
        MarkdownHeader_ as construct


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #pending-rename
# #history-B.4: blind rewrite
# #abstracted
