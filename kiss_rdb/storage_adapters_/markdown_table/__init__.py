"""NOTE this was #born only to bootstrap the development of the canon
"""
import re


def resolve_collection_via_file(opened, path, listener):

    if opened is None:
        try:
            opened = open(path)
        except FileNotFoundError as e_:
            e = e_

    if opened is None:
        assert(e)
        return _whine_about_collection_not_found(listener, lambda: str(e))

    with opened as fh:
        table_blocks = _table_blocks_via_filehandle(fh, path).execute()

    num_tables = len(table_blocks.children)

    if 0 == num_tables:
        return __whine_about_no_tables(listener, table_blocks, path)

    if 1 < num_tables:
        return __whine_about_too_many_tables(listener, table_blocks, path)

    return table_blocks.children[0].flush_to_table_as_collection()


# == decorators

def string_via_pieces(f):
    def use_f(selv):
        _hello = tuple(f(selv))
        return ''.join(_hello)
    return use_f


def dormant(f):
    def use_f(selv):
        if selv._is_dormant:
            selv._wake()
        return f(selv)
    return use_f


# ==

class _MUTABLE_Table_Block:
    """This exists only during the initial parse pass of the whole file

    (when we are looking for any multiple tables). It's a separate class only
    so that we don't have to look at or think about all this state elsewhere)
    """

    def __init__(self, header_line, inner):
        self._entity_lines = []
        self._header_line = header_line
        self._inner = inner

    def _accept_second_line(self, line, location_in_file):
        inner = self._inner
        del self._inner
        hl = self._header_line
        del self._header_line
        self._schema = _TableSchema(inner, line, hl, location_in_file)

    def append_entity_line(self, line):
        self._entity_lines.append(line)

    def close_mutable_table_block(self):
        s_a = self._entity_lines
        del self._entity_lines
        return _FrozenTableBlock(tuple(s_a), self._schema)


class _FrozenTableBlock:
    """might go away"""

    def __init__(self, lines, schema):
        self._body_lines = lines
        self._schema = schema

    def flush_to_table_as_collection(self):
        s_tup = self._body_lines
        del self._body_lines
        return _TableAsCollection(s_tup, self._schema)


class _TableAsCollection:

    def __init__(self, lines, schema):
        self._implementation = _MutableFreezableCollection(lines, schema)
        self._is_mutable = True

    def update_entity_as_storage_adapter_collection(self, iden, tup, listener):
        return self._implementation._update_(iden, tup, listener)

    def create_entity_as_storage_adapter_collection(self, dct, listener):
        return self._implementation._create_(dct, listener)

    def delete_entity_as_storage_adapter_collection(self, identi, listener):
        return self._implementation._delete_(identi, listener)

    def retrieve_entity_as_storage_adapter_collection(self, identi, listener):
        return self._implementation._retrieve_(identi, listener)

    def to_entity_stream_as_storage_adapter_collection(self, listener):
        return self._implementation._traverse_entities_(listener)

    def to_identifier_stream_as_storage_adapter_collection(self, listener):
        return self._implementation._traverse_IDs_(listener)

    def FREEZE_HACK(self):
        assert(self._is_mutable)
        self._is_mutable = False
        self._implementation._FREEZE_HACK_()
        return self


"""Introduction to yes no-value/yes-value, and
Why a tail-anchored pipe is hard to interpret correctly :#here5

            An undocumented provision is that you can't store blank strings,
            empty strings or the "null value"; for at least two reasons: One,
            it's an intentional trade-off to allow for more aesthetic/readable
            surface forms. Two, we don't *want* to support the distinction,
            because in practice this infects business code with the smell of
            not knowing whether you need to check for null/empty/blank for a
            given value, a smell that can spread deep into the code. :[#867.Y]

            Rather, we conflate all such cases into one we call "no-value",
            and we leave it up to the client to decide how or whether to
            represent a value whose key isn't present in the entity-as-dict.

            Also for reasons, we do not require that the entity row express
            those of its contiguous cel values that are no-value and also
            anchored to the tail of the line.

            This is to say:
                |foo|bar||||||||
            is the same as:
                |foo|bar|

            `man git-log` brings up the distinction bewteen
            > "terminator" semantics and "separator" semantics.
            This distinction between these two categories becomes relevant
            here with our interpretation of the pipe ("|").

            Also we allow for an optional, decorative trailing pipe on any
            row (that's not the first or maybe second row, that is the
            "the table head"). This is to say that all these are the same:

                |foo|bar||||||||
                |foo|bar|
                |foo|bar

            Combining the two broad principles above; namely that no-value
            expressions are not required when tail-anchored, and that any
            trailing pipe might be decorative; we cannot know how many field
            values the row intends to express just by looking at it. So: #here5
"""


