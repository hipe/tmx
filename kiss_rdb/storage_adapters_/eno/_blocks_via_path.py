# NOTE: our main focus at #birth is to build out our main algorithm
# (described #here5) involving partitioning an "edit" into file-specific
# edits and then applying each of those to the stream of "entity blocks"
# expressed by the file to produce a stream of new lines representing the
# new lines of the file.
#
# In part because python's eno implementation takes as input "big strings"
# rather than filesystem paths (it reads the whole (potentially huge) file
# into memory rather than parsing a file in a streaming manner; later for
# this..), and in part thanks to python's `difflib`, we are able to get as
# far as turning our edit into one or more "patchfiles" (lines in memory)
# relatively straightforwardly with "pure programming" and without too many
# hacks; that is, without having to make system calls or (if we want not to)
# read the filesystem.
#
# HOWEVER, when it comes time to actually applying the change to the collection
# is where things get more fragile and tricky. AS IT STANDS NOW, WE DO THIS
# IN A NON-TRANSACTIONAL, NON-ATOMIC WAY WHERE WE MIGHT END UP CORRUPTING THE
# COLLECTION BECAUSE WE DON'T HAVE SEVERAL IMAGINED SAFEGUARDS IN PLACE
# We explain this possible scenario more below in our wishlist.
#
# This is done in the interest of getting to an MVP in only two years. But:
#
# A wishlist (in order from easiest to most ideal/abstract/lofty):
#
# - Two-pass application of the patch files to better achieve transactional
#   atomicicity. As it stands, if for whatever some of the chunks are rejected,
#   the collection in left in a corrupt state. We want it to be all or nothing.
#   A solution to this is to write the output of the patches to a series of
#   tempfiles (one for each target file), and then only at the end if all the
#   patches succeed, rename each tempfile to the real file.
#
# - a necessary injection of a VCS adapter. Require that the collection on
#   the filesystem is "pristine" (in version control) before allowing a patch
#   to be applied.
#
# - semaphores!? concurrency yikes


# cf = collection facade

def new_file_lines__(file_edit, cf, order, emi, **body_of_text):
    for block in _new_file_blocks(file_edit, cf, order, emi, **body_of_text):
        for line in block.to_lines():
            yield line


