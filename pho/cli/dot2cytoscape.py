#!/usr/bin/env python3

import re


def cli_for_production():
    import sys as o
    from os import environ
    exit(CLI(o.stdin, o.stdout, o.stderr, o.argv, environ).execute())


class CLI:
    def __init__(self, sin, sout, serr, argv, environ):

        def listener(severity, shape, name, lineser):
            if 'error' == severity:
                if 0 == self._exitstatus:
                    self._exitstatus = 1
                self._did_see_error = True
            elif 'debug' == severity:
                return
            else:
                assert('info' == severity)

            assert('expression' == shape)
            pcs = [name.replace('_', ' '), ': ']  # #[#608.7]
            itr = lineser()
            pcs.append(next(itr))
            pcs.append('\n')
            serr.write(''.join(pcs))
            for line in itr:
                serr.write(line)
                serr.write('\n')

        # attrs that can change state
        self._did_see_error = False
        self._exitstatus = 0

        # higher-level, derived attrs
        self._listener = listener

        # lower-level attrs
        self._ARGV = argv
        self._stdout = sout
        self._stderr = serr

    def execute(self):
        if self._parse_ARGV():
            self._execute_main()
        if self._did_see_error:
            self._stderr.write(f"see '{self._program_name} -h' for help\n")
        return self._exitstatus

    def _execute_main(self):
        import json

        def write_dict(dct):
            w(json.dumps(dct))

        w = self._stdout.write

        with open(self._input_path) as input_lines:
            dcts = _output_dicts_via_input_lines(input_lines, self._listener)

            for dct in dcts:
                w('[')
                write_dict(dct)
                break

            for dct in dcts:
                w(',\n')
                write_dict(dct)

        w(']\n')

    def _parse_ARGV(self):
        a = []
        for arg in self._ARGV[1:]:
            if '-' == arg[0]:
                if not self._parse_flag(arg):
                    return
            else:
                a.append(arg)

        leng = len(a)
        if 1 == leng:
            self._input_path, = a
            return True  # _OK

        if 0 == leng:
            def lines():
                yield _FILE_MONIKER
            self._listener('error', 'expression', 'expecting_argument', lines)
            return

        assert(1 < leng)

        def lines():
            yield a[1]
        self._listener('error', 'expression', 'unexpected_argument', lines)

    def _parse_flag(self, arg):
        # assume starts with '-'
        if arg in ('-h', '--help'):
            self._show_help()
            return

        def lines():
            yield arg
        self._listener('error', 'expression', 'unrecognized_option', lines)
        self._exitstatus = 3

    def _show_help(self):
        w = _line_writer_for(self._stderr)
        w(f'usage: {self._program_name} [--help] {_FILE_MONIKER}')

    @property
    def _program_name(self):
        return self._ARGV[0]


def _line_writer_for(io):
    def w(line):
        io.write(line)
        io.write('\n')
    return w


def _output_dicts_via_input_lines(lines, listener):

    ast = _AST_via_input_lines(lines, listener)
    if ast is None:
        return

    next_node_ID = _IdentifierIncrementer('n')
    next_edge_ID = _IdentifierIncrementer('e')

    local_group_ID_via_remote_node_ID = {}
    local_node_ID_via_remote_node_ID = {}

    itr = _intermediate_representation_via_AST(ast)
    typ, *rest = next(itr)

    while 'group' == typ:
        label, members = rest
        local_node_ID = next_node_ID()
        for remote_ID in members:
            local_group_ID_via_remote_node_ID[remote_ID] = local_node_ID

        yield _local_node(local_node_ID, label)
        typ, *rest = next(itr)

    while 'node' == typ:
        remote_node_ID, *attrs = rest
        local_node_ID = next_node_ID()

        local_node_ID_via_remote_node_ID[remote_node_ID] = local_node_ID

        parent_ID = local_group_ID_via_remote_node_ID.get(remote_node_ID)
        specials = []

        label = None
        seen_filled = False
        for k, v in attrs:
            if 'label' == k:
                label = v
            elif 'style' == k:
                assert('filled' == v)
                specials.append(('done', True))
                seen_filled = True
            else:
                assert('shape' == k)
                # and ignore

        if not seen_filled:
            specials.append(('done', False))

        if label is None:
            label = ''

        yield _local_node(local_node_ID, label, parent_ID, specials)

        typ, *rest = next(itr)

    while 'association' == typ:
        remote_source_ID, remote_dest_ID = rest
        local_source_ID = local_node_ID_via_remote_node_ID[remote_source_ID]
        local_dest_ID = local_node_ID_via_remote_node_ID[remote_dest_ID]
        yield _local_edge(next_edge_ID(), local_source_ID, local_dest_ID)
        typ, *rest = next(itr)

    assert 'done' == typ

    for _ in itr:
        assert(False)


