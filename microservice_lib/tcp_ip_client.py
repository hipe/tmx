from microservice_lib import \
        hack_print_via_listener_ as _hack_print_via_listener, \
        make_content_length_header_line_ as _make_content_length_header_line, \
        end_of_headers_header_line_ as _end_of_headers_header_line, \
        read_headers_ as _read_headers, \
        encode_ as _encode, decode_ as _decode
from contextlib import contextmanager as _cm


# == Dictionary-based client

def open_dictionary_based_tcp_ip_client_via(listener, port):

    @_cm  # #[#510.12] misuse of context manager? how to wrap them
    def cm():
        with open_string_based_tcp_ip_client_via(listener, port) as impl:
            func = _send_dictionary_via_send_string(impl)
            yield _DictionaryBasedClient(func)
    return cm()


class _DictionaryBasedClient:
    def __init__(self, func):
        self.send_dictionary = func  # watch the world burn


def _send_dictionary_via_send_string(impl):

    def send_dictionary(dct):
        big_s = json_via_dict(dct)
        resp_s = impl.send_string(big_s)
        if resp_s is None:
            return  # [#102.B]

        assert isinstance(resp_s, str)  # [#022]

        # (if the request was not well-formed etc, it returns the empty string)

        assert len(resp_s)
        assert '{' == resp_s[0]
        return json_loads(resp_s)  # ..

    def json_via_dict(dct):
        assert isinstance(dct, dict)  # [#022]
        return json_dumps(dct, indent='  ')

    from json import dumps as json_dumps, loads as json_loads
    return send_dictionary


# == String-based client

def open_string_based_tcp_ip_client_via(listener, port):
    import socket

    # Create a TCP/IP socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    # Connect the socket to the port where the server is listening
    server_address = ('localhost', port)

    def lines():
        host, _ = server_address
        yield f"connecting to {host} port {port}"

    listener('info', 'expression', 'connecting_to_server', lines)

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
        if not stay_open:
            reason = f"server failed while processing response. got stay_open: {stay_open!r}"  # noqa: E501
            listener('error', 'expression', 'server_failed', lambda: (reason,))
            return  # [#102.B]

        assert stay_open
        assert content_length is not None

        response_bytes = sock.recv(content_length)

        print(f"got response: {response_bytes!r}")
        return _decode(response_bytes)

    class client:  # #class-as-namespace
        pass

    client.send_string = send_string

    @_cm
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
