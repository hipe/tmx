def _normalize_sys_path():
    """make the system path what we know we want it to be, not what python

    thinks it should be. at present this is necessary in every entrypoint
    file and is justified in [#019].
    """

    from sys import path as a
    from os import path

    dn = path.dirname

    cli_dir = dn(path.abspath(__file__))
    _suproj_dir = dn(cli_dir)
    mono_repo_dir = dn(_suproj_dir)
    _yikes = path.join(mono_repo_dir, 'my-venv', 'bin')

    if _yikes == a[0]:
        a[0] = mono_repo_dir
    elif mono_repo_dir == a[0]:
        pass  # when run under unit test, OK
    else:
        raise Exception('something strange about path')


_normalize_sys_path()
import click  # noqa: E402

# == HERE WE DEFINE OUR OWN DECORATORS (mostly)


def require_hub(orig_f):
    """decorator for ALL endpoints that need the "collectons hub" (so, most).

    DISCUSSION: although DRY, it feels under-abstracted (i.e. cluttered).
    """

    def f(ctx, **kwargs):

        cf = ctx.obj  # common functions
        if cf.unsanitized_collections_hub is not None:

            # (this handling of ec should be in its own decorator..)
            ec = orig_f(ctx, **kwargs)
            assert(isinstance(ec, int))
            if ec is 0:
                return 0  # (Case6129) (test_100)
            else:
                return __crazy_time(ec)  # should throw an exception

        _ = (f"'{ctx.info_name}' requires this option "
             "(under the top-level command) "
             f"(or set the {_coll_hub_env_var} environment variable).")

        raise click.MissingParameter(
                _,
                param_hint=(_coll_hub_opt,),
                param_type='option',
                )

    f.__name__ = orig_f.__name__  # click needs the name to be "right"
    f.__doc__ = orig_f.__doc__  # same! (covered)
    return f


def __crazy_time(ec):
    """track complaints about click #[#867.L]:

    - we shouldn't have to raise an exception to control the exit code
    - we shouldn't have to provide a message alongside an exit code
    """

    from click.exceptions import ClickException as e_class
    e = e_class(f'(as explained above) (exit status: {ec})')
    e.exit_code = ec  # thank goodness this works
    raise e


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
            injections_dictionary=_empty_mapping,
            ):

        from kiss_rdb.storage_adapters_.toml import (
                schema_via_file_lines as lib)
        import os.path as os_path

        hub = self.unsanitized_collections_hub

        # derive collection path
        coll_path = os_path.join(hub, collection_argument)

        # derive the schema
        schema = lib.SCHEMA_VIA_COLLECTION_PATH(coll_path, listener)
        if schema is None:
            return  # (Case5918)

        # money
        from kiss_rdb.storage_adapters_.toml import (
                collection_via_directory as lib)
        return lib.collection_via_directory_and_schema(
                collection_directory_path=coll_path,
                collection_schema=schema,
                **injections_dictionary)

    def build_monitor(self):
        return _Monitor(
                _express_error_structure, _echo_error,
                _express_info_structure)


def _express_error_structure(error_category, struct):  # (Case6080)
    """FOR NOW, this is just a messy attempt at making contact with all the

    components we expect to see for different cases..

    eventually we will want per-action handlers to be integrated somehow
    """

    dim_pool = {k: struct[k] for k in struct.keys()}  # "diminishing pool"

    dim_pool.pop('errno', None)  # get rid of it, if any. was handled #here2

    if 1 == len(dim_pool):
        __express_just_reason(** dim_pool)
    else:
        assert('input_error' == error_category)
        # when the above fails, consider just adding it to the dictionary

        from . import _case_adaptations as cases
        cases.WHINE_ABOUT(_echo_error, dim_pool)