class _MutableFreezableCollection:

    def __init__(self, lines, schema):
        self._is_mutable = True
        self._entity_lines = lines
        self._schema = schema

    def _update_(self, identi, tup, listener):
        """because we store every table line in memory anyway (the two-pass

        thing where we first count the tables in a file on the first pass),
        we're not gonna be OCD for now about this edit (remember the scope
        of this whole storage adapter). But this is written so that it would
        be feasible to adapt this to something more stream-oriented.
        """

        lines = iter(self._entity_lines)
        new_lines, future = _update(lines, identi, tup, self._schema, listener)
        new_lines_tup = tuple(new_lines)  # before below
        two = future()  # after above
        if two is None:
            return  # (Case2713)
        # (Case2716)
        before_ent, after_ent = two
        self._on_new_entity_lines(new_lines_tup)
        return before_ent, after_ent

    def _create_(self, dct, listener):

        lines = iter(self._entity_lines)
        new_lines, future = _create(lines, dct, self._schema, listener)
        new_lines_tup = tuple(new_lines)  # before below
        new_ent = future()  # after above
        if new_ent is None:
            return  # (Case2676)
        # (Case2682)
        self._on_new_entity_lines(new_lines_tup)
        return new_ent

    def _delete_(self, identi, listener):

        lines = iter(self._entity_lines)
        new_lines, future = _delete(lines, identi, self._schema, listener)
        new_lines_tup = tuple(new_lines)  # before below
        deleted_ent = future()  # after above
        if deleted_ent is None:
            return  # (Case2641)
        self._on_new_entity_lines(new_lines_tup)
        return deleted_ent

    def _retrieve_(self, iden, listener):
        return _retrieve(self._entity_lines, iden, self._schema, listener)

    def _traverse_IDs_(self, listener):
        return _IDs_via_lines(self._entity_lines, listener)

    def _traverse_entities_(self, listener):
        return _entities_via_lines_and_schema(
                self._entity_lines, self._schema, listener)

    def _on_new_entity_lines(self, lines):
        assert(self._is_mutable)
        self._entity_lines = lines

    def _FREEZE_HACK_(self):
        assert(self._is_mutable)
        self._is_mutable = False


def _update(lines, iden, tup, schema, listener):
    asts_via_line = _ASTs_via_line_via_listener(listener, schema)

    def future_then_new_lines():
        """.#here2 is a hack-or-pattern (used 3x in this file) which allows us
        to (sort of? maybe?) set client-exposed side-effects while iterating.

        The client receives two values: this iterator (in-progress, but they
        don't know it) and a function, which for now we have awkwardly dubbed
        a 'future'. The client promises to call this future (used quite like a
        pointer) only after traversal is complete, allowing the client to
        "dereference" a location in memory that we set some time during
        traversal. In part, this allows the client to know if traversal
        failed without them needing to set up a "monitor".

        This hack/pattern allows us to deliver arbitrary other named valued
        (like properties) besides just each item we yield. Suggestions welcome.
        """

        def future():
            return before_and_after
        before_and_after = None
        yield future

        # ==

        found = False
        num_lines = 0
        for line in lines:
            asts = asts_via_line(line)
            curr_ID_cel = next(asts)
            if iden == curr_ID_cel.identifier_in_first_cel:
                found = True
                break
            yield line
            num_lines += 1

        if not found:
            # (Case2710)
            _whine_about_entity_not_found(listener, num_lines, iden, 'update')
            return

        before_ent = _entity_from_these_two(curr_ID_cel, asts)

        UCDs = _prepare_edit(before_ent, tup, schema, 'update', listener)
        if UCDs is None:
            return  # (Case2713)

        after_ent = _flush_edit(before_ent, UCDs, schema)

        yield after_ent._TO_LINE_()

        for line in lines:
            yield line

        before_and_after = before_ent, after_ent  # complete the future

        express_edit_(listener, UCDs, iden, 'updated')

    itr = future_then_new_lines()
    return itr, next(itr)  # use the hack


