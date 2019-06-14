def dangerous_memoize(f):
    """decorator for lazy memoization of MONADIC method result

    this is called "dangerous" because ..

    #not-threadsafe
    #open #[#008.B]
    """

    def g(some_self):
        return mutable_f(some_self)

    def initially(orig_self):
        def subsequently(_):
            return x
        nonlocal mutable_f
        mutable_f = None
        x = f(orig_self)
        mutable_f = subsequently
        return g(None)

    mutable_f = initially
    return g


def lazy(f_f):
    """EXPERIMENTAL decorator to evaluate lazily the definition of a function.

    this can be useful if the function wants to draw on complicated setup
    that it's not practical to evaluate when file loads. the subject allows
    you to evaluate your setup only once the first call to the function
    happens.

    compare to the simpler `memoize`.
    #not-threadsafe
    #open #[#008.B]

    NOTE consider using [#872.02] which gets around use of nonlocal
    """

    def g(*a):
        return mutable_f(*a)

    def f_initially(*a):
        f = f_f()
        nonlocal mutable_f
        mutable_f = f
        return f(*a)

    mutable_f = f_initially
    return g


def memoize(f):
    """decorator for lazy memoization of functions.

    compare to the more complicated `lazy`
    #not-threadsafe
    #open #[#008.B]
    """

    def f_initially():
        def f_subsequently():
            return x
        x = f()
        nonlocal mutable_f
        mutable_f = f_subsequently
        return g()

    def g():
        return mutable_f()

    mutable_f = f_initially
    return g


# #history-A.4: fun bit of trivia, things were even uglier before nonlocal
# #history-A.3: a memoizer method moved here from elsewhere
# #history-A.2: a memoizer method moved here from elsewhere
# #history-A.1: a memoizer method moved here from elsewhere
