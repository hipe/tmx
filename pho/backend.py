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

    argp = _arg_parser(list(reversed(argv)), serr)
    _, es = argp.parse_one_argument()
    assert(not es)  # assume program name is always first element. discard
    command_name, es = argp.parse_one_argument('command name')
    if es:
        return es
    dct = _command_function_via_name
    if command_name not in dct:
        serr.write(f'unknown command: "{command_name}"\n')
        return 3

    es = dct[command_name](sin, sout, serr, argp, enver)

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
def retrieve_random_entity(sin, sout, serr, argp, enver):
    args, es = argp.parse_all_args('collection path')
    if es:
        return es
    coll_path, = args
    coll, mon = _collection_and_monitor(coll_path, serr)
    if coll is None:
        return mon.exitstatus
    listener = mon.listener
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
    serr.write(f'entity: {iden.to_string()}\n')
    ent_dct = coll.retrieve_entity_via_identifier(iden, listener)
    assert(ent_dct)
    return _write_entity_as_JSON(sout, ent_dct, listener)


@command
def retrieve_entity(sin, sout, serr, argp, enver):
    args, es = argp.parse_all_args('entity identifier', 'collection path')
    if es:
        return es
    eid_s, coll_path = args
    coll, mon = _collection_and_monitor(coll_path, serr)
    if coll is None:
        return mon.exitstatus
    ent_dct = coll.retrieve_entity(eid_s, mon.listener)
    if ent_dct is None:
        return mon.exitstatus
    return _write_entity_as_JSON(sout, ent_dct, mon.listener)


def _write_entity_as_JSON(sout, ent_dct, listener):
    eid_s = ent_dct['identifier_string']
    dct = ent_dct['core_attributes']
    from pho.magnetics_.document_fragment_via_definition import \
        document_fragment_via_definition
    document_fragment_via_definition(listener, eid_s, dct)  # throws
    dct['identifier'] = eid_s  # munge now that we ensured business fields
    import json
    indent = 2  # set to None to put it all on one line. 2 for pretty (longer)
    json.dump(dct, sout, indent=indent)
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


def _collection_and_monitor(coll_path, serr):
    mon = _monitor_via_stderr(serr)
    coll = _collection_via_path(coll_path, mon.listener)
    if coll is None:
        return None, mon
    return coll, mon


def _collection_via_path(coll_path, listener):
    from kiss_rdb import collectionerer
    return collectionerer().collection_via_path(coll_path, listener)


def _arg_parser(bash_argv, serr):
    # `bash_argv` is tribute to BASH_ARGV (see! it's reversed. it's a stack)

    def parse_all_args(*formals):
        args = []
        for formal in formals:
            arg, es = parse_one_argument(formal)
            if es:
                return None, es
            args.append(arg)

        if (es := assert_empty()):
            return None, es

        return tuple(args), None

    def parse_one_argument(formal=None):
        if len(bash_argv):
            return bash_argv.pop(), None
        serr.write(f"expecting {formal or 'argument'}\n")
        return None, 2

    def assert_empty():
        if not len(bash_argv):
            return
        serr.write("unexpected extra argument\n")
        return 2

    _1 = parse_all_args  # not ok
    _2 = parse_one_argument

    class parser:  # class as namespace
        parse_all_args = _1
        parse_one_argument = _2
    return parser


def _monitor_via_stderr(serr):
    from script_lib.magnetics import error_monitor_via_stderr
    return error_monitor_via_stderr(serr)


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


def xx():
    raise _MyException('write me')


class _MyException(RuntimeError):
    pass


if '__main__' == __name__:
    _API_for_production()
else:
    raise RuntimeError('where')

# #history-A.2: structural overhaul to resemble a CLI superficially
# #history-A.1: begin for electron
# #born.
