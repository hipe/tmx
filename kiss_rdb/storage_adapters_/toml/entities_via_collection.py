"""
DISCUSSION about roughness here:

  - the aspirational scope of this module is potentially (per its name)
  - however, currently towards that topic it only traverses coll for all ID's
  - towards helping make an index for CREATE.
  - at #history.A.1 it grew to house table block builders (e.g. for CREATE)
"""


def table_block_via_lines_and_table_start_line_object_(
        lines,
        table_start_line_object,
        listener=None):

    """
    EXPERIMENTAL. internal. parse a single table block from all the lines

    expecting that the first line is the first line of the body blocks.
    implicitly asserts etc (MORE ocd would be a grammar for this)
    """

    from . import (
            blocks_via_file_lines as blk_lib,
            identifiers_via_file_lines as sm_lib)

    # == BEGIN massive a hacks to alter parse state to be as if mid-parse

    class self:  # #class-as-namespace
        _actions = None

    def actionser(ps):  # the actions object isn't normally accessible
        self._actions = blk_lib.ActionsForCoarseBlockParse_(ps)
        return self._actions

    ps = sm_lib.state_machine_.build_parse_state(
            listener=listener,
            actions_class=actionser)

    ps.be_in_state_('table begun')  # the state after "table start line"

    self._actions.begin_table_with_(table_start_line_object)
    # begin the appendable table block

    # == END

    block_itr = ps.items_via_all_lines_(lines)

    table_block = next(block_itr)

    for _ in block_itr:
        assert(False)  # assert that that's the end of the stream

    return table_block


def open_identifier_traveral__(paths_function, iden_via_string, listener):
    # (20 months later this got flipped around to be a cm. #history-B.1)
    # (we wanted to overhaul tons of it but instead we tried to be minimal)
    from modality_agnostic import ModalityAgnosticErrorMonitor
    monitor = ModalityAgnosticErrorMonitor(listener)
    itr = _closer_then_idens(paths_function, iden_via_string, monitor)
    close_current_file = next(itr)

    from contextlib import contextmanager

    @contextmanager
    def cm():
        try:
            yield itr
        finally:
            close_current_file()
    return cm()


# otl = open table line


def _closer_then_idens(paths_function, id_via_string, monitor):
    my_listener = monitor.listener
    raw_otls = _table_start_line_stream_via_dir_path(paths_function, monitor)

    yield next(raw_otls)  # #here1

    def _():
        for otl in raw_otls:
            id_obj = id_via_string(otl.identifier_string, my_listener)
            if id_obj is None:
                break
            yield (id_obj, otl.table_type)

    itr = _()

    # since there is no previous item to compare it against, there is no
    # way way for the first item to be order-invalid. always yield it.

    for id_obj, table_type in itr:
        prev_id_s = id_obj.to_string()  # ..
        prev_table_type = table_type
        yield id_obj
        break

    # things that could make this fail: wrong ID depth, general parse fail
    if not monitor.OK:
        return

    # every subsequent item
    for id_obj, table_type in itr:

        this_id_s = id_obj.to_string()  # ..
        this_table_type = table_type

        if prev_id_s < this_id_s:  # the natural order of the universe
            prev_id_s = this_id_s
            prev_table_type = this_table_type
            yield id_obj
        elif prev_id_s == this_id_s:  # maybe when future feature 1
            if prev_table_type == this_table_type:
                xx('invalid input')
            else:
                xx('check that table type is right order then skip')
        else:
            xx('out of order')


def _table_start_line_stream_via_dir_path(paths_function, monitor):
    def close_current_file():
        if current_file:
            current_file.close()
    current_file = None
    yield close_current_file  # #here1

    from .identifiers_via_file_lines import (
            table_start_line_stream_via_file_lines_)

    def when_entities_dir_empty(entities_dir_pp):  # (Case4298) pp=posix path
        """(Case4298): the library function we call acts the same whether the
        directory was no ent or merely just empty. here we go the extra step
        and hit the filesystem again to complain iff noent.
        """

        if not entities_dir_pp.exists():
            __whine_about_not_exists(monitor.listener, entities_dir_pp)

    _ = paths_function(when_entities_dir_empty)

    for path_pp in _:
        current_file = open(path_pp)
        if True:

            with current_file as file_lines:
                for otl in table_start_line_stream_via_file_lines_(
                        file_lines, monitor.listener):
                    yield otl
            current_file = None

            # if something went wrong in one file, don't process subseq. files
            if not monitor.OK:
                break


def __whine_about_not_exists(listener, pp):

    def msg():
        _ = pp.as_posix()
        yield f'collection does not exist because no such directory - {_}'

    listener('error', 'expression', 'cannot_load_collection', msg)  # noqa: E501


def xx(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')

# #history-B.4
# #history-A.1: become home to place that parses single table body from lines
# #born.
