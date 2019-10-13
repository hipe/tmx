# == BEGIN listener stowaway


class error_monitor_via_stderr:
    """a common CLI-targeted expression strategy for emissions

    Its main useful exposure is a modality-specific implementation of a
    [#017] listener, one that will reach out to an unified expressor
    for structured emissions.

    The reason we need an error monitor bespoke for CLI is that if a structured
    emission has an `errno`, we need to grab on to it (with mutation)..
    """
    # this is conceptually a sub-class of [#507.9] the generic error monitor

    def __init__(self, stderr, interceptor=None):
        self.exitstatus = 0
        self.OK = True
        self._interceptor = interceptor
        self._stderr = stderr

    def listener(self, *a):
        from modality_agnostic import listening
        em = listening.emission_via_args(a)
        if self._interceptor is not None:
            tf = self._interceptor(em)
            if tf is True:
                return
            assert(tf is None)
        self.__see_emission_severity(em)
        self.__express_emission(em)

    def __express_emission(self, em):
        self._write_line = _line_writer_via_IO(self._stderr)  # meh

        if 'expression' == em.shape:
            return self.__express_when_shape_is_expression(em)

        assert('structure' == em.shape)
        self.__express_when_shape_is_structure(em)

    def __express_when_shape_is_structure(self, em):
        dct = em.flush_payloader()
        if 'errno' in dct:
            _new_errno = dct.pop('errno')  # it's bad to mutate it but w/e
            self.see_exitstatus(_new_errno)

        from kiss_rdb.cli._case_adaptations import WHINE_ABOUT  # will rename
        WHINE_ABOUT(self._write_line, em.channel_tail, dct)

    def __express_when_shape_is_expression(self, em):

        payloader = em.release_payloader()

        num_args = payloader.__code__.co_argcount
        if num_args:
            assert(1 == num_args)
            lines = payloader(STYLER_)  # [#511.3]
        else:
            lines = payloader()

        write_line = self._write_line
        for line in lines:
            write_line(line)

    def __see_emission_severity(self, em):
        if 'error' != em.severity:
            assert('info' == em.severity)  # ..
            return
        self.OK = False

        # it's convenient to be able to return from your CLI function using
        # only `monitor.exitstatus` rather than needing also to check
        # `monitor.OK`. as such, experimentally we're always gonna bump this
        # up from zero in these cases (Case3069DP)

        self.see_exitstatus(1)  # bump it up from zero IFF zero

    def see_exitstatus(self, new_errno):
        if self.exitstatus < new_errno:
            self.exitstatus = new_errno


def _line_writer_via_IO(io):  # (move this to wherever)
    def write_line(s):
        _len = io.write(f'{s}\n')  # :[#607.B]
        assert(isinstance(_len, int))  # sort of like ~[#022]
        return _len
    return write_line


class STYLER_:
    """EXPERIMENT (placeholder)"""

    def em(s):
        return "\u001B[1;32m%s\u001B[0m" % s

    def hello_styler():  # #[#022]
        pass


# == END listener stowaway

class resources_via_ARGV_stream_and_stderr_and_stdout:  # #todo

    def __init__(self, ARGV_stream, stderr, stdout):
        self.ARGV_stream = ARGV_stream
        self.stdout = stdout
        self.stderr = stderr


def deque_via_ARGV(ARGV):  # #todo
    """(just saves you the one line)"""

    from collections import deque
    return deque(ARGV)

# #history-A.2 rewrite
# #history-A.1
# #abstracted.
