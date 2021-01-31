from pho.config_component_ import \
        result_is_output_lines_ as _result_is_output_lines
from os.path import join as _path_join


class SSG_controller_via_defn:

    def __init__(self, itr):
        self._freeform_name_value_pairs = {
            'author': 'Viola Davis',  # #open [#407.B] get these from env
            'timezone': 'EST',
        }
        self._forward_refs = []
        for direc in itr:
            if 'source_directory' == direc[0]:
                self._accept_source_directory(* direc[1:])
            else:
                xx()

    def _accept_source_directory(self, pc):
        from pho.config_component_ import varname_via_placeholder_ as func
        varname = func(pc)
        if not varname:
            xx('no')
            self._source_directory = pc  # no. it's a string
            return
        self._source_directory_varname = varname
        self._forward_refs.append((varname, 'source_directory'))

    def finish_via_resolved_forward_references(self, comps):
        kw = {v: comps[k] for k, v in self._forward_refs}
        kw['source_directory_varname'] = self._source_directory_varname
        kw['freeform_KV'] = self._freeform_name_value_pairs
        return _SSG_Controller(**kw)

    @property
    def forward_references(self):
        return (tup[0] for tup in self._forward_refs)


class _SSG_Controller:

    def __init__(
            self, source_directory, source_directory_varname,
            freeform_KV,
            ):

        self._output_directory = 'OUTPUT_DIREOCTO'
        # (#todo at writing the above tested visually, but etc)

        self._source_directory = source_directory
        self._source_directory_varname = source_directory_varname

        self._freeform_name_value_pairs = freeform_KV

        # self._author = "HALLO I'M AUTHOR"  # #here1
        self._site_name = "HALLO I'M SITE NAME"
        self._site_URL = ''
        # self._timezone = 'EST'  # #here1

    def EXECUTE_COMMAND(self, cmd, listener, stylesheet=None):
        from pho.config_component_ import execute_command_ as func
        return func(self, cmd, listener, stylesheet)

    def to_additional_commands_(self):
        yield 'list_source_files', lambda kw: self._execute_command(kw)
        yield 'generate_file', lambda kw: self._execute_command(kw)

    def _execute_command(self, kw):
        cname = kw.pop('command_name')
        rest, listener = kw.pop('rest'), kw.pop('listener')
        kw.pop('stylesheet')
        assert not kw
        if rest is None:
            args = ()
        else:
            args = (rest,)  # while it works
        return getattr(self, cname)(listener, *args)

    # fcev = file change event

    def RECEIVE_FILESYSTEM_CHANGED(self, fcev, listener):
        assert 'file_created_or_saved' == fcev.change_type

        # Make intermediate directory (which is a whole peloocan project)
        diro = self._source_directory
        fkv = self._freeform_name_value_pairs

        rc = _touch_intermediate_project(diro, fkv, listener)
        if rc:
            return rc

        # Derive title and native lines from abstract (normalized) lines
        ad = fcev.TO_ABSTRACT_DOCUMENT(listener)
        if ad is None:
            return 123

        from .native_lines_via_abstract_document import func
        o = func(ad, listener=None)
        if o is None:
            return 123

        entry = o.entry
        wlines = o.write_lines

        # Write the intermediate file (maybe it's create, maybe clobber)
        wpath = _path_join(diro.path, 'pages', entry)  # [#882.B]
        with open(wpath, 'w') as fh:
            for line in wlines:
                fh.write(line)

        # Generate the final output file from the intermediate file!! WHEW
        return self.generate_file(listener, entry)

    def generate_file(self, listener, source_directory_entry):
        argv = self._procure_ARGV_for_generate_single_file(
                source_directory_entry, listener)
        if argv is None:
            return 123
        return self._invoke_pelican_via_ARGV(
                argv, source_directory_entry, listener)

    def _procure_ARGV_for_generate_single_file(
            self, source_dir_ent, listener=None):  # #testpoint

        if not self._check_non_empty_source_dir(listener):
            return

        return _ARGV_for_generate_single_file(
            # AUTHOR=self._author, # #here1
            SITENAME=self._site_name,
            SITEURL=self._site_URL,
            # TIMEZONE=self._timezone, # #here1
            source_directory_entry=source_dir_ent,
            source_directory=self._source_directory.path,
            output_directory=self._output_directory,
            theme_path=None, listener=listener)

    def _invoke_pelican_via_ARGV(self, argv, entry, listener):
        from pelican import main as func
        # (when server, would be nice to load the above eagerly, or not, #todo)

        res = func(argv)
        assert res is None  # just sanity check on their API
        # sadly, we probably can't figure out if it fails easily ..

        msg = f"probably generated: {entry}"
        listener('output', 'expression', lambda: (msg,))
        return 0

    def list_source_files(self, listener):
        return self._source_directory.EXECUTE_COMMAND('ls', listener)

    def _check_non_empty_source_dir(self, listener):
        sd = self._source_directory
        status = sd.status
        need = 'non_empty_directory'
        if need == status:
            return True
        _when_directory_not_ready(listener, status, need, sd.path)

    @_result_is_output_lines
    def execute_show_(self, ss, listener):
        yield ''.join((self.label_for_show_, ss.colon))

        if (sdvn := self._source_directory_varname):
            yield ''.join((ss.tab, 'source directory: ', sdvn))
            return

        lines = iter(self._source_directory.execute_show_(ss, listener))
        first_line = next(lines)

        yield ''.join((ss.tab, 'source directory ', first_line))

        for line in lines:
            yield ''.join((ss.tab, line))

    def get_component_(self, k):
        if 'source_directory' != k:
            return
        return self._source_directory

    def to_component_keys_(self):
        yield 'source_directory'

    label_for_show_ = '(SSG controller)'
    has_components_ = True


