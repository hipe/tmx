# == BEGIN [#607.6] hidden CLI

_this_var_name = 'template-file'

_my_doc = """experiment in using python templates

the file pointed to by <{_this_var_name}> should have variables
in it $like_this. set environment variables with names TMPL_LIKE_THIS.
etc.
"""
# #coverage-island


def _CLI(sin, sout, serr, ARGV):
    from script_lib.cheap_arg_parse import cheap_arg_parse
    return cheap_arg_parse(
            CLI_function=_do_CLI,
            stdin=sin, stdout=sout, stderr=serr, argv=ARGV,
            formal_parameters=(
                (_this_var_name, 'ohai i am thing 1'),
                ),
            description_template_valueser=lambda: {'_this_var_name': _this_var_name},)  # noqa: E501


def _do_CLI(error_monitor, sin, sout, serr, file_1_abc_CHAGEME_):

    with open(file_1_abc_CHAGEME_) as fh:
        big_string = fh.read()

    def key_via(template_variable_name):
        return f'TMPL_{template_variable_name.upper()}'

    from os import environ

    lines = _lines_via(
        data_source=environ,
        template_big_string=big_string,
        data_source_key_via_template_variable_name=key_via,
        listener=error_monitor.listener)

    if lines is None:
        return error_monitor.listener

    write = sout.write
    for line in lines:
        write(line)  # assume newline

    return error_monitor.listener


_do_CLI.__doc__ = _my_doc


# == END


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
    import re
    return re.findall(r'\$([a-zA-Z_][a-zA-Z0-9_]*)', big_string)


if __name__ == '__main__':
    import sys as o
    exit(_CLI(o.stdin, o.stdout, o.stderr, o.argv))

# #born.
