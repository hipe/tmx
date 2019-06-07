"""
This was #born at the birth of breaking the package up into an actual plugin/
dependency-injection thing with multiple storage adapters.

Its objective is to offer a rough "compatibility check" test suite so that
  - we aren't duplicating the work of redundantly coming up anew
    with cases for each new storage adapter
  - we can have some assurance and peace of mind that a given storage adapter
    meets some minimum standard of completeness

We take into account:
  - the [#867] entities CUD roadmap,
  - the [#868] CUD entities number allocation, which will change now #todo


.## "constants" for our below desciptions of cases
  - "N" is 8 for now


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
    - CASE: entity not found because mal-formed identifier
    - CASE: entity not found (identifier OK)
    - CASE: entity found

- Collection-mutation:

  - Delete entity:
    - CASE: entity not found
    - CASE: Delete OK resulting in non-empty collection
    - CASE: Delete OK resulting in empty collection

  - Create entity:
    - CASE: won't create because invalid somehow
    - CASE: create OK #edit

  - Update entity:
    - CASE: entity not found
    - CASE: #todo there are lots of cases for attribute CUD
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


class case_of_collection_not_found:  # #as-namespace-only

    def confirm_result_is_none(test_case):
        end_state = test_case.end_state()
        test_case.assertIsNone(end_state['result_value'])

    def confirm_emitted_accordingly(test_case):
        end_state = test_case.end_state()
        test_case.assertSequenceEqual(
            end_state['channel'],
            ('error', 'structure', 'collection_not_found'))

        reason = end_state['payloader_CAUTION_HOT']()['reason']
        test_case.assertRegex(reason, r'^collection not found: [\[a-zA-Z0-9]')


class case_of_empty_collection_found:  # #as-namespace-only

    def confirm_result_is_not_none(test_case):
        test_case.assertIsNotNone(test_case.subject_collection())


class case_of_non_empty_collection_found:  # #as-namespace-only

    def confirm_result_is_not_none(test_case):  # #copy-pasted
        test_case.assertIsNotNone(test_case.subject_collection())


class case_of_traverse_IDs_from_non_empty_collection:  # #as-namespace-only

    def confirm_all_IDs_in_any_order_no_repeats(tc):
        _sc = tc.subject_collection()  # similar to #here1
        _iids = _sc.to_identifier_stream_as_storage_adapter_collection()
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
        _actual = ent.yes_value_dictionary['thing-A']
        tc.assertEqual(_actual, "hi i'm B9H")

    def confirm_featherweighting_isnt_biting(tc):
        _tup = tc.flattened_collection_for_traversal_case()
        these = ('B8H', 'B7G')
        itr = (ent for ent in _tup if ent.identifier.to_string() in these)
        left = next(itr)
        right = next(itr)
        tc.assertNotEqual(left.identifier.to_string(),
                          right.identifier.to_string())
        tc.assertFalse(left.yes_value_dictionary is right.yes_value_dictionary)


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
    _sc = tc.subject_collection()  # similar to #here1
    _ents = _sc.to_entity_stream_as_storage_adapter_collection()
    return tuple(_ents)


def omg_omg():
    raise Exception('omg omg')

# #born.
