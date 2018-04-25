"""so..

the caveats from a sibling file apply here:

  - don't get too attached to this. this is the wrong way.

having said that,

  - for our purposes, parsing a markdown table is "easy".
    (see the pseudo grammar in the test file)

  - also, we experiment with crazy DOM tomfoolery

  - also, see note on "efficiency" over in the test
"""

from sakin_agac import (
        cover_me,
        sanity,
        )
from modality_agnostic import listening
import sys
import re


def _SELF(upstream_line, listener):
    return _Experiment(upstream_line, listener).execute()


class _Experiment:

    def __init__(self, s, l):
        self._ok = True
        self._result = None
        self._line = s
        self._listener = l

    def execute(self):
        self.__resolve_offsets()
        self._ok and self.__resolve_DOM()
        if self._ok:
            return self._DOM

    def __resolve_DOM(self):
        self._DOM = _RowDOM(self._offsets, self._line)

    def __resolve_offsets(self):
        _x = _do_resolve_offsets(self._line, self._listener)
        return self._assign('_offsets', _x)

    def _assign(self, var, x):
        if x is None:
            self._ok = False
        else:
            setattr(self, var, x)


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

    @property
    def is_branch(self):
        return True


class _RowDOM(_BranchDOM):

    def __init__(self, offsets, line):
        a = []
        num_cels = 0
        for (begin, end) in offsets:
            num_cels += 1
            a.append(_CelDOM(begin, end, line))
        None if '\n' == line[end] else sanity()
        a.append(_NEWLINE_LEAF)
        self.children = tuple(a)
        self.cels_count = num_cels

    def cel_at_offset(self, offset):
        if offset < 0 or offset >= self.cels_count:
            cover_me('out of range')
        return self.children[0]


class _CelDOM(_BranchDOM):

    def __init__(self, begin, end, line):

        _ = _LeafDOM(line[(begin+1):end])
        self.children = (_PIPE_LEAF, _)
        self._content_string = '_content_string_initially'

    def content_string(self):
        return getattr(self, self._content_string)()

    def _content_string_initially(self):
        self._content_string = None
        a = [self.children[0]]
        _further_parse_cel(a, self.children[1]._string)
        self.children = tuple(a)
        self._content_string = '_content_string_subsequently'
        return self.content_string()

    def _content_string_subsequently(self):
        return self.children[2]._string  # risky


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
        self._string = s

    def to_string(self):
        return self._string

    @property
    def is_branch(self):
        return False


_EMPTY_LEAF = _LeafDOM('')
_NEWLINE_LEAF = _LeafDOM('\n')
_PIPE_LEAF = _LeafDOM('|')


def _do_resolve_offsets(upstream_line, listener):
    result = None
    a = []
    scn = _CustomScanner(upstream_line, listener)
    while True:
        scn.mark_the_spot()
        if scn.match(_pipe):
            scn.match_assertively(_zero_or_more_not_newline_not_pipes)
            a.append(scn.release_tuple())
            continue
        if scn.match(_newline):
            if scn.is_end_of_string():
                result = a
                del a
                break
            cover_me('stuff after newline')
        scn.expecting('\n' if scn.is_end_of_string() else '|')
        break
    return result


o = re.compile
_newline = o(r'\n')
_pipe = o(r'\|')
_zero_or_more_spaces = o('[ ]*')
_zero_or_more_not_newline_not_pipes = o(r'[^|\n]*')
del o


class _CustomScanner:  # #abstraction candidate

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

    def match_assertively(self, rx):
        _yes = self.match(rx)
        None if _yes else sanity()

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

        had = ' had %s' % repr(self._line[self._offset]) if yes else ''
        error = listening.leveler_via_listener('error', self._listener)  # ..
        error("expecting {}{}{}".format(repr(s), had, where))

    def is_end_of_string(self):
        return self._len == self._offset


sys.modules[__name__] = _SELF  # #[#008.G] so module is callable

# #born.
