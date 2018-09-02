from sakin_agac import (
        cover_me,
        sanity,
        )


def row_two_function_and_liner_via_row_one_line(line, listener):
    """the interface here is bespoke for line-by-line parsing:

    it assumes that always you are going to parse two rows (lines): first,
    the row with the titles, then second the row with the alignments.
    (neither row is optional.)

    in targeting the requirements of some line-by-line clients, this gives
    immediate feedback by breaking the construction of the whole "schema"
    into two steps corresponding to these two lines. this function serves
    the first step and enables the other.

    the result is a two-tuple: the second element is simply a `to_line`-able
    that will echo back the row parsed. the first element is a function that
    will parse the second row, which (on success) produces another tuple:

    that tuple's second component is a `to_line`-able that gives you back
    the line. the first component is a function that produces the schema.
    """

    def __main():
        ok and __parse_second_row()
        ok and __ensure_row_has_endcap()
        if ok:
            return __finish()

    def __finish():
        _f = __build_schemaer_and_liner_via_alignments_line(
                row, row_via_line, listener)
        return (_f, row)

    def __ensure_row_has_endcap():
        if not row.has_endcap:
            # #coverpoint3.1
            from modality_agnostic import listening as li
            error = li.leveler_via_listener('error', listener)
            error('header row 1 must have "encap" (trailing pipe)')
            _stop()

    def __parse_second_row():
        nonlocal row
        row = row_via_line(line)
        if row is None:
            cover_me("we don't know if this is possible")

    def row_via_line(line_):
        return f(line_, listener)

    from sakin_agac.format_adapters.markdown_table.magnetics import (
            row_as_editable_line_via_line as f,
            )

    def _stop():
        nonlocal ok
        ok = False

    row = None
    ok = True
    return __main()


def __build_schemaer_and_liner_via_alignments_line(row1, row_via_line, listnr):
    """the reason we result in a schema-*er* and not just a schema is because

    we imagine there being some cost to building it that we want to avoid.
    YET currently do the parsing and validation of row count all the time,
    not as an opt-in. it's all experimental. the point was to make the
    policy part of it not very hard-coded..
    """

    def f(line):
        mutex()
        ok and __parse_row(line)
        ok and __validate_arity()
        if ok:
            return __finish()

    def __finish():
        def build_schema():
            return _SchemaIndex(row_via_line, row1, row2, listnr)
        return (build_schema, row2)

    def mutex():
        """(we save on complexity in one dimension if we can assume this)"""
        nonlocal mutex
        del(mutex)

    def __validate_arity():
        _validate = _make_row_num_validator(row1, listnr, False, True, False)
        if not _validate(row2):
            nonlocal ok
            ok = False

    def __parse_row(line):
        nonlocal row2
        row2 = row_via_line(line)
        if row2 is None:
            cover_me('hi')

    row2 = None
    ok = True

    return f


class _SchemaIndex:
    """mainly, keep track of which field (by "name") is in which column..."""

    def __init__(self, row_via_line, row1, row2, listener):

        None if row1.has_endcap else sanity()
        cels_count = len(row1.children) - 2  # yuck. one for endcap one for \n

        (
            self.__field_readerer,
            self.offset_via_field_name__,
            self.field_names__,
        ) = _the_index_components_via(cels_count, row1)

        self._validate_row_cel_count = _make_row_num_validator(
                row1, listener, True, True, False)

        self._row_via_line = row_via_line
        self.row_for_alignment__ = row2

    def row_as_line_via_line(self, line):
        row = self._row_via_line(line)
        if row is not None:
            if self._validate_row_cel_count(row):
                return row

    def field_reader(self, field_name):
        """given a normal field name, result in a function that, given a row,

        results in the value for that field in that row.
        """

        return self.__field_readerer(field_name)

    def natural_key_field_name__(self):
        return self.field_names__[0]  # assume [#418.I] first is it


def _the_index_components_via(cels_count, header_row1_DOM):
    """given a table with a header row like this, make a dictionary like this

    like this:
        | Foo Biff Bazz  | Bumbo-Boffo     | Xx

    like this:
        { 'foo_biff_bazz': 0, 'bumbo_boffo': 1, 'xx': 2 }

    this way, given a "normal field name" you can know the offset of the field
    """

    def normal_field_name_via_offset(offset):
        import sakin_agac.magnetics.normal_field_name_via_string as name_via
        _cel_DOM = header_row1_DOM.cel_at_offset(offset)
        _s = _cel_DOM.content_string()
        return name_via(_s)

    r = range(cels_count)
    field_names = tuple(normal_field_name_via_offset(i) for i in r)
    offset_via_normal_field_name = {field_names[i]: i for i in r}

    if cels_count != len(offset_via_normal_field_name):
        cover_me('duplicate field name? (when normalized)')

    def f(s):
        offset = offset_via_normal_field_name[s]

        def g(item):
            _cel = item.ROW_DOM_.cel_at_offset(offset)
            return _cel.content_string()
        return g
    return (f, offset_via_normal_field_name, field_names)


def _make_row_num_validator(model_row, listener, *ok_via_which):
    """`ok_via_which` is a three-tuple, each component either true or false:

    first: True IFF actual less than model is OK, False otherwise
    second: True IFF actual same as model is OK, False otherwise
    third: True IFF actual greater than model is OK, False otherwise
    """

    def f(row):
        actual_cel_count = row.cels_count
        which = my_compare(actual_cel_count)
        if ok_via_which[which]:
            return True
        else:  # #coverpoint3.1
            __when_cel_count_mismatch(which, actual_cel_count)

    def __when_cel_count_mismatch(which, actual_count):

        # row cannot have less               cels than the schema row has
        # row cannot have the same number of cels as   the schema row
        # row cannot have more               cels than the schema row has

        _3 = (
                ('less', 'than', ' has'),
                ('the same number of', 'as', ''),
                ('more', 'than', ' has'),
        )[which]

        _msg1 = "row cannot have {} cels {} the schema row{}".format(*_3)
        _msg2 = "(had {}, needed {}.)".format(actual_count, model_cel_count)

        _msg = '. '.join((_msg1, _msg2))

        from modality_agnostic import listening as li
        error = li.leveler_via_listener('error', listener)  # ..
        error(_msg)

    model_cel_count = model_row.cels_count
    my_compare = _make_my_compare(model_cel_count)
    return f


def _make_my_compare(model_count):
    """(the idiom from ruby is {-1, 0, 1} for these three categories.

    we use {0, 1, 2} instead (experimentally) so that we can use arrays
    (lists (tuples)) as-is without explicit keys, to signify etc..
    """

    def f(candidate_count):
        if model_count < candidate_count:
            return 2
        elif model_count == candidate_count:
            return 1
        elif model_count > candidate_count:
            return 0
        else:
            sanity()
    return f

# #born.
