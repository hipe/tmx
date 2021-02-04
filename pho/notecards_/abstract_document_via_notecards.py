"""
# Overview

To get an output document from notecards may seem like it "should be easy",
but there are a lot of steps involved:

- Determine the list of notecards that make up the document (from some input
  argument; e.g., the document root node, or any arbitary node in the document)
- The any notecard heading and any headers in the notecard body must be
  reconciled and normalized else broken structure or other document hiccups
- Resolve document title from the (mandatory) document root node heading,
  reconciling it with the above
- Reference-style links (RSL's) must be merged, unified and reallocated
- From this we get an *abstract* document, which SSG adapters take as input



# Determining the notecards that make up a document

We derive a document from one or more notecards in the following
(EXPERIMENTAL (still at start of 2021)) formulation:

(After we painstakingly wrote it, we thought of two edits we want to make to
this, (one cosmetic and one substantial) but we're gonna save it for another
edit #todo.)

A notecard can have an attribute `is_document_root`. If present, this
attribute must have a value of `true`. (Eventually we may experiment with
procedural hierarchical demarcation, but not today.) (This part of having a
boolean attribute to demarcate it was added #history-B.4, 19 months after
birth.)

Now, every notecard has:

- zero or one parent notecard
- zero or more children notecards
- zero or one previous notecard
- zero or one next notecard

Experimentally (*very* experimentally) no notecard can have *both* a
previous *and* a parent. (*But* a notecard can have *both* a next *and*
children.)

Probably eventually we'll make it so the previous-next relationships
correspond to the ordered-children list of the parent. But if this is not
the case now, we'll just live with it. For now, we'll imagine this *is* the
case, and know that when we say previous/next we are talking about sibling
nodes with the same parent. (This broad issue is now [#407.D].)

Now, to obtain a document tree from any arbitrary node:

    Is it a document root node? Go to the appropriate section below.
    Otherwise (and it's not document root node),
    also go to the appropriate section below.

If it's not a document root node:

    Keep hopping up over the parent relationship until either there's
    no parent or the current parent is a document root node.
    If the former, the start node wasn't within a document.
    Otherwise (and you found the document root node) go to the next section.

From a document node:

    Traverse its children depth-first recursively BUT keep track of how
    deep you are from the first node:

    If the current node *is* a document root node,
        if it *is*  an immediate child of the first node,
            skip it. (it's okay that it's a document)
        otherwise,
            fail because you can't do this, it must be the other way
    otherwise (and it's not a document root node),
    [something about don't go deeper than depth N]
    otherwise yield and procede

(NOTE #todo the above is not implemented and we want to abandon it: A
"chapter" node (or "chapter section") node should not merely be a document
with children documents, because we want it to have a different depth in the
hierarchy. When there is such a change in what we conceive of as the
container type, it must correspond to structural relationships expressed
over the parent-child axis, not the previous-next axis. So the bottom line
is, documents can have no child documents (recursive).
This is NOT covered yet.)

In summary, a document is derived from any node by traversing upward from
it until the document root node is found, and then by traversing downwards
depth-first rescursively to find all the nodes. While doing so, these
constraints are effected:
    - It might end up that the start node wasn't "in" a document.
      (If we find this to be the case, we express it.)
    - Distance from the document root node to any child cannot exceed X
      (probably 5).
    - A document node can hypothetically NOT have children document nodes

But getting the list of notecards that make up a document is only the first
step. Before we can build an "abstract document" (suitable to be passed to
an SSG for final rendering), we have to:

- normalize headings and headers
- universalize/re-provision reference-style URLs



# Recociling any headers in body text and any heading, across notecards

The remainder of this text describes what we do with *headings* (as in
`heading` the attribute) and *headers* (a markdown feature in the `body` text)
and how we reconcile them together and normalize them.

Each notecard has zero or one heading, and then in its body string (lines)
any arbitrary subset of those lines can be a "header" (alla markdown) line
of any arbitrary "depth" (number of contiguous octothorps anchored to the
beginning of the string).

The trick here is how to decide what to do with the different headings
and in-body headers so that they coalesce to make a document that looks
"normal" for the target, but is also built from `body` blocks that look
"normal" in the context of our unwritten standard.

In detail:

  - Every notecard's (any) heading (when present) will express as either
    a heading (line) or the document title.

  - For those notecards whose body copy has headers, their most significant
    depth is one as stored. (I.e., write headers `# like this` normally.)

  - It seems from our current output target that headers of depth one are
    something of an imaginary "reserved" slot that's only used to express
    the title of the generated document, which (in turn) is expressed by us
    only in the frontmatter we produce, not in any headers in our body copy.
    (This is :[#883.3], and should be considered as *not* set-in-stone.)

  - As such, normally a body copy header of depth 1 gets "demoted" to have
    a depth of 2 and so on (at expression). #here5

  - The "head notecard" (first one) in a document will always have a heading,
    and that heading will always be expressed as the document title (and so
    not as a header line).

  - IFF a non-head notecard has a heading, that heading will express as a
    header. This further demotes any body copy headers in that notecard
    by one more level of depth (at expression).
"""


