from sakin_agac.magnetics import (
        format_adapter_via_definition as _format_adapter,
        )
from sakin_agac import (
        cover_me,
        sanity,
        )


def _required(self, prop, x):  # ..
    if x is None:
        self._become_not_OK()
    else:
        setattr(self, prop, x)


def _new_doc_lines_via_sync(
        far_collection_reference,
        near_collection_reference,
        filesystem_functions,
        listener,
        custom_mapper_OLDSCHOOL=None,
        ):
    """here is where we bring it all together, the grand synthesis outlined

    in [#418.K].
    """

    from .magnetics import ordered_nativized_far_stream_via_far_stream_and_near_stream as lib  # noqa: E501
    from sakin_agac import my_contextlib

    def open_out(far, near):
        if not near.OK:
            return my_contextlib.empty_iterator_context_manager()
            # #provision [#418.L.2] iterate empty on failure

        _normal_far_st = far.release_normal_far_stream()
        _tagged_line_items = near.release_tagged_doc_line_item_stream()
        _far_deny_list = far.far_deny_list
        from .magnetics import synchronized_stream_via_far_stream_and_near_stream as _  # noqa: E501
        return _.OPEN_NEWSTREAM_VIA(
                normal_far_stream=_normal_far_st,
                near_tagged_items=_tagged_line_items,
                near_keyerer=near.keyerer,
                far_deny_list=_far_deny_list,
                listener=listener,
                )

    def open_near(far):
        if not far.OK:
            return my_contextlib.not_OK_context_manager()  # #coverpoint7.1
        _nrtp = far.TO_NRTP__()
        return lib.OPEN_NEAR_SESSION(
                near_relevant_traversal_parameters=_nrtp,
                near_collection_path=near_collection_reference.collection_identifier_string,  # noqa: E501
                listener=listener,
                )

    def open_far():
        return lib.OPEN_FAR_SESSION(
                cached_document_path=None,  # for testing only
                far_collection_reference=far_collection_reference,
                custom_mapper_OLDSCHOOL=custom_mapper_OLDSCHOOL,
                datastore_resources=filesystem_functions,
                listener=listener,
                )

    line_via = _liner()

    with open_far() as far, open_near(far) as near, open_out(far, near) as out:
        for k, v in out:
            line = line_via(k, v)
            if line is None:
                break  # #coverpoint5.3
            yield line


def _liner():
    """keep track of state of whether you're in a part of the document where

    the line-items are strings or not. that is all.
    """

    o = ExpectedTagOrder_()

    class _Liner:

        def __init__(self):
            self._item_is_string = o.per_current_top_item_is_string()

        def __call__(self, tag, item):
            _yes = o.matches_top(tag)
            if _yes:
                ok = True
            else:
                if 'markdown_table_unable_to_be_synced_against_' == tag:
                    ok = False  # #coverpoint5.3
                else:
                    o.pop_and_assert_matches_top(tag)
                    self._item_is_string = o.per_current_top_item_is_string()
                    ok = True
            if ok:
                if self._item_is_string:
                    result = item
                else:
                    result = item.to_line()
            else:
                result = None
            return result

    return _Liner()


def _open_fiter_request(trav_req):
    return _open_trav_request('filter', **trav_req.to_dictionary())


def _open_sync_request(trav_req):
    return _open_trav_request('sync', **trav_req.to_dictionary())


def _open_trav_request(
        intention,
        cached_document_path,
        collection_identifier,
        format_adapter,
        datastore_resources,
        listener):

    if cached_document_path is not None:
        sanity("markdown tables are always how you say 'cached'")

    from .magnetics import open_traversal_request_via_path as _
    return _.OPEN_TRAVERSAL_REQUEST_VIA_PATH(
            mixed_collection_identifier=collection_identifier,
            format_adapter=format_adapter,
            intention=intention,
            modality_resources=datastore_resources,
            listener=listener)


class ExpectedTagOrder_:
    """
    so:
      - each item is either itself a string or it's an object that exposes
        a `to_string()`. know which. (implementing __str__ is cheating)

      - "for free" we sanity check our understanding of the state machine

      - the spirit of [#411] (state machine processor thing), but
        self-contained, simpler by way of being more purpose-built.

      - abstraced from inline code above for #history-A.1
    """

    def __init__(self):
        self._stack = [
            ('tail_line', True),
            ('business_object_row', False),
            ('table_schema_line_two_of_two', False),
            ('table_schema_line_one_of_two', False),
            ('head_line', True),
        ]

    def per_current_top_item_is_string(self):
        return self._stack[-1][1]

    def pop_and_assert_matches_top(self, tag):
        self._stack.pop()
        if not self.matches_top(tag):
            cover_me('unexpected symbol here: %s' % tag)

    def matches_top(self, tag):
        return self._stack[-1][0] == tag


_functions = {
        'CLI': {
            'new_document_lines_via_sync': _new_doc_lines_via_sync,
            },
        'modality_agnostic': {
            'open_filter_request': _open_fiter_request,
            'open_sync_request': _open_sync_request,
            },
        }

FORMAT_ADAPTER = _format_adapter(
        functions_via_modality=_functions,
        associated_filename_globs=('*.md',),
        format_adapter_module_name=__name__,
        )

# #history-A.1: markdown table as producer
# #born.
