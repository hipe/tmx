import re


def decide_how_to_express_heading(
        is_head_fragment, frag_heading):

    if is_head_fragment:
        # all head fragments have headings [#883.2], expressed elsewhere
        assert(frag_heading is not None)
        add_header_depth = _normal_header_depth_to_add
        header = None

    elif frag_heading is None:
        # non-head fragment with no heading (Case121)
        add_header_depth = _normal_header_depth_to_add
        header = None

    else:
        # non-head fragment with YES heading (Case115)
        add_header_depth = _normal_header_depth_to_add + 1
        header = _Header(add_header_depth, frag_heading)

    return add_header_depth, header


# == models & associated trivial builder functions

def via_line(line):
    md = _header_rx.match(line)
    begin, end = md.span(1)
    number_of_octothorpes = end - begin
    rest = md[2]
    # --
    return _Header(number_of_octothorpes, rest)


class _Header:

    def __init__(self, depth, text):
        self.depth = depth  # number of octothorpes, typically
        self.text = text  # may or may not have leading space based on etc

    def to_lines(self):
        _1 = '#' * self.depth
        text = self.text
        # (headers from headings don't, the others do probably)
        _2 = '' if ' ' == text[0] else ' '
        yield f'{_1}{_2}{text}'

    symbol_name = 'header'


_Header.new_via = _Header  # wee


_header_rx = re.compile('^(#+)(.+\n)$')
_normal_header_depth_to_add = 1  # #[#883.3]

# #abstracted
