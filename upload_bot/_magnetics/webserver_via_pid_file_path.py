"""exactly [#304.figure-1]"""

import sys


def _SELF(
        pid_file_path,
        start_server,
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

    self = _State()

    def _start_the_server_etc():

        def recv_pid(new_pid):
            self.pid = new_pid
            __when_did_start_server()

        start_server(recv_pid, listener)

    def __when_did_start_server():
        _content = 'Process ID of running server: {}\n'.format(self.pid)
        _which = 'w' if self.do_clobber else 'x'
        with filesystem.open(pid_file_path, _which) as fh:
            fh.write(_content)
        _emit_a_courtesy_message_that_the_server_is_running()

    def __emit_a_message_that_the_process_is_stale():
        _info('(PID file was stale)')

    def _emit_a_courtesy_message_that_the_server_is_running():
        _info('(server PID: {})', self.pid)

    def _info(tmpl, *rest):
        def f(o):
            o(tmpl.format(*rest))
        listener('info', 'expression', f)

    # -- state reads

    def __the_process_is_running():
        try:
            psutil.Process(self.pid)
            yes = True
        except psutil._exceptions.NoSuchProcess:
            yes = False

        return yes

    def __the_PID_file_exists():
        def f(fh):
            import re
            _content = fh.read()
            _md = re.search(r'^Process ID of running server: (\d+)$', _content)
            self.pid = int(_md[1])
            self.do_clobber = True
            return True
        return filesystem.open_if_exists(pid_file_path, f)

    return __main()


class _State:  # #[#510.3]
    def __init__(self):
        self.pid = None
        self. do_clobber = False


# == EXPERIMENT
class _SelfAsCallableModule:

    def __call__(self, **kwargs):
        return _SELF(**kwargs)


sys.modules[__name__] = _SelfAsCallableModule()
# == END EXPERIMENT

# #born.
