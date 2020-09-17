import modality_agnostic.test_support.common as helper
import unittest


class _shared_subject:  # :[#510.4]
    # functionally similar to the main one, but the point is to keep one of
    # these in a known stable state so that we can refactor the other one,
    # and when we run tests, breakages to the other one will be detected)

    def __init__(self, f):
        self._method = f
        self._is_first_call = True

    def __call__(self, tc):
        if self._is_first_call:
            self._is_first_call = False
            f = self._method
            del self._method
            self._value = f(tc)
        return self._value


class _CommonYikes(unittest.TestCase):

    @property
    def namedtuple(self):
        from collections import namedtuple
        return namedtuple


class Case0105_memoize(_CommonYikes):

    def test_010_gives_the_same_result_at_each_subsquent_call(self):
        num_a = self.end_state.number_array
        self.assertEqual(1, num_a[0])
        self.assertEqual(1, num_a[1])
        self.assertEqual(1, num_a[2])

    def test_020_it_was_only_ever_called_once(self):
        self.assertEqual(1, self.end_state.num_times)

    @property
    @_shared_subject
    def end_state(self):
        lazy = helper.lazy

        @lazy
        def f():
            counter.increment()
            return counter.value

        counter = helper.Counter()
        _d_a = [f(), f(), f()]

        return self.namedtuple('_CustTpl01', ['num_times', 'number_array'])(
                num_times=counter.value,
                number_array=_d_a)


if __name__ == '__main__':
    unittest.main()

# #history-A.2: sunset lazy function definition
# #history-A.1: re-housed
# (the below should read #open [#007.2] but is kept intact for trackability)
# #open [#007.B] - when we use docutest, um..
