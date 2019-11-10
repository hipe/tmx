"""this is for exactly [#447.7] document-centric synchronization

provisions (requirements):

    - the consuming agent must be able to assume there is a one-for-one
      between elements yielded by this generator and lines in the upstrem
      file. we're doing it this way because A) we can and B) this is going
      to be used for full file rewrites..

keep in mind:

    - this should be somehow general use for our hacky purposes

    - other scripts elsewhere parse markdown tables better so don't get
      carried away; this is just proof-of-concept..

    - also keep in mind we should use a parser like ragel etc


this:

:[#873.D]: the idea is there is a cost to parsing a markdown table robustly
(you're counting cels, you're parsing escaping to allow for escaped pipes)
versus parsing markdown tables coarsely (you're just perhaps hopping over all
contiguous lines that start with a pipe.)

(also there is a cost to making the name-to-offset mapping.)

would that we had a single document with several markdown tables and we are
in fact riding on our [#457.B] central conceit of using MDT's as datastores;
we might want to parse the document *without* the assumption built-in to it
that we are parsing every markdown table we encounter robustly.

however, to implement this we would have to add a parameter representing the
desired MTD (probably by offset, maybe (gulp) by some kind of label).

furthermore such an arrangement would break consuemrs that expect documents
to have only these discrete N sectiosn (header, table, and so on.) so this
marker tracks relevant code spots that would be effected by expanding our
featureset to such a full realization..

(Case2421)
"""

import contextlib
import re


@contextlib.contextmanager
def OPEN_TAGGED_DOC_LINE_ITEM_STREAM(upstream_path, listener):
    """at #history-A.1 we were gung-ho on context managers. we may have erred

    on the side of over-doing it for now."""

    assert(listener)  # you're gonna want a listener  #[#412]

    parse = MarkdownTableLineParser_(listener)

    def f():
        with __open_upstream_path(upstream_path) as lines:
            for line in lines:
                pair = parse(line)
                if pair is None:
                    break
                yield pair
    yield f()


def __open_upstream_path(upstream_path):
    if isinstance(upstream_path, str):
        return open(upstream_path)
    else:
        return __open_upstream_path_challenge_mode(upstream_path)


def __open_upstream_path_challenge_mode(x):
    if isinstance(x, tuple):
        yes = True
    else:
        import collections.abc
        if isinstance(x, collections.abc.Iterable):
            yes = True  # like a generator (Case2013DP)
        else:
            yes = False
    if yes:
        from data_pipes import ThePassThruContextManager
        return ThePassThruContextManager(x)
    else:
        raise Exception(f'can we keep this simple? had {type(x)}')


class MarkdownTableLineParser_:
    """stay light on your feet. this is not the right way

    (after the fact, we documented this in [#447])
    """

    def __init__(self, listener):
        self._state = self.HEAD
        self._listener = listener

    def __call__(self, line):
        return self._state(line)

    def HEAD(self, line):
        if _looks_like_table_line(line):
            self._state = None
            return self.TABLE_SCHEMA_LINE_ONE(line)
        else:
            return ('head_line', line)

    def TABLE_SCHEMA_LINE_ONE(self, line):

        from .schema_index_via_schema_row import (
                row_two_function_and_liner_via_row_one_line as f)

        two = f(line, self._listener)
        if two is None:
            self._stop_early()
        else:
            self._row_two_function, liner = two
            self._state = self.TABLE_SCHEMA_LINE_TWO
            return ('table_schema_line_one_of_two', liner)

    def TABLE_SCHEMA_LINE_TWO(self, line):
        f = self._row_two_function
        del self._row_two_function

        schema_f, liner = f(line)  # ..
        schema = schema_f()  # #[#873.D] just build the index now, always

        if schema is None:
            self._stop_early()
        else:
            self._schema = schema
            self._state = self.ANOTHER_ROW_OR_NO_MORE_TABLE
            _ = _CustomHybrid(schema, liner)
            return ('table_schema_line_two_of_two', _)

    def ANOTHER_ROW_OR_NO_MORE_TABLE(self, line):
        if _looks_like_table_line(line):
            row = self._schema.row_as_line_via_line(line)
            if row is None:
                self._stop_early()
            else:
                return ('business_object_row', row)
        else:
            self._state = self.TAIL
            return self._state(line)

    def TAIL(self, line):
        if _looks_like_table_line(line):
            cover_me('multiple tables in one document needs a little work')
        return ('tail_line', line)

    def _stop_early(self):
        del self._state

    def to_line(self):
        return self.row_DOM.to_line()


class _CustomHybrid:
    """currently clients will have to know that we are *not* doing #[#873.D]"""

    def __init__(self, schema, liner):
        self.complete_schema = schema
        self._liner = liner

    def to_line(self):
        return self._liner.to_line()


_looks_like_table_line = re.compile(r'^\|').search


def cover_me(s):  # #open [#876] cover me
    raise Exception(f'cover me: {s}')

# #history-A.1: gung-ho on context managers
# #born.
