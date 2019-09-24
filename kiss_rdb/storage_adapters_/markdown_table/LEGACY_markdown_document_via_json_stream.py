"""experiment.."""
# #[#874.8] file generates mardown the old way and may need to be the new way
# #[#874.5] file used to be executable script and may need further changes
# #[#874.9] file is LEGACY


def _run_CLI(sin, sout, serr, argv):

    from script_lib.magnetics import (
            common_upstream_argument_parser_via_everything)

    _exitstatus = common_upstream_argument_parser_via_everything(
            CLI_function=_CLI_body,
            std_tuple=(sin, sout, serr, argv),
            argument_moniker='<script>',
            ).execute()
    return _exitstatus


def _CLI_body(arg, prog, sout, serr):

    from script_lib.magnetics import listener_via_stderr
    listener = listener_via_stderr(serr)

    _coll_id = collection_identifier_via_parsed_arg_(arg)

    line_itr = _raw_lines_via_collection_identifier(_coll_id, listener)
    if line_itr is None:
        return 5

    for line_body in line_itr:
        sout.write(line_body)
        sout.write('\n')

    return 0


_CLI_body.__doc__ = __doc__


def _raw_lines_via_collection_identifier(coll_id, listener):  # #testpoint

    from kiss_rdb.cli.LEGACY_stream import collection_reference_via_ as _
    coll_ref = _(coll_id, listener)

    if coll_ref is None:
        return

    _ = coll_ref.open_traversal_stream(
            cached_document_path=None,  # no
            datastore_resources=None,
            listener=listener)

    return __traverse_raw_lines_via_traversal_stream(_)


def __traverse_raw_lines_via_traversal_stream(opened):

    with opened as dcts:
        branch_dct = next(dcts)
        assert(branch_dct['_is_branch_node'])

        stateful = _Stateful()

        table_lines_via = _build_table_linser(stateful, dcts)

        while True:
            for line in table_lines_via(branch_dct):
                yield line

            branch_dct = stateful.release_any_next_branch_node()
            if branch_dct is None:
                break

            yield ''


def _build_table_linser(stateful, dcts):

    def table_lines(branch_dct):

        yield f'### {branch_dct["label"]}'
        yield '|document node|about|'
        yield '|---|---|'  # black friday needs at least three

        if stateful.do_example_rows_once():
            yield '|(example)|#example|'  # ballsy

        for dct in dcts:
            if '_is_branch_node' in dct:
                stateful.receive_next_branch_node(dct)
                break
            _markdown_link = _markdown_link_via_dictionary(dct)
            yield f'|{_markdown_link}||'

    return table_lines


class _Stateful:

    def __init__(self):
        self._yes_do_once = True
        self._next_branch_node = None

    def do_example_rows_once(self):
        if self._yes_do_once:
            self._yes_do_once = False
            return True

    def receive_next_branch_node(self, dct):
        self._next_branch_node = dct

    def release_any_next_branch_node(self):
        x = self._next_branch_node
        self._next_branch_node = None
        return x


# (COMMON_FAR_KEY_SIMPLIFIER gone a #history-A.2)


def COMMON_NEAR_KEY_SIMPLIFIER(key_via_row_DOM, schema, listener):
    """
    my hands look like this:
        [Foo Fa 123](bloo blah)
    so hers can look like this:
        foofa123

    (transplated & simplified from its first home to here at #history-A.1)
    """

    def f(row_DOM):
        _orig_key = key_via_row_DOM(row_DOM)
        return simplified_key_via_markdown_link(_orig_key)
    simplified_key_via_markdown_link = simplified_key_via_markdown_link_er()
    return f


def simplified_key_via_markdown_link_er():  # #html2markdown
    # ich muss sein notwithstanding #history-A.1. (Case1640DP)

    def simplified_key_via_markdown_link(markdown_link_string):
        md = markdown_link_rx.search(markdown_link_string)
        if md is None:
            assert(False)  # failed to parse markdown link
        _norm_key = normal_via_str(md.group(1))
        return simple_key_via_normal_key(_norm_key)

    import re
    markdown_link_rx = re.compile(r'^\[([^]]+)\]\([^\)]*\)$')

    from kiss_rdb.LEGACY_normal_field_name_via_string import (
            normal_field_name_via_string as normal_via_str)

    return simplified_key_via_markdown_link


def simple_key_via_normal_key(normal_key):
    return normal_key.replace('_', '')


def common_mapper_(key, listener):
    def mapper(dct):
        md_link = _markdown_link_via_dictionary(dct)
        dct.pop('label')  # ..
        dct.pop('url')  # ..
        dct[key] = md_link  # ..
        return dct
    return mapper


def label_via_string_via_max_width(max_width):  # (Case0810DP)
    def f(s):
        use_s = s[:(max_width-1)] + '…' if max_width < len(s) else s
        # (could also be accomplished by that one regex thing maybe)
        use_s = use_s.replace('*', '\\*')
        use_s = use_s.replace('_', '\\_')
        return use_s
    return f


def url_via_href_via_domain(domain):  # (Case0810DP)
    def f(href):
        _escaped_href = href.replace(' ', '%20')
        return url_head_format.format(_escaped_href)
    url_head_format = '{}{}'.format(domain, '{}')  # or just ''.join((a,b))
    return f


def _markdown_link_via_dictionary(dct):
    return markdown_link_via(dct['label'], dct['url'])  # (Case1749DP)


def markdown_link_via(label, url):
    return f'[{label}]({url})'  # (you could get bit)..


def collection_identifier_via_parsed_arg_(arg):
    typ = arg.argument_type
    if 'stdin_as_argument' == typ:
        return __collection_identifier_via_stdin(arg.stdin)
    else:
        assert('path_as_argument' == typ)
        return arg.path  # [#873.I] ugly but meh


def __collection_identifier_via_stdin(stdin):
    import json
    _itr = (json.loads(s) for s in stdin)
    from data_pipes import my_contextlib as _
    return _.context_manager_via_iterator__(_itr)


if __name__ == '__main__':
    import sys as o
    o.path[0] = ''
    _exitstatus = _run_CLI(o.stdin, o.stdout, o.stderr, o.argv)
    exit(_exitstatus)

# #history-A.2: no more sync-side entity-mapping
# #history-A.1: MD table generation overhaul & becomes library when gets covg
# #born.