def _local_node(local_node_ID, label, parent_ID=None, specials=()):
    data = {}
    data['id'] = local_node_ID
    if parent_ID is not None:
        data['parent'] = parent_ID
    data['label'] = label

    if len(specials):
        for k, v in specials:
            data[k] = v

    outer = {}
    outer['group'] = 'nodes'
    outer['data'] = data

    return outer


def _local_edge(local_edge_ID, local_source_ID, local_dest_ID):
    data = {'id': local_edge_ID, 'source': local_source_ID, 'target': local_dest_ID}  # noqa: E501
    return {'group': 'edges', 'data': data}


class _IdentifierIncrementer:

    def __init__(self, head):
        self._current_integer = 0
        self._head = head

    def __call__(self):
        self._current_integer += 1
        return f'{self._head}{self._current_integer}'


def _intermediate_representation_via_AST(ast):

    def on_node_forward_declaration(re):
        # these occur so graph viz places them in certain places. ignore..
        return ()

    def on_association_line(md):
        # we don't emit associations until the end
        associations_cached.append(md.groups())
        return ()

    associations_cached = []

    def on_subgraph(dct):
        line = dct['subgraph_label_line'][0]  # ..
        encoded_label = re.match('^  label="([^"]+)"$', line)[1]
        _ = tuple(md[1] for md in dct.get('node_forward_declaration', ()))
        yield 'group', encoded_label, _

    function_via_type = {
            'node_forward_declaration': on_node_forward_declaration,
            'subgraph': on_subgraph,
            'association_line': on_association_line,
            }

    for ihp in ast['interesting_head_phrase']:
        typ, data = ihp['interesting_head_item']
        for sexp in function_via_type[typ](data):
            yield sexp

    # ==

    for np in ast['node_phrase']:
        yield tuple(_node_tuple_parts(* np['node_phrase_body']))

    for lhs, rhs in associations_cached:
        yield 'association', lhs, rhs

    for ap in ast['association_phrase']:
        yield 'association', * ap['association_line'].groups()

    yield ('done',)


def _node_tuple_parts(typ, data):
    yield 'node'
    if 'single_line_node' == typ:
        yield data[1]
        for k, x in _name_value_big_hack(data[2]):
            yield k, x
        return

    assert('multi_line_node' == typ)
    yield data['open_node_line'][1]
    ss = [data['open_node_line'][2]]
    for qq in data.get('not_closing_node_line', ()):
        xx()
    ss.append(data['close_node_line'][1])
    big_string = ''.join(ss)
    for k, x in _name_value_big_hack(big_string):
        yield k, x


def _name_value_big_hack(string):
    leng = len(string)
    i = 0
    while True:
        md = _attr_head.match(string, i)
        key = md[1]
        i = md.span()[1]
        md = _attr_RHS.match(string, i)
        value = s.replace('\\n', '\n') if (s := md[1]) else md[2]
        yield key, value
        i = md.span()[1]
        if leng == i:
            break
        md = _one_or_more_space.match(string, i)
        i = md.span()[1]


_attr_head = re.compile('([a-z_]+)=')
_attr_RHS = re.compile('"([^"]*)"|([^ ]+)')
_one_or_more_space = re.compile('[ ]+')


def _AST_via_input_lines(lines, listener):  # #testpoint

    ast = None

    def debug_lines():
        yield f'{lineno}: {input_line[0:-1]}'

    lib = _grammar_lib()
    topmost_symbol, p = lib.WIP_TOPMOST_PARSER_VIA_GRAMMAR(_define_grammar)

    lineno = 0
    itr = iter(lines)
    for input_line in itr:
        lineno += 1

        listener('debug', 'expression', 'parsing_line', debug_lines)

        while True:
            direc = p.parse_line(input_line)
            if direc is None:
                direc = ('stop', None)
            direc_name, direc_data = direc

            if 'done_but_rewind' == direc_name:
                xx()

            break

        if 'stay' == direc_name:
            continue

        if 'stop' == direc_name:
            _express_expecting_from_top(
                    listener, input_line, lineno, topmost_symbol, p)
            return

        if 'done' == direc_name:
            ast = direc_data()
            break
        xx()

    if ast is None:
        xx()  # it never reached a done directivive

    for unexpected_line in itr:
        xx()  # had more lines than we expected

    return ast


