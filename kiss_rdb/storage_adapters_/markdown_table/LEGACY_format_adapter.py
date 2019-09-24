# #[#874.9] file is LEGACY

from kiss_rdb import (
        LEGACY_format_adapter_via_definition as _format_adapter)


def _new_doc_lines_via_sync(**kwargs):
    return __do_new_doc_lines_via_sync(**kwargs)


def __do_new_doc_lines_via_sync(
        stream_for_sync_is_alphabetized_by_key_for_sync,
        stream_for_sync_via_stream,
        dictionaries,
        near_collection_reference,
        near_keyerer,
        filesystem_functions,
        listener
        ):

    # #provision [#458.L.2] iterate empty on failure

    from .magnetics_.stream_for_sync_via import (
            OPEN_NEAR_SESSION, FAR_STREAM_FOR_SYNC_VIA)

    ns = OPEN_NEAR_SESSION(
            keyerer=near_keyerer,
            near_collection_path=near_collection_reference.collection_identifier_string,  # noqa: E501
            listener=listener)

    if not ns:
        raise Exception('cover me')  # #open [#876] cover me (below lies)
        return _empty_context_manager()  # (Case1314DP)

    # something about version number and (Case1319DP) gone at #history-A.3

    far = FAR_STREAM_FOR_SYNC_VIA(
            stream_for_sync_is_alphabetized_by_key_for_sync,
            stream_for_sync_via_stream,
            dictionaries, listener)

    def open_out(near):
        _tagged_line_items = near.release_tagged_doc_line_item_stream()
        from .magnetics_.synchronized_stream_via_far_stream_and_near_stream import (  # noqa: E501
                OPEN_NEWSTREAM_VIA)
        return OPEN_NEWSTREAM_VIA(
                normal_far_stream=far,
                near_tagged_items=_tagged_line_items,
                near_keyerer=near.keyerer,
                listener=listener)

    line_via = _liner()

    with ns as near, open_out(near) as out:
        for k, v in out:
            line = line_via(k, v)
            if line is None:
                break  # (Case2664DP)
            yield line


def _liner():
    """eep track of state of whether you're in a part of the document where

    the line-items are strings or not. that is all.
    """

    o = ExpectedTagOrder_()

    class _Liner:

        def __init__(self):
            self._item_is_string = o.per_current_top_item_is_string()

        def __call__(self, tag, item):

            _matched = o.matches_top(tag)
            if not _matched:
                if 'markdown_table_unable_to_be_synced_against_' == tag:
                    return  # (Case2664DP)
                o.pop_and_assert_matches_top(tag)
                self._item_is_string = o.per_current_top_item_is_string()

            if self._item_is_string:
                return item

            return item.to_line()

    return _Liner()


def _open_traversal_stream(stream_request):
    return __open_traversal_stream(**stream_request.to_dictionary())


def __open_traversal_stream(
        collection_identifier, cached_document_path,
        format_adapter,  # not used
        datastore_resources,  # not used (for now)
        listener):

    assert(not cached_document_path)
    # markdown tables always live in the filesystem (at writing #history-A.1),
    # never from (internet) urls so, in this sense they are already "cached"
    # so they should never be literally cached. All of this is away soon.

    from .magnetics_.markdown_table_scanner_via_lines import MarkdownTableScanner  # noqa: E501

    class ContextManager:

        def __enter__(self):
            assert(isinstance(collection_identifier, str))  # ..
            if True:
                lines = open(collection_identifier)
                self._exit_me = lines

            scn = MarkdownTableScanner(
                    lines=lines,
                    do_parse_example_row=False,
                    listener=listener)

            if scn.is_empty:
                raise Exception('cover me: empty file?')

            while 'head_line' == scn.peeked_AST_symbol:
                scn.advance()

            if scn.is_empty:
                raise Exception('cover me: file has no table?')

            assert('table_schema_from_two_lines' == scn.peeked_AST_symbol)

            scn.advance()
            while not scn.is_empty:
                if not 'business_object_row' == scn.peeked_AST_symbol:
                    break
                yield scn.peeked_AST
                scn.advance()

            while not scn.is_empty:
                assert('tail_line' == scn.peeked_AST_symbol)
                scn.advance()

        def __exit__(self, *_3):
            o = self._exit_me
            del self._exit_me
            return o.__exit__(*_3)

    return ContextManager()


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
            raise Exception(f'cover me: unexpected symbol here: {tag}')

    def matches_top(self, tag):
        return self._stack[-1][0] == tag


_functions = {
        'CLI': {
            'new_document_lines_via_sync': _new_doc_lines_via_sync,
            },
        'modality_agnostic': {
            'open_traversal_stream': _open_traversal_stream,
            },
        }


def _empty_context_manager():
    from data_pipes import my_contextlib
    return my_contextlib.empty_iterator_context_manager()


# == in oldentimes, this file was __init__.py probably. then, #history-A.2
s = __name__
_use_name = s[0:s.rindex('.')]  # like "dirname"
# ==


FORMAT_ADAPTER = _format_adapter(
        functions_via_modality=_functions,
        associated_filename_globs=('*.md',),
        format_adapter_module_name=_use_name,
        )

# #history-A.3: no more sync-side entity mapping
# #history-A.2
# #history-A.1: markdown table as producer
# #born.
