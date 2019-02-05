import _common_state  # noqa: F401
from kiss_rdb_test import structured_emission as selib
import unittest

unindent = selib.unindent

# (subject under test explained exhaustively in [#864] the toml adaptation)


class _CommonCase(unittest.TestCase):

    def _expect_everything_for_create(self):
        id_s, new_s = self.given_identifer_and_lines_for_new_entity()

        _f = _subj_mod().new_lines_via_create_and_existing_lines

        self._expect_everything(id_s, _f, new_s)

    def _expect_everything_for_update(self):
        id_s, new_s = self.given_identifer_and_new_lines_for_existing_entity()

        _f = _subj_mod().new_lines_via_update_and_existing_lines

        self._expect_everything(id_s, _f, new_s)

    def _expect_everything_for_delete(self):
        _id_s = self.given_identifer_for_entity_to_delete()

        _f = _subj_mod().new_lines_via_delete_and_existing_lines

        self._expect_everything(_id_s, _f)

    def _expect_everything(self, id_s, cud_function, new_s=None):

        x = self.expect_these_lines()
        if x is None:  # #here1
            expect_lines = ()
        else:
            expect_lines = tuple(unindent(x))

        new_lines = None if new_s is None else unindent(new_s)

        existing_lines = unindent(self.given_big_string())

        listener = selib.debugging_listener() if False else None

        _out = cud_function(
                identifier_string=id_s,
                incoming_lines=new_lines,
                existing_lines=existing_lines,
                listener=listener)

        actual = tuple(_out)

        self.assertEqual(actual, expect_lines)


class Case041_create_against_truly_empty_file(_CommonCase):

    def test_300_expect_these_lines(self):
        self._expect_everything_for_create()

    def expect_these_lines(self):
        return """
        new line 1
        new line 2
        """

    def given_identifer_and_lines_for_new_entity(self):
        return ('A', """
        new line 1
        new line 2
        """)

    def given_big_string(self):
        return """
        """


class Case125_create_against_effectively_empty_file_with_comments(_CommonCase):

    def test_300_expect_these_lines(self):
        self._expect_everything_for_create()

    def expect_these_lines(self):
        return """
        # the below is a blank line

        new line 1
        new line 2
        """

    def given_identifer_and_lines_for_new_entity(self):
        return ('TODO', """
        new line 1
        new line 2
        """)

    def given_big_string(self):
        return """
        # the below is a blank line

        """


class Case208_create_that_appends_entity_to_the_very_end(_CommonCase):

    def test_300_expect_these_lines(self):
        self._expect_everything_for_create()

    def expect_these_lines(self):
        return """
        [item.B.attributes]
        wing = ding
        new line 1
        new line 2
        """

    def given_identifer_and_lines_for_new_entity(self):
        # (change from 'C' to 'A' to see it break)
        return ('C', """
        new line 1
        new line 2
        """)

    def given_big_string(self):
        return """
        [item.B.attributes]
        wing = ding
        """


class Case292_create_that_inserts_at_the_front(_CommonCase):

    def test_300_expect_these_lines(self):
        self._expect_everything_for_create()

    def expect_these_lines(self):
        return """
        # one blank line below

        new line 1
        new line 2
        [item.B.attributes]
        x = y
        """

    def given_identifer_and_lines_for_new_entity(self):
        return ('A', """
        new line 1
        new line 2
        """)

    def given_big_string(self):
        return """
        # one blank line below

        [item.B.attributes]
        x = y
        """


class Case375_create_that_inserts_in_between(_CommonCase):

    def test_300_expect_these_lines(self):
        self._expect_everything_for_create()

    def expect_these_lines(self):
        return """
        [item.A.meta]
        prop-a = val-a
        [item.B.meta]
        prop-b = val-b
        [item.C.attributes]
        prop-c = val-c
        """

    def given_identifer_and_lines_for_new_entity(self):
        return ('B', """
        [item.B.meta]
        prop-b = val-b
        """)

    def given_big_string(self):
        return """
        [item.A.meta]
        prop-a = val-a
        [item.C.attributes]
        prop-c = val-c
        """


class Case411_create_that_inserts_in_between_no_props(_CommonCase):

    def test_300_expect_these_lines(self):
        self._expect_everything_for_create()

    def expect_these_lines(self):
        return """
        [item.A.meta]
        [item.B.meta]
        [item.C.attributes]
        """

    def given_identifer_and_lines_for_new_entity(self):
        return ('B', """
        [item.B.meta]
        """)

    def given_big_string(self):
        return """
        [item.A.meta]
        [item.C.attributes]
        """


