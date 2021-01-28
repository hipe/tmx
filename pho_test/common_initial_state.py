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
def big_index_one():
    bcoll = read_only_business_collection_one()
    return bcoll.build_big_index_OLD_(None)


@lazy  # 👀
def mutable_business_collection_one():
    return _mutable_business_collection_via(fixture_directory_one())


@lazy
def read_only_business_collection_two():
    return _read_only_business_collection_via(fixture_directory_two())


@lazy
def read_only_business_collection_one():
    return _read_only_business_collection_via(fixture_directory_one())


def _mutable_business_collection_via(collection_path):
    def rng(pool_size):
        return 11584  # DC6 with two behind it?
    from pho import _mutable_business_collection_via as func
    return func(collection_path, rng)


def _read_only_business_collection_via(directory):
    from pho import read_only_business_collection_via_path_ as func
    return func(directory)


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
    use_msg = ''.join(('oops / write me', * ((': ', msg) if msg else ())))
    raise RuntimeError(use_msg)

# #born.
