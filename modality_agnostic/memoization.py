def dangerous_memoize_in_child_classes(attr, builder_method_name):
    """decorator takes two parameters: an attribute to set the value in

    IN THE CLASS, and the name of a builder method to call.
    .#open [#507.F] integrate this with teardown so the memory is reclaimed
    """

    def decorate(f):
        return __do_wicked_memoizer(f, attr, builder_method_name)
    return decorate


def __do_wicked_memoizer(f, attr, builder_method_name):
    def use_f(tc):  # tc = test case
        o = tc.__class__
        if not hasattr(o, attr):
            setattr(o, attr, getattr(tc, builder_method_name)())
        return getattr(o, attr)
    return use_f


def memoize_into(attr):
    def decorator(f):
        def use_f(self):
            if not hasattr(self, attr):
                setattr(self, attr, f(self))
            return getattr(self, attr)
        return use_f
    return decorator


def dangerous_memoize(m):
    # we want to implement this with a class like we do elsewhere for some
    # [#510.6] custom memoizy decorators, bu it breaks weirdly like at
    # [#510.7.2] (grep dump test)
    def build_value(test_context_first_time):
        return m(test_context_first_time)
    return __lazify_method_dangerously(build_value)


def __lazify_method_dangerously(build_value):
    def use_method(invocation_context):
        if self._is_first_call:
            self._is_first_call = False
            self._value = build_value(invocation_context)
        return self._value
    self = _BlankState()
    self._is_first_call = True
    return use_method


def lazify_method_safely(build_value):  # 1x
    def use_method(ignore_invocation_context):
        return valuer()
    valuer = lazy(build_value)
    return use_method


class lazy:  # #[#510.8]

    def __init__(self, f):
        self._function = f
        self._is_first_call = True

    def __call__(self):
        if self._is_first_call:
            self._is_first_call = False
            f = self._function
            del self._function
            self._value = f()
        return self._value


class Counter:
    def __init__(self):
        self.value = 0

    def increment(self):
        self.value += 1


class OneShotMutex:
    def __init__(self):
        self._is_first_call = True

    def shoot(self):
        assert(self._is_first_call)
        self._is_first_call = False


class _BlankState:  # #[#510.2]
    pass

# #history-A.6: get rid of all nonlocal
# #history-A.5: experimental memoizing into a class attribute
# #history-A.4: fun bit of trivia, things were even uglier before nonlocal
# #history-A.3: a memoizer method moved here from elsewhere
# #history-A.2: a memoizer method moved here from elsewhere
# #history-A.1: a memoizer method moved here from elsewhere