def _create(lines, dct, schema, listener):
    """Create and insert the entity in an appropriate place in the table.

    If the table is empty (has no body lines (entities)), chose integer 1
    ('223') as the identifier and output the new entity as the only body line.
    Return.

    Assume at least one existing body-line (entity) in the table.

    Assert that the table's items are in ascending order (but not necessarily
    contiguous).

    Entity creation will never re-arrange the existing items in the table.
    The new entity will never be placed as the new first item in the table.

    For each (zero or more) next line in table, compare it to the line above
    it in terms of its identifier.

    If the integer "jump" (difference) between the two entity identifiers is
    exactly one, pass-through the current line and continue on to the next one.

    If the integer jump is less than one, the input table is out of order.
    Throw a not_covered error.

    Otherwise (and the integer jump is more than one), this is the insertion
    point. (Etc do the insertion.)

    Pass-thru the line you were holding on to.

    Pass thru the zero or more remaining lines WHILE CHECKING THAT each next
    identifier is greater than the one above. If any one of these is not this,
    the input table is out of order and throw a not_covered.

    An edge case is if the one or more existing entities are ordered and
    contiguous (no gaps, every jump is 1). Then append the new entity after
    passing through every existing line.
    """

    asts_via_line = _ASTs_via_line_via_listener(listener)

    codec = _memoized.identifier_codec
    iden_via_s = codec.identifier_via_string
    iden_via_int = codec.identifier_via_integer
    int_via_ident = codec.integer_via_identifier

    def cel_via_iden(iden):
        return _IdentifierInFirstCel(_w_left, iden, _w_right)

    def future_then_new_lines():

        # == set up #here2
        def future():
            return new_entity
        new_entity = None
        yield future
        # ==

        # creation is implemented as a specialized update

        fake_before_ent = _RowAsEntity(None, (), has_trailing_pipe=False)
        tup = tuple(('create_attribute', k, v) for k, v in dct.items())
        UCDs = _prepare_edit(fake_before_ent, tup, schema, 'create', listener)
        if UCDs is None:
            return  # (Case2676)

        new_ent = _flush_edit(fake_before_ent, UCDs, schema)

        # determine whether the table is empty with a peek of one line

        table_is_empty = True
        for first_line in lines:  # #once
            table_is_empty = False
            break

        def succeeded():  # (successful exit happens 2x here :/)
            _express_edit(listener, UCDs, new_iden, 'created')
            return new_ent

        # if the table is empty, give the new entity with an ID of 1 (Case2679)

        if table_is_empty:
            new_iden = iden_via_s('223')  # not iden_via_int(1) because depth
            new_ent._identifier_cel_ = cel_via_iden(new_iden)
            yield new_ent._TO_LINE_()
            new_entity = succeeded()
            return

        # table not empty, so find the insertion point with the algo (Case2682)

        prev_iden = next(asts_via_line(first_line)).identifier_in_first_cel
        prev_int = int_via_ident(prev_iden)

        yield first_line  # the new entity will neve be before the first line

        output_this_line = None  # we might need to keep 1 line "on deck" belo

        for line in lines:
            curr_iden = next(asts_via_line(line)).identifier_in_first_cel
            curr_int = int_via_ident(curr_iden)

            jump = curr_int - prev_int

            if 1 == jump:  # per the ☝️ algorithm
                prev_iden = curr_iden
                prev_int = curr_int
                yield line
                continue

            if jump < 1:
                _ = (f"bad jump from '{prev_iden.to_string()}' ({prev_int}) "
                     f"to '{curr_iden.to_string()}' ({curr_int}) "
                     '(i.e table is out of order)')
                not_covered(_)

            # the jump amount must be > 1. so this is the insertion point.

            output_this_line = line
            break

        # either you exhausted all the lines and the prev int is your prev int
        # or you found an open space and prev int is still your prev int.

        _my_int = prev_int + 1
        new_iden = iden_via_int(_my_int)  # who knows what depth
        new_ent._identifier_cel_ = cel_via_iden(new_iden)
        yield new_ent._TO_LINE_()

        if output_this_line is not None:

            yield output_this_line

            for line in lines:
                yield line

        new_entity = succeeded()

    itr = future_then_new_lines()
    return itr, next(itr)


def _delete(lines, iden, schema, listener):

    asts_via_line = _ASTs_via_line_via_listener(listener, schema)

    def future_then_new_lines():

        # == set up #here2
        def future():
            return deleted_ent
        deleted_ent = None
        yield future
        # ==

        found = False
        num_lines = 0
        for line in lines:
            asts = asts_via_line(line)
            curr_ID_cel = next(asts)
            if iden == curr_ID_cel.identifier_in_first_cel:
                found = True
                break
            yield line
            num_lines += 1

        if not found:
            _whine_about_entity_not_found(listener, num_lines, iden, 'delete')
            return

        deleted_ent = _entity_from_these_two(curr_ID_cel, asts)

        _num = len(deleted_ent._attribute_cels_)
        UCDs = ((), (), tuple(None for _ in range(0, _num)))

        for line in lines:
            yield line

        _express_edit(listener, UCDs, iden, 'deleted')

    itr = future_then_new_lines()
    return itr, next(itr)


