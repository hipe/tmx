"""(abstracted.)"""

from sakin_agac import (
        sanity,
        )


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

    _open_dictionary_stream = producer_module.open_dictionary_stream(
            fixture_document_path,  # {html_document_path|markdown_path}, e.g
            listener=use_listener,
            )

    def fuzzy_key(dct):
        """my hands look like this "[Foo Fa 123](bloo blah)"

        so hers can look like this "foo_fa_123"
        #abstraction-candidate (for business)
        """
        _md = rx.search(dct['name'])
        return normal_key(_md.group(1))
    import re
    rx = re.compile(r'^\[([A-Za-z][a-zA-Z0-9 ]+)\]\(')
    import sakin_agac.magnetics.normal_field_name_via_string as normal_key

    with _open_dictionary_stream as dcts:
        head_dct = next(dcts)
        objs = {fuzzy_key(dct): dct for dct in dcts}

    if 1 != len(emissions):
        sanity("(this wasn't the point of the test (but if it becomes one..)")
        # .. if it becomes something that is covered in a test, etc

    class _State:
        def __init__(self, _1, _2):
            self.head_dictionary = _1
            self.business_object_dictionary = _2

    return _State(head_dct, objs)


# #abstracted.
