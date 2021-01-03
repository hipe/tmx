def cli_for_production():
    def resourceser():
        if self.value is None:
            self.value = external_functions_via_stderr_(serr)
        return self.value
    self = resourceser  # #watch-the-world-burn
    self.value = None
    import sys as o
    serr = o.stderr
    exit(_CLI(o.stdin, o.stdout, serr, o.argv, resourceser))


def _formals_for_toplevel():
    yield '-h', '--help', 'This screen'
    yield 'command [..]', "One of the below"


def _subcommands():
    yield 'select', lambda: _pretend_module_for_command_called_select
    yield 'filter-by-tags', lambda: _load('.filter_by_tags')
    yield 'convert-collection', lambda: _load('.convert_collection')
    yield 'cc', _build_hacked_alias_to_convert_collection
    yield 'sync', lambda: _load('.sync')
    yield 'scrape', lambda: _load('.scrape')


_use_me = \
    "(alias to `convert-collection` (hacky experiment))"


def _build_hacked_alias_to_convert_collection():  # #wish [#608.11]: aliases

    # Experimenting. Abstract this when appropriate. It sort of asserts a spec
    mod = _load('.convert_collection')
    self = _MutableCommandModule()
    self.IS_CHAINABLE = mod.IS_CHAINABLE
    self.MUST_BE_ENDPOINT_OF_PIPELINE = mod.MUST_BE_ENDPOINT_OF_PIPELINE
    self.__name__ = 'convert_collection'

    if (f := getattr(mod, 'NONTERMINAL_PARSE_ARGS', None)):
        self.NONTERMINAL_PARSE_ARGS = f
    if (f := getattr(mod, 'TERMINAL_PARSE_ARGS', None)):
        self.TERMINAL_PARSE_ARGS = f

    self.BUILD_COLLECTION_MAPPER = mod.BUILD_COLLECTION_MAPPER
    return self


class _MutableCommandModule:
    pass


def _CLI(sin, sout, serr, argv, svcser):  # #testpoint
    """Data Pipes is an experimental potpourri of higher-level operations

    that operate on top of collections, sort of in the spirit of ReactiveX

    Chaining:

    Experimentally, some commands can be chained to each other. To make a
    chain of commands, link them with a pipe token ('|'). Be sure to enclose
    the pipe in quotes so your shell doesn't interpret it as a shell pipe:

        dp <cmd-name> [cmd-args] '|' <cmd-name> [cmd-args] '|' <cmd-name> [..]

    In theory, instead of doing it this way, you *could* use shell pipes:

        dp <cmd-name> [cmd-args] | dp <cmd-name> [cmd-args] '|' dp <cmd-name>..

    but the former way allows you to keep the whole thing in one process.

    (This general idea is where "data pipes" got its name from.)

    When chaining commands, use '-' for ther collection arguments as necessary.

    NOTE: CURRENTLY it's necessary to put all options before all positional
    arguments (within each node of the pipeline).

    (the broken display of this help screen is #open [#459.U])
    """

    long_prog_name = (bash_argv := list(reversed(argv))).pop()

    def prog_name():
        pcs = long_prog_name.split(' ')
        from os.path import basename
        pcs[0] = basename(pcs[0])
        return ' '.join(pcs)

    foz = formals_via_(_formals_for_toplevel(), prog_name, _subcommands)
    vals, es = foz.nonterminal_parse(serr, bash_argv)
    if vals is None:
        return es

    if vals.get('help'):
        return foz.write_help_into(serr, _CLI.__doc__)

    assert 0 == len(bash_argv)
    bash_argv = list(reversed(vals.pop('command')))  # the rest

    # cm = command module
    queue, cm, rc = _EXPERIMENTAL_parse_chained_command(serr, bash_argv, foz)
    if rc is not None:
        return rc

    if cm:
        ch_argv = tuple(reversed(bash_argv))
        return cm.CLI_(sin, sout, serr, ch_argv, svcser)

    assert queue

    return _RUN_THE_QUEUE(sin, sout, serr, queue, svcser)


# == Select

class _pretend_module_for_command_called_select:  # #class-as-namespace
    IS_CHAINABLE = True
    MUST_BE_ENDPOINT_OF_PIPELINE = False

    def NONTERMINAL_PARSE_ARGS(serr, bash_argv):
        prog_name = bash_argv.pop()
        foz = formals_via_(_formals_for_select(), lambda: prog_name)

        vals, es = foz.nonterminal_parse(serr, bash_argv)
        if vals is None:
            return None, None, es
        return vals, foz, None  # track [#459.O]

    def BUILD_COLLECTION_MAPPER(serr, vals, foz, rscser):
        return _build_collection_mapper_for_select(serr, vals, foz, rscser)


