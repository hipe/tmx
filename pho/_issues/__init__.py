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


def _jsonerer(sout, do_time):

    def output_json(rec):
        if is_subsequent():
            sout.write(',\n')
        dct = {}
        if do_time:
            dct['mtime'] = rec.mtime.strftime(strftime_fmt)
        ent = rec.row_AST
        dct['identifier'] = ent.nonblank_identifier_primitive
        dct2 = ent.core_attributes
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

        if isinstance(readmes, tuple) and 1 == len(readmes):
            readme, = readmes
            if not isinstance(readme, str):
                readme.isatty  # sort of [#022]. (Case3966)
                yield readme
                return

        for readme in readmes:
            assert '\n' != readme[-1]  # #here5
            yield readme


def _build_records_via_readme(counts, sort_by_time, tag_query, listener, opn):
    rec = _named_tuple('Record', ('mtime', 'row_AST', 'readme'))

    def records_via_readme(readme):
        counts.files += 1
        ic = issues_collection_via_(readme, listener, opn)

        opened = ic.collection.open_schema_and_entity_traversal(listener)
        with opened as (sch, ents):

            # #todo name this issue about resource management

            if ents is None:  # (tested visually, return code is nonzero)
                return

            for rec in records_via(sch, ents, readme):
                yield rec

    def records_via(sch, ents, readme):
        # If some kind of failure (eg {file|table} not found), None not iter
        if ents is None:
            return

        body_keys = sch.field_name_keys[1:]  # [#871.1]

        # If there is no filter and no sort, you are done
        if tag_query is None and sort_by_time is None:
            return (rec(None, ent, readme) for ent in ents)  # #here5

        # Maybe filter by tag query
        if tag_query is not None:
            assert isinstance(tag_query, str)  # for now
            ent_does_match = _build_matcher(tag_query, body_keys)
            ents = (ent for ent in ents if ent_does_match(ent))

        # If no sort by mtime, you are done
        if sort_by_time is None:
            return (rec(None, ent, readme) for ent in ents)  # #here5

        # The rest is the heavy lift. Lazily once per file get this badboy
        from kiss_rdb.vcs_adapters.git import blame_index_via_path as func
        vcs_index = func(readme, listener, opn)
        if vcs_index is None:
            xx("maybe the file isn't in version control?")

        mtime = vcs_index.datetime_for_lineno  # #here5 (below)
        unordered = (rec(mtime(ent.lineno), ent, readme) for ent in ents)
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
        dct = row_AST.core_attributes
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

def issues_collection_via_(readme, listener, opn=None):
    coll = _collection_via(readme, listener, opn)
    if coll is None:
        return

    def do_open_etc(listener):
        from contextlib import contextmanager as cm

        @cm
        def cm():
            with coll.open_schema_and_RAW_entity_traversal(listener) as (sch, enx):  # noqa: E501
                if enx is None:
                    return
                body_ks = sch.field_name_keys[1:]
                if ('main_tag', 'content') != body_ks:
                    raise RuntimeError(f"This is fine but hello: {body_ks!r}")
                yield sch, enx
        return cm()

    class issues_collection:  # #class-as-namespace
        def to_graph_lines(listener=listener):
            from .graph import to_graph_lines_ as func
            return func(issues_collection, listener)

        def open_schema_and_issue_traversal(listener=listener):
            return do_open_etc(listener)

        collection = coll
    return issues_collection


def _collection_via(readme, listener, opn=None):
    import kiss_rdb.storage_adapters_.markdown_table as sa_mod
    from kiss_rdb import collection_via_storage_adapter_and_path as func
    return func(sa_mod, readme, listener, opn=opn,
                iden_er_er=build_identifier_parser_,
                file_grows_downwards=False)


def _real_apply_diff(itr, listener):
    # #todo wouldn't you like to guard this with a VCS check
    from text_lib.diff_and_patch import apply_patch_via_lines as func
    is_dry, cwd = False, None
    return func(itr, is_dry, listener, cwd)


