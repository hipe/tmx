"""
This was #born at the birth of breaking the package up into an actual plugin/
dependency-injection thing with multiple storage adapters.

Its objective is to offer a rough "compatibility check" test suite so that
  - we aren't duplicating the work of redundantly coming up anew
    with cases for each new storage adapter
  - we can have some assurance and peace of mind that a given storage adapter
    meets some minimum standard of completeness

One positive side-effect is that we centralize how & where we interact
with the system under test mostly. The traversing, creating, updating &
deleting mostly happens here so it A) DRYes up the test files and B) distills
our real API "organically" into this file.

We take into account:
  - the [#867] entities CUD roadmap,
  - the [#868] CUD entities number allocation (a rough guideline)


.## our imagined suite:

- Read-only:

  - Resolve collection:
    - CASE: collection not found
    - CASE: empty collection found
    - CASE: non-empty collection found given some kind of path identifier

  - Traverse ID's
    - CASE: resolve the correct N ID's from the collection, in any order
    - CASE: traverse ID's from the empty collection

  - Traverse all entities:
    - CASE: resolve the correct N ID's in any order, test that one string
            field is retrieved, test that featherweighting isn't biting you

  - Retrieve one entity:
    - CASE: entity not found because identifier too deep
    - CASE: entity not found (identifier OK)
    - CASE: entity found

- Collection-mutation:

  - Delete entity:
    - CASE: entity not found
    - CASE: Delete OK resulting in non-empty collection
    - CASE: Delete OK resulting in empty collection

  - Create entity:
    - CASE: won't create because invalid somehow
    - CASE: create OK into non-empty collection
    - CASE: create OK into empty collection

  - Update entity:
    - CASE: entity not found
    - CASE: referenced attribute not found
    - CASE: update OK


to get a count of the above cases:

    head -n [end line above] [this file] | perl -ne 'print $_ if /\bCASE:/'
"""


def produce_agent():
    """DISCUSSION: EXPERIMENTAL

    This function is a placeholder for a *very* experimental that we can
    establish a "compliance declaration" programmatically.

    First, the idea of a "compliance declaration": it is the answer to the
    question of which cases from the canon does this storage adapter intend
    to comply with?

    We could assume that all storage adapters should comply with all cases,
    but we suspect that in practice such a constraint could be counter-
    productive.

    For example we may create SA's whose only purpose is to be read-only.
    Such SA's would be only partially compliant by design. We would want to
    recognize thse SA's formally as such by calling them (for example)
    "read-only compliant". We might want other designations like "fully
    compliant", "partially compliant (other)", etc.

    Furthermore, formalizing partial compliance can help us define acceptance
    criteria for different milestones along a development roadmap, for e.g.

    So now that we know why we want formalized partial compliance, the
    question becomes "how does an SA express which cases it intends to
    fullfill and not?"

    Our answer to that, at least in theory, is that such a declaration
    should only ever be derived *directly* from the unit tests. More later..
    """

    #  assertion programatically ..)
    import sys
    return sys.modules[__name__]


def _confirm_result_is_none(tc):  # tc = test case
    es = tc.end_state
    tc.assertIsNone(es['result_value'])


class case_of_collection_not_found:  # #as-namespace-only

    confirm_result_is_none = _confirm_result_is_none

    def confirm_channel_looks_right(tc):
        chan = tc.end_state['channel']
        tc.assertEqual(chan[0], 'error')
        # for historical and flex reasons, we are allowing expressions here
        tc.assertEqual(chan[2], 'cannot_load_collection')

    def confirm_expression_looks_right(tc):
        reason = _reason_from(tc.end_state)
        if -1 == (i := reason.find(' because ')):
            i = reason.index(':')  # ..
        head = reason[:i]
        exp = 'cannot load collection', 'collection does not exist'
        tc.assertIn(head, exp)


def _confirm_collection_is_not_none(tc):
    tc.assertIsNotNone(tc.given_collection())


class case_of_empty_collection_found:  # #as-namespace-only

    confirm_collection_is_not_none = _confirm_collection_is_not_none


