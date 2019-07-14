"""(abstracted.)"""


def build_state_the_bernstein_way(fixture_document_path, producer_module):
    """
    given a fixture document path and a producer module (usually script),

    produce an end-state of commonly tested-against summary information.

    we assume the provisions:
      - the human key field name of the formal record is called 'name'
      - the values (names) tha occur in this field look like markdown
        links (e.g "[Foo Bar 12](gopher://foo.edu)")

    the produced end state has as properties (at least):
      - a dictionary with every business record (dictionary, also)
        keyed to a lossy, simplified representation of the business
        item name.
    """

    emissions = []

    import modality_agnostic.test_support.listener_via_expectations as lib

    # use_listener = lib.for_DEBUGGING (works)
    use_listener = lib.listener_via_emission_receiver(emissions.append)

    """NOTE - we don't pass the first argument below as a named parameter
    because we can't: what that (required) parameter is named is currently
    indeterminable (that is, not governed by spec) because we want it to
    accord (make sense) with the particular script's assisting format
    adapter (e.g it might be called `html_document_path`, it might be called
    `markdown_path`). at writing (file birth), this file engages with
    producer scripts that serve both these associated format adapters.
    """

    _open_traversal_stream = producer_module.open_traversal_stream(
            fixture_document_path,  # {html_document_path|markdown_path}, e.g
            listener=use_listener)

    def fuzzy_key(dct):
        return simplified_key_via_markdown_link(dct['name'])
    from script.markdown_document_via_json_stream import (
            simplified_key_via_markdown_link_er as _,
            )
    simplified_key_via_markdown_link = _()

    with _open_traversal_stream as dcts:
        head_dct = next(dcts)
        objs = {fuzzy_key(dct): dct for dct in dcts}

    assert(1 == len(emissions))
    # this wasn't the point of the test but if we trip this, make a case for it

    class _State:
        def __init__(self, _1, _2):
            self.head_dictionary = _1
            self.business_object_dictionary = _2

    return _State(head_dct, objs)


# #abstracted.
