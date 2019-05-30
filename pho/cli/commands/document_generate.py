from pho.cli import pass_context
import click


@click.command(
        'NO SEE',
        short_help='Initializes a repo.',
        )
@click.option(
        '-o',
        'out_path',
        metavar='«out-path»',
        help=(
            'Write output to «out-path».'
            ' (interpreted as file or directory depending on other options.)'
            ),
        )
@click.option(
        '-R', '-r', '--recursive',
        is_flag=True,
        help=(
            'TEMPORARY/EXPERIMENTAL this option will go away or evolve'
            " once we figure some things out. For now, it's required."
            ),
        )
@click.option(
        '-F', '--force',
        is_flag=True,
        help=(
            'Must be provided to overwrite existing files.'
            ),
        )
@click.argument(
        'fragment_id',
        metavar='«fragment-ID»',
        required=False,
        )
@pass_context
def cli(
        ctx,
        out_path,
        recursive,
        force,
        fragment_id,
        ):
    """Generates a document or documents."""

    listener = ctx.build_structure_listener()

    from pho import emit_error

    path = ctx.user_provided_collection_path
    if path is None:
        emit_error(listener, 'parameter_is_currently_required',
                   '«collection-path»')  # ..
        return

    from pho.magnetics_.document_tree_via_fragment import (
            document_tree_via_fragment,
            )

    ok = document_tree_via_fragment(
            collection_path=path,
            fragment_IID=fragment_id,
            out_path=out_path,
            be_recursive=recursive,
            force_is_present=force,
            listener=listener,
            )

    if ok is None:
        if ctx.DID_ERROR:
            import sys
            sys.exit(5678)  # anything not zero
        return

    assert(ok is True)

# #born.
