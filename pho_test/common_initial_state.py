import os.path as os_path


# == Decorators used in this file

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


# == Collections

@lazy
def business_collection_one():
    def rng(pool_size):
        return 11584  # DC6 with two behind it?
    from pho import _Notecards, collection_via_path_
    directory = fixture_directory_one()
    coll = collection_via_path_(directory, lambda *_: xx(), rng)
    return _Notecards(coll)


@lazy
def collection_two():
    return _collection_via_directory(fixture_directory_two())


@lazy
def collection_one():
    return _collection_via_directory(fixture_directory_one())


def _collection_via_directory(directory):
    from pho import collection_via_path_
    return collection_via_path_(directory, lambda *_: xx())


def throwing_listenerer():
    from modality_agnostic import throwing_listener as func
    return func


# == Directories and related

@lazy
def fixture_directory_two():
    return fixture_directory('collection-00600-new-way')


@lazy
def fixture_directory_one():
    return fixture_directory('collection-00500-intro')


def fixture_directory(*tail):
    return os_path.join(fixture_directories_directory(), *tail)


@lazy
def fixture_directories_directory():
    return os_path.join(_top_test_dir(), 'fixture-directories')


@lazy
def _top_test_dir():
    return os_path.dirname(os_path.abspath(__file__))


# == These

def xx(msg=None):
    raise xxx(msg)


def xxx(msg=None):
    use_msg = ''.join(('oops / write me', * ((': ', msg) if msg else ())))
    return RuntimeError(use_msg)

# #born.
