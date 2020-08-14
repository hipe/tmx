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
# hack; that is, without having to make system calls or (if we want not to)
# read the filesystem.
#
# HOWEVER, when it comes time to actually applying the change to the collection
# is where things get more fragile and tricky. AS IT STANDS NOW, WE DO THIS
# IN A NON-TRANSACTIONAL, NON-ATOMIC WAY WHERE WE MIGHT END UP CORRUPTING THE
# COLLECTION BECAUSE WE DON'T HAVE SEVERAL IMAGINED SAFEGUARDS IN PLACE :#here6
# We explain this possible scenario more below in our wishlist.
#
# This is done in the interesting of getting to an MVP in only two years. But:
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


def batch_update_EXPERIMENTAL_CAN_CORRUPT_(eid, edits, order, coll, listener):
    # WARNING see #here6

    try:
        return _do_batch_update(eid, edits, order, coll, listener)
    except _Stop:
        pass


def _do_batch_update(eid, edits, order, coll, listener):

    def patch_via(path, edit_via_attr_via_eid):
        return _make_patch(edit_via_attr_via_eid, coll, order, mon, path=path)

    mon = coll.monitor_via_listener_(listener)  # make once for each file ick/m
    listener = mon.listener  # use this one instead always
    file_uows = _file_units_of_work_via(edits, coll, listener)
    patches = tuple(patch_via(path, edt) for path, edt in file_uows if mon.OK)
    if not mon.OK:
        return

    from tempfile import NamedTemporaryFile

    with NamedTemporaryFile('w+') as fp:
        for lines in patches:
            for line in lines:
                fp.write(line)
        fp.flush()
        _apply_big_patchfile(fp.name, listener)

    iden = coll.identifier_via_string_(eid, listener)
    _ = coll.retrieve_entity_as_storage_adapter_collection(iden, listener)
    return _


def _apply_big_patchfile(patchfile_path, listener):
    def serr(msg):
        if '\n' == msg[-1]:  # lines coming from the subprocess
            msg = msg[0:-1]
        listener('info', 'expression', 'from_patchfile', lambda: (msg,))

    import subprocess as sp

    opened = sp.Popen(
            args=('patch', '--strip', '1', '--input', patchfile_path),
            stdin=sp.DEVNULL,
            stdout=sp.PIPE,
            stderr=sp.PIPE,
            text=True,  # don't give me binary, give me utf-8 strings
            )

    with opened as proc:

        stay = True
        while stay:
            stay = False
            for line in proc.stdout:
                serr(f"GOT THIS STDOUT LINE: {line}")
                stay = True
                break
            for line in proc.stderr:
                serr(f"GOT THIS STDERR LINE: {line}")
                stay = True
                break

        proc.wait()  # not terminate. maybe timeout one day
        es = proc.returncode

    if 0 != es:
        serr(f"EXITSTATUS: {repr(es)}\n")
        raise _stop  # pray for etc


def _make_patch(edit, coll, order, mon, **bot):
    bot = coll.body_of_text_via_(**bot)
    new_file_lines = _new_file_lines(edit, coll, order, mon, body_of_text=bot)
    new_file_lines = tuple(new_file_lines)

    _ = bot.path or 'some-imaginary-file.dot'
    from difflib import unified_diff
    return tuple(unified_diff(bot.lines, new_file_lines, f'a/{_}', f'b/{_}'))


def _new_file_lines(edit, coll, order, mon, **body_of_text):
    for block in _new_file_blocks(edit, coll, order, mon, **body_of_text):
        for line in block.to_lines():
            yield line


def _new_file_blocks(edit_via_attr_via_eid, coll, order, mon, **body_of_text):
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

    stop = _stopper_via_listener(mon.listener)

    body_of_text = coll.body_of_text_via_(**body_of_text)

    def p(eid):
        return coll.identifier_via_string_(eid, mon.listener)
    stack = list(reversed([p(eid) for eid in edit_via_attr_via_eid.keys()]))

    prev_doc_iden = None
    for entb in _existing_entity_blocks_via_BoT(body_of_text, coll, mon):

        doc_iden = entb.entity.identifier
        if not (prev_doc_iden is None or prev_doc_iden < doc_iden):
            stop(_entity_order_in_doc, prev_doc_iden, doc_iden, body_of_text)
        prev_doc_iden = doc_iden

        # While there are any edits and they come before the cursor, insert
        while len(stack) and stack[-1] < doc_iden:
            yield xx("special function for insert new entity")
            stack.pop()

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

        request_eid = request_iden.to_string()

        # == BEGIN
        # one day whe we use this function also for delete it will be tuples
        temp = edit_via_attr_via_eid.pop(request_eid)
        cud_stack = [temp, 'update_entity']
        # == END

        cud_type = cud_stack.pop()
        if 'delete_entity' == cud_type:
            # deleting an entity simply means skipping it
            xx()
            assert(not len(cud_stack))
            continue

        assert('update_entity' == cud_type)  # ..
        update_params, = cud_stack
        yield _updated_document_entity(entb, update_params, order, mon)

    if len(stack):
        xx()  # assume these are creates. if updates or deletes, entity not


