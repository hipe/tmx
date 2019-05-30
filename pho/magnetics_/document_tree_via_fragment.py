import re


is_dry = False  # hard-coded undocumented not-yet-fully-integrated opt. works


def document_tree_via_fragment(
        collection_path,
        fragment_IID,
        out_path,
        be_recursive,
        force_is_present,
        listener,
        ):

    assert(collection_path)

    from pho import errorer
    e = errorer(listener)

    # hard-coded, temporary requirements

    if out_path is None:
        return e('parameter_is_currently_required', '«out-path»')  # ..

    if fragment_IID is not None:
        return e('not_yet_implemented', "single-document mode")

    if not be_recursive:
        return e('not_yet_implemented',
                 'non-recursive (single-document) mode')

    # resolve the source (the collection)

    big_index = _big_index_via(collection_path, listener)
    if big_index is None:
        return

    # WHEN RECURSIVE, let's ..

    out_dir = out_path
    import os
    if not os.path.isdir(out_dir):
        return e('directory_must_exist', out_dir)

    # ..

    _doc_itr = big_index.TO_DOCUMENT_STREAM(listener)

    count_files_attempted = 0
    count_files_written = 0
    count_lines_written = 0
    count_bytes_written = 0  # NOTE not acutally bytes but characters

    seen = set()

    ok_to_write = None
    for doc in _doc_itr:
        count_files_attempted += 1

        facets = _facets_for_plublishing_via_doc(doc, listener)
        if facets is None:
            continue  # meh

        # filename

        filename = facets.filename
        if filename in seen:
            cover_me((
                f'multiple documents share the same generated fileanme: '
                f'{filename}'
                ))
        seen.add(filename)

        # make sure it's ok to write

        out_path = os.path.join(out_dir, filename)

        del ok_to_write
        if os.path.exists(out_path):
            if force_is_present:
                ok_to_write = True
            else:
                e('cannot_overwrite_file', f"(without «force») {out_path}")
                ok_to_write = None
                continue  # LOOK don't crap out, keep going
        else:
            ok_to_write = True
        assert(ok_to_write)

        # flush

        if is_dry:
            open_file = _MOVE_ME()
        else:
            open_file = open(out_path, 'w')

        with open_file as io:

            def write_line(line):
                nonlocal count_lines_written
                nonlocal count_bytes_written
                count_lines_written += 1
                count_bytes_written += io.write(line)

            for line in facets.to_frontmatter_lines():
                write_line(line)

            for line in doc.TO_LINES(listener):
                write_line(line)

        count_files_written += 1

    def f():
        _message = (
                f'wrote {count_files_written}'
                f' of {count_files_attempted} files'
                f' ({count_lines_written} lines,'
                f' ~{count_bytes_written} bytes)'
                )
        return {'message': _message}
    listener('info', 'structure', 'wrote_files', f)
    return True


def _facets_for_plublishing_via_doc(doc, listener):
    """In order to publish a document (that is, write it to a file), we need

    to derive some fields of meta-data from the document; things like a file
    name and frontmatter fields (see [#884]). For now we refer to all this
    little meta-data collectively as "facets for publishing". :#here1

    We do not make validations at the input-level because these requirements
    are more a concern of the particular publishing platform we happen to
    be targeting.
    """

    dt = doc.document_datetime
    if dt is None:
        _iid_s = doc.head_fragment_identifier_string
        reason = (
                f'head fragment {repr(_iid_s)} must have `document_datetime`'
                ' (this is liable to change eventually)'
                )
        from pho import emit_error
        emit_error(listener, 'missing_required_attribute', reason)
        return

    return _FacetsForPublishing(dt, doc)


class _FacetsForPublishing:
    # (described at #here1)

    def __init__(self, document_datetime, doc):

        # we don't care about efficiency here.
        # for readability we break it up into steps.

        document_title = doc.document_title

        # --

        # First, start with the document title.
        # (Assume it could be the empty string (but hopefully it can't).)

        _ = document_title

        # Then eliminate all invalid characters. (Note this will leave behind
        # any spaces that were formerly adjacet to invalid characters, and so
        # may result in runs of multiple spaces where before there were none.)
        # Also note: we are allowing thru [- _] (those three)

        _ = re.sub('[^-a-zA-Z0-9_ ]+', '', _)

        # Then convert long runs of space-like characters down to just one,
        # while also normalizing this into just one type of space-like char.

        _ = re.sub('[-_ ]+', '-', _)

        # Then, let's lowercase everything for normality

        _ = _.lower()

        # Then, give every file a common ugly head so they're easy to remove
        # from the terminal lol, and put that identifier in there in case the
        # document title was the empty string or whatever..

        def _pieces_for_filename():
            yield 'GENERATED'
            yield doc.head_fragment_identifier_string
            if len(_):
                yield _

        self.frontmatter_title = (
                f'{document_title} '
                f'({doc.head_fragment_identifier_string})'
                )

        # Finally, append the file extension

        _head = '-'.join(_pieces_for_filename())
        self.filename = f'{_head}.md'

        self.frontmatter_datetime = document_datetime

    def to_frontmatter_lines(self):

        # title

        s = self.frontmatter_title
        if re.match('["\n]', s):
            cover_me('titles with quotes or newlines')
            escaped_title = s.replace('"', '\\"')  # newline tho
        else:
            escaped_title = s

        # date

        _dt = self.frontmatter_datetime
        _document_datetime_formatted_for_hugo = _dt.isoformat()  # ..

        yield '---\n'
        yield f'title: "{escaped_title}"\n'
        yield f'date: {_document_datetime_formatted_for_hugo}\n'
        yield '---\n'


def _big_index_via(collection_path, listener):

    import kiss_rdb
    coll = kiss_rdb.COLLECTION_VIA_DIRECTORY(collection_path, listener)
    if coll is None:
        return

    from pho.magnetics_.big_index_via_collection import (
            big_index_via_collection,
            )

    return big_index_via_collection(coll, listener)


class _MOVE_ME:

    def __enter__(self):
        return _DUMMY_WRITER

    def __exit__(self, *_3):
        return False  # did not process


class _DUMMY_WRITER:  # #as-namespace-only
    def write(line):
        return len(line)


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')

# #born.