def _formals_for_select():
    yield '-f', '--format=FMT', 'experimental..'
    yield '-h', '--help', this_screen_
    yield '<collection>', _desc_for_collection
    yield '<field-name>', 'maybe one day..'


def _build_collection_mapper_for_select(serr, vals, foz, rscser):
    """(experimental) something sorta like the SQL command. needs design
    """

    if vals.get('help'):
        doc = _build_collection_mapper_for_select.__doc__
        rc = foz.write_help_into(serr, doc)
        return None, rc

    field_name = vals.pop('field_name')
    if vals:
        xx(f"OOPS: {', '.join(vals.keys())}")

    def collection_mapper(schema, input_ents):
        if schema:
            missing_keys = set((field_name,)) - set(schema.field_name_keys)
            if missing_keys:
                xx(f"field(s) not found: {', '.join(missing_keys)}")

        def out_ents():
            for ent in input_ents:
                out_ents.count += 1
                out_dict = {field_name: ent.core_attributes[field_name]}
                # .. for one thing, KeyError. for another, multiple fields..
                # .. we don't know what behavior we want yet so, rien ..
                yield _MinimalEntity(out_dict)

        out_ents.count = 0  # #watch-the-world-burn

        def summarizer():
            class summary:  # #class-as-namespace
                def to_lines():
                    yield f"`select` saw {out_ents.count} entit{{y|ies}}\n"
            return summary

        out_schema = _MinimalSchema((field_name,))
        return out_schema, out_ents(), summarizer
    return collection_mapper, None


# == PARSE AND TRAVERSE THE PIPELINE

