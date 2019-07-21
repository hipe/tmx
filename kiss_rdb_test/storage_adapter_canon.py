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
    es = tc.end_state()
    tc.assertIsNone(es['result_value'])


class case_of_collection_not_found:  # #as-namespace-only

    confirm_result_is_none = _confirm_result_is_none

    def confirm_channel_looks_right(tc):
        chan = tc.end_state()['channel']
        tc.assertEqual(chan[0], 'error')
        # for historical and flex reasons, we are allowing expressions here
        tc.assertEqual(chan[2], 'collection_not_found')

    def confirm_expression_looks_right(tc):
        reason = _reason_from(tc.end_state())
        tc.assertRegex(reason, r'^collection not found: [\[a-zA-Z0-9]')


def _confirm_collection_is_not_none(tc):
    tc.assertIsNotNone(tc.subject_collection())


class case_of_empty_collection_found:  # #as-namespace-only

    confirm_collection_is_not_none = _confirm_collection_is_not_none


class case_of_non_empty_collection_found:  # #as-namespace-only

    confirm_collection_is_not_none = _confirm_collection_is_not_none


class case_of_traverse_IDs_from_non_empty_collection:  # #as-namespace-only

    def confirm_all_IDs_in_any_order_no_repeats(tc):  # similar to #here1
        coll = tc.subject_collection()
        _iids = _do_to_ID_stream(coll, None)
        _string_tup = tuple(iid.to_string() for iid in _iids)  # sim to #here2
        _actual_sorted = sorted(_string_tup)
        tc.assertSequenceEqual(_actual_sorted, _these_N_IDs)


class case_of_traverse_IDs_from_empty_collection:  # #as-namespace-only

    def confirm_results_in_empty_stream(tc):
        _tup = build_flattened_collection_for_traversal_case(tc)
        tc.assertSequenceEqual(_tup, ())


class case_of_traverse_all_entities:  # #as-namespace

    def confirm_all_IDs_in_any_order_no_repeats(tc):
        _tup = tc.flattened_collection_for_traversal_case()
        _string_tup = tuple(ent.identifier.to_string() for ent in _tup)
        _actual_sorted = sorted(_string_tup)  # similar to #here2
        tc.assertSequenceEqual(_actual_sorted, _these_N_IDs)

    def confirm_particular_entity_knows_one_of_its_field(tc):
        _tup = tc.flattened_collection_for_traversal_case()
        ent = next(ent for ent in _tup if 'B9H' == ent.identifier.to_string())
        _actual = _yes_value_dict(ent)['thing-A']  # #watch [#867.B] getters?
        tc.assertEqual(_actual, "hi i'm B9H")

    def confirm_featherweighting_isnt_biting(tc):
        _tup = tc.flattened_collection_for_traversal_case()
        these = ('B8H', 'B7G')
        itr = (ent for ent in _tup if ent.identifier.to_string() in these)
        left = next(itr)
        right = next(itr)
        tc.assertNotEqual(left.identifier.to_string(),
                          right.identifier.to_string())
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
        'B9H',
        'B9J',
        )


def build_flattened_collection_for_traversal_case(tc):  # similar to #here1
    _sc = tc.subject_collection()
    _ents = _sc.to_entity_stream_as_storage_adapter_collection(None)
    return tuple(_ents)


class case_of_entity_not_found_because_identifier_too_deep:
    # #as-namespace-only

    confirm_result_is_none = _confirm_result_is_none

    def confirm_emitted_accordingly(tc):
        es = tc.end_state()
        tc.assertSequenceEqual(
            es['channel'], ('error', 'structure', 'entity_not_found'))

        # assert that the requisite depth (in one case max)
        # and the argument identifier depth are both in the message (..)

        reason = _reason_from(es)

        import re
        md = re.search(r'\bneed(?:ed)? (\d+), had (\d+)', reason)
        if md is not None:
            two = md.groups()
        else:
            two = tuple(re.findall(r'\((\d)\)', reason))  # ..
        two = tuple(int(s) for s in two)
        two = sorted(two)
        tc.assertSequenceEqual(two, (3, 4))

        # assert that the identifier is in the expression (..)

        _assert_says_identifier_probably(tc, reason, 'AB23')

    def build_end_state(tc):
        return _end_state_for_retrieve_via_string(tc, 'AB23')