class case_of_non_empty_collection_found:  # #as-namespace-only

    confirm_collection_is_not_none = _confirm_collection_is_not_none


class case_of_traverse_IDs_from_non_empty_collection:  # #as-namespace-only

    def confirm_all_IDs_in_any_order_no_repeats(tc):  # similar to #here1
        coll = tc.given_collection()
        with coll.open_identifier_traversal(throwing_listener) as idens:
            eids = tuple(_EID_via_identifier(iden) for iden in idens)
        tc.assertSequenceEqual(sorted(eids), _these_N_IDs)


class case_of_traverse_IDs_from_empty_collection:  # #as-namespace-only

    def confirm_results_in_empty_stream(tc):
        _tup = build_flattened_collection_for_traversal_case(tc)
        tc.assertSequenceEqual(_tup, ())


# eid = Entity Identifier [#857.E]


class case_of_traverse_all_entities:  # #as-namespace

    def confirm_all_IDs_in_any_order_no_repeats(tc):
        ent_tup = tc.flattened_collection_for_traversal_case
        primi_tup = tuple(_EID_via_entity(ent) for ent in ent_tup)
        actual_sorted = sorted(primi_tup)  # similar to #here2
        tc.assertSequenceEqual(actual_sorted, _these_N_IDs)

    def confirm_particular_entity_knows_one_of_its_field(tc):
        eid = _EID_via_test_case(tc)
        tup = tc.flattened_collection_for_traversal_case
        ent = next(ent for ent in tup if eid == _EID_via_entity(ent))
        _actual = _yes_value_dict(ent)['thing_A']  # #watch [#867.B] getters?
        tc.assertEqual(_actual, f"hi i'm {eid}")

    def confirm_featherweighting_isnt_biting(tc):
        ent_tup = tc.flattened_collection_for_traversal_case
        these = ('B8H', 'B7G')
        itr = (ent for ent in ent_tup if _EID_via_entity(ent) in these)
        left = next(itr)
        right = next(itr)
        left_iden = left.identifier
        right_iden = right.identifier
        tc.assertNotEqual(left_iden, right_iden)
        left_dct = _yes_value_dict(left)
        right_dct = _yes_value_dict(right)
        tc.assertNotEqual(left_dct, right_dct)


_these_N_IDs = (
        '2HJ',
        'B7E',
        'B7F',
        'B7G',
        'B8H',
        'B9G',
        'B9H',  # this one is usually used for the create and update case too
        'B9J')


def build_flattened_collection_for_traversal_case(tc):  # similar to #here1
    coll = tc.given_collection()
    with coll.open_entity_traversal(None) as ents:
        return tuple(ents)


class case_of_entity_not_found_because_identifier_too_deep:
    # #as-namespace-only

    confirm_result_is_none = _confirm_result_is_none

    def confirm_emitted_accordingly(tc):

        es = tc.end_state

        tc.assertSequenceEqual(
            es['channel'], ('error', 'structure', 'entity_not_found'))

        # assert that the requisite depth (in one case max)
        # and the argument identifier depth are both in the message (..)

        reason = _reason_from(es)

        re = _re_lib()
        md = re.search(r'\bneed(?:ed)? (\d+), had (\d+)', reason)
        if md is not None:
            two = md.groups()
        else:
            two = tuple(re.findall(r'\((\d)\)', reason))  # ..
        two = tuple(int(s) for s in two)
        two = sorted(two)
        tc.assertSequenceEqual(two, (3, 4))

        # assert that the identifier is in the expression (..)

        _assert_says_identifier_probably(
                tc, reason, _EID_via_test_case(tc))

    def build_end_state(tc):
        return _end_state_for_retrieve_via_string(
                tc, _EID_via_test_case(tc), _expecting_not_OK)


