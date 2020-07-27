#!/usr/bin/env python3

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
            pcs = [name.replace('_', ' '), ': ']
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
        w = self._stdout.write
        with open(self._input_path) as input_lines:
            _ = _output_lines_via_input_lines(input_lines, self._listener)
            for output_line in _:
                w(output_line)

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


def _output_lines_via_input_lines(lines, listener):

    ast = _AST_via_input_lines(lines, listener)
    if ast is None:
        return

    yield 'line 1\n'
    yield 'line 2\n'


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
        ('one', 'open_node_line'),
        ('zero_or_more', 'not_closing_node_line'),
        ('one', 'close_node_line'),
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