class case_of_entity_not_found:  # #as-namespace-only

    confirm_result_is_none = _confirm_result_is_none

    def confirm_emitted_accordingly(tc):
        es = tc.end_state()
        tc.assertSequenceEqual(
            es['channel'], ('error', 'structure', 'entity_not_found'))
        reason = _reason_from(es)
        _assert_says_identifier_probably(tc, reason, tc.IDENTIFIER_STRING())
        tc.assertRegex(reason, r'\bnot found\b')

    def build_end_state(tc):
        return _end_state_for_retrieve_via_string(tc, tc.IDENTIFIER_STRING())


class case_of_retrieve_OK:  # #as-namespace-only

    def confirm_entity_is_retrieved_and_looks_ok(tc):
        # assume no emissions bc we built it belo with this implicit assumption
        ent = tc.end_state()['result_value']
        _same_confirmation_of_before_update(tc, ent)

    def build_end_state(tc):
        # we have to deconstruct and duplicate "build end state" b.c no emmiss
        iden = _identifier_via_string('B9H')
        coll = tc.subject_collection()
        wat = _do_retrieve(coll, iden, None)
        return {'result_value': wat, 'collection': coll, 'identifier': iden}


class case_of_delete_but_entity_not_found:  # #as-namespace-only

    confirm_result_is_none = _confirm_result_is_none

    def confirm_emitted_accordingly(tc):
        es = tc.end_state()
        tc.assertSequenceEqual(
            es['channel'], ('error', 'structure', 'entity_not_found'))
        reason = _reason_from(es)

        _assert_says_cannot_verb(tc, reason, 'delete')

        _assert_says_identifier_probably(tc, reason, tc.IDENTIFIER_STRING())

        tc.assertRegex(reason, r'\bnot found\b')

    def build_end_state(tc):
        return _end_state_for_delete_via_string(tc, tc.IDENTIFIER_STRING())


class _common_delete:  # as-namespace-only

    def confirm_result_is_the_deleted_entity(tc):
        sct = tc.end_state()
        deleted_ent = sct['result_value']
        _actual = deleted_ent.identifier
        _expected = sct['identifier']
        tc.assertEqual(_actual, _expected)
        tc.CONFIRM_THIS_LOOKS_LIKE_THE_DELETED_ENTITY(deleted_ent)

    def confirm_emitted_accordingly(tc):
        es = tc.end_state()
        tc.assertSequenceEqual(
                es['channel'], ('info', 'structure', 'deleted_entity'))
        _iid_s = es['identifier'].to_string()
        message = _message_from(es)
        _assert_says_identifier_probably(tc, message, _iid_s)
        tc.assertRegex(message, r'\bdeleted\b')

    def build_end_state_for_delete(tc, iid_s):
        return _end_state_for_delete_via_string(tc, iid_s)


class case_of_delete_OK_resulting_in_non_empty_collection(_common_delete):
    # #as-namespace-only

    def confirm_entity_no_longer_in_collection(tc):
        es = tc.end_state()
        iden = es['identifier']
        coll = es['collection']
        import modality_agnostic.test_support.structured_emission as se_lib
        ee = se_lib.expect(tc, ('error', 'structure', 'entity_not_found'))
        x = _do_retrieve(coll, iden, ee.listener)
        ee.ran()
        assert(x is None)


class case_of_delete_OK_resulting_in_empty_collection(_common_delete):
    # #as-namespace-only

    def confirm_the_collection_is_empty(tc):
        es = tc.end_state()
        coll = es['collection']
        _confirm_collection_empty(tc, coll)


