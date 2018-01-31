def dangerous_memoize(f):
    """decorator for lazy memoization of MONADIC method result

    this is called "dangerous" because ..

    #not-threadsafe
    #open #[#008.B]
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
        f_pointer[0] = f_subsequently
        return g()

    def g():
        return f_pointer[0]()

    f_pointer = [f_initially]
    return g


def hello_game_server():
    return 0

def main():
  print("hello from the game server.")


class Exception(Exception):
    pass


# #history-A.2: a memoizer method moved here from elsewhere
# #history-A.1: a memoizer method moved here from elsewhere
