"""DISCUSSION

This is a big giant rough sketch. The central point of it is to prove the
concept, to fill in this essential hole in the build pipeline, and to get
us writing and using the system.

We find it HIGHLY LIKELY that we will want to attempt at least most of
these refactorings down the road, but we didn't want to early abtrac them:

- One day if there's ever another SSG adapter, abstract out parts of this.
  This is sort of a proving ground for finding out what kind of facilities
  an SSG adapter would need.

- There are existing redundancies between this and the year old plus work
  of turning notecards into hugo (yikes) documents. It would be best to
  back-factor this new work into the old work, once this settles.
"""


def native_lines_via_abstract_document(ad):

    # If the last section is this one thing, take it off
    doc_meta_section = None
    sections = list(ad.sections)
    if _last_section_is_document_meta_section(sections):
        doc_meta_section = sections.pop()
    del doc_meta_section  # for now just meh

    # Normalize the depth of the section headers to make room for title (H1)
    orig_depths, sections = _normalize_header_depth(sections, 2)

    # Derive title
    def cpather():
        return ad.classified_path
    yn, title = _derive_title(ad.frontmatter, orig_depths, sections, cpather)
    if yn:
        # the SSG's template (the ones we've seen) produce an H1 for the title,
        # so if you derived the title from the first section header, you don't
        # want to repeat that same text in a smaller header immediately after
        sections[0] = sections[0].replace_header(None)

    assert '"' not in title

    def to_normalized_lines():
        yield f"title: {title}\n"  # NO QUOTES! quotes will end up in final tit
        # (we don't need the rest of the frontmatter)

        for section in sections:
            for line in section.to_normalized_lines():
                yield line

    return title, to_normalized_lines()


func = native_lines_via_abstract_document


# == ..


def _derive_title(frontmatter, orig_depths, sections, cpather):

    # One thing we didn't love about hugo that we similarly don't love
    # about peloogan is the requirement that you specify a title in the
    # frontmatter, when a title can generally be derived from the filename
    # or the first header (when it looks title-y). In fact we wrote a script
    # long ago to derive the requisite frontmatter from other things.

    # Anyway, now that some native documents have frontmatter and others
    # don't, we now use the frontmatter (when present) as the authoritative
    # source for the title; but now that we think about it we might go thru
    # and make these files dumb again

    if frontmatter and (s := frontmatter.get('title')):
        return False, s

    # This is a hoot: following the above rationale (it costs significantly
    # less to change a line of text than to rename a file), let's brazenly
    # derive our title from an in-document header when it matches a certain
    # pattern: Derive the title from the first header in the document if it's
    # an `<H1>` and it was the only H1 in the document (after doc meta removed)

    if ((arr := orig_depths.get(1)) and 1 == len(arr) and 0 == arr[0]):
        return True, sections[0].header.label_text

    # In a simple, ideal world (only of full documents not notecards), we
    # always name our files based on the title we want, and all headers are
    # section headers

    cpath = cpather()
    return False, cpath.derived_title


# == BEGIN probably move to place in models_

def _normalize_header_depth(sections, target_depth):

    dct = _depths_index_via_sections(sections)
    yield dct  # we're gonna use this in title derivations

    # How far down do we have to push the depths to meet the target?
    shallowest = min(dct.keys())
    push_by = target_depth - shallowest

    if not _decide_whether_to_push_depths(push_by, dct):
        yield sections
        return

    def replace(section):
        header = section.header
        if header is None:
            return section
        new_header = header.replace_depth(header.depth + push_by)
        return section.replace_header(new_header)

    yield [replace(sect) for sect in sections]


def _decide_whether_to_push_depths(push_by, dct):
    # Do we mutate it or do we leave it as is?

    # If the shallowest depth is at the target depth, nothing
    if 0 == push_by:
        return

    # If the shallowest depth is deeper than the target depth, nothing 👀
    if push_by < 0:
        return

    # How much clearance do you have between the deepest header and the max?
    deepest = max(dct.keys())
    under_by = 6 - deepest

    # If we don't have enough clearance to be able to meet the target,
    #   - we don't want to exceed the max allowable depth of header
    #     (there is no H7 tag)
    #   - we don't want to crush (flatten) the deepest depths into each other,
    #     clobbering meaningful structural relationships between sections
    # just take the L

    if under_by < push_by:
        return

    return True  # we made it! do the thing


def _depths_index_via_sections(sections):

    # Make an index structure to answer: what is shallowest and where
    def offset_and_depth():
        offset = -1
        for sect in sections:
            offset += 1
            header = sect.header
            if header:
                yield offset, header.depth
    dct = {}
    for offset, depth in offset_and_depth():
        if (arr := dct.get(depth)) is None:
            dct[depth] = (arr := [])
        arr.append(offset)

    return dct


# == END


def _last_section_is_document_meta_section(sections):
    if 0 == len(sections):
        return
    if (header := sections[-1].header) is None:
        return
    return 'document-meta' == header.label_text


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #born
