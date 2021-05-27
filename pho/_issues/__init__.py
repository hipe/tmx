from dataclasses import dataclass as _dataclass
from collections import namedtuple as _namedtuple


def records_via_query_(
        opened, user_query_tokens, sort_by, do_batch, listener, opn=None):

    class counts:  # #class-as-namespace
        items, files = 0, 0

    records_via_readme = _build_records_via_readme(
            counts, user_query_tokens, sort_by, listener, opn)

    if records_via_readme is None:
        yield None
        return

    yield _jsonerer, counts  # #provision [#883.E] (covered)

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

        # dct['identifier'] = ent.nonblank_identifier_primitive
        # (redundant with leftmost column with user's choice name..)

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

    if do_time:
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


# ct = collection traversal

def _build_records_via_readme(
        counts, user_query_tokens, sort_by, listener, opn):

    def records_via_readme(readme):

        counts.files += 1
        ic = issues_collection_via_(readme, listener, opn)

        opened = ic.collection.open_schema_and_entity_traversal(listener)
        with opened as (sch, ents):

            # #todo name this issue about resource management

            if ents is None:  # (tested visually, return code is nonzero)
                return

            for rec in records_via(_CollectionTraversal(sch, ents, readme)):
                yield rec

    """Rule table (explained in more detail in huge comment below)

    (in the rightmost cel, imagine every value starts with "all ents ->")

    | UQ?|  sort by | Q?| S?|
    | -  |     -    |   |   | map to recs
    | -  |   mtime  |   | S | map to recs while add mtime to each -> sort
    | -  | priority | Q | S | map reduce to recs w priority -> sort
    | UQ |     -    | Q |   | reduce by query -> map to recs
    | UQ |   mtime  | Q | S | reduce by query -> map to (same) -> sort
    | UQ | priority | Q | S | reduce by query and map to rec -> sort

    (UQ = user query, Q? = "do we need a query?", S? = "do we sort?"
    """

    def records_via():
        if user_query_tokens:
            uqt = user_query_tokens
            if yes_priority:
                return sort(_when_UQ_and_priority(uqt, listener))
            if yes_mtime:
                return sort(_when_UQ_and_mtime(uqt, opn, listener))
            return _when_UQ(uqt, listener)

        if yes_priority:
            return sort(_when_priority(listener))
        if yes_mtime:
            return sort(_when_mtime(opn, listener))
        return _when_totally_unadorned()

    yes_priority, yes_mtime = False, False
    if sort_by:
        sort_kw = {}
        by_what, ASC_or_DESC = sort_by
        if 'by_priority' == by_what:
            sort_kw['key'] = lambda rec: rec.priority
            assert 'ASCENDING' == ASC_or_DESC
            yes_priority = True
        else:
            assert 'by_time' == by_what
            sort_kw['key'] = lambda rec: rec.mtime
            if 'DESCENDING' == ASC_or_DESC:
                sort_kw['reverse'] = True
            else:
                assert 'ASCENDING' == ASC_or_DESC
            yes_mtime = True

        def sort(recordser):
            def use_recordser(ct):
                records = recordser(ct)
                return sorted(records, **sort_kw)
            return use_recordser

    try:
        records_via = records_via()
    except _Stop:  # #here3
        return

    return records_via_readme


# == Six Permutations

