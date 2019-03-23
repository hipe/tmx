"""
DISCUSSION about roughness here:

  - the aspirational scope of this module is potentially (per its name)
  - however currently its only public exposure is a traversing ID's function
  - towards helping make an index for CREATE.
  - the logic in this module is currently hard-coded for one schema but #open
"""


def identifiers_via_collection(dir_path, id_via_string, listener):

    from .identifiers_via_file_lines import ErrorMonitor_

    monitor = ErrorMonitor_(listener)
    my_listener = monitor.listener

    _otl_itr = _open_table_line_stream_via_dir_path(dir_path, monitor)

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


def _open_table_line_stream_via_dir_path(dir_path, monitor):
    # this func is scattered with #[#867.K] places that need schema injection

    from .identifiers_via_file_lines import (
            open_table_line_stream_via_file_lines_)
    from pathlib import Path
    import os.path as os_path

    def sorted_PP_entries_via_PP(posix_path):
        # absolutely do *not* rely on the filesystem to sort dir listings!
        _generator = posix_path.glob('*')  # ..
        _entries = list(_generator)
        return sorted(_entries, key=lambda pp: pp.as_posix())

    entries_dir_pp = Path(os_path.join(dir_path, 'entities'))  # ..

    # (to get through the day, the below is hard-coded to schema.
    #  but imagine recursiving it and making it dynamic per schema!)
    ok = True

    dirs = sorted_PP_entries_via_PP(entries_dir_pp)

    # == BEGIN
    """about (Case720):
    the `glob` above acts the same whether the directory was empty or noent.
    we require that when the directory is noent we emit an error. because we
    sorted the directories entries anyway, it's "free" to see if it was empty.
    """
    if not len(dirs):
        if not entries_dir_pp.exists():
            __whine_about_not_exists(monitor.listener, entries_dir_pp)
        return
    # == END

    for dir_pp in dirs:
        for path in sorted_PP_entries_via_PP(dir_pp):
            with open(path) as file_lines:
                for otl in open_table_line_stream_via_file_lines_(
                        file_lines, monitor.listener):
                    yield otl

            # if something went wrong in one file, don't process subseq. files
            if not monitor.ok:
                ok = False
                break

        # if something went wrong in one file, don't process subsequent dirs!
        if not ok:
            break


def __whine_about_not_exists(listener, pp):

    def msg():
        _ = pp.as_posix()
        yield f'collection does not exist because no such directory - {_}'

    listener('error', 'expression', 'argument_error', 'no_such_directory', msg)  # noqa: E501


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')

# #born.
