# (this started as overflow from sibling)


from dataclasses import dataclass as _dataclass
import re as _re


def _lazy(orig_f):  # [#510.6]
    def use_f():
        if use_f.do_call:
            use_f.do_call = False
            use_f.x = orig_f()
        return use_f.x
    use_f.do_call = True
    return use_f


# == Newfangled FSA's

@_lazy
def produce_default_git_log_parser_():

    def parse_default_git_log(scn):

        def from_beginning_state():
            yield p.otherwise, always_do_this

        def always_do_this():
            hdr = parse_git_patch_header(scn)
            p.store['whole_big_other_thing'] = hdr
            p.move_to(from_expecting_DIFF)

        def from_expecting_DIFF():
            yield if_match(DIFF_line_rx), go(from_expecting_MMM)

        def from_expecting_MMM():
            yield if_match(MMM_line_rx), go(from_expecting_PPP)

        def from_expecting_PPP():
            yield if_match(PPP_line_rx), finish

        def finish():
            p.scn.advance()  # we processed the PPP line
            p.store_last_matchdata()  # we just matched PPP line
            hdr = p.store.pop('whole_big_other_thing')
            return 'return_this', _Git_Hunk_Run_Header_AST(hdr, **p.store)

        assert scn.more  # ..
        p = _BUILD_PARSER_OMG(scn, from_beginning_state)
        if_match, go = p.if_match, p.go
        return p.PARSE_OMG()

    parse_git_patch_header = produce_git_patch_header_parser()
    c = _re.compile
    DIFF_line_rx = c(r'diff[ ]--git[ ](?P<A_path>[^ ]+)[ ](?P<B_path>\S+)$')
    MMM_line_rx = c(r'---[ ](?P<MMM_path>\S+)$')
    PPP_line_rx = c(r'\+\+\+[ ](?P<PPP_path>\S+)$')

    return parse_default_git_log


@_lazy
def produce_git_patch_header_parser():

    def parse_git_patch_header(scn):

        def from_beginning_state():
            yield if_match(SHA_line_rx), go(from_expecting_author_line)

        def from_expecting_author_line():
            yield if_match(author_line_rx), go(from_expecting_date_line)

        def from_expecting_date_line():
            yield if_match(date_line_rx), go(from_expect_newline_before_msgs)

        def from_expect_newline_before_msgs():
            yield if_newline, go(from_expecting_one_or_more_messages)

        def from_expecting_one_or_more_messages():
            yield if_not_newline, handle_first_of_several_messages

        def handle_first_of_several_messages():
            p.store['message_lines'] = []
            assert_and_append_message_line()
            p.move_to(from_expecting_any_subsequent_messages)

        def from_expecting_any_subsequent_messages():
            yield if_newline, you_found_the_end_of_the_messages
            yield otherwise, assert_and_append_message_line

        def if_not_newline():
            return not if_newline()

        def if_newline():
            return '\n' == p.line

        def you_found_the_end_of_the_messages():
            # NOTE we aren't storying the final '\n' anywhere
            p.scn.advance()
            return 'return_this', _GitPatchHeader(**store)

        def assert_and_append_message_line():
            assert message_line_rx.match(p.line)
            store['message_lines'].append(p.scn.next())

        assert scn.more  # ..
        p = _BUILD_PARSER_OMG(scn, from_beginning_state)
        if_match, go, store, otherwise = p.if_match, p.go, p.store, p.otherwise
        return p.PARSE_OMG()

    c = _re.compile
    SHA_line_rx = c(r'commit (?P<SHA>[0-9a-z]{8,})$')
    author_line_rx = c(r'Author:[ ](?P<author>.+)$')
    date_line_rx = c(r'Date:[ ]+(?P<datetime_string>[^ ].+)$')
    message_line_rx = c(r'^[ ]{4}')

    return parse_git_patch_header


# == Model-esque

@_dataclass
class _Git_Hunk_Run_Header_AST:
    git_patch_header: object
    A_path: str
    B_path: str
    MMM_path: str
    PPP_path: str

    def to_summary_lines(self, margin=''):
        yield f"{margin}Git hunk run header AST:\n"
        for line in self.git_patch_header._to_body_summary_lines_(margin):
            yield line

    @property
    def SHA(self):
        return self._delegated('SHA')

    @property
    def author(self):
        return self._delegated('author')

    @property
    def datetime_string(self):
        return self._delegated('datetime_string')

    @property
    def message_lines(self):
        return self._delegated('message_lines')

    def _delegated(self, attr):
        return getattr(self.git_patch_header, attr)


@_dataclass
class _GitPatchHeader:
    SHA: str
    author: str
    datetime_string: str
    message_lines: tuple  # (or list)

    def to_summary_lines(self, margin=''):
        yield f"{margin}Git patch header AST:\n"
        for line in self._to_body_summary_lines_(margin):
            yield line

    def _to_body_summary_lines_(self, margin=''):
        def these():
            for line in self.message_lines:
                line = rx.match(line)[1]
                if '\n' == line:
                    continue
                yield line
        rx = _re.compile(r'[ ]*(.+)', _re.DOTALL)
        itr = these()
        line1 = next(itr)
        line2 = None
        for line2 in itr:
            break
        yield f"{margin}  Commit: {self.SHA}\n"
        yield f"{margin}  Datetime: {self.datetime_string}\n"
        if True:
            yield f"{margin}  Excerpt: {line1}"
        if line2:
            yield f"{margin}           {line2}"


# == Experimental new parser generator

class _BUILD_PARSER_OMG:  # an experimental ABSTRACTION of #[#008.2]

    def __init__(self, scn, beginning_state):
        self.scn = scn
        self.stack = [beginning_state]

        from . import StrictDict_ as cls
        self.store = cls()

    def PARSE_OMG(self):
        while self.scn.more:
            action = self.find_transition()
            direc = action()
            if direc is None:
                continue
            typ = direc[0]
            assert 'return_this' == typ
            ret, = direc[1:]
            # (leave the line scanner wherever it is)
            return ret
        from_here = self.from_where()
        xx(f'premature end of input? {from_here}')

    def find_transition(self):
        for test, action in self.stack[-1]():
            yn = test()
            if yn:
                return action
        from_here = self.from_here()
        xx(f"No transition found {from_here} for line: {self.line!r}")

    def if_match(self, rx):
        def test():
            md = rx.match(self.line)
            if md is None:
                return
            self.store['last_matchdata'] = md
            return True
        return test

    def otherwise(_):  # courtesy
        return True

    @property
    def line(self):
        return self.scn.peek

    def go(self, state_function):
        def action():
            if 'last_matchdata' in self.store:
                self.store_last_matchdata()
            self.scn.advance()
            self.move_to(state_function)
        return action

    def move_to(self, state_function):
        self.stack[-1] = state_function

    def store_last_matchdata(self):
        md = self.store.pop('last_matchdata')
        for k, v in md.groupdict().items():
            self.store[k] = v

    def from_here(self):
        return self.stack[-1].__name__.replace('_', ' ')


_ugh = 12


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #refactored
