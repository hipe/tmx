def func(listener, port):
    recv_string = _build_string_receiver(listener)
    import game_server.cli.game_server_server as lib
    return lib.run_string_based_tcp_ip_server_via(recv_string, listener, port)


def _build_string_receiver(listener):
    def recv_string(ohai):
        return f'hello from injected string function: ({ohai!r})'
    return recv_string

# #born