import re as _re


def document_notecards_in_order_via_any_arbitrary_start_node_(  # #testpoint
        start_notecard_EID, notecards, listener=None):

    doc_root_node = _find_document_root_node(
            start_notecard_EID, notecards, listener)
    if doc_root_node is None:
        return
    return _produce_all_document_notecards_depth_first_recursive(
        doc_root_node, notecards, listener)


def _produce_all_document_notecards_depth_first_recursive(
        doc_root_node, notecards, listener=None):

    def recurse(node, current_depth, do_horizontal=True):
        eid = node.identifier_string
        if eid in seen:
            xx(f"integrity error: circular reference. {eid!r} seen twice")
        seen.add(eid)
        yield node, current_depth

        # Discussion: despite how hard we are trying, we can't read our old
        # code enough to determine whether a node can have both children and
        # next [#407.D]. For now we'll write it assuming yes, and (depth first)
        # recurse into children before going "horizontal" to next..

        # Descend into each of any children
        s_a = node.children
        if s_a is not None:
            assert len(s_a)  # or not

            use_depth = current_depth + 1
            if _max_depth < use_depth:
                xx("max depth exceeded. not covered yet.")

            for eid in s_a:
                ch = notecards.retrieve_notecard(eid, listener)
                if not ch:
                    xx("integrity error (not covered)")  # #here3

                for ch_node, ch_depth in recurse(ch, use_depth):
                    yield ch_node, ch_depth

        if not do_horizontal:
            return

        # Traverse across each in the horizontal row
        eid = node.next_identifier_string
        if eid is None:
            return

        while True:
            next_node = notecards.retrieve_notecard(eid, listener)
            if not next_node:
                xx("integrity error (not covered)")  # #here3

            # NOTE we do NOT use an incremented depth: going horizontally
            for nn, n_depth in recurse(next_node, current_depth, False):
                yield nn, n_depth
            eid = next_node.next_identifier_string
            if eid is None:
                break

    seen = set()

    return recurse(doc_root_node, 0)


_max_depth = 5  # html headers <H1> thru <H6>


def _find_document_root_node(eid, notecards, listener=None):

    curr = notecards.retrieve_notecard(eid, listener)
    if curr is None:
        return None  # e.g malformed EID

    seen = set()
    while True:
        # If this is the document root node, you're done!
        if 'document' == curr.hierarchical_container_type:
            return curr

        # Little integrity check lol
        prev_eid = curr.previous_identifier_string
        parent_eid = curr.parent_identifier_string
        predecessor_eid = None
        if parent_eid:
            if prev_eid:
                xx("wat [#407.D]")
            predecessor_eid = parent_eid
        elif prev_eid:
            predecessor_eid = prev_eid

        # If this node doesn't have a parent, this one error
        if predecessor_eid is None:
            return _when_not_in_document(listener, len(seen), eid)

        curr = notecards.retrieve_notecard(predecessor_eid, listener)
        if curr is None:  # error was expressed above
            return

        if predecessor_eid in seen:
            xx("integrity error, circular child-parent relationships")

        seen.add(predecessor_eid)


# ==

def abstract_document_via_notecards_iterator_(itr):
    first_notecard = next(itr)

    def these():
        yield first_notecard.heading, first_notecard.body
        for nc in itr:
            yield nc.heading, nc.body

    kw = {'ncid': first_notecard.identifier_string}
    kw['datetime'] = first_notecard.document_datetime
    return _do_abstract_document_via_notecards(these(), **kw)


