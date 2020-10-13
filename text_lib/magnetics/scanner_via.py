"""
Conceptually we imagine a scanner as a "rotating buffer" (see sibling) with
one element of lookahead. (If you need more than one, build it off that.)

You've got:
- `empty` a property that tells you yes/no whether it's reached the end
- `more` the opposite of `empty`. convenience
- `next()` result in the next item and advance the pointer. undefined if empty
- `peek` see what `next()` would produce without changing state. undef if empty

>>> scn = scanner_via_iterator(iter(('A', 'B')))
>>> scn.more
True

>>> scn.empty
False

>>> scn.next()
'A'

>>> scn.peek
'B'

>>> scn.advance()

>>> scn.empty
True

In practive, for a lot of the cases where we want to do something scanner-like,
we just use a list as a stack. (For example `script_lib.cheap_arg_parse` is a
prime use case for scanners, but by design we take a decoupled approach.)

This module was born years and years after the idiom incubated and propagated.
"""


# == Adding A Counter (lineno and so on)

def MUTATE_add_counter(scn):
    def on_advance():
        counter.increment()

    def count():
        return counter.count

    counter = _Counter()
    MUTATE_add_advance_observer(scn, on_advance)
    return count


def add_counter_to_iterator(itr):  # not about scanners, that's okay
    """
    >>> itr = iter(('A', 'B'))
    >>> itr, counter = add_counter_to_iterator(itr)
    >>> counter.count
    0

    >>> next(itr)
    'A'

    >>> counter.count
    1

    >>> tuple(itr)
    ('B',)

    >>> counter.count
    2

    >>> tuple(itr)
    ()

    >>> counter.count
    2

    """
    def use():
        for item in itr:
            counter.increment()
            yield item
    counter = _Counter()
    return use(), counter


class _Counter:  # #[#510.13]
    def __init__(self):
        self.count = 0

    def increment(self):
        self.count += 1


# ==


def scanner_via_list(tup):
    def func():
        if stop_here == func.offset:
            return False, None
        func.offset += 1
        return True, tup[func.offset]
    func.offset = -1
    stop_here = len(tup) - 1
    scn = _scanner_via_universal_function(func)

    return scn


# ==

def MUTATE_add_advance_observer(scn, on_advance):
    def use_advance():
        x = orig_advance()
        on_advance()
        return x
    orig_advance = scn.advance
    scn.advance = use_advance  # #here1


# ==

def scanner_via_iterator(itr):
    """
    >>> scn = scanner_via_iterator(iter(('A', 'B')))
    >>> scn.more
    True
    >>> scn.next()
    'A'
    >>> scn.next()
    'B'
    >>> scn.empty
    True

    >>> scn = scanner_via_iterator(iter(()))
    >>> scn.empty
    True
    """

    def func():
        for item in itr:
            return True, item
        return False, None
    assert hasattr(itr, '__next__')  # [#022]
    return _scanner_via_universal_function(func)


def _scanner_via_universal_function(func):  # #testpoint
    def advance():
        yes, value = func()
        if yes:
            self.peek = value
            return
        self.empty, self.more = True, False
        del self.advance
        del self.peek

    class scanner:  # #class-as-namespace
        def next():
            x = self.peek
            self.advance()  # use self-dot, it may have been changed #here1
            return x
        empty, more, peek = False, True, None
    scanner.advance = advance
    self = scanner
    advance()
    return scanner

# #abstracted from universe in big unification