def _flush_edit(original_ent, updates_creates_deletes, schema):
    # "edit" by resulting in a new entity meant to replace the arg entity

    # past this point (and for now), success is supposed to be inevitable

    updates, creates, deletes = updates_creates_deletes

    # don't count the leftmost (identifier) column when talking about offsets

    field_names = schema.normal_field_names[1:]
    num_fields = len(field_names)

    # start with a list that's the full length, to take arbitrary creates

    new_cels = [None for i in range(0, len(field_names))]

    # populate it with all the existing cels (which must be contiguous)

    orig_cels = original_ent._attribute_cels_
    num_original_cels = len(orig_cels)
    for i in range(0, num_original_cels):
        new_cels[i] = orig_cels[i]

    # invert the "dictionary" of field names

    offset_via_name = {field_names[i]: i for i in range(0, num_fields)}
    # (NOTE this could be pre-computed instead)

    # updates first, to re-assert that a cel is already there

    for k, new_content_s in updates:
        i = offset_via_name[k]
        original_cel = orig_cels[i]
        assert(k == original_cel.field_name)
        assert(0 < len(original_cel.content_string))
        new_cel = _AttributeCel(
                original_cel.left_number_of_spaces,
                new_content_s,
                original_cel.right_number_of_spaces,
                k)
        new_cels[i] = new_cel

    # creates before deletes, to re-assert the slot is clear

    # NOTE these attribute requests are in arbitrary, client-determined order

    this_offset = num_original_cels - 1  # bump this to keep track of..

    for k, new_content_s in creates:
        i = offset_via_name[k]
        new_cel = _AttributeCel(_w_left, new_content_s, _w_right, k)
        if this_offset < i:  # (or sort the request components)
            for j in range(this_offset+1, i):
                new_cels[j] = _AttributeCel(0, '', 0, field_names[j])
            this_offset = i
        else:
            original_cel = orig_cels[i]
            assert('' == original_cel.content_string)
        new_cels[i] = new_cel

    # deletes last because the other 2 wanted to go before them
    # NOTE the deletes are in an arbitrary, client-determined order
    # we feel like we should prune trailing empties, but that needs a policy

    for k in deletes:
        i = offset_via_name[k]
        original_cel = orig_cels[i]
        assert(0 < len(original_cel.content_string))
        new_cels[i] = _AttributeCel(0, '', 0, k)

    # Finally: you null-paddded the result list way above.
    # Now, take out the tail-anchored nulls you didn't need

    for i in reversed(range((this_offset+1), num_fields)):
        assert(new_cels[i] is None)
        assert(len(new_cels) == i + 1)
        new_cels.pop()

    _make_sure = filter(lambda i: new_cels[i] is None, range(0, len(new_cels)))
    assert(0 == len(tuple(_make_sure)))

    return _RowAsEntity(
            identifier_cel=original_ent._identifier_cel_,
            attribute_cels=tuple(new_cels),
            has_trailing_pipe=original_ent._has_trailing_pipe_,
            )


def _prepare_edit(ent, tups, schema, create_or_update, listener):
    """Prepare for an edit by validating and semi-normalizing the request.

    An edit request can fail to prepare for reasons like requesting to delete
    or updae a no-value attribute, requesting to create a yes-value attribute,
    referencing an unrecognized attribute name, or using an unrecognized verb.
    """

    updates = []
    creates = []
    deletes = []

    set_names = set()
    for cel in ent._attribute_cels_:
        if '' != cel.content_string:
            set_names.add(cel.field_name)

    known_names = schema.normal_field_name_set

    def encode(mixed):
        typ = type(mixed)
        if str == typ:
            return encode_string(mixed)

        # (Case2676): float and bool

        if typ in (int, float):
            return encode_string(str(mixed))  # still check string width 🤷

        if bool == typ:
            return 'yes' if mixed else 'no'  # 🤷

        not_covered(f"one day maybe we'll do '{type}' but not today")
    # decode hackishly is #here4

    def encode_string(s):
        leng = len(s)
        if leng == 0:
            not_covered("cannot store empty string. do not pass or use delete")
        elif 80 < leng:
            not_covered(f"sanity: quite long for a string: {leng}")
        md = re.match(r'[\n|]', s)
        if md is not None:
            _ = repr(md[0])
            not_covered(f'have fun implementing escaping & unescaping: {_}')
        return s

    fails = []

    for tup in tups:
        stack = list(reversed(tup))
        typ = stack.pop()
        k = stack.pop()
        if k not in known_names:
            fails.append(('unknown_attribute_name', k))
            continue
        if 'create_attribute' == typ:
            if k in set_names:
                fails.append(('cannot_create_because_yes_value', k))
                continue
            x = stack.pop()
            s = encode(x)
            creates.append((k, s))
        elif 'update_attribute' == typ:
            if k not in set_names:
                fails.append(('cannot_update_because_no_value', k))
                continue
            x = stack.pop()
            s = encode(x)
            updates.append((k, s))
        elif 'delete_attribute' == typ:
            if k not in set_names:
                fails.append(('cannot_delete_because_no_value', k))
                continue
            deletes.append(k)
        else:
            not_covered(f'bad attribute verb: {repr(typ)}')
        assert(0 == len(stack))

    if len(fails):
        __whine_about_cannot_prepare_edit(
                listener, fails, ent, schema, create_or_update)
        return

    return updates, creates, deletes


