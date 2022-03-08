def capability_record_structures_via_lines(lines, listener):
    memo = capability_record_structures_via_lines
    if memo.capability_class is None:
        memo.capability_class = _build_capability_class()
    _Capability = memo.capability_class
    from kiss_rdb.storage_adapters_.rec import NATIVE_RECORDS_VIA_LINES as func
    for rec in func(lines, listener):
        eid, = rec.pop('ID')
        label, = rec.pop('Label')
        children = rec.pop('Child', None)
        if children:
            children = tuple(children)
        assert not rec
        yield _Capability(label, eid, children)


capability_record_structures_via_lines.capability_class = None


def _build_capability_class():
    from collections import namedtuple as nt
    return nt('Guy', ('label', 'EID', 'children'))

# #born
