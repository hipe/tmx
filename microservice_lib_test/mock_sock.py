def end_state_for_client_via_test_case(tc):

    # Discussion: experimentally, departing from how we did on the server side,
    # we want how it feels if we model the expected emissions and ALSO the
    # sends AND receives AND closes etc ALL in the same definition structure.
    # This means the tests will be less level-of-detail regressable and more
    # strict.. but maybe they will be coarse enough to still be interesting
    # and regression-friendly..

    itr = tc.given_client_requests_and_expected_responses()
    scn, listener, done = _not_a_state_machine__thing_for_client(itr, tc)

    # Prepare for performance

    cr = _CallReceiver(scn, tc)
    conn = _ServerConn(cr)

    # Performance
    from game_server.cli.game_server_adapter import _open as func
    with func(conn, listener) as client:
        res = tc.given_session(client)

    if res is not None:
        raise RuntimeError(f"result?? {res!r}")

    return done()


def end_state_for_server_via_test_case(tc):

    # Business tings
    s_via_s = tc.given_string_via_string_function()

    # Set up listener and `done()`
    allow_set = tc.expected_emission_categories()
    listener, done = _listener_and_done_via_categories(allow_set, tc)

    # Prepare for performance
    itr = tc.given_requests_and_expected_responses()
    memo2 = {}
    sock = _MockSocket(memo2, itr)

    # Performance
    from game_server.cli.game_server_server import _run as func
    func(sock, s_via_s, listener)  # subroutine not function for now

    memo1 = done()
    memo1.update(memo2)  # meh
    return memo1


def _listener_and_done_via_categories(allow_set, tc):
    func = _em().listener_and_done_via_diminishing_pool
    listener, done = func(allow_set, tc)
    return listener, done


class _MockSocket:

    def __init__(self, memo, itr):
        self._steps = _sockect_steps_via_definition(memo, itr)

    def accept(self):
        tup = next(self._steps)
        assert 'connection_socket_step' == tup[0]
        return tup[1:]


def _not_a_state_machine__thing_for_client(itr, tc):

    memo = {}
    itr = (_call_receiver_via_tuple(tup, memo, tc) for tup in itr)

    from text_lib.magnetics.scanner_via import scanner_via_iterator as func
    scn = func(itr)

    def recvr(emi):
        if scn.empty:
            reason = f"received {emi.channel!r} when expecting nothing"
            raise RuntimeError(reason)

        # Manually disregard all verbose (covering it is too .. verbose)
        if 'verbose' == emi.severity:
            return

        scn.next().receive_emission(emi)

    lib = _em()
    recvrs = (lib.emission_receiver_for_debugging(tc), recvr)
    listener = lib.listener_via_receivers(recvrs)

    def done():
        if not scn.empty:
            what = scn.peek.describe_as_expecting()
            reason = f"At end of performance, still expecting {what}"
            raise RuntimeError(reason)
        return memo

    return scn, listener, done


def _sockect_steps_via_definition(memo, itr):

    # == States

    def from_start():
        yield 'connection', on_connection

    def from_connection():
        yield 'send_bytes', on_send_bytes
        yield 'sendall_bytes', on_sendall

    def from_after_sendall():
        yield 'expect_response', on_expect_response

    def from_after_expect_response():
        yield 'send_bytes', begin_another_send
        yield 'expect_close', on_expect_close

    def from_after_expect_close():
        yield 'end_of_definition', on_end_of_definition
        yield 'connection', subsequent_collection

    # == Transition actions

    def subsequent_collection():
        res = release_connection()
        self.state = from_connection
        on_connection()
        return res

    def on_connection():
        one, two = scn.next()[1:]
        self.client_addr = one, two
        self.connection_steps = []
        begin_send()

    def begin_another_send():
        begin_send()
        on_send_bytes()

    def begin_send():
        self.bytes = []
        self.state = from_connection

    def on_sendall():
        on_send_bytes()
        sendall = release_sendall()
        self.connection_steps.append(('conn_sendall_step', sendall))
        self.state = from_after_sendall

    def on_send_bytes():  # careful - also called as supporting function
        self.bytes.append(scn.next_RHS_value())

    def on_expect_response():
        parz = _parse_foo_fah_params(scn.next_RHS_rest())
        self.connection_steps.append(('conn_expect_response_step', memo, parz))
        self.state = from_after_expect_response

    def on_expect_close():
        scn.advance()
        self.connection_steps.append(('conn_expect_close_step',))
        self.state = from_after_expect_close

    def on_end_of_definition():
        return release_connection()

    # == Support for states & actions

    def release_connection():
        steps = tuple(self.connection_steps)
        del self.connection_steps
        client_conn = _ClientConn(steps)
        client_addr = self.client_addr
        del self.client_addr
        return 'connection_socket_step', client_conn, client_addr

    def release_sendall():
        res = b''.join(self.bytes)
        del self.bytes
        return res

    # ==

    class self:  # #class-as-namespace
        pass

    self.state = from_start
    scn = _experimental_sexp_scanner_via_iterator(itr)
    curr_typ = scn.peek_type

    did_end = False
    while True:

        # Search for a transition
        found = False
        for typ, action in self.state():
            if curr_typ == typ:
                found = True
                break

        # Bail if transition not found
        if not found:
            _1 = self.state.__name__
            reason = f"oops, can't get out of '{_1}' with '{curr_typ}'"
            raise RuntimeError(reason)

        # Yield if there's something to yield
        x = action()
        if x is not None:
            yield x

        if scn.more:
            curr_typ = scn.peek_type
            continue

        if did_end:
            break

        curr_typ = 'end_of_definition'
        did_end = True

    raise KeyboardInterrupt()  # amazing