def _retrieve(lines, identi, schema, listener):
    if _max_depth < len(identi.native_digits):
        return __whine_about_identifier_depth(listener, identi)
    asts_via_line = _ASTs_via_line_via_listener(listener, schema)
    found = False
    count = 0
    for line in lines:
        asts = asts_via_line(line)
        curr_ID_cel = next(asts)
        if identi == curr_ID_cel.identifier_in_first_cel:
            found = True
            break
        count += 1
    if not found:
        return _whine_about_entity_not_found(listener, count, identi)
    return _entity_from_these_two(curr_ID_cel, asts)


def _IDs_via_lines(lines, listener):
    asts_via_line = _ASTs_via_line_via_listener(listener)
    for line in lines:
        yield next(asts_via_line(line)).identifier_in_first_cel  # ..


def _entities_via_lines_and_schema(lines, schema, listener):
    asts_via_line = _ASTs_via_line_via_listener(listener, schema)
    for line in lines:
        identi_cel, *attr_cels, has_t = asts_via_line(line)  # ..
        yield _RowAsEntity(identi_cel, tuple(attr_cels), has_t)


def _entity_from_these_two(identi_cel, asts):
    asts = list(asts)
    _has_trailing_pipe = asts.pop().has_trailing_pipe
    return _RowAsEntity(identi_cel, tuple(asts), _has_trailing_pipe)


def _ASTs_via_line_via_listener(listener, schema=None):

    from kiss_rdb.magnetics_.string_scanner_via_definition import (
            Scanner,
            pattern_via_description_and_regex_string as o,
            )

    pipe = o('pipe', r'\|')

    whitespace = o('whitespace', '[ ]+')

    some_non_empty_cel_content = o(
            'non empty cel content',
            r"""
            [^\|\n ]    # match one not pipe or space
            (?:         # optionally,
              [^\|\n]*  # match any non pipes (space OK)
              [^\|\n ]  # provided that the last char is a not pipe or space
            )?
            """,
            re.VERBOSE)

    eos = o('end of line', r'\n')  # ..

    def throwing_listener(*args):
        listener(*args)
        raise _Stop

    def asts_via_line(line):
        try:
            for tup in asts_via_line_inner(line):
                yield tup
        except _Stop:
            pass

    identi_via_s = _memoized.identifier_codec.identifier_via_string

    def asts_via_line_inner(line):
        # implement exactly this [#873] state machine illustration (see)

        scn = Scanner(line, throwing_listener)

        def skip_any_whitespace():
            w = scn.skip(whitespace)
            return 0 if w is None else w

        # start

        has_trailing_pipe = False

        # first cel

        scn.skip_required(pipe)

        w_left = skip_any_whitespace()

        s = scn.scan_required(some_non_empty_cel_content)
        identi = identi_via_s(s, listener)

        w_right = skip_any_whitespace()

        yield _IdentifierInFirstCel(w_left, identi, w_right)

        field_names = schema.normal_field_names
        current_field_offset = 0  # off by one: we would start this at -1
        # but the first "field name" isn't a field name, it's "I d ENti Tfier"

        more = True
        while more:  # after content 010

            eos_w = scn.skip(eos)
            if eos_w is not None:
                break

            scn.skip_required(pipe)
            has_trailing_pipe = True

            while True:  # after pipe 020

                eos_w = scn.skip(eos)
                if eos_w is not None:
                    more = False
                    break

                current_field_offset += 1
                field_name = field_names[current_field_offset]  # ..

                pipe_w = scn.skip(pipe)
                if pipe_w is not None:
                    yield _AttributeCel(0, '', 0, field_name)
                    continue

                # allow for cels that are nothing but 1 or more spaces
                w_left = skip_any_whitespace()
                if w_left is 0:
                    content_s = scn.scan_required(some_non_empty_cel_content)
                else:
                    content_s = scn.scan(some_non_empty_cel_content)
                    if content_s is None:
                        content_s = ''
                w_right = skip_any_whitespace()
                has_trailing_pipe = False
                yield _AttributeCel(w_left, content_s, w_right, field_name)
                break

        assert(scn.eos())
        yield _HasTrailingPipeYesNo(has_trailing_pipe)

    return asts_via_line


# == RESOLVING THE CACHED LINES FROM A FILE

