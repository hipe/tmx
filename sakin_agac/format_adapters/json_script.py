"""the "JSON script" format adapter is currently for circumventing process:

the "central conceit" of JSON scripts is that they are the grand unifier
lingua franca: they can be implemented by any language/runtime environment,
(possibly even happening through sockets over a network). the client need
only know that she will have a stream of lines on STDOUT, and that each line
will parse as a simple JSON object.

however, having said all this it can *really* flare up one's OCD having to
go through this "great wall of normalization" just to get what amounts to
a stream of python dictionaries from one python module to another.

imagine two python modules as separate processes, one a producer and one
a consumer, passing a stream of items from producer to consumer:


                                |one line|
                                    ->
                              (could be IPC
                              or network hop)

                                  +------+
                                  |      |
            |convert dictionary|  |      |
            |to JSON string    |  |      |
            |(is string)       |  |      |   |(have string)|
                  ^               |      |           |
                  |               |      |           V
        |convert to     |         |      |     |convert from string |
        |dictionary     |         |      |     |to dictionary       |
        |(is dictionary)|         |      |     |(is dictionary)     |
               ^                  |      |
               |                  |      |
     |source process  |           |      |
     |makes one native|           |      |
     |object (is      |           |      |
     |native object)  |           |      |
                                  | the  |
    producer (in its own process) | wall |  consumer (in its own process)


    fig. 1) it can take 3 to 4 hops per item to go though the great wall,
    as well as (especially) incur network or IPC (I/O) latency.


the above feels like (and *is*) overkill, when we could just do this:

                              |one dictionary|
                                    ->
                               (must be in same
                               python runtime)

                                  +------+
                                  |      |
        |convert to     |         |      |
        |dictionary     |         |      |
        |(is dictionary)|         |      |     |(have dictionary)|
               ^                  |      |
               |                  |      |
     |make one native|            |      |
     |object (is     |            |      |
     |native object) |            | the  |
                                  | wall |

    fig. 2) if we can reasonably stay the same process (python runtime)
    we can reduce it to 1 or 2 hops, and things aren't as crazy.


indeed, figure 2 is how we would architect this if we were sure we wanted
to support only python (but we don't).

so anyway, figure 1 embodies the dream of the potential of this architecture
to achieve a plugin architecture of polyglot nirvana. but figure 2 is a
practical simplification we make, so we can stay in the same process.
(doing so allows us niceties we wouldn't otherwise have, like straightforward
step-debugging and seeing stack traces.)

furthermore, although figure 1 is the dream, it has not yet been realized as
a reality for lack of need. in fact, we have built this in as a provision
(assumption) in this module that we will only be doing figure 2 arrangements
for now. (:#here1).

(in the future we may loosen this so that every such script is categoried
as either "python" or "other" (based on the extension, maybe) and we use
either figure 1 or figure 2 based on that. but suffice it to say, there is
some figure 1 work we would have to do that is not yet implemented.)

.:[#417.A]
"""

from sakin_agac.magnetics import (
        format_adapter_via_definition,
        )
from sakin_agac import (
        cover_me,
        pop_property,
        sanity,
        )
import re
from os import path as os_path


def _open_trav_request(trav_req):
    return _OpenTravRequest(** trav_req.to_dictionary()).execute()