class _ServerConn:
    # This mocks the the *client's* connection to the *server*
    # It became un-pretty at #history-B.4 when we improved our header encoding

    def __init__(self, cr):
        self._receive_call = cr
        self._is_in_microchunk = False

    def sendall(self, byts):
        return self._receive_call('sendall', byts)

    def recv(self, num):
        if 1 == num:
            if not self._is_in_microchunk:
                self._enter_microchunk()
            return self._microchunks.pop()
        if self._is_in_microchunk:
            self._exit_microchunk()

        return self._receive_call('recv', num)

    def _enter_microchunk(self):
        assert not self._is_in_microchunk
        headers = self._receive_call('HEADERS')
        self._microchunks = _stack_of_bytes_via_header_chunk(headers)
        self._is_in_microchunk = True

    def _exit_microchunk(self):
        assert self._is_in_microchunk
        assert 0 == len(self._microchunks)
        del self._microchunks
        self._is_in_microchunk = False

    def close(self):
        return self._receive_call('close')


class _ClientConn:
    # This mocks the *servers's* connection to the *client*
    # When we changed to IRC-style scanning for newlines in headers (good)
    # this became bad #history-B.4.

    def __init__(self, connection_steps):
        self._steps = list(reversed(connection_steps))
        self._is_in_chunk = False
        self._is_in_microchunk = False

    def recv(self, num_bytes):
        if self._is_in_chunk:
            return self._do_chunk(num_bytes)

        if len(self._steps) and 'conn_sendall_step' == self._steps[-1][0]:
            byts, = self._steps.pop()[1:]
            self._is_in_chunk = True
            self._remaining_bytes = byts
            return self._do_chunk(num_bytes)

        return b''

    def _do_chunk(self, num_bytes):

        if 1 == num_bytes:
            if not self._is_in_microchunk:
                self._enter_microchunk()
            return self._microchunks.pop()
        if self._is_in_microchunk:
            self._exit_microchunk()

        leng = len(rem := self._remaining_bytes)

        # If the server is requesting LESS bytes than the client has, easy
        if num_bytes < leng:
            return self._shift_chunk(num_bytes)

        # If the server is requesting EXACTLY the bytes the client has
        if leng == num_bytes:
            self._is_in_chunk = False
            del self._remaining_bytes
            return rem

        # If the server is requesting MORE bytes than the client has, block
        assert leng < num_bytes
        return self._pretend_block_for_read()

    def _enter_microchunk(self):
        assert not self._is_in_microchunk

        offset = self._remaining_bytes.find(b'\n\n')
        if -1 == offset:
            return self._pretend_block_for_read()  # not even accurate to real
        head_chunk = self._shift_chunk(offset+2)
        self._microchunks = _stack_of_bytes_via_header_chunk(head_chunk)
        self._is_in_microchunk = True

    def _exit_microchunk(self):
        assert self._is_in_microchunk

        assert 0 == len(self._microchunks)  # the worst
        del self._microchunks

        self._is_in_microchunk = False

    def _shift_chunk(self, num_bytes):
        leng = len(rem := self._remaining_bytes)
        assert num_bytes < leng
        res = rem[0:num_bytes]
        self._remaining_bytes = rem[num_bytes:]
        return res

    def _pretend_block_for_read(self):
        raise MyException("in real life this would cause a blocking I/O operation")  # noqa: E501

    def sendall(self, byts):
        tup = self._steps.pop()
        stack = list(reversed(tup))
        assert 'conn_expect_response_step' == stack[-1]
        stack.pop()
        parz, memo = stack
        if parz is None:
            return
        k = parz.pop('store_result_as')
        assert not parz
        memo[k] = byts

    def close(self):
        # (close gets called during cleanup when an exception is thrown so..)
        if 'conn_expect_close_step' == self._steps[-1][0]:
            self._steps.pop()


