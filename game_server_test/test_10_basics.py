import os, sys, unittest

# boilerplate
_ = os.path
path = _.dirname(_.dirname(_.abspath(__file__)))
a = sys.path
if a[0] != path:
    a.insert(0, path)
# end boilerplate

import game_server_test.helper as helper

import game_server

helper.hello()


def _shared_subject(f):
    # (redundant with the other one, but the point is that we keep one of
    # these in a known stable state so that we can refactor the other one,
    # and when we run tests, breakages to the other one will be detected)

    def g(some_self):
        return f_pointer[0](some_self)

    def initially(orig_self):
        def subsequently(_):
            return x
        f_pointer[0] = None
        x = f(orig_self)
        f_pointer[0] = subsequently
        return g(None)

    f_pointer = [initially]
    return g


class _CommonYikes(unittest.TestCase):

    @property
    def namedtuple(self):
        from collections import namedtuple
        return namedtuple



class Case010_basics(unittest.TestCase):

    def test_010_hello_game_server(self):
        x = game_server.hello_game_server()
        self.assertEqual(0, x)


class Case020_memoize(_CommonYikes):

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
            d = times_pointer[0] + 1
            times_pointer[0] = d
            return d

        times_pointer = [0]
        _d_a = [ f(), f(), f() ]

        return self.namedtuple('_CustTpl01', ['num_times', 'number_array'])(
          num_times = times_pointer[0],
          number_array = _d_a,
        )


class Case030_lazy(_CommonYikes):

    def test_010_does_something_different_at_each_call(self):
        s_a = self.end_state.string_array
        self.assertEqual('even: 6', s_a[0])
        self.assertEqual('odd:  7', s_a[1])
        self.assertEqual('even: 8', s_a[2])

    def test_020_but_only_sets_it_up_the_first_time(self):
        self.assertEqual(1, self.end_state.num_times)

    @property
    @_shared_subject
    def end_state(self):
        lazy = helper.lazy
        @lazy
        def f():
            times_pointer[0] += 1
            d = {
                0: 'even: %d',
                1: 'odd:  %d',
            }
            def g(left_num, right_num):
                sum = left_num + right_num
                fmt = d[ sum % 2 ]
                return fmt % sum
            return g

        times_pointer = [0]

        _s_a = [
          f(2, 4),
          f(3, 4),
          f(1, 7),
        ]
        return self.namedtuple('_CustTpl02', ['num_times', 'string_array'])(
          num_times = times_pointer[0],
          string_array = _s_a,
        )


if __name__ == '__main__':
    unittest.main()
# #open [#007.B] - when we use docutest, um..
# #pending-rename: move to the meta-tests, make it the first test. scrap `hello_game_server`
