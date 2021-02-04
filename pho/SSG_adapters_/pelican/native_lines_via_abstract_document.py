"""DISCUSSION

This is a big giant rough sketch. The central point of it is to prove the
concept, to fill in this essential hole in the build pipeline, and to get
us writing and using the system.

We find it HIGHLY LIKELY that we will want to attempt at least most of
these refactorings down the road, but we didn't want to early abtract them:

- One day if there's ever another SSG adapter, abstract out parts of this.
  This is sort of a proving ground for finding out what kind of facilities
  an SSG adapter would need.
  (29 days later, it looks like no: we won't abstract anything lol)

- There are existing redundancies between this and the year old plus work
  of turning notecards into hugo (yikes) documents. It would be best to
  back-factor this new work into the old work, once this settles.
  (29 days later: again no)
"""


from collections import namedtuple as _nt


def native_lines_via_abstract_document(ad, listener):

    # If the last section is this one thing, take it off
    doc_meta_section = None
    sections = list(ad.sections)
    if _last_section_is_document_meta_section(sections):
        doc_meta_section = sections.pop()
    del doc_meta_section  # for now just meh

    # Normalize the depth of the section headers to make room for title (H1)
    orig_depths, sections = _normalize_header_depth(sections, 2)

    # Derive abstract title
    def cpather():
        return ad.classified_path
    yn, title = _derive_abstract_title(
            ad.frontmatter, orig_depths, sections, cpather)
    if yn:
        # the SSG's template (the ones we've seen) produce an H1 for the title,
        # so if you derived the title from the first section header, you don't
        # want to repeat that same text in a smaller header immediately after
        sections[0] = sections[0].replace_header(None)

    assert '"' not in title

    # Vendor will etc but we want to etc
    entry = _entry_via_title(title, listener)
    if entry is None:
        return

    # Something terrifying about children
    # (for use with our "strict_nav_tree" plugin)
    cx_line = None
    OHAI = getattr(ad, 'CHILDREN_DOCUMENT_HEAD_NODES', None)
    if OHAI:
        slugger = _sluggerer()
        ugh = []
        for ch_node in OHAI:
            slug = slugger(ch_node.heading, listener)
            if slug is None:
                return
            ugh.append(slug)
        cx_line = f"children: {' '.join(ugh)}\n"

    def to_normalized_lines():
        yield f"title: {title}\n"  # NO QUOTES! quotes will end up in final tit
        if cx_line:
            yield cx_line
        yield "date: 1925-05-19 12:13:14+05:00\n"
        # At #history-B.4 changing from pages to articles so now we need dates,
        # but we do NOT want to let default peloocan determine our order
        # nor etc. Later we will probably derive dates from etc..

        # (we don't need the rest of the frontmatter)

        for section in sections:
            for line in section.to_normalized_lines():
                yield line

    wlines = to_normalized_lines()
    return _these(entry=entry, title=title, write_lines=wlines)


func = native_lines_via_abstract_document


_these = _nt('these', ('entry', 'title', 'write_lines'))


# == ..

def _entry_via_title(title, listener):  # #testpoint
    """
    A head notecard's heading is ANY non-empty string (assume). From the
    heading we get (directly??) the title as it appears in the *abstract*
    frontmatter. Now, *somehow* we get from the abstract frontmatter title to
    the actual frontmatter title in the outputted vendor markdown document.

    A basic fact of life for SSGs (and web in general) is that there are
    characters you might want in an on-screen title that you won't want in
    filesystem paths (and relatedly, url paths). The latter are composed of
    components called "slugs".

    Presumably every SSG has some function (exposed or emergent) that gets you
    from frontmatter title to filesystem entry (filename (just basename)).
    (In peloogan it's `util.slugify` plus settings.)

    The thing is, we need to be sure we know what filesystem entry (slug plus)
    extension) the SSG will derive from its frontmatter, because we use
    filesystem paths (not frontmatter titles) to specify which outputted html
    document we want to reload on. If the strings don't line up, we will
    silently fail to generate the final document.

    At first we prototyped a lengthy but robust "slugify" of our own, and then
    after the fact we pried into vendor internals to see how they did it.

    At writing, not sure what the end pipeline will be with respect to our own
    code vs theirs, but the point is we have to be able to know (beforehand)
    what slug the vendor will derive from our title, so we can request to
    output the correct document. See (Case3782) and maybe others nearby.
    """

    return (slug := _sluggerer()(title, listener)) and ''.join((slug, '.md'))
    # (There's your hard-coded ".md" ☝️ :P)

    if False:  # tests run faster without this (~1000ms), vendor is bloated
        entry = None  # no
        vendor_entry = _vendor_entry_via_title(title)
        if entry != vendor_entry:
            xx(f"Interesting: {entry!r} vs {vendor_entry!r}")


def _vendor_entry_via_title(title):
    from pelican.settings import DEFAULT_CONFIG as conf
    from pelican.utils import slugify
    slug = slugify(title, regex_subs=conf['SLUG_REGEX_SUBSTITUTIONS'])
    return f"{slug}.md"


def _sluggerer():  # #testpoint
    o = _sluggerer
    if o.x is None:
        o.x = _build_slugger()
    return o.x


_sluggerer.x = None  # [#510.4]


def _build_slugger():

    def work(title, listener):

        def main():
            words = words_via_title(title, listener)
            pcs = (pc for pc in (piece_via_word(w) for w in words) if len(pc))
            return '-'.join(pcs)

        listener = throwing_listener_via(listener)
        try:
            return main()
        except stop:
            pass

    def piece_via_word(w):
        return replace_these_rx.sub('', w).lower()

    def words_via_title(title, listener):

        # Require at least one word
        scn = StringScanner(title, listener)
        yield scn.scan_required(word)
        while scn.more:

            # If there's something after one word, it has to be space
            scn.skip_required(space)

            # Assert another word
            yield scn.scan_required(word)

    from text_lib.magnetics.string_scanner_via_string import \
        StringScanner, pattern_via_description_and_regex_string as o
    import re as _re

    word = o('word', r'\S+')
    space = o('space', r'\s+')

    replace_these_rx = _re.compile(r'[^\w-]+')  # adapted from vendor & django

    def throwing_listener_via(listener):
        def use_listener(sev, *rest):
            listener(sev, *rest)
            if 'error' == sev:
                raise stop()
        return use_listener

    class stop(RuntimeError):
        pass

    return work


def _derive_abstract_title(frontmatter, orig_depths, sections, cpather):

    # One thing we didn't love about hugo that we similarly don't love
    # about peloogan is the requirement that you specify a title in the
    # frontmatter, when a title can generally be derived from the filename
    # or the first header (when it looks title-y). In fact we wrote a script
    # long ago to derive the requisite frontmatter from other things.
    # (one month later we are starting to see the light)

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


# == BEGIN probably move to the module dedicated to this? #todo

def _normalize_header_depth(sections, target_depth):

    dct = _depths_index_via_sections(sections)
    yield dct  # we're gonna use this in title derivations

    # If none of the sections have headers, nothing to do
    if 0 == len(dct):
        yield sections
        return

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

# #history-B.4
# #born
