from game_server import \
        hack_print_via_listener_ as _hack_print_via_listener, \
        make_content_length_header_line_ as _make_content_length_header_line, \
        end_of_headers_header_line_ as _end_of_headers_header_line, \
        read_headers_ as _read_headers, \
        decode_ as _decode, encode_ as _encode


def run_string_based_tcp_ip_server_via(recv_string, listener, port):
    import socket

    # Create a TCP/IP socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    # Bind the socket to the port
    server_address = ('localhost', port)
    print('starting up on {} port {}'.format(*server_address))
    sock.bind(server_address)

    # Listen for incoming connections
    sock.listen(1)

    _run(sock, listener)


def _run(sock, listener):  # #testpoint

    print = _hack_print_via_listener(listener)

    def main_loop():
        while True:
            # Wait for a connection
            print('waiting for a connection')

            try:
                conn, client_addr = sock.accept()
            except KeyboardInterrupt:
                print("\nshutting down immediately because received keyboard interrupt. goodbye.")  # noqa: E501
                return

            try:
                keep_alive = True
                while keep_alive:
                    keep_alive = handle_connection(conn, client_addr)
            finally:
                # Clean up the conn
                conn.close()

    def handle_connection(conn, client_addr):
        print('connection from', client_addr)

        # Parse client headers
        stay_open, content_length = _read_headers(conn, print)
        if not stay_open:
            return _its_time_to_close_this_connection
        assert content_length is not None

        # Read client payload
        print(f"OK you're doing great, content length: {content_length!r}")
        client_payload = _decode(conn.recv(content_length))

        leng = len(client_payload)
        print(f"OK received from client {leng} bytes")

        # Prepare response message
        beg = client_payload[:6]
        end = client_payload[-7:]
        message = f"I enjoyed processing this: ({beg}..{end})"

        # Prepare headers for response
        payload = _encode(message)
        header1 = _make_content_length_header_line(len(payload))
        header2 = _end_of_headers_header_line
        big_data = b''.join((header1, header2, payload))

        # Send response
        leng = len(big_data)
        print(f"sending {leng} bytes of big data back")
        conn.sendall(big_data)
        return _yes_keep_alive

    main_loop()


_its_time_to_close_this_connection = False
_yes_keep_alive = True


def xx(msg):
    raise RuntimeError(f"ohai: {msg}")

# #history-B.4: repurpose to be general tcp/ip server not "game server"
# #history-A.1: lost self-executability
# #born
