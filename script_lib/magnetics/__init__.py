# == BEGIN listener stowaway


def listener_via_stderr(stderr):
    # this is a modality implementation of a [#017] listener
    # see a simpler #[#607.C] above and a more complex one below
    # as of #history-A.1 this may be LEGACY and DEPRECATED, awaitng
    # unification of case expression

    def listener(*a):
        from modality_agnostic import listening
        em = listening.emission_via_args(a)
        assert(em.severity in ('error', 'info'))
        if 'expression' == em.shape:
            return when_expression(em)
        assert('structure' == em.shape)
        when_structure(em)

    def when_structure(em):
        receive_nonterminated_message_string(em.flush_some_message())

    def when_expression(em):
        emission_payload_f = em.release_payloader()
        import inspect
        length = len(inspect.signature(emission_payload_f).parameters)
        if 0 == length:
            # #cover-me
            for msg in emission_payload_f():  # [#511.3] message lines iterator
                receive_nonterminated_message_string(msg)
        else:
            emission_payload_f(receive_nonterminated_message_string, STYLER_)

    def receive_nonterminated_message_string(s):
        if s:
            s += _NEWLINE
        else:
            s = _NEWLINE
        stderr.write(s)

    return listener


class STYLER_:
    """EXPERIMENT (placeholder)"""

    def em(s):
        return "\u001B[1;32m%s\u001B[0m" % s

    def hello_styler():  # #[#022]
        pass


# == END listener stowaway


class resources_via_ARGV_stream_and_stderr_and_stdout:

    def __init__(self, ARGV_stream, stderr, stdout):
        self.ARGV_stream = ARGV_stream
        self.stdout = stdout
        self.stderr = stderr


def deque_via_ARGV(ARGV):
    """(just saves you the one line)"""

    from collections import deque
    return deque(ARGV)


def cover_me(msg):
    raise Exception(f'cover me: {msg}')


_NEWLINE = '\n'

# #history-A.1
# #abstracted.
