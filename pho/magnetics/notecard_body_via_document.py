# reminder: this is here because users ("") reference from their schema.rec
# files when they want to use body functions in this manner; so it needs to
# be part of our public API


from glob import glob as _glob
import os.path as _os_path
import re as _re


def REMOTE_NOTECARD_BODY(
        relpath, quoted_iden_expr, bent, memo, bcoll, listener):

    """this is a XXX [#882.Z] multiple collections.
    """

    md = _re.match(r'"([2-9A-HJ-LP-Z]{2,})"\Z', quoted_iden_expr)
    if md is None:
        def lines():
            yield (f"expected e.g '\"ABC\"' (use double quotes). had:"
                   f" {quoted_iden_expr!r}")
        listener('error', 'expression', 'value_function_value_error', lines)
        return
    eid, = md.groups()

    valueser = _value_producer_controller(listener, memo, bcoll)
    coll = valueser.collection_via_relpath(relpath)
    body = coll.retrieve_entity(eid, listener).core_attributes['body']
    assert body
    return (body,)


def func(directory, iden_expr, bent, memo, bcoll, listener, just_path=False):

    def main():
        if '[' == iden_expr[0]:
            doc_abspath = expand_path_from_identifier()
        elif _re.match(r'[A-Za-z0-9_-]+\.md\Z', iden_expr):  # ..
            doc_abspath = _os_path.join(produce_directory_abspath(), iden_expr)
        elif _re.match(r'[A-Za-z0-9_./-]+\.md\Z', iden_expr):
            cranky = _os_path.join(produce_directory_abspath(), iden_expr)
            doc_abspath = _os_path.realpath(cranky)
        else:
            _whine_about_shape(listener, iden_expr)
            return

        if just_path:
            return (doc_abspath,)  # wrapped value

        s = _notecard_body_via_document_path(doc_abspath, listener)
        if not s:
            xx('hmmmm wat do, maybe return none')
        return (s,)  # wrapped value

    def expand_path_from_identifier():
        iden = valueser.identifier_via_expression(iden_expr)
        dindex, dir_abspath = valueser.directory_index_and_abspath(directory)
        return procure_doc_abspath(iden, dindex, dir_abspath)

    def procure_doc_abspath(iden, dindex, dir_abspath):
        key = iden.to_inner_string_()
        if (doc_abspath := dindex.get(key)):
            return doc_abspath
        lines = tuple(_whine_big(iden, dindex, dir_abspath))
        xx(' '.join(lines))

    def produce_directory_abspath():
        return valueser.abspath_via_relpath(directory)

    valueser = _value_producer_controller(listener, memo, bcoll)

    try:
        return main()
    except _Stop:
        pass