def __express_just_reason(reason):
    _echo_error(reason)


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
      - NOTE all the print commands are messy and temporary #todo-soon

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

    import kiss_rdb.storage_adapters_.toml.collection_via_directory as _
    _inj = _.INJECTIONS(random_number_generator=rng, filesystemer=filesystem)
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
    and the rest. more at the INJECTIONS class elsewhere.
    """


@cli.command()
@click.option('-val', '--value', nargs=2, multiple=True)
@click.argument('collection')
@click.pass_context
@require_hub
def create(ctx, collection, value):
    """create a new entity in the collection
    given name-value pairs expressed by the --value option.
    """

    # begin boilerplate-esque
    cf = ctx.obj  # "cf" = common functions
    mon = cf.build_monitor()
    listener = mon.listener
    _inj = cf.release_these_injections('random_number_generator', 'filesystem')
    col = cf.collection_via_unsanitized_argument(collection, listener, _inj)
    if col is None:
        return mon.some_error_code()
    # end

    _cuds = tuple(('create', name_s, val_s) for name_s, val_s in value)

    doc_ent = col.create_entity(_cuds, listener)

    # exact same thing as 2 others #here3

    if doc_ent is None:
        return mon.some_error_code()

    sout = click.utils._default_text_stdout()

    # (hand-written confrmation message gone at #history-A.2)

    for line in doc_ent.to_line_stream():
        sout.write(line)

    return _success_exit_code


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
@require_hub
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
    col = cf.collection_via_unsanitized_argument(collection, listener, _inj)
    if col is None:
        return mon.some_error_code()
    # end

    cuds = []
    for n, v in add:
        cuds.append(('create', n, v))
    for n, v in change:
        cuds.append(('update', n, v))
    for n in delete:
        cuds.append(('delete', n))

    before_after = col.update_entity(internal_identifier, cuds, listener)

    # exact same thing as 2 others #here3:

    if before_after is None:
        return mon.some_error_code()

    before_ent, after_ent = before_after

    sout = click.utils._default_text_stdout()

    # #history-A.2 got rid of manually created message

    for line in after_ent.to_line_stream():
        sout.write(line)

    return _success_exit_code


@cli.command()
@click.argument('collection')
@click.argument('internal-identifier')
@click.pass_context
@require_hub
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
    col = cf.collection_via_unsanitized_argument(collection, listener)
    if col is None:
        return mon.some_error_code()
    # end

    dct = col.retrieve_entity(internal_identifier, listener)
    if dct is None:
        return mon.max_errno or 404  # (Case6064)  ##here1

    # (Case6080):
    # don't get overly attached to the use of JSON here.
    # it's done out of the convenience of implementation here..

    import json
    fp = click.utils._default_text_stdout()  # oh my
    json.dump(dct, fp=fp, indent=2)
    fp.write('\n')  # (the above doesn't)

    return _success_exit_code


@cli.command()
@click.argument('collection')
@click.argument('internal-identifier')
@click.pass_context
@require_hub
def delete(ctx, collection, internal_identifier):
    """delete the entity from the collection
    given the entity's internal identifier
    """

    # begin boilerplate-esque
    cf = ctx.obj  # "cf" = common functions
    mon = cf.build_monitor()
    listener = mon.listener
    _inj = cf.release_these_injections('random_number_generator', 'filesystem')
    col = cf.collection_via_unsanitized_argument(collection, listener, _inj)
    if col is None:
        return mon.some_error_code()
    # end

    doc_ent = col.delete_entity(internal_identifier, listener)

    # exact same thing as 2 others #here3:

    if doc_ent is None:
        return mon.some_error_code()

    sout = click.utils._default_text_stdout()
    serr = click.utils._default_text_stderr()

    serr.write('deleted:\n')

    for line in doc_ent.to_line_stream():
        sout.write(line)

    return _success_exit_code


@cli.command()
@click.argument('collection')
@click.pass_context
@require_hub
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
    col = cf.collection_via_unsanitized_argument(collection, listener)
    if col is None:
        return mon.some_error_code()
    # end

    _iids = col.to_identifier_stream(listener)

    echo = click.echo
    for iid in _iids:
        # (Case5934)
        echo(iid.to_string())

    # (make contact with what went wrong..)
    if len(mon.error_categories_box.set):
        assert(mon.error_categories_box.list == ['argument_error'])
        return mon.some_error_code()
    else:
        return _success_exit_code


@cli.command()
@click.argument('collection')
def select():
    """(experimental) something sorta like the SQL command. needs design
    """

    click.echo('#open [#867.M] select')


@cli.command()
@click.argument('collection')
def search():
    """WARNING may merge with select
    """

    click.echo('#open [#867.M] search')


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

        def listener(mood, *rest):
            # (Case5918)
            if 'error' == mood:
                when_error(rest)
            else:
                assert('info' == mood)
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

                if len(detail):
                    typ, = detail
                    if typ == 'no_such_directory':
                        pass  # #cover-me
                    else:
                        cover_me(f'type: {typ}')

                # (error category & detail is disregarded here - meh for now)
                for line in payloader():
                    echo_error_line(line)
            elif 'structure' == shape:

                if len(detail):
                    cover_me('meh')

                dct = payloader()
                if 'errno' in dct:
                    self._see_errno(dct['errno'])  # #here2
                express_error_structure(error_category, dct)
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
_success_exit_code = 0


# #history-A.2 as referenced
# #history-A.1: make first production-only injections for CLI
# #born.
