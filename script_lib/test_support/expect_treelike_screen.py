"""parse a stream of lines into a tree-like structure, assuming the..

..intuitive indentation rules similar to that of python. like:

    head
      eyes
      mouth
        tongue
    torso
      arms
        left arm
        right arm
      legs

:[#014]
"""


def sections_via_lines_allow_align_right__(lines):
    # This one recognizes three categories of line and does just a coarse
    # parse of sections.

    # At #history-B.2 our help screen formatting changed and it broke against
    # the existing parser. We may or may not alter the reality to match the
    # test (the breakage did in fact reveal an oversight - we were aligning
    # right when we didn't mean to of column A items) but here we are.

    # States

    def begin_state():
        yield if_header_line, move_to_in_section_state
        yield base_case, whine_about_expecting_etc

    def in_section_state():
        yield if_indented_line, add_the_line_to_the_section
        yield if_blank_line, move_to_expecting_section_state
        yield base_case, say_maybe_we_will_support_this

    def expecting_section_state():
        yield if_header_line, move_to_in_section_state
        yield base_case, whine_about_expecting_etc

    # Actions

    def move_to_in_section_state():
        state.current_section_lines.clear()
        add_the_line_to_the_section()
        state.current_state_function = in_section_state

    def add_the_line_to_the_section():
        state.current_section_lines.append(line)

    def move_to_expecting_section_state():
        roll_section_over()
        state.current_state_function = expecting_section_state

    def whine_about_expecting_etc():
        xx('fun')
        # the current state is a function that makes a 2xN table. read
        # column one from the table (all but the last row) and hack the
        # names out of the functions to get the splay of expecting

    def say_maybe_we_will_support_this():
        raise RuntimeError("Maybe we will support a run of non-indented lines")

    # Matchers

    def if_header_line():
        return re.match('^[a-zA-Z]', line)

    def if_indented_line():
        return ' ' == line[0]

    def if_blank_line():
        return '\n' == line

    def base_case():
        return True

    # ..

    def roll_section_over():
        sections.append(tuple(state.current_section_lines))
        state.current_section_lines.clear()

    class state:  # #class-as-namespace
        current_section_lines = []
        current_state_function = begin_state

    sections = []
    import re

    for line in lines:
        these = state.current_state_function()
        action = next(action for matcher, action in these if matcher())  # 👀
        action()

    # At the end, we don't want there to be trailing blank lines, nor
    # (we think) do we want there to be a header line..

    end_state_name = state.current_state_function.__name__
    if 'in_section_state' != end_state_name:
        xx()

    # if len(state.current_section_lines

    roll_section_over()
    return tuple(sections)


def tree_via_lines(lines):
    _scanned_line_itr = (_ScannedLine(s) for s in lines)
    scn = _scanner_via_iterator(_scanned_line_itr)

    if scn.has_current_token:
        return __tree_when_one_or_more_lines(scn)


def __tree_when_one_or_more_lines(scn):

    """traverse every line of input, effecting state changes.

      - implement the parsing grammar through a state machine whose
        transitions correspond to changes in indent from one line to
        another (with special handling for blank lines). (below we'll
        say "indentation deltas" to mean changes in indentation from
        one line to another (including the "no change" change))

      - the transitions in the state machine will effect "actions"
        (code) that probaly places each input line somewhere into a
        stack which will somehow end up as the output tree.

      - the responsibility here is simply to traverse every line of
        input straightforwardly, comparing each current line to each
        previous line, effecting the appropriate transition at each
        hop (again, recognizing blank lines as special).

      - detail: let a "hop" be the transition from one line to another.
        any sequence of N lines has N-1 hops. hops are what effect state
        machine transitions, and transitions are how actions are
        effected, and actions are where our result structure is built.

        we want the first line of input to trigger the same indentation-
        delta-based mechanics as the rest of the parsing, but note there
        is no hop onto the first line because there is no pre-existing
        line to compare it to. so imagine this:

        imagine an "imaginary line before the first line" that:
          - is not a blank line
          - has no indent

        modeling such an imaginary line has these advantages:

          - we get to have One Loop to rule them all, that handles
            the first line indifferently from other lines.

          - there are certain special assertions that we want to make of the
            first line of input: that it is not a blank line, that it is not
            indented. we can effect these assertions "for free" through our
            state machine by virtue of not modeling those transitions we
            disallow. but in order to employ the state machine for this
            purpose, we have to see the first line of input in terms of an
            indentation delta just as we do the other lines.

          - as it works out, we also want to make these same assertions
            for every first line of a top-level section, not just the
            first line of input. we will re-use this this "imaginary
            line" for this purpose #here2.
    """

    def __main_loop():
        while True:
            this_line = scn.current_token
            if this_line.is_blank_line:
                state.blank_line()
            else:
                prev_num = state.effective_margin_length
                this_num = this_line.effective_margin_length
                if prev_num < this_num:
                    state.more_indent()
                elif prev_num == this_num:
                    state.same_indent()
                else:
                    state.less_indent()

            scn.advance_by_one_token()
            if not scn.has_current_token:
                break

    def current_tokener():
        return scn.current_token
    state = _state_machine(current_tokener)
    __main_loop()
    return state.end_of_input()


