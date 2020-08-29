def COLLECTION_IMPLEMENTATION_FOR_PASS_THRU_WRITE(stdout):

    class CollectionImplementation:  # #class-as-namespace

        def OPEN_PASS_THRU_RECEIVER_AS_STORAGE_ADAPTER(monitor):

            pr = _build_private_receiver(stdout, monitor)

            class Receiver:  # class-as-namespace
                RECEIVE_PRODUCER_SCRIPT_STATEMENT = \
                        pr.receive_producer_script_statement

            class ContextManager:

                def __init__(self):
                    self._mutex = None

                def __enter__(self):
                    del self._mutex
                    pr.receive_beginning_of_file()
                    return Receiver

                def __exit__(self, exception_class, e, traceback):
                    if e is not None:
                        return
                    if not monitor.OK:
                        return  # don't write tail of file if errored
                    pr.receive_end_of_file()

            return ContextManager()

    return CollectionImplementation


def _build_private_receiver(stdout, MONITOR):

    actions = _BUILD_ACTIONS_INDEX(stdout, MONITOR)

    states = _BUILD_THIS_STATE_MACHINE(actions, _THIS_STATE_MACHINE())

    class PrivateReceiver:

        def __init__(self):
            s = 'start'
            self._current_dictionary = states[s].DICTIONARY
            self._current_state_name = s

        def receive_beginning_of_file(self):
            actions['output_file_head_placeholder_NOT_IN_FSA'](None)

        def receive_producer_script_statement(self, dct):

            token = _token_via(dct)
            action_name = self._current_dictionary.get(token, None)
            if action_name is None:
                _ = self._current_state_name
                raise Exception(f"no transition from '{_}' to '{token}'")

            while True:
                actions[action_name](dct)
                new_state_node = states[action_name]  # #conflation
                if new_state_node.is_branch:
                    self._current_state_name = action_name
                    self._current_dictionary = new_state_node.DICTIONARY
                    break
                action_name = new_state_node.ACTION_NAME  # NAME IS BOTH

        def receive_end_of_file(self):
            actions['output_file_tail_placeholder_NOT_IN_FSA'](None)

    return PrivateReceiver()


def _THIS_STATE_MACHINE():
    # (exactly [#874.4] the state machine digraph )

    yield 'start', {
            'header_1': 'output_header_1',
            'entity': 'output_PLACEHOLDER_header_1'}

    yield 'output_PLACEHOLDER_header_1', 'output_table_header'

    yield 'output_table_header', 'output_entity'

    yield 'output_header_1', {
            'header_2': 'memo_and_output_header_2',
            'entity': 'output_table_header'}

    yield 'memo_and_output_header_2', {
            'header_3': 'output_header_2_plus_header_3',
            'entity': 'output_table_header'}

    yield 'output_header_2_plus_header_3', {
            'entity': 'output_table_header'}

    yield 'output_entity', {
            'header_1': 'output_header_1',
            'header_2': 'memo_and_output_header_2',
            'header_3': 'output_header_2_plus_header_3',
            'entity': 'output_entity'}


def _token_via(dct):
    if '_is_branch_node' not in dct:
        return 'entity'
    if 'header_level' not in dct:
        return 'header_1'
    return __token_via_header_level[dct['header_level']]


__token_via_header_level = (None, 'header_1', 'header_2', 'header_3')


