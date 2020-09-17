_from_arg_moniker = 'FROM_COLLECTION'
_from_format_flag = '--from-format'

_to_arg_moniker = 'TO_COLLECTION'
_to_format_flag = '--to-format'


def convert_collection(
        cf, from_format, from_args, from_collection,
        to_format, to_collection):

    # shouldn't need RNG ever - don't we want to transfer the same ID's in?

    def main():
        maybe_dash_is_used_as_FROM()
        maybe_dash_is_used_as_TO()
        make_sure_STDIN_interactivity_looks_right()
        from_coll = resolve_from_collection()
        to_coll = resolve_to_collection()
        dcts = from_coll.multi_depth_value_dictionaries_as_storage_adapter(from_args, mon)  # noqa: E501
        with to_coll.open_pass_thru_receiver_as_storage_adapter(mon) as recv:
            for dct in dcts:
                recv(dct)
                if not mon.OK:
                    raise RuntimeError("cover me: in-loop failure")
        return mon.exitstatus

    def resolve_to_collection():
        return when_STDOUT() if self.TO_is_STDOUT else when_not_STDOUT()

    def resolve_from_collection():
        return when_STDIN() if self.FROM_is_STDIN else when_not_STDIN()

    def when_STDOUT():
        return self.to_SA.module.COLLECTION_IMPLEMENTATION_VIA_SINGLE_FILE(
            stdout, mon)

    def when_STDIN():
        return self.from_SA.module.COLLECTION_IMPLEMENTATION_VIA_SINGLE_FILE(
            stdin, mon)

    def when_not_STDOUT():
        return meta_collection.collection_via_path(
            to_collection, tl, format_name=to_format)._impl

    def when_not_STDIN():
        return meta_collection.collection_via_path(
            from_collection, tl, format_name=from_format)._impl

    def make_sure_STDIN_interactivity_looks_right():
        if self.FROM_is_STDIN:
            if not stdin.isatty():
                return
            error(f"when {_from_arg_moniker} is '-' STDIN must be a pipe")
        if stdin.isatty():
            return
        error(f"STDIN cannot be a pipe unless {_from_arg_moniker} is '-'")

    def maybe_dash_is_used_as_FROM():
        dash_ham('FROM_is_STDIN', 'from_SA', _from_arg_moniker,
                 _from_format_flag, from_collection, from_format)

    def maybe_dash_is_used_as_TO():
        dash_ham('TO_is_STDOUT', 'to_SA', _to_arg_moniker,
                 _to_format_flag, to_collection, to_format)

    def dash_ham(yn_attr, sa_attr, arg_moniker, format_flag, coll_path, fmt):
        memo(yn_attr, yn := '-' == coll_path)
        if not yn:
            return
        if fmt is None:
            error(f"{arg_moniker} of '-' requires '{format_flag}'")
        memo(sa_attr, meta_collection.storage_adapter_via_format_name(fmt, tl))

    # == Listeners and related

    def tl(sev, *rest):
        mon.listener(sev, *rest)
        if 'error' == sev:
            raise stop()

    mon = cf.build_monitor()

    def error(msg):
        cf.echo_error_line(msg)
        raise stop()

    class stop(RuntimeError):
        pass

    # == Our `self` and writing to it

    def memo(attr, mixed):
        setattr(self, attr, mixed)

    class self:  # #class-as-namespace
        pass

    # == Smalls and go!

    dct = cf.release_these_injections('stdin')
    stdin = dct.get('stdin') or cf.stdin  # meh
    stdout = cf.stdout
    meta_collection = cf.collectioner
    try:
        return main()
    except stop:
        return 9876


# #history-B.1: rewrote
# #born.
