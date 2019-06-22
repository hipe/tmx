def dangerous_memoize_in_child_classes(attr_name, builder_method_name):
    """decorator takes two parameters: an attribute to set the value in

    IN THE CLASS, and the name of a builder method to call.
    .#todo we need to integrate this with teardown so the memory is reclaimed
    """

    def decorate(f):
        return __do_wicked_memoizer(f, attr_name, builder_method_name)
    return decorate


def __do_wicked_memoizer(f, attr_name, builder_method_name):
    def use_f(tc):  # tc = test case
        o = tc.__class__
        if hasattr(o, attr_name):
            return getattr(o, attr_name)
        x = getattr(tc, builder_method_name)()
        setattr(o, attr_name, x)
        return x
    return use_f


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


# #history-A.5: experimental memoizing into a class attribute
# #history-A.4: fun bit of trivia, things were even uglier before nonlocal
# #history-A.3: a memoizer method moved here from elsewhere
# #history-A.2: a memoizer method moved here from elsewhere
# #history-A.1: a memoizer method moved here from elsewhere
