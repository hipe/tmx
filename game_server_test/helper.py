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


def shared_subject(f):
    """decorator for lazy memoization of MONADIC method result

    #todo - we are borrowing an idiom from a different ecosystem. this is
    *certainly* not the way to implement it here, but it's a stand in.

    #not-threadsafe
    """

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


def memoize(f):
    """decorator for lazy memoization of functions.

    compare to the more complicated `lazy`
    #not-threadsafe
    """

    def f_initially():
        def f_subsequently():
            return x
        x = f()
        f_pointer[0] = f_subsequently
        return g()

    def g():
        return f_pointer[0]()

    f_pointer = [f_initially]
    return g


def fixture_directory_(s):
    import os
    _test_dir = os.path.dirname(os.path.abspath(__file__))
    return os.path.join(_test_dir, 'fixture-directories', s)



@memoize
def empty_iterator():
    # "THE_EMPTY_STREAM"
    return iter(())


def iterator_via_times(num):
    # #todo
    for i in range(0, num): yield i


def hello():
    # for a very low-level (early) regression test.
    0
