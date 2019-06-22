class schema_file_scanner_via_recfile_scanner:

    def __init__(self, scn):
        self.recfile_scanner = scn

    def flush_to_config(self, listener, **formal_fields):

        result = {}

        says_required = ('allowed', 'required').index
        dim_pool = set(k for k, v in formal_fields.items() if says_required(v))
        # dim pool = diminshing pool: find missing requireds as you traverse

        while True:
            field = self.next_field(listener)
            if field is None:
                return
            if field.is_end_of_file:
                break
            n = field.field_name
            if n not in formal_fields:
                return self._emit_about_extra(listener, field, formal_fields)
            if n in dim_pool:
                dim_pool.remove(n)
            if n in result:
                return self._emit_about_collision(listener, field)
            result[n] = field.field_value_string

        if len(dim_pool):
            return self._emit_about_missing(listener, dim_pool, formal_fields)

        return result

    def next_field(self, listener):
        """Advance to the any next field block or the end-of-file block.

        This produces each next field in the file, steam-rolling over the
        separator blocks (blank lines and comment lines that separate records)
        so it is *not* appropriate for parsing a recfile *as* a recfile.

        The "end-of-file" block *is* resulted when it is encountered, so a
        None result always indicates that a parse error was emitted.
        """

        blk = self.recfile_scanner.next_block(listener)
        if blk is None:
            return

        """A block is only ever a field block, separator block or the
        end-of-file block. The scanner consumes separator block lines greedily
        so it is guaranteed (by definition) that there will never be two
        separator blocks produced adjacently to each other. So if you have one
        now, the next block will either be end-of-file or a field block.
        """

        if blk.is_separator_block:
            blk = self.recfile_scanner.next_block(listener)
            if blk is None:
                return

        if not blk.is_field_line:
            assert blk.is_end_of_file

        return blk

    # -- whiners (in-class)

    def _emit_about_missing(self, listener, dim_pool, ff):
        def structurer():  # (Case1406)
            # the set doesn't preserve insertion order (but dicts do).
            # sort the reported missings by formal order.
            _sorted = sorted(dim_pool, key=tuple(ff.keys()).index)
            _these = ', '.join(repr(s) for s in _sorted)
            dct = {'reason_tail': _these}
            dct['path'] = self.recfile_scanner.path
            return dct
        listener('error', 'structure',
                 'missing_required_config_fields', structurer)

    def _emit_about_collision(self, listener, field):
        def structurer():  # (Case1404)
            dct = {}
            dct['reason'] = f'{repr(field.field_name)} appears at least twice'
            self.contextualize_about_field_name(dct, field)
            return dct
        listener('error', 'structure',
                 'config_field_names_cannot_occur_more_than_once_in_a_file',
                 structurer)

    def _emit_about_extra(self, listener, field, ff):
        def structur():  # (Case1403)
            dct = {}
            dct['reason_tail'] = repr(field.field_name)
            dct['expecting_any_of'] = tuple(ff.keys())
            self.contextualize_about_field_name(dct, field)
            return dct
        listener('error', 'structure',
                 'unrecognized_config_attribute', structur)

    def contextualize_about_field_name(self, dct, field):
        dct['position'] = field.position_of_start_of_field_name
        self._common_contextualize(dct)

    def contextualize_about_field_value(self, dct, field):
        dct['position'] = field.position_of_start_of_value
        self._common_contextualize(dct)

    def _common_contextualize(self, dct):
        parse_state = self.recfile_scanner
        dct['line'] = parse_state.line
        dct['lineno'] = parse_state.lineno
        dct['path'] = parse_state.path

# #born.
