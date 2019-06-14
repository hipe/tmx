from kiss_rdb_test.common_initial_state import unindent
import unittest


"""
Adapter-specific edge-cases of CUD,

like what happens when creating into an empty collection (and more broadly,
what does "empty collection" mean exactly, here); do appends at the end and
inserts at the beginning work.

These are the generic cases we want to cover for all adapters:

    Can you {create|delete} into/from {an empty|a not empty} collection?

That ☝️ produces four cases to cover.

But there are more adapter-specific concerns we have:

    What if {insert/append |delete} at/from the {beginning|middle|end}?

This sounds overblown but invariably weird behavior emerges around comments &
whitespace when you start adding and removing blocks (like #open [#867.H]).

It *appears* that this is not integrated with the collection façade (using
a very document-line-centric interface, for both input and output) so it may
by orthogonal to canon.
"""


def expect_everything(orig_f):
    def new_f(self):

        x = self.expect_these_lines()
        _expect_lines = () if x is None else tuple(unindent(x))  # #here1

        _existing_lines = unindent(self.given_big_string())

        _listener = None  # _debugging_listener

        _out_lines_itr = orig_f(self, {
            'existing_lines': _existing_lines,
            'listener': _listener,
            })

        _actual = tuple(_out_lines_itr)

        self.assertEqual(_actual, _expect_lines)
    return new_f


class _CommonCase(unittest.TestCase):

    @expect_everything
    def _expect_everything_for_update(self, kwargs):

        def new_lines_via_entity(_mde_, _listener_):
            return tuple(unindent(new_s))

        id_s, new_s = self.given_identifer_and_new_lines_for_existing_entity()

        return _subj_mod().new_lines_via_update_and_existing_lines(
                new_lines_via_entity=new_lines_via_entity,
                identifier_string=id_s,
                **kwargs,
                )

    @expect_everything
    def _expect_everything_for_create(self, kwargs):
        id_s, new_s = self.given_identifer_and_lines_for_new_entity()
        _incoming_lines = unindent(new_s)
        return _subj_mod().new_lines_via_create_and_existing_lines(
                new_entity_lines=_incoming_lines,
                identifier_string=id_s,
                **kwargs)

    @expect_everything
    def _expect_everything_for_delete(self, kwargs):
        return _subj_mod().new_lines_via_delete_and_existing_lines(
                identifier_string=self.given_identifer_for_entity_to_delete(),
                **kwargs
                )


_empty_dict_OCD = {}


class Case4276_create_against_truly_empty_file(_CommonCase):

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


class Case4277_create_against_effectively_empty_file_with_comments(_CommonCase):  # noqa: E501

    def test_300_expect_these_lines(self):
        self._expect_everything_for_create()

    def expect_these_lines(self):
        return """
        # the below is a blank line

        new line 1
        new line 2
        """

    def given_identifer_and_lines_for_new_entity(self):
        return ('no see 1234', """
        new line 1
        new line 2
        """)

    def given_big_string(self):
        return """
        # the below is a blank line

        """


class Case4278_create_that_appends_entity_to_the_very_end(_CommonCase):

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


class Case4279_create_that_inserts_at_the_front(_CommonCase):

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


class Case4280_create_that_inserts_in_between(_CommonCase):

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


class Case4282_create_that_inserts_in_between_no_props(_CommonCase):

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


class Case4283_delete_at_head_no_fluff(_CommonCase):

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


class Case4284_delete_at_head_yes_fluff(_CommonCase):  # #midpoint in file

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


class Case4285_delete_in_middle(_CommonCase):

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


class Case4286_delete_at_end(_CommonCase):

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


class Case4288_delete_leaving_effectively_empty_file(_CommonCase):

    def test_300_expect_these_lines(self):
        self._expect_everything_for_delete()

    def expect_these_lines(self):
        return None

    def given_identifer_for_entity_to_delete(self):
        return 'TheOnlyFellow'

    def given_big_string(self):
        return """
        [item.TheOnlyFellow.attributes]
        attr-one = value 1
        """


class Case4289_update_at_beginning(_CommonCase):

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


class Case4290_update_beginning_no_props(_CommonCase):

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


class Case4291_update_in_middle(_CommonCase):

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


class Case4292_update_at_end(_CommonCase):

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


def _subj_mod():
    from kiss_rdb.storage_adapters_.toml import (
            file_lines_via_CUD_entity_and_file_lines as _)
    return _


def cover_me():
    raise Exception('cover me')


if __name__ == '__main__':
    unittest.main()

# #born.