def _do_abstract_document_via_notecards(notecards, ncid=None, datetime=None):
    # Flat map each notecard body into its N sections while:
    # - emitting a special s-expression just for the heading-derived title
    # - re-provisioning RSL names to be correct in the scope of the document
    # - gathering RSL definitions for output in a final section at doc end
    # - reconciling heading-as-header with existing body headers
    # - normalizing header depth based on the above
    # #testpoint

    itr = _final_sexps(notecards)
    typ, title = next(itr)
    assert 'document_title' == typ

    def sects():
        for typ, sect in _sections(itr):
            assert 'section' == typ
            yield sect

    frontmatter = {'title': title}
    if datetime:
        frontmatter['document_datetime'] = datetime

    kw = {'path': None, 'ncid': ncid}

    from pho.magnetics_.abstract_document_via_native_markdown_lines import \
        AbstractDocument_ as func
    return func(frontmatter, tuple(sects()), **kw)


def _sections(itr):
    from pho.magnetics_.abstract_document_via_native_markdown_lines import \
            MarkdownSection_ as _markdown_section

    for sx in itr:
        typ = sx[0]
        if 'section' != typ:
            assert 'RSL_definitions' == typ
            rsl_defs = sx[1]
            break
        _, heading_sx, crs = sx

        md_hdr = None
        if heading_sx:
            typ, md_hdr = heading_sx
            assert 'md_header' == typ
        lines = None
        if crs:
            lines = tuple(_lines_via_content_runs(crs))

        yield 'section', _markdown_section(md_hdr, lines or ())

    for _ in itr:  # ick/meh
        assert()

    if 0 == len(rsl_defs):
        return

    lines = ("\n", *(o.to_line() for o in rsl_defs.values()))
    # (Hugo and maybe others require one blank line to separate it from etc)

    yield 'section', _markdown_section(None, lines)


def _lines_via_content_runs(crs):
    for sx in crs:
        typ, val = sx
        if typ in ('content_run', 'code_fence_run'):

            # == hotfix, for now, "fix" these bodies
            leng = len(val)
            assert leng
            if '\n' != val[-1][-1]:  # ..
                val = list(val)
                val[-1] = ''.join((val[-1], '\n'))
            # ==

            for line in val:
                yield line
            continue
        if 'blank_line_run' == typ:
            assert 1 == val  # .. where #todo
            yield '\n'
            continue
        assert()


def _final_sexps(notecards):

    def each_notecard():

        def cstacker():
            return ({'heading': heading},)

        for heading, body in notecards:
            itr = _sections_future_and_each_RSL_definition_run(body, cstacker)
            itr = sections_w_reprovisioned_RSLs(rsl_def_index, itr)
            yield heading, scanner(itr)

    from pho.notecards_.links_index_via_content_runs import these_two as func
    sections_w_reprovisioned_RSLs, rsl_def_index = func()

    from text_lib.magnetics.scanner_via import scanner_via_iterator as scanner

    # Build the notecard scanner (that accumulates RSL definitons)
    # The first notecard in the document is special: we use its heading as a ti
    notecard_scn = scanner(each_notecard())
    assert notecard_scn.more  # no notecards or no notecard bodies
    heading, section_scn = notecard_scn.next()
    assert heading  # every document-root notecard needs a heading [#883.2]
    yield 'document_title', heading

    from pho.notecards_.sections_via_headers_and_headings import func
    for sx in func(section_scn, notecard_scn):
        yield sx

    yield 'RSL_definitions', rsl_def_index.finish()


# ==

def _sections_future_and_each_RSL_definition_run(body, cstacker):

    body_sexps = _sexps_via_lines(_lines_via_body_string(body, cstacker))
    body_sexps = tuple(body_sexps)

    def future():
        return result_all_sections

    yield future

    def actions():
        # The only thing we yield out (return from one of the actions) is..

        def header_line():
            if o.header_line or o.content_runs:  # #here1
                flush_section()
            o.header_line = sx

        def blank_line_run():
            pass

        def content_run():
            if 'blank_line_run' == prev_typ and 'header_line' != prev_prev_typ:
                o.content_runs.append(_one_blank_line)
            o.content_runs.append(sx)

        def code_fence_run():
            if 'blank_line_run' == prev_typ and 'header_line' != prev_prev_typ:
                o.content_runs.append(_one_blank_line)
            o.content_runs.append(sx)

        def link_definition_run():
            return sx  # yield this out #here2

        return locals()
    actions = actions()

    def flush_section():
        crs = None
        if len(o.content_runs):
            crs = tuple(o.content_runs)
            o.content_runs.clear()
        hl = o.header_line
        o.header_line = None
        all_sections.append((hl, crs))

    all_sections = []

    o = flush_section  # #watch-the-world-burn
    o.header_line = None
    o.content_runs = []
    o.last_blank_line_run = None

    prev_prev_typ = None
    prev_typ = None
    for sx in body_sexps:
        typ = sx[0]
        res = actions[typ]()
        if res:
            yield res  # #here2
        prev_prev_typ = prev_typ
        prev_typ = typ

    if o.header_line or o.content_runs:  # #here1
        flush_section()

    result_all_sections = tuple(all_sections)


