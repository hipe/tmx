def lazy(f):  # #[#510.8]
    class EvaluateLazily:
        def __init__(self):
            self._has_been_evaluated = False

        def __call__(self):
            if not self._has_been_evaluated:
                self._has_been_evaluated = True
                self._value = f()
            return self._value
    return EvaluateLazily()


@lazy
def writable_tmpdir():
    from os import path as os_path
    return os_path.join(os_path.dirname(__file__), 'writable-tmpdir')

# #abstracted: mostly copy-pasted
