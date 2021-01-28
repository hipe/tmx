#!/usr/bin/env python3

# NOTE:
#   - this is a bridge for the electron frontend to be able to reach our
#     backend using the `python-shell` node.js module
#   - this is not a proper CLI nor should it be developed as one:
#     no help screens, no name completion of commands, etc
#   - but we otherwise structure it similarly to a CLI:
#   - for now we want to be able to invoke it from the terminal for convenience
#   - watch for not duplicating effort with the actual CLI
#     (edit to above: who needs a CLI with an API like this?)
#   - be prepared to pivot this to a long-running e.g. flask


def _API_for_production():
    import sys as o
    stdout = _prefixer("stdout: ", o.stdout)
    stderr = _prefixer("stderr: ", o.stdout)
    exit(_API(o.stdin, stdout, stderr, o.argv, None))


def _API(sin, sout, serr, argv, efx):  # efx = external functions
    argp = _arg_parser(list(reversed(argv)), serr)
    _, es = argp.parse_one_argument()
    assert(not es)  # assume program name is always first element. discard
    command_name, es = argp.parse_one_argument('command name')
    if es:
        return es
    dct = _command_function_via_name
    if command_name not in dct:
        if '-list' == command_name:
            for key in dct.keys():
                sout.write(f'{key}\n')
            return 0
        serr.write(f'unknown command: "{command_name}"\n')
        return 3

    es = dct[command_name](sin, sout, serr, argp, efx)

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
def update_notecard(sin, sout, serr, argp, efx):
    ncs_path, es = argp.parse_one_argument('notecards path')
    if es:
        return es

    is_dry = False
    if _dry_run_flag == ncs_path:
        is_dry = True
        ncs_path, es = argp.parse_one_argument('notecards path')
        if es:
            return es

    ncid_s, es = argp.parse_one_argument('notecard identifier')
    if es:
        return es
    ncs, mon = _notecards_and_monitor(ncs_path, serr)
    if ncs is None:
        return mon.exitstatus

    moniker = '{create_attribute|update_attribute|delete_attribute}'
    cuds = []
    cud = []

    while True:
        which, es = argp.parse_one_argument(moniker)
        if es:
            return es
        cud.append(which)
        attr, es = argp.parse_one_argument('attribute name')
        if es:
            return es
        cud.append(attr)
        if which in ('update_attribute', 'create_attribute'):
            value, es = argp.parse_one_argument('attribute value')
            if es:
                return es
            value, es = _unescape(value, serr)
            if es:
                return es
            f = _hand_written_attribute_parsers.get(attr)
            if f is not None:
                value, es = f(value, serr)
                if es:
                    return es
            cud.append(value)
        elif 'delete_attribute' != which:
            serr.write(f'expecting {moniker} had "{which}"\n')
            return 5
        cuds.append(tuple(cud))
        cud.clear()
        if argp.is_empty():
            break

    nc = ncs.update_notecard(ncid_s, tuple(cuds), mon.listener, is_dry=is_dry)
    if nc is None:
        return mon.exitstatus

    nc.heading = ''.join(('OHAI FROM PHO API BACKEND! ', nc.heading))  # #todo
    return _write_entity_as_JSON(sout, nc, mon.listener)


@command
def create_notecard(sin, sout, serr, argp, efx):

    is_dry = False

    while True:
        arg, es = argp.parse_one_argument('option or notecards path')
        if es:
            return es
        if not (len(arg) and '-' == arg[0]):
            ncs_path = arg
            break
        if _dry_run_flag == arg:
            is_dry = True
            continue
        serr.write(f"not an option for 'create_notecard': '{arg}'\n")
        return 5

    ncs, mon = _notecards_and_monitor(ncs_path, serr)
    if ncs is None:
        return mon.exitstatus

    dct = {}
    seen = set()

    while True:
        attr, es = argp.parse_one_argument('attribute name')
        if es:
            return es
        value, es = argp.parse_one_argument('attribute value')
        if es:
            return es
        value, es = _unescape(value, serr)
        if es:
            return es
        if attr in seen:
            serr.write(f"multiple attribute values for '{attr}', limit 1\n")
            return 5
        seen.add(attr)
        dct[attr] = value
        if argp.is_empty():
            break

    nc = ncs.create_notecard(dct, mon.listener, is_dry=is_dry)
    if nc is None:
        return mon.exitstatus

    nc.heading = ''.join(('OHAI FROM PHO API BACKEND! ', nc.heading))  # #todo
    return _write_entity_as_JSON(sout, nc, mon.listener)


@command
def delete_notecard(sin, sout, serr, argp, efx):
    ncs_path, es = argp.parse_one_argument('notecards path')
    if es:
        return es

    is_dry = False
    if _dry_run_flag == ncs_path:
        is_dry = True

        ncs_path, es = argp.parse_one_argument('notecards path')
        if es:
            return es

    ncs, mon = _notecards_and_monitor(ncs_path, serr)
    if ncs is None:
        return mon.exitstatus

    ncid_s, es = argp.parse_one_argument('notecard identifier')
    if es:
        return es

    nc = ncs.delete_notecard(ncid_s, mon.listener, is_dry=is_dry)
    if nc is None:
        return mon.exitstatus

    nc.heading = ''.join(('OHAI FROM PHO API BACKEND! ', nc.heading))  # #todo
    return _write_entity_as_JSON(sout, nc, mon.listener)