def _new_file_blocks(edit_via_attr_via_eid, cf, order, emi, **body_of_text):  # noqa: E501 #testpoint
    # This is the center of the whole algorithm :#here5:
    #
    # We take a stream of existing entities and a stack of edits and output
    # a stream of lines.
    #
    # As you work, assert that the file's entity sections are in order.
    # Arrange your own units of work in a stack with lowest eid at the top.
    # Stream over the existing entities and at each entity:
    # (Assert that it's in order with respect to other entities you traversed)
    # If this entity's eid is lower than that of the top of your stack,
    # pass it through (its lines).
    # If this entity's eid is higher than the top of your stack, keep popping
    # off elements of the stack until this is not true at the top of the stack.
    # Now you have a queue of entities to create (insert). This is for later.
    # If you've gotten this far, the eid at the top of your stack is equal to
    # that of the current exisitng entity.
    # This entity edit is either a delete or an update. (Assert this.)
    # Delete is for later.
    # This is where we update the entity.
    # Get the lines for the updated entity in a different function

    stop = emi.stop
    listener = emi.listener

    from . import body_of_text_ as func
    body_of_text = func(**body_of_text)

    p = cf.build_identifier_function_(listener)
    idens = tuple(p(eid) for eid in edit_via_attr_via_eid.keys())
    assert(emi.OK)
    stack = list(reversed(sorted(idens)))

    def create_entity():
        value_via_dattr, = cud_stack  # (pray that #here6 formatted this)
        _ = tuple(_create_entity_lines(eid, value_via_dattr, order, emi.stop))
        return _pass_thru_block(_)

    def cud_stacker():
        return list(reversed(edit_via_attr_via_eid.pop(eid)))

    prev_doc_iden = None

    itr = document_sections_via_BoT_(body_of_text, cf, emi.monitor)
    for entb in itr:

        if entb.is_pass_thru_block:
            if entb.is_document_meta_section:
                document_meta_section = entb
                break
            yield entb
            continue

        doc_iden = entb.entity.identifier

        # Stop if existing document is out of order
        if not (prev_doc_iden is None or prev_doc_iden < doc_iden):
            stop(_entity_order_in_doc, prev_doc_iden, doc_iden, body_of_text)
        prev_doc_iden = doc_iden

        # While there are any edits and they come before the cursor, insert
        while len(stack) and stack[-1] < doc_iden:
            eid = stack.pop().to_string()
            cud_stack = cud_stacker()
            cud_type = cud_stack.pop()
            assert('create_entity' == cud_type)
            yield create_entity()

        # If no remaining edits, just pass thru
        if not len(stack):
            yield entb
            continue

        # There is a remaining edit that is equal or greater
        if doc_iden < stack[-1]:
            # If the head edit comes after the current entity, keep searching
            yield entb
            continue

        # Since the remaining edit wasn't before or after..
        request_iden = stack.pop()
        assert(doc_iden == request_iden)
        eid = request_iden.to_string()
        cud_stack = cud_stacker()
        cud_type = cud_stack.pop()

        if 'update_entity' == cud_type:
            update_params, = cud_stack
            de = _updated_document_entity(entb, update_params, order, emi)
            yield de
            continue

        if 'delete_entity' == cud_type:
            # To implement delete, all we need to do is skip the output of
            # the entity-section (and don't forget the index file)

            # (This was more complicated when we had a dangling slot-A)

            # This is annoying: currently, we might have explicit deletes of
            # specific fields (while also deleting the whole entity) because
            # we needed to trigger updates in the pointbacks

            if len(cud_stack):
                attr_cud_via_dattr, = cud_stack
                for k, tup in attr_cud_via_dattr.items():
                    attr_cud_type, = tup
                    assert('delete_attribute' == attr_cud_type)
            _check_delete_entity_OK(entb, stop)
            continue

        assert('create_entity' == cud_type)
        stop(_create_collision, doc_iden, body_of_text)

    # Any remaining stack items must be "non-clingy", i.e. creates..

    while len(stack):
        request_iden = stack.pop()
        eid = request_iden.to_string()
        cud_stack = cud_stacker()
        cud_type = cud_stack.pop()
        assert('create_entity' == cud_type)
        yield create_entity()

    yield document_meta_section
    for _ in itr:
        assert()


def _create_entity_lines(eid, value_via_dattr, order, stop):

    from kiss_rdb.storage_adapters_.eno import section_line
    yield section_line(f'entity: {eid}: attributes')

    pool = set(value_via_dattr.keys())
    for key in order:

        if key not in value_via_dattr:
            continue
        pool.remove(key)  # ..

        value = value_via_dattr[key]
        assert(value is not None)  # ..

        typ = _eno_type_via_value(value)
        lines = _attribute_block_head_lines_via(typ, value, key)
        for line in lines:
            yield line

    if len(pool):
        stop(xx, "attribute names not in whitelist")

    yield '\n'  # because [#873.K] there's always a trailing document-meta sect


def _updated_document_entity(entb, edit_via_dattr, order, emi):

    _ = _edited_attribute_blocks(entb, edit_via_dattr, order, emi.stop)
    attribute_blocks = tuple(_)

    if not emi.monitor.OK:
        return

    identity_line = entb.identity_line

    slot_B_lines = entb.slot_B_lines

    def to_lines():
        yield identity_line
        for ab in attribute_blocks:
            for line in ab.to_lines():
                yield line

    return _entity_block_via(
        identity_liner=lambda: identity_line,
        slot_B_lineser=lambda: slot_B_lines,
        attribute_blockser=lambda: attribute_blocks,
        to_lines=to_lines)


