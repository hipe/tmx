"""
(note on history:) At #rebirth we started this file (module) anew. There had
been a same-purposed one before it but it was absorbed by cheap_arg_parse
("legacy") during a full rewrite in 2020. Now the target output of this
module will be spiritually matched to the styling of that in  cheap_arg_parse,
but the names and interface will be different to accord with the New Way
(the "engine").

We might (in turn) one day refactor the legacy module to use this instead
of its in-file one. This is all to say that a continuous line of in-file
history will be in this way broken _twice_, but at this point it is
counter-productive to care.
"""


import re


def help_lines_via_components_EXPERIMENTAL_(
        raw_usage_lines, program_name, docstring_for_help_description):

    # Usage lines
    f = build_fake_template_thing_(program_name)
    itr = iter(f(s) for s in raw_usage_lines)
    first_line = next(itr)
    yield first_line
    second_line = next(itr, None)
    if second_line:
        g = _build_header_replacer_thing(first_line)
        yield g(second_line)
        for line in itr:
            yield g(line)

    # Description lines
    if callable(docstring_for_help_description):
        lines = docstring_for_help_description()
        # (we don't run it through the normalizer function. client can)
    else:
        lines = description_lines_via_mixed_(docstring_for_help_description)

    for line in lines:
        yield line


def description_lines_via_mixed_(docstring_for_help_description):

    if not docstring_for_help_description:
        return

    if isinstance(docstring_for_help_description, str):
        itr = _one_or_more_lines_via_docstring(docstring_for_help_description)
    else:
        assert hasattr(docstring_for_help_description, '__next__')
        itr = docstring_for_help_description

    yield '\n'
    first_line = next(itr)

    if not re.compile('^description:', re.IGNORECASE).match(first_line):
        first_line = f"description: {first_line}"

    yield first_line

    for line in itr:
        yield line


def _build_header_replacer_thing(usage_line_1):
    def replace(usage_line_2):
        return rx.sub(replacement, usage_line_2)
    md = re.match('^[a-zA-Z ]+:', usage_line_1)
    rx = re.compile(''.join(('^', re.escape(md[0]))))
    replacement = ' ' * md.end()
    return replace


def build_fake_template_thing_(program_name):
    def apply(raw_usage_line):
        md = re.search('(?P<outer>{{(?P<snake>(?:(?!=>}}).)*)}})', raw_usage_line)
        if not md or 'prog_name' != md['snake']:
            xx("expecting to find {{prog_name}} in line: {raw_usage_line!r}")
        begin, end = md.span('outer')
        return ''.join((raw_usage_line[0:begin], program_name, raw_usage_line[end:]))
    return apply


def _one_or_more_lines_via_docstring(big_string):  # #testpoint

    # States

    def from_beginning_state():
        yield if_big_string_has_no_newlines, add_newline_to_big_string_and_done
        yield if_content_line, passthru, from_expect_maybe_PEP_0257
        yield if_blank_line, ignore, from_expect_weird_determiner

    def from_expect_weird_determiner():
        yield if_content_line, handle_determiner, from_wierd_state

    def from_expect_determiner_line():
        yield if_content_line, handle_determiner, from_main_state

    def from_wierd_state():
        yield if_blank_line, ignore, from_main_state
        yield if_content_line, deindent, from_main_state

    def from_expect_maybe_PEP_0257():
        yield if_blank_line, ignore, from_expect_determiner_line
        yield if_content_line, handle_determiner, from_main_state

    def from_main_state():
        yield if_content_line, deindent
        yield if_blank_line, passthru
        yield if_extra_blank_at_end, ignore_extra_blank_at_end

    # Actions

    def deindent():
        md = release_line_classification()[1]
        over_by = len(md['margin'] or '') - len(state.expected_margin)
        if 0 == over_by:
            return md['content_line']
        if 0 < over_by:
            return (' ' * over_by) + md['content_line']
        xx(f"shallower indentation? {md['line']!r}")

    def handle_determiner():
        md = release_line_classification()[1]
        state.expected_margin = md['margin'] or ''
        return md['content_line']

    def passthru():
        return release_line_classification()[1]['line']

    def ignore():
        release_line_classification()

    def ignore_extra_blank_at_end():
        tail = big_string[state.cursor:]
        if not re.match('^[ \t]+$', tail):
            xx(f"strange: {tail!r}")
        state.cursor = big_string_length
        state.state_function = None

    def release_line_classification():
        tup = state.line_classification
        state.line_classification = None
        if 'content_line' == tup[0]:
            state.cursor = tup[1].end()
        else:
            assert 'blank_line' == tup[0]
            state.cursor += 1
        return tup

    def add_newline_to_big_string_and_done():
        state.cursor = big_string_length
        return f"{big_string}\n"

    # Conditions

    def if_content_line():
        return 'content_line' == touch_line_classification()[0]

    def if_blank_line():
        return 'blank_line' == touch_line_classification()[0]

    def if_extra_blank_at_end():
        return 'incomplete_line' == touch_line_classification()[0]

    def if_big_string_has_no_newlines():
        return '\n' not in big_string

    def touch_line_classification():
        tup = state.line_classification
        if tup:
            return tup
        md = rx_main.match(big_string, state.cursor)
        if md:
            if '\n' == md['line']:
                tup = 'blank_line', md
            else:
                tup = 'content_line', md
        else:
            tup = ('incomplete_line',)
        state.line_classification = tup
        return tup

    rx_main = re.compile(
            r'(?P<line>(?P<margin>[ \t]+)?(?P<content_line>([^ \t\n].*)?\n))')

    # ==

    def do_next_action():
        action, ting = find_matching_transition()
        prev_state = state.state_function
        state.state_function = None  # actions shouldn't rely on states lol
        res = action()
        if ting:
            state.state_function = ting
        else:
            state.state_function = prev_state
        return res

    def find_matching_transition():
        for two_or_three in state.state_function():
            stack = list(reversed(two_or_three))
            yn = stack.pop()()
            if not yn:
                continue
            action = stack.pop()
            if len(stack):
                ting, = stack
            else:
                ting = None
            return action, ting
        xx(f"no transition found {state.state_function.__name__}")

    state = from_beginning_state  # #watch-the-world-burn
    state.state_function = from_beginning_state
    state.cursor = 0
    state.line_classification = None

    big_string_length = len(big_string)
    while big_string_length != state.cursor:
        output_line = do_next_action()
        if output_line:
            yield output_line


def xx(msg=None):
    raise RuntimeError(''.join(('to do', *((': ', msg) if msg else ()))))

# #rebirth
