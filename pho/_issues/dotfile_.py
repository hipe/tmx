from re import match as _re_match


def write_dotfile(
        dotfile_path,
        readme_path,
        do_write,
        listener):

    wpath, value_path = dotfile_path, readme_path

    def main():
        ensure_value_file_exists()
        ensure_value_file_is_correct_type()
        if not do_write:
            yield ''.join(('export PHO_README=', _quote(value_path)))
            return

        # Eew: we want to open it for reading and writing whether or not
        # it already exists. If it already exists we don't want to truncate
        # it first..

        opened = None
        try:
            opened = open(wpath, 'r+')
        except FileNotFoundError:
            pass
        if opened is None:
            opened = open(wpath, 'w+')
        with opened as wfh:
            self.wfile = wfh
            attempt_write()

    def attempt_write():
        if the_file_has_any_existing_content():
            ensure_wfile_has_exactly_as_many_lines_as_we_expected()
            ensure_the_content_looks_exactly_as_we_expect_it_to()
        ensure_the_value_file_doesnt_look_scary()
        # assume #here1
        bytes_tot = self.wfile.write(f"editable_readme_path: {value_path}\n")
        self.wfile.truncate()
        _celebrate_how_we_did_it(listener, bytes_tot, wpath)

    def ensure_the_value_file_doesnt_look_scary():
        if _re_match(r'\S+\Z', value_path):
            return
        _whine_about_how_value_file_looks_scary(listener, value_path)
        raise stop()

    def ensure_the_content_looks_exactly_as_we_expect_it_to():
        line, = self.first_few_lines
        s = _parse_the_one_line(line, wpath, "won't overwite", listener)
        if s is None:
            stop()
        self.wfile.seek(0)  # #here1
        return

    def ensure_wfile_has_exactly_as_many_lines_as_we_expected():
        lines = self.first_few_lines
        if 1 < len(lines):
            _whine_about_wrong_number_of_lines(listener, lines, wpath)
            raise stop()

    def the_file_has_any_existing_content():
        count, lines, limit = 0, [], 2
        for line in self.wfile:
            count += 1
            lines.append(line)
            if limit == count:
                break
        if not count:
            return False
        self.first_few_lines = tuple(lines)
        return True

    def ensure_value_file_is_correct_type():
        if S_ISREG(self.stat.st_mode):
            return
        _whine_about_how_file_is_of_wrong_type(listener, value_path)
        raise stop()

    def ensure_value_file_exists():
        # Maybe the file is not found:
        try:
            self.stat = stat(value_path)
            return
        except FileNotFoundError as e:
            exce = e

        _whine_about_how_this_file_doesnt_exist(listener, exce)
        raise stop()

    self = main  # #watch-the-world-burn
    stop = _Stop

    from os import stat
    from stat import S_ISREG

    try:
        for line in main():
            yield line
    except stop:
        pass


def read_issues_file_path_from_dotfile(opened, listener):
    with opened as rfile:
        count, lines, limit = 0, [], 2
        for line in rfile:
            count += 1
            lines.append(line)
            if limit == count:
                break
    path = opened.name
    if 1 != len(lines):
        _whine_about_wrong_number_of_lines(listener, lines, path)
        return
    line, = lines
    return _parse_the_one_line(line, path, "can't read", listener)


# == Read and Write

def _parse_the_one_line(line, path, hence, listener):
    md = _re_match(r'editable_readme_path: (\S.+)$', line)
    if md:
        return md[1]
    _whine_about_how_line_doesnt_look_right(
        listener, line, path, hence)


# == Whiners

def _celebrate_how_we_did_it(listener, bytes_tot, wpath):
    def lines():
        yield f"wrote {wpath} ({bytes_tot} bytes)"
    listener('info', 'expression', 'wrote_file', lines)


def _whine_about_how_value_file_looks_scary(listener, value_path):
    def lines():
        yield "This readme path looks scary: {value_path!r}"
    listener('error', 'expression', 'value_file_path_looks_scary', lines)


def _whine_about_how_line_doesnt_look_right(listener, line, path, hence):
    def lines():
        yield f"Existing file line doesn't look right, {hence}:"
        yield f"line 1: {line[:-1]}"
        yield f"File: {path}"
    listener('error', 'expression', 'dotfile_line_looks_funny', lines)


def _whine_about_wrong_number_of_lines(listener, first_few_lines, wpath):
    def lines():
        func = when_too_many if len(first_few_lines) else when_too_few
        for line in func():
            yield line
        yield f"File: {wpath}"

    def when_too_many():
        yield "File has too many lines, expecting one:"
        count = 0
        for line in first_few_lines:
            count += 1
            yield f"line {count}: {line[:-1]}"

    def when_too_few():
        yield "File needs exactly one line but was empty."

    listener('error', 'expression', 'dotfile_has_wrong_number_of_lines', lines)


def _whine_about_how_file_is_of_wrong_type(listener, readme):
    def lines():
        yield f"Not a file - {readme}"
    listener('error', 'expression', 'value_file_is_of_wrong_type', lines)


def _whine_about_how_this_file_doesnt_exist(listener, exce):
    def lines():
        yield "Can't remember this readme file:"
        yield str(exce)
    listener('error', 'expression', 'value_file_not_found', lines)


# == Smalls

class _Stop(RuntimeError):
    pass


# == Delegations

def _quote(s):
    from shlex import quote
    return quote(s)


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #branched-out
