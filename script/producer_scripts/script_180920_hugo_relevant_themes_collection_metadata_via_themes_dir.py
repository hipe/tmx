#!/usr/bin/env python3 -W error::Warning::0

"""hackily parse the bash script that hugo uses to generate the site.

the comprehensive list of (semi-official, whatever) hugo themes is in a
purpose-built git repository (consisting mostly of submodules) maintained
by hugo.

it's unfortunate but not surprising that the authoritative list of active
themes is not simply a directory listing of the root of this repository
(i.e its submodules).

in fact there is (at writing) a bash script in the distribution that is used
to generate the site that showcases the various themes. this script is solely
responsible for producing the set of names we are after.

(at #born we committed such a file for use as a test fixture)

not only does it do things things like avoid development assets in this
distribution (like the script itself), but also it contains a couple of
hard-coded lists at least one of which we need to know.

there are alternatives to what we do here..

"""
# This producer script is one of several covered by (Case100SA).


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


def _do_CLI(monitor, stdin, stdout, stderr, themes_dir):

    cm = relevant_themes_collection_metadata_via_themes_dir(
            themes_dir, monitor.listener)
    # ..
    dct = cm.to_dictionary()
    if False:  # worked but
        import pprint
        pprint.pprint(dct, stderr)
        return _exitstatus_for_success

    import json
    _big_s = json.dumps(
            dct,
            indent=4,
            sort_keys=False,  # currently aesthetically ordered.
            )
    stderr.write(_big_s)
    stderr.write('\n')
    return monitor.exitstatus


_do_CLI.__doc__ = _my_desc


def relevant_themes_collection_metadata_via_themes_dir(themes_dir, listener):

    from os import path as os_path
    _path = os_path.join(themes_dir, '_script', 'generateThemeSite.sh')
    parse = _MadParseBashScript()
    with open(_path) as lines:
        for line in lines:
            yes = parse.receive_line(line)
            if not yes:
                break

    return parse.finish(themes_dir)


class _MadParseBashScript:  # the [#608.4] "mad parse" pattern
    """like grep but ..
    """

    def __init__(self):
        self._can_finish = False
        self._state = 'receive_line_while_looking_for_DENY_LIST_LINE'

    def receive_line(self, line):
        return getattr(self, self._state)(line)

    def receive_line_while_looking_for_DENY_LIST_LINE(self, line):
        md = _deny_list_line_rx.match(line)
        if md is not None:
            self._deny_list_parenthesized_list = md[1]
            self._state = 'receive_line_while_looking_for_NO_DEMO_LINE'
        return True

    def receive_line_while_looking_for_NO_DEMO_LINE(self, line):
        md = _no_demo_list_line_rx.match(line)
        if md is not None:
            self._no_demo_list_parenthesized_list = md[1]
            self._state = 'receive_line_while_looking_for_FIND_LINE'
        return True

    def receive_line_while_looking_for_FIND_LINE(self, line):
        md = _find_line_rx.match(line)
        if md is None:
            return True
        else:
            self._find_command = md[1]
            self._can_finish = True
            return False

    def finish(self, themes_dir):
        if not self._can_finish:
            cover_me("cannot finish - didn't reach end")

        # (we don't have a listener but we could)
        _1 = _tuple_via(self._deny_list_parenthesized_list)
        _2 = _tuple_via(self._no_demo_list_parenthesized_list)
        _3 = _normalize_find_command(self._find_command)

        return _ThemesCollectionMetadata(_1, _2, _3)


_deny_list_line_rx = re.compile(r'^blacklist=([^\n]+)')
_no_demo_list_line_rx = re.compile(r'^noDemo=([^\n]+)')
_find_line_rx = re.compile(r'^for x in `(find [^`]+)')


class _ThemesCollectionMetadata:

    def __init__(
            self,
            deny_tuple,
            no_demo_tuple,
            normal_find_command,
            ):
        self.deny_tuple = deny_tuple
        self.no_demo_tuple = no_demo_tuple
        self.find_command = normal_find_command

    def to_dictionary(self):
        o = {}
        o['deny_list'] = self.deny_tuple
        o['no_demo_list'] = self.no_demo_tuple
        o['find_command'] = self.find_command
        return o

    @property
    def bash_interpolation_expression(self):
        return _bash_interpolation_expression


def _tuple_via(parenthesized_group):
    _inside = re.match(r"""^\(['"](.+)['"]\)$""", parenthesized_group)[1]
    _s_a = re.split(r"""['"], ['"]""", _inside)
    return tuple(_s_a)


def _normalize_find_command(cmd):
    find_bash = re.match(r'(.+) \| xargs -n1 basename$', cmd)[1]
    _ = _bash_interpolation_expression
    if _ not in find_bash:
        cover_me(f'{_} not in find command - {find_bash}')
    return find_bash


def cover_me(s):
    raise Exception(f'cover me - {s}')


_bash_interpolation_expression = '${themesDir}'
_exitstatus_for_failure = 456
_exitstatus_for_success = 0


if __name__ == '__main__':
    import sys as o
    exit(_CLI(o.stdin, o.stdout, o.stderr, o.argv))

# #born.
