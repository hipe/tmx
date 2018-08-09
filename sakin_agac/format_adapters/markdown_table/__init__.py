from sakin_agac.magnetics import (
        format_adapter_via_definition as _format_adapter,
        )
from sakin_agac import (
        cover_me,
        pop_property,
        sanity,
        )


def _required(self, prop, x):  # ..
    if x is None:
        self._become_not_OK()
    else:
        setattr(self, prop, x)


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
            result = self.__iterate_via_sync_request()
        else:
            result = iter(())  # #provision [#410.F.2]
        return result
        # (was #coverpoint5.2 - now gone)

    def __iterate_via_sync_request(self):

        sync_request = pop_property(self, '_sync_request')

        _far_format_adapter = self._far_collection_reference.format_adapter

        _near_tagged_items = pop_property(self, '_near_tagged_items')

        o = sync_request.release_traversal_parameters()
        _dict_stream = sync_request.release_dictionary_stream()
        _nkfn = o.natural_key_field_name

        None if 2 == o.sync_parameters_version else cover_me('refa')
        _nkfn = o.natural_key_field_name
        _trav_is_ordered = o.traversal_will_be_alphabetized_by_human_key

        _sync_keyerser = o.sync_keyerser
        del(o)

        # --
        # #coverpoint6.2 (overloaded):

        use_far_stream = (x for x in _dict_stream if 'header_level' not in x)  # noqa: E501

        # #coverpoint9.1.2
        f = self._sneak_this_in
        if f is not None:
            use_far_stream = (f(x) for x in use_far_stream)
        # --

        from .magnetics import synchronized_stream_via_far_stream_and_near_stream as mag  # noqa: E501
        tagged_items = mag(
                # the streams:
                far_native_stream=use_far_stream,
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
        _x = _near_tuples_via_mixed(_nearstream_path, self._listener)
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

    _required = _required

    def _become_not_OK(self):
        self._OK = False


class _open_trav_request:
    """
    firstly:
      - when a markdown table serves as the "far collection" of a
        synchronization, things "should be" easier than when it's the "near
        collection" because we don't need to emit the before and after lines
        of the table, we just emit the lines of the table itself (actually
        rows (actually items)) sort of..

      - BUT, in order to serve as a producer for a "filter by" operation, we
        do some crazy flips to get the .. see #here2

      - (we were #[#020.3] at one point distrungtled that simple function-
        based context manager wouldn't suffice here.)

    this ended up blowing up into [#418] thoughts on collection metadata..
    """

    def __init__(
            self,
            intention,
            mixed_collection_identifier,
            modality_resources,
            format_adapter,
            listener,
            ):
        self._intention = intention
        self._mixed_collection_identifier = mixed_collection_identifier
        self._format_adapter = format_adapter
        self._listener = listener
        self._OK = True

    def __enter__(self):
        return self._format_adapter.sync_lib.SYNC_REQUEST_VIA_TWO_FUNCTIONS(
                release_sync_parameters_dictionary=self.__procure_schema_dict,
                release_dictionary_stream=self._release_dictionary_stream,
                )

    def __exit__(self, *_3):
        return False  # we did not consume the exception

    # ===

    def _release_dictionary_stream(self):
        """neat: python generators gives us a more expressive way to finish

        this peek-and-backtrack trick we usually use function pointers for.
        """

        dct = pop_property(self, '_example_row_dictionary')
        next_dict = pop_property(self, '_next_item_dictionary')
        # ..
        yield dct
        while True:
            dct = next_dict()
            if dct is None:
                break
            yield dct

    def __procure_schema_dict(self):
        self.__resolve_tuple_iterator()
        self._OK and self.__init_via_tuple_iterator()
        self._OK and self.__advance_over_head_lines()
        self._OK and self.__advance_over_the_schema_row_resolve_field_names()
        if self._OK:
            return self.__advance_past_the_example_row_procure_schema_item()

    def __advance_past_the_example_row_procure_schema_item(self):
        self._next_item_dictionary = self.__flush_main_stepper()
        dct = self._next_item_dictionary()
        if dct is None:
            cover_me("no example row (so empty table) - that's OK but etc")

        field_names = pop_property(self, '_field_names')
        ok, tlfn = _tag_lyfe_field_names_hack(
                dct, self._intention, self._listener)
        if not ok:
            return
        _nkfn = field_names[0]  # for now, hardcoded as this [#408.C.2]
        self._example_row_dictionary = dct
        return {
                '_is_sync_meta_data': True,
                'natural_key_field_name': _nkfn,
                'field_names': field_names,
                'tag_lyfe_field_names': tlfn,
                }

    def __advance_over_the_schema_row_resolve_field_names(self):
        tup = self._next_tuple()
        if tup is None:
            cover_me('table with header row but not schema row')
        tag, head_line_two_of_two = tup
        self._ETO.pop_and_assert_matches_top(tag)
        self._field_names = head_line_two_of_two.complete_schema.field_names__

        # nasty: if you do this here, it advances the state of the sanity
        # checker thing now and we don't have to mess with state changes in
        # our main loop
        self._ETO.pop_and_assert_matches_top('business_object_row')

    def __advance_over_head_lines(self):
        # traverse along each line of the md file till you find table line 1
        self._OK = False  # nonstandard trick ..
        o = self._ETO
        for tag, item in self._tuple_iterator:
            if not o.matches_top(tag):
                o.pop_and_assert_matches_top(tag)
                # tag is 'table_schema_line_one_of_two' can toss because #here3
                self._OK = True
                break
        if not self._OK:
            cover_me('beginning of markdown table never found')

    def __flush_main_stepper(self):

        dict_via_row_dom = _dict_via_row_dom(self._field_names)
        next_tuple = pop_property(self, '_next_tuple')
        eto = pop_property(self, '_ETO')

        def f():
            nonlocal next_tuple
            tup = next_tuple()
            if tup is None:
                # #coverpointTL.1.5.1.2:
                # table was last thing in file and that's OK
                next_tuple = None  # sanity
            else:
                tag, row_dom = tup
                if eto.matches_top(tag):
                    return dict_via_row_dom(row_dom)
                else:
                    next_tuple = None  # sanity
        return f

    def __init_via_tuple_iterator(self):
        self._ETO = _ExpectedTagOrder()
        from modality_agnostic import streamlib as _
        self._next_tuple = _.next_or_noner(self._tuple_iterator)

    def __resolve_tuple_iterator(self):
        _id = pop_property(self, '_mixed_collection_identifier')
        _ = _near_tuples_via_mixed(_id, self._listener)
        self._required('_tuple_iterator', _)

    _required = _required

    def _become_not_OK(self):
        self._OK = False


def _tag_lyfe_field_names_hack(dct, intention, listener):
    """as an answer to the problem introduced in [#418.2] ("whether to be a

    jack of all trades"), we introduced the idea of "intention" as a soft
    hint for what this traversal is for.

    for the sake of consistency and failing early and at a cost of a
    negligible amount of extra work, we do this hack whether or not we are
    doing a filter by, a sync or whatever..

    .:#here2:
    """

    these = tuple(k for k in dct.keys() if '#' in dct[k])
    result = these if len(these) else None

    if 'filter' == intention:
        if result is None:
            __whine_about_no_whatever(dct, listener)
            return False, None
        else:
            return True, result
    elif 'sync' == intention:
        return True, result
    else:
        sanity()


def __whine_about_no_whatever(dct, listener):  # #coverpointTL.1.5.1.1

    import script_lib.magnetics.ellipsified_string_via as _
    ellipsis_join = _.complicated_join

    def msg_f():
        yield "your example row needs at least one cel with a hashtag in it."
        yield ellipsis_join('(had: ', ', ', ')', dct.values(), 80, repr)
    listener('error', 'expression', 'no_tag_lyfe_field_names', msg_f)


def _dict_via_row_dom(field_names):
    def f(dom):
        _r = range(0, dom.cels_count)
        _pairs = ((i, dom.cel_at_offset(i).content_string()) for i in _r)
        # #[#410.13] where sparseness is implemented #coverpoint13.2:
        return {field_names[t[0]]: t[1] for t in _pairs if len(t[1])}
    return f


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


def _near_tuples_via_mixed(mixed, listener):
    from .magnetics import tagged_native_item_stream_via_line_stream as f
    return f(mixed, listener)


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
            'open_new_lines_via_sync': _open_new_lines_via_sync,
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