def build_identifier_parser_(listener, cstacker=None):  # #testpoint
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
                begin_identifier()
                parse_the_rest_of_the_identifier()
                parse_end_of_string()
            else:
                expecting_open_bracket_or_octothorphe()

        def parse_the_rest_of_the_identifier_and_close_bracket():
            parse_the_first_component()
            if not scn.empty and ']' == scn.peek(1):
                scn.advance_by_one()
                return
            parse_the_second_component()
            scn.skip_required(close_bracket)

        def parse_the_rest_of_the_identifier():
            parse_the_first_component()
            if scn.empty:
                return
            parse_the_second_component()

        def parse_the_first_component():
            ddd = scn.scan_required(fnetd)
            if not ddd:
                raise stop()
            one_or_two_identifiers[-1][0] = int(ddd)  # #here1

        def parse_the_second_component():
            scn.skip_required(dot)
            if (s := scn.scan(second_component_as_letter)):
                one_or_two_identifiers[-1][1] = (True, s)  # #here2
            elif (s := scn.scan(second_component_as_number)):
                one_or_two_identifiers[-1][1] = (False, s)  # #here2
            else:
                scn.whine_about_expecting(
                    second_component_as_letter, second_component_as_number)

        def parse_any_octothorpe():
            return scn.skip(octothorpe)

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
                begin_identifier()
                return True

        def parse_open_bracket():
            scn.skip_required(open_bracket)
            xx()
            begin_identifier()

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
            scn.whine_about_expecting(open_bracket, octothorpe)

        def begin_identifier():
            one_or_two_identifiers.append([None, None, True])  # #here1

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
    dot = o('"."', r'\.')
    octothorpe = o('octothorpe', '#')
    open_bracket = o('open bracket', r'\[')
    second_component_as_letter = o('second component as letter ([A-Z])', '[A-Z]')  # noqa: E501
    second_component_as_number = o('second component as number (d or dd)', '[0-9]{1,2}')  # noqa: E501
    close_bracket = o('close bracket', r']')
    return identifier_via_string


def _throwing_string_scan(listener, cstacker=None):
    def build_scanner(piece):
        return StringScanner(piece, throwing_listener, cstacker)

    def throwing_listener(sev, *rest):
        listener(sev, *rest)
        if 'error' == sev:
            raise stop()

    from text_lib.magnetics.string_scanner_via_string import \
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

    def __init__(
            self, major_int, tail_tuple=None, include_bracket=True):  # #here1

        minor_int, minor_int = None, None
        if tail_tuple is not None:
            yn, minor_surface = tail_tuple  # #here2
            if not isinstance(minor_surface, str):
                raise RuntimeError(f"where: {type(minor_surface)} {minor_surface!r}")  # noqa: E501  [#022]
            if yn:
                # A => 1, B => 2 ..
                minor_int = ord(minor_surface) - 64
            else:
                minor_int = int(minor_surface)
            self.minor_integer = minor_int
            self._minor_surface = minor_surface

        self.include_bracket = include_bracket
        self.key = (major_int, minor_int)
        self._as_string_lazy = None

    def to_string(self):
        if self._as_string_lazy is None:
            self._as_string_lazy = ''.join(self._to_string_pieces())
        return self._as_string_lazy

    def _to_string_pieces(self):
        major_int, minor_int = self.key
        if self.include_bracket:
            yield '['
        yield '#'
        yield '%03d' % major_int
        if minor_int is not None:
            yield '.'
            yield self._minor_surface  # (Case3853)
        if self.include_bracket:
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
        (my_major, my_minor), (otr_major, otr_minor) = self.key, otr.key
        if my_major < otr_major:
            return -1
        if otr_major < my_major:
            return 1
        assert my_major == otr_major
        if my_minor is None:
            if otr_minor is None:
                return 0
            if 0 == otr_minor:
                return 0
            return -1
        elif otr_minor is None:
            if 0 == my_minor:
                return 0
            return 1
        if my_minor < otr_minor:
            return -1
        if otr_minor < my_minor:
            return 1
        assert my_minor == otr_minor
        return 0

    @property
    def has_sub_component(self):
        return self.key[1] is not None

    @property
    def major_integer(self):
        return self.key[0]

    is_range = False


def _named_tuple(s, t):
    from collections import namedtuple as nt
    return nt(s, t)


def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))

# #born.
