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
# #[#410.1.2] this is a producer script (sort of)


import re

_my_desc = __doc__


def normalize_sys_path_():  # #cp from one level up
    import os.path as os_path
    from sys import path as sys_path
    dn = os_path.dirname
    here = os_path.abspath(dn(__file__))
    if here != sys_path[0]:
        sanity('sanity - in the future, default sys.path may change')
    sys_path[0] = dn(dn(dn(here)))


def sanity(s):
    raise Exception(f'sanity - {s}')


def _my_params(o, param):

    o['themes_dir'] = param(  # ..
            description='«help for themes_dir»',
            )


class _CLI:

    def __init__(self, *_):
        self.stdin, self.stdout, self.stderr, self.ARGV = _
        self._exitstatus = 1
        self._OK = True

    def execute(self):
        import script.stream as cl  # cl = "CLI lib"
        cl.must_be_interactive_(self)
        cl.parse_args_(self, '_namespace', _my_params, _my_desc)
        self.OK and setattr(self, '_listener', cl.listener_for_(self))
        self.OK and self._work()
        return self._exitstatus

    def _work(self):
        self._exitstatus = 0
        _ = getattr(self._namespace, 'themes-dir')
        cm = relevant_themes_collection_metadata_via_themes_dir(
                _, self._listener)
        # ..
        dct = cm.to_dictionary()
        if False:  # worked but
            import pprint
            pprint.pprint(dct, self.stderr)
        else:
            import json
            _big_s = json.dumps(
                    dct,
                    indent=4,
                    sort_keys=False,  # currently aesthetically ordered.
                    )
            self.stderr.write(_big_s)
            self.stderr.write('\n')


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


class _MadParseBashScript:  # #pattern #[#418.Z.4] "mad parse"
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

if __name__ == '__main__':
    normalize_sys_path_()
    import sys as o
    _exitstatus = _CLI(o.stdin, o.stdout, o.stderr, o.argv).execute()
    exit(_exitstatus)

# #born.
