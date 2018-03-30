"""exactly [#304.figure-1]"""

import sys


def _SELF(
        pid_file_path,
        server_start,
        filesystem,
        psutil,
        listener=None,
        ):

    def __main():  # exactly [#304.figure-1]
        if __the_PID_file_exists():
            if __the_process_is_running():
                _emit_a_courtesy_message_that_the_server_is_running()
            else:
                __emit_a_message_that_the_process_is_stale()
                _start_the_server_etc()
        else:
            _start_the_server_etc()

    # -- actions

    def _start_the_server_etc():
        nonlocal pid
        pid = server_start(listener)
        if pid is not None:
            __when_did_start_server()

    def __when_did_start_server():
        _content = 'Process ID of running server: {}\n'.format(pid)
        with filesystem.open(pid_file_path, 'x') as fh:
            fh.write(_content)
        _emit_a_courtesy_message_that_the_server_is_running()

    def __emit_a_message_that_the_process_is_stale():
        _info('(PID file was stale)')

    def _emit_a_courtesy_message_that_the_server_is_running():
        _info('server is running (PID: {})', pid)

    def _info(tmpl, *rest):
        def f(o):
            o(tmpl.format(*rest))
        listener('info', 'expression', f)

    # -- state reads

    def __the_process_is_running():
        try:
            psutil.Process(pid)
            yes = True
        except psutil._exceptions.NoSuchProcess:
            yes = False

        return yes

    def __the_PID_file_exists():
        def f(fh):
            import re
            _content = fh.read()
            _md = re.search(r'^Process ID of running server: (\d+)$', _content)
            nonlocal pid
            pid = int(_md[1])
            return True
        return filesystem.open_if_exists(pid_file_path, f)

    # -- nonlocals:
    pid = None
    # --

    return __main()


# == EXPERIMENT
class _SelfAsCallableModule:

    def __call__(self, **kwargs):
        return _SELF(**kwargs)


sys.modules[__name__] = _SelfAsCallableModule()
# == END EXPERIMENT

# #born.
