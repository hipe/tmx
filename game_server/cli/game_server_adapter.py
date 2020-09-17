#!/usr/bin/env python3 -W default::Warning::0


def cli_for_production():
    import sys
    argv = sys.argv
    if len(argv) > 1:
        print('usage: {}'.format(argv[0]))
    else:
        __run_adapter_forever(* argv[1:])


def __run_adapter_forever():

    class my_state:  # #class-as-namespace
        _timeout_float = 0.5

    self = my_state

    def __main():
        while True:
            _print('(timeout is currently {})'.format(self._timeout_float))
            inp = __parse_input()
            if inp.is_redo:
                continue
            if inp.is_quit:
                break
            __money(inp.send_this_string)

        _print('done.')

    def __money(s):

        import select
        rlist = (sock.fileno(),)

        send_bytes = bytes(s, 'utf-8')
        _print('sending: ', repr(send_bytes))
        sock.sendall(send_bytes)
        _print('blocking for FIRST read')
        while True:
            recvd_bytes = sock.recv(1024)
            if len(recvd_bytes) is 0:
                _print('received zero length')
                break
            _print('received: ', repr(recvd_bytes))
            avail, _, _ = select.select(rlist, (), (), self._timeout_float)
            if len(avail) is 0:
                _print('nothing was ready')
                break
            _print('something should be ready now')

    def __parse_input():
        s = input('any string (float to change timeout, "done" for done): ')
        if len(s) is 0:
            _print('sending the empty string causes problems. try another')
            return _REDO
        else:
            import re
            md = re.search('^\\d+\\.\\d+$', s)
            if md is None:
                if s == 'done':
                    _print('quitting loop.')
                    return _QUIT
                else:
                    return _NormalInput(s)
            else:
                return __when_change_timeout(md[0])

    def __when_change_timeout(float_s):
        was_float = self._timeout_float
        self._timeout_float = float(float_s)
        _fmt = 'changed sleep time from {} to {}'
        _print(_fmt.format(was_float, self._timeout_float))
        return _REDO

    sock = None
    _print = print
    port = 50007

    import socket
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sck:
        sck.connect(('0.0.0.0', port))
        sock = sck  # ick/meh
        __main()


class _NormalInput:
    def __init__(self, s):
        self.send_this_string = s
        self.is_quit = False
        self.is_redo = False


class _Redo:
    def __init__(self):
        self.is_quit = False
        self.is_redo = True


class _Quit:
    def __init__(self):
        self.is_quit = True
        self.is_redo = False


_REDO = _Redo()
_QUIT = _Quit()

# #history-A.1: lost self-executability
# #born
