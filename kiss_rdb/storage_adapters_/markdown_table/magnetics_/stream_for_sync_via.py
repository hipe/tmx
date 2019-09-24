"""
the name of this magnetic is more figurative than actual:

figuratively, we imagine the two streams coming together (near and far)
and from those, we skim off from the head of the near stream one example
item and then, using that item we output a stream of far items that get
"nativized" to be near items, a stream which (finally) we order when
necessary.

in fact this module does not accomplish this feat on its own in one
unified magnetic, but rather it has *all* (?) the constituent magnetics
that do this (with a bit of coordination required).

[#457.C.2] discusses this challenge in more depth.
"""


def NATIVIZER_ETC_VIA(**kwargs):
    return _NativizerVia(**kwargs).execute()


class _NativizerVia:

    def __init__(
            self,
            near_stream,
            complete_schema,
            listener,
            ):

        from modality_agnostic import streamlib as _
        self._next_near_item = _.next_or_noner(near_stream)

        self._nkfn = complete_schema.natural_key_field_name__()
        self._complete_schema = complete_schema
        self._listener = listener
        self._OK = True

    def execute(self):
        self._OK and self.__resolve_example_row()
        self._OK and self.__init_prototype_row_via_example_row()
        self._OK and self.__resolve_nativizer()
        if self._OK:
            return self

    def __resolve_nativizer(self):
        """
        it's going to need to be able to make new rows out of new far items.
        (inserts).
        """

        use_f = self.prototype_row.new_via_normal_dictionary

        def f(normal_dict):
            return use_f(normal_dict)  # #hi.

        self.near_item_via_normal_item_dictionary = f

    def __init_prototype_row_via_example_row(self):
        from . import prototype_row_via_example_row_and_schema_index as _
        self.prototype_row = _(
                natural_key_field_name=self._nkfn,
                example_row=self.example_row,
                complete_schema=self._complete_schema,
                )

    def __resolve_example_row(self):
        row_DOM = self._next_near_item()
        if row_DOM is None:
            cover_me("apparently you never covered this - no example row")
            _tmpl = "can't sync because no first business object row"
            self._emit('error', 'expression', 'no_prototype_row', _tmpl, ())
        else:
            self.example_row = row_DOM

    def _emit(self, *chan, tmpl, tup):
        def msg_f():
            yield tmpl.format(*tup)
        if 'error' == chan[0]:
            self._OK = False
        self._listener(*chan, msg_f)


def OPEN_NEAR_SESSION(
        keyerer,
        near_collection_path,
        listener,
        ):

    if keyerer is None:
        pass  # #hi.
    elif isinstance(keyerer, str):
        cover_me("this was the old way, mabye it will be the new way")
        from data_pipes.magnetics import function_via_function_identifier
        keyerer = function_via_function_identifier(keyerer, listener)
        if keyerer is None:
            return _not_OK_when_CM_expected()

    from . import tagged_native_item_stream_via_line_stream as _
    cm = _.OPEN_TAGGED_DOC_LINE_ITEM_STREAM(near_collection_path, listener)

    class ContextManager:

        def __enter__(self):
            return OpenNearSession(cm.__enter__(), keyerer)

        def __exit__(self, *_):
            return cm.__exit__(*_)

    class OpenNearSession:

        def __init__(self, line_items, keyerer):
            self._tagged_line_items = line_items
            self.keyerer = keyerer

        def release_tagged_doc_line_item_stream(self):
            x = self._tagged_line_items
            del self._tagged_line_items
            return x

        OK = True

    return ContextManager()


def FAR_STREAM_FOR_SYNC_VIA(
        stream_for_sync_is_alphabetized_by_key_for_sync,
        stream_for_sync_via_stream,
        dictionaries, listener):
    """
    👉 see this [#463] a graph-viz graph about pipelines

        - here is where we first thought of #wish [#873.H] customizable
          functional pipelines (so you could map before or after filter
          as you desire, for example). but needs to be specified and that
          definitely needs to incubate..
    """

    far_tuples = stream_for_sync_via_stream(dictionaries)

    if stream_for_sync_is_alphabetized_by_key_for_sync:
        return far_tuples  # (Case1322DP)

    return __yikes_sort(far_tuples)  # (Case0110DP)


def __yikes_sort(raw_order):
    """simply "flatten" the iterator into one big list and sort it by

    the human key. result in the big list as an iterator.
      - whine when we reach a sanity limit. we lose linear scaling
    """

    big_pairs_list = []
    sanity = 300  # ##[#873.6]

    # (at #history-A.1 the above got +100 for hugo themes lol)
    count = 0
    for kv_pair in raw_order:
        count += 1
        if sanity == count:
            cover_me('redis etc')
        big_pairs_list.append(kv_pair)

    big_pairs_list.sort(key=lambda kv_pair: kv_pair[0])
    # (we could expose a sophistication our sorting mechanics but
    # we'd rather not)

    return iter(big_pairs_list)


# (Case0730DP) use to cover when there is no custom far keyer
# (Case0160DP) covered when yes


def _not_OK_when_CM_expected():
    from data_pipes import my_contextlib
    return my_contextlib.not_OK_context_manager()


def cover_me(msg):  # #open [#876] cover me
    raise Exception(f'cover me: {msg}')

# #history-A.1: change when we apply the map function on the far stream
# #abstracted.
