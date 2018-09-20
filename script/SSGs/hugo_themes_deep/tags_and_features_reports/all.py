#!/usr/bin/env python3 -W error::Warning::0

"""
each hugo theme can have associated with it a list of "features" and a
list of "tags".

  - convention here: when we want to refer to "features" and "tags"
    indiscriminately (i.e when the distinction is not important), we'll say
    "phenomena" (or when referring to a single tag or feature, "phenomenon").

  - convention here: using a more general term associated with this broader
    project generally, we'll say "alternative" rather than "theme". so
    rather than "looking for a theme" we say you are chosing from a set of
    _alternatives_.

to whatever extent useful (and probably to some that are not) we want
this set of metadata (a dozen or so phenomena per alternative for a set
of ~255 alternatives) to be fed into our "dim sum table" of hugo themes,
an effort whose purpose is just outside this scope.

our hope is to answer questions like:

  - is there a practical discernable difference between tags and features?
    (we'll explore some possible metrics for answering this and then attempt
    an answer in the report called "uselessness of the dichotomy".)

  - how "normal" is the set of surface phenomena? (we explain this idea,
    offer metrics to measure it, and attempt an answer, all in
    the report called "variation in the phenomena".)

  - how "synonymous" is the deep set of phenomena? (we'll explore this below.)

  - synthesizing the answers from above, how useful is the received
    metadata? is it made more useful from the meta-metadata we generate
    here? again we'll offer metrics to this throughout, as well as offer some
    qualitative analysis once we have a first pass at answers.

## defining terms and offering metrics: synonymity

"synonymity" is the same idea as "normalcy", but whereas normalcy can be
measured by a report, synonymity is a more subjective determination:
we have to look at the set of all deep phenomena and ask who among them are
"like" the others..
"""


import re
from os import path as os_path
_os_path_basename = os_path.basename


_doc = __doc__


class _CLI_for_all:

    def __init__(self, *_CLI_4):
        self.stdin, self.stdout, self.stderr, self.ARGV = _CLI_4
        self.listener = _listener_for_CLI(self)
        self.exitstatus = 0

    def execute(self):
        if not _parse_args(self):
            return self.exitstatus
        _these = (_module_via_path(x) for x in _report_paths())
        _run_these_reports_for_CLI(self, _these)
        return self.exitstatus

    def _big_help_string(self):
        return _doc


def CLI_for_Report(report_module):
    _normalize_sys_path()  # for now, assume sibling entrypoint

    def f(*_four):
        return _CLI_for_Report(report_module, *_four)
    return f


class _CLI_for_Report:

    def __init__(self, report_module, * _CLI_4):
        self.stdin, self.stdout, self.stderr, self.ARGV = _CLI_4
        self._report_module = report_module
        self.listener = _listener_for_CLI(self)
        self.exitstatus = 0

    def execute(self):
        if not _parse_args(self):
            return self.exitstatus
        _run_these_reports_for_CLI(self, [self._report_module])
        return self.exitstatus

    def _big_help_string(self):
        return self._report_module.__doc__


def _parse_args(cli):
    argv = cli.ARGV
    length = len(argv)
    if 1 == length:
        return True
    io = cli.stderr
    rx = re.compile('^--?h(?:e(?:lp?)?)?$')  # --help
    _ = next((True for i in range(1, length) if rx.match(argv[i])), False)
    if _:
        io.write(f"usage: {argv[0]}\n")
        io.write('\n')
        io.write('arguments: this script requires the environment '
        f'variable {_this_one_env_var} to be set set.\n')  # noqa: E501
        io.write('\n')
        io.write('description:\n')
        io.flush()
        io.write(cli._big_help_string())
    else:
        cli.exitstatus = 334
        io.write(f'no arguments allowed for {argv[0]}\n')
    io.flush()
    return False


def _listener_for_CLI(cli):  # meh
    serr = cli.stderr

    def f(*args):
        flavor, shape, *_, express = args
        None if 'expression' == shape else sanity()
        if 'info' == flavor:
            io = serr
        elif 'error' == flavor:
            io = serr
            if not cli.exitstatus:
                cli.exitstatus = 333
        else:
            sanity()
        for line in express():
            io.write(f'{line}\n')
            io.flush()
    return f


def _run_these_reports_for_CLI(cli, report_modules):
    listener = cli.listener
    themes_dir = _THEMES_DIR_PLACEHOLDER(listener)
    if themes_dir is None:
        cli.stderr.write(f"see '{cli.ARGV[0]} -h' for help.\n")
        return
    rd = _report_dispatcher(report_modules, 'CLI', listener)
    _big_index = _big_index_via_walk(rd, themes_dir, listener)

    write = cli.stdout.write
    for line in rd._lines_via_dispatch_big_index(_big_index):
        write(line + '\n')


def API_for_Report__(themes_dir, report_module, listener):
    if themes_dir is None:
        themes_dir = _THEMES_DIR_PLACEHOLDER(listener)
    if themes_dir is None:
        return iter(())
    rd = _report_dispatcher([report_module], 'API', listener)
    _big_index = _big_index_via_walk(rd, themes_dir, listener)
    return rd._dictionaries_via_dispatch_big_index(_big_index)