_one_blank_line = 'blank_line_run', 1


# == S-expressions via lines

def _sexps_via_lines(lines):  # #testpoint
    # 17 months later, trying to simplify, but still it's necessary to get an
    # AST from the body lines so we can transform headers and links.
    # one day #open [#882.F] proper markdown parsing

    # States #[#008.2]

    def from_beginning_state():
        yield blank_line, begin_blank_line_run
        yield header_line, yield_header_line
        yield open_code_fence_line, begin_code_fence_run
        yield link_definition_line, begin_link_definition_run
        yield otherwise, begin_content_run

    from_beginning_state.can_end = True

    def from_content_run():
        # by us, content lines are defined as "any line that doesn't match
        # these other cases", so it's ugly-ly redundant with the above state

        # (it feels like this wastes work for cases (matching a RSL def line
        # twice) but in practice, blank lines almost always break the run)

        yield blank_line, end_content_run
        yield header_line, end_content_run
        yield open_code_fence_line, end_content_run
        yield link_definition_line, end_content_run
        yield otherwise, continue_content_run

    from_content_run.can_end = True

    def from_link_definition_run():
        yield link_definition_line, continue_link_definition_run
        yield otherwise, end_link_definition_run

    from_link_definition_run.can_end = True

    def from_code_fence_run():
        yield close_code_fence_line, end_code_fence_run
        yield otherwise, continue_code_fence_run

    from_code_fence_run.can_end = False

    def from_blank_line_run():
        yield blank_line, continue_blank_line_run
        yield otherwise, end_blank_line_run

    from_blank_line_run.can_end = True

    # Tests

    def link_definition_line():
        # (we used to simply match for '[' as `first_character_of_line`
        # and hope for the best, but then we read Gruber)
        md = _RSL_definition_rx.match(line)
        if md is None:
            return
        state.reference_style_link_definition_line_matchdata = md
        return True

    def open_code_fence_line():
        return _code_fence_rx.match(line)

    def close_code_fence_line():
        return _code_fence_rx.match(line)

    def header_line():
        return '#' == o.first_character_of_line

    def blank_line():
        return '\n' == line

    def otherwise():
        return True

    # Actions

    def func():
        pass

    from_beginning_state.final_yield = func

    # Actions: content run

    def begin_content_run():
        state.content_run_lines = []
        state.content_run_lines.append(line)
        stack_push(from_content_run)

    def continue_content_run():
        state.content_run_lines.append(line)

    def func():
        assert state.content_run_lines
        return end_content_run()

    from_content_run.final_yield = func

    def end_content_run():
        tup = tuple(state.content_run_lines)
        state.content_run_lines = None
        stack_pop()
        return 'yield_and_redo', ('content_run', tup)

    # Actions: link def run

    def begin_link_definition_run():
        state.link_definition_matchdatas = []
        continue_link_definition_run()
        stack_push(from_link_definition_run)

    def continue_link_definition_run():  # be careful, called as normal func
        md = state.reference_style_link_definition_line_matchdata
        state.reference_style_link_definition_line_matchdata = None
        state.link_definition_matchdatas.append(md)

    def func():
        assert state.link_definition_matchdatas
        return end_link_definition_run()

    from_link_definition_run.final_yield = func

    def end_link_definition_run():
        tup = tuple(state.link_definition_matchdatas)
        state.link_definition_matchdatas = None
        stack_pop()
        return 'yield_and_redo', ('link_definition_run', tup)

    # Actions: code fence run

    def begin_code_fence_run():
        state.code_fence_lines = []
        state.code_fence_lines.append(line)
        stack_push(from_code_fence_run)

    def continue_code_fence_run():
        state.code_fence_lines.append(line)

    def func():
        assert state.code_fence_lines
        return end_code_fence_run()

    from_code_fence_run.final_yield = func

    def end_code_fence_run():
        state.code_fence_lines.append(line)
        tup = tuple(state.code_fence_lines)
        state.code_fence_lines = None
        stack_pop()
        return 'yield_this', ('code_fence_run', tup)

    # Actions: blank line run

    def begin_blank_line_run():
        state.number_of_blank_lines = 1
        stack_push(from_blank_line_run)

    def continue_blank_line_run():
        state.number_of_blank_lines += 1

    def func():
        assert state.number_of_blank_lines
        return end_blank_line_run()

    from_blank_line_run.final_yield = func

    def end_blank_line_run():
        num = state.number_of_blank_lines
        state.number_of_blank_lines = None
        stack_pop()
        return 'yield_and_redo', ('blank_line_run', num)

    # Actions: header

    def yield_header_line():
        return 'yield_this', ('header_line', line)

    # ==

    def stack_push(func):
        stack.append(func)

    def stack_pop():
        assert 1 < len(stack)
        stack.pop()

    class memo:
        def clear(self):
            self._char = None

        @property
        def first_character_of_line(self):
            if self._char is None:
                self._char = line[0]
            return self._char

    o = memo()
    state = o  # #[#510.2] blank state (in effect)
    stack = [from_beginning_state]

    for line in lines:
        o.clear()
        while True:
            action = next(action for tester, action in stack[-1]() if tester())
            direc = action()
            if direc is None:
                break
            typ, value = direc
            if 'yield_and_redo' == typ:
                yield value
                continue
            assert 'yield_this' == typ
            yield value
            break

    if not stack[-1].can_end:
        xx(f"was in state '{stack[-1].__name__}' when reached end of input")

    direc = stack[-1].final_yield()
    if direc:
        typ, value = direc
        assert typ in 'yield_and_redo', 'yield_this'
        yield value

    assert 1 == len(stack)


