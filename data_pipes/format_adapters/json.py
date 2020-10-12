STORAGE_ADAPTER_CAN_LOAD_DIRECTORIES = False
STORAGE_ADAPTER_CAN_LOAD_SCHEMALESS_SINGLE_FILES = True
STORAGE_ADAPTER_ASSOCIATED_FILENAME_EXTENSIONS = ('.json',)
STORAGE_ADAPTER_IS_AVAILABLE = True


def LINES_VIA_SCHEMA_AND_ENTITIES(schema, given_ents, listener):

    def json_lines_via_entity(ent):
        # NOTE skipping the idea of identifiers for now

        dct = ent.core_attributes_dictionary_as_storage_adapter_entity
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


def _scnlib():
    import text_lib.magnetics.scanner_via as module
    return module


def xx(msg=None):
    raise RuntimeError(msg or "wee")

# #history-B.1 initial spike
# #born as nonworking stub
