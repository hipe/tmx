from modality_agnostic.memoization import (
        lazy,
        )
from sakin_agac import (
        cover_me,
        )


class custom_procure__:
    """"procure" is an essential part of [#505] our collections API.

    this is a specialization of it: given a filesystem path (a filename)
    and possibly a format name, we result in a name-value pair for a format
    adapter (where the name is a string like 'markdown_table' and the value
    is the platform module, loaded).
    """

    def __init__(
            self,
            collection_identifier,
            format_identifier,
            listener,
            ):

        self._collection_identifier = collection_identifier
        self._format_identifier = format_identifier
        self._listener = listener
        self.__these = None

    def execute(self):

        if self._format_identifier is None:
            cover_me('soon')
        else:
            x = self.__when_via_format_identifier()
        return x

    def __when_via_format_identifier(self):

        def _needle_function(human_key):
            return needle == human_key  # ..  we have to learn about rx esc for

        needle = self._format_identifier

        return self._procure(
            needle_function=_needle_function,
            say_needle=lambda: repr(needle),
            item_noun_phrase='format adapter',
            )

    def _procure(
            self,
            needle_function,
            say_needle,
            item_noun_phrase,
            subfeatures_via_item=None,
            ):

        kwargs = {}
        if subfeatures_via_item is not None:
            kwargs['subfeatures_via_item'] = subfeatures_via_item

        return _collection_lib().procure(
            human_keyed_collection=self._these(),
            needle_function=needle_function,
            say_needle=say_needle,
            item_noun_phrase=item_noun_phrase,
            listener=self._listener,
            **kwargs,
            )

    def _these(self):
        if self.__these is None:
            self.__these = self.__build_this_thing()
        return self.__these

    def __build_this_thing(self):
        _pairs = to_name_value_pairs()
        _ = _collection_lib()
        return _.human_keyed_collection_via_pairs_cached(_pairs)


def to_name_value_pairs():

    def natural_key_of(mod):
        return rx.search(mod.FORMAT_ADAPTER.format_adapter_module_name)[0]

    import re
    rx = re.compile(r'(?<=\.)[^.]+$')

    return ((natural_key_of(x), x) for x in EVERY_MODULE())


@lazy
def EVERY_MODULE():
    """result is an iterator over every such module.

    don't let the `lazy` fool you: this function is re-entrant:

    it can be called multiple times, and the filesystem is hit anew each
    time. (so if you weirdly add or remove filesystem nodes at runtime, it
    would get picked up.)
    """

    def f():
        return modules_via_directory_and_mod_name(*main_module_tuple)

    def _ALTERNATE_FOR_REFERENCE():
        # (this worked when it was written.)
        # (it's "proof" that we can support multiple adapter dirs)
        for x in modules_via_directory_and_mod_name(*main_module_tuple):
            yield x
        for x in modules_via_directory_and_mod_name(*other_module_tuple):
            yield x

    def modules_via_directory_and_mod_name(direc, mod_name):

        _this_glob = os_path.join(direc, '*')
        _entries = (os_path.basename(x) for x in glob_glob(_this_glob))

        def stems():
            # before #history-A.1 this used to be an elegant generator
            # expression, and could probably be made one again (a reduce)
            for entry in _entries:
                md = rx.search(entry)
                if md is not None:
                    yield md[1]

        _stems = stems()
        return (importlib.import_module('.%s' % x, mod_name) for x in _stems)

    from os import path as os_path
    dn = os_path.dirname
    import re

    main_dir = dn(__file__)

    main_module_tuple = (main_dir, __name__)

    if False:  # (see related test above)
        these = ('sakin_agac_test', 'format_adapters')
        other_module_tuple = (
                os_path.join(dn(dn(main_dir)), * these),
                '.'.join(these),
                )

    rx = re.compile(r'(^(?!_)[^\.]+)(?:\.py)?$')
    """
    such that:
      - don't match if it starts with an underscore
      - if it has an extension, the extension must be '*.py'
      - fnmatch might be more elegant, but we don't know it yet
    """

    import importlib
    from glob import glob as glob_glob
    return f


def _collection_lib():
    import sakin_agac.magnetics.via_human_keyed_collection as x
    return x


# #history-A.1: as referenced
# #born.