def _BUILD_ACTIONS_INDEX(stdout, MONITOR):

    memory = _hand_written_state_machine(stdout, MONITOR)

    class Actions:  # #class-as-namespace

        def output_file_head_placeholder_NOT_IN_FSA():
            # output hugo frontmatter. impure but simplifies visual development
            # hardcode timezone because see doc for datetime (near "reality")

            from datetime import datetime
            _timestamp = datetime.now().strftime('%Y-%m-%dT%H:%M:%S-05:00')

            yield '---'
            yield 'title: i am your collection'
            yield f'date: {_timestamp}'
            yield '---'
            yield ''
            yield ''  # we want 4 blanks. two are here.. then #here1

        def output_PLACEHOLDER_header_1():
            yield ''  # to make four blank lines #here1
            yield ''
            yield '## your collection'  # placeholder or w/e
            yield ''

        def output_header_1(label, url=None):
            yield ''  # to make four blank lines #here1
            yield ''
            if url is None:
                yield f'# {label}'
            else:
                yield f'# <a href="{url}">{label}</a>'  # would-be injection

        def memo_and_output_header_2(label):
            memory.last_header_two_label = label
            yield ''
            yield ''
            yield f'## {label}'

        def output_header_2_plus_header_3(label):
            yield ''
            yield ''
            yield f'## {memory.last_header_two_label} - {label}'

        def output_table_header(dct):  # MAGIC ARG NAME #here3
            yield ''
            for line_content in memory.output_table_header(dct):
                yield line_content

        def output_entity(dct):  # MAGIC ARG NAME #here3
            return memory.output_entity(dct)

        def output_file_tail_placeholder_NOT_IN_FSA():
            yield ''
            yield ''
            yield ''
            yield ''
            yield '## (document-meta)'
            yield ''
            yield '  - #born.'

    # == BEGIN HUGE EXPERIMENT

    actions_index = {}

    write = stdout.write

    def build_normal_function(prepare_args, user_function):
        def normal_function(dct):
            for line_content in user_function(** prepare_args(dct)):
                write(f'{line_content}\n')  # _eol
        return normal_function

    def when_kwargs(dct):
        return {k: v for k, v in dct.items() if k not in not_these}

    not_these = {
        '_is_branch_node',  # already saw this
        'header_level',  # header level is reflected in token
        '_is_composite_node',  # not used, might go away
        }

    def when_pass_thru(dct):
        return {'dct': dct}

    def when_monadic(dct):
        return empty_dct

    empty_dct = {}

    # for each action

    from inspect import getmembers, isfunction, getfullargspec
    for name, function in getmembers(Actions, predicate=isfunction):
        spec = getfullargspec(function)
        spec.defaults  # sometimes None, sometimes (None,)
        assert(spec.varargs is None)
        assert(spec.varkw is None)
        assert(0 == len(spec.kwonlyargs))
        assert(spec.kwonlydefaults is None)
        assert(0 == len(spec.annotations))

        args = spec.args
        leng = len(args)

        if 0 == leng:
            when_what = when_monadic
        elif 1 == len(args) and 'dct' == args[0]:  # OOF :#here3
            when_what = when_pass_thru
        else:
            when_what = when_kwargs

        actions_index[name] = build_normal_function(when_what, function)

    # == END

    return actions_index


def _hand_written_state_machine(STDOUT, MONITOR):

    cell_via = _cel_via_er()

    from kiss_rdb.storage_adapters_.markdown_table import RowAsEntity_

    def row_via_cels(orig_func):  # #decorator
        def use_func(self):
            return do_row_via_cels(orig_func(self))
        return use_func

    def do_row_via_cels(cels):
        cels = tuple(cels)  # often a generator
        return RowAsEntity_(cels[0], cels[1:], yes_always_trailing_pipe)

    yes_always_trailing_pipe = True

    class Memory:

        def __init__(self):
            self._is_first_entity_ever_seen = True

        def output_table_header(self, dct):
            if self._is_first_entity_ever_seen:
                self._is_first_entity_ever_seen = False
                _kwargs = _index_via_entity(dct)
                self.__see_first_entity_ever(** _kwargs)
            else:
                assert(set(self._content_width_via_key) == set(dct))
                # we probably don't want table structure to change..

            yield self.__build_labels_row().to_line_content_()
            yield self.__build_dashes_row().to_line_content_()

        @row_via_cels
        def __build_labels_row(self):
            # give each label cel ONE space to its left and ONE to its right

            for k, label in self._labels_as_entity.items():
                yield cell_via(1, label, 1, k)

        @row_via_cels
        def __build_dashes_row(self):
            # make the dashes fill every ASCII pixel, given index. ick/meh

            for k, w in self._content_width_via_key.items():
                yield cell_via(0, '-' * (w + 2), 0, k)

        def output_entity(self, dct):
            _cels = self._cels_via_entity(dct)
            _row = do_row_via_cels(_cels)
            yield _row.to_line_content_()

        def __see_first_entity_ever(
                self, labels_as_entity, offset_via_key, content_width_via_key):

            _celer_via_offset = _celer_via_offset_via(content_width_via_key)

            self._cels_via_entity = _cels_via_entity_er(
                    _celer_via_offset, content_width_via_key, offset_via_key)

            self._labels_as_entity = labels_as_entity
            self._content_width_via_key = content_width_via_key

    return Memory()


