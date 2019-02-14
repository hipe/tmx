import kiss_rdb.magnetics_.identifiers_via_file_lines as trav_lib
from .identifiers_via_file_lines import (
        stop, okay, nothing,
        )


def new_lines_via_delete_and_existing_lines(
        identifier_string,
        incoming_lines,
        existing_lines,
        listener,
        ):

    assert(incoming_lines is None)

    _ = _ActionsForUpdateOrDelete('delete')
    return _new_lines_via_chunky_actionser(
            _, identifier_string, incoming_lines, existing_lines, listener)


def new_lines_via_update_and_existing_lines(
        identifier_string,
        incoming_lines,
        existing_lines,
        listener,
        ):

    _ = _ActionsForUpdateOrDelete('update')
    return _new_lines_via_chunky_actionser(
            _, identifier_string, incoming_lines, existing_lines, listener)


def new_lines_via_create_and_existing_lines(
        identifier_string,
        incoming_lines,
        existing_lines,
        listener,
        ):

    _args_for_CUD_function = (identifier_string, incoming_lines)

    return LINE_STREAM_THE_NEW_WAY(
            _args_for_CUD_function,
            CREATE_THE_NEW_WAY,
            incoming_lines,
            existing_lines,
            listener,
            )


def _new_lines_via_chunky_actionser(client, id_s, new_s_a, big_s_a, listener):

    from kiss_rdb.magnetics_.identifiers_via_file_lines import (
            state_machine_ as _my_state,  # before #tombstone-A.1 we used to et
            )

    def actionser(parse_state):
        actions = _ActionsForCUD(client, id_s, new_s_a, parse_state)

        def f(name):
            return getattr(actions, name)
        return f

    _chunks = _my_state.parse(big_s_a, actionser, listener)

    for chunk in _chunks:
        for line in chunk:
            yield line


"""overview:

#todo: this whole comment block will hopefully go away soon...

the implementation of our parse actions occurs at the confluence of many
considerations. throughout this implementation we'll observe that the
manner in which these considerations fit together is not entirely self-
emergent; that is: it takes lots of test cases, thought and refactorings
to come up with a solution that's readable, DRY and correct.

(the hardest part is accepting that you don't know the best way as you
are writing the code.)

the considerations are:

  - which of two parse actions is being called ("enter section" or EOS).
  - whether we have just left the start state.
  - whether we are still searching for a "mode-changing" section.
  - whether the current line is a section line.
  - if yes, whether that section line needs to be parsed.
  - if yes, what to do on parse failure.
  - if yes, what to do on parse success (where to put the AST).
  - whether there's some cached lines.
  - if yes, whether they need to be flushed (emitted) now.
  - if yes, which of those lines need to be flushed now.
  - if yes, whether they should be flushed before or after any
    argument entity to be emitted.
  - whether we want our chunks of lines to have boundaries that coincide
    with the boundaries between existing document entities (sections).
  - whether there's an argument entity yet to be emitted.
  - when flushing cached lines, whether they are a previous section
    or just fluff that was at the beginning of the file. (a file may have
    any of the four purmutations of fluff/no fluff, sections/no sections.)
  - the fact that we would like this facility be applicable to more than
    one taxonomic category of operation (i.e at this moment CREATE+UPDATE)

we appear to to have served all these concerns through use of something like
dependency injection: there is one core parse actions "engine" that exposes
one method for each parse action (two at writing).

at construction this engine is injected with a client that does those
specific parts of the behavior that vary based on the verb being performed.

the three verbs are served by two client implementations: there is one
for CREATE and another that serves both UPDATE and DELETE.

(UPDATE and DELETE are similar enough that it's easier this way. which verb
is performed is determined by a flag (string) passed as an argument).
"""


def _parse_action(two_sub_chunks):
    """wraps a higher-level parse action definition with lower-level work

    so that the higher-level function can be written more DRY and literately.
    lower-level work like:

      - client function can simply return None on failure rather than
        the more obtuse two-tuples of (ok/not ok, payload)

      - the two sub-chunks are concatenated in the OCD way

      - necessary state change (step tick)

      - sanity check
    """

    def f(o):
        o.open_sanity_check
        tup = two_sub_chunks(o)
        if tup is None:
            return stop
        if o.just_left_start_state:
            o.just_left_start_state = False
        a_1, a_2 = tup
        # (doing this a cute, OCD, verbose way for now)
        if a_1 is None:
            if a_2 is None:
                return nothing  # (Case483)
            else:
                return (okay, a_2)  # (Case417)
        elif a_2 is None:
            return (okay, a_1)  # (Case517)
        else:
            return (okay, a_1 + a_2)  # (Case450)

    return f


