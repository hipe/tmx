def CLI(sin, sout, serr, argv, enver=None):
    from script_lib.cheap_arg_parse import cheap_arg_parse
    return cheap_arg_parse(
            _do_CLI, sin, sout, serr, argv, tuple(_params()), enver=enver)


def _params():
    from pho.cli import CP_

    yield ('-c', '--collection-path=PATH', * CP_().descs)

    yield ('-r', '--recursive',
           'TEMPORARY/EXPERIMENTAL attempts to generate *all* documents "in"',
           'the collection. <fragment-ID> (required) is ignored.')

    yield '-F', '--force', 'Must be provided to overwrite existing file(s)'

    yield '-n', '--dry-run', "Don't actually write the output file(s)"

    yield 'fragment-id', 'The head fragment of the document to generate.'

    yield ('out-path',
           'The directory into which to write the files',
           '(whose filenames are derived from the head fragment headings).',
           'Use "-" to write to STDOUT (IN PROGRESS).')


def _do_CLI(
        monitor, sin, sout, serr, enver,
        collection_path, recursive, force, dry_run, fragment_id, out_path):

    """Generate a document or documents.

    Generate a document or documents from the fragments in the collection.
    """

    # simple normalizations (partly because #wish [#608.13] `<arg-like-this>?`)

    if out_path in ('-', ''):
        out_path = None

    if fragment_id == '':
        fragment_id = None

    listener = monitor.listener

    # ==

    def main():
        tup = resolve_conditionally_required_arguments()
        if tup is None:
            return
        can_be_dry, out_type, out_value = tup

        if dry_run and not can_be_dry:
            return _whine_about_dry_run(listener)

        from pho import big_index_and_collection_via_path
        tup = big_index_and_collection_via_path(collection_path, listener)
        if tup is None:
            return
        big_index, _ = tup

        # get money

        from pho.magnetics_.document_tree_via_fragment import \
            document_tree_via_fragment
        _ok = document_tree_via_fragment(
                out_tuple=(out_type, out_value),
                fragment_IID_string=fragment_id,
                big_index=big_index,
                be_recursive=recursive,
                force_is_present=force,
                is_dry_run=dry_run,
                listener=listener)

        assert _ok in (None, True)

    def resolve_conditionally_required_arguments():

        can_be_dry = True

        # a rule table with three inputs: (recursve, fragment_id, out_path)

        if recursive:
            if fragment_id is not None:
                # for recursive, you can't pass a fragment ID
                return error('is_recursive', 'has_frag_id')

            if out_path is None:
                # for recursive, output must be to directory not STDOUT
                return error('is_recursive', 'has_out_path')

            # write recursively to directory
            return can_be_dry, 'output_directory_path', out_path

        if fragment_id is None:
            # for single document, you must pass fragment ID
            return error('is_recursive', 'has_frag_id')

        if out_path is None:
            # write single document to STDOUT
            import sys
            can_be_dry = False
            return can_be_dry, 'open_output_filehandle', sys.stdout

        # write single document to file
        return can_be_dry, 'output_file_path', out_path

    def error(focus_one, focus_two):
        o = {'is_recursive': lambda: recursive,
             'has_frag_id': lambda: fragment_id is not None,
             'has_out_path': lambda: out_path is not None}
        kwargs = {k: o.pop(k)() for k in (focus_one, focus_two)}
        k, = o.keys()
        kwargs[k] = None
        _whine_big_flex(listener, kwargs)

    def resolve_collection_path():
        if collection_path is not None:
            return collection_path
        from pho.cli import CP_
        return CP_().require_collection_path(enver, listener)

    main()
    return monitor.exitstatus


def _whine_about_dry_run(listener):
    def _():
        return {'reason': '«dry-run» is meaningless when output is stdout'}
    listener('error', 'structure', 'parameter_conditionally_unavailable', _)


def _whine_big_flex(listener, kwargs):
    def payloader():
        _msg = ''.join(__whine_big_flex_pieces(**kwargs))
        return {'reason_tail': _msg}
    listener('error', 'structure', 'conditional_argument_error', payloader)


def __whine_big_flex_pieces(is_recursive, has_frag_id, has_out_path):

    these = ((has_frag_id, '«fragment-ID»', 'a'),
             (has_out_path, '«out-path» on the filesystem', 'an'))

    # eliminate the None's from our expression
    these = tuple(x for x in these if x[0] is not None)

    # for now life is easy in this regard
    assert(1 == len(these))

    (t_or_f, label, article), = these

    if is_recursive:
        pp = "for --recursive"
    else:
        pp = "when outputting a single document"

    if t_or_f:
        sp = f"""you can't pass {article} {label} (maybe use "" instead)"""
    else:
        sp = f'you must provide {article} {label}'

    yield pp
    yield ', '
    yield sp

# #history-A.1 rewrite during cheap arg parse not click
# #born.