def _edited_attribute_blocks(entb, edit_via_dattr, order, stop):
    # Elsewhere, we assert that existing entities occur in order in their file.
    # For attributes, however, there is no equivalent requirement.
    # (We should still require their constituential uniqueness, however.)
    # (Also we will assert the order as an allowlist against both for now.)
    # The concern of ordering does not impact updates or deletes, only creates:
    # The insertion point is determined as if the existing entity is in order:
    # Each next attribute to be inserted is kept in an ordered stack. As each
    # next existing attribute is encountered, while the top of the stack has
    # an attribute that comes before the current existing attribute, emit it.
    # Emit any remaining creates at the end.

    order_offset_via_dattr = {order[i]: i for i in range(0, len(order))}
    creates, updates_and_deletes = _prepare_edit(
            edit_via_dattr, order_offset_via_dattr)

    seen = set()
    for attrb in entb.attribute_blocks:
        dattr = attrb.key

        # Assert existing attribute name against allowlist and constituency
        where = order_offset_via_dattr[dattr]  # assert the allowlist
        assert(dattr not in seen)
        seen.add(dattr)

        # Emit every attribute to be inserted while it goes before current
        while len(creates) and order_offset_via_dattr[creates[-1][0]] < where:
            yield _new_attribute_block(* creates.pop())  # #here4

        # Is there an edit for this attribute?
        edit = updates_and_deletes.pop(dattr, None)
        if edit is None:
            yield attrb
            continue

        # There is an edit for this attribute
        cud_type, *params = edit
        if 'delete_attribute' == cud_type:
            # delete simply means do nothing (what about comment rules tho)

            clinz = _check_edit_attribute_OK(attrb, stop)
            if 1 < len(clinz):
                yield _pass_thru_block(clinz)  # prob has leading blank line
            continue

        assert('update_attribute' == cud_type)
        yield _edited_attribute(attrb, *params, stop)

    # Are there edits that didn't get consumed from the pool above?
    if len(updates_and_deletes):
        stop(_edits_for_attributes_not_already_set, updates_and_deletes)

    # Any inserts that didn't get triggered by above
    while len(creates):
        yield _new_attribute_block(* creates.pop())  # #here4


def _prepare_edit(edit_via_dattr, order_offset_via_dattr):  # asserts for now
    unordered_creates = []
    updates_and_deletes = {}

    for dattr, edit in edit_via_dattr.items():
        order_offset_via_dattr[dattr]  # assert allowlist against request
        cud_type = edit[0]
        if 'create_attribute' == cud_type:
            unordered_creates.append((dattr, *edit[1:]))
            continue
        assert(cud_type in ('update_attribute', 'delete_attribute'))
        updates_and_deletes[dattr] = edit

    # For creates, discard request order. They must be in formal order.
    def key(create):
        return order_offset_via_dattr[create[0]]
    creates = list(sorted(unordered_creates, key=key, reverse=True))

    return creates, updates_and_deletes


def file_units_of_work_via__(entities_units_of_work, cf, emi):
    # (we assert the beginning term of each uow below)

    file_units_of_work = []
    file_UoW_offset_via_path = {}

    stop = emi.stop
    listener = emi.listener

    def safe_add(mixed):
        if dattr not in dct:
            dct[dattr] = mixed
            return
        curr = dct[dattr][0]  # #here3: hard-coded doo-hahs
        stop(_multiple_operations_on_one_attr, entity_cud_type, dattr, curr, eid)  # noqa: E501

    def dictionary_via_eid(dct):
        pair = dct.get(eid)
        if pair is None:
            dct[eid] = (entity_cud_type, (ent_dct := {}))
        else:
            this_entity_cud_type, ent_dct = pair
            assert(this_entity_cud_type == entity_cud_type)
        return ent_dct

    def dictionary_via_path():
        i = file_UoW_offset_via_path.get(path)
        if i is None:
            # if we haven't seen this path before (yet) and it's an ent create,
            maybe_create = 'create_entity' == entity_cud_type
            fuow = _FileUnitOfWork(maybe_create)
            file_UoW_offset_via_path[path] = (i := len(file_units_of_work))
            file_units_of_work.append((path, fuow))

        return file_units_of_work[i][1].dictionary

    iden_via = cf.build_identifier_function_(listener)

    for entity_cud_type, eid, *rest in entities_units_of_work:

        _assert(iden := iden_via(eid))
        _assert(path := cf.path_via_identifier_(iden, listener))
        dct = dictionary_via_path()
        dct = dictionary_via_eid(dct)  # #here7

        if 'update_entity' == entity_cud_type:
            attr_cud_type, *rest = rest
            if attr_cud_type in ('update_attribute', 'create_attribute'):
                dattr, value = rest
                safe_add((attr_cud_type, value))  # #here4
            else:
                assert('delete_attribute' == attr_cud_type)
                dattr, = rest
                safe_add((attr_cud_type,))  # #here4

        elif 'create_entity' == entity_cud_type:
            attr_cud_type, dattr, value = rest
            assert('create_attribute' == attr_cud_type)
            safe_add(value)  # #here6
        else:
            assert('delete_entity' == entity_cud_type)
            if len(rest):
                attr_cud_type, dattr = rest
                assert('delete_attribute' == attr_cud_type)
                dct[dattr] = ('delete_attribute',)
            else:
                pass  # at #here7 we made {'ABC': ('delete_entity', {})}

    return tuple(file_units_of_work)


