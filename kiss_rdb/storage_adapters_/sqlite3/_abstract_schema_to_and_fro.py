def abstract_schema_via_sqlite3_connection(conn, listener):
    lines = _schema_lines_as_if_one_full_monty_because_why_not(conn)
    return abstract_schema_via_sqlite_SQL_lines(lines)


def _schema_lines_as_if_one_full_monty_because_why_not(conn):
    """Normalize the lines we get from the sqlite query to have semicolons

    and newlines, and also munge all the lines together as if in one stream of
    lines, because our parser is already designed to accomodate that
    """

    c = conn.cursor()
    c.execute('SELECT sql FROM sqlite_master WHERE type = "table"')
    for row in c:
        big_string, = row
        lines = big_string.splitlines(keepends=True)
        last_char = lines[-1][-1]
        assert '\n' != last_char
        add_these = []
        if ';' != last_char:
            add_these.append(';')
        add_these.append('\n')
        lines[-1] = ''.join((lines[-1], *add_these))
        for line in lines:
            yield line


def abstract_schema_via_sqlite_SQL_lines(lines):

    # (in impl, this func is just a light wrapper that breaks streaming)
    def tables():
        for typ, val in sxs:
            assert 'abstract_create_table_statement' == typ
            yield val
    sxs = tuple(_abstract_table_defs_via_sqlite_lines(lines))

    from kiss_rdb.magnetics_.abstract_schema_via_definition import \
        abstract_schema_via_abstract_tables as func

    return func(tables())


