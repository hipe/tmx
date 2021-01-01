from inspect import getfullargspec as _getfullargspec


def func(listener, port):
    recv_string = _build_string_receiver(_response_dict_via_request_dict)

    from microservice_lib.tcp_ip_server import \
        run_string_based_tcp_ip_server_via as func
    return func(recv_string, listener, port)


def _build_string_receiver(response_dict_via_request_dict):

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

        resp_dct = response_dict_via_request_dict(dct, listener)

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


def _API_endpoint_function(orig_f):
    args, *rest = _getfullargspec(orig_f)

    # Assert none of these: varargs, varkw, defaults, kwonlyargs, kwod, annot
    assert not any(rest)

    # Assert every API endpoint func has this (which we disallow as an etc)
    assert 'listener' == args.pop()

    _via_command_name[orig_f.__name__] = set(args), orig_f
    return orig_f


_via_command_name = {}


@_API_endpoint_function
def ping(args, listener):
    bads = tuple(
        (i, type(args[i])) for i in range(0, len(args))
        if not (isinstance(args[i], str)))
    if bads:
        i, typ = bads[0]
        reason = f"arg at offset {i} was {typ.__name__} need string"
        return {'status': 12, 'reason': reason}

    def messages():
        if 0 == len(args):
            yield 'pong'
            return
        first, *rest = args
        yield f"Hello {first!r}, I am the server."
        if rest:
            yield f"(ignoring {rest!r})"

    return {
        'status': 0,
        'messages': tuple(messages())}


def _response_dict_via_request_dict(dct, listener):  # #testpoint

    def main():
        cmd_name, cmd_args = parse_level_one()
        these, func = _via_command_name.get(cmd_name)
        if these is None:
            return when_strange_command_name(cmd_name)

        if (extra := (set(cmd_args.keys()) - these)):
            return when_extra_args(extra, cmd_name)

        cmd_args['listener'] = _cray_listener  # watch world burn
        return func(**cmd_args)

    def parse_level_one():
        # Any missing required?
        def required(k):
            x = dct.pop(k, None)
            if x is not None:
                return x
            missing.append(k)
        missing = []
        command_name = required('command_name')
        command_args = required('command_args')
        if missing:
            return when_missing(missing)

        # Any unexpected extras?
        if len(dct):
            return when_extra(tuple(dct.keys()))

        # Assert type oh boy
        def check_type(k, x, label, cls):
            if isinstance(x, cls):
                return True
            when_type_mismatch(k, x, label)
        if not check_type('command_name', command_name, 'string', str):
            return
        if not check_type('command_args', command_args, 'dict', dict):
            return

        return command_name, command_args

    def when_extra_args(these, cmd_name):
        commalist = ', '.join(these)
        reason = f"unexpected arg(s) for '{cmd_name}': {commalist}"
        raise _Stop(reason, 6)

    def when_strange_command_name(x):
        raise _Stop(f"SCN: {x!r}", 5)

    def when_type_mismatch(varname, v, label):
        use = v.__class__.__name__  # meh
        reason = f"for {varname}, need {label} had {use}"
        raise _Stop(reason, 4)

    def when_extra(these):
        comma_list = ', '.join(these)
        reason = f"unexpected top-level component(s): {comma_list}"
        raise _Stop(reason, 3)

    def when_missing(these):
        comma_list = ', '.join(these)
        reason = f"missing required top-level component(s): {comma_list}"
        raise _Stop(reason, 2)

    try:
        return main()
    except _Stop as e:
        return e.to_dictionary()


def _cray_listener(*a):
    xx()


class _Stop(RuntimeError):

    def __init__(self, reason, code):
        self._reason = reason
        self._return_code = code

    def to_dictionary(self):
        return {k: v for k, v in self._to_dictionary()}

    def _to_dictionary(self):
        yield 'status', self._return_code
        yield 'reason', self._reason


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #born
