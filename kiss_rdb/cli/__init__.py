import click


# (got rid of conditional requirement of option (require hub) at #history-A.3)


class _CommonFunctions:

    def __init__(self, collections_hub, injections):
        self.unsanitized_collections_hub = collections_hub
        self._injections = injections

    def resolve_collection(self, coll_path, *release_these):
        mon = self.build_monitor()
        kw = self.release_these_injections(*release_these)
        coll = self.collection_via_unsanitized_argument(
            coll_path, mon.listener, **kw)
        return coll, mon

    def release_these_injections(self, *names):
        o = self._injections
        del(self._injections)
        if o is None:
            return _empty_mapping
        assert(isinstance(o, dict))
        return {k: o[k] for k in names}

    def collection_via_unsanitized_argument(
            self, coll_path, listener, opn=None, rng=None):
        # can't assume hub any more (#history-A.3)
        s = self.unsanitized_collections_hub
        if s is not None:
            import os.path as os_path
            coll_path = os_path.join(s, coll_path)
        return self.collectioner.collection_via_path(
                coll_path, listener, opn=opn, rng=rng)

    @property
    def collectioner(self):
        from kiss_rdb import collectionerer
        return collectionerer()

    def build_monitor(self):
        return _Monitor(
                _express_error_structure, _echo_error, _express_info_structure)

    def echo_error_line(self, line):
        _echo_error(line)

    @property
    def stdin(self):  # .. #todo
        from sys import stdin
        return stdin

    @property
    def stdout(self):  # (get it from click because we hack override it)
        from click.utils import _default_text_stdout
        return _default_text_stdout()


_empty_mapping = {}  # OCD


def _express_error_structure(echo_error_line, channel_tail, struct):
    # (Case6080)

    from script_lib.magnetics.expression_via_structured_emission import \
        lines_via_channel_tail_and_details as func
    for line in func(channel_tail, struct):
        echo_error_line(line)


def _express_info_structure(info_category, dct):  # (Case6129)

    # click.utils._default_text_stderr()
    _echo_error(dct['message'])


_coll_hub_opt = '--collections-hub'
_coll_hub_env_var = 'KSS_HUB'


def cli_for_production():

    """this is where all the magic happens that we can't/don't test:

    where:
      - when a file write/rewrite is committed, actually commit the rewrite.
      - do something real and not contrived for the random number generator
      - NOTE all the print commands are messy and temporary #open [#873.J]

    (spiked without coverage at #history-A.1.)
    """

    def commit_file_rewrite(from_fh, to_fh):  # to fail is to corrupt
        raise RuntimeError('nuke')
        import os
        os.rename(from_fh.name, to_fh.name)  # madman
        with open(from_fh.name, 'w+'):  # DOUBLE MADMAN - touch the temp
            pass  # file you just moved. (the tmp libary needs it to be there)

    def opn(path, *rest):  # opn = alternative open
        print("DOING ORDINARY OPEN")  # #todo
        assert(not len(rest))
        return open(path)

    def filesystem():
        raise RuntimeError('nuke')  # #todo
        import kiss_rdb.magnetics_.filesystem as fs
        return fs.Filesystem_EXPERIMENTAL(
                commit_file_rewrite=commit_file_rewrite)

    def rng(pool_size):  # used only for CREATE
        assert(pool_size > 1)

        import random
        import time

        time_float = time.time()
        print(f'\nRANDOM SEED: {time_float}')
        random.seed(time_float)

        # currently, never returning 0 is our hackish way of leaving '222'
        # (the first identifier, as int 0) unoccupied (so int 0 is never an
        # ID.) this is a vv fragile way of doing this. #open [#867.V]

        num = random.randrange(1, pool_size)
        print(f'\nRANDOM: {num} of {pool_size}')
        return num

    # == BEGIN NASTY python annoyance - why does it auto-escape wtf
    #    (this only comes up in production, not in tests.) #[#867.W]
    from sys import argv
    for i in range(1, len(argv)):
        if '\\' in argv[i]:
            argv[i] = argv[i].encode('utf-8').decode('unicode_escape')  # ..
    # == END

    from sys import stdin
    _inj = {'stdin': stdin, 'rng': rng, 'opn': opn}
    _ = cli.main(obj=_inj)
    xx(f'do you ever see this? {_}')
    return 0


@click.group()
@click.option(
        _coll_hub_opt, metavar='PATH',
        envvar=_coll_hub_env_var,
        help=f'The doo-hah with the foo-fah (env: {_coll_hub_env_var}).')