"""If you're thinking, "why is this so un-DRY?"

Ideally:

    ents = all_entities()

    if yes_some_cheaper_reduce():
        ents = (ent for ent in ents if some_test(ent))

    if yes_some_more_expensive_reduce():
        ents = (ent for ent in ents if expensive_test(ent))

    if has_this_one_sort_by():
        ents = sorted(ents, **sorted_kw)

    return (RecordStructure(ent) for ent in ents)

Ideally the generator is created all in one place, having filters and maps and
sorts progressively added to it as necessary based on user arguments.

This gets high marks for clarity and also efficiency: The code has clear
intent. As well, it has the efficiency of only ever traversing a collection
once, as well as the efficiency of avoiding redundant branching at traversal
time (i.e., you don't want to be doing IF statements about user arguments at
every entity traversed, probably).

And before #history-B.5 this was how we did it. But that all changed when
adding priority, which put us past some threshold of complexity:

At first, "#priority" is just like any other user-queryable tag (imagine
"#open"). Tag-querying is expensive: for multiple cels of every row, traverse
every regex in the query testing each regex separately against each cel (as
necessary based on the boolean conjunctor (AND or OR) of each node of the
query tree).

It's expensive enough that we absolutely will *not* run two separate queries
for cases when we have both a user query and a priority reduce-sort (which
is the most common real-word use case). So in these cases we AND together the
two queries (using a feature added to the external library just for this) so
that we only ever do one traversal and we delegate to the tag query library
to manage the boolean conjuction rather than hard-coded AND logic.

But the priority tag needs custom processing for value after it matches
(which can fail in numerous ways and we want to be able to skip over). IFF
it didn't fail we want to map out this custom value (in this case a float)
alongside the entity (quite like we do with mapping out an mtime when that
option is engaged) so that it will be in the record struct and sorted against.

At writing, all this is too much to keep track of while still keeping the
code DRY *and* transparent. Later when we establish coverage for the below
six (because why six?) we can try to tighten it back up
"""


# uqt = user query tokens

def _when_UQ_and_priority(uqt, listener):
    def records_via(ct):
        readme = ct.readme
        pass_filter = pass_filter_er(ct.schema)
        for priority_float, ent in pass_filter(ct.entities):
            yield _Record(ent, readme, priority=priority_float)
    pass_filter_er = _build_build_priority_pass_filter(listener, uqt)
    return records_via


def _when_UQ_and_mtime(uqt, opn, listener):
    def records_via(ct):
        readme = ct.readme
        mtime = mtime_via_lineno_via_readme(readme)
        UQ_pass_filter = UQ_pass_filter_er(ct.schema)
        ents = UQ_pass_filter(ct.entities)
        return (_Record(ent, readme, mtime=mtime(ent.lineno)) for ent in ents)
    UQ_pass_filter_er = _build_build_user_query_pass_filter(uqt, listener)
    mtime_via_lineno_via_readme = _build_mtime_function_function(opn, listener)
    return records_via


def _when_UQ(uqt, listener):
    def records_via(ct):
        readme = ct.readme
        UQ_pass_filter = UQ_pass_filter_er(ct.schema)
        return (_Record(ent, readme) for ent in UQ_pass_filter(ct.entities))
    UQ_pass_filter_er = _build_build_user_query_pass_filter(uqt, listener)
    return records_via


def _when_priority(listener):
    def records_via(ct):
        readme = ct.readme
        priority_pass_filter = priority_pass_filter_er(ct.schema)
        for priority_float, ent in priority_pass_filter(ct.entities):
            yield _Record(ent, readme, priority=priority_float)
    priority_pass_filter_er = _build_build_priority_pass_filter(listener)
    return records_via


def _when_mtime(opn, listener):
    def records_via(ct):
        ents, readme = ct.entities, ct.readme
        mtime = mtime_via_lineno_via_readme(readme)
        return (_Record(ent, readme, mtime=mtime(ent.lineno)) for ent in ents)
    mtime_via_lineno_via_readme = _build_mtime_function_function(opn, listener)
    return records_via


def _when_totally_unadorned():
    def records_via(ct):
        readme = ct.readme
        return (_Record(ent, readme) for ent in ct.entities)
    return records_via


# == Support for the permutations

# spp = stateful priority parser

