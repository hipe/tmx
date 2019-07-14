import re


def RESOLVE_UPSTREAM_EXPERIMENT(cli):
    """
    so:
      - this is [#608.3] an early abstraction
      - this is the first thing to use [#608.6] our new simplified API
    """

    def __main():
        if cli.stdin.isatty():
            __resolve_upstream_when_interactive()
        else:
            __resolve_upstream_when_non_interactive()

    def __resolve_upstream_when_interactive():
        if _an_argument_was_passed():
            if _help_was_requested():
                _express_help()
            elif __more_than_one_argument_was_passed():
                __THEN_complain_about_too_many_arguments()
            else:
                __THEN_use_that_one_arguent()
        else:
            __THEN_complain_about_no_arguments()

    def __resolve_upstream_when_non_interactive():
        if _an_argument_was_passed():
            if _help_was_requested():
                _express_help()
            else:
                __THEN_complain_about_cant_have_both()
        else:
            __THEN_use_stdin_as_upstream()

    def _an_argument_was_passed():
        return 1 < _number_of_arguments()

    def __more_than_one_argument_was_passed():
        return 2 < _number_of_arguments()

    def _help_was_requested():
        import re
        rx = re.compile('^--?h(?:e(?:lp?)?)?$')  # #[#608.4] DRY one day
        a = cli.ARGV
        return next((i for i in range(1, len(a)) if rx.match(a[i])), None)

    def _express_help():

        _ = ' '.join(cli.description_raw_lines_for_resolve_upstream())  # ..

        o = _liner_for(cli.stderr)
        program_name = _program_name()
        o(f'usage: {program_name} {_lone_argument_moniker()}')
        o(f'       some-stream | {program_name}')
        o()
        o(f'description: {_}')

        cli.OK = False

    def __THEN_complain_about_cant_have_both():
        _arg_error("can't have both STDIN and arguments")

    def __THEN_complain_about_no_arguments():
        _complain(f'expecting {_lone_argument_moniker()} or STDIN')

    def __THEN_complain_about_too_many_arguments():
        _arg_error(f'had {_number_of_arguments()} arguments, '
                   'needed one.')

    def _arg_error(msg):
        _complain(f'argument error: {msg}')

    def _complain(msg):
        o = _liner_for(cli.stderr)
        o(msg)
        o(f"see '{_program_name()} -h' for help.")
        cli.OK = False
        cli.exitstatus = 444

    def _program_name():
        return cli.ARGV[0]

    def _liner_for(io):
        def o(s=None):
            write('\n' if s is None else f'{s}\n')
        write = io.write
        return o

    def _number_of_arguments():
        return len(cli.ARGV)  # ..

    def __THEN_use_stdin_as_upstream():
        cli.upstream = cli.stdin

    def __THEN_use_that_one_arguent():
        cli.upstream = open(cli.ARGV[1])

    # --

    def _lone_argument_moniker():
        return cli.lone_argument_moniker_for_resolve_upstream()

    return __main()

    # == END


def CHEAP_ARG_PARSE(cli_function, std_tuple, arg_names=(), help_values={}):

    self = _State()

    def __main():
        if __help_was_requested_in_ANY_argument():
            __express_help()
        elif __parse_arguments_positionally():
            _args = __prepare_args_to_send()
            self.exitstatus = cli_function(*_args)
        return self.exitstatus

    def __prepare_args_to_send():
        listener = __build_common_listener(serr)  # ..
        return (* argv[1:], listener, * std_tuple[0:3])

    def __parse_arguments_positionally():

        if use_num_args == exp_num_args:
            return True
        else:
            ui_puts('had {} needed {} arguments', use_num_args, exp_num_args)
            _express_usage()
            return False

    def __help_was_requested_in_ANY_argument():
        rx = re.compile('^--?h(?:e(:?lp?)?)?$')  # #[#608.4] DRY one day
        _gen = (None for i in range(1, act_num_args) if rx.search(argv[i]))
        help_was_requested = None
        for _ in _gen:
            help_was_requested = True
            break
        return help_was_requested

    def __express_help():  # ..
        io = serr
        _express_usage()
        ui_puts()
        doc_s = cli_function.__doc__
        if doc_s is not None:
            io.write('description: ')  # ..
            if '\n' in doc_s:
                use_doc_s = doc_s
            else:
                use_doc_s = f'{doc_s}\n'
            _ = line_stream_via_doc_string_(
                    doc_string=use_doc_s,
                    help_values=help_values)
            for line in _:
                io.write(line)
        _succeeded()

    def _express_usage():

        if len(arg_names) is 0:
            _args = ''
        else:
            _args = ' ' + ' '.join(arg_names)

        _program_name = argv[0]  # ..
        ui_puts('usage: {}{}', _program_name, _args)

    def ui_puts(*a):
        if len(a) is 0:
            return serr.write('\n')
        else:
            _line_head = a[0].format(*a[1:])
            return serr.write(_line_head + '\n')

    def _succeeded():
        self.exitstatus = 0

    sin, sout, serr, argv = std_tuple

    exp_num_args = len(arg_names)
    act_num_args = len(argv)
    use_num_args = act_num_args - 1
    self.exitstatus = 678

    return __main()