def _cels_via_entity_er(celer_via_offset, content_width_via_key, offset_via_key):  # noqa: E501

    num_cels = len(offset_via_key)
    rang = range(0, num_cels)
    keys = tuple(offset_via_key.keys())

    def cels_via_entity(dct):
        cels = [None for _ in rang]
        for i, cel in offsets_and_cels_via_entity(dct):
            cels[i] = cel
        return tuple(cels)

    def offsets_and_cels_via_entity(dct):
        dim_pool = set(keys)

        for k, s in dct.items():
            assert(isinstance(s, str))  # just for now. orthogonal problem
            dim_pool.remove(k)

            offset = offset_via_key[k]
            _cel = celer_via_offset[offset](s)
            yield offset, _cel

        for k in dim_pool:
            offset = offset_via_key[k]
            _cel = celer_via_offset[offset]('')
            yield offset, _cel

    return cels_via_entity


def _celer_via_offset_via(content_width_via_key):

    # EXPERIMENTAL this is where we would want to do crazy padding

    cell_via = _cel_via_er()

    def build_cel_builders():
        for k in content_width_via_key.keys():
            yield build_cel_builder(content_width_via_key[k], k)

    def build_cel_builder(content_width, key):
        def build_cel(s):
            if '' == s:
                return cell_via(0, '', 0, key)
            return cell_via(1, s, 1, key)  # CHANGE ME
        return build_cel

    return tuple(build_cel_builders())


def _index_via_entity(dct):

    labels_as_entity = {}
    content_width_via_key = {}
    offset_via_key = {}

    import re

    i = -1  # be careful
    for k in dct.keys():
        i += 1
        offset_via_key[k] = i
        assert(re.match(r'[a-z]+(_[a-z]+)*$', k))
        pieces = k.split('_')
        pieces[0] = pieces[0].title()
        label = ' '.join(pieces)
        use_w = max(3, len(label))
        content_width_via_key[k] = use_w
        labels_as_entity[k] = label

    return {'labels_as_entity': labels_as_entity,
            'content_width_via_key': content_width_via_key,
            'offset_via_key': offset_via_key}


def _BUILD_THIS_STATE_MACHINE(action_index, these):  # [#008.2] state machine

    states = {}
    unresolved_references = set()

    def see_action_name(s):
        if s in states or s in unresolved_references:
            return
        unresolved_references.add(s)

    class Branch:
        def __init__(self, dct):
            for token_name, action_name in dct.items():
                see_action_name(action_name)
            self.DICTIONARY = dct

        is_branch = True

    class TransitionImmediately:
        def __init__(self, s):
            see_action_name(s)
            self.ACTION_NAME = s

        is_branch = False

    for state_name, mixed_RHS in these:
        assert(state_name not in states)
        if isinstance(mixed_RHS, str):
            states[state_name] = TransitionImmediately(mixed_RHS)
        else:
            assert(isinstance(mixed_RHS, dict))
            states[state_name] = Branch(mixed_RHS)

    for k in unresolved_references:
        assert(k in states)

    return states


def _cel_via_er():
    from kiss_rdb.storage_adapters_.markdown_table import AttributeCell_
    return AttributeCell_

# #history-A.3: full rewrite (unification, multi-table, state machine)
# #pending-rename: maybe to "via dictionaries"
# #history-A.2: move out of scripts directory. no longer an excutable.
# #history-A.1: (can be temporary) used to use putser_via_IO
# #history-A.1: big refactor, sunsetted file of origin
# #born: abstracted from sibling
