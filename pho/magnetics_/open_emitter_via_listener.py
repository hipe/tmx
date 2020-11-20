def func(listener, port):
    import game_server.cli.game_server_adapter as lib  # will change
    return lib.open_string_based_tcp_ip_client_via(listener, port)

# #born
