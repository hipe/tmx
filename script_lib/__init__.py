import re


def RESOLVE_UPSTREAM_EXPERIMENT(cli):
    """
    so:
      - this is [#608.3] an early abstraction
      - this is the first thing to use [#608.6] our new simplified API
    """

    def __main():
        if cli.stdin.isatty():
            __resolve_upstream_when_interactive()
        else:
            __resolve_upstream_when_non_interactive()

    def __resolve_upstream_when_interactive():
        if _an_argument_was_passed():
            if _help_was_requested():
                _express_help()
            elif __more_than_one_argument_was_passed():
                __THEN_complain_about_too_many_arguments()
            else:
                __THEN_use_that_one_arguent()
        else:
            __THEN_complain_about_no_arguments()

    def __resolve_upstream_when_non_interactive():
        if _an_argument_was_passed():
            if _help_was_requested():
                _express_help()
            else:
                __THEN_complain_about_cant_have_both()
        else:
            __THEN_use_stdin_as_upstream()

    def _an_argument_was_passed():
        return 1 < _number_of_arguments()

    def __more_than_one_argument_was_passed():
        return 2 < _number_of_arguments()

    def _help_was_requested():
        import re
        rx = re.compile('^--?h(?:e(?:lp?)?)?$')  # #[#608.4] DRY one day
        a = cli.ARGV
        return next((i for i in range(1, len(a)) if rx.match(a[i])), None)

    def _express_help():

        _ = ' '.join(cli.description_raw_lines_for_resolve_upstream())  # ..

        o = _liner_for(cli.stderr)
        program_name = _program_name()
        o(f'usage: {program_name} {_lone_argument_moniker()}')
        o(f'       some-stream | {program_name}')
        o()
        o(f'description: {_}')

        cli.OK = False

    def __THEN_complain_about_cant_have_both():
        _arg_error("can't have both STDIN and arguments")

    def __THEN_complain_about_no_arguments():
        _complain(f'expecting {_lone_argument_moniker()} or STDIN')

    def __THEN_complain_about_too_many_arguments():
        _arg_error(f'had {_number_of_arguments()} arguments, '
                   'needed one.')

    def _arg_error(msg):
        _complain(f'argument error: {msg}')

    def _complain(msg):
        o = _liner_for(cli.stderr)
        o(msg)
        o(f"see '{_program_name()} -h' for help.")
        cli.OK = False
        cli.exitstatus = 444

    def _program_name():
        return cli.ARGV[0]

    def _liner_for(io):
        def o(s=None):
            write('\n' if s is None else f'{s}\n')
        write = io.write
        return o

    def _number_of_arguments():
        return len(cli.ARGV)  # ..

    def __THEN_use_stdin_as_upstream():
        cli.upstream = cli.stdin

    def __THEN_use_that_one_arguent():
        cli.upstream = open(cli.ARGV[1])

    # --

    def _lone_argument_moniker():
        return cli.lone_argument_moniker_for_resolve_upstream()

    return __main()

    # == END


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


# #history-A.3: "cheap arg parse" moves to dedicated file
# #history-A.1: as referenced
# #born: abstracted
