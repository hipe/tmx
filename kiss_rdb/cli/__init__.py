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
            return orig_f(ctx, **kwargs)

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


class _CommonFunctions:

    def __init__(self, collections_hub):
        self.unsanitized_collections_hub = collections_hub


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
def get():
    """retrieve the entity from the collection
    given the entity's internal identifier.

    (the fact that this is named `get` and not `retrieve` is
    A) experimental and B) just so it's easier to type.)

    eventually this should be seen as a specialized form of select
    with a where clause mebbe
    """

    click.echo('#open [#867.M] get')


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
def traverse(cf, collection):
    """traverse the collection of entities in "storage order" and for every
    entity output exactly one line to STDOUT consisting of only the entity's
    internal identifier.

    (FOR DEVELOPMENT/DEBUGGING)
    we don't even know if we want this
    """

    """NOTE NOW #todo
    WE WILL ABSOLUTELY break these things up into functions
    """

    # make the thing

    import os.path as os_path
    col_path = os_path.join(cf.obj.unsanitized_collections_hub, collection)

    # make this other thind (unrelated)

    from kiss_rdb.magnetics_ import collection_via_directory as lib

    coll = lib.collection_via_directory_and_filesystem(col_path, 'xxx')

    # try this third thing

    error_categories_seen = set()
    error_categories = []

    def listener(*args):
        # (Case799_200)
        *chan, payloader = args
        assert('error' == chan[0])  # KIS for now
        error_category = chan[2]
        if error_category not in error_categories_seen:
            error_categories_seen.add(error_category)
            error_categories.append(error_category)
        for line in payloader():
            _echo_error(line)

    # get busy with this fourth thing

    xx = coll.to_identifier_stream(listener)

    for qq in xx:
        cover_me('heyo an item')

    if len(error_categories_seen):
        only_error_catetory, = error_categories  # ..
        from click.exceptions import UsageError as _ClickUsageError
        assert('argument_error' == only_error_catetory)
        raise _ClickUsageError('argument error (as explained above)')


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

# #born.