def _abstract_table_defs_via_sqlite_lines(lines):

    # == (the extremely popular #[#008.2] FSA pattern, but ultra mega)

    def from_root_state():
        yield if_keyword('CREATE'), lambda: push_to(from_expect_TABLE_keyword)

    def from_expect_TABLE_keyword():
        yield if_keyword('TABLE'), enter_create_table

    def enter_create_table():
        assert 'from_expect_TABLE_keyword' == stack.pop().__name__
        store['column_definitions'] = []
        expect_sequence(
            ('string_literal', 'as', 'table_name'),  # was once 'wordy_token'
            ('punctuation', '('),
            ('then_call_this', lambda: push_to(from_expecting_column_def)))

    def from_expecting_column_def():
        yield if_wordy_token, enter_column_definition

    def enter_column_definition():
        store['column_name'] = token_value
        push_to(from_expecting_type_name)

    def from_expecting_type_name():
        yield if_keyword_INTEGER, on_type_name_thats_also_valid_storage_class
        yield if_keyword_TEXT, on_type_name_thats_also_valid_storage_class
        # float one day..

    def on_type_name_thats_also_valid_storage_class():
        assert 'from_expecting_type_name' == stack.pop().__name__
        store['column_type_storage_class'] = abstract_type_via[token_value]
        push_to(from_expecting_column_constraint_or_get_out)

    def from_expecting_column_constraint_or_get_out():
        yield if_keyword_NOT, lambda: push_to(from_expecting_NULL_after_NOT)
        yield if_comma, handle_comma_after_column_def
        yield if_keyword_PRIMARY, lambda: push_to(from_expecting_KEY_after_PRIMARY)  # noqa: E501
        yield if_close_paren, handle_close_parenthesis_of_table
        yield if_keyword_REFERENCES, lambda: push_to(from_inside_FK_clause)
        yield if_keyword_UNIQUE, handle_UNIQUE

    def handle_comma_after_column_def():
        roll_over_column_def()
        move_to(from_expecting_column_def)  # look up

    def from_inside_FK_clause():
        yield if_string_literal, handle_FK

    def handle_FK():
        store['references_what_table'] = token_value
        assert 'from_inside_FK_clause' == stack[-1].__name__
        move_to(from_maybe_FK_column)

    def from_maybe_FK_column():
        yield if_open_paren, handle_foreign_key_column
        yield otherwise, when_no_zub_zub

    def handle_foreign_key_column():
        expect_sequence(
            ('wordy_token', 'as', 'referenced_column_name'),
            ('punctuation', ')'),
            ('then_call_this', after_FK))

    def when_no_zub_zub():
        after_FK()
        return ('retry',)

    def after_FK():
        assert 'from_maybe_FK_column' == stack.pop().__name__
        assert 'from_expecting_column_constraint_or_get_out' == stack[-1].__name__  # noqa: E501

    def from_expecting_NULL_after_NOT():
        yield if_keyword_NULL, handle_not_null

    def handle_not_null():
        store['not_null'] = True
        assert 'from_expecting_NULL_after_NOT' == stack.pop().__name__

    def handle_UNIQUE():
        store['is_unique'] = True

    def from_expecting_KEY_after_PRIMARY():
        yield if_keyword_KEY, handle_primary_key

    def handle_primary_key():
        store['is_primary_key'] = True
        assert 'from_expecting_KEY_after_PRIMARY' == stack.pop().__name__

    def handle_close_parenthesis_of_table():
        assert 'column_name' in store  # right?
        roll_over_column_def()
        assert 'from_expecting_column_def' == stack[-1].__name__
        move_to(from_expecting_semicolon_to_end_table)

    def roll_over_column_def():
        k = stack[-1].__name__
        assert 'from_expecting_column_constraint_or_get_out' == k
        stack.pop()
        k = stack[-1].__name__
        assert 'from_expecting_column_def' == k
        kw = {}
        kw['column_name'] = store.pop('column_name')
        kw['column_type_storage_class'] = store.pop('column_type_storage_class')  # noqa: E501

        """In our practice, 'NOT NULL' is the norm by some significant margin.
        So that it takes up less visual/cognitive space by not needing to state
        itself explicitly everywhere, it's the default in our abstract modeling
        (provision [#XXX.X]), and we expose a `null_is_OK` option there, one
        that is not usually exercised.

        With SQL (and so sqlite) on the other hand, "NULL OK" is the option,
        and there is no "NULL OK" or equivalent.

        This would all be fine and good if we simply start out 'null OK' as
        true here and flip it to false if we parse 'NOT NULL'; but things
        get tricky because we don't yet know this about sqlite:

        is NOT NULL implied on INTEGER PRIMARY KEY?

        For now we assume yes (hence the logic below) but this needs confirmati
        """

        is_prim = store.pop('is_primary_key', False)
        if 'not_null' in store:
            val = store.pop('not_null')
            assert val is True
            null_OK = False
        else:
            null_OK = not is_prim

        kw['null_is_OK'] = null_OK

        is_uniq = store.pop('is_unique', False)
        kw['is_unique'] = is_uniq

        references_who = store.pop('references_what_table', None)
        if references_who:
            kw['is_foreign_key_reference'] = True
            kw['referenced_table_name'] = references_who
            maybe = store.pop('referenced_column_name', None)
            kw['referenced_column_name'] = maybe

        kw['is_primary_key'] = is_prim

        ac = abstract_column_via(**kw, listener=stopping_listener)
        store['column_definitions'].append(ac)

    def from_expecting_semicolon_to_end_table():
        yield if_semicolon, wahoo_close_the_table_because_semicolon

    def wahoo_close_the_table_because_semicolon():
        assert 'from_expecting_semicolon_to_end_table' == stack.pop().__name__
        table_name = store.pop('table_name')
        cols = store.pop('column_definitions')
        table = abstract_table_via(table_name, cols, stopping_listener)
        return 'yield_this', ('abstract_create_table_statement', table)

    from kiss_rdb.magnetics_.abstract_schema_via_definition import \
        abstract_table_via_name_and_abstract_columns as abstract_table_via, \
        abstract_column_via

    # ==

    def if_keyword(kw):
        def func():
            return 'wordy_token' == token_type and kw == token_value
        return func

    def if_string_literal():
        return 'string_literal' == token_type

    def if_wordy_token():
        return 'wordy_token' == token_type

    if_keyword_INTEGER = if_keyword('INTEGER')
    if_keyword_TEXT = if_keyword('TEXT')
    if_keyword_NOT = if_keyword('NOT')
    if_keyword_NULL = if_keyword('NULL')
    if_keyword_UNIQUE = if_keyword('UNIQUE')
    if_keyword_PRIMARY = if_keyword('PRIMARY')
    if_keyword_KEY = if_keyword('KEY')
    if_keyword_REFERENCES = if_keyword('REFERENCES')

    abstract_type_via = {'INTEGER': 'int', 'TEXT': 'text'}

    # ==

    def if_punctuation(char):
        def func():
            return 'punctuation' == token_type and char == token_value
        return func

    if_comma = if_punctuation(',')
    if_open_paren = if_punctuation('(')
    if_close_paren = if_punctuation(')')
    if_semicolon = if_punctuation(';')

    # ==

    def expect_sequence(*directives):
        # The biggest flex ever. make a state function dynamically,
        # one whose alternatives are determined solely by the my_stack
        # (and only ever has one alternative). Experiment

        def from_custom_state():
            typ = my_stack[-1][0]
            if 'string_literal' == typ:
                return when_wordesque_token(if_string_literal)
            if 'wordy_token' == typ:
                return when_wordesque_token(if_wordy_token)
            assert 'punctuation' == typ
            return when_punct()

        def when_wordesque_token(if_what):
            def action():
                store[store_as] = token_value
                my_stack.pop()
                return maybe_pop()
            as_kw, store_as = my_stack[-1][1:]
            yield if_what, action

        def when_punct():
            def action():
                my_stack.pop()
                return maybe_pop()
            char, = my_stack[-1][1:]
            yield if_punctuation(char), action

        def maybe_pop():
            typ = my_stack[-1][0]  # .. (for now assume always this direc)
            if 'then_call_this' != typ:
                return
            func, = my_stack[-1][1:]
            my_stack.pop()
            assert not my_stack  # ..(for now always assume it's at the end)
            assert 'from_custom_state' == stack.pop().__name__
            return func()

        my_stack = list(reversed(directives))
        push_to(from_custom_state)

    def otherwise():
        return True

    # ==

    def move_to(state_function):
        stack[-1] = state_function

    def push_to(state_function):
        stack.append(state_function)

    # ==

    def find_transition():
        for test, action in stack[-1]():
            yn = test()
            if yn:
                return action
        lines = [f"for {token_type} token {token_value!r},"]
        from_where = stack[-1].__name__.replace('_', ' ')
        lines.append(f"didn't find a transition {from_where}.")
        lines.append(f"from line {tokens.line_offset + 1}: {tokens.line!r}")
        xx(' '.join(lines))

    store = _NoClobberDict()
    stack = [from_root_state]

    # == Our listener is a messy ball just to make runtime errors pretty

    def stopping_listener(sev, shape, *rest):
        *mid, payloader = rest
        assert 'error' == sev
        if 'expression' == shape:
            lines = tuple(payloader())
        else:
            assert 'structure' == shape
            wat = payloader()
            lines = []
            if (reason := wat.pop('reason', None)):
                lines.append(reason)
            if (func := wat.pop('build_two_lines_of_ASCII_art')):
                lines.extend(func())
            if not lines:
                lines.append(''.join(('idk: ', repr(tuple(wat.keys())))))
        xx('\n'.join(lines))

    # == The Token Scanner (who needs Lexx! See how fun this is!?)

    def cstacker():  # give context to parse errors
        dct = {k: v for k, v in context_keys_and_values()}
        return (dct,) if dct else ()

    def context_keys_and_values():
        # If it's an open filehandle, add filename
        if hasattr(lines, 'name'):
            yield 'path', lines.name

        # Maybe an error happened while there were zero lines seen so far
        if tokens.line_offset is not None:
            yield 'line', tokens.line
            yield 'lineno', tokens.line_offset + 1

    from text_lib.magnetics.string_scanner_via_string import \
        build_throwing_string_scanner_and_friends as func
    o, build_scanner, stop = func(stopping_listener, cstacker)
    # (there's probably redundancy where both client and us raise stops on etc)

    wordy_token = o('wordy token', '[a-zA-Z_][a-zA-Z0-9_]*')  # sure why not
    rxs = ''.join(("'", wordy_token.regex.pattern, "'"))
    single_quoted_fella = o('sinqle quoted fella', rxs)
    punctuation = o('punctuation', r'[,();]')
    space_or_tabs = o('tab or space', r'[ \t]+')
    newline = o('newline', r'\n')

    def tokens():

        def end_of_line():
            yn = scn.skip(newline)
            if not yn:
                return
            assert scn.empty
            return True

        for line_offset, line in enumerate(lines):
            tokens.line_offset, tokens.line = line_offset, line

            scn = build_scanner(line)
            while True:  # the only way out is #here1

                # The most frequent token is the wordy token
                value = scn.scan(wordy_token)
                if value:
                    yield 'wordy_token', value
                    scn.skip(space_or_tabs)  # (it's frequently followed by ws)
                    continue  # (it's frequently followed by another wordy)

                sqf = scn.scan(single_quoted_fella)
                if sqf:
                    yield 'string_literal', sqf[1:-1]
                    scn.skip(space_or_tabs)  # (it's frequently followed by ws)
                    continue  # (it's frequently followed by another wordy)

                # Most lines have at least one punctuation
                value = scn.scan(punctuation)
                if value:
                    yield 'punctuation', value
                    if end_of_line():  # (1/2 the time. eek the root of all ev)
                        break
                    continue

                # If it didn't match wordy or punct, usually it's this
                if end_of_line():
                    break

                # Sometimes we indent lines with whitespace
                yn = scn.skip(space_or_tabs)
                if yn:
                    continue

                scn.whine_about_expecting(
                    wordy_token, punctuation, space_or_tabs)

    tokens.line_offset = None  # #watch-the-world-burn

    if True:
        """At writing there's no handling of stops, just lots of "cover me"
        holes. But it's almost guaranteed that for production we will want to
        maturize this to make parse failures not as catstrophic-looking.

        At such time, change this `if True` to a `try` block. We won't simply
        keep thing shallow and wrap them in more and more functions because we
        want the parsimony of the loop item variable being global here.
        """

        for token_type, token_value in tokens():
            while True:
                action = find_transition()
                direc = action()
                if direc is None:
                    break  # next token
                typ = direc[0]
                if 'yield_this' == typ:
                    sx, = direc[1:]
                    yield sx
                    break
                assert 'retry' == typ

    if 1 < len(stack):
        xx('stream ended early, exected sometong')

