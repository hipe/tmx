from game_server import \
        hack_print_via_listener_ as _hack_print_via_listener, \
        make_content_length_header_line_ as _make_content_length_header_line, \
        end_of_headers_header_line_ as _end_of_headers_header_line, \
        read_headers_ as _read_headers, \
        encode_ as _encode


def open_string_based_tcp_ip_client_via(listener, port):
    import socket

    # Create a TCP/IP socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    # Connect the socket to the port where the server is listening
    server_address = ('localhost', port)
    print('connecting to {} port {}'.format(*server_address))
    sock.connect(server_address)

    return _open(sock, listener)


def _open(sock, listener):  # #testpoint

    print = _hack_print_via_listener(listener)

    def send_string(message):

        # Prepare headers for request
        payload = _encode(message)
        header1 = _make_content_length_header_line(len(payload))
        header2 = _end_of_headers_header_line

        big_data = b''.join((header1, header2, payload))

        # Send request
        print(f'sending {big_data!r}')
        sock.sendall(big_data)

        # Parse response headers
        stay_open, content_length = _read_headers(sock, print)
        assert stay_open
        assert content_length is not None

        response_bytes = sock.recv(content_length)

        print(f"got response: {response_bytes!r}")
        return 'hardcoded meaningless response for now'

    class client:  # #class-as-namespace
        pass

    client.send_string = send_string

    from contextlib import contextmanager as cm

    @cm
    def cm():
        try:
            yield client
        finally:
            print('closing socket')
            sock.close()
    return cm()


def xx(msg):
    raise RuntimeError(f"ohai: {msg}")

# #history-B.4: repurpose as generic tcp/ip client not "game server" client
#               and no more select
# #history-A.1: lost self-executability
# #born
