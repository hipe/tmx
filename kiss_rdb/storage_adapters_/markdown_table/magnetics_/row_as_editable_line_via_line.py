"""so..

the caveats from a sibling file apply here:

  - don't get too attached to this. this is the wrong way.

having said that,

  - for our purposes, parsing a markdown table is "easy".
    (see the pseudo grammar in the test file)

  - also, we experiment with crazy DOM tomfoolery

  - also, see note on "efficiency" over in the test

  - also (new at #history-A.1) a trailing pipe at the end of the line

(Case2407)
"""

import sys
import re


def _SELF(upstream_line, listener):
    return _row_DOM_via_line(upstream_line, listener).execute()


class _BranchDOM:

    def to_string(self):
        import io
        buff = io.StringIO()
        self._write_into_recursive(buff)
        s = buff.getvalue()
        buff.close()  # meh
        return s

    def _write_into_recursive(self, buff):
        for ch in self.children:
            if ch.is_branch:
                ch._write_into_recursive(buff)
            else:
                buff.write(ch.to_string())

    is_branch = True


class _row_DOM_via_line:

    def __init__(self, line, listener):
        self._line = line
        self._listener = listener

    def execute(self):
        a = []
        self._has_endcap = False
        self._last_end = 0
        self._ok = True

        class symbols:  # #class-as-namespace

            def cel(begin, end):
                _ = _CelDOM()._init_via_begin_and_end(begin, end, self._line)
                a.append(_)
                self._last_end = end

            def endcap():
                self._has_endcap = True

            def failed():
                self._ok = False

        for (symbol, beg_end) in self.__flush_to_tokens():
            getattr(symbols, symbol)(*beg_end)

        if self._ok:
            return self.__finish(a)

    def __finish(self, a):

        cels_count = len(a)  # before the rest

        if self._has_endcap:
            a.append(_PIPE_LEAF)
            end = self._last_end + 1
        else:
            end = self._last_end

        assert('\n' == self._line[end])
        a.append(_NEWLINE_LEAF)

        return _RowDOM().init_via_all_memberdata_(
            cels_count=cels_count,
            children=tuple(a),
            has_endcap=self._has_endcap)

    def __flush_to_tokens(self):

        # (only the first pipe is required. this makes the loop less pretty)

        def early_end_of_string():
            if scn.is_end_of_string():
                self._ok = False
                scn.expecting('\n')
                return True

        scn = _CustomScanner(self._line, self._listener)
        ok = True

        scn.mark_the_spot()
        if scn.fails_to_match_expected(_pipe, '|'):
            ok = False

        while ok:  # sneaky
            if early_end_of_string():
                break

            if scn.match(_newline):  # "endcap" IFF pipe then newline
                yield 'endcap', ()
                break

            scn.match_assertively(_zero_or_more_not_newline_not_pipes)

            _hi = scn.release_tuple()
            yield 'cel', _hi

            if early_end_of_string():
                break

            if scn.match(_newline):
                break

            """ok, challenge mode in logic: look at the last 3 matchy things
            we did. what do we know at this point?

              - there is some remainder in the string. (we checked for EOS)

              - whatever is at the head of the string, it's not a newline

              - it's not a not-newline-not-pipe either, because we matched
                all of those above. since there is more string, its head
                must be either a newline or a pipe. right?

              - since it's not a newline, it must be a pipe, right?
            """

            scn.mark_the_spot()
            scn.match_assertively(_pipe)

        if ok:
            assert(scn.is_end_of_string())  # stuff after newline?
        else:
            yield 'failed', ()


class _RowDOM(_BranchDOM):

    def init_via_all_memberdata_(
            self,
            cels_count,
            children,
            has_endcap,
            ):
        self.cels_count = cels_count
        self.children = children
        self.has_endcap = has_endcap
        return self

    def to_line(self):
        _s_a = [ch.to_string() for ch in self.children]
        return ''.join(_s_a)

    def cel_at_offset(self, offset):
        if offset < 0 or offset >= self.cels_count:
            cover_me('out of range')
        return self.children[offset]

    def any_endcap_(self):
        if self.has_endcap:
            return self.children[-2]  # yikes


