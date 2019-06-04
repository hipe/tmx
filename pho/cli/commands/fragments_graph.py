from pho.cli import pass_context
import click


@click.command(
        'NO SEE',
        short_help='Output a graph-viz digraph of the whole collection.',
        help=(
            "Show every relationship between every fragment in the collection."
            )
        )
@pass_context
def cli(
        ctx,
        ):
    listener = ctx.build_structure_listener()

    path = ctx.user_provided_collection_path
    if path is None:
        from pho import emit_error
        emit_error(listener, 'parameter_is_currently_required',
                   '«collection-path»')  # ..
        return

    from pho.magnetics_.graph_via_collection import (
            output_lines_via_collection_path)

    echo_out = click.echo

    for line in output_lines_via_collection_path(path, listener):
        echo_out(line)

# #born.
