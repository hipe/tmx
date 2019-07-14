import os.path as os_path


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


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')




def fixture_directory(stem):
    return os_path.join(fixture_directories_path(), stem)


@lazy
def fixture_directories_path():
    return os_path.join(_top_test_dir, 'fixture-directories')


def throwing_listenerer():
    return kiss_rdber().THROWING_LISTENER


def kiss_rdber():
    import kiss_rdb as _
    return _

# #born.
