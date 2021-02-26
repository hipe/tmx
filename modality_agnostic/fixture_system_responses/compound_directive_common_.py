from . import StrictDict_ as _StrictDict
from shlex import split as _shlex_split
import subprocess as _subprocess
from os.path import join as _path_join


class Directive_called_FROM_TEMPDIR_:

    def __init__(self):
        self.file_copying_directives = []
        self.finish_init_tmpdir_with_this_script = None
        self.filter_the_output_through = None
        self.represent_as_this_command = None
        self.this_is_the_command = None
        self._parametric_directives = _StrictDict()

    def receive_parametric_directive(self, k, v):
        self._parametric_directives[k] = v

    def finish(self):
        dct = self._parametric_directives
        del self._parametric_directives
        for k, v in dct.items():
            getattr(self, k)  # assert name
            setattr(self, k, v)

    def RUN_THE_TRACK(self, source_dir, listener):
        from tempfile import TemporaryDirectory as cls
        with cls() as tmpdir:
            try:
                _touch_this_one_file(tmpdir)
                _copy_files(tmpdir, source_dir, self, listener)
                _run_the_setup_script(tmpdir, self, listener)
                for line in _run_the_story_script(tmpdir, self, listener):
                    yield line
            except _Stop:
                pass


def _run_the_story_script(tmpdir, o, listener):

    # Build the one or two commands
    main_cmd = _build_main_command(o)
    cmd_to_pipe_to = _build_command_to_pipe_to(o)
    if cmd_to_pipe_to:
        describe_cmd_as = *main_cmd, '|', *cmd_to_pipe_to
        binary_yn = True
    else:
        describe_cmd_as = main_cmd
        binary_yn = False

    # Express the command(s)
    _represent_it_as_this(listener, o)
    _about_to_run_this_command(listener, tmpdir, describe_cmd_as)

    # Create the subprocesses
    first_proc = _open_the_main_process(binary_yn, main_cmd, tmpdir, o)
    if cmd_to_pipe_to:
        second_proc = _open_the_process_to_pipe_to(first_proc, cmd_to_pipe_to)
    else:
        second_proc = None

    # Traverse the process(es)
    from contextlib import ExitStack as cls
    with cls() as stack:
        stack.enter_context(first_proc)
        if second_proc:
            stack.enter_context(second_proc)

        proc = (second_proc or first_proc)

        for line in proc.stdout:
            yield line

        bads = []
        if second_proc:
            for line in second_proc.stderr:
                bads.append(line)

        if not bads:
            for line in first_proc.stderr:
                bads.append(line)

        proc.wait()
        rc = proc.returncode

    if bads:
        def lines():
            yield "Got the following line(s) written to stderr, will exit:"
            for bad in bads:
                yield f"   {bad}"
        listener('error', 'expression', 'got_stderr', lines)
        raise RuntimeError(''.join(bads))

    if 0 == rc:
        _express_relief_that_exitstus_was_zero(listener)
        return
    xx(f"but mom do we have to: {rc!r}")


def _open_the_process_to_pipe_to(upstream, cmd):
    sp = _subprocess
    return sp.Popen(
        args=cmd,
        shell=False,
        stdin=upstream.stdout, stdout=sp.PIPE, stderr=sp.PIPE,
        text=True,  # don't give me binary, give me utf-8 strings
        )


def _open_the_main_process(binary_yn, cmd, tmpdir, o):
    sp = _subprocess
    return sp.Popen(
        args=cmd,
        shell=False,
        stdin=sp.DEVNULL, stdout=sp.PIPE, stderr=sp.PIPE,
        # text=(not binary_yn),  # give me binary or utf-8 strings?
        text=True,  # whether or not you are piping, give text not binary (OH?)
        cwd=tmpdir)


def _build_command_to_pipe_to(o):
    string = o.filter_the_output_through
    if string is None:
        return
    return _shlex_split(string)


def _build_main_command(o):
    string = o.this_is_the_command
    assert string
    return _shlex_split(string)


def _run_the_setup_script(tmpdir, o, listener):
    entry = o.finish_init_tmpdir_with_this_script
    assert entry
    entry.rindex('.zsh', -4)  # until it isn't

    sp = _subprocess
    opened = sp.Popen(
        args=('zsh', entry),
        stdin=sp.DEVNULL, stdout=sp.PIPE, stderr=sp.PIPE,
        text=True,  # don't give me binary, give me utf-8 strings
        cwd=tmpdir)

    cache = []

    with opened as proc:

        for line in proc.stdout:
            cache.append(line)
            if 5 == len(cache):
                _zum_zum(listener, tuple(cache))
                cache.clear()

        for line in proc.stderr:
            xx("but mom do we have to")

        proc.wait()
        rc = proc.returncode

    if 0 != rc:
        xx(f"but mom do we have to: {rc!r}")

    if cache:
        _zum_zum(listener, cache)


def _copy_files(tmpdir, source_dir, o, listener):
    from shutil import copyfile
    from os.path import basename
    for source_path in _all_files_to_copy_abspaths(source_dir, o, listener):
        dest = _path_join(tmpdir, basename(source_path))
        copyfile(source_path, dest)


def _all_files_to_copy_abspaths(source_dir, o, listener):
    from glob import glob
    for (typ, val) in o.file_copying_directives:
        if 'copy_these_files' == typ:
            glob_path = _path_join(source_dir, val)
            these = glob(glob_path)
            if 0 == len(these):
                raise _stop_because_glob_made_no_files(listener, glob_path)
            for this in these:
                yield this
            continue
        assert 'copy_this_file' == typ
        yield _path_join(source_dir, val)


def _touch_this_one_file(tmpdir):
    # This is provided so that client scripts can make a sanity check

    from pathlib import Path
    Path(_path_join(tmpdir, '_THIS_IS_A_TEMPORARY_DIRECTORY_')).touch()


def _represent_it_as_this(listener, o):
    if (string := o.represent_as_this_command) is None:
        return

    def lines(): return (f"Represent the following command as this: {string}",)
    listener('info', 'expression', 'represent_the_command_as_this', lines)


# ==

def _express_relief_that_exitstus_was_zero(listener):
    def lines():
        yield "Returncode (exitstatus) from story performance: 0"
    listener('info', 'expression', 'returncode_of_performance_was_zero', lines)


def _about_to_run_this_command(listener, tmpdir, cmd):
    def lines():
        yield f"From this directory: {tmpdir}"
        yield f"About to run this command: {' '.join(cmd)}"
    listener('info', 'expression', 'here_is_the_actual_command', lines)


def _zum_zum(listener, some_lines):
    def lines(): return some_lines
    listener('debug', 'expression', 'some_lines_from_setup_script', lines)


def _stop_because_glob_made_no_files(listener, glob_path):
    def lines(): return f"glob made no files: {glob_path!r}"
    listener('error', 'expression', 'glob_made_no_files', lines)
    return _Stop()


class _Stop(RuntimeError):
    pass


def xx(msg=None):
    raise RuntimeError(''.join(('write me', *((': ', msg) if msg else ()))))

# #born
