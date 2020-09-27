def records_via_query_(
        opened, sort_by_time, tag_query, do_batch, listener, opn=None):

    class counts:  # #class-as-namespace
        items = 0
        files = 0

    yield _jsonerer, counts

    records_via_readme = _build_records_via_readme(
            counts, sort_by_time, tag_query, listener, opn)

    readmes = _readmes_via_opened(opened, do_batch)
    for readme in readmes:
        for record in records_via_readme(readme):
            yield record


def _jsonerer(sout):

    def output_json(rec):
        if is_subsequent():
            sout.write(',\n')
        dct = {}
        dct['mtime'] = rec.mtime.strftime(strftime_fmt)
        ent = rec.row_AST
        dct['identifier'] = ent.nonblank_identifier_primitive
        dct2 = ent.core_attributes_dictionary_as_storage_adapter_entity
        for k, v in dct2.items():
            assert k not in dct
            dct[k] = v
        dct['readme'] = rec.readme
        json_dump(dct, sout, indent=2)

    def is_subsequent():
        if self.is_subsequent:
            return True
        self.is_subsequent = True

    class self:
        is_subsequent = False

    from kiss_rdb.vcs_adapters.git import DATETIME_FORMAT as strftime_fmt
    from json import dump as json_dump
    return output_json


def _readmes_via_opened(opened, do_batch):
    with opened as readmes:
        if do_batch:
            for readme in readmes:
                assert '\n' == readme[-1]  # #here5
                yield readme[:-1]  # chop/chomp
            return
        for readme in readmes:
            assert '\n' != readme[-1]  # #here5
            yield readme


def _build_records_via_readme(counts, sort_by_time, tag_query, listener, opn):
    rec = _named_tuple('Record', ('mtime', 'row_AST', 'readme'))

    def records_via_readme(readme):
        counts.files += 1
        body_keys, ent_sxs = _body_keys_and_ent_sexps(readme, listener, opn)

        # If some kind of failure (eg {file|table} not found), None not iter
        if ent_sxs is None:
            return

        # If there is no filter and no sort, you are done
        if tag_query is None and sort_by_time is None:
            return (rec(None, sx[1], readme) for sx in ent_sxs)  # #here5

        # Maybe filter by tag query
        if tag_query is not None:
            assert isinstance(tag_query, str)  # for now
            ent_does_match = _build_matcher(tag_query, body_keys)
            ent_sxs = (sx for sx in ent_sxs if ent_does_match(sx[1]))

        # If no sort by mtime, you are done
        if sort_by_time is None:
            return (rec(None, sx[1], readme) for sx in ent_sxs)  # #here5

        # The rest is the heavy lift. Lazily once per file get this badboy
        from kiss_rdb.vcs_adapters.git import blame_index_via_path as func
        vcs_index = func(readme, listener, opn)
        if vcs_index is None:
            xx()

        mtime = vcs_index.datetime_for_lineno  # #here5 (below)
        unordered = (rec(mtime(sx[2]), sx[1], readme) for sx in ent_sxs)
        # (we can imagine some world where we return it unsorted but not here)
        return sorted(unordered, **sort_kwargs)

    if sort_by_time is not None:
        sort_kwargs = {'key': lambda rec: rec.mtime}
        if 'DESCENDING' == sort_by_time:
            sort_kwargs['reverse'] = True
        else:
            assert 'ASCENDING' == sort_by_time

    return records_via_readme


# == Fast Query

def _build_matcher(query_string, body_keys):
    def match_yn(row_AST):
        dct = row_AST.core_attributes_dictionary_as_storage_adapter_entity
        for k in body_keys:
            if (cel_content := dct.get(k)) is None:
                continue
            if match_cel_yn(cel_content):
                return True
    match_cel_yn = _build_cel_matcher(query_string)
    return match_yn


def _build_cel_matcher(query_string):
    def match_cel_yn(cel_content):
        if -1 == cel_content.find('#'):
            return  # optimization lol
        return rx.search(cel_content)
    import re
    rx = re.compile(''.join(('(^|[ ])', query_string, r'\b')))  # assume #here4
    return match_cel_yn


