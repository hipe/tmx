from sakin_agac.magnetics import (
        format_adapter_via_definition as _format_adapter,
        )
from sakin_agac import (
        cover_me,
        pop_property,
        )


class _open_new_lines_via_sync:

    def __init__(
            self,
            far_collection_reference,
            near_collection_reference,
            filesystem_functions,
            listener,
            sneak_this_in=None,
            ):
        self._close_me_stack = []
        self._OK = True
        self._mutex = None
        self._near_collection_reference = near_collection_reference
        self._far_collection_reference = far_collection_reference
        self._sneak_this_in = sneak_this_in
        self._filesystem_functions = filesystem_functions
        self._listener = listener

    def __enter__(self):
        # (experimentally we do all work on enter, none on construction)

        del(self._mutex)
        self._OK and self.__resolve_sessioner()
        self._OK and self.__resolve_sync_request()
        self._OK and self.__resolve_near_tagged_items()
        if self._OK:
            _ = self.__iterate_via_sync_request()
            return _  # #todo
        else:
            return iter(())  # #provision [#410.F.2]
        # (was #coverpoint5.2 - now gone)

    def __iterate_via_sync_request(self):

        sync_request = pop_property(self, '_sync_request')

        _far_format_adapter = self._far_collection_reference.format_adapter

        _near_tagged_items = pop_property(self, '_near_tagged_items')

        sp = sync_request.release_sync_parameters()
        _dict_stream = sync_request.release_dictionary_stream()
        _nkfn = sp.natural_key_field_name

        None if 2 == sp.sync_parameters_version else cover_me('refa')
        _nkfn = sp.natural_key_field_name
        _trav_is_ordered = sp.traversal_will_be_alphabetized_by_human_key

        _sync_keyerser = sp.sync_keyerser
        del(sp)

        # --
        # #coverpoint6.2 (overloaded):

        use_far_dict_stream = (x for x in _dict_stream if 'header_level' not in x)  # noqa: E501

        # #coverpoint9.1.2
        f = self._sneak_this_in
        if f is not None:
            use_far_dict_stream = (f(x) for x in use_far_dict_stream)
        # --

        from .magnetics import newstream_via_farstream_and_nearstream as mag
        tagged_items = mag(
                # the streams:
                far_dictionary_stream=use_far_dict_stream,
                near_tagged_items=_near_tagged_items,

                # the sync parameters:
                natural_key_field_name=_nkfn,
                farstream_format_adapter=_far_format_adapter,
                far_traversal_is_ordered=_trav_is_ordered,

                listener=self._listener,
                sync_keyerser=_sync_keyerser,
                )

        o = _ExpectedTagOrder()
        item_is_string = o.per_current_top_item_is_string()

        for tag, item in tagged_items:

            _yes = o.matches_top(tag)
            if not _yes:
                if 'markdown_table_unable_to_be_synced_against_' == tag:
                    # #coverpoint5.3
                    break
                o.pop_and_assert_matches_top(tag)
                item_is_string = o.per_current_top_item_is_string()

            if item_is_string:
                yield item
            else:
                yield item.to_line()

    def __resolve_near_tagged_items(self):
        _nearstream_path = self._near_collection_reference.collection_identifier_string  # noqa: E501
        _x = _near_tagged_items_via_mixed(_nearstream_path, self._listener)
        self._required('_near_tagged_items', _x)

    def __resolve_sync_request(self):
        # (#coverpoint7.1 is failure)

        cm = pop_property(self, '_sessioner')
        self._close_me_stack.append(cm)
        _ = cm.__enter__()
        self._required('_sync_request', _)

    def __resolve_sessioner(self):
        _ = self._far_collection_reference.open_sync_request(
                self._filesystem_functions, self._listener)

        # (sessioner false is #coverpoint5.10
        self._required('_sessioner', _)

    def __exit__(self, *_):
        while 0 != len(self._close_me_stack):
            _cm = self._close_me_stack.pop()
            _cm.__exit__(*_)
            """don't pass exception (for now) because confusing.
            result is ignored because confusing.
            #[#410.G] (track nested context managers closing each other)
            #coverpoint7.3
            """
        return False  # never trap exceptions

    def _required(self, prop, x):  # ..
        if x is None:
            self._OK = False
        else:
            setattr(self, prop, x)


class _open_sync_request:
    """.#[#020.3]."""

    def __init__(
            self,
            mixed_collection_identifier,
            modality_resources,
            format_adapter,
            listener,
            ):
        self._mixed_collection_identifier = mixed_collection_identifier
        self._format_adapter = format_adapter
        self._listener = listener

    def __enter__(self):
        """reading from a markdown table when it's serving as a producer

        is simpler than when it's the "near" side of a synchronization;
        because here we only care about emitting the lines of the markdown
        table themselves, not the lines before and after..
        """

        tagged_items = _near_tagged_items_via_mixed(
                self._mixed_collection_identifier, self._listener)

        o = _ExpectedTagOrder()

        # advance past the head cruft

        for tag, item in tagged_items:
            if not o.matches_top(tag):
                o.pop_and_assert_matches_top(tag)
                break

        # (item is now (normally) head line one of two. here we ignore it.)

        tag, head_line_two_of_two = next(tagged_items)  # ..
        o.pop_and_assert_matches_top(tag)

        field_names = head_line_two_of_two.complete_schema.field_names__

        def sync_params():
            # for now, this is not configurable. your first column must be it
            return {
                    '_is_sync_meta_data': True,
                    'natural_key_field_name': field_names[0],
                    'field_names': field_names,
                    }

        def dict_stream():
            # now, you normally have TWO state transitions to go through
            # (so, three states): state: at second header line.
            # state: business row lines. state: tail lines

            def f():
                o.pop_and_assert_matches_top(tag)
                nonlocal f
                f = main
                return f()

            def main():
                if o.matches_top(tag):
                    return (True, item)
                else:
                    nonlocal f
                    f = None
                    return (False, None)

            for tag, item in tagged_items:
                yes, x = f()
                if yes:
                    yield dict_via_row_dom(x)
                else:
                    break

        def dict_via_row_dom(dom):
            _r = range(0, dom.cels_count)
            _pairs = ((i, dom.cel_at_offset(i).content_string()) for i in _r)
            # #[#410.M] where sparseness is implemented #coverpont13.2:
            return {field_names[t[0]]: t[1] for t in _pairs if len(t[1])}

        return self._format_adapter.sync_lib.SYNC_REQUEST_VIA_TWO_FUNCTIONS(
                release_sync_parameters=sync_params,
                release_dictionary_stream=dict_stream,
                )

    def __exit__(self, *_3):
        return False  # we did not consume the exception


class _ExpectedTagOrder:
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


def _near_tagged_items_via_mixed(mixed, listener):
    from .magnetics import tagged_native_item_stream_via_line_stream as f
    return f(mixed, listener)


# --

_functions = {
        'CLI': {
            'open_new_lines_via_sync': _open_new_lines_via_sync,
            },
        'modality_agnostic': {
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
