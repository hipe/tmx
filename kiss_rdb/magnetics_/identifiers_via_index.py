"""
one thing with index files is they're never meant to be human-editable
(although we take pains to make them human readable!) so we do _not_
go to lengths to make error messages pretty,
or even to cover such edges cases for now!
"""


import re


def identifiers_via_lines_of_index(file_lines):
    return _StateMachineIsh(file_lines).execute()


class _StateMachineIsh():

    def __init__(self, x):

        from .collection_via_directory import native_digit_via_character_ as _
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
        if not indent_depth:
            cover_me('file must start with indent')

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
            # (only for an unlikely depth of four) (Case739)
            self.process_line = self.process_what_should_be_context_line

    def process_what_should_be_rack_line(self, line):

        md = _rx_for_matching_rack_line.match(line)
        if md is None:
            cover_me('failed to parse rack line')

        self.process_rack_line(md)

    def process_rack_line(self, md):

        # once you've passed the regex point, you can say "yes" this is our i.d
        self.at_indent_depth = 0

        penult_s, rack_s = md.groups()

        self.rack_line_as_digit_strings = (penult_s, * re.split('[ ]+', rack_s))  # noqa: E501

        self.ready = True
        self.release_items = self.release_items_for_real
        self.is_at_stopping_point = True
        self.process_line = self.process_subsequent_line_at_branch_point

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

        identifier_via_ND_tuple = _identifier_via_ND_tuple_er()

        for nd in itr:
            yield identifier_via_ND_tuple(*significants, nd)

    def when_empty_file(self):
        """(Case736) empty files
        for now we introduce an asymmetry: blow up when an empty file is read
        (although we do not blow up when writing an empty collection - the
        client should check for no lines emitted..)
        """
        raise EmptyFileException_('index file was empty')


def _identifier_via_ND_tuple_er():
    from .collection_via_directory import Identifier_

    def f(*tup):
        return Identifier_(tup)
    return f


class EmptyFileException_(Exception):
    pass


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')


id_rx = '[A-Z0-9]'  # meh
_rx_for_matching_rack_line = re.compile(f'^({id_rx}) \\([ ]*({id_rx}(?:[ ]+{id_rx})*)[ ]*\\)$')  # noqa: E501

_rx_for_matching_significant_line = re.compile(r'^([ ]*)(.*)$')


_two = 2  # the difference between identifier depth and initial indent depth

# #born.
