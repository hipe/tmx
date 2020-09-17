# 👉 These tests do *not* interact with the real life google sheets API
#
# 👉 They run on *fixtures* which are *recordings* of real life transactions
#
# 👉 As a rule, we never have real life spreadsheet ID's appear in code
#    or even cofig files that would be versioned
#
# 👉 You will need to interact with the real life sheets when developing
#    new kinds of transactions, when making new fixtures, when running some
#    of the the one-off visual tests at the end of this file. Ultimately
#    you will need to interact with the real life sheets in production
#
# 👉 To interact with the real life sheets API, you need OAuth credential
#    tokens (?). Getting them can be involved. The remainder of these points
#    explains how to get the token and some related concerns.
#
# 👉 Go to https://developers.google.com/sheets/api/quickstart/python :#here1
#
# 👉 As directed there, get the credentials.json file and place it in cwd
#
# 👉 We avoid hard-coded spreadsheet ID's or spreadsheet ID's in config files
#    by using environment variables. Those visual transactions below that
#    need real sheets will direct you to set certain environment variables
#    to the correct sheet ID; for example TMX_SPREADSHEET_ID_AC.
#
# 👉 The first time you run such a visual test, hope & pray you get credentials


import unittest


class CommonCase(unittest.TestCase):

    def go_ham(self, tra, sheet_name=None):
        if self.do_debug:
            listener = debugging_listener
        else:
            def listener(severity, *_):
                assert('debug' == severity)

        return this_lib().native_records_via(listener, tra, sheet_name)

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
        itr = self.go_ham(tra, sheet_name='Class Data')
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
def read_from_your_own_thing_as_main(lib):
    # NOTE export TMX_SPREADSHEET_ID_AD='..' to a writable sheet you own
    yield 'sheet_name', 'Sheet Onezo'
    ss_ID_ID = 'spreadsheet-ID-AD'
    tra = lib.live_transactor(ss_ID_ID)
    yield 'tra', tra


@common_as_main
def create_recording_from_live_thing_as_main(lib):
    # NOTE: export TMX_SPREADSHEET_ID_AC='..' to the sheet ID explained #here1
    ss_ID_ID = 'spreadsheet-ID-AC'
    yield 'sheet_name', 'Class Data'
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
    assert('sheet uno' == req.schema.sheet_name)
    assert('A2:E' == req.schema.cell_range_string)

    yield 'aa', 'bb'
    yield 'cc', 'dd'


def this_lib():
    from kiss_rdb_test.google_sheets import transactor_lib
    return transactor_lib()


def debugging_listener(*args):
    from modality_agnostic.test_support.common import debugging_listener
    debugging_listener()(*args)


if __name__ == '__main__':
    # visual tests / see if API still works
    # create_recording_from_in_memory_stuff_as_main()
    # read_recording_from_in_memory_stuff_as_main()
    # create_recording_from_live_thing_as_main()
    # read_from_your_own_thing_as_main()
    unittest.main()

# #born.
