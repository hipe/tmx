"""this is the lowest-level magnetic exposed.

this is for you if you want to create and run your own argument parser
directly, and only want the barest minimum of hacks we do to the native
argument parser.

the central conceit of this module is that the native argument parser is
"broken" in a few key ways and needs to be "fixed"...
"""

import script_lib as sl  # (our parent module, 2 levels up)


def begin_native_argument_parser_to_fix__(prog, **platform_kwargs):
    """just a tiny wrapper to keep a leash on how and where we build it"""

    import argparse
    return argparse.ArgumentParser(
            prog=prog,
            add_help=False,
            **platform_kwargs
            )


def fix_argument_parser__(ap, stderr):

    __fix_help(ap, stderr)
    __fix_error_function(ap, stderr)


#
# "fix" help
#

def __fix_help(ap, stderr):
    """"fix" how help is displayed

    the help they add is not helpful.
    calling `exit` is really bad style for us
    """

    def f(**three_kwargs):
        return __MyHelpAction(stderr, ** three_kwargs)

    ap.register('action', 'my help', f)  # register before next

    ap.add_argument(
        '-h', '--help',
        action='my help',
        help=_('show therse help message and exit'),
        )


class __MyHelpAction:
    """we've got to make one that looks like the native one"""

    def __init__(
            self,
            stderr,
            option_strings,
            dest,
            help,
            ):

        self.choices = None
        self.default = None
        self.dest = dest
        self.help = help
        self.nargs = 0
        self.metavar = None
        self._stderr = stderr
        self.option_strings = option_strings
        self.required = False
        self.type = None

    def __call__(self, parser, namespace, values, option_string):
        parser.print_help(self._stderr)
        raise _MyInterruption(sl.SUCCESS, None)


#
# "fix" the error function
#

def __fix_error_function(ap, stderr):
    """"fix" error function

    the *recently rewritten* stdlib option parsing library is not testing-
    friendly, nor is it sufficiently flexible for some novel uses.

      - it writes to system stderr and exits, which might be rather violent
        depending on what you're trying to do.
    """

    # here, rather than subclass it, we experiment with this:

    def f(message):
        ap.print_usage(stderr)
        args = {'prog': ap.prog, 'message': message}
        msg = _('%(prog)s: error: %(message)s\n') % args  # NEWLINE
        raise _MyInterruption(sl.GENERIC_ERROR, msg)
    ap.error = f


#
# support
#

class Interruption(Exception):
    """we are forced to throw exception to interrupt control flow there :("""

    # (#[#020.2] this is seen as a painpoint of argparse)

    def __init__(self, exitstatus, message):
        self.exitstatus = exitstatus
        self.message = message


_MyInterruption = Interruption


def _(s):
    from gettext import gettext as g
    return g(s)


# #abstracted.