def _updated_document_entity(entb, edit_via_dattr, order, mon):

    _ = _edited_attribute_blocks(entb, edit_via_dattr, order, mon)
    attribute_blocks = tuple(_)

    if not mon.OK:
        return

    identity_line = entb.identity_line

    def to_lines():
        yield identity_line
        for ab in attribute_blocks:
            for line in ab.to_lines():
                yield line

    def attr_blockser():
        return attribute_blocks

    return _entity_block_via_functions(
        lambda: identity_line, attr_blockser, to_lines, entity=None)


def _edited_attribute_blocks(entb, edit_via_dattr, order, mon):
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

    stop = _stopper_via_listener(mon.listener)

    order_offset_via_dattr = {order[i]: i for i in range(0, len(order))}
    creates, updates_and_deletes = _prepare_edit(
            edit_via_dattr, order_offset_via_dattr)

    seen = set()
    for attrb in entb.to_attribute_block_stream():
        dattr = attrb.key

        # Assert existing attribute name against allowlist and constituency
        where = order_offset_via_dattr[dattr]  # assert the allowlist
        assert(dattr not in seen)
        seen.add(dattr)

        # Emit every attribute to be inserted while it goes before current
        while len(creates) and order_offset_via_dattr[creates[-1][0]] < where:
            yield _new_attribute_block(* creates.pop())  # repeats #here4

        # Is there an edit for this attribute?
        edit = updates_and_deletes.pop(dattr, None)
        if edit is None:
            yield attrb
            continue

        # There is an edit for this attribute
        cud_type, *params = edit
        if 'delete_attribute' == cud_type:
            # delete simply means do nothing (what about comment rules tho)
            clinz = tuple(attrb.to_tail_anchored_comment_or_whitespace_lines())
            _check_edit_OK(clinz, attrb, stop)
            if 1 < len(clinz):
                yield _comments_block(clinz)  # probably has leading blank line
            continue

        assert('update_attribute' == cud_type)
        yield _edited_attribute(attrb, *params, stop)

    # Are there edits that didn't get consumed from the pool above?
    if len(updates_and_deletes):
        stop(_edits_for_attributes_not_already_set, updates_and_deletes)

    # Any inserts that didn't get triggered by above
    while len(creates):
        yield _new_attribute_block(* creates.pop())  # repeats #here4


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


def _file_units_of_work_via(edits, coll, listener):
    file_units_of_work = []
    file_UoW_offset_via_path = {}

    def add_attribute_edit(dct):
        if dattr in dct:
            curr = dct[dattr][0]  # #here3: hard-coded doo-hahs
            stop(_multiple_operations_on_one_attr, cud_type, dattr, curr, eid)
        dct[dattr] = (cud_type, *rest)

    def dictionary_via_eid(eid, dct):
        res = dct.get(eid)
        if res is None:
            dct[eid] = (res := {})
        return res

    def dictionary_via_path(path):
        i = file_UoW_offset_via_path.get(path)
        if i is None:
            file_UoW_offset_via_path[path] = (i := len(file_units_of_work))
            file_units_of_work.append((path, {}))
        return file_units_of_work[i][1]

    stop = _stopper_via_listener(listener)

    for eid, cud_type, dattr, *rest in edits:
        _assert(iden := coll.identifier_via_string_(eid, listener))
        _assert(path := coll.path_via_identifier_(iden, listener))
        dct = dictionary_via_path(path)
        dct = dictionary_via_eid(eid, dct)
        add_attribute_edit(dct)

    return tuple(file_units_of_work)


def _edited_attribute(attrb, new_value, stop):
    dattr = attrb.key
    existing_type = attrb.eno_type
    new_type = _eno_type_via_value(new_value)
    if existing_type != new_type:
        stop(_type_mismatch(existing_type, new_type, dattr))

    clines = tuple(attrb.to_tail_anchored_comment_or_whitespace_lines())
    _check_edit_OK(clines, attrb, stop)

    lines = _attribute_block_head_lines_via(new_type, new_value, dattr)

    return _attribute_block_via_five(
        dattr, new_value, new_type, lambda: lines, lambda: clines)


