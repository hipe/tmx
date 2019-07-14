import modality_agnostic.memoization as helper
import unittest


def _shared_subject(f):
    # (redundant with the other one, but the point is that we keep one of
    # these in a known stable state so that we can refactor the other one,
    # and when we run tests, breakages to the other one will be detected)

    def g(some_self):
        return mutable_function(some_self)

    def initially(orig_self):
        def subsequently(_):
            return x

        nonlocal mutable_function
        mutable_function = None
        x = f(orig_self)
        mutable_function = subsequently
        return g(None)

    mutable_function = initially
    return g


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
        memoize = helper.memoize

        @memoize
        def f():
            nonlocal count
            d = count + 1
            count = d
            return d

        count = 0
        _d_a = [f(), f(), f()]

        return self.namedtuple('_CustTpl01', ['num_times', 'number_array'])(
                num_times=count,
                number_array=_d_a,
        )


if __name__ == '__main__':
    unittest.main()

# #history-A.1: re-housed
# (the below should read #open [#007.2] but is kept intact for trackability)
# #open [#007.B] - when we use docutest, um..
