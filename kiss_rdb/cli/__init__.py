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
            if ec:
                __crazy_time(ec)
            return

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
    - whe shouldn't have to provide a message alongside an exit code
    """

    from click.exceptions import ClickException as e_class
    e = e_class(f'(as explained above) (exit status: {ec})')
    e.exit_code = ec  # thank goodness this works
    raise e


class _CommonFunctions:

    def __init__(self, collections_hub):
        self.unsanitized_collections_hub = collections_hub

    def collection_via_unsanitized_argument(self, collection_argument):
        import os.path as os_path
        _coll_path = os_path.join(
                self.unsanitized_collections_hub, collection_argument)

        from kiss_rdb.magnetics_ import collection_via_directory as lib
        return lib.collection_via_directory_and_filesystem(
                _coll_path, 'no fs yet')

    def three_for_listener(self):  # UGLY AS HELL

        error_categories_seen = set()
        error_categories = []

        def listener(*args):
            # (Case799_200)
            mood, shape, error_category, *chan_tail, payloader = args

            # for mood, for now there's only one mood
            assert('error' == mood)  # KIS for now

            # for error category, we simply check-off a box
            if error_category not in error_categories_seen:
                error_categories_seen.add(error_category)
                error_categories.append(error_category)

            # if there's business-level channel info, ok but cover it
            if len(chan_tail):
                business, = chan_tail
                if 'no_such_directory' == business:
                    pass
                else:
                    cover_me('ok fine but cover it - probably ignore it')

            # express the emission appropriately for the shape
            if 'expression' == shape:
                for line in payloader():
                    _echo_error(line)
            elif 'structure' == shape:
                _struct = payloader()
                _express_error_structure(error_category, _struct)
            else:
                assert(False)

        return error_categories_seen, error_categories, listener


def _express_error_structure(error_category, struct):  # (Case810)
    """messy for now..."""

    dim_pool = {k: struct[k] for k in struct.keys()}  # "diminishing pool"

    reason = dim_pool.pop('reason')  # assert

    if len(dim_pool):

        # for now, just making a bunch of overly attentive contact, as a
        # sort of specification assertion of what metadata is available

        assert('input_error' == error_category)  # hi.
        typ = dim_pool.pop('input_error_type')
        assert('not_found' == typ)  # hi.
        dim_pool.pop('identifier_string')
        dim_pool.pop('might_be_out_of_order')
        assert(0 == len(dim_pool))

    _echo_error(reason)


_coll_hub_opt = '--collections-hub'
_coll_hub_env_var = 'KSS_HUB'


# == BELOW

@click.group()
@click.option(
        _coll_hub_opt, metavar='PATH',
        envvar=_coll_hub_env_var,
        help=f'The doo-hah with the foo-fah (env: {_coll_hub_env_var}).')
@click.pass_context
def cli(ctx, collections_hub):
    ctx.obj = _CommonFunctions(collections_hub)


@cli.command()
@click.argument('collection')
def create():
    """create a new entity in the collection
    given THIS STUFF pray this will be easy
    """

    click.echo('#open [#867.M] create')


@cli.command()
@click.argument('collection')
@click.argument('internal-identifier')
def update():
    """update the entity in the collection
    given the entity's internal identifier
    and name-value pairs indicating the new this requires some design
    """

    click.echo('#open [#867.M] update')


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

    cf = ctx.obj
    error_categories_seen, error_categories, listener = cf.three_for_listener()

    col = cf.collection_via_unsanitized_argument(collection)

    dct = col.retrieve_entity(internal_identifier, listener)
    if dct is None:
        return 404  # (Case812)

    # (Case813):
    # don't get overly attached to the use of JSON here.
    # it's done out of the convenience of implementation here..

    import json
    fp = click.utils._default_text_stdout()  # oh my
    json.dump(dct, fp=fp, indent=2)
    fp.write('\n')  # (the above doesn't)

    return _success_exitstatus


@cli.command()
@click.argument('collection')
@click.argument('internal-identifier')
def delete():
    """delete the entity from the collection
    given the entity's internal identifier
    """

    click.echo('#open [#867.M] delete')


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

    cf = ctx.obj
    error_categories_seen, error_categories, listener = cf.three_for_listener()

    col = cf.collection_via_unsanitized_argument(collection)

    _iids = col.to_identifier_stream(listener)

    echo = click.echo
    for iid in _iids:
        # (Case799_200)
        echo(iid.to_string())

    if len(error_categories_seen):
        only_error_catetory, = error_categories  # ..
        assert('argument_error' == only_error_catetory)
        return 400  # 400 - Bad Request lol

    return _success_exitstatus


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


def _echo_error(line):
    click.echo(line, err=True)


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


_success_exitstatus = 0


# #born.