# == Whiners

def _when_not_in_document(listener, num_hops, eid):
    def lines():
        if num_hops:
            and_what = f"and none of its {num_hops} predecessor(s) are either"
        else:
            and_what = "and it has no parents"
        yield f"'{eid}' is not in a document: it is not a document root node {and_what}"  # noqa: E501
    listener('error', 'expression', 'node_not_in_document', lines)


# == Smalls

def _lines_via_body_string(big_string, cstacker):  # #[#610]
    """(Discussion: this was a oneliner before, but now we normalize the last

    line to ensure it's always newline-terminated even if the big string
    didn't enter storage that way. (So this is a lossy codex: we don't retrieve
    what is stored; we munge two cases of input into one output.)
    This is for poka-yoke: to accomodate the way we typically terminate bodies
    "by hand", in the manner that looks right (but isn't); so (in turn)
    regexes like #here4 can assume every line is newline-terminated. hotfix.

    We don't split because it wastes memory. Also it's orthogonal to above.)
    """

    leng = len(big_string)
    if 0 == leng:
        context = {k: v for frame in cstacker() for k, v in frame.items()}
        xx(f"empty body? not covered yet ({context!r})")

    # Produce the 0-N head-anchored normal strings in the 1-N length big string
    itr = _re.finditer('[^\n]*\n', big_string)
    md = None
    for md in itr:
        yield md[0]

    # Determine if we didn't traverse the full string and if not, transform
    def stop():
        if md:
            stop = md.span()[1]
            if stop < leng:
                return stop
            return

        # If we didn't even match one
        assert leng
        assert '\n' not in big_string
        return 0
    stop = stop()
    if stop is not None:
        raw_string = big_string[stop:]
        yield ''.join((raw_string, '\n'))


# == Regexen

# RSL = reference-style link
# #wish break out the title part into a second pass because too strict
_RSL_definition_rx = _re.compile(r'''     # NOTE all var names are #testpoint
        (?P<margin>[ ]{0,3})              # Gruber says up to 3 spaces
        \[
            (?P<link_identifier>
                [a-zA-Z0-9][a-zA-Z0-9_]*  # Gruber doesn't say the rules here
            )
        \]
        :
        (?P<second_whitespace>
          [ \t]+                          # "one or more spaces (or tabs)" -G
        )
        (?P<link_url>
            [^ \t\n]+                     # we're not gonna parse URL's here
        )
        (?:
            (?P<third_whitespace>[ \t\n]+)  # gonna just assume this
            (?:
                "(?P<double_quoted_insides>(?:[^"\\]|\\")+)"
                |
                '(?P<single_quoted_insides>(?:[^'\\]|\\')+)'
                |
                \((?P<parenthesized_insides>[^)]+)\)
            )
        )?
        \n\Z''', _re.VERBOSE)  # #here4 is link identifier regex


_code_fence_rx = _re.compile(r'```(?:[a-z\(]|$)')  # ick/meh


def xx(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')

# #history-B.5: blind rewrite of 17 months older code
# #history-B.4
# #history-A.3: refactored from S-expressions's to AST's
# #history-A.2: document fragment moves to own file
# #history-A.1: introduce footnote merging
# #born.
