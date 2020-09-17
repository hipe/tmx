#!/usr/bin/env python3 -W error::Warning::0

"""just a list (stream, actually) of each directory containing each

theme in the collection, taking into account the deny list (OR NOT)..
"""
# This producer script is one of several covered by (Case4975NC).

import re


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
    if True:
        def visit(dir_path):
            sout.write(f'{dir_path}\n')

        _ = open_theme_directory_stream_via_themes_dir(themes_dir, monitor.listener)  # noqa: E501
        with _ as dirs:
            for dir_path in dirs:
                visit(dir_path)

        return monitor.exitstatus

    # (at #history-A.2 got rid of retrofitting for old way [#608.5]


_do_CLI.__doc__ = _my_desc


class open_theme_directory_stream_via_themes_dir:  # just glue

    def __init__(self, *_2):
        self._themes_dir, self._listener = _2

    def __enter__(self):
        self._exit_me = None
        from script.producer_scripts import (
                script_180920_hugo_relevant_themes_collection_metadata_via_themes_dir as _)  # noqa: E501
        md = _.relevant_themes_collection_metadata_via_themes_dir(self._themes_dir, self._listener)  # noqa: E501
        if md is None:
            return
        other = _open_theme_directory_stream_via_these(
                themes_dir=self._themes_dir,
                find_command=md.find_command,
                bash_interpolation_expression=md.bash_interpolation_expression,
                listener=self._listener)
        result = other.__enter__()
        self._exit_me = other
        return result

    def __exit__(self, *_):
        other = self._exit_me
        del(self._exit_me)
        if other is None:
            return False
        else:
            return other.__exit__(*_)


class _open_theme_directory_stream_via_these:  # #testpoint

    def __init__(
            self,
            themes_dir,
            find_command,
            bash_interpolation_expression,
            listener):

        self._themes_dir = themes_dir
        self._find_command = find_command
        self._bash_interpolation_expression = bash_interpolation_expression
        self._listener = listener

    def __enter__(self):

        cmd = self.__build_find_command()
        assert(isinstance(cmd, tuple))  # something re #here1. ~#[#022]

        # == BEGIN hotfix for issue :[#410.5]:
        """
        the .github entry is a doozer:
          - this entry occurs (last we checked) if you check out the whole
            (~10 minute) checkout of every theme.

          - our list of themes comes from a find command.

          - the find command is scraped directly from a hugo thing.

          - the find command as coded by the vendor is coded to skip
            `.git` but not any other names.

        the effect of all this is that if a `.github` entry is in the list,
        it gets through and appears as though it is a theme. below we veryify
        that it still is that way, and then "fix" it for our needs.
        """

        a = list(cmd)
        idx = -4
        None if '*.git' == a[idx] else cover_me('vendor code changed')
        a[idx] = '*.git*'
        cmd = a
        # == END

        import subprocess
        cm = subprocess.Popen(
                args=cmd,
                bufsize=-1,  # only relevant for pipes, -1 means use default
                executable=None,  # specifies a replacement program (ignore)
                stdin=subprocess.DEVNULL,
                stdout=subprocess.PIPE,
                stderr=None,  # not what you want, meh
                preexec_fn=None,
                close_fds=True,
                shell=False,  # #here1 T if cmd is (EEW) string, F if tup
                cwd=None,
                env=None,
                universal_newlines=None,  # default is False. none b/c text
                startupinfo=None,
                creationflags=0,
                restore_signals=True,
                start_new_session=False,
                pass_fds=(),
                encoding=None,
                errors=None,
                text=True)  # default is None. setting to True means no binary

        self._terminate_me = cm

        with cm as proc:
            sout = proc.stdout

            def chop(line):
                return line[0:-1]  # chop not strip just to be gigo

            # at #history-A.1 removed thing that removed '.github' from listing
            # (at #history-A.3 we re-addressed the above better for [#410.5])

            for line in sout:
                yield chop(line)

            es = proc.returncode
            if es is not None:
                cover_me(f'wee we got an exitstatus: {es!r}')

    def __build_find_command(self):
        return _crazy_interpolate(
                self._find_command,
                self._bash_interpolation_expression,
                self._themes_dir)

    def __exit__(self, *_):
        o = self._terminate_me
        del(self._terminate_me)
        o.terminate()  # yikes
        return False


def _crazy_interpolate(tmpl, var, value):  # meh

    md = re.search(r'[^-a-zA-Z_0-9/]', value)
    if md is not None:
        _ = md[0]
        cover_me(f'path contains chars ({_}!r) we are afraid of: {value!r}')

    # NOTE - it is ESSENTIAL that we get this right. it's a TERRIFYING
    # security risk if somehow we manage to etc.
    # we prefer .. etc

    i = tmpl.index(var)  # ValueError when substring not found, which is nice
    head = tmpl[0:i]
    tail = tmpl[(i + len(var)):]

    # OLD WAY:
    # return ''.join((head, value, tail))
    # NEW WAY
    _tail_pieces = list(__do_the_crazy_thing(tail))
    return (head.strip(), value, * _tail_pieces)


def __do_the_crazy_thing(command_part):
    # (in ruby it's called Shellwords - no time to care now)

    rx = re.compile('[ ]([^ ]+)')

    cursor = 0
    length = len(command_part)

    while cursor != length:

        md = rx.match(command_part, cursor)
        s = md[1]
        if '"' == s[0]:
            assert('"' == s[-1])
            yield s[1:-1]
        else:
            yield s
        cursor = md.end()


def cover_me(s):
    raise Exception(f'cover me - {s}')


_exitstatus_for_failure = 345


if __name__ == '__main__':
    import sys as o
    exit(_CLI(o.stdin, o.stdout, o.stderr, o.argv))

# #history-A.3 can be temporary. as referenced.
# #history-A.2 can be temporary. as referenced. salt.
# #history-A.1 (as referenced)
# #born.
