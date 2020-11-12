"""Expose CREATE, UPDATE and DELETE.

These three implementatons are exactly based on the pseudocode in
in [#864] the toml adaptation for entites at "synthesis".
"""


def _verb(future):  # decorator
    def use_decorator(f):
        return _do_verb(f, future)
    return use_decorator


def _do_verb(f, do_future):
    def use_f(existing_file_lines, listener, **client_args):
        return _do_do_verb(
                existing_file_lines, listener, client_args, f, do_future)
    return use_f


def _do_do_verb(existing_file_lines, listener, client_args, f, do_future):

    # what a ride:

    # peek when an iterator failed
    from modality_agnostic import ModalityAgnosticErrorMonitor
    monitor = ModalityAgnosticErrorMonitor(listener)

    # convert the stream of file lines into a stream of blocks

    blocks = __block_stream_via_file_lines(
            existing_file_lines, monitor.listener)

    # shear off the any head block now, it's not an entity block. used below

    head_block = None
    for head_block in blocks:  # #once
        break

    # cut out early if the file failed to parse the first block

    if not monitor.OK:
        return

    # if input entity blocks are out of order, you're gonna have a bad time.

    blocks = __check_order(blocks, listener)

    # give these will-sanitize entity blocks to the injected function to edit

    mixed_client_itr = f(block_itr=blocks, monitor=monitor, **client_args)

    # if the client does future, get it immediately before we get crazy

    if do_future:
        future = next(mixed_client_itr)  # used below

    # for almost final output, stitch that head block on to the front again

    def re_unified_blocks():
        """head block is None IFF the input file was truly empty (Case4276)
        or non-existent. The injected functions must behave the same whether
        the input is a truly empty file or a file with some existing non-
        entity content (from their perspective), so we hide this from them.
        """

        if head_block is not None:
            yield head_block

        for block in mixed_client_itr:
            yield block

    output_lines = __lines_via_blocks(re_unified_blocks())

    if do_future:
        return output_lines, future
    else:
        return output_lines


@_verb(future=False)
def new_lines_via_update_and_existing_lines(
        identifier_string, new_lines_via_entity, block_itr, monitor):

    # this is a copy-paste-modify of DELETE that's unabstracted for clarity.
    # output entities that are lesser while searching for one that is equal.
    # de = document entity

    # this doesn't yet do the "future" thing with the twin snapshots (before/
    # after, introduced #history-A.4) but it could.

    did_find = False
    for de in block_itr:
        if identifier_string == de.identifier_string:
            # do NOT yield the one we are updating. break.
            did_find = True
            break

        yield de

    if not monitor.OK:  # there's a lot that could have been wrong in the file
        return

    if not did_find:
        _whine_about_entity_not_found(identifier_string, monitor.listener)
        return  # not covered - blind faith

    mde = de.to_mutable_document_entity_(monitor.listener)
    if mde is None:
        return

    # got rid of recv_doc_ent at #history-A.3

    new_entity_lines = new_lines_via_entity(mde, monitor.listener)
    if new_entity_lines is None:
        return

    yield _LinesAsBlock(new_entity_lines)

    # output any remaining entities in the file (this might fail at any point)

    for de in block_itr:
        yield de


@_verb(future=True)
def new_lines_and_future_deleted_via_existing_lines(
        identifier_string, block_itr, monitor):

    def future():
        # implement [#857.11]: custom struct for delete
        cls = _custom_structs().for_delete
        return cls(deleted_document_entity, emit_edited=None)
    deleted_document_entity = None
    yield future

    # this is a copy-paste-modify of UPDATE that's unabstracted for clarity.

    # output entities that are lesser while searching for one that is equal.

    did_find = False
    for de in block_itr:
        if identifier_string == de.identifier_string:
            # do NOT yield the one we are deleting. break.
            did_find = True
            document_entity_that_will_be_deleted = de
            break

        yield de

    if not monitor.OK:  # there's a lot that could have been wrong in the file
        return

    if not did_find:
        _whine_about_entity_not_found(identifier_string, monitor.listener)
        return  # (Case4288)

    # output any remaining entities in the file (this might fail at any point)

    for de in block_itr:
        yield de

    # [#864]: "important: set the future value only once stream is exhausted"

    if monitor.OK:
        deleted_document_entity = document_entity_that_will_be_deleted
        _express_joy_at_having_deleted(
                monitor.listener, deleted_document_entity)


@_verb(future=False)
def new_lines_via_create_and_existing_lines(
        identifier_string, new_entity_lines, block_itr, monitor):

    # find the first item that is greater. output those that are lesser.

    first_greater = None
    for de in block_itr:
        if de.identifier_string < identifier_string:
            yield de
        elif de.identifier_string == identifier_string:
            xx('erroneous monk - this has a case')
        else:
            # NOTE this means we have found a first document entity that
            # has an identifier string that is greater. we use this below!
            first_greater = de
            break

    if not monitor.OK:
        return

    # output the new lines

    yield _LinesAsBlock(new_entity_lines)

    # output that first (any) one we found that was greater.

    if first_greater is not None:
        yield first_greater

    # output any of the remainder (this could fail at any step in traversal)

    for de in block_itr:
        yield de


# ==

def __check_order(block_itr, listener):

    # new in #history-A.2, for each of CUD, ensure this
    # pass the stream through unchanged, but bork if it's out of order

    done = True
    for de in block_itr:  # #once
        done = False
        break

    if done:
        return

    curr_id_s = de.identifier_string
    yield de

    for de in block_itr:
        next_id_s = de.identifier_string

        if curr_id_s < next_id_s:  # this is how it is supposed to be
            curr_id_s = next_id_s
            yield de
            continue

        xx('original doohah out of order')  # #open #[#867.C]


# == Model-esque

def _custom_structs():  # #[#510.8] lazy
    o = _custom_structs
    if o.value is None:
        o.value = _build_custom_structs()
    return o.value


_custom_structs.value = None


def _build_custom_structs():
    from collections import namedtuple as _nt
    these = ('emit_edited',)
    fd = _nt('DeleteResult', ('deleted_entity', *these))
    return _nt('These', ('for_delete',))(fd)


class _LinesAsBlock:

    def __init__(self, lines):
        self._lines = lines

    def to_line_stream(self):
        return self._lines  # while it works :P


# == whiners

def _express_joy_at_having_deleted(listener, table_block):
    _ = tuple(table_block.to_body_block_stream_as_table_block_())
    heh = tuple(None for o in _ if o.is_attribute_block)
    eid = table_block.identifier.to_string()
    from kiss_rdb.magnetics_.CUD_attributes_request_via_tuples \
        import emit_edited_ as emit
    emit(listener, ((), (), heh), eid, 'deleted')


def _whine_about_entity_not_found(id_s, listener):
    def structurer():
        _reason = f'entity {repr(id_s)} is not in file'
        return {'reason': _reason}
    listener('error', 'structure', 'input_error', structurer)


# == trivial & wrappers

def __lines_via_blocks(blocks):  # #c/p
    for block in blocks:
        for line in block.to_line_stream():
            yield line


def __block_stream_via_file_lines(existing_file_lines, listener):
    from . import blocks_via_file_lines as block_lib
    return block_lib.block_stream_via_file_lines(existing_file_lines, listener)


# ==

def xx(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')

# #history-A.4: futures, decorator
# #history-A.3
# #history-A.2: begin rewrite of CUD using block stream not parse actions
# #tombstone-A.1: got rid of mutate state machine,now empty files OK everywhere
# #born.
