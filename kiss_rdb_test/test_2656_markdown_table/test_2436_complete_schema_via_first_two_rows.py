import modality_agnostic.test_support.common as em
from modality_agnostic.test_support.common import lazy
import unittest


class CommonCase(unittest.TestCase):
    do_debug = False


def _be_like_so(self, orig_s, exp_s):
    _actual_s = self._go_subject(orig_s)
    self.assertEqual(_actual_s, exp_s)


def _split_like_so(self, orig_s, * expect_these_s_a):
    _actual_these = self._go_subject(orig_s)
    self.assertEqual(_actual_these, expect_these_s_a)


class Case2435_camel_case(CommonCase):

    def test_010_nothing(self):
        self._this('hi', 'hi')

    def test_020_something(self):
        self._this('Foo', 'Foo')

    def test_030_two(self):
        self._this('FooBar', 'Foo', 'Bar')

    def test_040_three(self):
        self._this('FooBarBaz', 'Foo', 'Bar', 'Baz')

    _this = _split_like_so

    def _go_subject(self, big_s):
        from kiss_rdb import _memoized
        f = _memoized.namer.split_on_camel_case
        return tuple(s for s in f(big_s))


class Case2436_normalize_freeform_strings(CommonCase):  # #midpoint

    def test_010(self):
        self._this('FooBar  biffo-bazzo', 'foo_bar_biffo_bazzo')

    def test_020(self):
        self._this("Mom's spaghetti!!!", 'moms_spaghetti')

    _this = _be_like_so

    def _go_subject(self, big_s):
        return _stowaway_subject_function()(big_s)


class Case2437_endcap_is_required(CommonCase):

    def test_010_loads(self):
        self.assertIsNotNone(subject_function())

    def test_rumskalla(self):
        listener, emissions = em.listener_and_emissions_for(self, limit=2)
        _line = "|I don't|have an|endcap\n"
        tup = tuple(subject_function()((_line,), listener))
        assert(not len(tup))
        emi, *_ = emissions
        actual = emi.to_messages()
        expected = ('header row 1 must have "endcap" (trailing pipe)',)
        self.assertSequenceEqual(actual, expected)


def _stowaway_subject_function():
    from kiss_rdb import normal_field_name_via_string
    return normal_field_name_via_string


def _subject_module():
    from kiss_rdb.storage_adapters_.markdown_table.magnetics_ import (
        schema_index_via_schema_row as mod)
    return mod


if __name__ == '__main__':
    unittest.main()

# #born.
