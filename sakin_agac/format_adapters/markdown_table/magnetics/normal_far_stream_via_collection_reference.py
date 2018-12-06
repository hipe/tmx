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

[#417.C.2] discusses this challenge in more depth.
"""

from sakin_agac import (
        cover_me,
        pop_property,
        )


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
        near_relevant_traversal_parameters,
        near_collection_path,
        listener,
        ):

    tup = __process_near_opts(listener, **near_relevant_traversal_parameters)
    if tup is None:
        cover_me('probably OK')
        return _not_OK_when_CM_expected()
    keyerer, = tup

    from . import tagged_native_item_stream_via_line_stream as _
    cm = _.OPEN_TAGGED_DOC_LINE_ITEM_STREAM(near_collection_path, listener)

    class _OpenNearSessionContextManager:

        def __enter__(self):
            return _OpenNearSession(cm.__enter__(), keyerer)

        def __exit__(self, *_):
            cm.__exit__(*_)
            return False

    class _OpenNearSession:

        def __init__(self, line_items, keyerer):
            self._tagged_line_items = line_items
            self.keyerer = keyerer

        def release_tagged_doc_line_item_stream(self):
            return pop_property(self, '_tagged_line_items')

        OK = True

    return _OpenNearSessionContextManager()


def __process_near_opts(
        listener,
        custom_near_keyer_for_syncing=None,
        ):

    keyerer = None
    if custom_near_keyer_for_syncing is not None:
        keyerer = _procure_func_via_func_identifier(
                custom_near_keyer_for_syncing, listener)
        if keyerer is None:
            return None

    return (keyerer,)


def OPEN_FAR_SESSION(
        cached_document_path,
        far_collection_reference,
        datastore_resources,
        listener,
        custom_mapper_OLDSCHOOL=None,  # see [#418.I.4]
        ):

    sr_cm = far_collection_reference.open_sync_request(
            cached_document_path=cached_document_path,
            datastore_resources=datastore_resources,
            listener=listener)

    if sr_cm is None:
        return _not_OK_when_CM_expected()  # #coverpoint5.10

    class _OpenFarSessionContextManager:

        def __enter__(self):

            sync_request = sr_cm.__enter__()

            tup = _far_session_work(sync_request, custom_mapper_OLDSCHOOL, listener)  # noqa: E501
            if tup is None:
                cover_me('wee')

            return _OpenFarSession(*tup)

        def __exit__(self, *_):
            return sr_cm.__exit__(*_)

    class _OpenFarSession:

        def __init__(self, normal_far_st, tp):
            self._normal_far_stream = normal_far_st
            self._traversal_parameters = tp

        def release_normal_far_stream(self):
            return pop_property(self, '_normal_far_stream')

        def TO_NRTP__(self):  # #testpoint
            # NRTP = "near relevant traversal parameters"

            o = {}
            _ = self._traversal_parameters.custom_near_keyer_for_syncing
            o['custom_near_keyer_for_syncing'] = _
            return o

        @property
        def far_deny_list(self):
            return self._traversal_parameters.far_deny_list

        OK = True

    return _OpenFarSessionContextManager()


def _far_session_work(sync_request, custom_mapper_OLDSCHOOL, listener):
    """
    so:
        - here we implement exactly [#423.B] (a graph-viz graph)

        - here is where we first thought of #wish [#410.Y] customizable
          functional pipelines (so you could map before or after filter
          as you desire, for example). but needs to be specified and that
          definitely needs to incubate..
    """

    # -- order matters
    tp = sync_request.release_traversal_parameters()
    if tp is None:
        cover_me('wee')

    far_dict_st = sync_request.release_dictionary_stream()
    del(sync_request)
    # --

    if 4 != tp.traversal_parameters_version:
        raise Exception('woot - #provision [#418.J] - parameters added')

    is_ordered = tp.traversal_will_be_alphabetized_by_human_key

    ok, use_map = __procure_any_map(tp, custom_mapper_OLDSCHOOL, listener)
    if not ok:
        return

    ok, pass_filter = __procure_any_pass_filter(tp, listener)
    if not ok:
        return

    far_keyer = __procure_some_far_keyer(tp, listener)
    if far_keyer is None:
        cover_me('failed to load function referenced in schema')
        return

    normal_pair = __synthesize_normal_pair_function(far_keyer, use_map)

    if pass_filter is None:
        raw_order = (normal_pair(far_dct) for far_dct in far_dict_st)
    else:
        raw_order = (normal_pair(d) for d in far_dict_st if pass_filter(d))

    if is_ordered:
        cover_me('almost certainly fine but not covered')
        normal_far_st = raw_order
    else:
        normal_far_st = _yikes_sort(raw_order)

    return (normal_far_st, tp)


def _yikes_sort(raw_order):
    """simply "flatten" the iterator into one big list and sort it by

    the human key. result in the big list as an iterator.
      - whine when we reach a sanity limit. we lose linear scaling
    """

    big_pairs_list = []
    sanity = 300  # ##[#410.R]

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


def __synthesize_normal_pair_function(far_keyer, use_map):

    def normal_pair_via_normal_dict(far_dct):
        key = far_keyer(far_dct)
        if key is None:
            cover_me("nil key")
        return (key, far_dct)

    if use_map is None:
        normal_pair = normal_pair_via_normal_dict
    else:
        def normal_pair(far_dict):
            normal_dict = use_map(far_dict)
            if normal_dict is None:
                cover_me('map resulted in none')
            return normal_pair_via_normal_dict(normal_dict)

    return normal_pair


def __procure_some_far_keyer(o, listener):

    cust_far_keyer_id = o.custom_far_keyer_for_syncing
    nkfn = o.natural_key_field_name
    if nkfn is None:
        cover_me('when is this ever not set')

    if cust_far_keyer_id is None:

        def result(far_dct):
            return far_dct[nkfn]  # #coverpoint7.3
    else:
        # #coverpoint1.6
        f_f = _procure_func_via_func_identifier(cust_far_keyer_id, listener)
        if f_f is None:
            cover_me('failed to load function from function identifier')

        result = f_f(o, listener)
        if result is None:
            cover_me('user defined function-function failed to produce function')  # noqa: E501

    return result


def __procure_any_pass_filter(tp, listener):

    f_id = tp.custom_pass_filter_for_syncing
    if f_id is None:
        result = (True, None)
    else:
        # #coverpoint13.3
        pass_filter = _procure_func_via_func_identifier(f_id, listener)
        if pass_filter is None:
            result = (False, None)  # meh, not covered
        else:
            result = (True, pass_filter)
    return result


def __procure_any_map(tp, custom_mapper_OLDSCHOOL, listener):
    # we would rather not support both these map techniques, but how? ..

    map_id = tp.custom_mapper_for_syncing
    has_map_specified_in_schema = map_id is not None
    has_map_passed_directly = custom_mapper_OLDSCHOOL is not None

    if has_map_specified_in_schema:
        if has_map_passed_directly:
            cover_me('we would rather not end up with two maps here..')
        else:
            use_map = _CRAZY_TIME(map_id, listener)
            ok = False if use_map is None else True
    elif has_map_passed_directly:
        ok = True
        use_map = custom_mapper_OLDSCHOOL  # #coverpoint9.1.1
    else:
        ok = True
        use_map = None

    return (ok, use_map)


def _CRAZY_TIME(map_id, listener):
    """(static arguments in function identifiers #stub [#418.I.5]"""

    import re
    md = re.match(r'^(.+)\(([^)]+)\)$', map_id)
    if md is None:
        cover_me('xx')

    func_id, arg = md.groups()

    f_f = _procure_func_via_func_identifier(func_id, listener)
    if f_f is None:
        return

    md = re.match(r'^"([^"]+)"$', arg)
    if md is None:
        cover_me('currently hardcoded to take one string-looking argument')

    f = f_f(md[1], listener)
    if f is None:
        cover_me('client function function did not return function')

    return f  # #coverpoint15.1


def _not_OK_when_CM_expected():
    from sakin_agac import my_contextlib
    return my_contextlib.not_OK_context_manager()


def _procure_func_via_func_identifier(identifier, listener):
    from sakin_agac.magnetics import function_via_function_identifier as _
    return _(identifier, listener)


# #pending-rename: perhaps to "normal far stream via SOMETHING"
# #history-A.1: change when we apply the map function on the far stream
# #abstracted.
