def memoize(f):
    """decorator for lazy memoization of functions.

    compare to the more complicated `lazy`
    #not-threadsafe
    #open [#008.B]
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

# #history-A.1: a memoizer method moved here from elsewhere
