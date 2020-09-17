from modality_agnostic.memoization import \
        dangerous_memoize as shared_subject, lazy
import unittest


CommonCase = unittest.TestCase


class Case250_parse_lines(CommonCase):

    def test_100_loads(self):
        self.assertIsNotNone(asset_lib())

    def test_150_parses(self):
        self.assertLess(0, len(self.raw_structs))

    def test_200_date_and_time_and_message_parse(self):
        o = self.raw_structs[0]
        self.assertEqual(o.date_string, '07-07')
        self.assertEqual(o.time_string, '11:51:01')
        self.assertEqual(o.message_string, "ohai i am the first record")

    def test_250_date_isnt_necessary(self):
        o = self.raw_structs[1]
        self.assertIsNone(o.date_string)
        assert(o.time_string)
        assert(o.message_string)

    def test_300_time_isnt_necessary(self):
        o = self.raw_structs[2]
        self.assertIsNone(o.date_string)
        assert(o.message_string)

    @property
    def raw_structs(self):
        return raw_structs_one()


class Case255_normal_structs(CommonCase):

    def test_100_parses(self):
        self.assertIsNotNone(self.normal_structs)

    def test_150_entities_with_one_message_still_have_a_tuple(self):
        o = self.normal_structs[0]
        self.assertIsInstance(o.message_strings, tuple)
        self.assertEqual(len(o.message_strings), 1)
        self.assertEqual(o.message_strings[0][0:4], 'ohai')

    def test_200_entities_without_a_date_take_the_previous_date(self):
        o = self.normal_structs[1]
        self.assertEqual(o.date_string, '07-07')
        self.assertEqual(o.time_string, '11:52:02')  # make sure it's right one

    def test_250_multi_line_messages_look_like_this(self):
        self.assertSequenceEqual(
                self.normal_structs[1].message_strings,
                ('same day different time', 'this is a follow-up line'))

    def test_300_lineno_is_number_of_first_line(self):
        ent1, ent2 = self.normal_structs
        self.assertEqual(ent1.lineno, 1)
        self.assertEqual(ent2.lineno, 2)

    @property
    def normal_structs(self):
        return normal_structs_one()


class Case260_normal_entities_for_sync(CommonCase):

    def test_100_works(self):
        self.assertIsNotNone(self.result)

    def test_150_first_element_is_remote_reference_entity(self):
        ref = self.result[0]
        self.assertSequenceEqual(dat(ref), ('07-06', '11:12'))
        lines = ("humongous mungus", "line 2")
        self.assertSequenceEqual(msgs(ref), lines)

    def test_200_second_and_last_element_is_entities_to_add(self):
        res = self.result
        self.assertEqual(len(res), 2)

        ent1, ent2 = res[1]  # implicit assertion
        self.assertSequenceEqual(dat(ent1), ('07-06', '11:13:00'))
        self.assertSequenceEqual(msgs(ent1), (("ohai i am a new guy",)))

        self.assertSequenceEqual(dat(ent2), ('07-06', '11:14:00'))
        lines = ("i am another new guy", "new guy line 2")
        self.assertSequenceEqual(msgs(ent2), lines)

    def test_250_big_money_lets_go(self):
        x = asset_lib().records_to_push_via_entities_to_push_(*self.result)
        expected = (
            ('', '11:14', 'i am another new guy'),
            ('', '', 'new guy line 2'),
            ('', '11:13', 'ohai i am a new guy'))

        sequence_equal_recursive(self, tuple(x), expected)

    @shared_subject
    def result(self):
        lines = (
                "  05-05 55:55:55  will be passed over\n",
                "  07-06 66:66:66  also passed over\n",
                "        11:12:00  humongous mungus\n",
                "                  line 2\n",
                "        11:13:00  ohai i am a new guy\n",
                "        11:14:00  i am another new guy\n",
                "                  new guy line 2\n")

        local_itr = asset_lib().normal_structs_via_lines(lines)

        from kiss_rdb.storage_adapters_.google_sheets import \
            EXPERIMENT_READ as f
        remote_itr = f(recordings_dir(), _ss_ID_ID, _sheet_name, _cell_range)

        f = asset_lib().reference_and_normal_entities_to_sync_
        return f(local_itr, remote_itr, listener=None)


def dat(normal):
    return (normal.date_string, normal.time_string)


def msgs(normal):
    return normal.message_strings


def sequence_equal_recursive(tc, have, expect):
    tc.assertEqual(len(have), len(expect))
    for i in range(0, len(expect)):
        tc.assertSequenceEqual(have[i], expect[i])  # ..


@lazy
def normal_structs_one():
    _ = raw_structs_one()
    return tuple(asset_lib().normal_structs_via_line_record_structs_(_))


@lazy
def raw_structs_one():
    lines = ("  07-07 11:51:01  ohai i am the first record\n",
             "        11:52:02  same day different time\n",
             "                  this is a follow-up line\n")

    return tuple(asset_lib().line_record_structs_via_lines_(lines))


def read_live_recordings_as_main():
    from kiss_rdb.storage_adapters_.google_sheets import EXPERIMENT_READ as f
    itr = f(recordings_dir(), _ss_ID_ID, _sheet_name, _cell_range)
    for rec in itr:
        print(f'Ok wow: {rec}')
    print('done.')


def make_live_recording_as_main():
    from kiss_rdb.storage_adapters_.google_sheets import EXPERIMENT_RECORD as f
    itr = f(recordings_dir(), _ss_ID_ID, _sheet_name, _cell_range)
    for rec in itr:
        pass
    print('done.')


_ss_ID_ID = 'spreadsheet-ID-PAA'
_sheet_name = 'Sheet Onezo'
_cell_range = 'A2:C'


@lazy
def recordings_dir():
    from pho_test.common_initial_state import fixture_directory
    return fixture_directory('google-sheets')


def asset_lib():
    from pho.magnetics import timestamp_records_via_lines
    return timestamp_records_via_lines


def do_me():
    raise NotImplementedError("do me")


if __name__ == '__main__':
    # visual / fixture creators
    # make_live_recording_as_main()
    # read_live_recordings_as_main()

    unittest.main()

# #born.