class case_of_entity_not_found:  # #as-namespace-only

    confirm_result_is_none = _confirm_result_is_none

    def confirm_emitted_accordingly(tc):
        es = tc.end_state
        tc.assertSequenceEqual(
            es['channel'], ('error', 'structure', 'entity_not_found'))
        reason = _reason_from(es)
        _assert_says_identifier_probably(
                tc, reason, _EID_via_test_case(tc))
        tc.assertRegex(reason, r'\bnot found\b')

    def build_end_state(tc):
        return _end_state_for_retrieve_via_string(
                tc, _EID_via_test_case(tc), _expecting_not_OK)


class case_of_retrieve_OK:  # #as-namespace-only

    def confirm_entity_is_retrieved_and_looks_ok(tc):
        # assume no emissions bc we built it belo with this implicit assumption
        ent = tc.end_state['result_value']
        _ = _EID_via_test_case(tc)
        _same_confirmation_of_before_update(tc, ent, _)

    def build_end_state(tc):
        # we have to deconstruct and duplicate "build end state" b.c no emissio
        eid = _EID_via_test_case(tc)
        coll = tc.given_collection()
        wat = _do_retrieve(coll, eid, None)
        dct = {}
        dct['result_value'] = wat
        dct['collection'] = coll
        dct['identifier_primitive'] = eid
        return dct


class case_of_delete_but_entity_not_found:  # #as-namespace-only

    confirm_result_is_none = _confirm_result_is_none

    def confirm_emitted_accordingly(tc):
        es = tc.end_state
        tc.assertSequenceEqual(
            es['channel'], ('error', 'structure', 'entity_not_found'))
        reason = _reason_from(es)

        _assert_says_cannot_verb(tc, reason, 'delete')

        _assert_says_identifier_probably(
                tc, reason, _EID_via_test_case(tc))

        tc.assertRegex(reason, r'\bnot found\b')

    def build_end_state(tc):
        return _end_state_for_delete_via_string(
                tc, _EID_via_test_case(tc), _expecting_not_OK)


class _common_delete:  # as-namespace-only

    def confirm_result_is_the_deleted_entity(tc):
        es = tc.end_state
        deleted_ent = es['result_value']
        act = _EID_via_entity(deleted_ent)
        exp = es['identifier_primitive']
        tc.assertEqual(act, exp)
        tc.CONFIRM_THIS_LOOKS_LIKE_THE_DELETED_ENTITY(deleted_ent)

    def confirm_emitted_accordingly(tc):
        es = tc.end_state
        tc.assertSequenceEqual(
                es['channel'], ('info', 'structure', 'deleted_entity'))
        act_eid = es['identifier_primitive']
        message = _message_from(es)
        _assert_says_identifier_probably(tc, message, act_eid)
        tc.assertRegex(message, r'\bdeleted\b')

    def build_end_state_for_delete(tc, eid):
        return _end_state_for_delete_via_string(tc, eid, _expecting_OK)


class case_of_delete_OK_resulting_in_non_empty_collection(_common_delete):
    # #as-namespace-only

    pass  # lost only thing at #history-B.4


class case_of_delete_OK_resulting_in_empty_collection(_common_delete):
    # #as-namespace-only

    def confirm_the_collection_is_empty(tc):
        es = tc.end_state
        coll = es['collection']
        _confirm_collection_empty(tc, coll)


class case_of_create_but_something_is_invalid:  # #as-namespace-only

    confirm_result_is_none = _confirm_result_is_none

    def confirm_emitted_accordingly(tc):
        es = tc.end_state
        tc.assertSequenceEqual(
            es['channel'][:3], ('error', 'structure', 'cannot_create'))
        reason = _reason_from(es)

        _assert_says_cannot_verb(tc, reason, 'create')

        tc.CONFIRM_THE_REASON_SAYS_WHAT_IS_WRONG_WITH_IT(reason)

    def build_end_state(tc):
        dct = tc.dictionary_for_create_with_something_invalid_about_it()
        return _end_state_for_create(tc, dct, _expecting_not_OK)


