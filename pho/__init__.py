def errorer(listener):
    def f(error_symbol, msg):
        return emit_error(listener, error_symbol, msg)
    return f


def emit_error(listener, error_symbol, msg):
    _head = error_symbol.replace('_', ' ')
    _reason = f'{_head}: {msg}'
    listener('error', 'structure', error_symbol, lambda: {'reason': _reason})

# #born.
