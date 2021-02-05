from os import path as _os_path
import re as _re


def generate_markdown(collection_path, listener, NCID=None):
    """Hi, hugo adapter here.

    This generates hugo-flavored markdown files from notecards.

    A typical output-directory might be: zub2/content/posts

    Args:
        NCID: If notecard ID is a document head, output only that document.
              If it's a part of a document, same.
              If it's a document container type (book, book part, chapter,
              chapter section etc), outputs the documents in order.
              If none, attempt to produce every document in the collection.
    """
    # (NOTE the above is parsed and merged in to UI (CLI) (all experimental))

    def main():
        if o.node_is_specified_and_part_of_document:
            return do_single_document()
        if o.node_is_specified_and_document_tree:
            return do_multiple_documents()
        if NCID:
            o.complain_about_no_container()
            raise stop_running()
        return attempt_every_document()

    def attempt_every_document():
        return do_document_tree(o.PROCURE_EXACTLY_ONE_DOCUMENT_TREE())

    def do_multiple_documents():
        ti = o.RELEASE_DOCUMENT_TREE()
        return do_document_tree(ti)

    def do_document_tree(ti):
        start, stop = ti.document_depth_minmax
        reason = None
        if start != stop:
            reason = f"can't do different document depths ({start}, {stop})"
        elif 1 < start:
            reason = f"for now, afraid of deep document trees (?) ({start})"
        if reason:
            listener('error', 'expression', 'document_depths', lambda: (reason,))  # noqa: E501
            yield ('adapter_error',)
            return

        bcoll = o.read_only_business_collection
        for ptup, ad in ti.TO_ABSTRACT_DOCUMENTS(bcoll):
            for direc in _directives_via_AD(ptup, ad, listener):
                yield direc

    def do_single_document():
        ad = o.RELEASE_ABSTRACT_DOCUMENT()
        return _directives_via_AD((), ad, listener)

    class stop_running(RuntimeError):
        pass

    from pho.notecards_.big_index_via_collection import NarrativeFacilitator
    o = NarrativeFacilitator(NCID, collection_path, listener, stop_running)

    try:
        return main()
    except stop_running:
        return (('adapter_error',),)  # not sure


def _directives_via_AD(ptup, ad, listener):
    fm = _facets_for_publishing_via_doc(ad, listener)
    if fm is None:
        yield ('adapter_error',)
        return

    def lines_of_this_one_file():
        for line in fm.to_frontmatter_lines():
            yield line
        for line in ad.TO_HOPEFULLY_AGNOSTIC_MARKDOWN_LINES():
            yield line

    path_tail = _os_path.join(*ptup, fm.filename)
    yield 'markdown_file', path_tail, lines_of_this_one_file()


def _facets_for_publishing_via_doc(doc, listener):
    """In order to publish a document (that is, write it to a file), we need

    to derive some fields of meta-data from the document; things like a file
    name and frontmatter fields (see [#884]). For now we refer to all this
    little meta-data collectively as "facets for publishing". :#here1

    Here you see some validations effecting the validation of
    publishing-platform-specific required fields. We do not make these
    validations at the input phase (i.e when notecards are created/edited)
    because these requirements
    are more a concern of the particular publishing platform we happen to
    be targeting.
    """

    dt = doc.document_datetime

    if dt is None:
        dt = '1925-05-19 01:02:03+06:00'

    if False:  # this is what we want but testing it is too annoying for now
        _whine_about_datetime(listener, doc)
        return

    return _FacetsForPublishing(dt, doc)


class _FacetsForPublishing:
    # (described at #here1)

    def __init__(self, document_datetime, doc):
        self.__init_filename_and_frontmatter_title(doc)

        # toml (like json, sort of) has built-in types; eno does not. The
        # KISS-iest thing would seem to be to proscribe that we use the any
        # available built-in types in the expected way. (Especially when you're
        # hand-editing files, not to support built-in types would seem to be
        # a major usability/design flaw, in a poka-yoke sense.)

        # But doing this presents a nasty smell of its own: with no other
        # provisions, a migration to a new storage adapter can break the
        # fundamental storage-retrieval contract: get back out exactly what
        # you put in ("data-integrity"?).

        # .#wish [#873.20] is our would-be solution to this: a schema-types
        # layer that communicates to the adapter what the expected type is and
        # the adapter acts in an adapter-appropriate way to fulfill the
        # contract (or fail loudly and clearly when it can't (yet)).

        # Barring that, we have this band-aid:

        assert(isinstance(document_datetime, str))
        from datetime import datetime  # reminder: toml does RFC3339
        self.frontmatter_datetime = datetime.fromisoformat(document_datetime)

    def __init_filename_and_frontmatter_title(self, doc):

        # we don't care about efficiency here.
        # for readability we break it up into steps.

        document_title = doc.document_title

        # --

        # First, start with the document title.
        # (Assume it could be the empty string (but hopefully it can't).)

        _ = document_title

        # Then eliminate all invalid characters. (Note this will leave behind
        # any spaces that were formerly adjacent to invalid characters, and so
        # may result in runs of multiple spaces where before there were none.)
        # Also note: we are allowing thru [- _] (those three)

        _ = _re.sub('[^-a-zA-Z0-9_ ]+', '', _)

        # Then convert long runs of space-like characters down to just one,
        # while also normalizing this into just one type of space-like char.

        _ = _re.sub('[-_ ]+', '-', _)

        # Then, let's lowercase everything for normality

        _ = _.lower()

        # Then, give every file a common ugly head so they're easy to remove
        # from the terminal lol, and put that identifier in there in case the
        # document title was the empty string or whatever..

        def _pieces_for_filename():
            yield 'GENERATED'
            yield doc.head_notecard_identifier_string
            if len(_):
                yield _

        self.frontmatter_title = (
                f'{document_title} '
                f'({doc.head_notecard_identifier_string})')

        # Finally, append the file extension

        _head = '-'.join(_pieces_for_filename())
        self.filename = f'{_head}.md'

    def to_frontmatter_lines(self):

        # title

        s = self.frontmatter_title
        if _re.match('["\n]', s):
            xx('titles with quotes or newlines')
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


def _whine_about_datetime(listener, doc):
    def payloader():
        _ = doc.head_notecard_identifier_string
        _ = f'head notecard {repr(_)} must have `document_datetime`' \
            ' (this is liable to change eventually)'
        return {'reason_tail': _}
    listener('error', 'structure', 'missing_required_attribute', payloader)


HELLO_I_AM_AN_ADAPTER_MODULE = True


def xx(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')

# #history-B.5 removed old code
# #history-B.4 as adapter, hierarchical containter type & narrative faciliator
# #born.
