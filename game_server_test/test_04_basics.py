from modality_agnostic.test_support.common import \
        dangerous_memoize_in_child_classes as shared_subject_in_children
import unittest


class CommonCase(unittest.TestCase):

    @property
    @shared_subject_in_children
    def end_state(self):
        return self.build_end_state()

    def build_end_state(self):
        func = support_lib().end_state_via_test_case
        return func(self)

    do_debug = False


# Case110 connect and send zero length string  # very similar to next


class Case114_string_less_than_80_length_and_no_newline(CommonCase):

    def test_010_loads(self):
        assert subject_module()

    def test_050_causes_blocking_IO_operation(self):
        exce = support_lib().MyException
        with self.assertRaises(exce) as ctx:
            self.build_end_state()
        msg, = ctx.exception.args
        self.assertEqual(msg, "in real life this would cause a blocking I/O operation")  # noqa: E501

    def expected_emission_categories(_):
        yield 'waiting'
        yield 'connection'
        yield 'sending'
        yield 'closing'
        yield 'shutting_down'

    def given_requests_and_expected_responses(_):
        yield 'connection', 'some.ip.address', 'port.no-see'
        yield 'sendall_bytes', b'less than 80 no newline'
        yield 'expect_response'
        yield 'expect_close'


class Case118_header_OK(CommonCase):

    def test_050_performs(self):
        assert self.build_end_state()

    def expected_emission_categories(_):
        yield 'waiting'
        yield 'connection'
        yield 'sending'
        yield 'closing'
        yield 'shutting_down'

    def given_requests_and_expected_responses(_):
        yield 'connection', 'some.ip.address', 'port.no-see'
        yield 'send_bytes', content_length(4)
        yield 'sendall_bytes', b'ohai'
        yield 'expect_response'
        yield 'expect_close'


class Case124_one_client_with_multiple_requests(CommonCase):

    def test_050_performs(self):
        assert self.build_end_state()

    def expected_emission_categories(_):
        # DRY #todo
        yield 'waiting'
        yield 'connection'
        yield 'sending'
        yield 'closing'
        yield 'shutting_down'

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

    def expected_emission_categories(_):
        # DRY #todo
        yield 'waiting'
        yield 'connection'
        yield 'sending'
        yield 'closing'
        yield 'shutting_down'

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


def content_length(num):
    line1 = content_length_header_line(num)
    return b''.join((line1, end_of_headers_line))


def content_length_header_line(num):
    return header_line(f'Content length: {num}')


def header_line(content):
    return bytes(''.join((content, ' ' * (79-len(content)), '\n')), 'utf-8')


end_of_headers_line = header_line('End of headers')


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
