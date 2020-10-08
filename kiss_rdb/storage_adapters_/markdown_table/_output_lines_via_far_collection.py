def pass_thru_collection_for_write_(stdout, _listener):
    class collection_impl_for_write:  # #class-as-namespace
        def open_pass_thru_receiver_as_storage_adapter(_listener):
            return _open_pass_thru_receiver(stdout, _listener)
    return collection_impl_for_write


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


def _actions():

    class actions:  # #class-as-namespace

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
            yield '  - #born'

    class memory:  # #class-as-namespace
        last_header_two_label = None

    memory.output_table_header = _build_output_schema_rows(memory)

    return actions


def _open_pass_thru_receiver(sout, _listener):
    class context_manager:

        def __enter__(self):
            use_sout = sout.__enter__()  # should be same
            assert sout == use_sout  # ..

            for line in actions.output_file_head_placeholder_NOT_IN_FSA():
                use_sout.write(f"{line}\n")  # #here4

            return _build_receiver(sout, actions, _listener)

        def __exit__(self, *_4):

            for line in actions.output_file_tail_placeholder_NOT_IN_FSA():
                sout.write(f"{line}\n")  # #here4

            return sout.__exit__(*_4)

    actions = _actions()

    return context_manager()


def _build_receiver(sout, actions, _listener):
    # As you receive each next item from the upstream, determine what lines
    # to output (using our little state machine (see graph)) and write those
    # lines to STDOUT (or whatever it is). #[#008.2] custom state machine

    def receive(dct):
        transition_name = transition_name_via_item(dct)
        return follow_transition(transition_name, dct)

    def transition_name_via_item(dct):
        if '_is_branch_node' in dct:
            lvl = dct.get('header_level', 1)
            return transition_name_via[lvl]
        return 'entity'

    transition_name_via = {1: 'header_1', 2: 'header_2', 3: 'header_3'}

    def follow_transition(transition_name, dct):
        branch_rhs = rhs_via_state[self.state_name]
        action_and_state_name = branch_rhs[transition_name]  # ..

        # Keep performing actions while the transitions are "immediate"
        while True:
            # Transition into the current state/action by executing the action
            for line in change_state_and_execute(action_and_state_name, dct):
                # For both historical and readability reasons, actions above
                # do *not* terminate their newlines but table row lines #here4
                # *do*; hence this conditional. Chunking writes into whole
                # lines rather than writing little pieces makes debugging
                # output and test code less clunky (so, better). Ich muss sein
                if not (len(line) and '\n' == line[-1]):
                    line = f"{line}\n"
                sout.write(line)

            # If the right hand side of this transition is another branch,
            # stop now as-is and wait to receive the next item to continue
            mixed_rhs = rhs_via_state[action_and_state_name]
            if isinstance(mixed_rhs, dict):
                break

            # Otherwise (and the right hand side is a string) this is an
            # "immediate" transition.
            assert isinstance(mixed_rhs, str)
            action_and_state_name = mixed_rhs

    def change_state_and_execute(action_and_state_name, dct):
        func = getattr(actions, action_and_state_name)
        kwargs = args_via_dict_via_func(func)(dct)
        self.state_name = action_and_state_name
        return func(**kwargs)

    rhs_via_state = {k: x for k, x in _THIS_STATE_MACHINE()}
    args_via_dict_via_func = _build_args_via_dict_via_func()

    class self:
        state_name = 'start'

    return receive


def _build_output_schema_rows(memo):
    # The first time you see an entity dictionary.. The second time..

    def output_schema_rows_the_first_time(first_dct):

        def output_schema_rows(_):
            yield row1.to_line()  # #here4
            yield row2.to_line()

        def output_business_entity_row(dct):
            yield new_row_via(dct.items(), None).to_line()  # #here4

        complete_schema = build_complete_schema_via_first_dictionary(first_dct)
        row1, row2 = complete_schema.rows_

        eg_row = row1  # WHAT TO USE HERE?? we'll use the label row as long as
        new_row_via, _ = create_and_upd(eg_row, complete_schema)

        # BIG FLEX [re]write the methods of the thing
        memo.output_table_header = output_schema_rows
        memo.output_entity = output_business_entity_row
        return memo.output_table_header(None)

    build_complete_schema_via_first_dictionary = \
        _build_build_complete_schema_via_first_dictionary()

    from ._prototype_row_via_example_row_and_complete_schema import \
        BUILD_CREATE_AND_UPDATE_FUNCTIONS_ as create_and_upd

    return output_schema_rows_the_first_time


