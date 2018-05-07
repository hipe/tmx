"""this is for exactly [#407.G].

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
"""


from sakin_agac import (
        cover_me,
        )
import sys
import re


def _SELF(upstream_path, listener=None):

    parse = _Parse(listener)

    with open(upstream_path) as fh:
        for line in fh:
            x = parse(line)
            if x is None:
                break
            yield x


class _Parse:
    """stay light on your feet. this is not the right way

    (after the fact, we documented this in [#407])
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
        schema = _markdown_table_schema_as_line_via_line(line, self._listener)
        if schema is None:
            self._stop_early()
        else:
            self._state = self.TABLE_SCHEMA_LINE_TWO
            self._schema = schema
            return ('table_schema_line_one_of_two', schema)

    def TABLE_SCHEMA_LINE_TWO(self, line):
        row = self._schema.row_as_line_via_line(line)
        if row is None:
            self._stop_early()
        else:
            self._state = self.ANOTHER_ROW_OR_NO_MORE_TABLE
            return ('table_schema_line_two_of_two', row)

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


def _markdown_table_schema_as_line_via_line(line, listener):

    from sakin_agac.format_adapters.markdown_table.magnetics import (
            row_as_editable_line_via_line as row_via_line_and_listener,
            )

    def row_via_line(line_):
        return row_via_line_and_listener(line_, listener)

    row = row_via_line(line)
    if row is not None:
        return _MarkdownTableSchemaAsLine_(row, row_via_line, listener)


class _MarkdownTableSchemaAsLine_:

    def __init__(self, row, row_via_line, listener):

        self.cels_count = row.cels_count
        self._schema_row = row
        self._row_via_line = row_via_line
        self._listener = listener

    def row_as_line_via_line(self, line):

        row = self._row_via_line(line)
        if row is not None:
            act = row.cels_count
            if act == self.cels_count:
                return row
            else:
                self.__when_cel_count_mismatch(act)

    def __when_cel_count_mismatch(self, act):
        from modality_agnostic import listening
        error = listening.leveler_via_listener('error', self._listener)  # ..
        _fmt = 'cel count mismatch (had {} needed {})'
        error(_fmt.format(act, self.cels_count))

    def build_field_readerer__(self):
        from . import schema_index_via_schema_row as x
        return x.field_reader_via_schema_row(self.cels_count, self._schema_row)


_looks_like_table_line = re.compile(r'^\|').search

sys.modules[__name__] = _SELF  # #[#008.G] so module is callable

# #born.
