import click


# (got rid of conditional requirement of option (require hub) at #history-A.3)


_empty_mapping = {}  # OCD


class _CommonFunctions:

    def __init__(self, collections_hub, injections):
        self.unsanitized_collections_hub = collections_hub
        self._injections = injections

    def release_these_injections(self, *names):
        o = self._injections
        del(self._injections)
        if o is None:
            return _empty_mapping
        else:
            return o.RELEASE_THESE(names)

    def collection_via_unsanitized_argument(
            self, collection_argument,
            listener,
            **injections,
            ):

        # can't assume hub any more (#history-A.3)
        s = self.unsanitized_collections_hub
        if s is None:
            coll_path = collection_argument
        else:
            import os.path as os_path
            coll_path = os_path.join(s, collection_argument)

        from kiss_rdb import collection_via_path_
        return collection_via_path_(coll_path, listener, **injections)

    def build_monitor(self):
        return _Monitor(
                _express_error_structure, _echo_error, _express_info_structure)


def _express_error_structure(echo_error_line, channel_tail, struct):
    # (Case6080)

    from ._case_adaptations import WHINE_ABOUT

    dim_pool = {k: struct[k] for k in struct.keys()}  # "diminishing pool"

    dim_pool.pop('errno', None)  # get rid of it, if any. was handled #here2

    WHINE_ABOUT(echo_error_line, channel_tail, dim_pool)


def _express_info_structure(info_category, dct):  # (Case6129)

    # click.utils._default_text_stderr()
    _echo_error(dct['message'])


_coll_hub_opt = '--collections-hub'
_coll_hub_env_var = 'KSS_HUB'


# == BELOW

def cli_for_production():

    """this is where all the magic happens that we can't/don't test:

    where:
      - when a file write/rewrite is committed, actually commit the rewrite.
      - do something real and not contrived for the random number generator
      - NOTE all the print commands are messy and temporary #open [#873.J]

    (spiked without coverage at #history-A.1.)
    """

    def commit_file_rewrite(from_fh, to_fh):  # to fail is to corrupt
        import os
        os.rename(from_fh.name, to_fh.name)  # madman
        with open(from_fh.name, 'w+'):  # DOUBLE MADMAN - touch the temp
            pass  # file you just moved. (the tmp libary needs it to be there)

    def filesystem():
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

    from kiss_rdb import ModalityAdaptationInjections_
    _inj = ModalityAdaptationInjections_(
            random_number_generator=rng, filesystemer=filesystem)
    _ = cli.main(obj=_inj)
    cover_me(f'do you ever see this? {_}')
    return 0


@click.group()
@click.option(
        _coll_hub_opt, metavar='PATH',
        envvar=_coll_hub_env_var,
        help=f'The doo-hah with the foo-fah (env: {_coll_hub_env_var}).')
@click.pass_context
def cli(ctx, collections_hub):
    ctx.obj = _CommonFunctions(collections_hub, ctx.obj)  # NASTY see below

    """DISCUSSION #[#867.U]

    our only way to inject anything into our CLI is thru this cryptic 'obj'
    attribute. the semantics of this get overloaded, because we need to
    exploit it for two purposes: one, it's how we get arbitrary config into
    our CLI at all, and two, it's how our specific actions can access this
    and the rest. more at the ModalityAdaptationInjections_ class elsewhere.
    """


