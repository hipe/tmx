import game_server

def stream_via_memoized_array(f):
    """EXPERIMENTAL decorator"""

    # #todo yuck - using arrays as function pointers

    def permanent_f(some_self):
        return current_f_a[0](some_self)

    def at_first_call_only(self_FROM_FIRST_CALL):

        a = f(self_FROM_FIRST_CALL)  # imagine frozen. a long-running
        def at_subsequent_calls(_):
            return iter(a)

        current_f_a[0] = at_subsequent_calls
        return at_subsequent_calls(None)


    current_f_a = [at_first_call_only]

    return permanent_f


shared_subject = game_server.dangerous_memoize


def lazy(f_f):
    """EXPERIMENTAL decorator to evaluate lazily the definition of a function.

    this can be useful if the function wants to draw on complicated setup
    that it's not practical to evaluate when file loads. the subject allows
    you to evaluate your setup only once the first call to the function
    happens.

    compare to the simpler `memoize`.
    #not-threadsafe
    """

    def g(*a):
        return f_pointer[0](*a)

    def f_initially(*a):
        f = f_f();
        f_pointer[0] = f
        return f(*a)

    f_pointer = [f_initially]
    return g


memoize = game_server.memoize
@memoize
def empty_command_module():
    import types
    ns = types.SimpleNamespace()
    setattr(ns, 'PARAMETERS', None)
    class DoYouSeeMe:
        pass
    setattr(ns, 'Command', DoYouSeeMe)
    return ns


class magnetics:
    """much shorter names, insulate from name change"""

    @memoize
    def ARGV():
        from game_server._magnetics import interpretation_via_command_stream_and_ARGV as mag
        return mag

    @memoize
    def command():
        from game_server._magnetics import command_via_parameter_stream as mag
        return mag

    @memoize
    def parameter():
        from game_server._magnetics import parameter_via_definition as mag
        return mag


def fixture_directory_(s):
    import os
    _test_dir = os.path.dirname(os.path.abspath(__file__))
    return os.path.join(_test_dir, 'fixture-directories', s)


def iterator_via_times(num):
    # #todo
    for i in range(0, num): yield i


def hello():
    # for a very low-level (early) regression test.
    0
