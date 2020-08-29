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
# This producer script is one of several covered by (Case5025NC).


import re
from os import path as os_path


_os_path_basename = os_path.basename


_doc = __doc__


def _CLI_for_all(stdin, stdout, stderr, argv):

    def do_CLI_for_all(mon, sin, sout, serr, htd):
        _cli = _CLI_Client(mon.listener, sout, serr, argv)
        return _do_CLI_for_all(_cli, mon, sin, sout, serr, htd)

    do_CLI_for_all.__doc__ = _doc

    from script_lib.cheap_arg_parse import cheap_arg_parse
    return cheap_arg_parse(
            CLI_function=do_CLI_for_all,
            stdin=stdin, stdout=stdout, stderr=stderr, argv=argv,
            formal_parameters=(_same_option(),),
            description_template_valueser=lambda: {})


def _do_CLI_for_all(cli, monitor, sin, sout, serr, htd):
    _these = (_module_via_path(x) for x in _report_paths())
    _run_these_reports_for_CLI(cli, htd, _these)
    monitor.exitstatus


def CLI_for_Report(report_module):
    def f(sin, sout, serr, argv):
        return _do_CLI_for_report(sin, sout, serr, argv, report_module)
    return f


def _do_CLI_for_report(sin, sout, serr, argv, report_module):

    def do_CLI(mon, sin, sout, serr, htd):
        _cli = _CLI_Client(mon.listener, sout, serr, argv)
        _run_these_reports_for_CLI(_cli, htd, (report_module,))
        return mon.exitstatus

    do_CLI.__doc__ = report_module.__doc__

    from script_lib.cheap_arg_parse import cheap_arg_parse
    return cheap_arg_parse(
            CLI_function=do_CLI,
            stdin=sin, stdout=sout, stderr=serr, argv=argv,
            formal_parameters=(_same_option(),),
            description_template_valueser=lambda: {})


def _same_option():
    return (f'{_this_one_opt}=DIR',
            f'or set {_this_one_env_var} environment variable')


def _run_these_reports_for_CLI(cli, themes_dir, report_modules):
    listener = cli.listener

    if themes_dir is None:
        themes_dir = cli.require_environment_variable_value(
                _this_one_env_var, _this_one_opt)
        if themes_dir is None:
            cli.stderr.write(f"see '{cli.program_name} -h' for help.\n")
            return

    rd = _report_dispatcher(report_modules, 'CLI', listener)
    _big_index = _big_index_via_walk(rd, themes_dir, listener)

    write = cli.stdout.write
    for line in rd._lines_via_dispatch_big_index(_big_index):
        write(line + '\n')


class _CLI_Client:

    def __init__(self, listener, sout, serr, argv):
        self.listener = listener
        self.stdout = sout
        self.stderr = serr
        self.argv = argv

    def require_environment_variable_value(self, env_name, opt_name):
        def lineser():
            yield f"pass the '{opt_name}' option or"
            yield f"use the '{env_name}' environment variabler"
        return _require_of_environment(env_name, lineser, self.listener)

    @property
    def program_name(self):
        return _os_path_basename(self.argv[0])


def API_for_Report__(themes_dir, report_module, listener):
    if themes_dir is None:
        def lineser():
            yield f"please set the '{_this_one_env_var} environemnt variable"
        themes_dir = _require_of_environment(_this_one_env_var, lineser, listener)  # noqa: E501
    if themes_dir is None:
        return iter(())
    rd = _report_dispatcher([report_module], 'API', listener)
    _big_index = _big_index_via_walk(rd, themes_dir, listener)
    return rd._dictionaries_via_dispatch_big_index(_big_index)


def _require_of_environment(env_name, lineser, listener):
    # this makes things untestable - is just a stand-in for now

    from os import environ
    if env_name in environ:
        return environ[env_name]

    listener('error', 'expression', 'missing_environment_variable', lineser)


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
        if self._tappers_count == 0:
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

    from script.producer_scripts import (
        script_180920_hugo_theme_toml_stream_via_themes_dir as _)

    _surface_phenomena_index = big_index._surface_phenomena_index

    threer = __build_threer(_surface_phenomena_index, listener)

    if rd._tappers_count:
        real_threer = threer
        if rd._tappers_count == 1:
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
                assert(isinstance(mixed, list))
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

                assert(alternative_k not in assoc_type_via_alternative)
                # why is there already an association?

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
    raise Exception('This was not covered. Almost certainly broke just now.')
    # broke (probably) at #history-A.1. #cover-me. probably trivial to fix

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


def _module_via_path(report_path):  # #[#510.10] module via path
    import importlib
    _stem = __stem_via_path(report_path)
    _use = f'script.producer_scripts.script_180920_hugo_themes.{_stem}'
    return importlib.import_module(_use)


def __stem_via_path(report_path):
    _bn = os_path.basename(report_path)
    stem, _ = os_path.splitext(_bn)  # disregard file extension (always '.py')
    return stem


# -- lowest level/common


def cover_me(msg):
    raise Exception(f'cover me: {msg}')


_blank_rx = re.compile('^[ ]*$')

_word_boundary_rx = re.compile(r'[- ]|(?<=[a-z])(?=[A-Z])')
# split on space or dash or the boundary in a CamelCase .. boundary
# (that's a "positive lookbehind" and a "positive lookahead")


_this_one_opt = '--hugo-themes-dir'
_this_one_env_var = 'SAKIN_AGAC_HUGO_THEMES_DIR'


if __name__ == '__main__':
    import sys as o
    exit(_CLI_for_all(o.stdin, o.stdout, o.stderr, o.argv))

# #history-A.1
# #born.