def _express_expecting_from_top(listener, line, lineno, topmost_symbol, p):

    phrase = p.phrase_for_expecting(topmost_symbol)
    lines_via_words = _grammar_lib().lines_via_words

    def lines():
        for s in lines_via_words(words(), 60):
            yield s
        yield line

    def words():
        for w in phrase.to_words():
            yield w
        yield 'at'
        yield 'line'
        yield f"{lineno}:"

    listener('error', 'expression', 'expecting', lines)


def _define_grammar(g):
    define = g.define
    sequence = g.sequence
    alternation = g.alternation
    regex = g.regex

    n = '[A-Za-z0-9_]+'

    define('file', sequence(
        ('one', 'open_digraph_line'),
        ('zero_or_more', 'attribute_assignment_phrase'),
        ('one_or_more', 'interesting_head_phrase', 'keep'),
        ('one_or_more', 'node_phrase', 'keep'),
        ('one_or_more', 'association_phrase', 'keep'),
        ('one', 'close_digraph_line'),
        ('zero_or_one', 'multiline_comment')
    ))

    define('open_digraph_line', regex(r'^digraph [a-z] \{$'))

    define('attribute_assignment_phrase', sequence(
        ('one', 'single_line_attribute_assignment'),
        ('zero_or_more', 'ignorable_line'),
    ))

    define('single_line_attribute_assignment', regex('^[a-z_]+='))

    define('interesting_head_phrase', sequence(
        ('one', 'interesting_head_item', 'keep'),
        ('zero_or_more', 'ignorable_line')
    ))

    define('interesting_head_item', alternation(
        'subgraph',
        'association_line',
        'node_forward_declaration',
    ))

    define('subgraph', sequence(
        ('one', 'subgraph_opening_line'),
        ('one', 'subgraph_label_line', 'keep'),
        ('zero_or_more', 'node_forward_declaration', 'keep'),
        ('one', 'close_digraph_line'),
    ))

    define('subgraph_opening_line', regex(r'^subgraph [^ ]+ \{'))

    define('subgraph_label_line', regex('^  label="[^"]+"$'))

    define('node_phrase', sequence(
        ('one', 'node_phrase_body', 'keep'),
        ('zero_or_more', 'ignorable_line'),
    ))

    define('node_phrase_body', alternation(
        'single_line_node', 'multi_line_node'
    ))

    define('multi_line_node', sequence(
        ('one', 'open_node_line', 'keep'),
        ('zero_or_more', 'not_closing_node_line', 'keep'),
        ('one', 'close_node_line', 'keep'),
    ))

    define('open_node_line', regex(f'^({n})\\[([^\\]]*)$'))
    define('single_line_node', regex(f'^({n})\\[(.+)\\]$'))
    define('not_closing_node_line', regex(r'^([^\[\]]+)$'))
    define('close_node_line', regex(r'^([^\[\]]+)\]$'))

    define('node_forward_declaration', regex(f'^(?:  )?({n})$'))

    define('association_phrase', sequence(
        ('one', 'association_line', 'keep'),
        ('zero_or_more', 'ignorable_line'),
    ))

    define('association_line', regex(f'^({n})->({n})$'))

    define('multiline_comment', sequence(
        ('one', 'open_multiline_comment_line'),
        ('one_or_more', 'not_closing_multiline_comment_line'),
        ('one', 'close_multiline_comment_line'),
    ))

    define('open_multiline_comment_line', regex(r'^/\*(?:(?!\*/).)*$'))
    define('not_closing_multiline_comment_line', regex(r'^(?:(?!\*/).)*$'))
    define('close_multiline_comment_line', regex(r'^\*/$'))

    define('single_line_comment_line', regex(r'^/\*.+\*/$'))

    define('ignorable_line', alternation(
        'blank_line', 'single_line_comment_line'
    ))

    define('close_digraph_line', regex('^}$'))

    define('blank_line', regex('^$'))


def _grammar_lib():
    from script_lib.magnetics import parser_via_grammar
    return parser_via_grammar


def xx():
    raise RuntimeError('do me')


_FILE_MONIKER = '<DOT-FILE>'


if __name__ == '__main__':
    cli_for_production()

# #born