def _stack_of_bytes_via_header_chunk(head_chunk):
    byts = tuple(d.to_bytes(1, 'little') for d in head_chunk)
    return list(reversed(byts))


class _CallReceiver:

    def __init__(self, scn, tc):
        self._scanner = scn
        self._test_case = tc

    def __call__(self, m, *args):

        if self._test_case.do_debug:
            print(f"CALL TO: '{m}'")

        scn = self._scanner
        if scn.empty:  # not MyException for now
            if 'close' == m:
                print("IGNORING CALLS TO 'close' WHEN NO EXPECTS FOR NOW")
                return
            raise RuntimeError(f"received '{m}' call when expecting nothing")

        res = scn.peek.receive_call(m, args)
        scn.advance()  # hi.
        return res


def _call_receiver_via_tuple(tup, memo, tc):
    stack = list(reversed(tup))
    typ = stack.pop()
    if 'expect_call_to' == typ:
        return _call_receiver_via_stack(memo, stack)

    if 'expect_emission' == typ:
        return _emission_receiver_via_stack(memo, stack, tc)

    raise RuntimeError(f"no: '{typ}'")


def _call_receiver_via_stack(memo, stack):
    m = stack.pop()
    kw = {}
    if len(stack):
        k = stack.pop()
        if 'record_arg_as' == k:
            kw['record_arg_as'] = stack.pop()
        elif 'result_via' == k:
            kw['result_via'] = stack.pop()
        else:
            raise KeyError(f"unrecognized option '{k}'")
        assert not stack
    return _call_receiver_via(memo, m, **kw)


def _call_receiver_via(memo, method_name, result_via=None, record_arg_as=None):

    class expect_call:  # #class-as-namepsace

        def receive_call(m, args):

            if method_name != m:
                reason = f"expected {describe_as_expecting()}; '{m}' called"
                raise RuntimeError(reason)

            if record_arg_as:
                arg, = args  # ..
                memo[record_arg_as] = arg

            if result_via:
                return result_via(*args)

            return 'never see ever ever'

        def receive_emission(emi):
            reason = f"expected {describe_as_expecting()}, had {emi.channel!r}"
            raise RuntimeError(reason)

    def describe_as_expecting():
        return f"call to '{method_name}'"

    expect_call.describe_as_expecting = describe_as_expecting
    return expect_call


def _emission_receiver_via_stack(memo, stack, tc):
    sev, cat = stack.pop(), stack.pop()
    assert not stack
    exp_two = sev, cat

    class expect_emission:  # #class-as-namespace

        def receive_emission(emi):
            act_two = emi.severity, emi.channel[2]  # ..
            tc.assertSequenceEqual(act_two, exp_two)

        def receive_call(m, args):
            reason = f"expected {describe_as_expecting()}, had call to '{m}'"
            raise RuntimeError(reason)

    def describe_as_expecting():
        return ' '.join(('emission', repr(exp_two)))

    expect_emission.describe_as_expecting = describe_as_expecting
    return expect_emission


def _experimental_sexp_scanner_via_iterator(itr):  # custom #[#611] scanner

    class scn:  # #class-as-namespace
        def next_RHS_value():
            rest = self.next_RHS_rest()
            rhv, = rest
            return rhv

        def next_RHS_rest():
            tup = self.next()
            return tup[1:]

        def next():
            x = self.peek_tuple
            advance()
            return x

        more, empty, peek_type, peek_tuple = True, False, None, None

    def advance():
        try:
            x = next(itr)
            if isinstance(x, tuple):
                tup = x
            else:
                tup = (x,)
            self.peek_tuple = tup
            self.peek_type = tup[0]
        except StopIteration:
            self.more = False
            self.empty = True
            del self.peek_type
            del self.peek_tuple

    self = scn
    advance()
    self.advance = advance
    return scn


def _parse_foo_fah_params(rest):
    if 0 == len(rest):
        return None
    kw = _dict_via_iambic(rest)
    if 'as' in kw:
        kw['store_result_as'] = kw.pop('as')  # 'as' is keyword, btw
    _check_names(**kw)
    return kw


def _check_names(store_result_as=None):
    pass  # sheez!


def _dict_via_iambic(rest):
    itr = iter(rest)
    return {k: next(itr) for k in itr}


def _em():
    import modality_agnostic.test_support.common as module
    return module


class MyException(RuntimeError):
    pass

# #history-B.4
# #born
