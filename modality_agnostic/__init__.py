class listening:  # (as namespace only)

    def leveler_via_listener(level_s, listener):
        def o(msg, *args):
            log(level_s, msg, *args)
        log = listening.logger_via_listener(listener)
        return o

    def logger_via_listener(listener):
        def log(category, msg, *args):
            def write_this(o):
                o(msg.format(*args))
            listener(category, 'expression', write_this)
        return log


class Exception(Exception):
    pass


# #history-A.1: listener-related methods are spliced in from elsewhere
# #born.