class _CelDOM(_BranchDOM):

    def _init_via_begin_and_end(self, begin, end, line):
        _ = _LeafDOM(line[(begin+1):end])
        self.children = (_PIPE_LEAF, _)
        self._content_string = '_content_string_initially'
        return self

    def init_via_children__(self, children):
        self.children = children
        self._content_string = '_content_string_subsequently'
        return self

    def content_string(self):
        return getattr(self, self._content_string)()

    def _content_string_initially(self):
        self._content_string = None
        a = [self._pipe_child]
        _further_parse_cel(a, self._child_at(1).string_)
        self.children = tuple(a)
        self._content_string = '_content_string_subsequently'
        return self.content_string()

    def _content_string_subsequently(self):
        return self._child_at(2).string_

    @property
    def _pipe_child(self):
        return self._child_at(0)

    def _child_at(self, offset):
        return self.children[offset]


def _further_parse_cel(a, outer_s):
    """imagine if you could `strip()` string but also "keep" a handle to the

    any leading and trailing whitespace that was stripped off. more formally:
    decompose any string into three strings where:
      - the first string is the longest head-anchored substring of spaces
      - the last string is the longest tail-anchored substring of spaces
      - the middle string is the same as calling strip()
    """

    lef, mid, rit = re.match('^([ ]+)?(?:(.*[^ ])([ ]+)?)?$', outer_s).groups()
    a.append(_LeafDOM(lef) if lef else _EMPTY_LEAF)
    a.append(_LeafDOM(mid) if mid else _EMPTY_LEAF)
    a.append(_LeafDOM(rit) if rit else _EMPTY_LEAF)


class _LeafDOM:

    def __init__(self, s):
        self.string_ = s

    def to_string(self):
        return self.string_

    is_branch = False


_EMPTY_LEAF = _LeafDOM('')
_NEWLINE_LEAF = _LeafDOM('\n')
_PIPE_LEAF = _LeafDOM('|')


o = re.compile
_newline = o(r'\n')
_pipe = o(r'\|')
_zero_or_more_spaces = o('[ ]*')
_zero_or_more_not_newline_not_pipes = o(r'[^|\n]*')
del o


class _CustomScanner:  # #abstraction candidate #[#008.4] a scanner

    def __init__(self, upstream_line, listener):

        self._mark_OK = True
        self._offset = 0
        self._len = len(upstream_line)
        self._line = upstream_line
        self._listener = listener

    def mark_the_spot(self):
        del self._mark_OK
        self._THE_SPOT = self._offset

    def release_tuple(self):
        x = self._THE_SPOT
        del self._THE_SPOT
        self._mark_OK = True
        return (x, self._offset)

    def fails_to_match_expected(self, rx, label):
        _yes = self.match(rx)
        if _yes:
            return False
        else:
            self.expecting(label)
            return True

    def match_assertively(self, rx):
        _yes = self.match(rx)
        assert(_yes)

    def match(self, rx):
        md = rx.match(self._line, self._offset)
        if md is not None:
            self._offset = md.span()[1]
            return True  # ..

    def expecting(self, s):
        if 0 == self._offset:
            where = ' at beginning of line'
            yes = self._len is not 0
        elif self.is_end_of_string():
            where = ' at end of line'
            yes = False
        else:
            where = ' at offset %d' % self._offset
            yes = True

        def lines():
            if yes:
                _ = repr(self._line[self._offset])
                had = f' had {_}'
            else:
                had = ''
            yield f'expecting {repr(s)}{had}{where}'
        self._listener('error', 'expression', lines)

    def is_end_of_string(self):
        return self._len == self._offset


def cover_me(msg=None):  # #open [#876] cover me
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


sys.modules[__name__] = _SELF  # #[#008.G] so module is callable

# #history-A.1
# #born.