class case_of_create_but_something_is_invalid:  # #as-namespace-only

    confirm_result_is_none = _confirm_result_is_none

    def confirm_emitted_accordingly(tc):
        es = tc.end_state()
        tc.assertSequenceEqual(
            es['channel'], ('error', 'structure', 'cannot_create'))
        reason = _reason_from(es)

        _assert_says_cannot_verb(tc, reason, 'create')

        tc.CONFIRM_THE_REASON_SAYS_WHAT_IS_WRONG_WITH_IT(reason)

    def build_end_state(tc):
        dct = tc.dictionary_for_create_with_something_invalid_about_it()
        return _end_state_for_create(tc, dct)


def _create_OK_emitted_accordingly(tc):
    es = tc.end_state()
    tc.assertSequenceEqual(
            es['channel'], ('info', 'structure', 'created_entity'))
    message = _message_from(es)
    # we don't know what ID was provisioned and meh as far as conf
    these = _find_all_identifer_looking_strings(message)
    tc.assertEqual(len(these), 1)  # ..
    tc.assertRegex(message, "^created '[A-Z1-9]+' with 2 attributes$")


def _create_OK_confirm_in_collection(tc):

    es = tc.end_state()
    ent_one = es['result_value']
    iden = ent_one.identifier
    coll = es['collection']
    ent_two = _do_retrieve(coll, iden, None)
    if ent_one != ent_two:
        dct_one = _yes_value_dict(ent_one)
        dct_two = _yes_value_dict(ent_two)
        tc.assertEqual(dct_one, dct_two)


class case_of_create_OK_into_empty_collection:  # #as-namespace-only

    def confirm_result_is_the_created_entity(tc):
        sct = tc.end_state()
        dct = _yes_value_dict(sct['result_value'])
        tc.assertEqual(dct['thing-2'], 123)
        tc.assertEqual(dct['thing-B'], 3.14)
        tc.assertEqual(len(dct), 2)

    confirm_emitted_accordingly = _create_OK_emitted_accordingly

    confirm_entity_now_in_collection = _create_OK_confirm_in_collection

    def build_end_state(tc):
        def confim_empty(coll):
            _confirm_collection_empty(tc, coll)

        dct = {'thing-2': 123, 'thing-B': 3.14}  # ..
        return _end_state_for_create(tc, dct, confim_empty)


class case_of_create_OK_into_non_empty_collection:  # #as-namespace-only

    def confirm_result_is_the_created_entity(tc):
        sct = tc.end_state()
        dct = _yes_value_dict(sct['result_value'])
        tc.assertEqual(dct['thing-2'], -2.718)
        tc.assertEqual(dct['thing-B'], False)
        tc.assertEqual(len(dct), 2)

    confirm_emitted_accordingly = _create_OK_emitted_accordingly

    confirm_entity_now_in_collection = _create_OK_confirm_in_collection

    def build_end_state(tc):
        dct = {'thing-2': -2.718, 'thing-B': False}  # ..
        return _end_state_for_create(tc, dct)


class case_of_update_but_entity_not_found:  # #as-namespace-only

    confirm_result_is_none = _confirm_result_is_none

    def confirm_emitted_accordingly(tc):
        es = tc.end_state()
        tc.assertSequenceEqual(
            es['channel'], ('error', 'structure', 'entity_not_found'))
        reason = _reason_from(es)
        _assert_says_cannot_verb(tc, reason, 'update')
        _iid_s = es['identifier'].to_string()
        _assert_says_identifier_probably(tc, reason, _iid_s)
        tc.assertIn(' not found ', reason)  # ..

    def build_end_state(tc):
        s, tup = tc.request_tuple_for_update_that_will_fail_because_no_ent()
        return _end_state_for_update(tc, tup, s)