@click.pass_context
def cli(ctx, collections_hub):
    ctx.obj = _CommonFunctions(collections_hub, ctx.obj)


# == BEGIN commands
#    (they are in the order we would like them to appear in in the UI,
#    but NOTE click sorts them alphabetically 🙃)


@cli.command()
@click.option('-val', '--value', nargs=2, multiple=True)
@click.argument('collection')
@click.pass_context
# #history-A.3 (did require hub)
def create(ctx, collection, value):
    """create a new entity in the collection
    given name-value pairs expressed by the --value option.
    """

    coll, mon = ctx.obj.resolve_collection(collection, 'rng', 'opn')
    if coll is None:
        return mon.errno

    listener = mon.listener

    attr_values = {name_s: val_s for name_s, val_s in value}  # ..
    cs = coll.create_entity(attr_values, listener)  # cs = custom struct

    # exact same thing as 2 others #here3

    if cs is None:
        return mon.errno

    doc_ent = cs.created_entity  # provision [#857.10]

    sout = click.utils._default_text_stdout()

    # (hand-written confrmation message gone at #history-A.2)

    for line in doc_ent.to_line_stream():
        sout.write(line)

    return success_exit_code_


@cli.command()
@click.option(
        '-add', nargs=2, multiple=True, metavar='<name>, <val>',
        help='the name/value to add. must not already be set.')
@click.option(
        '-change', nargs=2, multiple=True, metavar='<name>, <val>',
        help='the attribute to change. must already be set.')
@click.option(
        '-delete', multiple=True, metavar='<name>',
        help='the attribute to delete. must already be set.')
# #[#867.L] can't name the above "-del" if you wanted to
@click.argument('collection')
@click.argument('internal-identifier')
@click.pass_context
# #history-A.3 (did require hub)
def update(ctx, collection, internal_identifier, add, change, delete):
    """update the entity in the collection
    given the entity's internal identifier
    and one or more directives describing how to modify the entity's existing
    set of attributes. (is currently quite strict and particular :P)
    """

    coll, mon = ctx.obj.resolve_collection(collection, 'opn')
    if coll is None:
        return mon.errno

    cuds = []
    for n, v in add:
        cuds.append(('create_attribute', n, v))
    for n, v in change:
        cuds.append(('update_attribute', n, v))
    for n in delete:
        cuds.append(('delete_attribute', n))

    cs = coll.update_entity(internal_identifier, cuds, mon.listener)
    # cs = custom struct

    # exact same thing as 2 others #here3:

    if cs is None:
        return mon.errno

    assert cs.before_entity  # provision [#857.8]: custom result from update
    after_ent = cs.after_entity
    sout = click.utils._default_text_stdout()

    # #history-A.2 got rid of manually created message

    for line in after_ent.to_line_stream():
        sout.write(line)

    return success_exit_code_


@cli.command()
@click.argument('collection')
@click.argument('internal-identifier')
@click.pass_context
# #history-A.3 (did require hub)
def get(ctx, collection, internal_identifier):
    """retrieve the entity from the collection
    given the entity's internal identifier.

    (the fact that this is named `get` and not `retrieve` is
    A) experimental and B) just so it's easier to type.)

    eventually this should be seen as a specialized form of select
    with a where clause mebbe
    """

    coll, mon = ctx.obj.resolve_collection(collection, 'opn')
    if coll is None:
        return mon.errno

    ent = coll.retrieve_entity(internal_identifier, mon.listener)
    if ent is None:
        return mon.max_errno or 404  # (Case6064)  ##here1

    dct = ent.to_dictionary_two_deep()

    fp = click.utils._default_text_stdout()
    from kiss_rdb import dictionary_dumper_as_JSON_via_output_stream as func
    dump = func(fp)
    dump(dct)
    fp.write('\n')

    return success_exit_code_


@cli.command()
@click.argument('collection')
@click.argument('internal-identifier')
@click.pass_context
# #history-A.3 (did require hub)
def delete(ctx, collection, internal_identifier):
    """delete the entity from the collection
    given the entity's internal identifier
    """

    coll, mon = ctx.obj.resolve_collection(collection, 'rng', 'opn')
    if coll is None:
        return mon.errno

    cs = coll.delete_entity(internal_identifier, mon.listener)
    # cs = custom struct

    # exact same thing as 2 others #here3:

    if cs is None:
        return mon.errno

    doc_ent = cs.deleted_entity  # provision [#857.11]: custom result for delet

    sout = click.utils._default_text_stdout()
    serr = click.utils._default_text_stderr()

    serr.write('deleted:\n')

    for line in doc_ent.to_line_stream():
        sout.write(line)

    return success_exit_code_


