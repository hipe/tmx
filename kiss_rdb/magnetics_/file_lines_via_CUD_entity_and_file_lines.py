

def new_lines_via_delete_and_existing_lines(
        identifier_string,
        incoming_lines,
        existing_lines,
        listener,
        ):

    assert(incoming_lines is None)

    _args_for_CUD_function = (identifier_string,)

    return LINE_STREAM_THE_NEW_WAY(
            _args_for_CUD_function,
            DELETE_THE_NEW_WAY,
            incoming_lines,
            existing_lines,
            listener,
            )


def new_lines_via_update_and_existing_lines(
        identifier_string,
        incoming_lines,
        existing_lines,
        listener,
        ):

    _args_for_CUD_function = (identifier_string, incoming_lines)

    return LINE_STREAM_THE_NEW_WAY(
            _args_for_CUD_function,
            UPDATE_THE_NEW_WAY,
            incoming_lines,
            existing_lines,
            listener,
            )


def new_lines_via_create_and_existing_lines(
        identifier_string,
        incoming_lines,
        existing_lines,
        listener,
        ):

    _args_for_CUD_function = (identifier_string, incoming_lines)

    return LINE_STREAM_THE_NEW_WAY(
            _args_for_CUD_function,
            CREATE_THE_NEW_WAY,
            incoming_lines,
            existing_lines,
            listener,
            )


def LINE_STREAM_THE_NEW_WAY(
        args_for_CUD_function,
        CUD_function,
        incoming_lines,
        existing_lines,
        listener):

    from .identifiers_via_file_lines import (
            block_stream_via_file_lines,
            ErrorMonitor_)

    monitor = ErrorMonitor_(listener)

    _block_itr = block_stream_via_file_lines(existing_lines, monitor.listener)

    _block_itr = BLOCK_STREAM_THE_NEW_WAY(
            args_for_CUD_function,
            CUD_function,
            _block_itr,
            monitor)

    for block in _block_itr:
        for line in block.to_line_stream():
            yield line


def BLOCK_STREAM_THE_NEW_WAY(args, CUD_function, block_itr, monitor):

    # == always same for head block

    head_block = None
    for head_block in block_itr:
        break

    if not monitor.ok:
        return

    if head_block is None:
        # the only OK way there can be head block None is when the file is
        # truly empty (or non-existent) (Case417). our hope is that for all
        # of C, U and D the CUD_function can implement itself indifferently.
        pass
    else:
        yield head_block

    # ==

    _block_itr = __block_stream_check_order(block_itr, monitor.listener)

    _block_itr = CUD_function(*args, _block_itr, monitor)

    for block in _block_itr:
        yield block


# ==

def UPDATE_THE_NEW_WAY(id_s, new_entity_lines, block_itr, monitor):

    # this is a copy-paste-modify of DELETE that's unabstracted for clarity.

    # output entities that are lesser while searching for one that is equal.

    did_find = False
    for de in block_itr:
        if id_s == de.identifier_string:
            # do NOT yield the one we are updating. break.
            did_find = True
            break

        yield de

    if not monitor.ok:  # there's a lot that could have been wrong in the file
        return

    if not did_find:
        cover_me('hi woot 2')  # #open #[#867.C]

    yield _LinesAsBlock(new_entity_lines)

    # output any remaining entities in the file (this might fail at any point)

    for de in block_itr:
        yield de


def DELETE_THE_NEW_WAY(id_s, block_itr, monitor):

    # this is a copy-paste-modify of DELETE that's unabstracted for clarity.

    # output entities that are lesser while searching for one that is equal.

    did_find = False
    for de in block_itr:
        if id_s == de.identifier_string:
            # do NOT yield the one we are deleting. break.
            did_find = True
            break

        yield de

    if not monitor.ok:  # there's a lot that could have been wrong in the file
        return

    if not did_find:
        cover_me('hi woot 1')  # #open #[#867.C]

    # output any remaining entities in the file (this might fail at any point)

    for de in block_itr:
        yield de


def CREATE_THE_NEW_WAY(id_s, new_entity_lines, block_itr, monitor):

    # find the first item that is greater. output those that are lesser.

    first_greater = None
    for de in block_itr:
        if de.identifier_string < id_s:
            yield de
        elif de.identifier_string == id_s:
            cover_me('erroneous monk - this has a case')
        else:
            # NOTE this means we have found a first document entity that
            # has an identifier string that is greater. we use this below!
            first_greater = de
            break

    if not monitor.ok:
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


def __block_stream_check_order(block_itr, listener):

    # new in #history-A.2, for each of CUD, ensure this

    none = True
    for de in block_itr:
        none = False
        break

    if none:
        return

    yield de

    curr_id_s = de.identifier_string

    for de in block_itr:
        next_id_s = de.identifier_string

        if curr_id_s < next_id_s:  # this is how it is supposed to be
            curr_id_s = next_id_s
            yield de
            continue

        cover_me('original doohah out of order')  # #open #[#867.C]


class _LinesAsBlock:

    def __init__(self, lines):
        self._lines = lines

    def to_line_stream(self):
        return self._lines  # while it works :P


def known_error_case_yet_to_cover():
    raise Exception('known error case yet to cover')


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')

# #history-A.2: begin rewrite of CUD using block stream not parse actions
# #tombstone-A.1: got rid of mutate state machine,now empty files OK everywhere
# #born.
