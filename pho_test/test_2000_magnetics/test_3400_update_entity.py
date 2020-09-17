from modality_agnostic.memoization import lazy
from unittest import TestCase, main as unittest_main


def in_memory_collection(orig_f):
    def use_f():
        return in_memory_collection_via_entity_dictionaries(orig_f())
    return use_f


class CommonCase(TestCase):

    def these(self):
        def useAssertSequenceEqual(actual, expected):
            assert(isinstance(expected, tuple))
            use_expected = ('update_entity', *expected)
            self.assertSequenceEqual(actual, use_expected)
        pe = self.build_end_state().result_value
        stack = list(reversed(pe.units_of_work))
        return stack.pop, stack, useAssertSequenceEqual

    @property
    def end_state(self):
        cls = self.__class__
        if hasattr(cls, evil):
            return getattr(cls, evil)

        es = self.customize_end_state(self.build_end_state())
        setattr(cls, evil, es)
        return es

    def customize_end_state(self, end_state):
        return end_state

    def build_end_state(self):
        import modality_agnostic.test_support.common as em
        listener, emissions = em.listener_and_emissions_for(self)
        ncs = notecards_via_collection(self.collection())

        def perform(eid, cud_tups):
            entity_identifier_tup = ('update_entity', eid)
            return ncs._prepare_edit(entity_identifier_tup, cud_tups, listener)

        edits = self.perform(perform)
        return EndState(edits, tuple(emissions))

    do_debug = False


class EndState:

    def __init__(self, x, emi):
        self.result_value = x
        self.emissions = emi
        self.custom_data = None


evil = '_OMG_'  # back hacky memory hack [#507.6]


class Case3250_POORLY_FORMED_REQUEST(CommonCase):

    def test_100_strange_CUD_type(self):
        self.end_state['unrecognized CUD']

    def test_200_strange_attributes(self):
        line = self.end_state['had attribute'][0]
        self.assertEqual(line, 'had attribute name(s) not in the list of known attributes.')  # noqa: E501

    def test_300_multiple(self):
        self.end_state['appears multiple']

    def test_400_custom_reason(self):
        line = self.end_state["can't update"][0]
        self.assertEqual(line, "can't update identifier because identifiers are appointed to you")  # noqa: E501

    def customize_end_state(self, end_state):
        dct = {}
        assert(end_state.result_value is None)
        em, = end_state.emissions
        for para in paragraphs_via_lines(em.to_messages()):
            k = first_N_words(2, para[0])
            dct[k] = para
        return dct

    def perform(self, perform):
        cuds = []
        cuds.append(('frobulate_attribute', 'body'))
        cuds.append(('update_attribute', 'height_in_kilograms', 'qq'))
        cuds.append(('update_attribute', 'identifier', 'qq'))
        cuds.append(('create_attribute', 'body', 'qq'))
        cuds.append(('update_attribute', 'body', 'qq'))
        return perform('BB', cuds)

    def collection(self):
        return collection_LL1()


@lazy
@in_memory_collection
def collection_minimal():
    yield {
        'identifier_string': 'QQ',
        'core_attributes': {**reqs}}


class Case3280_delete_primitive(CommonCase):

    def test_100_everything(self):
        line, = self.build_end_state().emissions[0].to_messages()
        self.assertIn('body cannot be none', line)

    def perform(self, perform):
        return perform('QQ', (('delete_attribute', 'body'),))

    def collection(self):
        return collection_minimal()


class Case3310_update_primitive(CommonCase):

    def test_100_everything(self):
        pe = self.build_end_state().result_value
        edit, = pe.units_of_work
        expect = ('update_entity', 'QQ', 'update_attribute', 'body', 'wahoo')
        self.assertSequenceEqual(edit, expect)

    def perform(self, perform):
        cuds = []
        cuds.append(('update_attribute', 'body', 'wahoo'))
        return perform('QQ', cuds)

    def collection(self):
        return collection_minimal()


@lazy
@in_memory_collection
def collection_LL1():
    #
    #   AA <-> BB <-> CC <-> DD        GG <-> HH <-> II <-> JJ
    #

    yield {
        'identifier_string': 'AA',
        'core_attributes': {'next': 'BB', **reqs}}
    yield {
        'identifier_string': 'BB',
        'core_attributes': {'previous': 'AA', 'next': 'CC', **reqs}}
    yield {
        'identifier_string': 'CC',
        'core_attributes': {'previous': 'BB', 'next': 'DD', **reqs}}
    yield {
        'identifier_string': 'DD',
        'core_attributes': {'previous': 'CC', **reqs}}
    yield {
        'identifier_string': 'GG',
        'core_attributes': {'next': 'HH', **reqs}}
    yield {
        'identifier_string': 'HH',
        'core_attributes': {'previous': 'GG', 'next': 'II', **reqs}}
    yield {
        'identifier_string': 'II',
        'core_attributes': {'previous': 'HH', 'next': 'JJ', **reqs}}
    yield {
        'identifier_string': 'JJ',
        'core_attributes': {'previous': 'II', **reqs}}