def _build_build_complete_schema_via_first_dictionary():
    # Because this whole storage adapter is optimized more torwards the reading
    # (rather than writing) operations relatively quickly and simply, when
    # we're going in the other direction (encoding not decoding) we do stuff
    # that can feel superfluous like creating our complete schema by building
    # the document lines that define it.

    def build_complete_schema_via_first_dictionary(dct):
        sr1 = line_AST_via_things(things_for_schema_row_line_one(dct))
        sr2 = line_AST_via_things(things_for_schema_row_line_two(len(dct)))
        return complete_schema_via_(sr1, sr2)

    def things_for_schema_row_line_one(dct):
        yield 'padding_on_every_cell', ' ', ' '
        for k in dct.keys():
            yield label_via_far_dictionary_key(k)

    def things_for_schema_row_line_two(leng):
        yield 'padding_on_every_cell', '', ''
        for _ in range(0, leng):
            yield '---'

    def line_AST_via_things(things):
        class memo:  # #class-as-namespace
            pass

        sexps, pcs, memo.current_width = [], [], 0

        typ, left_padding, right_padding = next(things)
        assert 'padding_on_every_cell' == typ

        def add_piece(pc):
            memo.current_width += len(pc)
            pcs.append(pc)

        for cell_content in things:
            add_piece('|')  # every cell starts with a pipe
            span_begin = memo.current_width
            add_piece(left_padding)
            add_piece(cell_content)
            add_piece(right_padding)
            sexps.append(('padded_cell', (span_begin, memo.current_width)))

        add_piece('|\n')  # add endcap and _eol #here4
        sexps.append(('line_ended_with_pipe',))
        return row_AST_via(sexps, ''.join(pcs), 0)

    def label_via_far_dictionary_key(k):  # k = far_dictionary_key
        assert re.match(r'[a-z]+(_[a-z]+)*$', k)  # ..
        pcs = k.split('_')
        pcs[0] = pcs[0].title()
        return ' '.join(pcs)

    from . import complete_schema_via_, schema_row_builder_
    row_AST_via = schema_row_builder_()

    import re
    return build_complete_schema_via_first_dictionary


def _build_args_via_dict_via_func():
    # What arguments should we pass to the action?
    # For action readability, there's 3 different forms of argument they take

    def args_via_dict_via_func(func):
        name = func.__name__
        x = cache.get(name)
        if not x:
            cache[name] = do_args_via_dict_via_func(func)
        return cache[name]

    cache = {}

    def do_args_via_dict_via_func(func):
        spec = getfullargspec(func)
        spec.defaults  # sometimes None, sometimes (None,)
        assert spec.varargs is None
        assert spec.varkw is None
        assert 0 == len(spec.kwonlyargs)
        assert spec.kwonlydefaults is None
        assert 0 == len(spec.annotations)

        args = spec.args
        leng = len(args)

        if 0 == leng:
            return monadic

        if 1 == leng and 'dct' == args[0]:  # OOF :#here3
            return pass_thru

        return sanitized_keywords_via_dict

    # == Functions for Action Arguments via Upstream Item Dictionary

    def sanitized_keywords_via_dict(dct):
        return {k: v for k, v in dct.items() if allow_list[k]}

    def pass_thru(dct):  # The action take a single argument called 'dct'
        return {'dct': dct}

    def monadic(dct):  # The action takes no arguments
        return empty_dct

    # == support for above

    # #here2: TODO has business-specific stuff that would need to b abs'd/inj'd
    allow_list = {  # what components of upstream item do we pass thru
            'header_level': False,  # ..
            '_is_branch_node': False,
            '_is_composite_node': False,  # not used, might go away
            'label': True,
            'url': True}

    empty_dct = {}

    from inspect import getfullargspec
    return args_via_dict_via_func


# #history-B.1: blind rewrite
# #history-A.3: full rewrite (unification, multi-table, state machine)
# #history-A.2: move out of scripts directory. no longer an excutable.
# #history-A.1: (can be temporary) used to use putser_via_IO
# #history-A.1: big refactor, sunsetted file of origin
# #born: abstracted from sibling
