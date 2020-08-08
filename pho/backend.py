#!/usr/bin/env python3

# NOTE:
#   - this is a bridge for the electron frontend to be able to reach our
#     backend using the `python-shell` node.js module
#   - this is not a proper CLI nor should it be developed as one:
#     no help screens, no name completion of commands, etc
#   - but we otherwise structure it similarly to a CLI:
#   - for now we want to be able to invoke it from the terminal for convenience
#   - watch for not duplicating effort with the actual CLI
#   - be prepared to pivot this to a long-running e.g. flask


def _API_for_production():
    import sys as o
    stdout = _prefixer("stdout: ", o.stdout)
    stderr = _prefixer("stderr: ", o.stdout)
    exit(_API(o.stdin, stdout, stderr, o.argv, None))


def _API(sin, sout, serr, argv, enver):

    bash_argv = list(reversed(argv))  # name is tribute to BASH_ARGV (see)

    assert(len(bash_argv))  # assume program name is always first element

    bash_argv.pop()  # we don't care about program name

    if not len(bash_argv):
        serr.write("expecting command name\n")
        return 2

    command_name = bash_argv.pop()
    dct = _command_function_via_name
    if command_name not in dct:
        serr.write(f'unknown command: "{command_name}"\n')
        return 3

    es = dct[command_name](sin, sout, serr, bash_argv, enver)

    if not isinstance(es, int):  # #[#022]
        raise _MyException(f'expected int had: {type(es)}')

    return es


def _build_command_decorator_and_state():
    def command(f):
        name = f.__name__
        assert(name not in dct)
        dct[name] = f
        return f
    dct = {}
    return command, dct


command, _command_function_via_name = _build_command_decorator_and_state()


@command
def retrieve_random_entity(sin, sout, serr, bash_argv, enver):
    coll_path, es = _parse_one_argument(bash_argv, 'collection path', serr)
    if es:
        return es

    mon = _monitor_via_stderr(serr)
    listener = mon.listener

    coll = _collection_via_path(coll_path, listener)

    if coll is None:
        return mon.exitstatus

    yikes = tuple(coll.to_identifier_stream(listener))
    leng = len(yikes)

    if 0 == leng:
        serr.write("collection is empty\n")
        return 5

    from random import Random
    from time import time

    seed = time()
    rng = Random(seed)
    serr.write(f'RNG seed: {seed}\n')
    iden = yikes[rng.randrange(0, leng)]
    id_s = iden.to_string()
    serr.write(f'entity: {id_s}\n')
    ent = coll._impl.retrieve_entity_as_storage_adapter_collection(iden, listener)  # noqa: E501
    dct = ent.core_attributes_dictionary_as_storage_adapter_entity

    from pho.magnetics_.document_fragment_via_definition import \
        document_fragment_via_definition

    document_fragment_via_definition(listener, id_s, dct)  # throws
    dct['identifier'] = id_s

    import json
    json.dump(dct, sout)
    sout.write("\n")
    return 0


@command
def hello_to_pho(sin, sout, serr, bash_argv, enver):  # a.k.a "ping"

    from pho import HELLO_FROM_PHO
    from time import sleep

    sout.write(HELLO_FROM_PHO)
    sout.write('\n')

    if not len(bash_argv):
        serr.write('No arguments\n')
        return 4

    arg = bash_argv.pop()
    sout.write(f'First argument: {arg}\n')
    count = 1

    while len(bash_argv):
        count += 1
        arg = bash_argv.pop()
        length_of_time_to_sleep = 0.718 if count % 2 else 1.180
        sleep(length_of_time_to_sleep)
        sout.write(f'Argument number {count}: {arg}\n')

    return 0


def _parse_one_argument(bash_argv, which, serr):

    if not len(bash_argv):
        serr.write(f"expecting {which}\n")
        return None, 4

    arg = bash_argv.pop()

    if len(bash_argv):
        serr.write("unexpected extra argument\n")
        return None, 4

    return arg, None


def _collection_via_path(coll_path, listener):
    from kiss_rdb import collectionerer
    return collectionerer().collection_via_path(coll_path, listener)


def _monitor_via_stderr(serr):

    from script_lib.magnetics import error_monitor_via_stderr
    return  error_monitor_via_stderr(serr)


class _prefixer:

    def __init__(self, prefix, downstream_IO):
        self._buffer = [prefix]
        self._prefix = prefix
        self._downstream_IO = downstream_IO

    def write(self, string):
        leng = len(string)
        if 0 == leng:
            return 0

        cursor = 0
        while True:
            i = string.find('\n', cursor)
            if -1 == i:
                self._buffer.append(string[cursor:])
                break
            nextCursor = i + 1
            self._buffer.append(string[cursor:nextCursor])
            self.flush()
            if leng == nextCursor:
                break
            cursor = nextCursor

        return leng

    def flush(self):
        if 0 == len(self._buffer):
            return
        big_string = ''.join(self._buffer)
        self._buffer.clear()
        self._buffer.append(self._prefix)
        self._downstream_IO.write(big_string)
        return self._downstream_IO.flush()


class _MyException(RuntimeError):
    pass


if '__main__' == __name__:
    _API_for_production()
else:
    raise RuntimeError('where')

# #history-A.2: structural overhaul to resemble a CLI superficially
# #history-A.1: begin for electron
# #born.