def _THEMES_DIR_PLACEHOLDER(listener):
    # this makes things untestable - is just a stand-in for now

    from os import environ
    if _this_one_env_var in environ:
        return environ[_this_one_env_var]

    def f():
        yield f'please set this environment variable: {_this_one_env_var}'
    listener('error', 'expression', 'missing_environment_variable', f)


# -- the reports (dispatching)


def _report_dispatcher(report_modules, modality, listener):
    rd = _ReportDispatcher()
    for report_module in report_modules:
        report_module.Report(rd, modality, listener)
        # the report subscribes to events
    return rd


class _ReportDispatcher:

    def __init__(self):
        self._tappers_count = 0
        self._subscribed_to_phenomenon_variation = []
        self._subscribed_to_big_index = []

    # --

    def receive_subscription_to_tap_each_alternative(self, tap_f, done_f=None):
        if self._tappers_count is 0:
            self._tappers = []
            self._doners = []
        self._tappers_count += 1
        self._tappers.append(tap_f)
        if done_f is not None:
            self._doners.append(done_f)

    # --

    def receive_subscription_to_big_index(self, rcvr):
        self._subscribed_to_big_index.append(rcvr)

    def receive_subscription_to_phenomenon_variation(self, rcvr):
        self._subscribed_to_phenomenon_variation.append(rcvr)

    def _lines_via_dispatch_big_index(self, big_index):
        for rcvr in self._subscribed_to_big_index:
            for line in rcvr(big_index):
                yield line
        # --
        if self._tappers_count:
            for doner in self._doners:
                for line in doner():
                    yield line
        # --
        o = big_index._surface_phenomena_index
        for rcvr in self._subscribed_to_phenomenon_variation:
            for line in rcvr.receive_phenomenon_variation(o):
                yield line

    def _dictionaries_via_dispatch_big_index(self, big_index):
        for rcvr in self._subscribed_to_big_index:
            # COPY PASTED
            for dct in rcvr(big_index):
                yield dct
        # --

        if self._tappers_count:
            for doner in self._doners:
                cover_me('copy paste above lol')
        # --
        for rcvr in self._subscribed_to_phenomenon_variation:
            cover_me('copy paste above lol')


# -- indexing

def _big_index_via_walk(rd, themes_dir, listener):

    big_index = _BigIndex()

    import script.SSGs.hugo_themes_deep.theme_toml_stream_via_themes_dir as _

    _surface_phenomena_index = big_index._surface_phenomena_index

    threer = __build_threer(_surface_phenomena_index, listener)

    if rd._tappers_count:
        real_threer = threer
        if rd._tappers_count is 1:
            tap = rd._tappers[0]

            def threer(alternative):
                three = real_threer(alternative)
                tap(three, alternative)
                return three
        else:
            tap1, tap2 = rd._tappers  # ick/meh

            def threer(alternative):
                three = real_threer(alternative)
                tap1(three, alternative)
                tap2(three, alternative)
                return three

    _ = _.theme_toml_stream_via_themes_dir(themes_dir, listener)
    for path, dct in _:

        alternative = _Alternative(dct, path)
        as_feature_only, as_both, as_tag_only = threer(alternative)
        f = big_index.build_associator_for(alternative)
        f('as_tag_only', as_tag_only)
        f('as_both', as_both)
        f('as_feature_only', as_feature_only)

    return big_index


def __build_threer(surface_phenomena_index, listener):
    """for each phenomenon in the context of each alternative, ensure that

    each alternative has at most *one* association with the phenomenon:
    it is either as-tag-only, as-feature-only, or both. :#here1
    """

    phenomena_keys_via = __build_phenomena_keyser(surface_phenomena_index, listener)  # noqa: E501

    def threer(alternative):

        # as_tag_only = ..
        as_both = []
        as_feature_only = []

        _ = phenomena_keys_via('tags', alternative)

        pool = {k: None for k in _}

        _ = phenomena_keys_via('features', alternative)

        for k in _:
            if k in pool:
                pool.pop(k)
                as_both.append(k)
            else:
                as_feature_only.append(k)
        as_tag_only = list(pool.keys())

        return (as_feature_only, as_both, as_tag_only)
    return threer


def __build_phenomena_keyser(surface_phenomena_index, listener):

    normal_via_surface = surface_phenomena_index.build_normal_via_surface()

    def phenomena_keys_via(which, alternative):
        dct = alternative.dictionary
        alternative_s = alternative.basename
        if which in dct:
            mixed = dct[which]
            if isinstance(mixed, str):
                None if 'nothing yet' == mixed else cover_me('cry')
            else:
                None if isinstance(mixed, list) else sanity()
                for phenomenon_surface_s in mixed:
                    if _blank_rx.match(phenomenon_surface_s):
                        def f():
                            yield f'skipping blank {which} for {alternative_s}'
                        info(f)
                    else:
                        yield normal_via_surface(phenomenon_surface_s)
        else:
            def f():
                yield f'{alternative_s} has no list of {which}s'
            info(f)

    def info(f):
        listener('info', 'expression', 'skipping_because', f)

    return phenomena_keys_via


