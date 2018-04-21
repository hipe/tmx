"""EXPERIMENT

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
        _big_string = cli_function.__doc__.format(**help_values)
        _reg = re.compile('^(.*\n)', re.MULTILINE)
        _itr = _reg.finditer(_big_string)
        itr = (__deinident(md) for md in _itr)
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
        if len(a) is not 0:
            serr.write(a[0].format(*a[1:]))
        serr.write('\n')

    def _succeeded():
        nonlocal exitstatus
        exitstatus = 0

    sin, sout, serr, argv = std_tuple

    exp_num_args = len(arg_names)
    act_num_args = len(argv)
    use_num_args = act_num_args - 1
    exitstatus = 678

    return __main()


def __deinident(md):
    line = md[1]
    md2 = re.search('^[ ]{8}(.*\n)', line)
    return line if md2 is None else md2[1]


def __build_common_listener(serr):
    def listener(*these):
        chan = these[0:-1]
        if 'expression' == chan[1]:
            these[-1](serr_puts)
        else:
            raise('cover me')

    serr_puts = putser_via_IO(serr)

    return listener


def leveler_via_listener(level_s, listener):
    def o(msg, *args):
        log(level_s, msg, *args)
    log = logger_via_listener(listener)
    return o


def logger_via_listener(listener):
    def log(category, msg, *args):
        def write_this(o):
            o(msg.format(*args))
        listener(category, 'expression', write_this)
    return log


def putser_via_IO(io):
    def o(s):
        d = io.write(s)
        d += io.write('\n')
        return d
    return o


# #born: abstracted
