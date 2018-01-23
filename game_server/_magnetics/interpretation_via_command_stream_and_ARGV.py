"""an exemplary instance of our modality-agnostic 'injection' pattern:

wrap the modality-specific unsanitized request data (the ARGV) in a subject
(the "interpretation maker") and "inject" it into the microservice.

then, as the "invocation" is being processed, the subject (once injected)
receives the command collection from the service..

from these two elements (the ARGV and the collection of commands), the
subject's charge is to parse the one against the other and produce an
"interpretation" object, OR them agree and to either parse the request
into a cha cha TODO that it must produce 


because the order feels somewhat counterintuitive (ARGV *then* commands)
and also is somewhat arbitrary, we have given the module a name that
flattens this order out of it (in part in case we want to change it, the
rename won't be drastic.)
"""

def interpretation_builder_via_modality_resources(
      ARGV,
      stdout,
      stderr,
    ):
    """currently the only entrypoint into this module (file)

    xx
    """
    return _InterpretationBuilder(ARGV, stdout, stderr)


class _InterpretationBuilder:

    def __init__(self,
      ARGV,
      stdout,
      stderr,
    ):
        self.ARGV = ARGV
        self.stdout = stdout
        self.stderr = stderr

    def interpretation_via_command_stream(self, command_stream):
        """currently the only other public method in this module (file)"""

        return _BuildInterpretation(
          command_stream=command_stream,
          protected_resources=self,
        ).execute()


class _BuildInterpretation:

    def __init__(self,
      command_stream,
      protected_resources,
    ):
        self.command_stream = command_stream
        self.protected_resources = protected_resources

    def execute(self):

        self.__mutate_ARGV()
        self.__init_top_parser()
        self.__HACK_THE_ARG_PARSER()

        rsc = self.protected_resources

        ap = self._top_parser ; del self._top_parser

        e = None
        try:
            x = ap.parse_args(rsc.ARGV)
        except _MyInterruption as e_:
            e = e_

        if e:
            rsx = self.protected_resources
            rsx.stderr.write(e.message)
            return _FailureResult(e.exitstatus)
        else:
            return write_me()


    def __init_top_parser(self):

        import argparse

        pn = self.__program_name ; del self.__program_name
        top_parser = argparse.ArgumentParser(
          prog=pn,
          description='choo cha',
        )

        cs = self.command_stream ; del self.command_stream

        _RecurseIntoCommandBranch(
          command_stream = cs,
          parser = top_parser,
        ).execute()

        self._top_parser = top_parser


    def __HACK_THE_ARG_PARSER(self):
        """the *recently rewritten* stdlib option parsing library is not
        testing-friendly, nor is it sufficiently flexible for some novel
        uses. it writes to system stderr and exits, which might be rather
        violent depending on what you're trying to do.

        here, rather than subclass it, we experiment with this:
        """
        ap = self._top_parser

        def f(message):

            from gettext import gettext as _

            ap.print_usage(self.protected_resources.stderr)
            args = {'prog': ap.prog, 'message': message}
            msg = _('%(prog)s: error: %(message)s\n') % args
            raise _MyInterruption(2, msg)

        ap.error = f


    def __mutate_ARGV(self):

        argv = self.protected_resources.ARGV
        self.__program_name = argv[0]
        argv[0:1] = []



class _RecurseIntoCommandBranch:

    """do the same thing at every "branch node", whether it's a
    the top parser or a subparser (or a subsubparser, etc)"""

    def __init__(
      self,
      command_stream,
      parser,
    ):
        self.command_stream = command_stream
        self._subparsers = parser.add_subparsers()

    def execute(self):

        command_stream = self.command_stream
        del self.command_stream

        for cmd in command_stream:
          self._add_command(cmd)

    def _add_command(self, cmd):

        parser = self._subparsers.add_parser(
          cmd.name,
          help = 'cha cha',
        )

        if cmd.has_parameters:
            cover_me()


class _FailureResult:
    """x"""

    def __init__(self, es):
        self.exitstatus = es

    @property
    def OK(self):
        return False  # #never OK


class _MyInterruption(Exception):
    """we are forced to throw exception to interrupt control flow there :("""
    def __init__(self, exitstatus, message):
        self.exitstatus = exitstatus
        self.message = message


# #born.