def _check_edit_OK(clines, attrb, stop):
    dattr = attrb.key
    if len(clines) and '\n' != clines[0]:
        stop(_wont_machine_edit, clines, dattr)

    if 'List' != attrb.eno_type:
        return

    itr = iter(attrb.to_head_anchored_body_lines())
    assert(f'{dattr}:\n' == next(itr))  # YIKES
    import re
    count = 0
    for line in itr:
        count += 1
        if True or re.match('^- ', line):
            continue
        stop(_list_item_looks_strange, line, count, dattr)


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

    return _attribute_block_via_five(
            key, value, typ,
            to_head_anchored_body_lines,
            to_tail_anchored_comment_or_whitespace_lines)


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

    if 'Multiline Field Begin' == eno_type:
        return tuple(multiline_field_lines(dattr, value))

    assert('List' == eno_type)
    return tuple(list_lines(dattr, value))


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


def _first_line_offset_of(el):
    return el._instruction['line']  # not okay, technically


# == Read Existing Blocks

def _existing_entity_blocks_via_BoT(bot, coll, mon):

    docu = coll.eno_document_via_(body_of_text=bot, listener=mon.listener)
    els = coll.entity_section_elements_via_document_(docu, bot.path, mon)
    line_index = _line_index_via_lines(bot.lines)

    def flush(end):
        ent = previous_entity.pop()
        begin = first_line_offset_of_entity(ent)
        return _existing_entity_block(begin, end, ent, line_index)

    def first_line_offset_of_entity(ent):
        return _first_line_offset_of(ent.VENDOR_SECTION_)

    previous_entity = []  # abuse

    for eid, sect in els:
        iden = coll.identifier_via_string_(eid, mon.listener)
        ent = coll.read_only_entity_via_section_(sect, iden, mon)
        if len(previous_entity):
            yield flush(first_line_offset_of_entity(ent))
        previous_entity.append(ent)

    if len(previous_entity):
        yield flush(len(line_index.line_cache))


def _existing_entity_block(begin, end, ent, line_index):

    def to_lines():
        return line_index.line_cache[begin:end]

    def identity_line():
        return line_index.line_cache[begin]

    def to_attribute_block_stream():
        return _to_attribute_block_stream(ent, end, line_index)

    return _entity_block_via_functions(
        identity_line, to_attribute_block_stream, to_lines, ent)


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

def _entity_block_via_functions(
        identity_liner, to_attribute_block_stream, to_lines, entity):
    _ent = entity

    class entity_block:  # #class-as-namespace
        @property
        def identity_line(_):
            return identity_liner()

        def to_attribute_block_stream(_):
            return to_attribute_block_stream()

        def to_lines(_):
            return to_lines()

        entity = _ent
    return entity_block()


def _attribute_block_via_five(dattr, value, typ, head_lineser, tail_lineser):

    class attribute_block:

        def to_lines(_):
            for line in self.to_head_anchored_body_lines():
                yield line

            for line in self.to_tail_anchored_comment_or_whitespace_lines():
                yield line

        def to_head_anchored_body_lines(_):
            return head_lineser()

        def to_tail_anchored_comment_or_whitespace_lines(_):
            return tail_lineser()

        @property
        def key(_):
            return dattr

        @property
        def value(_):
            return value

        @property
        def eno_type(_):
            return typ

    return (self := attribute_block())


def _comments_block(comment_lines):
    class comments_block:
        def to_lines():
            return comment_lines
    return comments_block


# == Error Case Messages

def _stopper_via_listener(listener):
    def stop(f, *args):
        lines = tuple(f(*args))  # meh
        listener('error', 'expression', 'edit_request_error', lambda: lines)
        raise _stop_because_edit_request_error
    return stop


def _list_item_looks_strange(line, count, dattr):
    yield(f"won't edit list attribute '{dattr}' because its item {count} "
          f"might contain a comment: {repr(line)}")


def _wont_machine_edit(comment_lines, dattr):
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
    raise _stop


class _Stop(RuntimeError):  # experiment
    pass


_stop = _Stop()


def xx(msg=None):
    raise RuntimeError(f"write me{f': {msg}' if msg else ''}")


class _OpenStruct:
    pass

# #birth
