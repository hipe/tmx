import os
import re


def document_tree_via_fragment(
        out_tuple,
        fragment_IID_string,
        big_index,
        be_recursive,
        force_is_present,
        is_dry_run,
        listener,
        ):

    from pho import errorer
    e = errorer(listener)

    fw = _FileWriter(force_is_present, is_dry_run)

    if be_recursive:
        out_type, out_dir = out_tuple
        assert('output_directory_path' == out_type)
        return _when_recursive(
                fw, out_dir,
                big_index, e, listener)
    else:
        return _when_single_file(
                fw, out_tuple, fragment_IID_string,
                big_index, e, listener)


def _when_recursive(fw, out_dir, big_index, e, listener):
    if not os.path.isdir(out_dir):
        return e('directory_must_exist', out_dir)

    _doc_itr = big_index.TO_DOCUMENT_STREAM(listener)

    count_files_attempted = 0
    count_files_written = 0

    seen = set()

    for doc in _doc_itr:
        count_files_attempted += 1

        facets = _facets_for_publishing_via_doc(doc, listener)
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

        _out_file_path = os.path.join(out_dir, filename)
        _out_tuple = ('output_file_path', _out_file_path)

        _ok = fw.write_file(_out_tuple, facets, doc, listener)
        if _ok:
            count_files_written += 1

    fw.express_summary_into(
            listener, count_files_written, count_files_attempted)

    return True


def _when_single_file(
        fw, out_tuple, fragment_IID_string,
        big_index, e, listener):

    doc = big_index.RETRIEVE_DOCUMENT(fragment_IID_string, listener)
    if doc is None:
        return

    facets = _facets_for_publishing_via_doc(doc, listener)
    if facets is None:
        return

    ok = fw.write_file(out_tuple, facets, doc, listener)
    if ok:
        fw.express_summary_into(listener, 1, 1)
    return ok


class _FileWriter:
    """meant to abstract those parts of writing files common to both

    single file and recursive mode..
    """

    def __init__(self, force_is_present, is_dry):
        self.count_bytes_written = 0
        self.count_lines_written = 0
        self.force_is_present = force_is_present
        self.is_dry = is_dry
        if is_dry:
            import modality_agnostic.io as io_lib
            self._dry_open_file = io_lib.write_only_IO_proxy(
                    write=lambda x: None,
                    on_OK_exit=lambda: None)

    def express_summary_into(
            self, listener, count_files_attempted, count_files_written):
        def f():
            _message = (
                    f'wrote {count_files_written}'
                    f' of {count_files_attempted} files'
                    f' ({self.count_lines_written} lines,'
                    f' ~{self.count_bytes_written} bytes)'
                    )
            return {'message': _message}
        listener('info', 'structure', 'wrote_files', f)

    def write_file(self, out_tuple, facets, doc, listener):

        out_type, out_value = out_tuple
        if 'output_file_path' == out_type:
            out_path = out_value
            if os.path.exists(out_path) and not self.force_is_present:
                _emit_error(listener, 'cannot_overwrite_file',
                            f"(without «force») {out_path}")
                return
            is_stdout_probably = False
        else:
            assert('open_output_filehandle' == out_type)
            assert(not self.is_dry)  # check at higher level
            open_file = out_value
            is_stdout_probably = True
        del out_value

        def lines():
            for line in facets.to_frontmatter_lines():
                yield line

            for line in doc.TO_LINES(listener):
                yield line

        if is_stdout_probably:
            pass
        elif self.is_dry:
            open_file = self._dry_open_file
        else:
            open_file = open(out_path, 'w')

        with open_file as io:
            for line in lines():
                self.count_lines_written += 1
                self.count_bytes_written += io.write(line)
        return True


def _facets_for_publishing_via_doc(doc, listener):
    """In order to publish a document (that is, write it to a file), we need

    to derive some fields of meta-data from the document; things like a file
    name and frontmatter fields (see [#884]). For now we refer to all this
    little meta-data collectively as "facets for publishing". :#here1

    Here you see some validations effecting the validation of
    publishing-platform-specific required fields. We do not make these
    validations at the input phase (i.e when fragments are created/edited)
    because these requirements
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
        _emit_error(listener, 'missing_required_attribute', reason)
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


def _emit_error(listener, channel_tail, reason):
    from pho import emit_error
    return emit_error(listener, channel_tail, reason)


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')

# #born.