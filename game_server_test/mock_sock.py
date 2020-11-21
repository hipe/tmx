def end_state_via_test_case(tc):

    # Set up listener and `done()`
    allow_set = tc.expected_emission_categories()
    listener, done = _listener_and_done_via_categories(allow_set, tc)

    # Prepare for performance
    itr = tc.given_requests_and_expected_responses()
    sock = _MockSocket(itr)

    # Performance
    from game_server.cli.game_server_server import _run as func
    func(sock, listener)  # subroutine not function for now

    return done()


def _listener_and_done_via_categories(allow_set, tc):
    from modality_agnostic.test_support.common import \
            listener_and_done_via_diminishing_pool as func
    listener, done = func(allow_set, tc)
    return listener, done


class _MockSocket:

    def __init__(self, itr):
        self._steps = _sockect_steps_via_definition(itr)

    def accept(self):
        tup = next(self._steps)
        assert 'connection_socket_step' == tup[0]
        return tup[1:]


def _sockect_steps_via_definition(itr):

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
        scn.advance()
        self.connection_steps.append(('conn_expect_response_step',))
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


class _ClientConn:

    def __init__(self, connection_steps):
        self._steps = list(reversed(connection_steps))
        self._is_in_chunk = False

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
        leng = len(rem := self._remaining_bytes)

        # If the server is requesting LESS bytes than the client has, easy
        if num_bytes < leng:
            res = rem[0:num_bytes]
            self._remaining_bytes = rem[num_bytes:]
            return res

        # If the server is requesting EXACTLY the bytes the client has
        if leng == num_bytes:
            self._is_in_chunk = False
            del self._remaining_bytes
            return rem

        # If the server is requesting MORE bytes than the client has, block
        assert leng < num_bytes
        raise MyException("in real life this would cause a blocking I/O operation")  # noqa: E501

    def sendall(self, byts):
        tup = self._steps.pop()
        assert 'conn_expect_response_step' == tup[0]
        # (currently, we don't do value assertions on the response)

    def close(self):
        # (close gets called during cleanup when an exception is thrown so..)
        if 'conn_expect_close_step' == self._steps[-1][0]:
            self._steps.pop()


def _experimental_sexp_scanner_via_iterator(itr):

    class scn:  # #class-as-namespace
        def next_RHS_value():
            tup = self.next()
            rhv, = tup[1:]
            return rhv

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


class MyException(RuntimeError):
    pass

# #born