@command
def retrieve_random_notecard(sin, sout, serr, argp, efx):
    args, es = argp.parse_all_args('notecards path')
    if es:
        return es
    ncs_path, = args
    ncs, mon = _notecards_and_monitor(ncs_path, serr)
    if ncs is None:
        return mon.exitstatus
    listener = mon.listener

    with ncs.open_identifier_traversal(listener) as idens:
        yikes = tuple(idens)

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
    nc = ncs.retrieve_notecard_via_identifier(iden, listener)
    assert(nc)
    return _write_entity_as_JSON(sout, nc, listener)


@command
def retrieve_notecard(sin, sout, serr, argp, efx):
    args, es = argp.parse_all_args('notecard identifier', 'notecards path')
    if es:
        return es
    ncid_s, ncs_path = args
    ncs, mon = _notecards_and_monitor(ncs_path, serr)
    if ncs is None:
        return mon.exitstatus
    nc = ncs.retrieve_notecard(ncid_s, mon.listener)
    if nc is None:
        return mon.exitstatus
    return _write_entity_as_JSON(sout, nc, mon.listener)


def _write_entity_as_JSON(sout, nc, listener):
    dct = nc.to_core_attributes()
    dct['identifier'] = nc.identifier_string
    import json
    indent = 2  # set to None to put it all on one line. 2 for pretty (longer)
    json.dump(dct, sout, indent=indent)
    sout.write("\n")
    return 0


@command
def hello_to_pho(sin, sout, serr, argp, efx):  # a.k.a "ping"

    from pho import HELLO_FROM_PHO
    from time import sleep

    sout.write(HELLO_FROM_PHO)
    sout.write('\n')

    if argp.is_empty():
        serr.write('No arguments\n')
        return 4

    arg, es = argp.parse_one_argument('arg')
    if es:
        return es
    sout.write(f'First argument: {arg}\n')
    count = 1

    while not argp.is_empty():
        count += 1
        arg, _ = argp.parse_one_argument('arg')
        length_of_time_to_sleep = 0.718 if count % 2 else 1.180
        sleep(length_of_time_to_sleep)
        sout.write(f'Argument number {count}: {arg}\n')

    return 0


def _parse_children_value(string, serr):
    import re
    rxs = '[a-zA-Z0-9]+'  # lenient, long hair don't care
    md = re.match(f'^{rxs}(?:,[ ]{rxs})*$', string)
    if md:
        return tuple(string.split(', ')), None
    from pho import repr_
    serr.write(f"expecting format: 'aa, bb, cc'{repr_(string)}\n")
    return None, 5


_hand_written_attribute_parsers = {'children': _parse_children_value}


def _notecards_and_monitor(ncs_path, serr):
    # many of our API actions need to resolve the collection as the first
    # step and also crete a monitor, so there's this weird pairing

    mon = _monitor_via_stderr(serr)
    from pho import notecards_via_path
    ncs = notecards_via_path(ncs_path, mon.listener)
    if ncs is None:
        return None, mon
    return ncs, mon


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
        if is_empty():
            return
        serr.write("unexpected extra argument\n")
        return 2

    def is_empty():
        return 0 == len(bash_argv)

    _1 = parse_all_args  # not ok
    _2 = parse_one_argument
    _4 = is_empty

    class parser:  # class as namespace
        parse_all_args = _1
        parse_one_argument = _2
        is_empty = _4
    return parser


# == BEGIN open [#882.N] it is not us that should be doing unescaping

def _unescape(value, serr):  # we can't find documentation on who's doing this
    if '\\' not in value:
        return value, None
    errcode_hack = []
    _wow = _yikes(value, errcode_hack, serr)
    big_string = ''.join(_wow)
    if len(errcode_hack):
        errcode, = errcode_hack
        return None, errcode
    return big_string, None


def _yikes(big_string, errcode_hack, serr):
    import re
    begin = 0
    itr = re.finditer(r'\\(.?)', big_string)
    for md in itr:
        match_begin, match_end = md.span()
        if begin < match_begin:
            yield big_string[begin:match_begin]
        begin = match_end
        char = md[1]
        if 'n' == char:
            yield "\n"
            continue
        serr.write(f'no support for this escape sequence rignt now: "\\{char}"\n')  # noqa: E501
        errcode_hack.append(441)
        return
    if begin < len(big_string):
        yield big_string[begin:]

# == END


def _monitor_via_stderr(serr):
    from script_lib.magnetics.error_monitor_via_stderr import func
    return func(serr, default_error_exitstatus=33)


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


_dry_run_flag = '-dry-run'


if '__main__' == __name__:
    _API_for_production()
else:
    raise RuntimeError('where')

# #history-A.2: structural overhaul to resemble a CLI superficially
# #history-A.1: begin for electron
# #born.
