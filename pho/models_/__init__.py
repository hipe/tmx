import re


# == support

class SingleLineAST_:

    def __init__(self, line, symbol_name=None):
        self.line = line
        if symbol_name is not None:
            self.symbol_name = symbol_name

    def to_lines(self):
        yield self.line


# == fenced code block #stowaway

class fenced_code_block:  # #as-namespace-only
    def opening_via_line(line):
        return _FencedCodeBlockInProgress(line)


class _FencedCodeBlockInProgress:

    def __init__(self, line):
        self._cache = [line]

    def build_alternate_line_processer__(self, listener):

        def process_line(line):

            md = _end_of_fenced_code_block_rx.match(line)
            if md is None:
                self._cache.append(line)
                is_last = False
                ast = None
            else:
                self._cache.append(line)
                ast = _FencedCodeBlock(tuple(self._cache))
                del self._cache
                is_last = True

            return _okay, is_last, ast

        return process_line

    symbol_name = 'fenced code block open'


_end_of_fenced_code_block_rx = re.compile('^```')  # ..


class _FencedCodeBlock:

    def __init__(self, lines):
        self._lines = lines

    def to_lines(self):
        return self._lines

    symbol_name = 'fenced code block'


# == content line #stowaway

class content_line:  # #as-namespace-only

    def any_structured_via_line(line):
        from . import footnote
        return footnote.any_structured_via_line__(line)

    def via_line(line):
        return _NonStructuredContentLine(line)


class StructuredContentLine__:

    def __init__(self, mixed_children_tuple):
        self.mixed_children = mixed_children_tuple

    def to_lines(self):
        pcs = []
        for s in self.__strings():
            assert(isinstance(s, str))  # #[#008.G]
            pcs.append(s)
        yield ''.join(pcs)

    def __strings(self):
        itr = iter(self.mixed_children)
        yield next(itr)  # guaranteed string, maybe empty
        for ast in itr:
            yield ast.to_string()
            yield next(itr)  # guaranteed string, maybe empty

    def dereference_footnotes__(self, *many):
        from . import footnote
        tup = footnote.dereference_footnotes__(self.mixed_children, *many)
        if tup is None:
            return
        return self.__class__(tup)

    symbol_name = 'structured content line'


class _NonStructuredContentLine(SingleLineAST_):

    symbol_name = 'content line'


# == empty line #stowaway

class empty_line:  # #as-namespace-only

    the_empty_line_AST = SingleLineAST_('\n', 'empty line')


# == support (again)

_okay = True

# #abstracted.
