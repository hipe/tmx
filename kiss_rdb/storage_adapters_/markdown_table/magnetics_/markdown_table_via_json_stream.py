#!/usr/bin/env python3 -W error::Warning::0

# this is stepping-stone one-off, frontiering #[#432] multi-tablism.


class _CLI:

    def __init__(self, *four):
        def f():
            self.exitstatus = 5
        self.exitstatus = 0
        self.stdin, self.stdout, self.stderr, self.ARGV = four
        import script_lib as _
        self._listener = _.listener_via_error_listener_and_IO(f, self.stderr)

    def execute(self):
        if self.stdin.isatty():
            dicts = self._when_tty()
        else:
            dicts = self._when_non_interactive()

        if dicts is not None:
            write = self.stdout.write
            for line in _lines_via_dicts(dicts, self._listener):
                write(line + '\n')

        return self.exitstatus

    def _when_tty(self):

        _, script_path, one_url, * urls = self.ARGV  # awful #parse-args

        # --

        if './' == script_path[0:2]:  # awful - completion on command line
            script_path = script_path[2:]
        stem, _ = script_path.split('.')
        mod_name = stem.replace('/', '.')
        import importlib
        mod = importlib.import_module(mod_name)

        # --
        def obj_stream_via_url(url):
            return mod.object_stream_via_url_(None, url, self._listener)

        if len(urls):
            return _flatten((one_url, *urls), obj_stream_via_url)
        else:
            return obj_stream_via_url(one_url)

    def _when_non_interactive(self):
        _, = self.ARGV  # #parse-args
        import json
        with self.stdin as upstream_lines:
            for line in upstream_lines:
                yield json.parse(line)


def _flatten(args, f):
    for arg in args:
        for item in f(arg):
            yield item


def _lines_via_dicts(dicts, listener):

    # -- output hugo frontmatter. impure but simplifies visual development
    import datetime as _
    _timestamp = _.datetime.now().strftime('%Y-%m-%dT%H:%M:%S-05:00')
    # hardcode timezone because see doc for datetime (near "reality")
    yield '---'
    yield 'title: kubernetes documentation roadmap'
    yield f'date: {_timestamp}'
    yield '---'
    # --

    in_table = False
    last_header_two_label = None

    for dct in dicts:
        label = dct['label']
        if '_is_branch_node' in dct:
            if '_is_composite_node' in dct:
                do_render_header = True
                do_render_table = False
            else:
                do_render_header = True
                do_render_table = False
        else:
            do_render_header = False
            do_render_table = True

        if do_render_header:
            in_table = False
            num = dct['header_level']
            if 1 == num:
                yield ''
                yield ''
                yield f'# <a href="{dct["url"]}">{label}</a>'

            elif 2 == num:
                yield ''  # aesthetics
                yield f'## {label}'
                last_header_two_label = label

            else:
                assert(3 == num)
                yield ''  # aesthetics
                yield f'## {last_header_two_label} - {label}'

        if do_render_table:
            if not in_table:
                yield '|section|notes|'
                yield '|---|---|'
                in_table = True

            yield f'|{label}|'

    # ick/meh
    yield ''
    yield ''
    yield ''
    yield ''
    yield '## (document-meta)'
    yield ''
    yield '  - #born.'


if __name__ == '__main__':
    import sys as o
    _exitstatus = _CLI(o.stdin, o.stdout, o.stderr, o.argv).execute()
    exit(_exitstatus)

# #born.