def _when_directory_not_ready(listener, status, need, path):
    def lines():
        yield f"source directory not ready. Is {status!r} need {need!r}"
        yield f"directory: {path}"
    listener('error', 'expression', 'source_directory_not_ready', lines)


def _touch_intermediate_project(diro, fkv, listener):
    status = diro.status

    # If directory already exists and has something in it, assume it's ok
    if 'non_empty_directory' == status:
        return 0

    # At this point, path must be noent
    if 'noent' != status:
        def lines():
            reason = status.replace('_', ' ')  # haha
            yield f"can't generate because {reason} - {diro.path}"
        listener('error', 'expression', 'cant_generate', lines)
        return 123

    # Call our task with the rando, messy, particular things we have to give it
    fkv = fkv.copy()
    author = fkv.pop('author')
    timezone = fkv.pop('timezone')
    if fkv:
        xx(f"why: {tuple(fkv.keys())!r}")

    from invoke.context import Context
    c = Context()
    from pho_tasks.tasks import make_pelican_intermediate_directory as task
    task(c, diro.path, author, timezone)  # you chose to result in None
    return 0  # for now we just assume success


class intermediate_directory_via_defn:

    def __init__(self, itr, filesystem=None):
        self._filesystem = filesystem
        for direc in itr:
            typ = direc[0]
            if 'path' == typ:
                self._process_path(direc[1:])
            else:
                xx()

    def finish_via_resolved_forward_references(self, comps):
        path = self._path
        del self._path
        path = path.finish_via_resolved_forward_references(comps)
        from pho.config_component_.directory_via_path import func
        return func(path, _functions, filesystem=self._filesystem)

    def _process_path(self, rest):
        from pho.config_component_.path_with_forward_references import func
        path = func(rest)
        self._forward_references_of_path = path.forward_references
        self._path = path

    @property
    def forward_references(self):
        return self._forward_references_of_path


def _ARGV_for_generate_single_file(
        source_directory_entry, source_directory,
        output_directory, theme_path, listener=None, **other_settings):

    def argv_tokens():
        """NOTE:
        - imagine breaking this up into one for single vs one for directory
        - we put "hotter" options towards the end, like in real life ARGV's
        """

        yield source_directory  # the only positional argument

        if (these := tuple(extra_setting_asst_exprs())):
            yield '--extra-settings', * these
            # (only represent this option 1x! subseq refs overwrite previous)

        yield '--fatal', 'warnings'  # meh
        yield '--debug'   # or --verbose, or nothing
        yield '--theme-path', theme_path
        yield '--generate-selected', 'yes: Pages no: Articles, Static'
        yield '--settings', settings_file_path,
        yield '--output', output_directory
        yield '--write-selected', write_selected

    def extra_setting_asst_exprs():
        for k, v in extra_settings_raw():
            if '' == v:
                # use_v = 'none'
                use_v = ''
            elif ' ' in v:
                if '"' in v:
                    xx(f"have fun: {v!r}")
                use_v = ''.join(('"', v, '"'))
            else:
                use_v = v
            yield f"{k}={use_v}"

    def extra_settings_raw():
        for k in _turn_off_all_feeds():
            yield k, ''
        for k, v in other_settings.items():
            yield k, v

    if theme_path is None:
        theme_path = _default_theme_path()

    write_selected = _output_path_via(output_directory, source_directory_entry)

    settings_file_path = _path_join(source_directory, 'pconf.py')

    return tuple(
        s for row in argv_tokens() for s in
        ((row,) if isinstance(row, str) else row))


def _output_path_via(output_directory, source_directory_entry):
    # Output path via

    from os.path import splitext as _splitext
    base, ext = _splitext(source_directory_entry)
    assert '.md' == ext
    tail = ''.join((base, '.html'))

    return _path_join(output_directory, 'pages', tail)  # [#882.B] pages


def _default_theme_path():
    from os.path import dirname as dn
    from sys import modules
    here = modules[__name__].__file__
    mono_repo_dir = dn(dn(dn(dn(here))))
    return _path_join(
        mono_repo_dir, 'pho-themes', 'for-pelican', 'alabaster-for-pelican')


def _turn_off_all_feeds():
    return (
        # copy-paste of inacessible list in  "pelukan/settings.py:592",
        # but remove those (these) not in the config dict at ":25" 🙃:
        # 'FEED_ATOM', 'FEED_RSS', 'FEED_ALL_RSS', 'CATEGORY_FEED_RSS',
        # 'TAG_FEED_ATOM', 'TAG_FEED_RSS', 'TRANSLATION_FEED_RSS'

        'FEED_ALL_ATOM', 'CATEGORY_FEED_ATOM',
        'AUTHOR_FEED_ATOM', 'AUTHOR_FEED_RSS',
        'TRANSLATION_FEED_ATOM',
    )


class _functions:
    # #todo probably this won't be used
    pass


HELLO_I_AM_AN_ADAPTER_MODULE = True


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))


""":#here1: There are a few configuration parameters that they *don't* have
in the default settings dictionary (which I expect is probably just an
oversight); a corollary of this is that you *can't* pass these config
settings though the `--extra-settings` option; and (if you want to avoid
warnings) you need to have them in the `pelicanconf.py` file. If it weren't
for this fact, we would need no "physical" conf file at all..
"""

# #born