def _edited_attribute(attrb, new_value, stop):
    dattr = attrb.key
    existing_type = attrb.eno_type
    new_type = _eno_type_via_value(new_value)
    if existing_type != new_type:
        stop(_type_mismatch, existing_type, new_type, dattr)

    clines = _check_edit_attribute_OK(attrb, stop)

    lines = _attribute_block_head_lines_via(new_type, new_value, dattr)

    return _attribute_block_via(
        dattr, new_value, new_type, lambda: lines, lambda: clines, attrb.begin)


def _check_delete_entity_OK(entb, stop):

    if (clines := entb.slot_A_lines) is not None:
        name = 'slot_A_'
    elif len(clines := entb.slot_B_lines):
        name = 'slot_B_'
    else:
        # we want to check slot C but meh
        name = None

    if name is None:
        return

    from . import _machine_edit_check as lib
    stop(getattr(lib, name), clines, entb)


def _check_edit_attribute_OK(attrb, stop):
    # result in comment lines if OK

    dattr = attrb.key
    clines = tuple(attrb.to_tail_anchored_comment_or_whitespace_lines())

    if _is_touchy_trailing_comment_block(clines):
        stop(_wont_machine_edit_attribute, clines, dattr)

    if 'List' != attrb.eno_type:
        return clines

    itr = iter(attrb.to_head_anchored_body_lines())
    assert(f'{dattr}:\n' == next(itr))  # YIKES
    import re
    count = 0
    for line in itr:
        count += 1
        if re.match('^- ', line):
            continue
        stop(_list_item_looks_strange, line, count, dattr)

    return clines


def _is_touchy_trailing_comment_block(clines):
    return len(clines) and '\n' != clines[0]

# == END


def _existing_attribute_block(begin, end, el, line_index):

    # We are the attribute block.

    # We know the line offset of our first line, and we know the line offset
    # of the beginning of the next attribute/entity/end of file. So we know
    # the lines that are in our "block".

    # However, we don't know which of these lines (if any) are trailing or
    # interceding whitespace/comment lines. (We only know that our first line
    # is a content line.)

    # Fortunately, the vendor library unofficially gives us an index of ranges
    # into the "big string" (every character in the file in one .. big string)
    # that tells us the ending boundary of our content (in terms of big string
    # character offsets), and from this we can derive part of an answer to our
    # question, with some work :#here2

    from kiss_rdb.storage_adapters_.eno import \
            key_value_vendor_type_via_attribute_element_

    key, value, typ = key_value_vendor_type_via_attribute_element_(el)

    if 'Field' == typ:
        _, end_char = el._instruction['ranges']['value']
        middle = line_index.line_offset_via_character_offset(end_char) + 1
        # the above is the offset of our last content line plus 1, so it's the
        # offset of the first tail-anchored block of comment lines (or similar)
        # #todo maybe we don't need the crazy reverse
    elif 'Multiline Field Begin' == typ:
        middle = el._instruction['end']['line'] + 1
    else:
        assert('List' == typ)
        # we assume at least one item otherwise we wouldn't "know" it's a list
        _, end_char = el._instruction['items'][-1]['ranges']['line']
        middle = line_index.line_offset_via_character_offset(end_char) + 1

    lines = line_index.line_cache

    def to_head_anchored_body_lines():
        return (lines[i] for i in range(begin, middle))

    def to_tail_anchored_comment_or_whitespace_lines():
        return (lines[i] for i in range(middle, end))

    return _attribute_block_via(
            key, value, typ,
            to_head_anchored_body_lines,
            to_tail_anchored_comment_or_whitespace_lines, begin)


def _new_attribute_block(dattr, value):
    eno_type = _eno_type_via_value(value)
    lines = _attribute_block_head_lines_via(eno_type, value, dattr)

    class new_attribute_block:  # #class-as-namespace
        # (if you need more than this, use one of the existing classes)
        def to_lines():
            return lines
    return new_attribute_block


