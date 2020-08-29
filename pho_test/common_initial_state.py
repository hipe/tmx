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
def collection_one():
    directory = fixture_directory_one()
    from pho import collection_via_path_
    return collection_via_path_(directory, lambda *_: xx())


# == Emissions and Listeners

def listener_and_emissions():
    def listener(sev, shape, cat, payloader):
        chan = (sev, shape, cat)
        if 'expression' == shape:
            lines = tuple(payloader())
        else:
            assert('structure' == shape)
            lines = (payloader()['reason'],)
        emissions.append(Emission(chan, lines))
    emissions = []
    return listener, emissions


class Emission:
    def __init__(self, cha, li):
        self.channel = cha
        self.lines = li


def throwing_listenerer():
    from modality_agnostic import listening
    return listening.throwing_listener


# == Directories and related

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