def _create_OK_emitted_accordingly(tc):
    es = tc.end_state
    tc.assertSequenceEqual(
            es['channel'], ('info', 'structure', 'created_entity'))
    message = _message_from(es)
    # we don't know what ID was provisioned and meh as far as conf
    these = _find_all_identifer_looking_strings(message)
    tc.assertEqual(len(these), 1)  # ..
    tc.assertRegex(message, r"^created '[^']+' with \d attributes$")


def _create_OK_confirm_in_collection(tc):

    es = tc.end_state
    ent_one = es['result_value']
    eid = _EID_via_entity(ent_one)
    coll = es['collection']
    ent_two = _do_retrieve(coll, eid, None)
    if ent_one != ent_two:
        dct_one = _yes_value_dict(ent_one)
        dct_two = _yes_value_dict(ent_two)
        tc.assertEqual(dct_one, dct_two)


class case_of_create_OK_into_empty_collection:  # #as-namespace-only

    def confirm_result_is_the_created_entity(tc):
        sct = tc.end_state
        dct = _yes_value_dict(sct['result_value'])
        # tc.assertEqual(dct['thing_2'], '123')  # #here3
        tc.assertEqual(dct['thing_B'], '3.14')
        tc.assertIn(len(dct), (1, 2))  # #here3

    confirm_emitted_accordingly = _create_OK_emitted_accordingly

    confirm_entity_now_in_collection = _create_OK_confirm_in_collection

    def build_end_state(tc):
        def confim_empty(coll):
            _confirm_collection_empty(tc, coll)

        dct = {'thing_2': '123', 'thing_B': '3.14'}  # ..
        return _end_state_for_create(tc, dct, _expecting_OK, confim_empty)


class case_of_create_OK_into_non_empty_collection:  # #as-namespace-only

    def confirm_result_is_the_created_entity(tc):
        sct = tc.end_state
        dct = _yes_value_dict(sct['result_value'])
        # tc.assertEqual(dct['thing_2'], '-2.718') .. #history-B.1
        tc.assertEqual(dct['thing_B'], 'false')
        tc.assertIn(len(dct), (1, 2))  # #here3

    confirm_emitted_accordingly = _create_OK_emitted_accordingly

    confirm_entity_now_in_collection = _create_OK_confirm_in_collection

    def build_end_state(tc):
        dct = {'thing_2': '-2.718', 'thing_B': 'false'}  # ..
        return _end_state_for_create(tc, dct, _expecting_OK)


class case_of_update_but_entity_not_found:  # #as-namespace-only

    confirm_result_is_none = _confirm_result_is_none

    def confirm_emitted_accordingly(tc):
        es = tc.end_state
        tc.assertSequenceEqual(
            es['channel'], ('error', 'structure', 'entity_not_found'))
        act = _reason_from(es)
        _assert_says_cannot_verb(tc, act, 'update')
        eid = es['identifier_primitive']
        _assert_says_identifier_probably(tc, act, eid)
        tc.assertIn(' not found ', act)  # ..

    def build_end_state(tc):
        s, tup = tc.request_tuple_for_update_that_will_fail_because_no_ent()
        return _end_state_for_update(tc, tup, s, _expecting_not_OK)


class case_of_update_but_attribute_not_found:  # #as-namespace-only

    confirm_result_is_none = _confirm_result_is_none

    def confirm_emitted_accordingly(tc):
        es = tc.end_state
        exp = 'error', 'structure', 'cannot_update'
        tc.assertSequenceEqual(es['channel'], exp)
        s = _reason_from(es)
        _assert_says_cannot_verb(tc, s, 'update')
        _assert_says_identifier_probably(tc, s, es['identifier_primitive'])
        tc.assertRegex(s, r'\b(?:has no existing value|not found in entity)\b')

    def build_end_state(tc):
        eid, tup = tc.given_request_tuple_for_update_that_will_fail_because_attr()  # noqa: E501
        return _end_state_for_update(tc, tup, eid, _expecting_not_OK)


