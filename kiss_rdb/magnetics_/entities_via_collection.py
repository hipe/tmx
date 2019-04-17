"""
DISCUSSION about roughness here:

  - the aspirational scope of this module is potentially (per its name)
  - however currently its only public exposure is a traversing ID's function
  - towards helping make an index for CREATE.
"""


def identifiers_via_collection(
        directory_path, id_via_string,
        schema, listener):

    from .identifiers_via_file_lines import ErrorMonitor_

    monitor = ErrorMonitor_(listener)
    my_listener = monitor.listener

    _otl_itr = _open_table_line_stream_via_dir_path(
            directory_path, schema, monitor)

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
    if not monitor.ok:
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
                cover_me('invalid input')
            else:
                cover_me('check that table type is right order then skip')
        else:
            cover_me('out of order')


def _open_table_line_stream_via_dir_path(dir_path, schema, monitor):

    from .identifiers_via_file_lines import (
            open_table_line_stream_via_file_lines_)

    def when_entities_dir_empty(entities_dir_pp):  # (Case720) pp=posix path
        """(Case720): the library function we call acts the same whether the
        directory was no ent or merely just empty. here we go the extra step
        and hit the filesystem again to complain iff noent.
        """

        if not entities_dir_pp.exists():
            __whine_about_not_exists(monitor.listener, entities_dir_pp)

    _ = schema.ENTITIES_FILE_PATHS_VIA(dir_path, when_entities_dir_empty)

    for path_pp in _:
            with open(path_pp) as file_lines:
                for otl in open_table_line_stream_via_file_lines_(
                        file_lines, monitor.listener):
                    yield otl

            # if something went wrong in one file, don't process subseq. files
            if not monitor.ok:
                break


def __whine_about_not_exists(listener, pp):

    def msg():
        _ = pp.as_posix()
        yield f'collection does not exist because no such directory - {_}'

    listener('error', 'expression', 'argument_error', 'no_such_directory', msg)  # noqa: E501


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')

# #born.
