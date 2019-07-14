import os.path as os_path


def lazy(f):  # #meh
    is_first_call = True
    x = None

    def use_f():
        nonlocal is_first_call
        nonlocal x
        if is_first_call:
            is_first_call = False
            x = f()
        return x
    return use_f




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
