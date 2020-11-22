import re


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
        content_length = None
        while True:  # while more headers
            content_bytes = sock.recv(80).strip()
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

        response_bytes = sock.recv(content_length)

        print(f"Yay we are done. got response: {response_bytes!r}")
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


def _hack_print_via_listener(listener):
    # NOTE #todo VERY soon this will merge with the other similar thing (maybe)
    # on the server side. but we want to cover the client side as-is first
    # It's worth mentioning here (but delete this later) that this side.
    # (unlike the server side) only ever gets single-argument (single-string)
    # calls so it's simpler. Also, we might throw the whole thing away

    def print(content):
        md = re.match(r'(\w+)[ ]', content)
        w = md[1]
        cat = None
        if w in verbose_set:
            sev = 'verbose'
        elif w in info_set:
            sev = 'info'
            cat = w  # careful..
        elif 'Yay' == w:
            sev = 'info'
            cat = 'got_response'
        else:
            xx(f"ohai: {content!r}")

        these = [sev, 'expression']
        if cat:
            these.append(cat)

        listener(*these, lambda: (content,))

    verbose_set = set(('wahoo',))
    info_set = set('sending closing'.split())

    return print


def _make_content_length_header_line(leng):
    assert isinstance(leng, int)  # #[#022]
    content = ' '.join(('Content length:', str(leng)))
    return _fixed_with_header_line_via(content)


def _fixed_with_header_line_via(string_content):
    pad_num = 79 - len(string_content)
    assert -1 < pad_num
    line = ''.join((string_content, ' '*pad_num, '\n'))
    return _encode(line)


def _decode(data):
    return str(data, 'utf-8')


def _encode(msg):
    return bytes(msg, 'utf-8')


_end_of_headers_header_line = _fixed_with_header_line_via('End of headers')


def xx(msg):
    raise RuntimeError(f"ohai: {msg}")

# #history-B.4: repurpose as generic tcp/ip client not "game server" client
#               and no more select
# #history-A.1: lost self-executability
# #born
