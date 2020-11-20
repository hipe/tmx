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

    def main_loop():
        while True:
            # Wait for a connection
            print('waiting for a connection')

            try:
                conn, client_addr = sock.accept()
            except KeyboardInterrupt:
                print("\nreceived keyboard interrupt. shutting down server immediately. goodbye.")  # noqa: E501
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
        content_length = None
        import re
        while True:  # while more headers

            content_bytes = conn.recv(80)
            if 0 == len(content_bytes):
                print('got zero length msg from client. time to close')
                return _its_time_to_close_this_connection

            content_bytes = content_bytes.strip()
            if b'End of headers' == content_bytes:
                print('wahoo we found end of headers!')
                break

            content = _decode(content_bytes)

            md = re.match('([A-Za-z- ]+):[ ](.+)', content)
            if md is None:
                xx(f"why didn't this match: {content!r}")

            n, v = md.groups()
            if 'Content length' == n:
                assert re.match(r'\d+\Z', v)  # ..
                content_length = int(v)
                continue
            xx(f'not covered: strange header: {n!r}')

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


def _make_content_length_header_line(leng):  # #scp
    assert isinstance(leng, int)  # #[#022]
    content = ' '.join(('Content length:', str(leng)))
    return _fixed_with_header_line_via(content)


def _fixed_with_header_line_via(string_content):  # #scp
    pad_num = 79 - len(string_content)
    assert -1 < pad_num
    line = ''.join((string_content, ' '*pad_num, '\n'))
    return _encode(line)


def _decode(data):
    return str(data, 'utf-8')


def _encode(msg):
    return bytes(msg, 'utf-8')


_end_of_headers_header_line = _fixed_with_header_line_via('End of headers')
_its_time_to_close_this_connection = False
_yes_keep_alive = True


def xx(msg):
    raise RuntimeError(f"ohai: {msg}")


# #history-B.4: repurpose to be general tcp/ip server not "game server"
# #history-A.1: lost self-executability
# #born