class case_of_update_but_attribute_not_found:  # #as-namespace-only

    confirm_result_is_none = _confirm_result_is_none

    def confirm_emitted_accordingly(tc):
        es = tc.end_state()
        tc.assertSequenceEqual(
                es['channel'], ('error', 'structure', 'cannot_update'))
        reason = _reason_from(es)

        _assert_says_cannot_verb(tc, reason, 'update')

        _assert_says_identifier_probably(
                tc, reason, es['identifier'].to_string())

        tc.assertRegex(reason, r'\b(?:has no existing value|not found in entity)\b')  # noqa: E501

    def build_end_state(tc):
        iid_s, tup = tc.request_tuple_for_update_that_will_fail_because_attr()
        return _end_state_for_update(tc, tup, iid_s)


class case_of_update_OK:  # #as-namespace-only

    def confirm_result_is_before_and_after_entities(tc):
        sct = tc.end_state()
        before_ent, after_ent = sct['result_value']
        tc.assertEqual(before_ent.identifier, after_ent.identifier)
        tc.assertNotEqual(before_ent, after_ent)

    def confirm_emitted_accordingly(tc):
        es = tc.end_state()
        chan = es['channel']
        tc.assertSequenceEqual(chan, ('info', 'structure', 'updated_entity'))
        message = _message_from(es)
        tc.assertEqual(
            message,  # a big flex 👇
            "updated 'B9H' (created 1, updated 1 and deleted 1 attribute)")

    def confirm_the_before_entity_has_the_before_values(tc):
        before_ent, after_ent = tc.end_state()['result_value']
        _same_confirmation_of_before_update(tc, before_ent)

    def confirm_the_after_entity_has_the_after_values(tc):
        before_ent, after_ent = tc.end_state()['result_value']
        _same_confirmation_of_after_update(tc, after_ent)

    def confirm_retrieve_after_shows_updated_value(tc):
        es = tc.end_state()
        identi = es['identifier']
        coll = es['collection']
        ent = _do_retrieve(coll, identi, None)
        _same_confirmation_of_after_update(tc, ent)

    def build_end_state(tc):
        iid_s, tup = tc.request_tuple_for_update_that_will_succeed()
        return _end_state_for_update(tc, tup, iid_s)


# == support that helps make asssertions of states

def _same_confirmation_of_after_update(tc, after_ent):
    _ = after_ent.identifier.to_string()
    tc.assertEqual(_, 'B9H')  # might become own test
    dct = _yes_value_dict(after_ent)
    act_left = dct['thing-B']
    act_right = dct['thing-2']
    tc.assertEqual(act_left, "I'm modified \"thing-B\"")
    tc.assertEqual(act_right, "I'm created \"thing-2\"")
    tc.assertEqual(len(dct), 2)  # to confirm deletes


def _same_confirmation_of_before_update(tc, ent):
    tc.assertEqual(ent.identifier.to_string(), 'B9H')  # might become own test
    dct = _yes_value_dict(ent)
    tc.assertEqual(dct['thing-A'], "hi i'm B9H")
    tc.assertEqual(dct['thing-B'], "hey i'm B9H")
    tc.assertEqual(len(dct), 2)  # to confirm deletes in after


def _assert_says_identifier_probably(tc, reason, iid_s):
    # do the "in" test first just to get a friendly errmsg, then check count

    these = _find_all_identifer_looking_strings(reason)
    leng = len(these)
    if leng:
        tc.assertEqual(1, leng)
        return
    needle = f"'{iid_s}'"
    tc.assertIn(needle, reason)


def _find_all_identifer_looking_strings(message):
    import re
    return tuple(re.findall(r"'([A-Z0-9]{2,})'", message))  # ..


def _assert_says_cannot_verb(tc, reason, verb):
    assert(verb in ('create', 'update', 'delete'))
    _ = f"\\b(?:cannot|can't|couldn't) {verb}\\b"  # etc
    tc.assertRegex(reason, _)


def reason_via_end_state(es):
    return _message_or_reason_from('error', es)


_reason_from = reason_via_end_state


def _message_from(es):
    return _message_or_reason_from('info', es)