def _attribute_block_head_lines_via(eno_type, value, dattr):
    from kiss_rdb.storage_adapters_.eno import \
            list_lines, multiline_field_lines, field_line

    if 'Field' == eno_type:
        return (field_line(dattr, value),)

    if 'List' == eno_type:
        return tuple(list_lines(dattr, value))

    assert('Multiline Field Begin' == eno_type)  # ..
    assert(isinstance(value, str))  # #[#011]

    # Break a big string up into lines, while preserving the newline characters
    import re
    lines = [md[0] for md in re.finditer('[^\n]*\n|[^\n]+', value)]  # #[#610]

    # See `man git-log` near terminator vs separator semantics. The form data
    # we have coming in has newlines with separator sematics: a typical
    # multiline block of text looks like "line 1\nline2".

    # But according to the function we'll call below and everywhere else,
    # we want to be using terminator semantics. So as-is, that last component
    # is a malformed "line" because it's not terminated with a newline.

    # We do this change later not earlier to save on the memory hit of making
    # a copy of a big string just to add one character.

    # Note this might have a lurking bug: what if the form data comes in as
    # "line 1\nline 2\n" - it's likely this gets munged in to the below

    if len(lines) and '\n' != lines[-1][-1]:
        lines[-1] = ''.join((lines[-1], '\n'))

    output_lines = multiline_field_lines(dattr, lines)
    return tuple(output_lines)


def _eno_type_via_value(value):
    if isinstance(value, str):
        if '\n' in value:
            return 'Multiline Field Begin'
        assert(len(value))  # ..
        return 'Field'
    assert(isinstance(value, tuple))
    assert(len(value))
    return 'List'


def _line_index_via_lines(line_cache):
    # Bridge the gap between character offsets (into the "big string" of
    # every character in the file) and line offsets. mainly serve #here2

    # Given a character offset into the big string, find the line offset.

    # Currently this is achieved thru straight search but could be improved:

    # Find the first line whose beginning offset is AFTER (not equal to) the
    # argument offset. Your result is the offset of this line minus one. We
    # are guaranteed to find one for all offsets into the big string because
    # of #here1, an added extra end component signifying the start of the
    # imaginary next line after the last line in the file.

    # As it is written this is severly unoptimal. Performance will get worse
    # and worse as you increase the number of attributes you are looking up
    # and *as the entity gets lower in the file*!. We could improve it with a
    # B-tree but why.

    assert(isinstance(line_cache, tuple))  # #[#011]

    character_offsets = []
    total_characters_seen = 0

    for line in line_cache:
        character_offsets.append(total_characters_seen)
        total_characters_seen += len(line)

    character_offsets.append(total_characters_seen)  # #here1
    character_offsets = tuple(character_offsets)
    use_line_offset_range = range(0, len(character_offsets))

    class line_index:

        def line_offset_via_character_offset(_, char_offset):
            for line_offset in use_line_offset_range:
                if character_offsets[line_offset] <= char_offset:
                    continue
                return line_offset - 1
            assert()

        @property
        def line_cache(_):
            return line_cache

    return line_index()


# == Read Existing Blocks

def document_sections_via_BoT_(bot, cf, mon):

    docu = cf.eno_document_via_(body_of_text=bot)  # throw FileNotFound, others
    from . import document_sections_of_ as func
    itr = func(docu, bot.path, mon)
    itr = _add_line_starts(itr)
    line_index = _line_index_via_lines(bot.lines)
    itr = _add_line_ends(len(line_index.line_cache), itr)
    typ = None

    lines_pointer = []

    from . import read_only_entity_via_section_ as read_only_entity_via_section
    iden_via = cf.build_identifier_function_(mon.listener)

    for typ, eid, vendor_sect, beg, end in itr:
        if 'entity_section' != typ:
            break
        iden = iden_via(eid)
        ent = read_only_entity_via_section(vendor_sect, iden, mon)
        entb = _existing_entity_block(beg, end, ent, line_index)

        # if the previous entity had some slot B or slot C comments, take them
        if len(lines_pointer):
            entb = entb.but_with(slot_A_lines=lines_pointer.pop())
            assert(not len(lines_pointer))

        # if this entity has lines that belong to the next entity, store them
        matchdata = _matchdata_for_slot_A_of_next_section(entb)
        if matchdata is not None:
            entb, lines = _break_off_lines(entb, matchdata)
            lines_pointer.append(lines)

        yield entb

    assert('document_meta' == typ)

    if len(lines_pointer):
        xx()

    for _ in itr:
        assert()

    yield _document_meta_section(tuple(line_index.line_cache[beg:end]))


