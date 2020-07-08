from modality_agnostic.memoization import lazy
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


@lazy
def normal_structs_one():
    _ = raw_structs_one()
    return tuple(asset_lib().normal_structs_via_line_record_structs(_))


@lazy
def raw_structs_one():
    lines = ("  07-07 11:51:01  ohai i am the first record\n",
             "        11:52:02  same day different time\n",
             "                  this is a follow-up line\n")

    return tuple(asset_lib().line_record_structs_via_lines(lines))


def asset_lib():
    from pho.magnetics import timestamp_records_via_lines
    return timestamp_records_via_lines


def do_me():
    raise NotImplementedError("do me")


if __name__ == '__main__':
    unittest.main()

# #born.
