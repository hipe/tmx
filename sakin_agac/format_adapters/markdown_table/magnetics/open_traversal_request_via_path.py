"""
firstly:
  - when a markdown table serves as the "far collection" of a synchronization,
    things "should be" easier than when it's the "near collection" because we
    don't need to emit the before and after lines of the table, we just emit
    the lines of the table itself (actually rows (actually items)) sort of..

  - BUT, in order to serve as a producer for a "filter by" operation, we
    need to know what fields are participating "tag lyfe" fields (#here2)

  - (we were #[#020.3] at one point distrungtled that simple function-
    based context manager wouldn't suffice here.)

this ended up blowing up into [#418] thoughts on collection metadata..
"""

from sakin_agac import (
        cover_me,
        pop_property,
        sanity,
        )


class OPEN_TRAVERSAL_REQUEST_VIA_PATH:  # #coverpoint13.2
    """exercise #pattern [#418.Z.2]: separate context manager from work"""

    def __init__(
            self,
            intention,
            mixed_collection_identifier,
            format_adapter,
            modality_resources,
            listener
            ):

        import contextlib
        es = contextlib.ExitStack()

        def enter():
            _doc_items = es.enter_context(open_doc_items())
            tup = _main_work(_doc_items, intention, listener)
            arg1, arg2 = _normalize_final_args(tup)

            import sakin_agac.magnetics.synchronized_stream_via_far_stream_and_near_stream as _  # noqa: E501
            return _.SYNC_RESPONSE_VIA_TWO_FUNCTIONS(
                release_sync_parameters_dictionary=arg1,
                release_dictionary_stream=arg2,
                )

        def exit(*_):
            return es.__exit__(*_)

        def open_doc_items():
            from . import tagged_native_item_stream_via_line_stream as _  # noqa: E501
            return _.OPEN_TAGGED_DOC_LINE_ITEM_STREAM(mixed_collection_identifier, listener)  # noqa: E501

        self._enter = enter
        self._exit = exit
        self._OK = True

    def __enter__(self):
        return pop_property(self, '_enter')()

    def __exit__(self, *_):
        return pop_property(self, '_exit')(*_)


def _normalize_final_args(tup):  # (just glue)

    mut = _ExperimentalMutexer()

    if tup is None:

        def use_release_sync_parameters_dictionary():
            mut.only_once_ever()

        use_release_dictionary_stream = None
    else:
        wow_re_wrap_stream, schema_dct = tup
        mut2 = _ExperimentalMutexer()

        def use_release_sync_parameters_dictionary():
            mut.only_once_ever()
            return schema_dct

        def use_release_dictionary_stream():
            mut2.only_once_ever()  # OCD
            return wow_re_wrap_stream()

    return (use_release_sync_parameters_dictionary,
            use_release_dictionary_stream)


def _main_work(doc_line_items, intention, listener):

    from modality_agnostic import streamlib as _
    next_doc_line_item = _.next_or_noner(doc_line_items)

    import sakin_agac.format_adapters.markdown_table as _
    eto = _.ExpectedTagOrder_()

    _ok = __advance_over_head_lines(doc_line_items, eto)
    if not _ok:
        return

    field_names = __advance_over_schema_row_procure_field_names(next_doc_line_item, eto)  # noqa: E501
    if field_names is None:
        return

    next_item_dictionary = __main_stepper(next_doc_line_item, field_names, eto)

    eg_dct = next_item_dictionary()
    if eg_dct is None:
        cover_me("no example row (so empty table) - that's OK but etc")

    ok, tlfn = __tag_lyfe_field_names_hack(eg_dct, intention, listener)
    if not ok:
        return

    schema_dct = __build_schema_dictionary(tlfn, field_names)

    def wow_re_wrap_stream():
        # neat: python generators gives us a more expressive way to finish
        # this peek-and-backtrack trick we usually use function pointers for.

        yield eg_dct
        while True:
            dct = next_item_dictionary()
            if dct is None:
                break
            yield dct

    return wow_re_wrap_stream, schema_dct


# ==

def __build_schema_dictionary(tlfn, field_names):

    _nkfn = field_names[0]  # for now, hardcoded as this [#418.I.2]
    return {
            '_is_sync_meta_data': True,
            'natural_key_field_name': _nkfn,
            'field_names': field_names,
            'tag_lyfe_field_names': tlfn,
            }


def __advance_over_schema_row_procure_field_names(next_doc_line_item, eto):

    tup = next_doc_line_item()
    if tup is None:
        cover_me('table with header row but not schema row')

    tag, head_line_two_of_two = tup
    eto.pop_and_assert_matches_top(tag)
    field_names = head_line_two_of_two.complete_schema.field_names__

    # nasty: if you do this here, it advances the state of the sanity
    # checker thing now and we don't have to mess with state changes in
    # our main loop
    eto.pop_and_assert_matches_top('business_object_row')

    return field_names


def __advance_over_head_lines(doc_line_items, eto):
    """traverse along each line of the md file till you find table line 1"""

    ok = False
    for tag, item in doc_line_items:
        if not eto.matches_top(tag):
            eto.pop_and_assert_matches_top(tag)
            # tag is 'table_schema_line_one_of_two', can toss
            ok = True
            break
    if ok:
        return True
    else:
        cover_me('beginning of markdown table never found')


# ==

def __tag_lyfe_field_names_hack(dct, intention, listener):
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


# ==

def __main_stepper(next_doc_line_item, field_names, eto):
    """step over each item (row (line)) in the markdown table.

    as you encounter each item, convert it to a dictionary.
    stop when (any of):
      - you reach the end of the file
      - you reach the end of the table (but not file)
    """

    dict_via_row_dom = __dict_via_row_dom(field_names)

    def f():
        check_mutex()
        result = None
        pair = next_doc_line_item()
        if pair is None:
            # #coverpointTL.1.5.1.2:
            # table was last thing in file and that's OK
            close_mutex()
        else:
            tag, row_dom = pair
            if eto.matches_top(tag):
                result = dict_via_row_dom(row_dom)
            else:
                close_mutex()
        return result

    mut = _ExperimentalMutexer()
    check_mutex = mut.check_mutex
    close_mutex = mut.close_mutex

    return f


def __dict_via_row_dom(field_names):
    def f(dom):
        _r = range(0, dom.cels_count)
        _pairs = ((i, dom.cel_at_offset(i).content_string()) for i in _r)
        # #[#410.13] where sparseness is implemented #coverpoint13.2:
        return {field_names[t[0]]: t[1] for t in _pairs if len(t[1])}
    return f


class _ExperimentalMutexer:

    def __init__(self):
        self._is_closed = False
        self._meta_mutex = None

    def only_once_ever(self):
        self.check_mutex()
        self.close_mutex()

    def close_mutex(self):
        pop_property(self, '_meta_mutex')
        self._is_closed = True

    def check_mutex(self):
        if self._is_closed:
            sanity()

# #abstracted.