def _break_off_lines(entb, matchdata):
    from ._machine_edit_check import BREAK_OFF_LINES
    return BREAK_OFF_LINES(entb, *matchdata)


def _matchdata_for_slot_A_of_next_section(entb):

    attr_blocks = entb.attribute_blocks
    if len(attr_blocks):
        clines = attr_blocks[-1].to_tail_anchored_comment_or_whitespace_lines()
        clines = tuple(clines)
    else:
        clines = entb.slot_B_lines

    if not len(clines):
        return

    from ._machine_edit_check import MATCH_DATA
    break_here = MATCH_DATA(clines)
    if break_here is None:
        return

    _ = 'break_attr_clines' if len(attr_blocks) else 'break_slot_B_clines'
    return _, break_here, clines


def _add_line_ends(num_lines, itr):
    prev = None
    for prev in itr:
        break
    if prev is None:
        return
    for curr in itr:
        yield *prev, curr[-1]
        prev = curr
    yield *prev, num_lines


def _add_line_starts(itr):
    for typ, eid, vendor_sect in itr:
        i = _first_line_offset_of(vendor_sect)
        yield (typ, eid, vendor_sect, i)


def _first_line_offset_of(el):
    return el._instruction['line']  # not okay, technically


def _existing_entity_block(begin, end, ent, line_index):

    def to_lines():
        return line_index.line_cache[begin:end]

    def identity_line():
        return line_index.line_cache[begin]

    def slot_B_lineser():
        attrbs = state.attribute_blocks
        if len(attrbs):
            comments_end = attrbs[0].begin
        else:
            comments_end = end
        return tuple(line_index.line_cache[(begin+1):comments_end])

    class State:
        def __init__(self):
            self._slot_B_lines = None
            self._attr_blocks = None

        def slot_B_lines(self):
            if self._slot_B_lines is None:
                self._slot_B_lines = slot_B_lineser()
            return self._slot_B_lines

        @property
        def attribute_blocks(self):
            if self._attr_blocks is None:
                self._attr_blocks =\
                    tuple(_to_attribute_block_stream(ent, end, line_index))
            return self._attr_blocks

    state = State()

    return _entity_block_via(
        identity_liner=identity_line,
        slot_B_lineser=state.slot_B_lines,
        attribute_blockser=lambda: state.attribute_blocks,
        to_lines=to_lines,
        entity=ent)


def _to_attribute_block_stream(ent, end, line_index):

    def flush(end):
        el = previous_element.pop()
        begin = _first_line_offset_of(el)
        return _existing_attribute_block(begin, end, el, line_index)

    previous_element = []  # abuse

    for el in ent.VENDOR_SECTION_.elements():
        if len(previous_element):
            yield flush(_first_line_offset_of(el))
        previous_element.append(el)

    if len(previous_element):
        yield flush(end)


# == Models (that are not ad-hoc)

class _FileUnitOfWork:

    def __init__(self, yn):
        self.maybe_create_file = yn
        self.dictionary = {}


def _entity_block_via(
        identity_liner, slot_B_lineser,
        attribute_blockser, to_lines, entity=None, slot_A_lines=None):
    _ent = entity
    _slot_A_lines = slot_A_lines

    class entity_block:  # #class-as-namespace
        def but_with(
                self, slot_A_lines=None, slot_B_lines=None,
                attribute_blocks=None):
            o = {}
            o['slot_A_lines'] = (slot_A_lines or _slot_A_lines)
            o['identity_liner'] = identity_liner

            y = slot_B_lines is None
            o['slot_B_lineser'] = slot_B_lineser if y else lambda: slot_B_lines

            y = attribute_blocks is None
            o['attribute_blockser'] = attribute_blockser if y else lambda: attribute_blocks  # noqa: E501

            o['to_lines'] = None  # never pass through the original this
            o['entity'] = _ent
            return _entity_block_via(**o)

        @property
        def identity_line(_):
            return identity_liner()

        @property
        def slot_B_lines(_):
            return slot_B_lineser()

        @property
        def attribute_blocks(_):
            return attribute_blockser()

        def to_lines(self):
            if to_lines is not None:
                to_lines()
            if slot_A_lines is not None:
                for line in slot_A_lines:
                    yield line
            yield identity_liner()
            for line in slot_B_lineser():
                yield line
            for attr in attribute_blockser():
                for line in attr.to_lines():
                    yield line

        slot_A_lines = _slot_A_lines
        entity = _ent
        is_pass_thru_block = False
    return entity_block()


