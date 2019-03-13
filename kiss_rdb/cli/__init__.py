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


@click.group()
def cli():
    # (you could output lines here and it will break help screens)
    pass


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
def traverse():
    """traverse the collection of entities in "storage order" and for every
    entity output exactly one line to STDOUT consisting of only the entity's
    internal identifier.

    (FOR DEVELOPMENT/DEBUGGING)
    we don't even know if we want this
    """

    click.echo('#open [#867.M] traverse')


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


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')

# #born.