class case_of_update_OK:  # #as-namespace-only

    def confirm_result_is_before_and_after_entities(tc):
        sct = tc.end_state
        before_ent, after_ent = sct['result_value']
        tc.assertEqual(before_ent.identifier, after_ent.identifier)
        tc.assertNotEqual(before_ent, after_ent)

    def confirm_emitted_accordingly(tc):
        es = tc.end_state
        chan = es['channel']
        tc.assertSequenceEqual(chan, ('info', 'structure', 'updated_entity'))
        message = _message_from(es)
        _ = _EID_via_test_case(tc)
        # a big flex 👇
        _exp = f"updated '{_}' "\
               '(created 1, updated 1 and deleted 1 attribute)'
        tc.assertEqual(message, _exp)

    def confirm_the_before_entity_has_the_before_values(tc):
        before_ent, after_ent = tc.end_state['result_value']
        _ = _EID_via_test_case(tc)
        _same_confirmation_of_before_update(tc, before_ent, _)

    def confirm_the_after_entity_has_the_after_values(tc):
        before_ent, after_ent = tc.end_state['result_value']
        _ = _EID_via_test_case(tc)
        _same_confirmation_of_after_update(tc, after_ent, _)

    def confirm_retrieve_after_shows_updated_value(tc):
        es = tc.end_state
        eid = es['identifier_primitive']
        coll = es['collection']
        ent = _do_retrieve(coll, eid, None)
        _ = _EID_via_test_case(tc)
        _same_confirmation_of_after_update(tc, ent, _)

    def build_end_state(tc):
        eid, tup = tc.request_tuple_for_update_that_will_succeed()
        return _end_state_for_update(tc, tup, eid, _expecting_OK)


# == support that helps make asssertions of states

def _same_confirmation_of_after_update(tc, after_ent, eid):
    tc.assertEqual(_EID_via_entity(after_ent), eid)  # might become own test
    dct = _yes_value_dict(after_ent)
    act_left = dct['thing_B']
    act_right = dct['thing_2']
    tc.assertEqual(act_left, "I'm modified \"thing_B\"")
    tc.assertEqual(act_right, "I'm created \"thing_2\"")
    tc.assertEqual(len(dct), 2)  # to confirm deletes


def _same_confirmation_of_before_update(tc, ent, eid):
    tc.assertEqual(_EID_via_entity(ent), eid)  # maybe dedicated test
    dct = _yes_value_dict(ent)
    tc.assertEqual(dct['thing_A'], f"hi i'm {eid}")
    tc.assertEqual(dct['thing_B'], f"hey i'm {eid}")
    tc.assertEqual(len(dct), 2)  # to confirm deletes in after

    # we might move this to its own test
    dct_ = ent.to_dictionary_two_deep()
    tc.assertEqual(dct_['identifier_string'], eid)
    tc.assertEqual(dct_['core_attributes'], dct)  # OOF extreme laziness


def _assert_says_identifier_probably(tc, reason, eid):
    # do the "in" test first just to get a friendly errmsg, then check count

    these = _find_all_identifer_looking_strings(reason)
    leng = len(these)
    if leng:
        tc.assertEqual(1, leng)
        return
    needle = f"'{eid}'"
    tc.assertIn(needle, reason)


def _find_all_identifer_looking_strings(message):
    return tuple(_re_lib().findall(r"'([^']+)'", message))  # #history-B.1


def _assert_says_cannot_verb(tc, reason, verb):
    assert(verb in ('create', 'update', 'delete'))
    _ = f"\\b(?:cannot|can't|couldn't) {verb}\\b"  # etc
    tc.assertRegex(reason, _)


def reason_via_end_state(es):
    return _message_or_reason_from('error', es)


_reason_from = reason_via_end_state


def _message_from(es):
    return _message_or_reason_from('info', es)


def _message_or_reason_from(_which, es):
    from modality_agnostic import emission_via_args as func
    emi = func(*es['channel'], es['payloader'])
    is_expression = ('structure', 'expression').index(emi.shape)
    if is_expression:
        return ' '.join(emi.to_messages())
    # at #history-A.5 we broke tests by simplifying the emissions class such
    # that it no longer does its own clever expression enhancements. so:
    from script_lib.magnetics.expression_via_structured_emission import \
        lines_via_channel_tail_and_details as func
    lines = tuple(func(emi.to_channel_tail(), emi.payloader()))
    return ' '.join(lines)