def _value_producer_controller(listener, memo, bcoll):

    if 0 == len(memo):
        _init_memo(memo)

    class value_producer_controller:  # #class-as-namespace

        def collection_via_relpath(relpath):
            abspath = abspath_via_relpath(relpath)
            return produce_collection(abspath)

        def directory_index_and_abspath(dir_expr):
            dir_abspath = abspath_via_relpath(dir_expr)
            dindex = produce_directory_index(dir_abspath)
            return dindex, dir_abspath

        def identifier_via_expression(iden_expr):
            return produce_idener()(iden_expr)

    def produce_collection(abspath):
        dct = memo['remote_collection_via_abspath']
        if (coll := dct.get(abspath)):
            return coll
        coll = build_collection(abspath)
        if coll:
            dct[abspath] = coll
        return coll

    def build_collection(abspath):
        from kiss_rdb import \
            collection_via_storage_adapter_name_and_path as func
        return func('eno', abspath, listener)

    def produce_directory_index(absdir):
        mdct = memo['directory_listing_index_via_abspath']
        if (dd := mdct.get(absdir)) is None:
            dd = build_directory_index(absdir)
            mdct[absdir] = dd
        return dd

    def build_directory_index(absdir):

        gpath = _os_path.join(absdir, '[0-9]*.md')
        abspaths = _glob(gpath)
        if 0 == len(abspaths):
            xx(f"no documents in directory? - {absdir}")

        dct = {}
        for abspath in abspaths:
            bn = _os_path.basename(abspath)
            md = _entry_rx.match(bn)
            if md is None:
                xx(f"oops didn't match: {bn!r}")
            ss, = md.groups()
            if ss in dct:
                xx(f"oops, clobber, multiple docs with {ss!r}")
            dct[ss] = abspath
        return dct

    def abspath_via_relpath(directory):
        dct = memo['abs_path_via_doc_path']
        if (s := dct.get(directory)):
            return s
        cranky = _os_path.join(bcoll.collection_path, directory)
        abspath = _os_path.realpath(cranky)  # (see [#882.S.4])
        dct[directory] = abspath
        return abspath

    value_producer_controller.abspath_via_relpath = abspath_via_relpath

    def produce_idener():
        idener = memo.get('idener')
        if idener:
            if memo['listener_used_before'] != listener:
                xx('oops assumption failed. think about this')
            return idener
        idener = build_idener()
        memo['idener'] = idener
        memo['listener_used_before'] = listener
        return idener

    def build_idener():
        def idener(expr):
            iden = vendor(expr)
            if iden is None:
                raise _Stop()
            return iden

        from pho._issues import build_identifier_parser_ as func
        vendor = func(listener)
        return idener

    return value_producer_controller


def _notecard_body_via_document_path(path, listener):
    # Traverse the whole file now, because we are gonna peek and maybe
    # pop the final section

    lines = tuple(_notecard_body_lines_via_document_path(path))
    return ''.join(lines)  # life is pain


def _notecard_body_lines_via_document_path(path):

    with open(path) as lines:
        fm_lines, sections = _FM_lines_and_sects_via_lines(lines, path)

    # NOTE: doing NOTHING with frontmatter for now

    # Skip this one section if it exists
    if sections and 'document-meta' == sections[-1].header.label_text:
        sections.pop()

    from pho.magnetics_.abstract_document_via_native_markdown_lines \
        import AbstractDocument_ as func

    ad = func(None, tuple(sections), path=path)
    return ad.TO_HOPEFULLY_AGNOSTIC_MARKDOWN_LINES()


def _FM_lines_and_sects_via_lines(lines, path):
    from pho.magnetics_.abstract_document_via_native_markdown_lines \
        import PARSE_DOCUMENT_NEW_WAY_ as func

    fm_lines, sects = None, None
    itr = func(lines, path)
    for typ, x in itr:  # once
        assert 'unparsed_frontmatter_lines' == typ
        fm_lines = x

        def these():
            for typ, x in itr:
                assert 'markdown_header' == typ
                yield x
        sects = list(these())
        break
    return fm_lines, sects


def _whine_big(iden, dindex, dir_abspath):
    key = iden.to_inner_string_()

    from pho.magnetics_.text_via import \
        word_wrap_pieces_using_commas as func

    head = f"A document for {key!r} no found"
    these = tuple(func(dindex.keys(), 79))  # ick/meh
    leng = len(these)
    if leng:
        if 1 == leng and len(these[0]) < 20:
            yield '. Have: '.join((head, these[0]))
        else:
            yield ''.join((head, '. Have:'))
            for line in these:
                yield line
    else:
        sentence = 'Directory has no documents.'
        yield '. '.join((head, sentence))

    yield ''.join(('Directory: ', dir_abspath))


def _whine_about_shape(listener, expr):
    def lines():
        yield ("should look like node identifier ([#123]) or path entry: "
               f"{expr!r}")
    listener('error', 'expression', 'identifier_is_bad', lines)


def _init_memo(memo):
    memo['abs_path_via_doc_path'] = {}
    memo['remote_collection_via_abspath'] = {}
    memo['directory_listing_index_via_abspath'] = {}


_entry_rx = _re.compile(r'(\d{3}(?:\.[A-Z0-9])?)')  # not sure


class _Stop(RuntimeError):
    pass


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #born
