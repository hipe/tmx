#!/usr/bin/env python3 -W default::Warning::0

"""
generate a stream of JSON from
{raw_url}

(this is the content-producer of the producer/consumer pair)
"""

"""
orginally this scraped HTML but more conveniently the raw markdown is
available to us, exposed by github over plain old HTTP. so at #history-A.1
this refactored quite smoothly into pioneering the idea of scraping
markdown instead (sidestepping the #html2markdown problem).

This producer script is covered by multiple test files:
((Case2754DP), (Case3459DP))
"""


_raw_url = (
        'https://raw.githubusercontent.com'
        '/webmaven/python-parsing-tools/master/README.md')


def _CLI(sin, sout, serr, argv):
    formals = (
        ('-p', '--prepared-for-sync',
         'map certain fields from far to near (1 rename, 1 split)'),
        ('-s', '--for-sync',
         'translate to a stream suitable for use in [#447] syncing'),
        ('-h', '--help', 'this screen'))
    kwargs = {'description_valueser': lambda: {'raw_url': _raw_url}}
    from script_lib.cheap_arg_parse import cheap_arg_parse as func
    return func(_do_CLI, sin, sout, serr, argv, formals, **kwargs)


def _do_CLI(mon, sin, sout, serr, do_prepare, is_for_sync, rscer):
    mon = rscer().monitor
    listener = mon.listener

    if do_prepare or is_for_sync:
        opened = open_traversal_stream(listener)
    else:
        opened = _open_raw_traversal_stream(listener, None, False)

    with opened as dcts:
        if is_for_sync:
            dcts = stream_for_sync_via_stream(dcts)
        _ps_lib().flush_JSON_stream_into(sout, serr, dcts)

    return mon.exitstatus


_do_CLI.__doc__ = __doc__


stream_for_sync_is_alphabetized_by_key_for_sync = False


def stream_for_sync_via_stream(dcts):
    from kiss_rdb.storage_adapters.markdown import \
            simplified_key_via_markdown_link_er
    key_via = simplified_key_via_markdown_link_er()

    for dct in dcts:
        # #[#873.5] how sparseness (holes) must be filled lost at #history-A.4
        # lost at #history-A.3 or before was `simplify_keys_`

        yield (key_via(dct['name']), dct)


def open_traversal_stream(listener, markdown_path=None):
    # like the raw stream but..

    class ContextManager:
        def __enter__(self):
            self._em = None
            cm = _open_raw_traversal_stream(listener, markdown_path, True)
            self._em = cm
            with cm as itr:
                field_names = next(itr)
                dict_via = _dict_via_cels_via(field_names)

                for dct in itr:
                    vals = []  # was prettier before #history-B.1 but meh
                    for k in field_names:
                        if k not in dct:
                            break
                        vals.append(dct[k])
                    yield dict_via(vals)

        def __exit__(self, *_3):
            if self._em:
                return self._em.__exit__(self, *_3)

    return ContextManager()


def _dict_via_cels_via(far_field_names):
    _split_th_version = updated_and_version_via_string
    from data_pipes.magnetics.flat_map_horizontal_via_definition import \
        dictionary_via_cells_via_definition as func
    return func(
        unsanitized_far_field_names=far_field_names,
        special_field_instructions={
            'name': ('string_via_cel', lambda s: s),
            'parses': ('rename_to', 'grammar'),
            'updated': ('split_to', ('updated', 'version'), _split_th_version),
            },
        string_via_cel=lambda s: s)


class _open_raw_traversal_stream:  # #[#459.3] class as context manager

    def __init__(self, listener, markdown_path=None, do_field_names=False):
        self._raw_url = _raw_url
        self._do_field_names = do_field_names
        self._markdown_path = markdown_path
        self._listener = listener

    def __enter__(self):
        self._close_this = None
        from data_pipes.format_adapters.html.script_common \
            import cached_document_via as func
        doc = func(
            self._markdown_path, self._raw_url, 'markdown', self._listener)
        # ..
        opened = open(doc.cache_path)
        self._close_this = opened
        return _main(opened, self._do_field_names, self._listener)

    def __exit__(self, *_3):
        if not self._close_this:
            return
        return self._close_this.__exit__(*_3)