def _build_build_priority_pass_filter(listener, uqt=None):
    def build_UQ_plus_priority_pass_filter(schema):
        def pass_filter(entities):
            for ent in entities:
                mds = matchdatas_via_ent(ent)
                if mds is None:
                    continue
                flot = spp(mds['#priority'])
                if flot is None:
                    continue
                yield flot, ent
        matchdatas_via_ent = _build_matchdatas_via_row_AST(schema, matcher)
        return pass_filter
    spp = _build_stateful_priority_parser(listener)
    if uqt:
        """(put the query node for priority to the LEFT of that for user query
        because in practice it usually lets you short-circuit out of the
        expensive tag query engine sooner: issues with '#priority' are
        typically a subset of '#open' issues (and in any case usually smaller
        in number), so if you do that criteria first you knock candidates out
        of the running sooner. It's like a basketball playoff bracket (is it?);
        or like if you had to find all people who are gemini and have purple
        hair; you will do less work if you check hair color first before
        astrological sign; in a world where purple hair is rarer than gemini.)
        """

        user_matcher = _build_user_query_matcher(uqt, listener)  # #here3
        matcher = _produce_priority_matcher().AND_matcher(user_matcher)
    else:
        matcher = _produce_priority_matcher()
    return build_UQ_plus_priority_pass_filter


def _build_build_user_query_pass_filter(uqt, listener):
    def build_user_query_pass_filter(schema):
        def pass_filter(entites):
            return (ent for ent in entites if yes_no(ent))
        yes_no = _build_matchdatas_via_row_AST(schema, matcher)
        return pass_filter
    matcher = _build_user_query_matcher(uqt, listener)
    return build_user_query_pass_filter


def _build_user_query_matcher(uqt, listener):
    matcher = _matcher_via_tokens(uqt, listener)
    if matcher is None:
        raise _Stop()
    return matcher


def _produce_priority_matcher():
    return _matcher_via_tokens(('#priority',))


def _matcher_via_tokens(tokens, listener=None):
    from tag_lyfe.magnetics.query_via_token_stream import \
        EXPERIMENTAL_NEW_WAY as func
    return func(tokens, listener)


def _build_mtime_function_function(opn, listener):
    def mtime_via_lineno_via_readme(readme):
        vcs_index = do_index_via(readme, listener, opn_for_git)
        if vcs_index is None:
            xx("maybe the file isn't in version control?")
        return vcs_index.datetime_for_lineno
    from kiss_rdb.vcs_adapters.git import blame_index_via_path as do_index_via
    opn_for_git = (opn and opn.open_for_git)
    return mtime_via_lineno_via_readme


# ==

def _build_matchdatas_via_row_AST(schema, matcher):
    def matchdatas_via_row_AST(row_AST):
        dct = row_AST.core_attributes
        any_cel_strings = (dct.get(k) for k in body_keys)
        cel_strings = (s for s in any_cel_strings if s)
        cel_strings = tuple(cel_strings)  # necessary in case multiple matchers
        return matcher.matchdatas_against_strings(cel_strings)
    body_keys = schema.field_name_keys[1:]  # [#871.1]
    return matchdatas_via_row_AST


# ==

_CollectionTraversal = _namedtuple(
    '_CollectionTraversal', ('schema', 'entities', 'readme'))


@_dataclass
class _Record:
    row_AST: object
    readme: str
    priority: float = None
    mtime: object = None


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
                if fixed_for_now != body_ks:
                    reason = f"expected {fixed_for_now!r} had {body_ks!r}"
                    raise RuntimeError(reason)
                yield sch, enx
        return cm()

    fixed_for_now = 'main_tag', 'content'

    class issues_collection:  # #class-as-namespace
        def to_graph_lines(listener=listener, **kw):
            from .graph import to_graph_lines_ as func
            return func(issues_collection, listener, **kw)

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


# ==

