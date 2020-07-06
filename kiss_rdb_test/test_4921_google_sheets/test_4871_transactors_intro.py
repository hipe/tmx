import unittest


class CommonCase(unittest.TestCase):

    def go_ham(self, tra, subsheet_name=None):
        if self.do_debug:
            listener = debugging_listener
        else:
            def listener(severity, *_):
                assert('debug' == severity)

        return this_lib().native_records_via(listener, tra, subsheet_name)

    do_debug = False


class Case4861_read_in_memory(CommonCase):

    def test_100_everything(self):
        lib = this_lib()
        tra = lib.in_memory_stub_transactor_via_function(in_memory_stub_A)
        out = tuple(self.go_ham(tra))
        self.assertSequenceEqual(out, (('aa', 'bb'), ('cc', 'dd')))


class Case4866_read_hand_written_recording(CommonCase):

    def test_100_everything(self):
        tra = this_lib().read_recording_transactor('spreadsheet-ID-AA')
        out = tuple(self.go_ham(tra))
        self.assertSequenceEqual(out, (
            ["hello mom", "hi mother"],
            ["kanye west", 123],
            "qq mm aa",
            123.45))


class Case4871_read_recording_from_live_thing(CommonCase):

    def test_100_everything(self):
        lib = this_lib()
        tra = lib.read_recording_transactor('spreadsheet-ID-AC')
        itr = self.go_ham(tra, subsheet_name='Class Data')
        xx = next(itr)
        self.assertSequenceEqual(
                xx, ('Alexandra', 'Female', '4. Senior', 'CA', 'English'))

        self.assertSequenceEqual(
                next(itr), ('Andrew', 'Male', '1. Freshman', 'SD', 'Math'))


def common_as_main(f):  # #decorator
    def use_f():
        lib = this_lib()
        args = {k: v for k, v in f(lib)}
        itr = lib.native_records_via(debugging_listener, **args)
        lib.wahoo(itr)

    return use_f


@common_as_main
def create_recording_from_live_thing_as_main(lib):
    # Currently, to talk to a real live google sheet takes a bunch of oauth
    # stuff and a hope and a prayer. Go through the flow as described at
    # https://developers.google.com/sheets/api/quickstart/python
    # As provided there, you need the credentials.json file.
    # The first time you run this, you need a hope and a prayer and to
    # click through a flow and give permission and get your OATH credentials.
    # You also need to set the environment variable TMX_SPREADSHEET_ID_AC='..'
    # with the spreadsheet ID from there.

    ss_ID_ID = 'spreadsheet-ID-AC'
    yield 'subsheet_name', 'Class Data'
    tra = lib.live_transactor(ss_ID_ID)
    tr2 = lib.write_recordings_transactor_via_transactor(ss_ID_ID, tra)
    yield 'tra', tr2


@common_as_main
def read_recording_from_in_memory_stuff_as_main(lib):
    yield 'tra', lib.read_recording_transactor('spreadsheet-ID-AB')


@common_as_main
def create_recording_from_in_memory_stuff_as_main(lib):
    furthest_tra = lib.in_memory_stub_transactor_via_function(in_memory_stub_A)
    yield 'tra', lib.write_recordings_transactor_via_transactor(
            'spreadsheet-ID-AB', furthest_tra)


def in_memory_stub_A(transaction_shape, ss_ID_ID, req):
    assert('values_get' == transaction_shape)
    assert('spreadsheet-ID-AA' == ss_ID_ID)
    assert('sheet uno' == req.subsheet_name)
    assert('A2:E' == req.cel_range_string)

    yield 'aa', 'bb'
    yield 'cc', 'dd'


def this_lib():
    from kiss_rdb_test.google_sheets import transactor_lib
    return transactor_lib()


def debugging_listener(*args):
    from modality_agnostic.test_support.listener_via_expectations import \
        for_DEBUGGING as listener
    listener(*args)


if __name__ == '__main__':
    # visual tests / see if API still works
    # create_recording_from_in_memory_stuff_as_main()
    # read_recording_from_in_memory_stuff_as_main()
    # create_recording_from_live_thing_as_main()
    # exit(0)
    unittest.main()

# #born.
