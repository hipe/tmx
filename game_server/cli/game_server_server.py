def _do_work_for_client_socket(client_sock):

            while True:
                print('recv..')
                recvd_bytes = client_sock.recv(8)
                if len(recvd_bytes) is 0:
                    print('no data - break.')
                    break

                recvd_str = str(recvd_bytes, 'utf-8')
                print('    received: ', repr(recvd_str))

                send_str = recvd_str.upper()
                print('     sending: ', repr(send_str))

                send_bytes = bytes(send_str, 'utf-8')

                client_sock.sendall(send_bytes)


def _run_my_server_forever(
    bind_port,
    max_backlog_of_connections=5,
):
    def __main():
        with __create_socket() as s:
            __bind_and_listen(s)
            __main_loop_forever(s)

    def __main_loop_forever(local_socket):
        while True:
            _print('waiting for connection')
            client_sock, adr = local_socket.accept()
            _print('connected by', repr(adr))
            with client_sock:
                _do_work_for_client_socket(client_sock)

    def __bind_and_listen(s):
        s.bind((bind_ip, bind_port))
        s.listen(max_backlog_of_connections)
        _print('listening on {}:{}'.format(bind_ip, bind_port))

    def __create_socket():
        import socket
        return socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    _print = print

    bind_ip = '0.0.0.0'
    __main()


def cli_for_production():
    _run_my_server_forever(
        bind_port=50007,
    )

# #history-A.1: lost self-executability
# #born