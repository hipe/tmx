_from_arg_moniker = 'FROM_COLLECTION'
_from_format_flag = '--from-format'

_to_arg_moniker = 'TO_COLLECTION'
_to_format_flag = '--to-format'


class ConvertCollection:

    def __init__(
            self, cf, from_format, from_args, from_collection,
            to_format, to_collection):

        self.from_collection = from_collection
        self.from_args = from_args
        self.from_format = from_format

        self.to_collection = to_collection
        self.to_format = to_format

        # shouldn't need RNG ever - don't we want to transfer the same ID's in?

        dct = cf.release_these_injections('filesystem', 'stdin')
        self._filesystem = dct['filesystem']
        self._stdin = dct['stdin'] or cf.stdin  # meh

        self._meta_collection = cf.collectioner
        self._monitor = cf.build_monitor()
        self._echo_error = cf.echo_error_line
        self._stdout = cf.stdout

    def execute(self):
        x = self._main()
        if x is None:
            return 9876
        assert(isinstance(x, int))
        return x

    def _main(self):
        if not self.__validate():
            return
        from_coll = self.__procure_from()
        if from_coll is None:
            return
        to_coll = self.__procure_to()
        if to_coll is None:
            return

        mon = self._monitor
        from_coll.convert_collection_into(self.from_args, to_coll, mon)
        return mon.exitstatus

    def __procure_to(self):
        if self._to_is_STDOUT:
            return self._to_SA.collection_for_pass_thru_write__(self._stdout)
        return self.__coll_when_not_STDOUT()

    def __procure_from(self):
        if self._from_is_STDIN:
            return self._from_SA.collection_via_open_read_only__(
                    self._stdin, self._monitor)
        return self.__coll_when_not_STDIN()

    def __coll_when_not_STDIN(self):
        return self._meta_collection.collection_via_path(
                collection_path=self.from_collection,
                listener=self._monitor.listener,
                adapter_variant=None,  # ..
                format_name=self.from_format,
                filesystem=self._filesystem)

    def __validate(self):
        if not self.__resolve_from_storage_adapter_if_provided():
            return
        if not self.__resolve_to_storage_adapter_if_provided():
            return
        if not self.__see_dash_used_as_from_collection_path():
            return
        if not self.__see_dash_use_as_to_collection_path():
            return
        if not self.__make_sure_STDIN_interactivity_looks_right():
            return
        return True

    # --

    def __make_sure_STDIN_interactivity_looks_right(self):
        is_a_tty = self._stdin.isatty()
        if self._from_is_STDIN:
            if not is_a_tty:
                return _okay
            return self._echo_error(
                    f"when {_from_arg_moniker} is '-' STDIN must be a pipe")

        # from not from STDIN
        del self._stdin
        if is_a_tty:
            return _okay

        return self._echo_error(
                f"STDIN cannot be a pipe unless {_from_arg_moniker} is '-'")

    # --

    def __see_dash_used_as_from_collection_path(self):
        ok, self._from_is_STDIN = self.see_dash(
                _from_arg_moniker, self.from_collection,
                _from_format_flag, self._from_SA)

        if ok and self._from_is_STDIN:
            del self.from_collection

        return ok

    def __see_dash_use_as_to_collection_path(self):
        ok, self._to_is_STDOUT = self.see_dash(
                _to_arg_moniker, self.to_collection,
                _to_format_flag, self._to_SA)

        if ok and self._to_is_STDOUT:
            del self.to_collection

        return ok

    def see_dash(self, arg_moniker, coll_path, format_flag, sa):

        if '-' != coll_path:
            return _okay, False

        if sa is not None:
            return _okay, True

        self._echo_error(f"{arg_moniker} of '-' requires '{format_flag}'")
        return _not_okay, None

    # --

    def __resolve_from_storage_adapter_if_provided(self):
        ok, self._from_SA = self.resolve_storage_adapter(self.from_format)
        return ok

    def __resolve_to_storage_adapter_if_provided(self):
        ok, self._to_SA = self.resolve_storage_adapter(self.to_format)
        return ok

    def resolve_storage_adapter(self, format_name):
        # if a storage adapter format name was specified, resovle it into
        # a storage adapter (or fail). if none was passed, pass

        if format_name is None:
            return _okay, None
        sa = self._meta_collection.storage_adapter_via_format_name(
                format_name, self._monitor.listener)
        if sa is None:
            return _not_okay, None
        return _okay, sa


def xx():
    raise Exception('write me')


_not_okay = False
_okay = True

# #born.