class _BigIndex:

    def __init__(self):
        self._surface_phenomena_index = _SurfacePhenomenaIndex()
        self._assoc_type_via_alternative_via_phenomenon = {}

    def build_associator_for(self, alternative):
        """so:

        one normal phenomenon has at most one association to any one
        alternative (per #here1).
        """

        dct = self._assoc_type_via_alternative_via_phenomenon
        alternative_k = alternative.basename

        def associate(assoc_type, normal_phenomena):
            for phenom_k in normal_phenomena:
                # whether the phenomenon already exists in the dictionary is
                # not interesting to us here. it's no big deal either way.
                if phenom_k in dct:
                    assoc_type_via_alternative = dct[phenom_k]
                else:
                    assoc_type_via_alternative = {}
                    dct[phenom_k] = assoc_type_via_alternative

                if alternative_k in assoc_type_via_alternative:
                    sanity('why is there already an association?')

                assoc_type_via_alternative[alternative_k] = assoc_type
        return associate

    @property
    def assoc_type_via_alternative_via_phenomenon__(self):
        return self._assoc_type_via_alternative_via_phenomenon

    @property
    def surface_phenomena_index__(self):
        return self._surface_phenomena_index


class _SurfacePhenomenaIndex:

    def __init__(self):
        self._parsed_via_surface = {}

    def build_normal_via_surface(self):

        parsed_via_surface = self._parsed_via_surface

        def f(surface):
            if surface in parsed_via_surface:
                return parsed_via_surface[surface].normal
            parsed = _ParsedPhenomenon(surface)
            key = parsed.normal
            parsed_via_surface[surface] = parsed
            return key
        return f

    @property
    def dictionary_READ_ONLY__(self):
        return self._parsed_via_surface


class _ParsedPhenomenon:
    # keep track of what the surface phenomenon was and its words..

    def __init__(self, surface):
        wordishes = tuple(_word_boundary_rx.split(surface))
        self.normal = '-'.join(wordishes).lower()
        self.wordishes = wordishes
        self.surface = surface


class _Alternative:

    def __init__(self, dct, path):
        self.dictionary = dct
        self.basename = _os_path_basename(path)


# --

def _report_paths():
    _dir = os_path.dirname(__file__)
    # at writing, above should be same as `sys.path[0]` but like, yikes
    _cmd = ['find', _dir, '-name', 'report_*.py', '-type', 'f', '-maxdepth', '1']  # noqa: E501
    import subprocess
    _ = subprocess.Popen(
            _cmd,
            shell=False,
            stdout=subprocess.PIPE,
            universal_newlines=None,  # can't be not-none when `text=True`
            text=True,  # not binary
            )

    with _ as proc:
        sout = proc.stdout

        for line in sout:
            yield line[0:-1]  # chop not strip just to be gigo

        es = proc.returncode

    if es is not None:  # `find` doesn't give us a code even when args are bad
        cover_me(f'exitstatus: {es}')


def _module_via_path(report_path):
    import importlib
    _stem = __stem_via_path(report_path)
    _use = f'script.SSGs.hugo_themes_deep.tags_and_features_reports.{_stem}'
    return importlib.import_module(_use)


def __stem_via_path(report_path):
    _bn = os_path.basename(report_path)
    stem, _ = os_path.splitext(_bn)  # disregard file extension (always '.py')
    return stem


# -- lowest level/common

def _normalize_sys_path():
    # was custom, now is not
    from sys import path as sys_path
    dn = os_path.dirname
    here = os_path.abspath(dn(__file__))
    monorepo_dir = dn(dn(dn(dn(here))))

    if here != sys_path[0]:
        sanity('sanity - in the future, default sys.path may change')
    if monorepo_dir == sys_path[1]:
        sanity()
    # sys_path.insert(1, monorepo_dir)  old way was to keep local dir at head
    sys_path[0] = monorepo_dir


def cover_me(msg):
    raise Exception(f'cover me: {msg}')


def sanity(msg):
    _use_msg = 'sanity' if msg is None else f'sanity: {msg}'
    raise Exception(_use_msg)


_blank_rx = re.compile('^[ ]*$')

_word_boundary_rx = re.compile(r'[- ]|(?<=[a-z])(?=[A-Z])')
# split on space or dash or the boundary in a CamelCase .. boundary
# (that's a "positive lookbehind" and a "positive lookahead")


_this_one_env_var = 'SAKIN_AGAC_HUGO_THEMES_DIR'


if __name__ == '__main__':
    _normalize_sys_path()
    import sys as o
    _exitstatus = _CLI_for_all(o.stdin, o.stdout, o.stderr, o.argv).execute()
    exit(_exitstatus)

# #born.
