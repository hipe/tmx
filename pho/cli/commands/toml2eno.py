import re


def CLI(sin, sout, serr, argv, efx=None):
    # efx = external function.
    # We don't use it but we must accept it because our parent does
    from script_lib.cheap_arg_parse import cheap_arg_parse
    return cheap_arg_parse(_do_CLI, sin, sout, serr, argv, _formals)


_formals = (('file-path', 'some file'), ('-h', '--help', 'this screen'))


def _do_CLI(sin, sout, serr, file_path, _rscr):
    """Quick and dirty hack to change file from toml to eno.

    We don't parse toml robustly because at writing it's not possible
    (how we got in to this whole mess the first place); so instead we
    hand-write an entire hacky line-based parser here.
    """

    write = sout.write
    with open(file_path) as fh:
        for line in __output_lines_via_line_scanner(__file_line_scanner(fh)):
            write(line)

    return 0


def __output_lines_via_line_scanner(scn):

    def main():
        while not scn.eos:
            token = tokener()
            for line in getattr(actions, token)():
                yield line

    class actions:  # #class-as-namespace

        def section():
            md = re.match(r'\[([a-zA-Z0-9.]+)\]\n$', line())
            these = md[1].split('.')
            assert('item' == these[0])
            these[0] = 'entity'
            scn.advance()
            yield section_line(': '.join(these))

        def field():
            md = re.match('([^ =]+) ?= ?(?:(""")|(")|(\'\'\')|([0-9]))', line())  # noqa: E501
            dashes_name, is_double_multi, is_double_oneline, is_single_multi, is_literal = md.groups()  # noqa: E501

            # #provision [#873.21] underscores
            var_name = dashes_name.replace('-', '_')

            if is_double_oneline:
                # for quote quoted string on one line, just strip quotes.
                # will be broken for escape sequences
                md = re.search(' ?= ?"(.+)"\n$', line())  # yikes
                scn.advance()
                yield field_line(var_name, md[1])
                return

            if is_literal:
                md = re.search('= ?(.+)\n$', line())  # yikes
                scn.advance()
                yield field_line(var_name, md[1])
                return

            if is_single_multi:
                stop_at_line = "'''\n"
            else:
                assert(is_double_multi)
                stop_at_line = '"""\n'

            # the centerpoint of this hack: cha cha cha

            scn.advance()  # first time, advance over
            assert(stop_at_line != line())  # assert not empty multi-line str

            def these_lines():
                s = line()
                while True:
                    scn.advance()  # advance over the content line
                    yield s  # yield the content line
                    s = line()
                    if stop_at_line == s:
                        scn.advance()  # advance over the terminating line
                        break

            for s in multiline_field_lines(var_name, these_lines()):
                yield s

            yield '\n'  # aesthetics

        def comment():
            # assert that we are at the end of the file
            a = [scn.peek]
            scn.advance()
            while not scn.eos:
                s = scn.peek
                assert('#' == s[0])
                a.append(s)
                scn.advance()

            yield section_line('document-meta')
            for s in multiline_field_lines('string_as_comment', a, False):
                yield s

        def blank():
            x = line()
            scn.advance()
            yield x

    def line():
        return scn.peek

    tokener = __build_tokenizer(scn)

    from kiss_rdb.storage_adapters_.eno import \
        multiline_field_lines, field_line, section_line

    return main()


def __build_tokenizer(scn):

    main_rx = re.compile(r'([a-zA-Z])|(\[)|($)|(#)')
    symbol_via_offset = ('field', 'section', 'blank', 'comment')

    def token():
        md = main_rx.match(scn.peek)
        # ..
        t = md.groups()
        offset, = filter(lambda i: t[i] is not None, range(0, 4))
        return symbol_via_offset[offset]

    return token


def __file_line_scanner(fh):

    class FileLineScanner:  # others like it, etc

        def __init__(self):
            self.eos = False
            self.peek = None
            self.advance()

        def advance(self):
            line = next(itr)
            if line is None:
                self.eos = True
                del self.peek
                return
            self.peek = line

    itr = __yield_none_at_EOF(fh)
    return FileLineScanner()


def __yield_none_at_EOF(fh):

    for line in fh:
        yield line

    yield None

# #born.
