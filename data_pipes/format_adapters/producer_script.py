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

.:[#457.A]
"""


def OHAI(collection_identity, random_number_generator, filesystem, listener):
    mod = producer_script_module_via_path(
            collection_identity.collection_path, listener)
    if mod is None:
        return
    return _CollectionImplementation(mod)


class _CollectionImplementation:
    def __init__(self, mod):
        self.PRODUCER_SCRIPT_MODULE = mod


def producer_script_module_via_path(script_path, listener):

    from os import path as os_path
    import re

    def main():
        path_stem = path_stem_via_path()
        normal_stem = normal_stem_via_path_stem(path_stem)
        if normal_stem is None:
            return
        return module_via_normal_stem(normal_stem)

    def module_via_normal_stem(normal_stem):
        import importlib
        _name = normal_stem.replace('/', '.')
        return importlib.import_module(_name)  # ..

    def normal_stem_via_path_stem(path_stem):
        assert('/' == os_path.sep)  # windows is possible but not covered

        # if it starts with a dot slash, use the part after it
        md = re.search(r'^\./(?=[^/])', path_stem)
        if md is not None:
            return normal_stem_via_dot_slash(md, path_stem)

        md = re.search(r'^/(?=[^/])', path_stem)
        if md is not None:
            return normal_stem_via_absolute(path_stem)

        # if it doesn't look absolute, it must be OK, right?
        return normal_stem_via_string(path_stem)

    def normal_stem_via_absolute(path_stem):
        """when an absolute filesystem path was used, it's a bit more

        tricky: we only want to mess with it if it looks like it's part
        of our ecosysystem (for now). so if the path is "outside" the
        ecosystem, bork. (tacitly, the assumption is it's unacceptably
        weird to have the filesystem root directory in `sys.path.`!)
        """

        dn = os_path.dirname
        import data_pipes as x
        root = dn(dn(x.__file__))  # not __init__.py, not data_pipes
        path_len = len(path_stem)
        head_len = len(root) + 1  # include a trailing '/' sep yuck

        if 0 is path_stem.find(root) and path_len > head_len:  # ##[#459.L]
            return normal_stem_via_string(path_stem[head_len:path_len])
        else:
            whine(f'absolute path outside of ecosystem - {path_stem}')

    def normal_stem_via_dot_slash(md, path_stem):
        # when it's dot-slash, use the part after it (meh)
        return normal_stem_via_string(path_stem[md.end():])

    def normal_stem_via_string(s):
        md = re.search(r'[^a-zA-Z0-9_/]', s)
        if md is None:
            return s
        else:
            whine(f"character we don't like ({md[0]!r}) in path stem: {s}")

    def path_stem_via_path():
        """the path has to end in .py.

        (this is a sanity check only while provision #here1 holds)
        """

        stem, ext = os_path.splitext(script_path)
        assert('.py' == ext)  # else the #here1 provision may have changed..
        return stem

    def whine(msg):
        listener('error', 'expression', lambda: (msg,))  # #[#511.3]

    return main()


# #history-A.1: storage adapter not format adapter
# #born.