class _ActionsForCUD:

    def __init__(self, client, id_s, new_lines, ps):

        # --
        self.still_searching = True
        self.just_left_start_state = True
        self.open_sanity_check = None

        # -- for caching EACH received line
        ps.on_line_do_this(self._receive_line)
        self._cached_lines = []

        # -- invocation arguments
        self.client = client
        self.argument_identifier_string = id_s
        self._new_lines = new_lines
        self.parse_state = ps

    """at section start:

    this parse action is called just after a section line has been received
    (that is, when such a line is the current line).

    if you're coming here after another section, only now do you know that the
    other section has closed. otherwise (and you're coming here from the start
    state) there either is or isn't one or more lines of opening fluff cached
    that we have to flush.
    """

    @_parse_action
    def on_section_start(o):

        if o.just_left_start_state:
            if o.has_more_than_one_cached_line:
                # head fluff in non-empty file (Case517)
                a_1 = o.step_the_cache()
            else:
                # hi. no head fluff. no pass-thru to flush now (Case483)
                a_1 = None
        else:
            # most often, flush lines of the previous section :#here1
            ok, a_1 = o.client.subchunk_one_on_nonfirst_section(o)
            if not ok:
                return

        if o.still_searching:
            id_s = o.section_identifier_via_section_line()
            if id_s is None:
                return
            if id_s < o.argument_identifier_string:
                # the section we are stepping in to should be output before
                # the argument section. just cache lines like this like normal
                # and in the next step they'll be flushed #here1 (Case483)
                a_2 = None
            elif o.argument_identifier_string < id_s:
                # for a CREATE this is probably a "mode-change". for a
                # UPDATE or DELETE this is probably an error condition.
                ok, a_2 = o.client.subchunk_two_when_greater_than(o)
                if not ok:
                    return
            else:
                # argument ID equals this ID. whether or not this is a fail
                # state depends on the operation being served. (for UPDATE
                # it must be that condition is met exactly once (formally).
                # for CREATE it must be that it is never met.)
                ok, a_2 = o.client.subchunk_two_when_equal(o)
                if not ok:
                    return
        else:
            # perhaps passthru which happened above
            ok, a_2 = o.client.subchunk_two_when_done_searching(o)
            if not ok:
                return

        return (a_1, a_2)

    """at end of input:

    assume that this is the parse action associated with every transition that
    moves you into the 'done' state. assume further that the grammar supports
    moving directly from the start state to the done state.

    if you came here from the start state, then the file was either
    effectively empty (meaning there was one or more fluff lines at the start
    of the file) or truly empty (meaning zero bytes).

    otherwise (and you came her not from the start state) you came here after
    having been in a section (entity), the last line of which you only just
    now learned that you have received.
    """

    @_parse_action
    def at_end_of_input(o):
        del o.open_sanity_check

        if o.still_searching:
            ok, tup = o.client.subchunks_at_end_when_still_searching(o)
            if not ok:
                return
            a_1, a_2 = tup
        else:
            assert(not o.just_left_start_state)
            ok, a_1 = o.client.subchunk_one_at_end_when_not_searching(o)
            if not ok:
                return
            a_2 = None
        return (a_1, a_2)

    def section_identifier_via_section_line(self):
        o = self.parse_state
        otl = trav_lib.open_table_line_via_line_(o.line, o.listener)
        if otl is None:
            return
        id_s = otl.identifier_string
        which = otl.table_type

        # (we aren't validating. here we are indifferent.)
        assert('attributes' == which or 'meta' == which)
        return id_s

    def be_no_longer_searching(self):
        assert(self.still_searching)
        self.still_searching = False  # this effectuates the "mode change"

    def _receive_line(self):
        self._cached_lines.append(self.parse_state.line)

    def clear_the_one_line_and_disengage_cache(self):
        assert(1 == len(self._cached_lines))
        self._cached_lines = None

    def reengage_the_cache(self, lis):
        assert(self._cached_lines is None)
        self._cached_lines = lis

    def step_the_cache(self):
        assert(self.has_more_than_one_cached_line)
        a = self._cached_lines
        self._cached_lines = [a.pop()]
        return a

    def release_cache(self):
        assert(self.has_more_than_zero_cached_lines)  # (Case875)
        a = self._cached_lines
        del self._cached_lines
        return a

    def release_empty_cache(self):
        assert(self._cached_lines is None)
        del self._cached_lines

    def release_new_lines(self):
        a = list(self._new_lines)
        assert(0 < len(a))
        del self._new_lines
        return a

    def release_NO_lines(self):  # just to assert this
        assert(self._new_lines is None)
        del self._new_lines

    @property
    def has_more_than_one_cached_line(self):
        return 1 < len(self._cached_lines)

    @property
    def has_more_than_zero_cached_lines(self):
        return 0 < len(self._cached_lines)