def _main(opened, do_field_names, listener):
    import kiss_rdb.storage_adapters_.markdown_table as sa
    from kiss_rdb import \
        single_file_collection_via_storage_adapter_and_path as func
    coll = func(sa, opened, listener)
    ci = coll.COLLECTION_IMPLEMENTATION

    action_stack = [
        ('end_of_file', lambda o: o.turn_yield_off()),  # don't yield this pc
        ('table_schema_line_ONE_of_two', xx),
        ('other_line', lambda o: o.turn_yield_off()),
        ('business_row_AST',),
        ('table_schema_line_TWO_of_two', lambda o: o.turn_yield_on()),
        ('table_schema_line_ONE_of_two',),
        ('head_line',),
        ('beginning_of_file',)]

    sxs = ci.sexps_via_action_stack(action_stack, listener)
    sx = next(sxs)
    assert 'table_schema_line_TWO_of_two' == sx[0]
    complete_schema = sx[2]
    ks = complete_schema.field_name_keys
    if do_field_names:
        yield ks
    for sx in sxs:
        typ, ast, _lineno = sx
        assert 'business_row_AST' == typ
        dct = ast.core_attributes_dictionary_as_storage_adapter_entity
        dct['name'] = ast.nonblank_identifier_primitive  # yikes
        yield dct


def updated_and_version_via_string(s):  # #testpoint (sort of)
    """
    given a string that has (usually) two pieces of information in it,
    break it up into the two pieces (defaultng to None for max one of them).

    we try not to be overly sentimental re: ourobouros center-of-the-universe
    spots, but if there was one it would be the part where we try to write a
    regex to parse all the various version expressions and date strings of a
    collection of parser generators 👹

    broad provisions:
      - we never have to check for empty string or blank string.
      - which is to say there is always some "content" to parse.

    heuristically:
      - if it has a date:
        - it's always anchored to the end
        - it's always of the psuedo format ' ?MM?/YYYY$'
        - which is to say always the month, never the day.
        - a date may appear alone or it may appear after a version expression.
        - there's the separator space IFF preceding version expression.
      - if it has a version expression:
        - circa one version expression doesn't have any periods
        - circa one version expression doesn't begin with a '^v ?'
        - if you strip out the any leading '^v ?' and any interceding periods,
          all version expressions are '^[0-9a-z]+'

    corollaries of all the above:
      - it has a date IFF it contains '/'. (it will have at most one).
      - after you lop off the any date matched by above (and any separator
        space), the any remaining head-anchored content is the version
        expression
      - we may simply want to normalize
    """

    import re

    final_date = None
    final_version = None
    unsanitized_version = None

    if '/' in s:
        md = re.search(r'( )?(\d\d?)/(\d{4})$', s)
        sep_s, month, year = md.groups()
        final_date = '%s-%02d' % (year, int(month))
        if sep_s is not None:
            unsanitized_version = s[0:md.start()]
    else:
        unsanitized_version = s

    if unsanitized_version is not None:
        md = re.search('^v (.+)', unsanitized_version)
        if md is None:
            final_version = unsanitized_version
        else:
            final_version = 'v%s' % md.group(1)

    return (final_date, final_version)


def _ps_lib():
    import data_pipes.format_adapters.html.script_common as x
    return x


def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))


if __name__ == '__main__':
    import sys as o
    exit(_CLI(o.stdin, o.stdout, o.stderr, o.argv))

# #history-B.1
# #history-A.4: rewrite: no more sync-side stream mapping
# #history-A.3: key simplifier found to be not covered and left broken
# #history-A.1: birth of the expression "collection meta-record"
# #history-A.1: wow rewrite half so it scrapes markdown not HTML
# #born
