import re

_this_var_name = '<template-file>'

_my_doc = f"""experiment in using python templates

the file pointed to by {_this_var_name} should have variables
in it $like_this. set environment variables with names TMPL_LIKE_THIS.
etc.
"""
# #[#874.5] file used to be executable script and may need further changes


class _CLI:

    def __init__(self, *four):
        self.stdin, self.stdout, self.stderr, self.ARGV = four

    def execute(self):
        self.exitstatus = 5  # generic failure, guilty til proven innocent
        self._work()
        return self.exitstatus

    def _work(self):
        if not self.__validate_arguments():
            return

        if not self.__resolve_big_string():
            return

        def my_key_via(template_variable_name):
            return f'TMPL_{template_variable_name.upper()}'

        from os import environ

        from script_lib.magnetics import listener_via_resources as _
        _listener = _.listener_via_stderr(self.stderr)

        lines = _lines_via(
            data_source=environ,
            template_big_string=self._big_string,
            data_source_key_via_template_variable_name=my_key_via,
            listener=_listener)

        if lines is None:
            return

        io = self.stdout
        for line in lines:
            io.write(line)  # assume newline

        self.exitstatus = _success_exitstatus

    def __resolve_big_string(self):
        with open(self._file) as fh:
            self._big_string = fh.read()
        return True

    # --

    def __validate_arguments(self):
        num_args = len(self.ARGV) - 1
        self._num_args = num_args
        if 0 == num_args:
            self.__when_no_arguments()
        elif 1 == num_args:
            if '-' == self.ARGV[1][0]:
                self.__when_request_starts_with_dash()
            else:
                self._file = self.ARGV[1]
                del(self.ARGV)
                return True
        else:
            self.__when_too_many_arguments()

    def __when_request_starts_with_dash(self):
        arg = self.ARGV[1]
        if arg in ('-h', '--help'):
            self.__express_help()
            self.exitstatus = _success_exitstatus
        else:
            o = self._usage_talkinbout
            o(f'this application takes no options (had "{arg}")')

    def __express_help(self):  # experiment
        line = r'([^\n]+)\n'
        blank_line = r'\n'
        the_rest = r'((?:.|\n)+)\n'

        md = re.search(f'^{line}{blank_line}{line}{the_rest}\\Z', _my_doc)

        o = self._express_stderr_line
        o(f'synopsis: {md[1]}')
        o()
        self._express_usage_line()
        o()
        o(f'description: {md[2]}')
        o(md[3])

    def __when_too_many_arguments(self):
        self._usage_talkinbout(f'need one argument had {self._num_args}')

    def __when_no_arguments(self):
        self._usage_talkinbout('no arguments')

    def _usage_talkinbout(self, msg):
        o = self._express_stderr_line
        o(f'argument error: {msg}')
        self._express_usage_line()
        o(f'try "{self._prog_name} -h" for help')

    def _express_usage_line(self):
        o = self._express_stderr_line
        o(f'usage: {self._prog_name} {_this_var_name}')

    @property
    def _prog_name(self):
        return self.ARGV[0]

    def _express_stderr_line(self, line=None):
        if line is None:
            self.stderr.write('\n')
        else:
            self.stderr.write(line + '\n')


def _lines_via(  # #testpoint
        data_source,  # must do `in` and `[]`
        template_big_string,
        data_source_key_via_template_variable_name,
        listener,
        ):

    _names = __template_variable_names_via_big_string(template_big_string)

    dct = __dictionary_via_etc(
            data_source, _names,
            data_source_key_via_template_variable_name, listener)

    if dct is None:
        return

    from string import Template
    _template = Template(template_big_string)
    big_string = _template.substitute(dct)

    return __lines_via_big_string(big_string)


def __lines_via_big_string(big_string):

    # (there has to be a better way that doesn't blitz the memory)
    i = 0
    stop = len(big_string)
    while i != stop:
        newline_index = big_string.index('\n', i)
        next_i = newline_index + 1
        yield big_string[i:next_i]
        i = next_i


def __dictionary_via_etc(
        data_source, names,
        data_source_key_via_template_variable_name, listener):

    dct = {}
    missing = []

    for name in names:
        far_key = data_source_key_via_template_variable_name(name)
        if far_key in data_source:
            dct[name] = data_source[far_key]
        else:
            missing.append(far_key)

    if len(missing):
        def o():
            _ = ', '.join(missing)
            yield f'set these environment variables: ({_})'
        listener('error', 'expression', 'missing_required_doohahs', o)
        return None
    else:
        return dct


def __template_variable_names_via_big_string(big_string):
    return re.findall(r'\$([a-zA-Z_][a-zA-Z0-9_]*)', big_string)


_success_exitstatus = 0


if __name__ == '__main__':
    import sys as o
    _exitstatus = _CLI(o.stdin, o.stdout, o.stderr, o.argv).execute()
    exit(_exitstatus)

# #born.