@cli.command()
@click.option('-val', '--value', nargs=2, multiple=True)
@click.argument('collection')
@click.pass_context
# #history-A.3 (did require hub)
def create(ctx, collection, value):
    """create a new entity in the collection
    given name-value pairs expressed by the --value option.
    """

    # begin boilerplate-esque
    cf = ctx.obj  # "cf" = common functions
    mon = cf.build_monitor()
    listener = mon.listener
    _inj = cf.release_these_injections('random_number_generator', 'filesystem')
    coll = cf.collection_via_unsanitized_argument(collection, listener, **_inj)
    if coll is None:
        return mon.some_error_code()
    # end

    _cuds = {name_s: val_s for name_s, val_s in value}  # ..

    doc_ent = coll.create_entity(_cuds, listener)

    # exact same thing as 2 others #here3

    if doc_ent is None:
        return mon.some_error_code()

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

    # begin boilerplate-esque
    cf = ctx.obj  # "cf" = common functions
    mon = cf.build_monitor()
    listener = mon.listener
    _inj = cf.release_these_injections('filesystem')
    coll = cf.collection_via_unsanitized_argument(collection, listener, **_inj)
    if coll is None:
        return mon.some_error_code()
    # end

    cuds = []
    for n, v in add:
        cuds.append(('create_attribute', n, v))
    for n, v in change:
        cuds.append(('update_attribute', n, v))
    for n in delete:
        cuds.append(('delete_attribute', n))

    before_after = coll.update_entity(internal_identifier, cuds, listener)

    # exact same thing as 2 others #here3:

    if before_after is None:
        return mon.some_error_code()

    before_ent, after_ent = before_after

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

    # begin boilerplate-esque
    cf = ctx.obj  # "cf" = common functions
    mon = cf.build_monitor()
    listener = mon.listener
    _inj = cf.release_these_injections('filesystem')
    coll = cf.collection_via_unsanitized_argument(collection, listener, **_inj)
    if coll is None:
        return mon.some_error_code()
    # end

    dct = coll.retrieve_entity(internal_identifier, listener)
    if dct is None:
        return mon.max_errno or 404  # (Case6064)  ##here1

    from kiss_rdb import dictionary_dumper_as_JSON_via_output_stream
    fp = click.utils._default_text_stdout()
    _dump = dictionary_dumper_as_JSON_via_output_stream(fp)
    _dump(dct)
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

    # begin boilerplate-esque
    cf = ctx.obj  # "cf" = common functions
    mon = cf.build_monitor()
    listener = mon.listener
    _inj = cf.release_these_injections('random_number_generator', 'filesystem')
    coll = cf.collection_via_unsanitized_argument(collection, listener, **_inj)
    if coll is None:
        return mon.some_error_code()
    # end

    doc_ent = coll.delete_entity(internal_identifier, listener)

    # exact same thing as 2 others #here3:

    if doc_ent is None:
        return mon.some_error_code()

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

    # begin boilerplate-esque
    cf = ctx.obj  # "cf" = common functions
    mon = cf.build_monitor()
    listener = mon.listener
    _inj = cf.release_these_injections('filesystem')
    coll = cf.collection_via_unsanitized_argument(collection, listener, **_inj)
    if coll is None:
        return mon.some_error_code()
    # end

    _iids = coll.to_identifier_stream(listener)

    echo = click.echo
    for iid in _iids:
        # (Case5934)
        echo(iid.to_string())

    if len(mon.error_categories_box.set):
        return mon.some_error_code()
    else:
        return success_exit_code_


@cli.command()
@click.argument('collection')
def select():
    """(experimental) something sorta like the SQL command. needs design
    """

    click.echo('#open [#867.M] select')


def _filter_by_tags():
    from . import filter_by_tags_
    return filter_by_tags_


@cli.command(short_help='reduce entity collection by tags')
@click.argument('collection')
@click.argument('query', nargs=-1)
@click.pass_context
# #history-A.3 (did require hub)
def filter_by_tags(ctx, collection, query):
    """EXPERIMENTAL. example: \\( "#open" and not "#cosmetic" \\) or "#critical"
    unfortunately you will have to follow the code to find the documentaton
    because there's no easy way for us to blit all of it here and there's a lot
    """

    return _filter_by_tags().filter_by_tags(ctx, collection, query)


# ==

class _Monitor:
    """this is an experimental example of a "modality-specific" adaptation

    of a listener. this is used similarly to the (at writing) only other
    class with "Monitor" in the name.

    for this monitor, we care about gathering simple "statistics" about all
    the emissions; like whether a certain kind of error was emitted, or what
    the highest level of "errno" was..
    """

    def __init__(
            self, express_error_structure, echo_error_line,
            express_info_structure):

        self._init_errno_stuff()

        error_categories_box = _Box()

        def listener(severity, *rest):
            # (Case5918)
            if 'error' == severity:
                when_error(rest)
            else:
                assert('info' == severity)
                when_info(rest)

        def when_info(rest):
            shape, info_category, *detail, payloader = rest
            assert('structure' == shape)
            dct = payloader()
            express_info_structure(info_category, *detail, dct)

        def when_error(rest):
            shape, error_category, *detail, payloader = rest

            error_categories_box.see(error_category)

            # express the emission appropriately for the shape
            if 'expression' == shape:

                # (error category & detail is disregarded here - meh for now)
                for line in payloader():
                    echo_error_line(line)
            elif 'structure' == shape:

                dct = payloader()
                if 'errno' in dct:
                    self._see_errno(dct['errno'])  # #here2

                express_error_structure(
                        echo_error_line, (error_category, *detail), dct)
            else:
                assert(False)

        self.listener = listener
        self.error_categories_box = error_categories_box

    def _init_errno_stuff(self):

        self.max_errno = None

        def see_errno_initially(errno):
            self.max_errno = errno
            self._see_errno = see_errono_subsequently

        self._see_errno = see_errno_initially

        def see_errono_subsequently(errno):
            if self.max_errno < errno:
                self.max_errno = errno

    def some_error_code(self):
        if self.max_errno is None:
            return _failure_exit_code_bad_request
        else:
            return self.max_errno


class _Box:  # OCD..

    def __init__(self):
        self.set = set()
        self.list = []

    def see(self, item):
        if item not in self.set:
            self.set.add(item)
        self.list.append(item)


def _echo_error(line):
    click.echo(line, err=True)


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


_failure_exit_code_bad_request = 400  # Bad Request lol ##here1
success_exit_code_ = 0


# #history-A.3: no more "require hub" decorator
# #history-A.2 as referenced
# #history-A.1: make first production-only injections for CLI
# #born.
