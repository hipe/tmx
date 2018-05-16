class listening:  # (as namespace only)

    def leveler_via_listener(level_s, listener):
        def o(tmpl, *args, **kwargs):
            log(level_s, tmpl, *args, **kwargs)
        log = listening.logger_via_listener(listener)
        return o

    def logger_via_listener(listener):
        def log(category, tmpl, *args, **kwargs):
            def write_this(o):
                _msg = tmpl.format(*args, **kwargs)
                o(_msg)
            listener(category, 'expression', write_this)
        return log


class streamlib:  # (as namespace only)

    def next_or_noner(itr):
        def f():
            return streamlib.next_or_none(itr)
        return f

    def next_or_none(itr):
        try:
            return next(itr)
        except StopIteration:
            pass


class Exception(Exception):
    pass


# #history-A.1: listener-related methods are spliced in from elsewhere
# #born.
