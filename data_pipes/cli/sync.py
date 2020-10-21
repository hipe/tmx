"""
Mutate a near collection by merging ("syncing") a far collection in to it.

(This describes a sync where both collections are well-formed and valid, and
the "interleaving" sync algorithm (described elsewhere) is employed.)

For each entity in the far collection, try to match it to an entity in the
near collection using the "sync key" of each entity.

Entities in the far collection but not the near collection (by sync key) will
be inserted (and surface-represented) into the near collection.

Entities in the near collection but not the far collection (by sync key) will
be left "where they are". (There is currently no `--prune` option).

When a match-pair is made (one near and one far), we attempt an "entity sync",
which is solved in a manner somewhat recurive to the above but different:

Attributes in the near and not the far remain as they are.

For attributes set in both near and far, the far value clobbers the near.

But, if there are attributes in the far that are not present in the near
(by name), this is expressed as an error and we exit early.

(At writing, the above proviso is only for one particular format adapter,
but there is only one participating format adapter for near collections
so it holds for "all".)
"""

# NOTE some of the content of the above text is covered by (Case3492)
# [#447] describes the above algorithm more formally

# at #history-A.3, you can visual test this with
# kiss_rdb_test/fixture-directories/2656-markdown-table/0100-hello.md
# data_pipes_test/fixture_executables/exe_130_edit_add.py


_desc = __doc__


_formal_parameters = (
        ('--near-format=FORMAT_NAME', 'ohai «the near_format»'),
        ('--diff', 'show only the changed lines as a diff'),
        ('-h', '--help', 'this screen'),
        ('<near-collection>', 'ohai «help for near_collection»', "try 'help'"),
        ('<producer-script>', 'ohai «help for producer_script»'))


def CLI_(sin, sout, serr, argv, _rscer):
    from script_lib.cheap_arg_parse import require_interactive, cheap_arg_parse
    if not require_interactive(serr, sin, argv):
        return 456  # _exitstatus_for_error
    return cheap_arg_parse(_do_CLI, sin, sout, serr, argv, _formal_parameters)


CLI_.__doc__ = _desc


def _do_CLI(sin, sout, serr, near_fmt, do_diff, near_coll, ps_path, rscr):
    if 'help' == near_fmt:
        from data_pipes.cli import SPLAY_FORMAT_ADAPTERS
        return SPLAY_FORMAT_ADAPTERS(sout, serr)

    mon = rscr().monitor
    sout_lines = _stdout_lines_from_sync(
            near_coll, ps_path, mon.listener, do_diff, near_fmt)
    for line in sout_lines:
        sout.write(line)
    return mon.exitstatus


def _stdout_lines_from_sync(  # #testpoint
        near_coll_path, producer_script, listener,
        do_diff=False, near_format=None,
        cached_document_path=None, opn=None):

    def main():
        resolve_near_collection()
        resolve_the_sync_agent_of_the_near_collection()
        make_sure_the_sync_agent_can_do_the_thing()
        resolve_the_producer_script()
        for line in work():
            yield line

    def work():
        ps = self.producer_script
        far_sorted = ps.stream_for_sync_is_alphabetized_by_key_for_sync
        near_keyerer = ps.near_keyerer
        opened = ps.open_traversal_stream(listener, cached_document_path)
        with opened as far_dcts:
            stream_for_sync = ps.stream_for_sync_via_stream(far_dcts)
            from data_pipes.magnetics.flat_map_via_far_collection import \
                flat_map_via_producer_script as func
            flat_map = func(
                    stream_for_sync,
                    stream_for_sync_is_alphabetized_by_key_for_sync=far_sorted,
                    preserve_freeform_order_and_insert_at_end=False,
                    build_near_sync_keyer=near_keyerer,  # [#459.R]
                    )
            if do_diff:
                m = 'DIFF_LINES_VIA'
            else:
                m = 'NEW_LINES_VIA'
            call_me = getattr(self.sync_agent, m)
            olines = call_me(flat_map, listener)
            for line in olines:
                yield line

    def resolve_the_producer_script():
        if isinstance(producer_script, str):
            ps = producer_script_normally()
        else:
            assert hasattr(producer_script, 'HELLO_I_AM_A_PRODUCER_SCRIPT__')
            ps = producer_script
        set_or_stop('producer_script', ps)

    def producer_script_normally():
        from data_pipes.format_adapters.producer_script import \
                producer_script_module_via_path_ as func
        return func(producer_script, listener)

    def make_sure_the_sync_agent_can_do_the_thing():
        if do_diff and not self.sync_agent.SYNC_AGENT_CAN_PRODUCE_DIFF_LINES:
            xx()

    def resolve_the_sync_agent_of_the_near_collection():
        def capability_path():
            yield 'SYNC_AGENT_FOR_DATA_PIPES', 'sync-related function'

        # un-abstracted this from library class (simplify it) at #history-B.4

        dig_path = tuple(capability_path())
        assert dig_path
        assert all('_' != k[0] for k, _ in dig_path)  # make sure no names..

        coll = self.near_coll
        say_collection = coll.to_noun_phrase
        ci = coll.COLLECTION_IMPLEMENTATION
        from kiss_rdb.magnetics.via_collection import DIGGY_DIG as func
        x = func(ci, dig_path, say_collection, listener)

        x = x and x()
        set_or_stop('sync_agent', x)

    def resolve_near_collection():
        from data_pipes import meta_collection_ as func
        mcoll = func()
        near_coll = mcoll.collection_via_path(
                collection_path=near_coll_path,
                adapter_variant='THE_ADAPTER_VARIANT_FOR_STREAMING',
                format_name=near_format, opn=opn, listener=listener)
        set_or_stop('near_coll', near_coll)

    def set_or_stop(attr, value):
        if value is None:
            raise stop()
        setattr(self, attr, value)

    class self:
        pass

    class stop(RuntimeError):
        pass

    try:
        for line in main():
            yield line
    except stop:
        pass


def xx(msg=None):
    use_msg = ''.join(('oops/write me', * ((': ', msg) if msg else ())))
    raise RuntimeError(use_msg)


_do_CLI.__doc__ = _desc


if '__main__' == __name__:
    # until we #open [#008.13] figure out how to setup.py, we added this
    # (at #history-A.4) so that we can invoke this script directly
    import sys as o
    exit(CLI_(o.stdin, o.stdout, o.stderr, o.argv, lambda: xx()))

# #history-B.4
# #history-B.1: blind rewrite
# #history-A.4
# #history-A.3: no more formal parameters. cheap arg parse not older API's
# #history-A.2: map-for-sync abstracted out of this
# #history-A.1: replace hand-written argparse with agnostic modeling
# #born.
