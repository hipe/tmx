from script_lib import cover_me


#
# listener stowaway
#

def listener_via_resources(rsx):
    # (see comments in dedicated file)

    return listener_via_resources.listener_via_stderr(rsx.stderr)


def _listener_via_stderr(stderr):

    def listener(*a):
        d = _deque_via_array(a)
        emission_payload_f = d.pop()
        s = d.popleft()
        if s not in _approved_toplevel_channels:
            cover_me('bad first channel component: {}'.format(s))
        s = d.popleft()
        if s != 'expression':
            cover_me("need 'expression' had {}".format(s))
        if 1 < len(d):
            # cover_me(f'do you really want a fourth component?: {d[1]!r}')
            # longer channels used in e.g tag_lyfe [#708.3]. now preferred.
            pass

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


listener_via_resources.listener_via_stderr = _listener_via_stderr


class STYLER_:
    """EXPERIMENT (placeholder)"""

    def em(s):
        return "\u001B[1;32m%s\u001B[0m" % s

    def hello_styler():  # #[#022]
        pass


_approved_toplevel_channels = {
        'info': None,
        'error': None,
        }


#
#
#

class resources_via_ARGV_stream_and_stderr_and_stdout:

    def __init__(self, ARGV_stream, stderr, stdout):
        self.ARGV_stream = ARGV_stream
        self.stdout = stdout
        self.stderr = stderr


def deque_via_ARGV(ARGV):
    """(just saves you the one line)"""

    from collections import deque
    return deque(ARGV)


_deque_via_array = deque_via_ARGV

_NEWLINE = '\n'

# #abstracted.
