from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subject_in_children
import unittest


class CommonCase(unittest.TestCase):

    @property
    @shared_subject_in_children
    def end_state(self):
        return self.build_end_state()

    def build_end_state(self):
        func = support_lib().end_state_for_server_via_test_case
        return func(self)

    def expected_emission_categories(_):
        yield 'waiting'
        yield 'connection'
        yield 'sending'
        yield 'closing'
        yield 'shutting_down'

    def given_string_via_string_function(_):
        return default_string_via_string_function

    do_debug = False


def default_string_via_string_function(request_message, _listener):
    leng = len(request_message)
    if leng < 13:
        desc = repr(request_message)
    else:
        beg = request_message[:6]
        end = request_message[-7:]
        desc = f"({beg}..{end})"
    return f"I enjoyed processing this: {desc}"


# Case110 connect and send zero length string  # very similar to next


class Case114_string_has_no_double_newline(CommonCase):

    def test_010_loads(self):
        assert subject_module()

    def test_050_causes_blocking_IO_operation(self):
        exce = support_lib().MyException
        with self.assertRaises(exce) as ctx:
            self.build_end_state()
        msg, = ctx.exception.args
        self.assertEqual(msg, "in real life this would cause a blocking I/O operation")  # noqa: E501

    def given_requests_and_expected_responses(_):
        yield 'connection', 'some.ip.address', 'port.no-see'
        yield 'sendall_bytes', b'one newline but not two\nhi'
        yield 'expect_response'
        yield 'expect_close'


class Case118_header_OK(CommonCase):

    def test_050_performs(self):
        assert self.end_state

    def test_100_response(self):
        memo = self.end_state
        response = memo['RESPO']
        self.assertIn(b"I enjoyed processing this: 'ohai'", response)

    def given_requests_and_expected_responses(_):
        yield 'connection', 'some.ip.address', 'port.no-see'
        yield 'send_bytes', content_length(4)
        yield 'sendall_bytes', b'ohai'
        yield 'expect_response', 'as', 'RESPO'
        yield 'expect_close'


class Case124_one_client_with_multiple_requests(CommonCase):

    def test_050_performs(self):
        assert self.build_end_state()

    def given_requests_and_expected_responses(_):
        yield 'connection', 'some.ip.address', 'port.no-see'
        yield 'send_bytes', content_length(6)
        yield 'sendall_bytes', b'ohai 1'
        yield 'expect_response'
        yield 'send_bytes', content_length(6)
        yield 'sendall_bytes', b'ohai 2'
        yield 'expect_response'
        yield 'expect_close'


class Case128_one_client_then_another_client(CommonCase):

    def test_050_performs(self):
        assert self.build_end_state()

    def given_requests_and_expected_responses(_):
        yield 'connection', 'ip.address.one', 'port.no-see'
        yield 'send_bytes', content_length(6)
        yield 'sendall_bytes', b'ohai A'
        yield 'expect_response'
        yield 'expect_close'
        yield 'connection', 'ip.address.two', 'port.no-see'
        yield 'send_bytes', content_length(6)
        yield 'sendall_bytes', b'ohai B'
        yield 'expect_response'
        yield 'expect_close'


class ClientCase(unittest.TestCase):

    def build_end_state(self):
        func = support_lib().end_state_for_client_via_test_case
        return func(self)

    do_debug = False


class Case150_CLIENT_WAH_GWAN(ClientCase):

    def test_500(self):
        self.build_end_state()

    def given_session(self, client):
        act = client.send_string('zib zum cha chum')
        exp = 'foo fa'  # string not bytes
        self.assertEqual(act, exp)

    def given_client_requests_and_expected_responses(_):
        yield 'expect_emission', 'info', 'sending'
        yield 'expect_call_to', 'sendall', 'record_arg_as', 'feat. never used'
        yield 'expect_call_to', 'HEADERS', 'result_via', lambda: _all_hdrs(6)
        yield 'expect_call_to', 'recv', 'result_via', lambda n: _TING(n)
        yield 'expect_emission', 'info', 'got_response'
        yield 'expect_emission', 'info', 'closing'
        yield 'expect_call_to', 'close'


# == No

def _all_hdrs(content_length):
    lines = []
    lines.append(content_length_header_line(content_length))
    lines.append(end_of_headers_line)
    return b''.join(lines)


def _TING(n):
    assert 6 == n
    return b'foo fa'


# ==

def content_length(num):
    line1 = content_length_header_line(num)
    return b''.join((line1, end_of_headers_line))


def content_length_header_line(num):
    return header_line(f'Content length: {num}')


def header_line(content):
    return b''.join((bytes(content, 'utf-8'), b'\n'))


end_of_headers_line = b'\n'


def support_lib():
    import game_server_test.mock_sock as module
    return module


def subject_module():
    import game_server as module
    return module


def xx(msg):
    raise RuntimeError(f"ohai: {msg}")


if __name__ == '__main__':
    unittest.main()

# #pending-rename: to something like 'string-based tcp/ip servers and clients'
# #history-B.4: repurpose, spike string-based tcp/ip server and client
# #born: lost DNA
