import os
p = os.path


def rm_minus_rf_via_directory(dir_path):
    """generator that generates units of work for equivalent of `rm -rf`..

    on each unit of work, you must call `uow.execute_emitting_into(listener)`
    where you 'inject' into the execution of the UoW your [#017.3] listener.

    you must execute each unit of work (A) and generally do so in the
    order is received (B). failure to do so will lead to general failure,
    because we attempt to remove each directory assuming it is empty.

    we do it this way rather than using e.g `shutil.rmtree` for one primary
    and one or more ancilliary reasons:

        - primarily, we want to be able to maybe emit a message about every
          file we remove and maybe every directory too, at the discretion
          of the caller.

        - additionally, we do it this way because `rm -rf` is TERRIFYING
          and we feel that there is less liklihood of catastrophic failure
          (we've seen it happen) if we remove each individual file "by hand"
          before removing directories that are tacitly empty.
    """

    _tuples = os.walk(
            dir_path,
            topdown=False,  # important - rm files before their parent dirs!
            onerror='TODO',
            )

    def _unit_of_work_for_remove_directory(dir_path):
        def exe(listener):
            def exp(expag):
                yield _RM_DIR_MSG.format(dir_path)
            listener('info', 'expression', 'removing_directory', exp)
            os.rmdir(dir_path)
        return _UnitOfWork(exe)

    def _unit_of_work_for_remove_file(file_path):
        def exe(listener):
            def exp(expag):
                yield _RM_FILE_MSG.format(file_path)
            listener('info', 'expression', 'removing_file', exp)
            os.remove(file_path)
        return _UnitOfWork(exe)

    for dirpath, dirs, files in _tuples:

        for file_entry in files:
            _path = p.join(dirpath, file_entry)
            yield _unit_of_work_for_remove_file(_path)

        for dir_entry in dirs:
            _path = p.join(dirpath, dir_entry)
            yield _unit_of_work_for_remove_directory(_path)

    yield _unit_of_work_for_remove_directory(dir_path)


class _UnitOfWork:

    def __init__(self, exe):
        self._callable = exe

    def execute_emitting_into(self, listener):
        self._callable(listener)


_RM_DIR_MSG = "rming dir: {}"
_RM_FILE_MSG = "NOTE totally throwing away in-progress work: {}"

# #born.