def _attribute_block_via(dattr, value, typ, head_lineser, tail_lineser, begin):

    _value = value
    _begin = begin

    class attribute_block:  # #class-as-namespace

        def but_with(tail_anchored_comment_or_whitespace_lines):
            def use_tail_lineser():
                return tail_anchored_comment_or_whitespace_lines
            return _attribute_block_via(
                dattr, value, typ, head_lineser, use_tail_lineser, begin)

        def to_lines():
            for line in self.to_head_anchored_body_lines():
                yield line

            for line in self.to_tail_anchored_comment_or_whitespace_lines():
                yield line

        to_head_anchored_body_lines = head_lineser
        to_tail_anchored_comment_or_whitespace_lines = tail_lineser
        key = dattr
        value = _value
        eno_type = typ
        begin = _begin

    return (self := attribute_block)


class _document_meta_section:
    # just like a pass thru block plus this one flag
    def __init__(self, lines):
        self._lines = lines

    def to_lines(self):
        return self._lines

    is_pass_thru_block = True
    is_document_meta_section = True
    block_type_name = 'document_meta_section'


def _pass_thru_block(lines):
    class pass_thru_block:  # #class-as-namespace
        def to_lines():
            return lines
        is_pass_thru_block = True
        block_type_name = 'generic'
    return pass_thru_block


# == Stops


def emitter_via_monitor__(mon):  # #testpoint

    class emitter:  # #class-as-namespace
        def stop(_, *args):
            _stopper_via_listener(mon.listener)(*args)

        @property
        def listener(_):
            return mon.listener

        @property
        def OK(_):
            return mon.OK

        monitor = mon

        @property
        def stopper_exception_class(_):
            return _Stop

    return emitter()


def _stopper_via_listener(listener):
    def stop(f, *args):
        lines = tuple(f(*args))  # meh
        listener('error', 'expression', 'edit_request_error', lambda: lines)
        raise _Stop()
    return stop


def _create_collision(iden, body_of_text):
    yield(f"can't create entity '{iden.to_string()}', entity already exists")


def _list_item_looks_strange(line, count, dattr):
    yield(f"won't edit list attribute '{dattr}' because its item {count} "
          f"might contain a comment: {repr(line)}")


def _wont_machine_edit_attribute(comment_lines, dattr):
    _ = repr(comment_lines[0])
    yield f"won't machine-edit '{dattr}' with touching comment line - {_}"


def _type_mismatch(existing_type, new_type, dattr):
    yield f"'{dattr} changed from '{existing_type}' to '{new_type}'."
    yield "Can't handle this yet."


def _edits_for_attributes_not_already_set(updates_and_deletes):
    _ = ', '.join(updates_and_deletes.keys())
    yield f"edit(s) for attribute(s) not already set: ({_})"


def _entity_order_in_doc(prev_doc_iden, doc_iden, body_of_text):
    _1, _2 = (iden.to_string for iden in (prev_doc_iden, doc_iden))
    _3 = f' in {path}' if (path := body_of_text.path) else ' in body of text'
    yield f"'{_1}' can't come before '{_2}'{_3}"


def _multiple_operations_on_one_attr(cud_type, dattr, existing, eid):
    yield f"can't '{cud_type}' on {eid}.{dattr}; it already has '{existing}'"


# == Constants & Small Flow Control & Other Small

def _assert(x):
    if x:
        return
    raise _Stop()


class _Stop(RuntimeError):  # experiment
    pass


def xx(msg=None):
    raise RuntimeError(f"write me{f': {msg}' if msg else ''}")


class _OpenStruct:
    pass

# #birth