class Case3340_create_a_prext(CommonCase):
    #
    #   AA <-> BB <-> CC <-> DD        GG <-> HH <-> II <-> JJ
    #
    #                          AFTER:
    #
    #   AA <-> BB <-> CC <-> DD <-> GG <-> HH <-> II <-> JJ

    def test_100_everything(self):
        p, stack, o = self.these()
        o(p(), ('DD', 'create_attribute', 'next', 'GG'))
        o(p(), ('GG', 'create_attribute', 'previous', 'DD'))
        assert(0 == len(stack))

    def perform(self, perform):
        cud = ('create_attribute', 'previous', 'DD')
        return perform('GG', (cud,))

    def collection(self):
        return collection_LL1()


class Case3370_two_cut_one_splice_a_linked_list(CommonCase):
    #
    #   AA <-> BB <-> CC <-> DD        GG <-> HH <-> II <-> JJ
    #
    #                          AFTER:
    #
    #   AA <-> BB <-> II <-> JJ     CC <-> DD    GG <-> HH

    def test_100_everything(self):
        p, stack, o = self.these()
        o(p(), ('HH', 'delete_attribute', 'next'))
        o(p(), ('II', 'update_attribute', 'previous', 'BB'))
        o(p(), ('CC', 'delete_attribute', 'previous'))
        o(p(), ('BB', 'update_attribute', 'next', 'II'))
        assert(0 == len(stack))

    def perform(self, perform):
        return perform('BB', (('update_attribute', 'next', 'II'),))

    def collection(self):
        return collection_LL1()


@in_memory_collection
def collection_tiktok():
    yield {
        'identifier_string': 'bytedance',
        'core_attributes': {'children': ('TikTok',), **reqs}}
    yield {
        'identifier_string': 'TikTok',
        'core_attributes': {'parent': 'bytedance', **reqs}}


class Case3400_delete_parent(CommonCase):
    #
    #        bytedance
    #             |
    #          TikTok
    #
    #          AFTER:
    #
    #        bytedance
    #
    #          TikTok

    def test_100_everything(self):  # _NOW_
        p, stack, o = self.these()
        o(p(), ('bytedance', 'delete_attribute', 'children'))
        o(p(), ('TikTok', 'delete_attribute', 'parent'))
        assert(0 == len(stack))

    def perform(self, perform):
        cud = ('delete_attribute', 'parent')
        return perform('TikTok', (cud,))

    def collection(self):
        return collection_tiktok()


class Case3430_create_parent(CommonCase):
    #
    #               AAA         BBB
    #             /    \       /   \
    #           A22    A23    B22  B23   C22
    #
    #                    AFTER:
    #                AAA
    #              /  |  \
    #           A22  A23  BBB            C22
    #                    /  \
    #                  B22 B23

    def test_100_everything(self):
        p, stack, o = self.these()
        o(p(), ('AAA', 'update_attribute', 'children', ('A22', 'A23', 'BBB')))
        o(p(), ('BBB', 'create_attribute', 'parent', 'AAA'))
        assert(0 == len(stack))

    def perform(self, perform):
        cud = ('create_attribute', 'parent', 'AAA')
        return perform('BBB', (cud,))

    def collection(self):
        return collection_fellas()


class Case3460_update_parent(CommonCase):
    #
    #               AAA         BBB
    #             /    \       /   \
    #           A22    A23    B22  B23   C22
    #
    #                    AFTER:
    #               AAA          BBB
    #             /            /  |  \
    #           A22         B22  B23 A23    C22

    def test_100_everything(self):
        p, stack, o = self.these()
        o(p(), ('AAA', 'update_attribute', 'children', ('A22',)))
        o(p(), ('BBB', 'update_attribute', 'children', ('B22', 'B23', 'A23')))
        o(p(), ('A23', 'update_attribute', 'parent', 'BBB'))
        assert(0 == len(stack))

    def perform(self, perform):
        cud = ('update_attribute', 'parent', 'BBB')
        return perform('A23', (cud,))

    def collection(self):
        return collection_fellas()


@lazy
@in_memory_collection
def collection_fellas():
    #
    #               AAA         BBB
    #             /    \       /   \
    #           A22    A23    B22  B23   C22
    #

    yield {
        'identifier_string': 'AAA',
        'core_attributes': {'children': ['A22', 'A23'], **reqs}}
    yield {
        'identifier_string': 'BBB',
        'core_attributes': {'children': ['B22', 'B23'], **reqs}}
    yield {
        'identifier_string': 'C22',
        'core_attributes': reqs}
    yield {
        'identifier_string': 'A22',
        'core_attributes': {'parent': 'AAA', **reqs}}
    yield {
        'identifier_string': 'A23',
        'core_attributes': {'parent': 'AAA', **reqs}}
    yield {
        'identifier_string': 'B22',
        'core_attributes': {'parent': 'BBB', **reqs}}
    yield {
        'identifier_string': 'B23',
        'core_attributes': {'parent': 'BBB', **reqs}}


