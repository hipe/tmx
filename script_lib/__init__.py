"""EXPERIMENT

(stowaway:)
[#608.2]: external tracking
[#607.B]: as referenced
[#604]: wish for strong type
[#603]: [the help screen parser]
:[#602]: #open track that one issue with argparse (should patch)
"""

import re


def CHEAP_ARG_PARSE(cli_function, std_tuple, arg_names=(), help_values={}):

    def __main():
        if __help_was_requested_in_ANY_argument():
            __express_help()
        elif __parse_arguments_positionally():
            _args = __prepare_args_to_send()
            nonlocal exitstatus
            exitstatus = cli_function(*_args)
        return exitstatus

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
        rx = re.compile('^--?h(?:e(:?lp?)?)?$')
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
        io.write('description: ')  # ..
        itr = line_stream_via_doc_string_(
                doc_string=cli_function.__doc__,
                help_values=help_values)
        io.write(next(itr))
        for line in itr:
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
        nonlocal exitstatus
        exitstatus = 0

    sin, sout, serr, argv = std_tuple

    exp_num_args = len(arg_names)
    act_num_args = len(argv)
    use_num_args = act_num_args - 1
    exitstatus = 678

    return __main()


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
        None if int == type(_len) else sanity('type assertion failed')  # #track [#604]  # noqa: E501
        return _len
    return o


def cover_me(s):
    raise _exe('cover me: {}'.format(s))


def sanity(s=None):
    _msg = 'sanity' if s is None else 'sanity: %s' % s
    raise _exe(_msg)


_exe = Exception


class Exception(Exception):
    pass


# -- CONSTANTS

GENERIC_ERROR = 2
SUCCESS = 0
TEMPORARY_DIR = 'z'  # ick/meh


# #born: abstracted