def _message_or_reason_from(which, es):
    from modality_agnostic import listening as lib
    severity, *rest = *es['channel'], es['payloader_CAUTION_HOT']
    if 'error' == which:
        assert('error' == severity)
        return lib.reason_via_error_emission(*rest)
    assert('info' == severity)
    return lib.message_via_info_emission(*rest)


def _confirm_collection_empty(tc, coll):
    itr = _do_to_ID_stream(coll, None)
    for iden in itr:
        tc.fail("collection was not empty.")


def _yes_value_dict(ent):
    return ent.core_attributes_dictionary_as_storage_adapter_entity


yes_value_dictionary_of = _yes_value_dict


def _identifier_via_string(s):
    from modality_agnostic import listening
    listener = listening.throwing_listener
    from kiss_rdb.magnetics_ import identifier_via_string as lib
    return lib.identifier_via_string_(s, listener)


# == support that helps set up state

# -- update

def _end_state_for_update(tc, tup, iid_s):
    def run(listener):
        return coll.update_entity_as_storage_adapter_collection(
                identifier, tup, listener)
    identifier = _identifier_via_string(iid_s)
    coll = tc.subject_collection()
    return _end_state_plus(tc, run, coll, identifier)


# -- create

def _end_state_for_create(tc, dct, with_coll=None):
    def run(listener):
        return coll.create_entity_as_storage_adapter_collection(dct, listener)
    coll = tc.subject_collection()
    if with_coll is not None:
        with_coll(coll)
    es = _end_state_via(tc, run)
    es['collection'] = coll
    return es


# -- delete

def _end_state_for_delete_via_string(tc, iid_s):
    def run(listener):
        return coll.delete_entity_as_storage_adapter_collection(iden, listener)
    iden = _identifier_via_string(iid_s)
    coll = tc.subject_collection()
    return _end_state_plus(tc, run, coll, iden)


# -- retrive

def _end_state_for_retrieve_via_string(tc, iid_s):
    ident = _identifier_via_string(iid_s)
    coll = tc.subject_collection()
    return _end_state_for_retrieve_via_identifier(tc, ident, coll)


def _end_state_for_retrieve_via_identifier(tc, iden, coll):
    def run(listener):
        return _do_retrieve(coll, iden, listener)
    return _end_state_plus(tc, run, coll, iden)


def _do_retrieve(coll, identi, listener):
    return coll.retrieve_entity_as_storage_adapter_collection(identi, listener)


def _do_to_ID_stream(coll, listener):
    return coll.to_identifier_stream_as_storage_adapter_collection(listener)


# -- support

def _end_state_plus(tc, run, coll, identifier):
    es = _end_state_via(tc, run)
    es['collection'] = coll
    es['identifier'] = identifier
    return es


def end_state_via_run(tc, run):
    listener, emissioner = _listener_and_emissioner_for(tc)
    x = run(listener)
    chan, payloader = emissioner()

    """Why we say `payloader_CAUTION_HOT` everywhere: one whole point of the
    listener interface is that payloads are not constructed unless they are
    dereferenced. This benefits both runtime and testing: often when we make
    payloads we engage complicated linguistic production with dependencies.
    A) We don't want to engage these resources and moving parts for something
    the client won't use anyway (think i18n), and B) putting the payload behind
    a getter callback allows for more focused, regression-friendly testing of
    just the payload details separate from the whole invocation.

    But A) the work that goes into assembling this payload is not typically
    cached or memoized (because yuck) and B) there is the occcasionally
    (perhaps only in antiquity) the assembly that consumes something (side-
    effectively) and so cannot be assembled more than once.

    So the trade-off to all this is that we write our tests making every
    effort to call the thing named this max once per case. Experimental.
    """

    return {
            'result_value': x,
            'channel': chan,
            'payloader_CAUTION_HOT': payloader,
            }


_end_state_via = end_state_via_run


def _listener_and_emissioner_for(tc):
    from modality_agnostic.test_support import structured_emission as se_lib
    return se_lib.listener_and_emissioner_for(tc)


def omg_omg():
    raise Exception('omg omg')

# #born.