class _table_blocks_via_filehandle:
    # to preserve history, the comment block for this is up at #here5

    def __init__(self, fh, path):
        self._filehandle = fh
        self._path = path

    def execute(self):

        fh = self._filehandle
        del self._filehandle

        self._lineno = 0
        self._last_header_line = None
        self._current_mutable_table_block = None
        self._state = self._when_ready
        self._cached_table_blocks = []

        for line in fh:
            self._lineno += 1
            self._process_line(line)

        self._state(None)
        self._step()  # :#here1

        return _TableBlocks(
                children=tuple(self._cached_table_blocks),
                num_lines=self._lineno)

    def _when_ready(self, line):
        if '\n' == line:
            return
        if line is None:
            return  # assuming #here1
        char = line[0]
        if '|' == char:
            md = _table_open_line_rx.match(line)
            if not md:
                not_covered('when line starts with pipe but is not table open')
            # self._last_header_line can be None (Case2519)
            self._line_number_of_last_table_open = self._lineno
            self._step()
            self._current_mutable_table_block = _MUTABLE_Table_Block(
                    self._last_header_line, md[1])
            self._last_header_line = None
            return self._when_after_table_open
        if '#' == char:
            self._last_header_line = line
            return
        self._last_header_line = None

    def _when_after_table_open(self, line):
        if line is None:
            not_covered('when file ends after table open but b4 metrics line')
        if '|' != line[0]:
            not_covered("whine line after table open doesn't look like metrix")

        i = self._line_number_of_last_table_open
        del self._line_number_of_last_table_open
        _lif = _LocationInFile(i, self._path)

        self._current_mutable_table_block._accept_second_line(line, _lif)
        return self._when_inside_table_body

    def _when_inside_table_body(self, line):
        if line is None:
            # end of file when inside table, no big woop if #here1 (Case2519)
            return
        char = line[0]
        if '|' == char:
            self._current_mutable_table_block.append_entity_line(line)
            return
        self._state = self._when_ready
        self._process_line(line)

    def _process_line(self, line):
        f = self._state(line)
        if f is None:
            return
        self._state = f

    def _step(self):
        if self._current_mutable_table_block is None:
            return
        o = self._current_mutable_table_block
        self._current_mutable_table_block = None
        self._cached_table_blocks.append(o.close_mutable_table_block())


_table_open_line_rx = re.compile(r'^\|([^\|]+(?:\|[^\|]+)+)\|$')


# == models

class _RowAsEntity:
    # introduced at (Case2587)

    def __init__(self, identifier_cel, attribute_cels, has_trailing_pipe):
        assert(isinstance(attribute_cels, tuple))  # #[#008.D]
        self._identifier_cel_ = identifier_cel
        self._attribute_cels_ = attribute_cels
        self._has_trailing_pipe_ = has_trailing_pipe

    @string_via_pieces
    def _TO_LINE_(self):
        all_cels = (self._identifier_cel_, * self._attribute_cels_)
        * all_but_last, last_cel = all_cels
        for cel in all_but_last:
            yield '|'
            yield cel.to_cel_string_with_full_padding()
        yield '|'
        if self._has_trailing_pipe_:
            yield last_cel.to_cel_string_with_full_padding()
            yield '|'
        else:
            yield last_cel.to_cel_string_with_head_padding_only()
        yield '\n'  # ..

    def to_yes_value_dictionary_as_storage_adapter_entity(self):
        return {k: v for k, v in self.__to_key_and_non_empty_value_pairs()}

    def __to_key_and_non_empty_value_pairs(self):
        for cel in self._attribute_cels_:
            s = cel.content_string
            if '' == s:
                continue
            yield cel.field_name, cel.DECODE_HACKISHLY()

    @property
    def identifier(self):
        return self._identifier_cel_.identifier_in_first_cel


class _Cel:  # #abstract

    def __init__(self, w_left, w_right):
        self.left_number_of_spaces = w_left
        self.right_number_of_spaces = w_right

    @string_via_pieces
    def to_cel_string_with_full_padding(self):
        if self.left_number_of_spaces:
            yield ' ' * self.left_number_of_spaces
        yield self._to_main_piece_()
        if self.right_number_of_spaces:
            yield ' ' * self.right_number_of_spaces

    @string_via_pieces
    def to_cel_string_with_head_padding_only(self):
        if self.left_number_of_spaces:
            yield ' ' * self.left_number_of_spaces
        yield self._to_main_piece_()


class _IdentifierInFirstCel(_Cel):

    def __init__(self, w_left, identi, w_right):
        super().__init__(w_left, w_right)
        self.identifier_in_first_cel = identi

    def _to_main_piece_(self):
        return self.identifier_in_first_cel.to_string()


class _AttributeCel(_Cel):

    def __init__(self, w_left, content_string, w_right, field_name):
        super().__init__(w_left, w_right)
        self.content_string = content_string
        self.field_name = field_name

    def _to_main_piece_(self):
        return self.content_string

    def DECODE_HACKISHLY(self):
        # to do this right they would have to look like json then what's the p
        s = self.content_string
        assert(len(s))
        md = _crazy_rx.match(s)
        int_or_float, float_tail, boole, other = md.groups()
        if int_or_float is not None:
            if float_tail is not None:
                return float(int_or_float)
            return int(int_or_float)
        if boole is not None:
            return ('no', 'yes').index(boole)
        return other  # string


