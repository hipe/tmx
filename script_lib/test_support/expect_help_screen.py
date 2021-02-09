"""Parse a help screen for the purpose of testing

(:[#601.4])
"""

import re as _regex


def parse_help_screen(lines):
    lines = _dont_trust_lines(lines)
    func = _treelib().sections_via_lines_allow_align_right__
    sections = func(lines)
    sect_via_lines = _build_section_parser()
    sections = tuple(sect_via_lines(lines) for lines in sections)
    return _help_screen(sections)


def _help_screen(sects):
    offset_via_key = {sects[i].section_key: i for i in range(0, len(sects))}

    class help_screen:
        def to_option_index(_):
            return _option_index_via_sections(offset_via_key, sects)

        def to_positional_index(_):
            return _positional_index_via_sections(offset_via_key, sects)

        def __getitem__(_, k):  # an alias. meh
            return sects[offset_via_key[k]]

        def section_via_key(_, k):
            return sects[offset_via_key[k]]
    return help_screen()


def _option_index_via_sections(offset_via_key, sections):
    offset = _find_section_offset(offset_via_key, _option_headers)
    return _build_option_index(sections[offset])


def _positional_index_via_sections(offset_via_key, sections):
    offset = _find_section_offset(offset_via_key, _positional_headers)
    return _build_positional_index(sections[offset])


_option_headers = (
    'options', 'option', 'optional arguments', 'optional argument')


_positional_headers = (
   'arguments', 'sub-commands', 'argument', 'sub-command',
   'positional arguments', 'positional argument')


def _find_section_offset(offset_via_key, keys):
    key = next(k for k in keys if k in offset_via_key)
    return offset_via_key[key]


def _build_option_index(section):
    lines = section.to_body_lines()
    return {k: v for k, v in _do_build_option_index(lines)}


def _do_build_option_index(lines):
    from text_lib.magnetics.scanner_via import scanner_via_iterator as func
    scn = func(lines)
    while True:
        o = _parse_option_line(scn.next())
        additional_desc_lines = []
        while scn.more and _regex.match(r'^[ ]+[^- ]', scn.peek):
            additional_desc_lines.append(scn.next())
        o.additional_desc_lines_NOT_USED = tuple(additional_desc_lines)  # meh
        yield o.main_long_switch, o
        if scn.empty:
            break


def _parse_option_line(line):
    """EXPERIMENT...

    ... if this proves at all useful it should certainly be abstracted.
    """

    def main():
        yield 'main_short_switch', parse_any_short()
        yield 'main_long_switch', parse_long()
        yield 'args_tail_of_long', parse_any_args()
        yield 'desc_lines', (desc_first_line,)

    class my_state:  # #class-as-namespace
        cursor = 0

    self = my_state

    def parse_any_args():
        if self.cursor is not len(haystack_s):
            return assert_scan('[ =]([^ ].+)$')  # soften if necessary

    def parse_long():
        return assert_scan('--[a-z]+(?:-[a-z]+)*')  # ..

    def parse_any_short():
        s = scan('-[a-z]')
        if s is not None:
            assert_skip(',?[ ]+')
            return s
    # --

    def assertify(f):
        """(decorator...)"""

        def g(rx_s):
            x = f(rx_s)
            if x is None:
                msg = build_assertion_failure_message(f, rx_s)
                raise RuntimeError(msg)
            return x
        return g

    @assertify
    def assert_scan(rx_s):
        return scan(rx_s)

    @assertify
    def assert_skip(rx_s):
        return skip(rx_s)

    def scan(rx_s):
        md = match(rx_s)
        if md is None:
            return
        advance_cursor_to(md.end())
        s_a = md.groups()
        leng = len(s_a)
        if leng == 0:
            return md[0]
        assert(leng == 1)
        # if you use groups in your scan regex,
        # you can only have one group'
        return s_a[0]

    def skip(rx_s):
        md = match(rx_s)
        if md is None:
            return
        cursor_ = md.end()
        width = cursor_ - self.cursor
        advance_cursor_to(cursor_)
        return width

    def match(rx_s):
        rx = re.compile(rx_s)
        return rx.match(haystack_s, self.cursor)

    def build_assertion_failure_message(f, rx_s):
        fmt = 'failed to {verb} /{rx_s}/: {excerpt}'
        fname = f.__name__
        md = re.search('_([a-z]+)$', fname)
        if md is None:
            verb = fname
        else:
            verb = md[1]
        if self.cursor >= len(haystack_s):
            excerpt = '[empty string]'
        else:
            excerpt = '«%s»' % haystack_s[self.cursor:]
        return fmt.format(verb=verb, rx_s=rx_s, excerpt=excerpt)

    def advance_cursor_to(num):
        self.cursor = num

    # md = re.search('^((?:[^ ]|[ ](?![ ]))+)(?:[ ]{2,}(.+))?$', line)
    # haystack, desc_first_line = md.groups()
    here = line.rindex('  ')
    haystack_s = line[0:here].strip()
    desc_first_line = line[here+2:-1]

    re = _regex
    kwargs = {k: v for k, v in main()}
    return _OptionLine(**kwargs)


class _OptionLine:
    # used to be collections.namedtuple before #history-B.2
    def __init__(
            o, main_short_switch, main_long_switch,
            args_tail_of_long, desc_lines):
        o.main_short_switch = main_short_switch
        o.main_long_switch = main_long_switch
        o.args_tail_of_long = args_tail_of_long
        o.desc_lines = desc_lines


def _build_positional_index(section):
    def split_via_line(line):
        # md = re.search('^([^ ]+)[ ]{2,}', line)  # before #history-B.2
        here = line.rindex('  ')
        return line[:here].strip(), line
    lines = section.to_body_lines()
    return {k: v for k, v in (split_via_line(line) for line in lines)}


def _build_section_parser():
    def sect_via_lines(lines):
        key = section_key_via_header_line(lines[0])
        num_lines = len(lines)

        class section:
            def to_body_lines(_):
                for i in rang:
                    yield lines[i]
            body_line_count = num_lines - 1
            head_line = lines[0]
            section_key = key
        rang = range(1, num_lines)
        section.lines = lines
        return section()
    section_key_via_header_line = _build_section_key_parser()
    return sect_via_lines


def _build_section_key_parser():
    def parse(line):
        md = rx.match(line)
        head = md['this_fellow']
        return f"{head}s" if md['plural_thing'] else head
    re = _regex
    rx = re.compile(r'''
      (?P<this_fellow>
        (?:[a-z]+[ ])*             # zero or more (word then space)
        [a-z]+                     # one word
      )
      (?P<plural_thing> \(s\)  )?  # MAYBE "(s)"
      :                            # every header line has to have one of these
                                   # (not anchored to end because oneliners)
    ''', re.IGNORECASE | re.VERBOSE)
    return parse


def _dont_trust_lines(lines):

    # in the past we used a vendor library (click) to generate help
    # screens. it (not us) flattened our multi-lines messages and also word-
    # wrapped them (?), such that our helps screens were in ONE BIG STRING.
    # now that this testlib is used against our own generated help screens,
    # we no longer have to turn ONE BIG STRING into a line stream.

    line_rx = _regex.compile(r'^.*\n\Z')
    for line in lines:
        if line_rx.match(line):
            yield line
            continue
        raise RuntimeError("ohai this is not a well-formed line (see here)")
        # #history-B.2
        # from script_lib import lines_via_big_string


def xx(msg=''):
    raise RuntimeError(f"write me: {msg}")


def _treelib():
    from . import expect_treelike_screen as module
    return module


# #history-B.2 full rewrite to simplify
# #born.
