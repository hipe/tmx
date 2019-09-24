"""
one thing with index files is they're never meant to be human-editable
(although we take pains to make them human readable!) so we do _not_
go to lengths to make error messages pretty,
or even to cover such edges cases for now!
"""


import re


class _CLI:
    """see if index file parses ok. visual test."""

    # based off the one in index_via_identifiers, born #history-A.1

    def __init__(self, sin, sout, serr, argv):
        self._arg_stack = list(reversed(argv))
        self._long_program_name = self._arg_stack.pop()
        self._pn = None
        self.stdout, self.stderr = sout, serr
        from os import path as os_path
        self.os_path = os_path

    def execute(self):
        errno = self._parse_args()
        if errno is not None:
            return errno

        # listener = self.build_listener()

        idx_path = self._argument
        del(self._argument)
        # idx_path = self.os_path.abspath(idx_path)

        def _each_fellow():
            with open(idx_path) as fh:
                for iid in identifiers_via_lines_of_index(fh):
                    yield iid

        itr = _each_fellow()

        sout = self.stdout

        def vis(iid):
            s = iid.to_string()
            i = int_via_iid(iid)
            sout.write(f'{s} {i}\n')

        _ = _iid_lib()
        for iid in itr:
            _id_depth = len(iid.native_digits)
            iid_via_int, int_via_iid, cap = _.three_via_depth_(_id_depth)
            vis(iid)
            break

        for iid in itr:
            vis(iid)

        return 0

    def _parse_args(self):
        length = len(self._arg_stack)

        if 0 == length:
            self.stderr.write('missing argument.\n')
            return self.express_usage_and_invite()

        last_tok = self._arg_stack[-1]
        if '-' == last_tok[0]:
            import re
            if re.match('^--?h(?:e(?:lp?)?)?$', last_tok):
                self.stderr.write(f'description: {(_CLI.__doc__)}\n\n')
                self.express_usage()
                return 0

            self.stderr.write(f'unrecognized option: {last_tok}\n')
            return self.express_usage_and_invite()

        if 1 < length:
            self.stderr.write(f'too many args (need 1 had {length}).\n')
            return self.express_usage_and_invite()

        self._argument, = self._arg_stack
        del(self._arg_stack)

    def express_usage_and_invite(self):
        self.express_usage()
        self.stderr.write(f"see '{self.program_name()} -h'\n")
        return 400  # generic "application error"

    def express_usage(self):
        self.stderr.write(f'usage: {self.program_name()} INDEX_PATH\n')

    def program_name(self):
        if self._pn is None:
            s = self._long_program_name
            self._pn = self.os_path.basename(s)
        return self._pn


def identifiers_via_lines_of_index(file_lines):
    return _StateMachineIsh(file_lines).execute()


