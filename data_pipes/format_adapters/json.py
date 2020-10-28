from collections import namedtuple as _nt


STORAGE_ADAPTER_CAN_LOAD_DIRECTORIES = False
STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES = True
STORAGE_ADAPTER_ASSOCIATED_FILENAME_EXTENSIONS = ('.json',)
STORAGE_ADAPTER_IS_AVAILABLE = True


def FUNCTIONSER_FOR_SINGLE_FILES():

    class edit_funcs:  # #class-as-namespace
        lines_via_schema_and_entities = _lines_via_schema_and_entities

    class read_funcs:  # #class-as-namespace
        schema_and_entities_via_lines = _schema_and_entities_via_lines

    class fxr:  # #class-as-namespace
        def PRODUCE_EDIT_FUNCTIONS_FOR_SINGLE_FILE():
            return edit_funcs

        def PRODUCE_READ_ONLY_FUNCTIONS_FOR_SINGLE_FILE():
            return read_funcs

        def PRODUCE_IDENTIFIER_FUNCTIONER():
            return _build_identifier_builder
    return fxr


def _schema_and_entities_via_lines(lines, listener):  # #testpoint:KS
    scn = _scnlib().scanner_via_iterator(lines)
    if scn.empty:
        xx("cover me: line stream was empty (no lines)")

    if '[]\n' == scn.peek:
        xx("cover me: line stream expressed an empty JSON list")

    dcts = _one_or_more_dictionaries_via_JSON_line_stream(scn, listener)
    if dcts is None:
        return

    first_dct = next(dcts)

    def rewound():  # #[#612.3] rewinding an interator
        yield first_dct
        for dct in dcts:
            yield dct

    schema = _MinimalSchema(tuple(first_dct.keys()))  # ..
    return schema, (_JustEnoughEntity(dct) for dct in rewound())


def _one_or_more_dictionaries_via_JSON_line_stream(scn, LISTENER):
    def main():
        expect_first_line_has_opening_square_bracket_and_stash_the_line_tail()

        while True:  # Each entity
            for_now_expect_at_least_one_attribute_line_noting_the_comma()

            while True:  # Each attribute
                if the_above_line_had_a_comma():
                    expect_another_attribute_line_noting_the_comma()
                    continue
                break

            expect_closing_curly_and_either_comma_or_closing_square_bracket()
            yield release_the_dictionary()
            if the_above_line_had_a_comma():
                continue
            break
        if scn.empty:
            return
        xx("had extra lines after closing square bracket")

    def release_the_dictionary():
        one_json_object = ''.join(attribute_lines_cache)
        attribute_lines_cache.clear()
        return json_loads(one_json_object)  # ..

    def expect_closing_curly_and_either_comma_or_closing_square_bracket():
        line = scn.peek
        if '},\n' == line:
            scn.advance()
            attribute_lines_cache.append('}\n')  # LOOK
            self.had_comma = True
            return
        if '}]\n' == line:
            scn.advance()
            attribute_lines_cache.append('}\n')  # LOOK
            self.had_comma = False
            return
        raise expecting(("closing curly bracket and either a comma"
                         " or a closing square bracket"), '"}," or "}]"')

    def the_above_line_had_a_comma():
        return self.had_comma

    def for_now_expect_at_least_one_attribute_line_noting_the_comma():
        if '{\n' != scn.peek:
            raise expecting('open curly bracket', '{')
        attribute_lines_cache.append(scn.next())
        if scn.empty:
            raise expecting("attribute line")
        expect_another_attribute_line_noting_the_comma()

    def expect_another_attribute_line_noting_the_comma():  # assume line
        md = re.match(r'[ ]{2}"[^"]+":[ ].*(?:[^,\n]|(?P<comma>,))$', scn.peek)
        if not md:
            raise expecting("indented attribute line")  # could be nicer
        self.had_comma = -1 != md.span('comma')[0]
        attribute_lines_cache.append(scn.next())

    def expect_first_line_has_opening_square_bracket_and_stash_the_line_tail():
        line = scn.peek
        beg, end = re.match('(?P<first_char>.)?', line).span('first_char')
        if -1 != beg:
            first_char, rest = line[beg:end], line[end:]
            if '[' == first_char:
                scn.peek = rest  # BIG HACK
                return
        raise expecting('open square bracket', '[')

    def expecting(descr_np, char=None, pos=None):
        xx("write the cool thing with the arrows. note we never use pos")

    attribute_lines_cache = []

    class self:  # #class-as-namespace
        pass

    class stop(RuntimeError):
        pass

    from json import loads as json_loads
    import re

    try:
        for dct in main():
            yield dct
    except stop:
        pass


def _lines_via_schema_and_entities(schema, given_ents, listener):
    # #testpoint:KS

    def json_lines_via_entity(ent):
        # NOTE skipping the idea of identifiers for now

        dct = ent.core_attributes_dictionary
        big_s = json_dumps(dct, indent=2)

        # Split on newlines but keep the newlines #[#610]
        return re.split(r'(?<=\n)(?=.)', big_s)

    # "run" = a run of lines, just a mutable list of EOL-terminated lines
    runs = (json_lines_via_entity(ent) for ent in given_ents)

    from json import dumps as json_dumps
    import re

    scn = _scnlib().scanner_via_iterator(runs)

    if scn.empty:
        yield '[]\n'
        return

    # First item only: smunge the '[' into there
    run = scn.next()
    run[0] = ''.join(('[', run[0]))

    # Always pop that last line off there because we don't know if it
    # needs a comma at the end until we know if we have another one
    last_line_of_previous = run.pop()

    for line in run:
        yield line

    while scn.more:
        line = ''.join((last_line_of_previous, ',\n'))
        yield line
        run = scn.next()
        last_line_of_previous = run.pop()
        for line in run:
            yield line

    # Last item only: smunge that ']' on to there
    line = ''.join((last_line_of_previous, ']\n'))
    yield line


def _build_identifier_builder(_listener, _cstacker=None):
    def iden_via_primitive(x):  # #[#877.4] this might become default
        assert isinstance(x, str)
        assert len(x)
        return x
    return iden_via_primitive


_JustEnoughEntity = _nt('JustEnoughEntity', ('core_attributes_dictionary',))
_MinimalSchema = _nt('MinimalSchema', ('field_name_keys',))


def _scnlib():
    import text_lib.magnetics.scanner_via as module
    return module


def xx(msg=None):
    raise RuntimeError(msg or "wee")

# #history-B.1 initial spike
# #born as nonworking stub
