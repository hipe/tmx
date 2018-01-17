def shared_subject(f):

    """decorator for lazy memoization of MONADIC method result

    #todo - we are borrowing an idiom from a different ecosystem. this is
    *certainly* not the way to implement it here, but it's a stand in.
    """

    first_YUCK = [True]
    value_YUCK = [False]

    def g(self_FROM_FIRST_CALL):
        if first_YUCK[0]:
            first_YUCK[0] = False
            value_YUCK[0] = f(self_FROM_FIRST_CALL)
        return value_YUCK[0]

    return g



def empty_iterator():
    if 0 == len(empty_iterator_YUCK):
      empty_iterator_YUCK.append( iter(()) )
    return empty_iterator_YUCK[0]

empty_iterator_YUCK = []



def hello():
    # for a very low-level (early) regression test.
    0