class _StateMachineIsh():  # #[#008.2] a state machine

    def __init__(self, x):

        self._identifier_via_NDs = _identifier_via_NDs_er()

        _ = _iid_lib().native_digit_via_character_
        self.native_digit_via_character = _

        self.is_at_stopping_point = True
        self.ready = True  # start out wanting to hit the "empty file" whine
        self.release_items = self.when_empty_file

        self.process_line = self.process_first_line
        self.file_lines = x

    def execute(self):

        for line in self.file_lines:
            self.process_line(line)
            if self.ready:
                for x in self.release_items():
                    yield x

        if self.ready:
            for x in self.release_items():
                yield x

        if not self.is_at_stopping_point:
            cover_me('was not at stopping point')

    def process_subsequent_line_at_branch_point(self, line):
        # the state with the most indeterminancy we ever have is here: after
        # we have processed a "rack" line: ..

        md = _rx_for_matching_rack_line.match(line)
        if md is not None:
            self.process_rack_line(md)
        else:
            # only at this point, the file can "reset" to any arbitray
            # indent depth within an allowed range of indent depths
            self.do_reset_indent_depth = True
            self.at_indent_depth = None
            self.process_what_should_be_context_line(line)

    def process_first_line(self, first_line):
        # the first line of an index file is significant because from it we
        # can infer the identifier depth we will use for the rest of the file

        md = _rx_for_matching_significant_line.match(first_line)
        margin, rest = md.groups()
        indent_depth = len(margin)
        if indent_depth is 0:
            self.__enter_shallow_mode_permanantly()
            return self.process_line(rest)
        else:
            self.__process_first_line_when_deep(indent_depth, rest)

    def __process_first_line_when_deep(self, indent_depth, rest):

        # identifier depth is the initial indent depth of the file plus two.

        self.identifier_depth = indent_depth + _two
        self.max_indent_depth = indent_depth

        self.significants = [None for _ in range(0, indent_depth)]

        self.at_indent_depth = indent_depth + 1  # BE CAREFUL
        self.do_reset_indent_depth = False

        self.process_indented_line(indent_depth, rest)

    def process_what_should_be_context_line(self, line):
        # NOTE the copy-pasting

        md = _rx_for_matching_significant_line.match(line)
        margin, rest = md.groups()
        indent_depth = len(margin)
        if not indent_depth:
            cover_me('expected non-rack-line after rack-line to have indent')

        if self.max_indent_depth < indent_depth:
            cover_me('indented line is too far indented, exceeds identifier depth')  # noqa: E501

        self.process_indented_line(indent_depth, rest)

    def process_indented_line(self, indent_depth, rest):

        self.process_line = None  # remind ourselves we have to decide

        if self.do_reset_indent_depth:
            self.do_reset_indent_depth = False
            self.at_indent_depth = indent_depth
        else:
            expected_indent_depth = self.at_indent_depth - 1
            assert(expected_indent_depth)
            if expected_indent_depth != indent_depth:
                cover_me(f'expected level of indent {expected_indent_depth} had {indent_depth}')  # noqa: E501
            self.at_indent_depth = indent_depth

        nd = self.native_digit_via_character(rest, None)  # #no-listener

        _use_offset = self.identifier_depth - indent_depth - _two

        self.significants[_use_offset] = nd

        # for both of the below cases, you're expecting a next line,
        # you cannot yield now. this might be redundant but meh.

        self.ready = False
        self.is_at_stopping_point = False
        self.release_items = None

        if 1 == indent_depth:
            self.process_line = self.process_what_should_be_rack_line
        else:
            # (only for an unlikely depth of four) (Case1470)
            self.process_line = self.process_what_should_be_context_line

    # == BEGIN SHALLOW INVASION

    def __enter_shallow_mode_permanantly(self):
        self.process_line = self._process_line_when_shallow

    def _process_line_when_shallow(self, line):

        md = self._assert_rack_line(line)
        chars_via_rack_match = self._chars_via_rack_match
        nd_via_char = self.native_digit_via_character
        iid_via_NDs = self._identifier_via_NDs

        def release_items():

            # after each line we encounter, we are ready to flush its one or
            # more items. but after doing so, always turn "ready" to False or
            # you will flush the last line 2x

            self.ready = False
            self.release_items = None

            # doing this longform for now for easier debugging

            _char_tup = tuple(chars_via_rack_match(md))

            _nd_tup = tuple(nd_via_char(char, None) for char in _char_tup)
            # #no-listener

            rubric_nd, *tail_nds = _nd_tup

            for nd in tail_nds:
                yield iid_via_NDs(rubric_nd, nd)

        self.ready = True
        self.release_items = release_items
        self.is_at_stopping_point = True

    # == END

    def process_what_should_be_rack_line(self, line):
        self.process_rack_line(self._assert_rack_line(line))

    def _assert_rack_line(self, line):
        md = _rx_for_matching_rack_line.match(line)
        if md is None:
            cover_me('failed to parse rack line')
        return md

    def process_rack_line(self, md):

        # once you've passed the regex point, you can say "yes" this is our i.d
        self.at_indent_depth = 0

        self.rack_line_as_digit_strings = self._chars_via_rack_match(md)
        self.ready = True
        self.release_items = self.release_items_for_real
        self.is_at_stopping_point = True
        self.process_line = self.process_subsequent_line_at_branch_point

    def _chars_via_rack_match(self, md):
        # the match needs a second pass of processing, because we don't
        # attempt to parse the whole line all in one go

        penult_s, rack_s = md.groups()
        return (penult_s, * re.split('[ ]+', rack_s))

    def release_items_for_real(self):

        # even though we don't finish iterating until below, clear state now

        self.ready = False
        self.release_items = None

        """
        we can isomorph every rack line as a series of 2 or more digit
        strings:

            A (B)

        the above isomorphs losslessly (back and forth, for our purposes) to:

            ("A", "B")

        so we'll just model rack lines as a plain old flat iterator of
        strings mapped over the same parsing call, whether it's the more
        significant or one of the least significant "rack" digits.

        that 'penault' digit we need to reuse over every rack digit when
        we build identifiers out of them ..
        """

        s_a = self.rack_line_as_digit_strings
        del self.rack_line_as_digit_strings

        def f(s):
            return self.native_digit_via_character(s, None)  # #no-listener

        itr = (f(s) for s in s_a)

        _penult_nd = next(itr)

        significants = (*self.significants, _penult_nd)

        identifier_via_NDs = self._identifier_via_NDs

        for nd in itr:
            yield identifier_via_NDs(*significants, nd)

    def when_empty_file(self):
        """(Case1466) empty files
        for now we introduce an asymmetry: blow up when an empty file is read
        (although we do not blow up when writing an empty collection - the
        client should check for no lines emitted..)
        """
        raise EmptyFileException_('index file was empty')


def _identifier_via_NDs_er():
    Identifier_ = _iid_lib().Identifier_

    def f(*tup):
        return Identifier_(tup)
    return f


class EmptyFileException_(Exception):
    pass


def _iid_lib():
    from kiss_rdb.magnetics_ import identifier_via_string as _
    return _


def cover_me(msg=None):  # #open [#876] cover me
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


id_rx = '[A-Z0-9]'  # meh
_rx_for_matching_rack_line = re.compile(f'^({id_rx}) \\([ ]*({id_rx}(?:[ ]+{id_rx})*)[ ]*\\)$')  # noqa: E501

_rx_for_matching_significant_line = re.compile(r'^([ ]*)(.*)$')


_two = 2  # the difference between identifier depth and initial indent depth


if __name__ == '__main__':
    from sys import argv, stdout, stderr
    exit(_CLI(None, stdout, stderr, argv).execute())


# #history-A.1: spike development CLI, "shallow invasion"
# #born.