class _State:  # #[#510.3]
    def __init__(self):
        self.exitstatus = None


# -- abstracted at #history-A.1 - scream case because kludge, reach-down

def CACHED_DOCUMENT_VIA_TWO(cached_path, url, noun_phrase, listener):
    # ugly to reach down but that hard coded doo-hah is here & convenient
    if cached_path is None:
        return _cached_doc_via_url(url, listener)
    else:
        return _cached_doc_via_filesystem(cached_path, noun_phrase, listener)


def _cached_doc_via_filesystem(cached_path, noun_phrase, listener):
    from data_pipes.format_adapters.html.magnetics import (
            cached_doc_via_url_via_temporary_directory as cachelib)

    def lineser():
        yield f'(reading {noun_phrase} from filesystem - {cached_path})'
    listener('info', 'expression', 'reading_from_filesystem', lineser)
    return cachelib.Cached_HTTP_Document(cached_path)


def _cached_doc_via_url(url, listener):
    from data_pipes.format_adapters.html.magnetics import (
            cached_doc_via_url_via_temporary_directory as cachelib)
    return cachelib(TEMPORARY_DIR)(url, listener)
# --


def line_stream_via_doc_string_(doc_string, help_values):
    if help_values is None:
        big_string = doc_string
    else:
        big_string = doc_string.format(**help_values)
    _reg = re.compile('^(.*\n)', re.MULTILINE)
    _itr = _reg.finditer(big_string)
    return (__deinident(md) for md in _itr)


def __deinident(md):
    line = md[1]
    md2 = re.search('^[ ]{8}(.*\n)', line)
    return line if md2 is None else md2[1]


def listener_via_error_listener_and_IO(when_error, serr):

    from script_lib.magnetics import listener_via_resources as _
    downstream_listener = _.listener_via_stderr(serr)

    def listener(head_channel, *a):
        if 'error' == head_channel:
            when_error()
        downstream_listener(head_channel, *a)
    return listener


def __build_common_listener(serr):
    """(approaching #open [#508])
    """

    def listener(*these):
        (*chan), emitter = these
        if 'expression' != chan[1]:
            raise('cover me')
        import inspect
        length = len(inspect.signature(emitter).parameters)
        if 0 == length:
            for line in emitter():
                serr_puts(line)
        elif 1 == length:
            # (deprecated but still widespread at writing)
            emitter(serr_puts)
        else:
            cover_me('two args? very oldschool - probably refactor')
    serr_puts = putser_via_IO(serr)
    return listener


class filesystem_functions:  # as namespace
    """with this you "inject" the "filesystem" *as* a dependency into your

    application. the sub-components of your application don't interact with
    the filesystem directly, but rather all of their interactions with it
    happen through the "filesystem" conduit they were passed (this façade).

    for small scripts, using this would probably be obfuscating overkill. but
    for applications of any significant complexity, this has these objectives:

      - use of this tacitly encourages the filesystem to be conceived of and
        modeled around as just another datastore, rather than as a ubiquitous
        service to be taken for granted. this can encourage modularity and
        flexibility in your components, in case (for example) you were to
        rearchitect to target a different datastore other than the local
        filesystem.

      - more specifically, [something about heroku]

      - for some use cases it can be most practical to mock a filesystem
        rather than use a mock filesystem tree. [citation needed]
    """

    open = open  # simply, *our* open is the *real* open

    def open(*x):
        cover_me('not used')  # #todo


def putser_via_IO(io):
    def o(s):
        _line = '%s\n' % s
        _len = io.write(_line)  # :[#607.B]
        assert(isinstance(_len, int))  # sort of like ~[#022]
        return _len
    return o


def cover_me(s):
    raise _exe('cover me: {}'.format(s))


_exe = Exception


class Exception(Exception):
    pass


# -- CONSTANTS

GENERIC_ERROR = 2
SUCCESS = 0
TEMPORARY_DIR = 'z'  # ick/meh


# #history-A.1: as referenced
# #born: abstracted