class _ActionsForUpdateOrDelete:

    def __init__(self, which):
        if 'update' == which:
            self._is_update = True
            self._is_delete = False
        elif 'delete' == which:
            self._is_update = False
            self._is_delete = True
        else:
            assert(False)

        self._is_normal_mode = True

    def subchunk_one_on_nonfirst_section(self, o):
        """normally be normal, but on the section we are replacing, rien."""

        if self._is_normal_mode:
            return (okay, o.step_the_cache())  # (Case925)
        else:
            return nothing  # also (Case925)

    def subchunk_two_when_equal(self, o):
        """when doing a UPDATE this is the condition you've been waiting to

        meet. just like a CREATE we release the argument lines here. but
        in contrast to CREATE, rather than outputting the entity we are
        stepping in to, we are replacing it; so actually what we do is *turn
        off* line caching
        """

        self.__turn_things_off(o)
        if self._is_update:
            chunk_or_none = o.release_new_lines()
        else:
            o.release_NO_lines()
            chunk_or_none = None
        return (okay, chunk_or_none)

    def subchunk_two_when_greater_than(self, o):
        """finding a document section that is greater than the argument entity

        is an error condition when doing an UPDATE because you should have
        found a section that is equal to the argument entity before finding
        one greater, and you should have mode-changed then.
        """

        known_error_case_yet_to_cover()  # #open #[#867.C]

    def subchunks_at_end_when_still_searching(self, o):
        """if you get to the end of the document and you are still searching,

        then the matching section wasn't in the document and the UPDATE can
        not be performed.
        """

        known_error_case_yet_to_cover()  # #open #[#867.C]

    def subchunk_two_when_done_searching(self, o):

        if self._is_normal_mode:
            cover_me()
            return (okay, o.step_the_cache())
        else:
            self.__turn_things_back_on(o)
            return nothing

    def subchunk_one_at_end_when_not_searching(self, o):
        """in contrast to what happens for CREATE, here we may or may not

        have a final cached chunk to output, based on whether the section
        that was updated/deleted was the last section..
        """

        if self._is_normal_mode:
            lines_or_none = o.release_cache()
        else:
            o.release_empty_cache()
            lines_or_none = None  # (Case975)

        return (okay, lines_or_none)

    def __turn_things_off(self, o):

        def f():
            pass  # hi.

        self._prev_line_handler = o.parse_state.replace_line_handler(f)
        o.be_no_longer_searching()
        o.clear_the_one_line_and_disengage_cache()
        self._is_normal_mode = False

    def __turn_things_back_on(self, o):

        ps = o.parse_state

        ps.replace_line_handler(self._prev_line_handler)
        del self._prev_line_handler

        self._is_normal_mode = True
        o.reengage_the_cache([ps.line])


def LINE_STREAM_THE_NEW_WAY(
        args_for_CUD_function,
        CUD_function,
        incoming_lines,
        existing_lines,
        listener):

    from .identifiers_via_file_lines import (
            block_stream_via_file_lines,
            ErrorMonitor_)

    monitor = ErrorMonitor_(listener)

    _block_itr = block_stream_via_file_lines(existing_lines, monitor.listener)

    _block_itr = BLOCK_STREAM_THE_NEW_WAY(
            args_for_CUD_function,
            CUD_function,
            _block_itr,
            monitor)

    for block in _block_itr:
        for line in block.to_line_stream():
            yield line


def BLOCK_STREAM_THE_NEW_WAY(args, CUD_function, block_itr, monitor):

    # == always same for head block

    head_block = None
    for head_block in block_itr:
        break

    if not monitor.ok:
        return

    if head_block is None:
        # the only OK way there can be head block None is when the file is
        # truly empty (or non-existent) (Case417). our hope is that for all
        # of C, U and D the CUD_function can implement itself indifferently.
        pass
    else:
        yield head_block

    # ==

    _block_itr = __block_stream_check_order(block_itr, monitor.listener)

    _block_itr = CUD_function(*args, _block_itr, monitor)

    for block in _block_itr:
        yield block


# ==

def CREATE_THE_NEW_WAY(id_s, new_entity_lines, block_itr, monitor):

    # find the first item that is greater. output those that are lesser.

    first_greater = None
    for de in block_itr:
        if de.identifier_string < id_s:
            yield de
        elif de.identifier_string == id_s:
            cover_me('erroneous monk - this has a case')
        else:
            # NOTE this means we have found a first document entity that
            # has an identifier string that is greater. we use this below!
            first_greater = de
            break

    if not monitor.ok:
        return

    # output the new lines

    yield _LinesAsBlock(new_entity_lines)

    # output that first (any) one we found that was greater.

    if first_greater is not None:
        yield first_greater

    # output any of the remainder (this could fail at any step in traversal)

    for de in block_itr:
        yield de


# ==


def __block_stream_check_order(block_itr, listener):

    # new in #history-A.2, for each of CUD, ensure this

    none = True
    for de in block_itr:
        none = False
        break

    if none:
        return

    yield de

    curr_id_s = de.identifier_string

    for de in block_itr:
        next_id_s = de.identifier_string

        if curr_id_s < next_id_s:  # this is how it is supposed to be
            curr_id_s = next_id_s
            yield de
            continue

        cover_me('original doohah out of order')  # #todo


class _LinesAsBlock:

    def __init__(self, lines):
        self._lines = lines

    def to_line_stream(self):
        return self._lines  # while it works :P


def known_error_case_yet_to_cover():
    raise Exception('known error case yet to cover')


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')

# #history-A.2: begin rewrite of CUD using block stream not parse actions
# #tombstone-A.1: got rid of mutate state machine,now empty files OK everywhere
# #born.