class Case438_update_at_beginning(_CommonCase):

    def test_300_expect_these_lines(self):
        self._expect_everything_for_update()

    def expect_these_lines(self):
        return """
        hallo line 1
        hallo line 2
        [item.bbb.meta]
        prop-b = val-b
        """

    def given_identifer_and_new_lines_for_existing_entity(self):
        return ('aaa', """
        hallo line 1
        hallo line 2
        """)

    def given_big_string(self):
        return """
        [item.aaa.meta]
        prob-a = val-a
        [item.bbb.meta]
        prop-b = val-b
        """


class Case448_update_beginning_no_props(_CommonCase):

    def test_300_expect_these_lines(self):
        self._expect_everything_for_update()

    def expect_these_lines(self):
        return """
        hallo line 1
        [item.bbb.meta]
        """

    def given_identifer_and_new_lines_for_existing_entity(self):
        return ('aaa', """
        hallo line 1
        """)

    def given_big_string(self):
        return """
        [item.aaa.meta]
        [item.bbb.meta]
        """


class Case458_update_in_middle(_CommonCase):

    def test_300_expect_these_lines(self):
        self._expect_everything_for_update()

    def expect_these_lines(self):
        return """
        [item.A.meta]
        prop-a = val-a
        new line 1
        new line 2
        [item.C.attributes]
        prop-c = val-c
        """

    def given_identifer_and_new_lines_for_existing_entity(self):
        return ('B', """
        new line 1
        new line 2
        """)

    def given_big_string(self):
        return """
        [item.A.meta]
        prop-a = val-a
        [item.B.meta]
        prop-b = val-b
        [item.C.attributes]
        prop-c = val-c
        """


class Case478_update_at_end(_CommonCase):

    def test_300_expect_these_lines(self):
        self._expect_everything_for_update()

    def expect_these_lines(self):
        return """
        [item.A.meta]
        prop-a = val-a
        new line 1
        new line 2
        """

    def given_identifer_and_new_lines_for_existing_entity(self):
        return ('B', """
        new line 1
        new line 2
        """)

    def given_big_string(self):
        return """
        [item.A.meta]
        prop-a = val-a
        [item.B.meta]
        prop-b = val-b
        """


class Case542_delete_at_head_no_fluff(_CommonCase):

    def test_300_expect_these_lines(self):
        self._expect_everything_for_delete()

    def expect_these_lines(self):
        return """
        [item.BB.attributes]
        prop-b = val-b
        """

    def given_identifer_for_entity_to_delete(self):
        return 'AA'

    def given_big_string(self):
        return """
        [item.AA.meta]
        prop-a = val-a
        [item.BB.attributes]
        prop-b = val-b
        """


class Case645_delete_at_head_yes_fluff(_CommonCase):

    def test_300_expect_these_lines(self):
        self._expect_everything_for_delete()

    def expect_these_lines(self):
        return """
        # this file is blah blah

        [item.BB.attributes]
        prop-b = val-b
        """

    def given_identifer_for_entity_to_delete(self):
        return 'AA'

    def given_big_string(self):
        return """
        # this file is blah blah

        [item.AA.meta]
        prop-a = val-a
        [item.BB.attributes]
        prop-b = val-b
        """


class Case708_delete_in_middle(_CommonCase):

    def test_300_expect_these_lines(self):
        self._expect_everything_for_delete()

    def expect_these_lines(self):
        return """
        [item.050.meta]
        [item.150.meta]
        """

    def given_identifer_for_entity_to_delete(self):
        return '100'

    def given_big_string(self):
        return """
        [item.050.meta]
        [item.100.attributes]
        [item.150.meta]
        """


class Case792_delete_at_end(_CommonCase):

    def test_300_expect_these_lines(self):
        self._expect_everything_for_delete()

    def expect_these_lines(self):
        return """
        [item.A.meta]
        prop-a = val-a
        """

    def given_identifer_for_entity_to_delete(self):
        return 'B'

    def given_big_string(self):
        return """
        [item.A.meta]
        prop-a = val-a
        [item.B.meta]
        prop-b = val-b
        """


class Case875_delete_leaving_effectively_empty_file(_CommonCase):

    def test_300_expect_these_lines(self):
        self._expect_everything_for_delete()

    def expect_these_lines(self):
        return None  # :#here1

    def given_identifer_for_entity_to_delete(self):
        return 'TheOnlyFellow'

    def given_big_string(self):
        return """
        [item.TheOnlyFellow.attributes]
        attr-one = value 1
        """


def _subj_mod():
    from kiss_rdb.magnetics_ import new_lines_via_CUD_and_existing_lines as _  # noqa: E501
    return _


def cover_me():
    raise Exception('cover me')


if __name__ == '__main__':
    unittest.main()

# #pending-rename: something more specific like entity-CUD, also give it 530
# #born.
