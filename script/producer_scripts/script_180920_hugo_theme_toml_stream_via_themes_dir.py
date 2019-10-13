#!/usr/bin/env python3 -W error::Warning::0

"""
stream of a pretty dump of every dictionary from every toml fellow.

currently this is for inspection (development & debugging) only.

arrangements could be made to make this more machine readable but currently
it is not very much so for practical purposes (with each JSON-like record
occupying possibly more than one line).
"""
# This producer script is one of several covered by (Case100SA).

from os import path as os_path


_my_desc = __doc__


def _CLI(stdin, stdout, stderr, argv):
    from script_lib.cheap_arg_parse import require_interactive, cheap_arg_parse

    if not require_interactive(stderr, stdin, argv):
        return _exitstatus_for_failure

    return cheap_arg_parse(
        CLI_function=_do_CLI,
        stdin=stdin, stdout=stdout, stderr=stderr, argv=argv,
        formal_parameters=(
            ('themes-dir', 'ohai «help for themes_dir»'),
            ),
        description_template_valueser=lambda: {})


def _do_CLI(monitor, sin, sout, serr, themes_dir):

        def visit(path, dct):
            sout.write(path)
            write_newline()
            pp(dct)

        def write_newline():
            sout.write('\n')

        import pprint
        pp = pprint.PrettyPrinter(indent=2, stream=sout).pprint
        except_first_time = _ExceptFirstTime(write_newline)
        _ = theme_toml_stream_via_themes_dir(themes_dir, monitor.listener)
        for path, dct in _:
            except_first_time()
            visit(path, dct)

        return monitor.exitstatus


def theme_toml_stream_via_themes_dir(themes_dir, listener):  # glue

    dictionary_via_toml_via_path = _make_toml_parser(listener)

    from script.producer_scripts import (
        script_180920_hugo_theme_directory_stream_via_themes_dir as _)

    _ = _.open_theme_directory_stream_via_themes_dir(themes_dir, listener)
    with _ as paths:
        for path in paths:
            dct = dictionary_via_toml_via_path(path)
            if dct is not None:
                yield (path, dct)


def _make_toml_parser(listener):  # #testpoint
    import toml  # try to make this be the only place.
    # (toml dependency added at #born.)

    def dictionary_via_toml_via_path(theme_path):
        toml_path = os_path.join(theme_path, 'theme.toml')
        dct, e = parse_normally(toml_path)
        if dct is None and e is not None:
            dct = parse_try_again(e, toml_path)
        return dct

    def parse_normally(toml_path):
        dct = None
        e = None
        try:
            dct = toml.load(toml_path)
        except FileNotFoundError as e_:
            __say_not_found(listener, e_, toml_path)
        except ValueError as e_:
            e = e_
        return dct, e

    def parse_try_again(e, toml_path):
        if 'could not convert string to float' not in str(e):
            cover_me('what is the problem here')
        with open(toml_path) as fh:
            big_s = fh.read()

        import re
        use_big_s = re.sub(r'\b(min_version = )(\d\S*)', lambda md: f'{md[1]}"{md[2]}"', big_s)  # noqa: E501
        return toml.loads(use_big_s)

    return dictionary_via_toml_via_path


def __say_not_found(listener, e, toml_path):
    def f():
        yield f'skipping toml file not found: {str(e)}'
    listener('info', 'expression', 'toml_file_not_found', f)


class _ExceptFirstTime:
    def __init__(self, f):
        self._f = f
        self._yes = False

    def __call__(self):
        if self._yes:
            self._f()
        else:
            self._yes = True


def cover_me(s):
    raise Exception(f'cover me - {s}')


def woot(*_):
    raise Exception('woot')


_exitstatus_for_failure = 345


if __name__ == '__main__':
    import sys as o
    exit(_CLI(o.stdin, o.stdout, o.stderr, o.argv))

# #born.
