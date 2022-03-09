# (remember that longterm we don't want to do it this way)

def RETRIEVE_ENTITY(recfile, EID, listener):

    def use_listener(*emi):
        if 'expression' == emi[0]:
            return listener(*emi)
        chan = emi[0:-1]
        if ('error', 'structure', 'input_error') == chan:
            dct = emi[-1]()
            s = dct['reason']
            return listener('error', 'expression', 'input_error', lambda: (s,))
        return listener(*emi)  # meh

    from kiss_rdb.magnetics_.identifier_via_string import \
            identifier_via_string_ as func
    iden = func(EID, use_listener)
    if not iden:
        return
    del iden

    itr = _structures_via_recsel(recfile, listener, '-e', f'ID="{EID}"')
    first = None
    for first in itr:
        break

    # Maybe it wasn't found
    if not first:
        def lineser():
            yield f"not found: {EID!r}"
        listener('error', 'expression', "entity_not_found", lineser)
        return

    # Maybe multiple were found (integrity error)
    second = None
    for second in itr:
        break
    if second:

        # exhaust the traversal to close the process :/
        count = 2
        for _ in itr:
            count += 1

        def lineser():
            yield f"{count} entities with same EID: {EID!r}"
        listener('error', 'expression', 'multiple_entities_found', lineser)
        return

    return first


def TRAVERSE_COLLECTION(recfile, listener):
    return _structures_via_recsel(recfile, listener)


def _structures_via_recsel(recfile, listener, *recfile_args):  # #testpoint
    _Capability = _capability_class()
    from kiss_rdb.storage_adapters_.rec import NATIVE_RECORDS_VIA_RECSEL as func
    for rec in func(recfile, recfile_args, listener):
        eid, = rec.pop('ID')
        label, = rec.pop('Label')
        children = rec.pop('Child', None)
        if children:
            children = tuple(children)
        assert not rec
        yield _Capability(label, eid, children)


def _capability_class():
    memo = _capability_class
    if not memo.value:
        memo.value = _build_capability_class()
    return memo.value


_capability_class.value = None


def _build_capability_class():
    from collections import namedtuple as nt
    return nt('Guy', ('label', 'EID', 'children'))

# #born