@cli.command()
@click.argument('collection')
@click.pass_context
# #history-A.3 (did require hub)
def traverse(ctx, collection):
    """traverse the collection of entities in "storage order" and for every
    entity output exactly one line to STDOUT consisting of only the entity's
    internal identifier.

    (FOR DEVELOPMENT/DEBUGGING)
    we don't even know if we want this
    """

    coll, mon = ctx.obj.resolve_collection(collection, 'opn')
    if coll is None:
        return mon.errno

    echo = click.echo
    with coll.open_identifier_traversal(mon.listener) as idens:
        # (Case5934)
        itr = iter(idens)
        for iden in itr:
            if isinstance(iden, str):
                def str_via(x):
                    return x
            else:
                def str_via(x):
                    return x.to_string()
            echo(str_via(iden))

        for iden in itr:
            echo(str_via(iden))

    if len(mon.error_categories_seen):
        return mon.errno()
    else:
        return success_exit_code_


# -- commands concerned with CRUD of collections themselves (and adjacent)


@cli.command()
@click.option('--dry-run', '-n', is_flag=True, help="(dry run)")
@click.argument('adapter-name')
@click.argument('collection-path')
@click.pass_context
def create_collection(ctx, adapter_name, collection_path, dry_run):
    """Create a new collection given the storage adapter type. EXPERIMENTAL
    """

    listener = ctx.obj.build_monitor().listener
    from kiss_rdb import collectionerer
    collrr = collectionerer()
    sa = collrr.storage_adapter_via_format_name(adapter_name, listener)
    if sa is None:
        return
    coll = sa.CREATE_COLLECTION(collection_path, listener, dry_run)
    if coll is None:
        return
    import sys
    serr, = (getattr(sys, x) for x in ('stderr',))
    serr.write(f"created collection: {collection_path}\n")


# == END commands


class _Monitor:
    """this is an experimental example of a "modality-specific" adaptation

    of a listener. this is used similarly to the (at writing) only other
    class with "Monitor" in the name.

    for this monitor, we care about gathering simple "statistics" about all
    the emissions; like whether a certain kind of error was emitted, or what
    the highest level of "errno" was..

    .#open [#873.4] use that other one
    """

    def __init__(
            self, express_error_structure, echo_error_line,
            express_info_structure):

        self._init_errno_stuff()

        error_categories_seen = set()

        def listener(severity, *rest):
            # (Case5918)
            if 'error' == severity:
                when_error(rest)
            else:
                assert('info' == severity)
                when_info(rest)

        def when_info(rest):
            shape, info_category, *detail, payloader = rest
            if 'expression' == shape:
                express_expression(payloader)
                return
            assert('structure' == shape)
            dct = payloader()
            express_info_structure(info_category, *detail, dct)

        def when_error(rest):
            shape, error_category, *detail, payloader = rest
            self.OK = False

            if error_category not in error_categories_seen:
                error_categories_seen.add(error_category)

            # express the emission appropriately for the shape
            if 'expression' == shape:
                express_expression(payloader)
                return

            assert('structure' == shape)

            dct = payloader()
            if 'errno' in dct:
                self._see_errno(dct['errno'])  # #here2

            express_error_structure(
                    echo_error_line, (error_category, *detail), dct)

        def express_expression(payloader):
            # (error category & detail is disregarded here - meh for now)
            for line in payloader():
                echo_error_line(line)

        self.OK = True
        self.error_categories_seen = error_categories_seen
        self.listener = listener

    def _init_errno_stuff(self):

        self.max_errno = None

        def see_errno_initially(errno):
            self.max_errno = errno
            self._see_errno = see_errono_subsequently

        self._see_errno = see_errno_initially

        def see_errono_subsequently(errno):
            if self.max_errno < errno:
                self.max_errno = errno

    @property
    def errno(self):
        if self.max_errno is None:
            return _failure_exit_code_bad_request
        return self.max_errno

    @property
    def exitstatus(self):
        if self.max_errno is None:
            return success_exit_code_
        return self.max_errno


def _echo_error(line):
    click.echo(line, err=True)


def xx(msg=None):
    use_msg = ''.join(('cover/write me', *((': ', msg) if msg else ())))
    raise RuntimeError(use_msg)


_failure_exit_code_bad_request = 400  # Bad Request lol ##here1
success_exit_code_ = 0


# #history-B.1
# #history-A.3: no more "require hub" decorator
# #history-A.2 as referenced
# #history-A.1: make first production-only injections for CLI
# #born.
