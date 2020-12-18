def func(listener, port):
    recv_string = _build_string_receiver(listener)
    import game_server.cli.game_server_server as lib
    return lib.run_string_based_tcp_ip_server_via(recv_string, listener, port)


def _build_string_receiver(_listener):

    def recv_string(request_string, listener):

        # Make sure the request string looks right
        if not len(request_string) or '{' != request_string[0]:
            when_looks_strange(listener, request_string)
            return ''

        # Attempt to decode the request string as JSON
        dct = None
        try:
            dct = json_loads(request_string)
            del request_string
        except JSONDecodeError as e:
            exc = e
        if dct is None:
            r = str(exc)  # r = reason
            listener('error', 'expression', 'JSON_decode_error', lambda: (r,))
            return ''

        # Make a pretend structured response
        ks = tuple(dct.keys())
        resp_dct = {'message': f"Here's your keys: {ks!r}"}

        # Encode and return the response
        return json_dumps(resp_dct, indent='  ')

    def when_looks_strange(listener, request_string):
        def lineser():
            if len(request_string) < 7:
                excerpt = request_string
            else:
                excerpt = ''.join((request_string[:6], '…'))
            yield f"Doesn't look like JSON string: {excerpt!r}"
        listener('error', 'expression', 'hmm_request', lineser)

    from json import dumps as json_dumps, loads as json_loads
    from json.decoder import JSONDecodeError

    return recv_string

# #born
