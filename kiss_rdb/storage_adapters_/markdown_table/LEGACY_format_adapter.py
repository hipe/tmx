"""LONGWINDED DISCUSSION

this module pre-dates the existence of kiss-rdb.
"""


def __new_doc_lines_via_sync(
        stream_for_sync_is_alphabetized_by_key_for_sync,
        stream_for_sync_via_stream,
        dictionaries,
        near_collection_implementation,
        near_keyerer,
        filesystem_functions,
        listener
        ):

    # #provision [#458.L.2] iterate empty on failure

    from .magnetics_.stream_for_sync_via import (
            OPEN_NEAR_SESSION, FAR_STREAM_FOR_SYNC_VIA)

    _near_path = near_collection_implementation.collection_identity.collection_path  # noqa: E501

    ns = OPEN_NEAR_SESSION(
            keyerer=near_keyerer,
            near_collection_path=_near_path,
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


def _new_doc_lines_via_sync_er(near_collection_implementation):

    def new_doc_lines_via_sync(
            stream_for_sync_is_alphabetized_by_key_for_sync,
            stream_for_sync_via_stream,
            dictionaries,
            near_keyerer,
            filesystem_functions,
            listener):

        return __new_doc_lines_via_sync(
                stream_for_sync_is_alphabetized_by_key_for_sync,
                stream_for_sync_via_stream,
                dictionaries,
                near_collection_implementation,
                near_keyerer,
                filesystem_functions,
                listener)
    return new_doc_lines_via_sync


def THING_2(*_):
    raise Exception('wahoo: _open_traversal_stream')


def __open_traversal_stream_AS_CAPABILIY(stream_request):
    _use_dict = __map_these_args(**stream_request.to_dictionary())
    return _open_traversal_stream(**_use_dict)


def __map_these_args(
        collection_identifier,
        datastore_resources,  # not used (for now)
        listener):

    # (we might do away we "capabilities" alltogether but not yet..)
    assert(isinstance(collection_identifier, str))  # ..

    return {
            'collection_path': collection_identifier,  # note name change
            'listener': listener,
            }


class LightweightCollectionJustForStreaming_:

    COLLECTION_CAPABILITIES = {
            'CLI': {
                'new_document_lines_via_sync': _new_doc_lines_via_sync_er,
                },
            'modality_agnostic': {
                'open_traversal_stream': THING_2,
                },
            }

    def __init__(self, coll_ID):
        self.collection_identity = coll_ID

    def OPEN_TRAVERSAL_STREAM__(self, listener):
        return _open_traversal_stream(
                self.collection_identity.collection_path, listener)


def _open_traversal_stream(collection_path, listener):

    from .magnetics_.markdown_table_scanner_via_lines import MarkdownTableScanner  # noqa: E501

    class ContextManager:

        def __enter__(self):
            if True:
                lines = open(collection_path)
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


def _empty_context_manager():
    from data_pipes import my_contextlib
    return my_contextlib.empty_iterator_context_manager()


# #pending-rename: magnetics_/entities_via_collection.py
# #history-A.4: no more format adapter
# #history-A.3: no more sync-side entity mapping
# #history-A.2
# #history-A.1: markdown table as producer
# #born.