def parse_query_(query, listener):
    if query is None:
        return

    def main():
        parse_the_first_token()
        if_theres_more_than_one_token_whine_for_now()
        return tok

    def parse_the_first_token():  # all #here4
        begin = scn.pos  # probably zero
        scn.skip_required(leading_octothorpe)
        scn.skip_required(tag_body)
        scn.skip_required(the_end)
        assert 0 == begin and scn.empty and scn.pos == len(tok)

    def if_theres_more_than_one_token_whine_for_now():
        if not len(hstack):
            return
        msg = f"Sorry, no compound queries yet in this version: {hstack[-1]!r}"
        listener('error', 'expression', 'not_yet', lambda: (msg,))
        raise stop()

    o, build_string_scanner, stop = _throwing_string_scan(listener)
    leading_octothorpe = o("'#'", '#')
    tag_body = o('tag body ([-a-z]..)', '[a-z]+(?:-[a-z]+)*')
    the_end = o('end of tag', r'\Z')

    hstack = list(reversed(query))
    tok = hstack.pop()  # guaranteed because #here3
    scn = build_string_scanner(tok)

    try:
        return main()
    except stop:
        pass


# ==

def _body_keys_and_ent_sexps(readme, listener, opn):
    from kiss_rdb.storage_adapters_.markdown_table import \
        COLLECTION_IMPLEMENTATION_VIA_SINGLE_FILE as func
    iden_clser = _build_identifier_parser
    ci = func(readme, listener, opn=opn, iden_clser=iden_clser)

    # Make a custom request of the document, to get the ents AND the schema
    custom_action_stack = [
        ('end_of_file', lambda o: o.turn_yield_off()),  # don't yield this pc
        ('table_schema_line_ONE_of_two',),
        ('other_line', lambda o: o.turn_yield_off()),
        ('business_row_AST',),
        ('table_schema_line_TWO_of_two', lambda o: o.turn_yield_on()),
        ('table_schema_line_ONE_of_two',),
        ('head_line',),
        ('beginning_of_file',)]
    sxs = ci.sexps_via_action_stack(custom_action_stack, listener)
    if sxs is None:
        return None, None

    # Pop off the schema (always the 1st item of the possibly empty itr)
    schema, body_keys = None, None
    for csr2_sx in sxs:
        schema = csr2_sx[2]
        body_keys = schema.field_name_keys[1:]
        break

    if body_keys is not None and ('main_tag', 'content') != body_keys:
        raise RuntimeError(f"This is fine but hello: {body_keys!r}")

    return body_keys, sxs


def _build_identifier_parser(listener, cstacker=None):  # #testpoint
    def identifier_via_string(piece):
        def main():
            if parse_any_open_bracket():
                if parse_any_wild_oldschool_markdown_footnote_thing():
                    parse_octothorpe()
                    parse_the_rest_of_the_identifier()
                    parse_wild_oldschool_markdown_footnote_thing_close()
                else:
                    parse_octothorpe()
                    parse_the_rest_of_the_identifier_and_close_bracket()
                    if parse_any_dash():
                        parse_open_bracket()
                        parse_the_rest_of_the_identifier_and_close_bracket()
                parse_end_of_string()
            elif parse_any_octothorpe():
                parse_the_rest_of_the_identifier()
                parse_end_of_string()
            else:
                expecting_open_bracket_or_octothorphe()

        def parse_the_rest_of_the_identifier_and_close_bracket():
            ddd = scn.scan_required(fnetd)
            if not ddd:
                raise stop()
            one_or_two_identifiers[-1][0] = int(ddd)  # #here1
            char = scn.peek(1)
            if ']' == char:
                scn.advance_by_one()
                return
            if '.' != char:
                scn.whine_about_expecting('.')
            scn.advance_by_one()
            if (s := scn.scan(second_component_as_letter)):
                one_or_two_identifiers[-1][1] = (True, s)  # #here2
            elif (s := scn.scan(second_component_as_number)):
                one_or_two_identifiers[-1][1] = (False, s)  # #here2
            else:
                xx("sketched out elaboratedly..")
                scn.whine_about_expecting(
                    second_component_as_letter, second_component_as_number)
            scn.skip_required(close_bracket)

        def parse_the_rest_of_the_identifier():
            xx()

        def parse_any_octothorpe():
            xx()

        def parse_octothorpe():
            scn.skip_required(octothorpe)

        def parse_wild_oldschool_markdown_footnote_thing_close():
            xx()

        def parse_any_wild_oldschool_markdown_footnote_thing():
            if '\\' == scn.peek(1):
                xx()

        def parse_close_bracket():
            xx()

        def parse_any_open_bracket():
            if '[' == scn.peek(1):
                scn.advance_by_one()
                one_or_two_identifiers.append([None, None, True])  # #here1
                return True

        def parse_open_bracket():
            scn.skip_required(open_bracket)
            xx()
            one_or_two_identifiers.append([None, None, True])  # #here1

        def parse_any_dash():
            if scn.empty:
                return
            if '-' == scn.peek(1):
                xx()
                scn.advance_by_one()
                return True

        def parse_end_of_string():
            if scn.empty:
                return
            scn.whine_about_expecting('end of string')

        def expecting_open_bracket_or_octothorphe():
            xx()

        one_or_two_identifiers = []
        scn = build_string_scanner(piece)

        try:
            main()
        except stop:
            return
        rang = tuple(_Identifier(*three) for three in one_or_two_identifiers)
        if 1 == len(rang):
            iden, = rang
            return iden
        return _IdentifierRange(*rang)

    o, build_string_scanner, stop = _throwing_string_scan(listener, cstacker)
    fnetd = o('for now exactly three digits', '[0-9]{3}')
    octothorpe = o('octothorpe', '#')
    open_bracket = o('open bracket', r'\[')
    second_component_as_letter = o('second component', '[A-Z]')
    second_component_as_number = o('second component', '[0-9]{1,2}')
    close_bracket = o('close bracket', r']')
    return identifier_via_string