def _RUN_THE_QUEUE(sin, sout, serr, queue, rscser):
    # Why this feels like the most complicated algorithm i ever did 😂

    def main():
        check_the_endpointability_of_the_nodes()
        for_the_first_node_store_the_coll_ref()
        for_the_nonfirst_nodes_assert_dash()
        prepare_cmappers_for_all_the_nodes()
        do_big_marriage_thing()
        co = produce_collection()
        with co.open_schema_and_entity_traversal(throwing_listener) as (s, e):
            self.VISIT(s, e)

    def produce_collection():
        def error(msg):
            serr.write(f"{msg}\n")
            raise stop(_generic_error_returncode)
        fmt = self.format
        moni = self.coll_path_key.upper()  # ick/meh
        coll_ref = self.collection_reference
        func = normalize_collection_reference_
        use_fmt, use_cref = func(sin, fmt, coll_ref, 'STDIN', moni, error)

        from data_pipes import meta_collection_ as func
        collib = func()
        return collib.collection_via_path(
            use_cref, throwing_listener, format_name=use_fmt)

    def do_big_marriage_thing():
        # Our final step in this pipeline (being as we are a CLI) is always to
        # write something to STDOUT (usually the result collection in some
        # particular format). Nodes that specify themselves as endpoint nodes
        # must implement their own behavior around this: They expose a
        # function that receives STDOUT and produces a collection visitor.
        # Otherwise (and our final node wasn't such a node) we must add a
        # default behavior (which is to output the result collection as json).

        if self.last_node_is_endpoint_node:
            these = self.cmappers
        else:
            these = (*self.cmappers, DEFAULT_ENDPOINT_CMAPPER)

        # Go backwards from the end, marrying each pair
        curr_visit = these[-1](sout)
        exclude_the_end = range(0, len(these)-1)  # might be none

        for i in reversed(exclude_the_end):
            prev_map = these[i]
            curr_visit = marry(prev_map, curr_visit)
        self.VISIT = curr_visit

    def marry(prev_map, curr_visit):
        # Make a new collection visitor that's the marriage of two other
        def visit_collection(in_schema, in_ents):
            out_schema, out_ents, summarizer = prev_map(in_schema, in_ents)
            if out_ents is None:
                return

            def use_out_ents():  # yuck but i don't know how/when to do summary
                for ent in out_ents:
                    yield ent
                obj = summarizer()
                lines = obj.to_lines()
                for line in lines:
                    serr.write(line)

            curr_visit(out_schema, use_out_ents())
        return visit_collection

    def DEFAULT_ENDPOINT_CMAPPER(sout):
        def collection_visitor(schema, ents):
            _do_default_endpoint(sout, schema, ents)
        return collection_visitor

    def _do_default_endpoint(sout, schema, ents):
        out_coll = _json_collection_via(sout)
        with out_coll.open_collection_to_write_given_traversal(listener) as rc:
            rc.receive_schema_and_entities(schema, ents, listener)

    # == Resolve cmappers

    def prepare_cmappers_for_all_the_nodes():
        # we know there's at least one because of #here1, but we don't know whi
        self.cmappers = tuple(cmapper(uow) for uow in queue)

    def cmapper(uow):
        cmd_mod = uow.properties
        vals = uow.values
        foz = uow.formals
        f, rc = cmd_mod.BUILD_COLLECTION_MAPPER(serr, vals, foz, rscser)
        if not f:
            raise stop(rc)
        return f

    # ==

    def for_the_nonfirst_nodes_assert_dash():
        if 1 == leng:  # assume #here1
            return  # hi.
        for i in range(1, leng):  # Each non-first node must..
            uow = queue[i]
            k, kk = two_keys_for(uow)
            coll_ref, fmt = pop_softly(uow, k, kk)
            if coll_ref not in ('-', None):  # none IFF help #here2
                xx("For non-first components of a pipe, the collection you "
                   "specify has to be '-'")
            if fmt is not None:
                xx("In non-first components, you can't specify an "
                   "input format")

    def for_the_first_node_store_the_coll_ref():
        uow = queue[0]  # guaranteed b.c #here1
        k, kk = two_keys_for(uow)
        self.coll_path_key = k
        self.collection_reference, self.format = pop_softly(uow, k, kk)

    def pop_softly(uow, k, kk):
        # Even though collection path is required, not there IFF help #here2
        coll_ref, fmt = uow.values.pop(k, None), uow.values.pop(kk, None)
        return coll_ref, fmt  # when help #here2

    def two_keys_for(uow):
        # Historically every now-participating node exposed formal parameters
        # for specifying the input collection
        #
        # Some did and others did not expose a format option: We chose to
        # overlook this as an option in most  interfaces because in practice
        # t seems always sufficient to rely on the extension when file or to
        # infer json when STDIN. (That is, it seemed we never had STDIN input
        # that was not json and we never had files that did not express format
        # through their extension.)
        #
        # However in one interface, symmetry compelled us to expose not one
        # but two options to specify format: one for input and one for output.
        #
        # Its out of scope for us to try to "consistentize" these arguments and
        # option across all the formal nodes (in terms of name, in terms of
        # exposure) because for one thing it requires new design choices, and
        # we want this to be a backwards-compatible feature-add.
        #
        # Because this amounts to an interface-level, almost cosmetic decision,
        # we should plan for this to change and so we want to abstract this
        # decision away and always assume (from some low level) that it's an
        # option.
        #
        # But in an part-way imagined future this could simplify

        leftmost_arg_k = uow.formals.formal_positionals[0].key
        leftmost_opt_k = uow.formals.formal_options[0].key

        if 'collection' == leftmost_arg_k:
            use_ting = None
            if 'format' == leftmost_opt_k:
                use_ting = leftmost_opt_k
            return leftmost_arg_k, use_ting  # for now, in practicum

        def oops(moni, which):
            s = uow.to_moniker()
            raise xx(f"whoops: {s!r} leftmost {which} was {moni!r}")

        # Assert that the leftmost positional parameter matches "_collection$"
        import re
        if not re.search('._collection$', leftmost_arg_k):
            oops(leftmost_arg_k, 'postional parameter')

        # Assert that the leftmost option looks like this
        if not re.search('._format$', leftmost_opt_k):
            oops(leftmost_opt_k, 'option')

        return leftmost_arg_k, leftmost_opt_k

    # ==

    def check_the_endpointability_of_the_nodes():
        # If there are any nodes that say they must be at end, check that.

        assert 0 < leng  # :#here1
        bs = tuple(i for i in range(0, leng) if queue[i].properties.MUST_BE_ENDPOINT_OF_PIPELINE)  # noqa: E501

        reason, yes = None, False
        if len(bs):
            if 1 < len(bs):
                reason = "multiple endpoint-only functions in pipeline [..]"
            elif (leng-1 != bs[-1]):
                reason = "endpoint-only function must be at end, is not."
            else:
                yes = True
        if reason:
            xx(reason)
        self.last_node_is_endpoint_node = yes

    def throwing_listener(sev, *rest):
        listener(sev, *rest)
        if ('info', 'error').index(sev):  # ..
            raise stop(_generic_error_returncode)

    leng = len(queue)

    mon = rscser().produce_monitor()
    listener = mon.listener

    self = main  # #watch-the-world-burn
    stop = _Stop
    try:
        main()
        rc = mon.returncode  # ..
    except stop as exc:
        args = exc.args
        if len(args):
            rc, = args  # ..
        else:
            rc = mon.returncode
    return rc