def _build_stateful_priority_parser(listener):

    def spp(md):
        string = md.string
        _start, pos = md.span()
        md = rx.match(string, pos)
        dct = {k: v for k, v in _parse_priority(md, pos)}
        reason = dct.get('reason')
        if reason is None:
            flot = dct['value_float_value']
            if flot in seen:
                reason = "Can't re-use the same priority number. Already seen:"
        if reason:
            return whine_about(reason, dct.get('pos', pos), string)
        seen.add(flot)
        return flot

    def whine_about(reason, pos, string):
        def lines():
            yield reason
            yield ''.join((margin, string))
            yield ''.join((margin, ('-'*pos), '^'))
        margin = '    '
        listener('error', 'expression', 'parse_error', lines)

    from re import compile as re_compile, VERBOSE
    rx = re_compile(r"""
        : (?P<right_hand_side>                          # a colon followed by
            (?P<priority_name> [a-z]+(?:-[a-z]+)* )     # words ("extra-high")
            |                                           # or an integer or flot
            (?P<priority_number> -? [0-9] + (?P<flot_part> \. [0-9]+ )? )
        )?
    """, VERBOSE)
    seen = set()
    return spp


def _parse_priority(md, pos):
    if md is None:
        yield 'reason', "Expecting colon (\":\")"
        return

    pos += 1  # advance pointer over the colon
    yield 'pos', pos

    if md['right_hand_side'] is None:
        yield 'reason', "Expecting priority value (e.g \"0.123\")"
        return

    if md['priority_name']:
        yield 'reason', "No support for string names yet, use numbers"
        return

    yield 'pos', md.span('right_hand_side')[1] - 1  # advance to point to after

    if md['flot_part'] is None:
        yield 'reason', "Must be a floating point number"
        return

    flot = float(md['priority_number'])
    if flot <= 0.0:
        yield 'reason', "Priority value cannot be negative or 0.0"
        return

    if 1.0 <= flot:
        yield 'reason', "Priority value must be less than 1.0"
        return

    yield 'value_float_value', flot  # whew!

# ==


