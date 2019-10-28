import re


def OPEN_UPSTREAM(stderr, arg_moniker, arg_value, stdin):
    # At #history-A.4 this shurnk to tiny,  re-written for API change.
    # At this same time, we sunsetted a whole redundant module (file).
    # Using stderr instead of listener is an experimental simplification..
    # Result value is experimental.

    typ = RESOLVE_UPSTREAM(stderr, arg_moniker, arg_value, stdin)
    if typ is None:
        return

    if 'stdin_as_argument' == typ:
        from data_pipes import ThePassThruContextManager
        return ThePassThruContextManager(stdin)

    assert('path_as_argument' == typ)
    return open(arg_value)


def RESOLVE_UPSTREAM(stderr, arg_moniker, arg_value, stdin):
    # (see note at above function)

    def main():
        if stdin.isatty():
            if '-' == arg_value:
                return when_neither()
            return 'path_as_argument'
        if '-' == arg_value:
            return 'stdin_as_argument'
        return when_both()

    def when_both():
        whine(f'when piping from STDIN, {arg_moniker} must be "-"')

    def when_neither():
        whine(f'when {arg_moniker} is "-", STDIN must be pipe')

    def whine(msg):
        stderr.write(f'parameter error: {msg}\n')  # [#607.I] _eol

    return main()


# -- abstracted at #history-A.1 - scream case because kludge, reach-down

def CACHED_DOCUMENT_VIA_TWO(cached_path, url, noun_phrase, listener):
    # ugly to reach down but that hard coded doo-hah is here & convenient
    if cached_path is None:
        return _cached_doc_via_url(url, listener)
    else:
        return _cached_doc_via_filesystem(cached_path, noun_phrase, listener)


def _cached_doc_via_filesystem(cached_path, noun_phrase, listener):
    from data_pipes.format_adapters.html.magnetics import (
            cached_doc_via_url_via_temporary_directory as cachelib)

    def lineser():
        yield f'(reading {noun_phrase} from filesystem - {cached_path})'
    listener('info', 'expression', 'reading_from_filesystem', lineser)
    return cachelib.Cached_HTTP_Document(cached_path)


def _cached_doc_via_url(url, listener):
    from data_pipes.format_adapters.html.magnetics import (
            cached_doc_via_url_via_temporary_directory as cachelib)
    return cachelib(TEMPORARY_DIR)(url, listener)
# --


def deindent_doc_string_(big_string, do_append_newlines):
    # convert a PEP-257-like string into an iterator of lines

    if _eol not in big_string:
        if do_append_newlines:
            yield f'{big_string}{_eol}'
        else:
            yield big_string
        return

    if do_append_newlines:
        iter_rxs = '^.*\n'
        # two_tabs_rxs = '^[ ]{8}(.*\n)'
    else:
        iter_rxs = '^.*(?=\n)'
        # two_tabs_rxs = '^[ ]{8}(.*)\n'

    # two_tabs_rx = re.compile(two_tabs_rxs)
    indented_line_md = None
    for line_md in re.compile(iter_rxs, re.MULTILINE).finditer(big_string):
        line = line_md[0]
        # indented_line_md = two_tabs_rx.match(line)
        if True or indented_line_md is None:
            yield line
        else:
            yield indented_line_md[0]


class filesystem_functions:  # as namespace
    """with this you "inject" the "filesystem" *as* a dependency into your

    application. the sub-components of your application don't interact with
    the filesystem directly, but rather all of their interactions with it
    happen through the "filesystem" conduit they were passed (this façade).

    for small scripts, using this would probably be obfuscating overkill. but
    for applications of any significant complexity, this has these objectives:

      - use of this tacitly encourages the filesystem to be conceived of and
        modeled around as just another datastore, rather than as a ubiquitous
        service to be taken for granted. this can encourage modularity and
        flexibility in your components, in case (for example) you were to
        rearchitect to target a different datastore other than the local
        filesystem.

      - more specifically, [something about heroku]

      - for some use cases it can be most practical to mock a filesystem
        rather than use a mock filesystem tree. [citation needed]
    """

    open = open  # simply, *our* open is the *real* open

    def open(*x):
        cover_me('not used')  # [#676] cover me


def cover_me(s):
    raise _exe('cover me: {}'.format(s))


_exe = Exception


class Exception(Exception):
    pass


# -- CONSTANTS

GENERIC_ERROR = 2
SUCCESS = 0
TEMPORARY_DIR = 'z'  # ick/meh


_eol = '\n'


# #history-A.4
# #history-A.3: "cheap arg parse" moves to dedicated file
# #history-A.1: as referenced
# #born: abstracted
