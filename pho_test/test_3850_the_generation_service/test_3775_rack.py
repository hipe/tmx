from modality_agnostic.test_support.common import \
        listener_and_emissions_for
import unittest


class CommonCase(unittest.TestCase):

    def go(self, rc):
        dct = {k: v for k, v in self.given_request_dictionary()}
        listener, emis = listener_and_emissions_for(self)
        from pho.generation_service_.run_message_broker_via_config import \
            _response_dict_via_request_dict as func
        dct = func(dct, listener)
        if self.do_debug:
            print(f"DBG: {dct!r}")
        self.assertEqual(dct['status'], rc)

    do_debug = False


class Case3765_missing_everything(CommonCase):

    def test_010_go(self):
        self.go(2)

    def given_request_dictionary(_):
        return ()


class Case3768_extra(CommonCase):

    def test_010_go(self):
        self.go(3)

    def given_request_dictionary(_):
        yield 'command_name', 'foo',
        yield 'command_args', {'a': 'b'}
        yield 'funky_wazoozle', 'ohai'


class Case3771_type(CommonCase):

    def test_010_go(self):
        self.go(4)

    def given_request_dictionary(_):
        yield 'command_name', 1
        yield 'command_args', 2


class Case3774_ok(CommonCase):

    def test_010_go(self):
        self.go(0)

    def given_request_dictionary(_):
        yield 'command_name', 'ping'
        yield 'command_args', {'args': ('a', 'b', 'c')}


if __name__ == '__main__':
    unittest.main()

# #born
