"""this is the next level up from "fixed argument parser"..

you want to use this magnetic directly if you want to build your argument
parser from modality agnostic commands, but otherwise manage your own
parsing.
"""

from modality_agnostic.memoization import (
        lazy,
        )

from script_lib import (
        cover_me,
        )

# #todo - you could eliminate (at writing) all `lazy` here (look)


class _Me:
    """a collection of commands is passed over the transation boundary

    as a stream (actually iterator), streams being the lingua franca for
    collections passed over transactional boundaries. however it's more
    convenient to have this collection be in a dictionary after the work
    is done of building the argument parser..
    """

    def __init__(self, stderr, prog, description, command_stream):

        ap_lib = _ap_lib()

        ap = ap_lib.begin_native_argument_parser_to_fix(
            prog=prog,
            description=description,
            )
        _hack_argument_parser(ap, stderr)

        self.command_dictionary = _populate_argument_parser_while_indexing(
                stderr, ap, command_stream)
        self.argument_parser = ap

    @property
    def this_one_name__(self):
        return _THIS_NAME


def _populate_argument_parser_while_indexing(stderr, ap, command_stream):

    d = {}
    subparsers = ap.add_subparsers(dest=_THIS_NAME)
    for cmd in command_stream:
        k = cmd.name
        if k in d:
            _msg = "name collision - multiple commands named '%s'"
            cover_me(_msg % k)
        d[k] = cmd
        __add_command_to_argument_parser(subparsers, cmd, stderr)
    return d


class __add_command_to_argument_parser:
    """the bulk of the work of our modality-specific adapatation of parameters

    """

    def __init__(self, subparsers, cmd, stderr):

        f = cmd.description
        if f is not None:
            desc_s = _string_via_description_function(f)
        else:
            desc_s = "«desc for subparser (place 2) '%s'»\nline 2" % cmd.name

        self._count_of_positional_args_added = 0

        ap = subparsers.add_parser(
            _slug_via_name(cmd.name),
            help='«help for command»',
            description=desc_s,
            add_help=False,
        )
        _hack_argument_parser(ap, stderr)
        self._parser = ap
        d = cmd.formal_parameter_dictionary
        for name in d:
            self.__add_parameter(d[name], name)

    def __add_parameter(self, param, name):
        """[#502] discusses different ways to conceive of parameters ..

        in terms of ther argument arity. here we could either follow the
        "lexicon" (`is_required`, `is_flag`, `is_list`) or the numbers. we
        follow the numbers for no good reason..
        """

        r = param.argument_arity_range
        min = r.start
        max = r.stop
        if min is 0:
            if max is 0:
                self.__add_flag(param, name)
            elif max is 1:
                self.__add_optional_field(param, name)
            else:
                None if max is None else sanity()
                self.__add_optional_list(param, name)
        else:
            None if min is 1 else sanity()
            sanity() if min is not 1 else None
            if max is 1:
                self.__add_required_field(param, name)
            else:
                None if max is None else sanity()
                self.__add_required_list(param, name)

    def __add_required_field(self, param, name):
        """purely from an interpretive standpoint, we could express any number..

        of required fields as positional arguments when as a CLI command.
        HOWEVER from a usability standpoint, as an #aesthetic-heuristic
        we'll say experimentally that THREE is the max number of positional
        arguments a command should have.
        """

        if 3 > self._count_of_positional_args_added:
            self._count_of_positional_args_added += 1
            self.__do_add_required_field(param, name)
        else:
            cover_me('many required fields')

    def __add_required_list(self, param, name):  # category 5
        self._parser.add_argument(
            _slug_via_name(name),
            ** self._common_kwargs(param, name),
            nargs='+',
            # action = 'append', ??
        )

    def __do_add_required_field(self, param, name):  # category 4
        self._parser.add_argument(
            _slug_via_name(name),
            ** self._common_kwargs(param, name),
        )

    def __add_optional_list(self, param, name):  # category 3
        self._parser.add_argument(
            _slug_via_name(name),
            ** self._common_kwargs(param, name),
            nargs='*',
            # action = 'append', ??
        )

    def __add_optional_field(self, param, name):  # category 2
        self._parser.add_argument(
            (_DASH_DASH + _slug_via_name(name)),
            ** self._common_kwargs(param, name),
            metavar=_infer_metavar_via_name(name),
        )

    def __add_flag(self, param, name):  # category 1
        self._parser.add_argument(
            (_DASH_DASH + _slug_via_name(name)),
            ** self._common_kwargs(param, name),
            action='store_true',  # this is what makes it a flag
        )

    def _common_kwargs(self, param, name):

        s = param.generic_universal_type
        if s is not None:
            implement_me()

        d = {}
        f = param.description
        if f is not None:
            d['help'] = _string_via_description_function(f)
        else:
            d['help'] = ("«the '%s' parameter»" % name)  # ..
        return d


#
# argument parser (build with functions not methods, expermentally)
#

def _string_via_description_function(f):

    from script_lib.magnetics import STYLER_
    s_a = []

    def write_f(s):
        s_a.append(s + _NEWLINE)
    f(write_f, STYLER_)
    return _EMPTY_STRING.join(s_a)


def _hack_argument_parser(ap, stderr):

    ap_lib = _ap_lib()
    ap_lib.fix_argument_parser(ap, stderr)


@lazy
def _infer_metavar_via_name():
    """given an optional field named eg. "--important-file", name its

    argument moniker 'FILE' rather than'IMPORTANT_FILE'
    """

    import re
    regex = re.compile('[^_]+$')

    def f(name):
        return regex.search(name)[0].upper()
    return f


def _slug_via_name(name):
    return name.replace('_', '-')  # UNDERSCORE, DASH


def _ap_lib():
    import script_lib.magnetics.fixed_argument_parser_via_argument_parser as x
    return x


@lazy
def _():
    # #wish [#008.E] gettext uber alles
    from gettext import gettext as g

    def f(s):
        return g(s)
    return f


def implement_me():
    raise _exe('implement me')


def sanity():
    raise _exe('sanity')


_exe = Exception

_DASH_DASH = '--'
_EMPTY_STRING = ''
_NEWLINE = '\n'
_THIS_NAME = 'chosen_sub_command'


# == BEGIN #callable-module-hack

class _MeAsCallable:
    def __call__(self, *a, **kwargs):
        return _Me(*a, **kwargs)

import sys  # noqa E402
sys.modules[__name__] = _MeAsCallable()

# == END

# #history-A.2: MASSIVE exodus
# #history-A.1: as referenced (can be temporary)
# #born.
