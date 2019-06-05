from pho.cli import pass_context
import click


_help_for_frag_ID_and_out_path = (
    "To generate one particular document, don't pass --recursive. "
    '«fragment-ID» (required) indicates the head fragment of the document'
    ' to generate. '
    'Output is written to «out-path» if provided, otherwise STDOUT. '
    'You currently have the option to generate *all* documents "in" the '
    'collection (with --recursive) but NOTE this point of interface '
    'will likely be refined with experience once we have it. '
    'Pass no «fragment-ID». '
    '«out-path» (required) is the directory into which to write the files'
    ' (whose filenames are derived from the head fragment headings).'
    )


@click.command(
        'NO SEE',
        short_help='Generate a document or documents.',
        help=(
            "Generate a document or documents from"
            " the fragments in the collection."
            f' {_help_for_frag_ID_and_out_path}'
            )
        )
@click.option(
        '-R', '-r', '--recursive',
        is_flag=True,
        help=(
            'TEMPORARY/EXPERIMENTAL this option is likely to evolve (or'
            " perhaps go away entirely) once we figure some things out"
            ),
        )
@click.option(
        '-F', '--force',
        is_flag=True,
        help=(
            'Must be provided to overwrite existing file(s)'
            ),
        )
@click.option(
        '-n', '--dry-run',
        is_flag=True,
        help=(
            "Don't actually write the output file(s)"
            ),
        )
@click.argument(
        'fragment_id',
        metavar='[«fragment-ID»]',
        required=False,  # we require it conditionally by hand
        )
@click.argument(
        'out_path',
        metavar='[«out-path»]',
        required=False,
        )
@pass_context
def cli(
        ctx,
        fragment_id,
        out_path,
        recursive,
        force,
        dry_run,
        ):
    """Generates a document or documents."""

    listener = ctx.build_structure_listener()

    # == crazy custom argument combination parsing

    def e(is_recursive, frag_id_yes, out_path_yes):
        _msg = ''.join(_pieces(is_recursive, frag_id_yes, out_path_yes))
        _emit_error(listener, 'conditional_argument_error', _msg)

    # do the crazy rule-table-like thing
    # FFF x
    # FFT x
    # FTF x
    # FTT x
    # TFF x
    # TFT x
    # TTF x
    # TTT x

    can_be_dry = True

    collection_path = ctx.user_provided_collection_path
    if recursive:
        if fragment_id is None:
            if out_path is None:
                # TFF: in recursive mode you must provide a directory
                return e(True, None, False)
            else:
                assert(False)  # TFT: impossible to express
        elif out_path is None:
            # NOTE TTF: this is where you hack things to make it make sense
            # because you can't in real life express this on CLI w positionals
            out_tuple = ('output_directory_path', fragment_id)
            fragment_id = None
        else:
            # TTT: you cannot express fragment ID when doing recursive
            return e(True, True, None)
    elif fragment_id is None:
        # FFF: FFT: in single-file mode you must provide a fragment ID
        return e(False, False, None)
    elif out_path is None:
        # FTF: write one document to stdout
        import sys
        out_tuple = ('open_output_filehandle', sys.stdout)
        can_be_dry = False
    else:
        # FTT: write one document to file
        out_tuple = ('output_file_path', out_path)

    # ==

    # this one custom conditional validation

    if dry_run and not can_be_dry:
        _emit_error(listener, 'parameter_conditionally_unavailable',
                    '«dry-run» is meaningless when output is stdout')
        return

    # resolve the collection then the big index

    from pho import big_index_and_collection_via_path
    tup = big_index_and_collection_via_path(collection_path, listener)
    if tup is None:
        return
    big_index, _ = tup

    # get money

    from pho.magnetics_.document_tree_via_fragment import (
            document_tree_via_fragment)

    ok = document_tree_via_fragment(
            out_tuple=out_tuple,
            fragment_IID_string=fragment_id,
            big_index=big_index,
            be_recursive=recursive,
            force_is_present=force,
            is_dry_run=dry_run,
            listener=listener,
            )

    if ok is None:
        if ctx.DID_ERROR:
            import sys
            sys.exit(5678)  # anything not zero
        return

    assert(ok is True)


# == whiners

def _pieces(is_recursive, frag_id_yes, out_path_yes):

    these = (
            (frag_id_yes, '«fragment-ID»', 'a'),
            (out_path_yes, '«out-path»', 'an'),
            )

    # eliminate the None's from our expression
    these = tuple(x for x in these if x[0] is not None)

    # for now life is easy in this regard
    assert(1 == len(these))

    (t_or_f, label, article), = these

    # True = "you cannot pass a"
    # False = "you must provide a"

    if t_or_f:
        yield f'you cannot pass {article} {label}'
    else:
        yield f'you must provide {article} {label}'

    yield ' '

    if is_recursive:
        yield "in --recursive mode"
    else:
        yield "in single-file mode"


def _emit_error(listener, channel_tail, reason):
    from pho import emit_error
    return emit_error(listener, channel_tail, reason)

# #born.
