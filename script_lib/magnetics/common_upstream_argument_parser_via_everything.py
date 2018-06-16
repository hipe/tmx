"""
broadly the idea is to satisfy the common pattern of this CLI interface.

at first swing it's coarse and not configurable. later we can break it
out into a tower of abstracted segments as needed.

three-laws compliant, but all coverage is from [#414.2] (:[#608.2]).
"""


class common_upstream_argument_parser_via_everything:

    def __init__(
            self,
            cli_function,
            std_tuple,
            argument_moniker,
    ):
        self._stdin, self._stdout, self._stderr, self._ARGV = std_tuple
        self._arg_moniker = argument_moniker
        self._CLI_function = cli_function

    def execute(self):
        self._OK = True
        self._OK and self.__resolve_main_thing()
        self._OK and self.__call_user_thing()
        return self._exitstatus

    def __call_user_thing(self):
        _exitstatus = self._CLI_function(
                self._NORMALIZED_ARGUMENT,
                self._program_name(),
                self._stdin,
                self._stdout,
                self._stderr,
                )
        self._exitstatus = _exitstatus

    def __resolve_main_thing(self):
        if self._something_in_ARGV():
            if self._something_in_STDIN():
                self.__when_both()
            else:
                self.__when_ARGV()
        elif self._something_in_STDIN():
            self.__when_stdin()
        else:
            self.__when_neither()

    def __when_ARGV(self):
        import re
        rx = re.compile(r'^--?h(?:e(?:lp?)?)?$')
        argv = self._ARGV
        length = len(argv)
        yes = False
        for i in range(1, length):
            md = rx.search(argv[i])
            if md is not None:
                yes = True
                break
        if yes:
            self.__when_help()
        elif 2 == length:
            self.__when_argv_argument()
        else:
            self.__when_too_many()

    def __when_stdin(self):  # #coverpoint9.1.1
        self._NORMALIZED_ARGUMENT = _STDIN_As_Argument(self._stdin)

    def __when_argv_argument(self):  # #coverpoint9.1.2
        self._NORMALIZED_ARGUMENT = _FilesystemPathAsArgument(self._ARGV[-1])

    def __when_help(self):
        # #coverpoint9.1.4 - one arg, help

        from script_lib import line_stream_via_doc_string_ as line_stream_via

        def f():
            pn = self._program_name()
            yield 'usage: some_jsonesque_thing | {}'.format(pn)
            yield '       {} {}'.format(pn, self._arg_moniker)
            yield '       {} --help'.format(pn)

            big_s = self._CLI_function.__doc__
            if True:
                itr = line_stream_via(big_s, {})
                itr = (s[:-1] for s in itr)  # meh
                yield ''
                yield 'description: %s' % next(itr)
                for line in itr:
                    yield line

        self._emit_these(f, self._stderr)  # (or stdout)
        self._will_exit_with(0)

    def __when_too_many(self):  # #coverpoint9.3 - too many
        def f():
            yield 'too many args (had {} need 1)'.format(self._num_args())
            yield self._invite_line()
        self._unable_because(f)

    def __when_both(self):  # #coverpoint9.2 - both
        def f():
            yield "can't have both STDIN and argument(s)"
            yield self._invite_line()
        self._unable_because(f)

    def __when_neither(self):  # #coverpoint9.0 - neither
        def f():
            yield 'provide STDIN or {}'.format(self._arg_moniker)
            yield self._invite_line()
        self._unable_because(f)

    def _something_in_ARGV(self):
        return 0 < self._num_args()

    def _num_args(self):
        return len(self._ARGV) - 1

    def _something_in_STDIN(self):
        return not self._stdin.isatty()

    def _invite_line(self):
        return "'{} -h' for help".format(self._program_name())

    def _program_name(self):
        return self._ARGV[0]

    def _unable_because(self, f):
        self._emit_these(f, self._stderr)
        self._will_exit_with(9)

    def _will_exit_with(self, es):
        self._exitstatus = es
        self._OK = False

    def _emit_these(self, f, io):
        for line in f():
            io.write(line + '\n')


class _STDIN_As_Argument:
    def __init__(self, stdin):
        self.stdin = stdin

    @property
    def argument_type(self):
        return 'stdin_as_argument'


class _FilesystemPathAsArgument:
    def __init__(self, path):
        self.path = path

    @property
    def argument_type(self):
        return 'path_as_argument'


import sys  # noqa: E402
sys.modules[__name__] = common_upstream_argument_parser_via_everything

# #abstracted, vaguely.
