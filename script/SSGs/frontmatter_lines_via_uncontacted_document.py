#!/usr/bin/env python3 -W error::Warning::0

"""try to infer hugo frontmatter lines from an "uncontacted" markdown document.

each (if any) document from our collection of internal markdown documents
(numbering in the hundreds) that we would want to publish through hugo (or
probably any other SSG) .. is going to require the requisite "frontmatter"
(or equivalent) lines at the top of the file.

(while this metadata is not strictly necessary, to omit certain frontmatter
lines yields such unpleasant results that we see them as effectively a
bare minimum requirement.)

when we started writing these documents years ago we anticipated that one
day we would probably want to integrate them with an SSG in some a way; and
while we didn't know what SSG platform we would use (much less the interface),
we knew that if we followed certain self-consistent conventions of our own,
we could protofit our old documents to whatever the new way was. today is
the day where we try try to link up the old with the new.

because these internal documents sort of exist on their own remote island
separated from the rest of the world by years, we call them "uncontacted".

here's the relevant conventions of our "uncontacted" documents:

  - every first line of every document is a "title header" (a header
    with exactly one octothorp). (furthermore we almost never use such
    a header anywhere else in the document.)

  - every document has a final section called 'document-meta'. we won't
    be fully realizing the "vision" for this section here, but suffice
    it to say that the _final_ line of the section (and so final line
    of the document) should always look something like this '  - #born\n'.
    (sometimes there's a trailing period, sometimes not. it is aesthetic
    but meaningless.)

from these two we can derive the requisite metadata we want.

one final note,
it bears mentioning that the trick with the `#born` line is a more particular
way of doing something more general: `git log --follow the_file.md` and get the
timestap of first commit of the file (which would be the last line of output).

we do it our way and not the above way for a couple reasons:
  - it acts as a sort of poka-yoke, to be sure that we are looking at a
    fully participating document. (if we aren't, chances are good it's not a
    document that we would want to publish as-is anyway.)

  - more generally it's an experiment in parsing such lines of metadata
    for a broader vision of tracking revision history of a document in
    this manner.
"""

_my_doc = __doc__


def _my_parameters(o, param):

    o['markdown_file'] = param(
            description="the path to the conventional markdown document",
            argument_arity='REQUIRED_FIELD',
            )


class _CLI:

    def __init__(self, *four):
        self.stdin, self.stdout, self.stderr, self.ARGV = four  # #[#608.6]
        self.exitstatus = 5
        self.OK = True

    def execute(self):
        self._work()
        return self.exitstatus

    def _work(self):
        self._parse_arguments()
        if not self.OK:
            return

        import script_lib.magnetics as _
        listener = _.listener_via_resources(self)

        dct = _dictionary_via_file(self._markdown_file, listener)
        if dct is None:
            return

        io = self.stdout
        for line in _frontmatter_lines_via_dictionary(dct):
            io.write(line)

        self.exitstatus = 0

    def _parse_arguments(cli):

        from script_lib.magnetics import (
                parse_stepper_via_argument_parser_index as _,
                )
        reso = _.SIMPLE_STEP(
                cli.stdin, cli.stderr, cli.ARGV, _my_parameters,
                stdin_OK=True,
                description=_my_doc,
                )
        ok = reso.OK
        cli.OK = ok  # make extra unnecessary contact for now..
        if not ok:
            cli.exitstatus = reso.exitstatus
            return
        ns = reso.namespace
        cli._markdown_file = getattr(ns, 'markdown-file')


def _frontmatter_lines_via_dictionary(dct):
    """guarantee to write at least the two '---' lines.
    lines are newline terinated.
    """

    yield '---\n'
    for k in dct:
        yield f'"{k}": "{dct[k]}"\n'
    yield '---\n'


def _dictionary_via_file(markdown_file, listener):

    s = _title_via_conventional_markdown_file(markdown_file, listener)
    if s is None:
        return

    ds = _date_string_via_conventional_markdown_file(markdown_file, listener)
    if ds is None:
        return

    return {"title": s, "date": ds}


def _title_via_conventional_markdown_file(path, listener):
    """hackisly parse the first line of the markdown file, asserting that

    it looks like we expect it to. simply return the content of that header.
    """

    with open(path) as lines:
        line = next(lines)

    import re
    md = re.search(r'^# ([a-zA-Z].*)', line)

    if md is None:
        if '---\n' == line:
            def msg():
                yield 'looks like frontmatter already exists for this file'
            listener('info', 'expression', msg)
            return

        def msg():
            yield f"first line doesn't look like title line: {line[1:-1]}"
        listener('error', 'expression', msg)
        return

    return md[1]


def _date_string_via_conventional_markdown_file(path, listener):

    cmd = ['git', 'blame', '--date', 'iso-strict', path]

    import subprocess
    cm = subprocess.Popen(
            args=cmd,

            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=None,  # not what you want, meh

            shell=False,  # True if cmd is (EEW) a string
            text=True,  # sfsef encd
            universal_newlines=None,  # default is False. none b/c text
            )

    with cm as proc:
        sout = proc.stdout

        for line in sout:
            last_line = line

        proc.terminate()
        es = proc.returncode

    if es is not None:
        raise('no')

    import re
    md = re.search(r'^[^(]+\(([^)]+)\) (.*)', last_line)
    if md is None:
        def msg():
            yield f'failed to parse line of output of git blame - {last_line}'
        listener('error', 'expression', msg)
        return

    last_line_ = md[2]
    if re.search(r'^  - \#(born|abstracted)\.?$', last_line_) is None:
        def msg():
            yield f'failed to parse "born" line of file - {last_line_}'
        listener('error', 'expression', msg)
        return

    md2 = re.search(r'[ ]([^ ]+)[ ]\d+$', md[1])
    return md2[1]  # the datestamp


if __name__ == '__main__':
    import hugo_themes as _
    _.normalize_sys_path_()
    import sys as o
    _exitstatus = _CLI(o.stdin, o.stdout, o.stderr, o.argv).execute()
    exit(_exitstatus)

# #born.
