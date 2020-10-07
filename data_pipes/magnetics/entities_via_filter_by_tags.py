"""
Filter the stream of entities by looking for hashtag-like markup in
certain of its cels. E.g.: \\( "#open" and not "#cosmetic" \\) or "#critical"

  - we once had a feature where you could indicate which "fields" to look
    in for tags, but we removed it at #history-A.1 for lack of necessity.

every feature of the query grammar:

  - search for rows containing the tag by expressing the tag name, eg. `#red`
  - taggings can look like name-value pairs: `#priority:urgent`
  - but taggings can be arbitrarily deep: `#priority:urgent:right-now`
  - co-join matcher-expressions with `and` or `or`: `#red and #blue`
  - nest with parentheses: `#red or #blue or ( #pink and #brown )`
  - negate with `not`: `#red and not #blue`
  - example of "values" plus boolean conjuction: `#code:red or #code:pink`
  - shorthand for above: `#code in ( red pink )`
  - regex: `#full-name in /^Kim Jong-/`
  - range: `#age in 33..44` (experiment, not very useful yet because no ∞)
  - find tags of a certain name with no value-ish: `#age without value`
  - find tags of a certain name that do have a value-ish: `#urgent with value`

NOTEs about its adapation to CLI:

  - the above examples do not illustrate formally one important dimension:
    the query as entered into the shell must be broken up into "shell words"
    in the correct way.

  - it is mostly intuitive, and mostly follows from our use of spaces in the
    above examples. for example `#red and #blue` must be three arguments,
    not one.

  - however, regexp expressions must be one word, even (especially when)
    they contain spaces (like `/^Kim Jong-/` above).

  - '(' and ')' must be their own "words" (tokens), so use a space after and
    before them (this is exactly as the use of parenthesis in unix `find`.)

  - so, because most shells give special expansion to parenthesis and use
    `#` as a comment marker (in certain contexts), we escape these with
    backslashes or put them in quotes when entering via our shell.
"""


def stats_future_and_results_via_entity_stream_and_query(ents, q):

    from tag_lyfe.magnetics.tagging_subtree_via_string import \
        doc_pairs_via_string

    count_of_items_that_did_not_match = 0
    count_of_items_that_matched = 0
    count_of_items_that_did_not_have_taggings = 0
    count_of_items_that_had_taggings = 0

    def future():
        return {
                'count_of_items_that_did_not_match': count_of_items_that_did_not_match,  # noqa: E501
                'count_of_items_that_matched': count_of_items_that_matched,
                'count_of_items_that_did_not_have_taggings': count_of_items_that_did_not_have_taggings,  # noqa: E501
                'count_of_items_that_had_taggings': count_of_items_that_had_taggings,  # noqa: E501
                }

    yield future

    def these_keys_via_dictionary(dct):
        return dct.keys()

    for entity in ents:
        dct = entity.core_attributes_dictionary_as_storage_adapter_entity
        taggings = None
        _use_keys = these_keys_via_dictionary(dct)
        for k in _use_keys:
            top_thing = doc_pairs_via_string(dct[k])
            pairs = top_thing.doc_pairs
            if 1 == len(pairs) and pairs[0].tag is None:
                continue  # no taggings in that cel content
            if taggings is None:
                taggings = []
            for pair in pairs:
                if (tag := pair.tag) is None:
                    continue
                taggings.append(tag)

        if taggings is None:
            count_of_items_that_did_not_have_taggings += 1
            use_taggings = ()
        else:
            count_of_items_that_had_taggings += 1
            use_taggings = taggings

        _yes = q.yes_no_match_via_tag_subtree(use_taggings)
        if _yes:
            count_of_items_that_matched += 1
            yield entity
        else:
            count_of_items_that_did_not_match += 1


def prepare_query(tokens, listener=None):
    from tag_lyfe.magnetics import query_via_token_stream
    assert(len(tokens))
    big_string = _NULL_BYTE.join(tokens)
    itr = query_via_token_stream.MAKE_CRAZY_ITERATOR_THING(big_string)
    wat = next(itr)
    assert(wat)  # "TopThing" generated by tatsu
    _unsani = next(itr)
    for _ in itr:
        assert(False)
    q = _unsani.sanitize(listener)
    if q is None:
        return

    result_string = q.to_string()
    before_len = len(big_string)
    after_len = len(result_string)
    if before_len == after_len:
        return q

    assert(_NULL_BYTE == big_string[after_len])
    tokens = big_string[after_len + 1:].split(_NULL_BYTE)

    def payloader():
        return {
                'reason': f"unexpected token '{tokens[0]}'",
                'position': 0,
                'line': ' '.join(tokens),
                }
    listener('error', 'structure', 'parse_error', payloader)


_NULL_BYTE = '\0'  # NULL_BYTE_

# #history-A.1: rewrite, re-house
# #born.