def _confirm_collection_empty(tc, coll):
    with coll.open_identifier_traversal(throwing_listener) as idens:
        for iden in idens:
            tc.fail("collection was not empty.")


def _yes_value_dict(ent):
    return ent.core_attributes_dictionary


yes_value_dictionary_of = _yes_value_dict


# == support that helps set up state

# -- update

def _end_state_for_update(tc, tup, eid, expecting_OK):
    def run(listener):
        return coll.update_entity(eid, tup, listener)
    coll = tc.given_collection()
    return _end_state_plus(tc, run, coll, eid, expecting_OK)


# -- create

def _end_state_for_create(tc, dct, expecting_OK, with_coll=None):
    def run(listener):
        return coll.create_entity(dct, listener)
    coll = tc.given_collection()
    if with_coll is not None:
        with_coll(coll)
    es = end_state_via_(tc, run, expecting_OK)
    es['collection'] = coll
    return es


# -- delete

def _end_state_for_delete_via_string(tc, eid, expecting_OK):
    def run(listener):
        return coll.delete_entity(eid, listener)
    coll = tc.given_collection()
    return _end_state_plus(tc, run, coll, eid, expecting_OK)


# -- retrive

def _end_state_for_retrieve_via_string(tc, eid, expecting_OK):
    def run(listener):
        return _do_retrieve(coll, eid, listener)
    coll = tc.given_collection()
    return _end_state_plus(tc, run, coll, eid, expecting_OK)


def _do_retrieve(coll, eid, listener):
    return coll.retrieve_entity(eid, listener)


# -- support

def build_end_state_expecting_failure_via(tc, additionally=None):
    listener, emissions = _em().listener_and_emissions_for(tc, limit=2)
    x = tc.resolve_collection(listener)
    if x and additionally:
        x = additionally(x, listener)
    emi, *_ = emissions
    sct = emi.payloader()  # make it not hot
    return {'result_value': x, 'channel': emi.channel,
            'payloader': lambda: sct}
    # eventually #open [#867.J] re-redund this


def _end_state_plus(tc, run, coll, eid, expecting_OK):
    es = end_state_via_(tc, run, expecting_OK)
    es['collection'] = coll
    es['identifier_primitive'] = eid
    return es


def end_state_via_(tc, run, expecting_OK):
    sev = 'info' if expecting_OK else 'error'
    expectation = (sev, '?+', 'as', '_the_one_emission')
    listener, done = _em().listener_and_done_via((expectation,), tc)
    x = run(listener)
    e = done()['_the_one_emission']
    # removed discussion of payloader_caution_HOT at #history-B.1
    return {'result_value': x, 'channel': e.channel, 'payloader': e.payloader}


def identifier_via_string(_, s):  # #method
    from modality_agnostic import throwing_listener as listener
    from kiss_rdb.magnetics_ import identifier_via_string as lib
    return lib.identifier_via_string_(s, listener)


# == Smalls, support

def _EID_via_test_case(tc):
    if hasattr(tc, 'given_identifier_string'):
        return tc.given_identifier_string()
    return tc.given_identifier_primitive()


def _EID_via_entity(ent):  # meh
    return _EID_via_identifier(ent.identifier)


def _EID_via_identifier(iden):
    if iden is None:
        return
    if isinstance(iden, str):  # #provision [#857.E]
        return iden
    return iden.to_primitive()


# == Libs

def throwing_listener(*emission):
    return _em().throwing_listener(*emission)


def _em():
    import modality_agnostic.test_support.common as em
    return em


def _re_lib():
    import re as module
    return module


_expecting_not_OK = False
_expecting_OK = True


# #history-B.5
# #history-B.4
# :#here3: at #history-B.1, [#871.1] messes up some doo-hahs and not others
# #history-B.1
# #born.