def _state_machine(current_tokener):  # #[#008.2] a state machine
    # (state machine made less obtuse at #history-A.2)

    class StateMachine:

        def less_indent(self):
            line = current_tokener()
            leng = line.effective_margin_length
            while True:
                stack_of_margin_lengths.pop()
                stack.pop()

                compare = stack_of_margin_lengths[-1]

                if compare > leng:
                    continue

                assert(compare == leng)
                break
            accept()

        def same_indent(self):
            accept()

        def more_indent(self):
            branch_above_children = stack[-1].children
            line_above = branch_above_children[-1]
            assert(line_above.is_terminal)

            line = current_tokener()
            new_branch = ChildBranchNode(line_above, line)

            # commit
            branch_above_children[-1] = new_branch
            stack_of_margin_lengths.append(line.effective_margin_length)
            stack.append(new_branch)

        def blank_line(self):
            accept()

        def end_of_input(self):
            del(state._mutex)
            return root

        @property
        def effective_margin_length(self):
            return stack_of_margin_lengths[-1]

    def accept():
        line = current_tokener()
        stack[-1].children.append(line)

    class RootBranchNode:
        def __init__(self):
            self.children = []

        is_terminal = False

    class ChildBranchNode:
        def __init__(self, head_line, first_child):
            self.head_line = head_line
            self.children = [first_child]

        is_terminal = False

    class PrivateState:
        def __init__(self):
            self._mutex = None

    sm = StateMachine()
    root = RootBranchNode()
    stack = [root]
    stack_of_margin_lengths = [0]
    state = PrivateState()

    return sm


class _ScannedLine:

    def __init__(self, line_s):
        match = self.__class__._THIS_ONE_RE.search(line_s)
        if match is None:
            raise Exception('assumption failed: was not newline terminated')
        self._match = match

        margin_s = self.margin_string
        content_s = self.styled_content_string

        is_blank_line = False
        if margin_s is None:
            if content_s is None:
                is_blank_line = True
            else:
                self.effective_margin_length = 0
        elif content_s is None:
            _tmpl = 'blank line with trailing whitespace is frowned upon: {}'
            raise _my_exception(_tmpl.format(repr(line_s)))
        elif _TAB in margin_s:
            raise _my_exception('tabs are gonna be annoying because math')
        else:
            self.effective_margin_length = len(margin_s)

        self.is_blank_line = is_blank_line

    def reader_for_named_group(m):
        """(ad-hoc single-purpose decorator for this classs only)"""

        name = m.__name__

        def f(self):
            return self._match.group(name)
        return f

    @property
    def s(self):
        _ = (self.margin_string or '')
        __ = (self.styled_content_string or '')
        return f'{_}{__}'

    @property
    @reader_for_named_group
    def styled_content_string():
        pass

    @property
    @reader_for_named_group
    def margin_string():
        pass

    is_terminal = True

    # #refa [#608.J] can you employ decorators w/o a starting method :#here1

    import re
    _THIS_ONE_RE = re.compile(
        '^(?P<margin_string>[ \t]+)?' +  # there need not be any
        '(?P<styled_content_string>[^\n\r]+)?' +  # there need not .. ibid.
        '(?:\n|\r\n?)')


class _scanner_via_iterator:  # #testpoint
    """there is a fundamental idiomatic difference between scanners and iterators..

    ..even though are isomorphic to one another.
    """

    def __init__(self, itr):
        self._iterator = itr
        self.has_current_token = True
        self.current_token = None
        self.advance_by_one_token()

    def advance_by_one_token(self):
        stay, item = self.__next_stay_and_item()
        if stay:
            self.current_token = item
        else:
            del self.current_token
            self.has_current_token = False

    def __next_stay_and_item(self):
        try:
            x = next(self._iterator)
            return True, x
        except StopIteration:
            del self._iterator
            return False, None


def _my_exception(msg):  # #copy-pasted
    from script_lib import Exception as MyException
    return MyException(msg)


def xx(msg='write me'):
    raise RuntimeError(msg)


_TAB = "\t"

# #history-B.2: spike a new state machine to accomodate align right
# #history-A.2: overhaul state machine to be less obtuse
# #history-A.1: refactor line streamer to use generator expression
# born.
