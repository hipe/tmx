from sakin_agac.magnetics import (
        format_adapter_via_definition as _format_adapter,
        )
from sakin_agac import (
        cover_me,
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
        from .magnetics import synchronized_stream_via_far_stream_and_near_stream as _  # noqa: E501
        return _.OPEN_NEWSTREAM_VIA(
                normal_far_stream=_normal_far_st,
                near_tagged_items=_tagged_line_items,
                near_keyerer=near.keyerer,
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
                far_collection_reference=far_collection_reference,
                custom_mapper_OLDSCHOOL=custom_mapper_OLDSCHOOL,
                filesystem_functions=filesystem_functions,
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


def _open_trav_request(*_):
    from .magnetics import open_traversal_request_via_path
    return open_traversal_request_via_path.OPEN_TRAVERSAL_REQUEST_VIA_PATH(*_)


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


# --

def simplified_key_via_markdown_link_er():
    """the only reason this is a function that builds a function (instead

    of just a function) is so we lazy-(ish)-load the dependency modules.
    one place this is covered is *as* test support under #coverpoint13.
    which makes this also a #testpoint.
    this is nowhere near #html2markdown except that it crudely parses
    a tiny sub-slice of markdown.
    """

    def simplified_key_via_markdown_link(markdown_link_string):
        """my hands look like this "[Foo Fa 123](bloo blah)"

        so hers can look like this "foo_fa_123"
        """

        md = first_pass_rx.search(markdown_link_string)
        if md is None:
            _tmpl = 'failed to parse as markdown link - %s'
            cover_me(_tmpl % markdown_link_string)

        return normal_via_str(md.group(1))

    import re
    first_pass_rx = re.compile(r'^\[([^]]+)\]\([^\)]*\)$')
    import sakin_agac.magnetics.normal_field_name_via_string as normal_via_str
    return simplified_key_via_markdown_link


# --

_functions = {
        'CLI': {
            'new_document_lines_via_sync': _new_doc_lines_via_sync,
            },
        'modality_agnostic': {
            'open_filter_request': lambda *a: _open_trav_request('filter', *a),
            'open_sync_request': lambda *a: _open_trav_request('sync', *a),
            },
        }

FORMAT_ADAPTER = _format_adapter(
        functions_via_modality=_functions,
        associated_filename_globs=('*.md',),
        format_adapter_module_name=__name__,
        )

# #history-A.1: markdown table as producer
# #born.