class Case3490_delete_children(CommonCase):
    #
    #               AAA         BBB
    #             /    \       /   \
    #           A22    A23    B22  B23   C22
    #
    #                    AFTER:
    #               AAA         BBB
    #             /    \
    #           A22    A23    B22  B23   C22

    def test_100_everything(self):
        p, stack, o = self.these()
        o(p(), ('B22', 'delete_attribute', 'parent'))
        o(p(), ('B23', 'delete_attribute', 'parent'))
        o(p(), ('BBB', 'delete_attribute', 'children'))
        assert(0 == len(stack))

    def perform(self, perform):
        return perform('BBB', (('delete_attribute', 'children'),))

    def collection(self):
        return collection_fellas()


class Case3520_edit_children(CommonCase):
    #
    #               AAA         BBB
    #             /    \       /   \
    #           A22    A23    B22  B23   C22
    #
    #                    AFTER:
    #                AAA        BBB
    #             /   |  \       |
    #           C22  A23 B23    B22      A22

    def test_100_everything(self):
        p, stack, o = self.these()
        o(p(), ('BBB', 'update_attribute', 'children', ('B22',)))
        o(p(), ('B23', 'update_attribute', 'parent', 'AAA'))
        o(p(), ('C22', 'create_attribute', 'parent', 'AAA'))
        o(p(), ('A22', 'delete_attribute', 'parent'))
        o(p(), ('AAA', 'update_attribute', 'children', ('C22', 'A23', 'B23')))
        assert(0 == len(stack))

    def perform(self, perform):
        cud = ('update_attribute', 'children', ('C22', 'A23', 'B23'))
        return perform('AAA', (cud,))

    def collection(self):
        return collection_fellas()


class Case3550_create_children(CommonCase):
    #
    #               AAA         BBB
    #             /    \       /   \
    #           A22    A23    B22  B23   C22
    #
    #                    AFTER:
    #               AAA
    #             /     \
    #           A22     A23
    #                 /  |  \
    #              C22  BBB B23
    #                   /
    #                 B22

    def test_100_everything(self):
        p, stack, o = self.these()
        o(p(), ('BBB', 'update_attribute', 'children', ('B22',)))
        o(p(), ('B23', 'update_attribute', 'parent', 'A23'))
        o(p(), ('C22', 'create_attribute', 'parent', 'A23'))
        o(p(), ('BBB', 'create_attribute', 'parent', 'A23'))
        o(p(), ('A23', 'create_attribute', 'children', ('C22', 'BBB', 'B23')))
        assert(0 == len(stack))

    def perform(self, perform):
        cud = ('create_attribute', 'children', ('C22', 'BBB', 'B23'))
        return perform('A23', (cud,))

    def collection(self):
        return collection_fellas()


def notecards_via_collection(coll):
    from pho import _Notecards
    return _Notecards(coll)


# == FROM will move to kiss one day probaly

class in_memory_collection_via_entity_dictionaries:

    def __init__(self, ent_dcts):
        coll_dct = {}
        for ent_dct in ent_dcts:
            eid = ent_dct['identifier_string']
            assert(eid not in coll_dct)
            coll_dct[eid] = ent_dct
        self._dct = coll_dct

    def retrieve_entity(self, eid_s, listener):
        ent_dct = self._dct.get(eid_s)
        if ent_dct is not None:
            return ent_dct

        def structer():
            return {'reason': f"not found (hello from test) '{eid_s}'"}
        listener('error', 'structure', 'entity_not_found', structer)

# == TO here


def paragraphs_via_lines(lines):
    def flush():
        para = tuple(cache)
        cache.clear()
        return para
    itr = iter(lines)
    cache = [next(itr)]
    for line in itr:
        if ' ' == line[0]:
            cache.append(line)
            continue
        yield flush()
        cache.append(line)
    para = flush()
    assert(len(para))
    yield para


def _build_first_N_words():
    def first_N_words(n, s):
        return rx_for(n).match(s)[0]

    def rx_for(n):
        rx = cache.get(n)
        if rx:
            return rx
        this = "[a-zA-Z']+"
        pcs = ['^', this]
        for _ in range(1, n):
            pcs.append(' ')
            pcs.append(this)

        rx = re.compile(''.join(pcs))
        cache[n] = rx
        return rx

    import re
    cache = {}
    return first_N_words


first_N_words = _build_first_N_words()


reqs = {
    'heading': "some heading",
    'body': "some body"}


if __name__ == '__main__':
    unittest_main()


# still need to cover:
# - {update} primitive
# - delete parent when you are only child leads to delete children

# #born