# ==


def SQL_lineses_for_CREATE_TABLEs_(abstract_tables, listener):
    # it's gonna throw an sqlite3.OperationalError on any syntax errors

    for at in abstract_tables:
        yield _SQL_lines_for_CREATE_TABLE(at)


def _SQL_lines_for_CREATE_TABLE(at):
    s = at.table_name
    _sanity_check_table_name(s)
    s = _single_quote(s)

    """We think this is a sqlite bug #todo:
    We need to put the below in quotes (single or double, doesn't seem to
    matter) because our table name might be a keyword (like 'commit')
    but when we use quotes, the .schema command adds an IF NOT EXISTS,
    but only for the .schema command not for sqlite_master.sql
    """

    yield f"CREATE TABLE {s} (\n"

    assert at._columns  # ..
    prev_line = None
    for col in at.to_columns():
        if prev_line:
            yield ''.join(('  ', prev_line, ',\n'))
        prev_line = _CREATE_TABLE_column_line_no_end_for(col)
    yield ''.join(('  ', prev_line, ');\n'))


def _CREATE_TABLE_column_line_no_end_for(col):
    words = (w for row in _column_words(col) for w in row)
    return ' '.join(words)


def _column_words(col):
    """
    (sqlite (and the adjacent SQL ISO standard) gives you flexibility in what
    order you put a lot of the clauses here. For lack of any formal guidelines,
    we're going to follow the cosmetic, surface order as presented in the
    visuals [here][1] at the time of writing, just so we produce SQL that is
    self-consistent and hopefully "sounds natural".)

    [1]: https://www.sqlite.org/lang_createtable.html
    """

    s = col.column_name
    _sanity_check_column_name(s)
    yield (s,)

    abs_typ = col.column_type_storage_class

    if col.is_primary_key:
        assert 'int' == abs_typ
        assert not col.is_foreign_key_reference
        assert not col.null_is_OK
        yield 'INTEGER', 'PRIMARY', 'KEY'
        return

    if 'int' == abs_typ:
        yield ('INTEGER',)
    else:
        assert 'text' == abs_typ
        yield ('TEXT',)

    if not col.null_is_OK:
        yield 'NOT', 'NULL'

    if col.is_unique:
        yield ('UNIQUE',)

    if col.is_foreign_key_reference:
        s = col.referenced_table_name
        _sanity_check_table_name(s)
        yield 'REFERENCES', _single_quote(s)
        s = col.referenced_column_name
        if s:
            _sanity_check_column_name(s)
            yield (''.join(('(', s, ')')),)

    # 'INDEX' stuff will be a hoot


def _single_quote(s):
    # this was a necessity for us because table names were keywords (COMMIT)

    assert "'" not in s
    return ''.join(("'", s, "'"))


def _sanity_check_table_name(s):
    return _sanity_check(s, 'table name')


def _sanity_check_column_name(s):
    return _sanity_check(s, 'column name')


def _sanity_check(s, surface_noun_phrase):
    o = _sanity_check
    if not hasattr(o, 'x'):
        o.x = {k: v for k, v in _build_sanity_check()}
    rx = o.x[surface_noun_phrase]
    if rx.match(s):
        return
    xx(f"malformed {surface_noun_phrase}? {s!r}")


def _build_sanity_check():
    import re
    yield 'table name', re.compile(r'[a-z]+(?:_[a-zA-Z]+)*\Z')
    yield 'column name', re.compile(r'[a-zA-Z]+(?:_[a-zA-Z]+)*\Z')


# ==

class _NoClobberDict(dict):  # c/p #[#508.5] custom strict data structure

    def __setitem__(self, k, v):
        assert k not in self
        return super().__setitem__(k, v)


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #born
