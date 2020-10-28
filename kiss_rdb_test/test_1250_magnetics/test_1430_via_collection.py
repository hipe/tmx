from modality_agnostic.test_support.common import \
        dangerous_memoize as shared_subject, lazy
import modality_agnostic.test_support.common as em
import doctest
import unittest


def load_tests(loader, tests, ignore):  # (this is a unittest API hook-in)
    tests.addTests(doctest.DocTestSuite(_subject_module()))
    return tests


class CommonCase(unittest.TestCase):

    def _said_this(self, msg):
        _tup = self.end_state
        msgs = _tup[1]
        self.assertEqual(len(msgs), 1)
        self.assertEqual(msgs[0], msg)

    def _result_is_none(self):
        _tup = self.end_state
        self.assertIsNone(_tup[0])

    def _execute_while_listening(self, **kwargs):

        _coll = self._collection()
        _needle = self._needle_function()

        listener, emissions = em.listener_and_emissions_for(self, limit=1)

        _x = _subject_module().key_and_entity_via_collection(
                collection=_coll,
                needle_function=_needle,
                listener=listener,
                **kwargs)

        emi, = emissions
        msgs = tuple(emi.payloader())
        return (_x, msgs)

    def _execute_while_not_listening(self, **kwargs):

        _coll = self._collection()
        _needle = self._needle_function()

        return _subject_module().key_and_entity_via_collection(
                collection=_coll,
                needle_function=_needle,
                listener=None,
                **kwargs)

    do_debug = False


class Case1428_anything_against_none(CommonCase):

    def test_050_subject_module_loads(self):
        # (currently redudant and pointless because of doctest integ but meh.)
        self.assertIsNotNone(_subject_module())

    def test_100_result_is_none(self):
        self._result_is_none()

    def test_200_said_thing_not_found_and_(self):
        self._said_this("'zingo_bango' not found. (there's nothing)")

    @shared_subject
    def end_state(self):
        return self._execute_while_listening()

    def _needle_function(self):
        return 'zingo_bango'

    def _collection(self):
        return _the_empty_collection()


class Case1429_splay(CommonCase):

    def test_100_result_is_none(self):
        self._result_is_none()

    def test_200_splays(self):
        _exp = "no choo chi named 'zanga_tanga'. (there's 'ha_hu', 'he_hu'…)"
        self._said_this(_exp)

    @shared_subject
    def end_state(self):
        return self._execute_while_listening(
                item_noun_phrase=lambda: 'choo chi')

    def _needle_function(self):
        return 'zanga_tanga'

    def _collection(self):
        return _collection_B()


class Case1431_ambiguous(CommonCase):

    def test_100_result_is_none(self):
        self._result_is_none()

    def test_200_splays(self):
        _exp = "'fi*' was ambiguous. did you mean 'fiz' or 'fin'?"
        self._said_this(_exp)

    @shared_subject
    def end_state(self):
        return self._execute_while_listening(
                say_collection='bazonga',
                subfeatures_via_item=lambda k, item: item[2],  # #here1
                say_needle=lambda: "'fi*'")  # note redundancy with below

    def _needle_function(self):
        import re
        rx = re.compile('^fi')

        def f(s):
            return rx.search(s)  # hi.
        return f

    def _collection(self):
        return _collection_C()


class Case1432_succeed(CommonCase):

    def test_100_result_is_not_none(self):
        self.assertIsNotNone(self.end_state)

    def test_200_first_element_of_tuple_is_entity_natural_key(self):
        _k = self.end_state[0]
        self.assertEqual(_k, 'red_ranger')

    def test_300_second_element_is_item(self):
        _x = self.end_state[1]
        self.assertEqual(_x[1], 'zizi')

    @shared_subject
    def end_state(self):
        return self._execute_while_not_listening(
                say_collection='bazonga',
                subfeatures_via_item=lambda k, item: item[2])  # #here1

    def _needle_function(self):
        return 'foz'

    def _collection(self):
        return _collection_C()


@lazy
def _collection_C():
    x = 'no see'
    pairs = (
            # :#here1
            ('blue_ranger', (x, x, ('fiz', 'fim', 'fap'))),
            ('red_ranger', (x, 'zizi', ('fuz', 'foz', 'faz'))),
            ('yellow_ranger', (x, x, ('fin', 'foo', 'fuu'))),
            ('green_ranger', (x, x, ())))
    return _collection_via_pairs(iter(pairs))  # risky, experimental


@lazy
def _collection_B():
    pairs = (
            ('ha_hu', 'no see'),
            ('he_hu', 'no see'),
            ('hi_hu', 'no see'),
            ('ho_hu', 'no see'),
            ('hu_hu', 'no see'))
    return _collection_via_pairs(iter(pairs))  # risky, experimental


@lazy
def _the_empty_collection():
    return _collection_via_pairs(iter(()))  # risky, experimental


def _collection_via_pairs(pairs):
    return _subject_module().collection_via_pairs_cached(pairs)


@lazy
def _subject_module():
    import kiss_rdb.magnetics.via_collection as x
    return x


if __name__ == '__main__':
    unittest.main()

# #born.
