def func(listener, port):
    from contextlib import contextmanager as cm

    import game_server.cli.game_server_adapter as lib  # will change
    opened = lib.open_dictionary_based_tcp_ip_client_via(listener, port)

    @cm  # idk
    def cm():
        with opened as impl:
            yield _Client(impl)
    return cm()


class _Client:
    def __init__(self, impl):
        self._impl = impl

    def send_dictionary(self, *rest):
        return self._impl.send_dictionary(*rest)

# #born
