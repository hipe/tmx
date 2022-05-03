# (remember that longterm we don't want to do it this way)

from dataclasses import dataclass
from random import random as _random_float  # for now


_main_record_type = 'NativeCapability'


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

    itr = _structures_via_recsel(
            recfile, listener, '-t', _main_record_type, '-e', f'ID="{EID}"')
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
    return _structures_via_recsel(recfile, listener, '-t', _main_record_type)


def _structures_via_recsel(recfile, listener, *recfile_args):  # #testpoint

    def lineser():
        yield f"\n\nrecsel {' '.join(recfile_args)} {recfile}\n\n\n"

    if listener:
        listener('info', 'expression', 'sending_recsel', lineser)

    Capability = _build_EXPERIMENTAL_capability_class(recfile)

    from kiss_rdb.storage_adapters_.rec import NATIVE_RECORDS_VIA_RECSEL as func
    for rec in func(recfile, recfile_args, listener):
        eid, = rec.pop('ID')
        label, = rec.pop('Label')
        native_URL, = rec.pop('NativeURL', (None,))
        children = rec.pop('Child', None)
        if children:
            children = tuple(children)
        if len(rec):
            xx(f"handle this/these field(s): ({' '.join(rec.keys())})")
        assert not rec
        yield Capability(label, eid, native_URL, children)


def _build_EXPERIMENTAL_capability_class(recfile):

    class Capability(_Capability):
        def __init__(self, *rest):
            super().__init__(*rest)

        def RETRIEVE_NOTES(self, listener):
            recfile
            yield _Note("I am Note One")
            yield _Note("I am Note Two")

    return Capability


@dataclass
class _Capability:
    label: str
    EID: str
    native_URL: str
    children: tuple

    @property
    def implementation_state(self):
        f = _random_float()
        if f < 0.30:
            return
        if f < 0.55:
            return 'might_implement_eventually'
        if f < 0.90:
            return 'wont_implement_or_not_applicable'
        return 'is_implemented'


class _Note:
    def __init__(self, body):
        self.body = body


def xx(msg=None):
    raise RuntimeError(''.join(('oops', *((': ', msg) if msg else ()))))

# #history-C.1 changed main model class from namedtuple to dataclass
# #born