def build_identifier_parser_(listener, cstacker=None):  # #testpoint

    def identifier_via_string(piece):
        """At #history-B.4 we had to leave behind something more readable

        to introduce the new kind of fancy ranges (inclusive/exclusive).
        This *almost* has us wanting to look into EBNF etc but sigh
        """

        def main():
            ch = scn.more and scn.peek(1)
            if '[' == ch:
                return when_open_square_bracket()
            if '#' == ch:
                return when_octothorpe_at_beginning()
            if '(' == ch:
                return when_open_paren_at_beginning()
            scn.whine_about_expecting(
                open_bracket, octothorpe, open_parenthesis)

        # == Three kinds of beginnings

        def when_open_square_bracket():
            scn.advance_by_one()
            if parse_any_wild_oldschool_markdown_footnote_thing():
                return when_oldschool()
            parse_identifier_starting_with_octothorpe()
            if parse_any_dash():
                open_and_close_bracket_type[0] = 'square'
                return finish_range_tight_version()
            parse_close_bracket()
            if parse_any_dash():
                open_and_close_bracket_type[0] = 'square'
                return finish_range_wide_version()
            parse_end_of_string()

        def when_octothorpe_at_beginning():
            parse_identifier_starting_with_octothorpe()
            parse_end_of_string()

        def when_open_paren_at_beginning():
            open_and_close_bracket_type[0] = 'parenthesis'
            parse_identifier_starting_with_octothorpe()
            parse_dash()
            parse_identifier_starting_with_octothorpe()
            parse_close_square_bracket_or_parenthesis_and_end_of_string()

        # ==

        def when_oldschool():
            # this form is ancient and hasn't been covered in ages and prob gon

            parse_identifier_starting_with_octothorpe()
            parse_wild_oldschool_markdown_footnote_thing_close()
            parse_end_of_string()

        def finish_range_tight_version():
            # If you use the dash inside the range, fancy range caps
            # example tight ranges:  "[#123-#123.5)"  "(#123-#124]"
            parse_identifier_starting_with_octothorpe()
            parse_close_square_bracket_or_parenthesis_and_end_of_string()

        def finish_range_wide_version():
            # If you use the dash outside the brackets, no fancy range caps
            # example wide range: "[#123]-[#124.B]"

            parse_open_square_bracket()
            parse_identifier_starting_with_octothorpe()
            parse_close_bracket()
            parse_end_of_string()

        # == Parse Identifiers

        def parse_identifier_starting_with_octothorpe():
            scn.skip_required(octothorpe)
            begin_identifier()
            parse_the_first_component()
            if scn.empty or '.' != scn.peek(1):
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

        def parse_wild_oldschool_markdown_footnote_thing_close():
            xx()

        def parse_any_wild_oldschool_markdown_footnote_thing():
            if '\\' == scn.peek(1):
                xx()

        def parse_close_square_bracket_or_parenthesis_and_end_of_string():
            ch = scn.more and scn.peek(1)
            if ']' == ch:
                typ = 'square'
            elif ')' == ch:
                typ = 'parenthesis'
            else:
                scn.whine_about_expecting(close_bracket, close_parenthesis)
            open_and_close_bracket_type[1] = typ
            scn.advance_by_one()
            parse_end_of_string()

        # == Single characters

        def parse_open_square_bracket():
            scn.skip_required(open_bracket)

        def parse_any_dash():
            return scn.skip(dash)

        def parse_dash():
            scn.skip_required(dash)

        def parse_close_bracket():
            scn.skip_required(close_bracket)

        def parse_end_of_string():
            if scn.empty:
                return
            scn.whine_about_expecting('end of string')

        # == Support

        def begin_identifier():
            one_or_two_identifiers.append([None, None, True])  # #here1

        one_or_two_identifiers = []
        open_and_close_bracket_type = [None, None]
        scn = build_string_scanner(piece)

        try:
            main()
        except stop:
            return
        rang = tuple(_Identifier(*three) for three in one_or_two_identifiers)
        if 1 == len(rang):
            iden, = rang
            return iden
        return _IdentifierRange(*rang, *open_and_close_bracket_type)

    from text_lib.magnetics.string_scanner_via_string import \
        build_throwing_string_scanner_and_friends as func
    o, build_string_scanner, stop = func(listener, cstacker)

    fnetd = o('for now exactly three digits', '[0-9]{3}')
    dot = o('"."', r'\.')
    octothorpe = o('octothorpe', '#')
    open_bracket = o('open bracket', r'\[')
    open_parenthesis = o('open parenthesis', r'\(')
    second_component_as_letter = o('second component as letter ([A-Z])', '[A-Z]')  # noqa: E501
    second_component_as_number = o('second component as number (d or dd)', '[0-9]{1,2}')  # noqa: E501
    dash = o('dash', '-')
    close_bracket = o('close bracket', r']')
    close_parenthesis = o('close parenthesis', r'\)')
    return identifier_via_string


# == Models

class _IdentifierRange:

    def __init__(self, one, two, open_square_or_paren, close_square_or_paren):
        self.start_is_included = _include_yes_no.index(open_square_or_paren)
        self.stop_is_included = _include_yes_no.index(close_square_or_paren)
        self.start, self.stop = one, two

    def to_string(self):
        return ''.join(self._to_string_pieces())

    def _to_string_pieces(self):
        yield '[' if self.start_is_included else '('
        yield '#'
        for pc in self.start._to_inner_string_pieces():
            yield pc
        yield '-#'
        for pc in self.stop._to_inner_string_pieces():
            yield pc
        yield ']' if self.stop_is_included else ')'

    is_range = True


_include_yes_no = ('parenthesis', 'square')


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

    def to_inner_string_(self):
        return ''.join(self._to_inner_string_pieces())

    def _to_string_pieces(self):
        if self.include_bracket:
            yield '['
        yield '#'
        for pc in self._to_inner_string_pieces():
            yield pc
        if self.include_bracket:
            yield ']'

    def _to_inner_string_pieces(self):
        major_int, minor_int = self.key
        yield '%03d' % major_int
        if minor_int is not None:
            yield '.'
            yield self._minor_surface  # (Case3853)

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


def xx(msg=None):
    raise RuntimeError('write me' + ('' if msg is None else f": {msg}"))


class _Stop(RuntimeError):
    pass

# #history-B.5
# #history-B.4
# #born.