_crazy_rx = re.compile(r"""^(?:
(-?\d+(\.\d+)?) |
(yes|no) |
(.+)
)$""", re.VERBOSE)  # #here4


class _HasTrailingPipeYesNo:
    def __init__(self, yn):
        self.has_trailing_pipe = yn


class _TableSchema:
    # (hide the fact that you evaluate some stuff lazily)
    # (second line is ignored for now)

    def __init__(self, inner, second_line, header_line, location_in_file):
        self._inner = inner
        self._is_dormant = True
        self._name_from_header_is_awake = False
        self._header_line = header_line
        self.location_in_file = location_in_file

    @property
    def name_from_header(self):
        if self._name_from_header_is_awake:
            return self._name_from_header  # #only-when-whole-suite-is-run
        self._name_from_header_is_awake = True
        s = self._header_line
        del self._header_line
        if s is None:
            use_name = None
        else:
            md = re.match('^#+ *([^\n]+)', s)
            use_name = md[1]
        self._name_from_header = use_name
        return use_name

    @property
    @dormant
    def normal_field_names(self):
        return self._normal_field_names

    @property
    @dormant
    def normal_field_name_set(self):
        return self._normal_field_name_set

    def _wake(self):
        # resolve normal field names

        self._is_dormant = False
        inner = self._inner
        del self._inner

        def normal_field_name_of(content):
            # treat dashes, spaces, and underscores as all one unified separato
            _pieces = re.split(r'[- _]', content)
            return '-'.join(normal_piece_via_piece(piece) for piece in _pieces)

        def normal_piece_via_piece(piece):
            # lowercase the piece unless it is all caps EXPERIMENTAL
            if re.match(r'^[A-Z]+$', piece):
                return piece
            return piece.lower()

        tup = tuple(normal_field_name_of(s.strip()) for s in inner.split('|'))

        st = set()
        for s in tup[1:]:  # #here3
            st.add(s)

        self._normal_field_name_set = st
        self._normal_field_names = tup


class _TableBlocks:

    def __init__(self, children, num_lines):
        self.num_lines = num_lines
        self.children = children


class _LocationInFile:
    def __init__(self, lineno, path):
        self.lineno = lineno
        self.path = path


class _Stop(BaseException):
    pass


# == whiners

def express_edit_(listener, UCDs, identifier, created_or_updated_or_deleted):
    # (Case2716) (Case2682)

    def structer():
        # eg.: "updated 'XFG' (created 3, updated 2 and deleted 1 attribute)"
        # e.g: "created 'XFG' with 2 attributes"

        updates, creates, deletes = UCDs
        if 'updated' == created_or_updated_or_deleted:
            hack = list(__these_pieces(updates, creates, deletes))
            if len(hack):
                last_count_was_many = hack.pop()
                from modality_agnostic.magnetics.rotating_buffer_via_positional_functions import (  # noqa: E501
                        oxford_AND)
                _head = oxford_AND(iter(hack))
                s = 's' if last_count_was_many else ''
                detail = f'({_head} attribute{s})'
            else:
                detail = '(did nothing)'
        else:
            lc = len(creates)
            lu = len(updates)
            ld = len(deletes)
            if 'created' == created_or_updated_or_deleted:
                assert(0 == lu + ld)
                leng = lc
            else:
                assert(0 == lc + lu)
                leng = ld

            s = '' if 1 == leng else 's'
            detail = f'with {leng} attribute{s}'

        _iid_s = identifier.to_string()
        _message = f"{created_or_updated_or_deleted} '{_iid_s}' {detail}"

        return {'message': _message}

    if 'created' == created_or_updated_or_deleted:
        tail_channel = 'created_entity'
    elif 'updated' == created_or_updated_or_deleted:
        tail_channel = 'updated_entity'
    else:
        assert('deleted' == created_or_updated_or_deleted)
        tail_channel = 'deleted_entity'

    listener('info', 'structure', tail_channel, structer)


_express_edit = express_edit_


def __these_pieces(updates, creates, deletes):

    lc = len(creates)
    if lc:
        yield f'created {lc}'
        last_was_many = 1 < lc

    lu = len(updates)
    if lu:
        yield f'updated {lu}'
        last_was_many = 1 < lu

    ld = len(deletes)
    if ld:
        yield f'deleted {ld}'
        last_was_many = 1 < ld

    if lc or lu or ld:
        yield last_was_many  # (Case6226)


