"""DISCUSSION we know we want these different adapters in different files
(modules), but we have ZERO idea what the interface should be. If we do ever
end up with multiple adapters for the different watch utilities, we find it
very likely that we see the .. architecture of this API change (in terms of
where the boundaries are and what the interactions are shaped like).

For now the API boundary is built on the kinds of interactions we want for
our one watcher (one where the client (not us) exec's out to a subprocess
though use of an ARGV and other hard-coded decisions), but it's unlikely
that the interaction would have these same properties for other watchers
(especially on other OS'es yikes)
"""


"""NOTE nowhere in the mono-repo is it reflected that we have installed
`watchexec`: it's not in requirements.txt nor did we make an installer task.

The installation on OS X was entirely straightforward as pointed to
by [#409.3]. After writing this, we made the version check thing that points
to this docuemntation on failure.
"""


_EXECUTABLE_NAME = 'watchexec'

_EXPECTED_VERSION = '1.14.1'
# (We're probably being too strict with this. But we'll start with wanting a
# noisy failure at first, then we'll deal with making this check less strict &
# /or taking the check out entierely. It just happend to be 1.14.1 at #birth)


def CHECK_VERSION(listener):
    def main():
        cp = _OK_completed_process_for_version_check(listener)
        ver = _version_via_completed_process(cp)
        return _do_check_version(listener, ver)
    try:
        return main()
    except _stop:
        pass


def ARGV_VIA_DIRECTORY(dir_path):
    rows = _argv_tokens(dir_path)
    return tuple(s for row in rows for s in ((row,)
                 if isinstance(row, str) else row))


def _argv_tokens(dir_path):
    yield _EXECUTABLE_NAME

    # 👉 The remainder of this method is *every* "FLAG" and "OPTION"
    #    found in `watchexec --help`
    # 👉 ([cleaned up one thing manually] | cut -c9- | sort)
    # 👉 The first comment line of every component section is exactly as-is
    #    from the help screen (plus the occasional "noqa: E501" as necessary)
    #
    # Hypothetically this could be used in the future (with a deterministic
    # amount of pain) to make a feature-diff against future versions of the
    # vendor command (wow). Also as more minor notes:
    #
    # 👉 The man page (as opposed to the help screen) has longer descriptions
    #    for most (or all?) of these parametric components
    # 👉 We visualy confirmed (once) that the set of parametric components
    #    is identical between man page and help screen, but we have no good
    #    reason to assume that will hold into the future; and yes we could
    #    go psychomode and parse the help screen too. (nb tmx about 15 yrs ago)

    # Clear screen before executing command
    # yield '--clear'

    # Set the timeout between detected change and command execution, defaults to 500ms  # noqa: E501
    yield '--debounce', '15'

    # Comma-separated list of file extensions to watch (js,css,html)
    # yield '--ext/-s <extensions>'

    # Ignore all modifications except those matching the pattern
    yield '--filter', '*.md'  # ..

    # Force polling mode (interval in milliseconds)
    # yield '--force-poll <interval>'

    # Prints help information
    # yield '--help'

    # Ignore modifications to paths matching the pattern
    # yield '--ignore <pattern>...'

    # Send SIGKILL to child processes (deprecated, use -s SIGKILL instead)
    # yield '--kill'

    # Skip auto-ignoring of commonly ignored globs
    # yield '--no-default-ignore'

    # Do not set WATCHEXEC_*_PATH environment variables for child process
    # yield '--no-environment'

    # Skip auto-loading of ignore files (.gitignore, .ignore, etc.) for filtering  # noqa: E501
    # yield '--no-ignore'

    # Ignore metadata changes
    # yield '--no-meta'

    # Do not wrap command in 'sh -c' resp. 'cmd.exe /C'
    yield '--no-shell'

    # Skip auto-loading of .gitignore files for filtering
    # yield '--no-vcs-ignore'

    # Wait until first change to execute command
    # yield '--postpone'
    # (not postponing is good for checking connection BUT..)

    # Restart the process if it's still running
    # yield '--restart'

    # Send signal to process upon changes, e.g. SIGHUP
    # yield '--signal <signal>'

    # Print debugging messages to stderr
    yield '--verbose'
    # (this is indeed verbose)

    # Prints version information
    # yield '--version'

    # Watch a specific file or directory
    yield '--watch', dir_path

    # Ignore events while the process is still running
    # yield '--watch-when-idle'

    yield '--', 'pho', 'wow-holy-smokes', dir_path


# == Decorators

def _stop_if_none(orig_f):
    def use_f(*a):
        res = orig_f(*a)
        if res is None:
            raise _stop()
        return res
    return use_f


# == Version check implementation

def _do_check_version(listener, version_string):
    from packaging.version import parse as parse_version

    target_version = parse_version(_EXPECTED_VERSION)
    actual_version = parse_version(version_string)

    if target_version == actual_version:
        return True

    _when_not_exact_version(listener, actual_version, target_version)


def _version_via_completed_process(cp):

    # Since it succeeded, assert there's no stderr (only stdout)
    assert 0 == len(cp.stderr)
    line = str(cp.stdout, 'utf-8')
    import re

    # Assert exactly one line in stdout
    one_line, = re.match(r'([^\n]+)\n\Z', line).groups()

    # Parse out the version string in successive levels of detail
    version_string, = re.match(r'watchexec[ ](.+)\Z', one_line).groups()

    return version_string


@_stop_if_none
def _OK_completed_process_for_version_check(listener):
    from subprocess import run as sp_run

    e = None
    try:
        cp = sp_run((_EXECUTABLE_NAME, '--version'), capture_output=True)
    except FileNotFoundError as exception:
        e = exception
    if e:
        return _when_not_installed(listener, e)

    if cp.returncode:
        return _when_couldnt(listener, 'check version', cp)

    return cp


# == Whiners

def _when_not_exact_version(listener, actual_version, target_version):
    if actual_version < target_version:
        preposition = 'behind'
    else:
        assert target_version < actual_version
        preposition = 'ahead of'

    def lineser():
        yield f"Installed version of {_EXECUTABLE_NAME} is {preposition} required version:"  # noqa: E501
        yield f"  required version:  {target_version}"
        yield f"  installed version: {actual_version}"
        yield "(This is probably OK, but we haven't spec'd what to do yet in such cases)"  # noqa: E501

    listener('error', 'expression', 'vendor_command_version_mismatch', lineser)


def _when_couldnt(listener, lexeme_phrase, cp):
    assert 0 == len(cp.stdout)
    big_string = str(cp.stderr, 'utf-8')
    errno = cp.returncode

    def structer():
        return {k: v for k, v in keys_values()}

    def keys_values():
        message_big_string = f"couldn't {lexeme_phrase}:\n{big_string}"

        yield 'errno', errno
        yield 'message', message_big_string
        # (the above is fully helpful as written, as far as we've seen)
    listener('error', 'structure', 'vendor_command_usage_error', structer)


def _when_not_installed(listener, e):
    errno, filename, strerror = e.errno, e.filename, e.strerror

    def structer():
        return {k: v for k, v in keys_values()}

    def keys_values():
        invitation = "(See [409.3] for how to install it)"
        yield 'errno', errno
        yield 'message', '\n'.join((strerror, invitation))
        yield 'filename', filename
    listener('error', 'structure', 'vendor_command_not_found', structer)


class _stop(RuntimeError):
    pass


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #birth