def _EXPERIMENTAL_parse_chained_command(serr, bash_argv, foz):
    def main():
        while True:
            resolve_a_command_from_argv_head()  # reminder: check for empty
            if command_is_not_chainable():
                if is_first_command():
                    return None, self.cmd_mod, None  # #here3
                xx("complain about etc")
            parse_the_args_for_that_command_passively()
            if end_of_argv():
                break
            the_next_token_must_be_a_pipe()

        return tuple(queue), None, None  # #here3

    def end_of_argv():
        return 0 == len(bash_argv)

    def is_first_command():
        return 0 == len(queue)

    def command_is_not_chainable():
        return not self.cmd_mod.IS_CHAINABLE

    def the_next_token_must_be_a_pipe():
        if '|' == bash_argv[-1]:  # #hereZ
            bash_argv.pop()
            return
        xx(f"next token must be a pipe (use quotes), had {bash_argv[-1]!r}")

    def resolve_a_command_from_argv_head():
        if 0 == len(bash_argv):
            xx(f"expecting command after '{_PIPE}'")  # on
        three = foz.parse_alternation_fuzzily(serr, bash_argv[-1])
        cmd_name, cmd_moder, rc = three
        if not cmd_name:
            raise stop(rc)  # #cover-me:seen

        self.cmd_mod = cmd_moder()
        ch_pn = ' '.join((foz.program_name, cmd_name))  # doin it early ick/meh
        bash_argv[-1] = ch_pn  # replace the short name with a qualified name

    def parse_the_args_for_that_command_passively():
        mod = self.cmd_mod

        # track [#459.O] (these N args):
        if hasattr(mod, 'NONTERMINAL_PARSE_ARGS'):
            vals, foz, rc = mod.NONTERMINAL_PARSE_ARGS(serr, bash_argv)
        else:
            vals, foz, rc = CHA_CHA()
        if vals is None:
            raise stop(rc)  # #cover-me:seen
        uow = _UoW(vals, foz, self.cmd_mod)
        queue.append(uow)

    def CHA_CHA():
        # Some commands (like the tags query) don't lend themselves easily to
        # a passive parse mode (stop on first unrecognized) So we hack it.
        # This is broken for any command that meaningfully parses a pipe anywhe

        i_s = reversed(range(1, len(bash_argv)))
        found = None
        try:
            found = next(i for i in i_s if _PIPE == bash_argv[i])
        except StopIteration:  # ick/meh
            pass
        if found is None:  # if no pipe anywhere in the thing
            use_bash_argv = bash_argv
        else:
            use_bash_argv = bash_argv[found+1:]

            # Take the args off global bash_argv that you're processing
            for _ in range(0, len(use_bash_argv)):
                bash_argv.pop()  # lol
            # NOTE you leave the pipe on for #hereZ

        vals, foz, rc = self.cmd_mod.TERMINAL_PARSE_ARGS(serr, use_bash_argv)
        # track [#459.O] ☝️ 👇
        return vals, foz, rc  # #hi.

    _UoW = _nt('UnitOfWork', ('values', 'formals', 'properties'))

    def ff(self):
        return self.properties.__name__  # ..
    _UoW.to_moniker = ff

    queue = []

    self = main  # #watch-the-world-burn
    stop = _Stop
    try:
        return main()
    except stop as exe:
        return None, None, exe.args[0]  # #here3


# ==