def __whine_about_cannot_prepare_edit(
        listener, fails, ent, schema, create_or_update):

    names_via_category = {}

    for cat, k in fails:
        if cat in names_via_category:
            a = names_via_category[cat]
        else:
            a = []
            names_via_category[cat] = a
        a.append(k)

    if 'create' == create_or_update:
        reason_head = "cannot create entity: "
        channel_tail = 'cannot_create'

    elif 'update' == create_or_update:
        reason_head = f"cannot update '{ent.identifier.to_string()}': "
        channel_tail = 'cannot_update'

    name_from_header = schema.name_from_header
    lif = schema.location_in_file
    lineno = lif.lineno
    path = lif.path

    sps = []  # sps = sentence phrases

    _order = (
        'cannot_create_because_yes_value',
        'cannot_update_because_no_value',
        'cannot_delete_because_no_value',
        'unknown_attribute_name',
        )
    _cats = sorted(names_via_category.keys(), key=_order.index)
    for cat in _cats:
        names = names_via_category[cat]
        plural = 1 != len(names)
        # comma-ify and quote the names in the splay
        splay_inner = ', '.join(f"'{k}'" for k in names)
        # parenthesize the splay if plural
        splay = f'({splay_inner})' if plural else splay_inner
        if 'unknown_attribute_name' == cat:
            if plural:
                this_these, s, does_do = 'these', 's', 'do'
            else:
                this_these, s, does_do = 'the', '', 'does'
            if name_from_header is None:
                in_the_table = ' in the table'
            else:
                in_the_table = f' in "{name_from_header}"'
            sps.append(f'{this_these} field{s} {splay} {does_do} not appear'
                       f'{in_the_table} in {path}:{lineno}')
        else:
            md = re.match(r'^cannot_([a-z]+)_because_(.+)$', cat)
            verb, yes_or_no = md.groups()
            yn = (True, False)[('yes_value', 'no_value').index(yes_or_no)]
            if plural:
                why = 'already have' if yn else 'have no existing'
                sps.append(f'cannot {verb} attributes because '
                           f'they {why} values: {splay}')
            else:
                why = 'already has a' if yn else 'has no existing'
                sps.append(f'cannot {verb} {splay} because it {why} value')

    _reason_tail = ', also '.join(sps)
    reason = f'{reason_head}{_reason_tail}'

    def structer():
        return {'reason': reason}
    listener('error', 'structure', channel_tail, structer)


def _whine_about_entity_not_found(listener, num_lines, iden, head=None):
    def structer():
        _use_head = '' if head is None else f'cannot {head} because '
        _reason = (  # (Case2609)
            f'{_use_head}'
            f"'{iden.to_string()}' not found "
            f"(searched {num_lines} line(s))"
            )
        return {'reason': _reason}
    listener('error', 'structure', 'entity_not_found', structer)


def __whine_about_identifier_depth(listener, iden):
    def structer():
        _actual = len(iden.native_digits)  # (Case2606)
        _reason = (
            f"can't retrieve '{iden.to_string()}' because "
            f"that identifier depth ({_actual}) exceeds "
            f"the max for this format ({_max_depth})"
            )
        return {'reason': _reason}
    listener('error', 'structure', 'entity_not_found', structer)


def __whine_about_too_many_tables(listener, cached_proto_tables, path):
    def reasoner():
        return (f'found {num_tables} markdown tables, '
                f'for now can only have one - {path}')
    num_tables = len(cached_proto_tables.children)
    _whine_about_collection_not_found(listener, reasoner)


def __whine_about_no_tables(listener, cached_proto_tables, path):
    def reasoner():
        return f'no markdown table found in {num_lines} lines - {path}'
    num_lines = cached_proto_tables.num_lines
    _whine_about_collection_not_found(listener, reasoner)


def _whine_about_collection_not_found(listener, reasoner):
    _emit_collection_not_found(listener, lambda: {'reason': reasoner()})


def _emit_collection_not_found(listener, structer):
    def use_structer():
        dct = structer()
        dct['reason'] = f"collection not found: {dct['reason']}"
        return dct
    listener('error', 'structure', 'collection_not_found', use_structer)


# == memoized resources (as an experiment)

class _Memoized:
    def __init__(self):
        self._do_ic = True

    @property
    def identifier_codec(self):
        if self._do_ic:
            self._do_ic = False
            self._ic = _IdentifierCodec()
        return self._ic


_memoized = _Memoized()


class _IdentifierCodec:  # experiment

    def __init__(self):
        import kiss_rdb.magnetics_.identifier_via_string as lib

        def f(s, listener=None):
            return use(s, listener)

        use = lib.identifier_via_string_

        self.identifier_via_string = f
        self.identifier_via_integer = lib.identifier_via_integer__
        self.integer_via_identifier = lib.integer_via_identifier_er__()


# == constants buried down here for now

_max_depth = 3  # identifier depth. not as important for single-file
_w_left = 1  # the "cel padding"
_w_right = 1


# ==

def not_covered(when):
    raise Exception(f'edge case not covered: {when}')


# #history-A.1 spike feature-completion, rewrite parser to use scanner not rx
# #born.