def _throwing_string_scan(listener, cstacker=None):
    def build_scanner(piece):
        return StringScanner(piece, throwing_listener, cstacker)

    def throwing_listener(sev, *rest):
        listener(sev, *rest)
        if 'error' == sev:
            raise stop()

    from kiss_rdb.magnetics.string_scanner_via_string import \
        StringScanner, pattern_via_description_and_regex_string as o

    class stop(RuntimeError):
        pass

    return o, build_scanner, stop


# == Models

class _IdentifierRange:

    def __init__(self, one, two):
        self._left = one
        self._right = two

    def to_string(self):
        xx()

    is_range = True


class _Identifier:

    def __init__(self, i, tail_primitive=None, include_bracket=True):  # #here1
        if tail_primitive is None:
            self._sub_component_primitive = None
        else:
            yn, value = tail_primitive  # #here2
            if yn:
                # A => 1, B => 2 ..
                self._sub_component_as_integer = ord(value) - 64
            else:
                value = int(value)
                self._sub_component_as_integer = value
            self._sub_component_primitive = value  # #testpoint (visual)
        self._include_bracket = include_bracket
        self._integer = i  # #testpoint (visual)

    def to_string(self):
        return ''.join(self._to_string_pieces())

    def _to_string_pieces(self):
        if self._include_bracket:
            yield '['
        yield '#'
        yield '%03d' % self._integer
        if self._sub_component_primitive is not None:
            yield '.'
            yield str(self._sub_component_primitive)  # (Case3853)
        if self._include_bracket:
            yield ']'

    def __le__(self, otr):
        return self._compare(otr) in (-1, 0)

    def __lt__(self, otr):
        return -1 == self._compare(otr)

    def __ge__(self, otr):
        return self._compare(otr) in (0, 1)

    def __gt__(self, otr):
        return 1 == self._compare(otr)

    def __ne__(self, otr):
        return 0 != self._compare(otr)

    def __eq__(self, otr):
        return 0 == self._compare(otr)

    def _compare(self, otr):
        assert isinstance(otr, _Identifier)  # ..
        left_int, right_int = self._integer, otr._integer
        if left_int < right_int:
            return -1
        if left_int > right_int:
            return 1
        assert left_int == right_int
        left_has = self._sub_component_primitive is not None
        right_has = otr._sub_component_primitive is not None
        if left_has:
            if right_has:
                left_int = self._sub_component_as_integer
                right_int = otr._sub_component_as_integer
            else:
                return 1
        elif right_has:
            return -1
        else:
            return 0
        if left_int < right_has:
            return -1
        if right_int < left_int:
            return 1
        assert left_int == right_int
        return 0

    is_range = False


def _named_tuple(s, t):
    from collections import namedtuple as nt
    return nt(s, t)


def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))

# #born.