def SPLAY_FORMAT_ADAPTERS__(stdout, stderr):
    """if the user passes the string "help" for the argument, display

    help for that format and terminate early. otherwise, do nothing.
    """

    o = stderr.write
    o('the filename extension can imply a format adapter.\n')
    o('(or you can specify an adapter explicitly by name.)\n')
    o('known format adapters (and associated extensions):\n')

    out = stdout.write  # imagine piping output (! errput) (Case3459DP)
    count = 0

    from kiss_rdb import collectionerer
    _ = collectionerer().SPLAY_STORAGE_ADAPTERS()

    for (k, ref) in _:
        _storage_adapter = ref()
        mod = _storage_adapter.module
        if mod.STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES:
            _these = mod.STORAGE_ADAPTER_ASSOCIATED_FILENAME_EXTENSIONS
            _these = ', '.join(_these)
            _surface = f'({_these})'
        else:
            _surface = '(schema-based)'

        _name = k.replace('_', '-')
        out(f'    {_name} {_surface}\n')
        count += 1
    o(f'({count} total.)\n')
    return 0  # _exitstatus_for_success


def normalize_collection_reference_(
        sin_sout, fmt, arg, STDIN_STDOUT, arg_moniker, error):

    # (#todo: this logic is repeated 1x in a test :[#459.M])

    if '-' == arg:
        if sin_sout.isatty() and 'STDIN' == STDIN_STDOUT:
            # (oops this one is asymmetrical)
            error(f"when {arg_moniker} is '-', {STDIN_STDOUT} must be a pipe")
        use_coll_ID = sin_sout
        if fmt is None:
            fmt = 'json'
    elif sin_sout.isatty():
        use_coll_ID = arg
    else:
        error(f"{STDIN_STDOUT} cannot be a pipe unless {arg_moniker} is '-'")
    return fmt, use_coll_ID


def external_functions_via_stderr_(serr, rscser=None):  # #testpoint
    # there's a design issue here. this is how we would get env vars in from
    # the "real world". in tests it's easiest to just pass in None here.
    # maybe in production too.. so this "service" of producing a monitor ends
    # up being un-DRY. #[#605.6] a resourceser. Also [sl] implements diff intrf

    if rscser:
        xx('see above')

    from script_lib.magnetics.error_monitor_via_stderr import func
    mon = func(serr, default_error_exitstatus=4)

    class my_resources:  # #class-as-namespace
        def produce_monitor():
            return mon  # for now it's always built b.c it's the only thing
    return my_resources


def resolve_input_collection_(sin, coll_path, listener):
    if sin.isatty():
        if '-' == coll_path:
            xx("not ok - when you pass '-' as path, STDIN must be non-intera")
        return _collection_via_path(coll_path, listener)
    if '-':
        return _json_collection_via(sin, listener)
    xx("not ok - if you want to read from STDIN pass '-'")


def _collection_via_path(coll_path, listener):
    from data_pipes import meta_collection_ as func
    mc = func()
    return mc.coll_via_path(coll_path, listener)


def _json_collection_via(f, listener=None):
    sa_mod = _json_storage_adapter()
    from kiss_rdb import collection_via_storage_adapter_and_path as func
    return func(sa_mod, f, listener)


def _json_storage_adapter():
    import data_pipes.format_adapters.json as module
    return module


# == Models

def _lol(orig_f):  # #decorator
    def use_f(*components):
        if not ptr:
            ptr.append(_nt(orig_f.__name__, orig_f()))
        return ptr[0](*components)
    ptr = []
    return use_f


@_lol
def _MinimalSchema():
    return ('field_name_keys',)


@_lol
def _MinimalEntity():
    return ('core_attributes',)


# == Smalls

def _load(key):
    from importlib import import_module
    mod = import_module(key, __name__)
    return mod


def formals_via_(itr, prog_name, subcommands=None):
    from script_lib.cheap_arg_parse import formals_via_definitions as func
    return func(itr, prog_name, subcommands)


def _contextmanager(orig_f):
    from contextlib import contextmanager as decorator
    return decorator(orig_f)


def _nt(symbol_name, attrs):
    from collections import namedtuple as nt
    return nt(symbol_name, attrs)


class _Stop(RuntimeError):
    pass


_desc_for_collection = 'usually a fileystem path to your collection'
_generic_error_returncode = 54321
_PIPE = '|'
this_screen_ = 'this screen'


def xx(msg=None):
    raise RuntimeError(''.join(('hello', * ((': ', msg) if msg else ()))))


# #history-B.4: introduce soft pipeline
# #history-A.5: lost almost all the stuff
# #history-A.4: become not executable any more
# #history-A.3: no more sync-side stream-mapping
# #history-A.2 can be temporary. as referenced.
# #history-A.1: begin become library, will eventually support "map for sync"
# #born.