class _OpenTravRequest:
    """
    if such a script ends in *.py (which for now, all of them do :+#here1),
    then don't incur the overhead and annoyance (debugging/development wise)
    of going thru another processs. rather, load it as a module.
    """

    def __init__(
            self,
            cached_document_path,
            collection_identifier,
            datastore_resources,
            format_adapter,
            listener,
            ):

        self._cached_document_path = cached_document_path
        self._filesystem_path = collection_identifier
        self._fiesystem_functions = datastore_resources
        self._format_adapter = format_adapter
        self._listener = listener
        self._OK = True

    def execute(self):
        self._OK and self.__resolve_path_stem_via_path()
        self._OK and self.__resolve_normal_stem_via_path_stem()
        self._OK and self.__resolve_dictionary_stream_session_via_normal_stem()
        if self._OK:
            return self.__flush_context_manager()

    def __flush_context_manager(self):
        """(by 'flush' we mean "build it the one time we build it")"""

        _sess = pop_property(self, '_dictionary_stream_session')
        _fa = pop_property(self, '_format_adapter')
        return _MyContextManager(_sess, _fa)

    def __resolve_dictionary_stream_session_via_normal_stem(self):

        import importlib
        _stem = pop_property(self, '_normal_stem')
        _name = _stem.replace('/', '.')
        _mod = importlib.import_module(_name)  # ..
        _sess = _mod.open_dictionary_stream(
                self._cached_document_path, self._listener)
        self._dictionary_stream_session = _sess

    def __resolve_normal_stem_via_path_stem(self):

        if '/' != os_path.sep:
            cover_me('we need help implementhing this on windows 🙄')

        path_stem = pop_property(self, '_path_stem')

        # if it starts with a dot slash, use the part after it
        md = re.search(r'^\./(?=[^/])', path_stem)
        if md is None:
            md = re.search(r'^/(?=[^/])', path_stem)
            if md is None:
                # if it doesn't look absolute, it must be OK, right?
                self._use_as_normal_stem(path_stem)
            else:
                self.__normalize_stem_when_absolute(path_stem)
        else:
            self.__normalize_stem_when_dot_slash(md, path_stem)

    def __normalize_stem_when_absolute(self, path_stem):
        """when an absolute filesystem path was used, it's a bit more

        tricky: we only want to mess with it if it looks like it's part
        of our ecosysystem (for now). so if the path is "outside" the
        ecosystem, bork. (tacitly, the assumption is it's unacceptably
        weird to have the filesystem root directory in `sys.path.`!)
        """

        dn = os_path.dirname
        import sakin_agac as x
        root = dn(dn(x.__file__))  # not __init__.py, not sakin_agac
        path_len = len(path_stem)
        head_len = len(root) + 1  # include a trailing '/' sep yuck

        if 0 is path_stem.find(root) and path_len > head_len:  # ##[#410.C]
            self._use_as_normal_stem(path_stem[head_len:path_len])
        else:
            self._err('absolute path outside of ecosystem - {}', path_stem)

    def __normalize_stem_when_dot_slash(self, md, path_stem):
        # when it's dot-slash, use the part after it (meh)
        self._use_as_normal_stem(path_stem[md.end():])

    def _use_as_normal_stem(self, s):
        md = re.search(r'[^a-zA-Z0-9_/]', s)
        if md is None:
            self._normal_stem = s
        else:
            _msg = f"character we don't like ({md[0]!r}) in path stem: {s}"
            self._err(_msg)

    def __resolve_path_stem_via_path(self):
        """the path has to end in .py.

        (this is a sanity check only while provision #here1 holds)
        """

        path = pop_property(self, '_filesystem_path')

        stem, ext = os_path.splitext(path)

        if '.py' == ext:
            self._path_stem = stem
        else:
            sanity('the #here1 provision has possibly changed..')

    def _err(self, tmpl, *args):
        from modality_agnostic import listening as li
        _err = li.leveler_via_listener('error', self._listener)
        _err(tmpl, *args)
        self._OK = False


class _MyContextManager:

    def __init__(self, sess, fa):
        self._the_worst = sess
        self._format_adapter = fa

    def __enter__(self):

        _dictionary_stream = self._the_worst.__enter__()

        import sakin_agac.magnetics.synchronized_stream_via_far_stream_and_near_stream as _  # noqa: E501
        return _.SYNC_RESPONSE_VIA_DICTIONARY_STREAM(
                _dictionary_stream,
                self._format_adapter,
                )

    def __exit__(self, *_):
        _exit_me = pop_property(self, '_the_worst')
        return _exit_me.__exit__(*_)  # #[#410.G]


def _native_item_normalizer(dct):
    # #coverpoint7.4
    return dct  # provision [#418.E.2] dictionary is the standard item


def _value_readers_via_field_names(*names):  # #coverpoint5.2
    def reader_for(name):
        def read(normal_dict):
            return normal_dict[name]
        return read
    return [reader_for(name) for name in names]


# --

_functions = {
        'modality_agnostic': {
            'open_filter_request': _open_trav_request,
            'open_sync_request': _open_trav_request,
            }
        }

FORMAT_ADAPTER = format_adapter_via_definition(
        functions_via_modality=_functions,
        native_item_normalizer=_native_item_normalizer,
        value_readers_via_field_names=_value_readers_via_field_names,
        associated_filename_globs=('*.py',),  # :+#here1
        format_adapter_module_name=__name__,
        )

# #born.
