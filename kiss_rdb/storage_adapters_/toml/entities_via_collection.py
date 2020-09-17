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

    self = _ThisState()
    self._actions = None

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


class _ThisState:  # [#510.2]
    pass


def identifiers_via__(paths_function, id_via_string, listener):
    from modality_agnostic import ModalityAgnosticErrorMonitor
    monitor = ModalityAgnosticErrorMonitor(listener)
    my_listener = monitor.listener

    _otl_itr = _table_start_line_stream_via_dir_path(paths_function, monitor)

    def _():
        for otl in _otl_itr:
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
        if True:
            with open(path_pp) as file_lines:
                for otl in table_start_line_stream_via_file_lines_(
                        file_lines, monitor.listener):
                    yield otl

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

# #history-A.1: become home to place that parses single table body from lines
# #born.
