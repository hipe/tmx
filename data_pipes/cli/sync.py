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

# NOTE some of the content of the above text is covered by (Case3066)
# [#447] describes the above algorithm more formally

# at #history-A.3, you can visual test this with
# kiss_rdb_test/fixture-directories/2656-markdown-table/0100-hello.md
# data_pipes_test/fixture_executables/exe_130_edit_add.py


_desc = __doc__


_formal_parameters = (
        ('--near-format=FORMAT_NAME', 'ohai «the near_format»'),
        ('--diff', 'show only the changed lines as a diff'),
        ('near-collection', 'ohai «help for near_collection»', "try 'help'"),
        ('producer-script', 'ohai «help for producer_script»'),
        )


def _CLI(sin, sout, serr, argv):
    from script_lib.cheap_arg_parse import require_interactive, cheap_arg_parse
    if not require_interactive(serr, sin, argv):
        return 456  # _exitstatus_for_error
    return cheap_arg_parse(
            CLI_function=_do_CLI,
            stdin=sin, stdout=sout, stderr=serr, argv=argv,
            formal_parameters=_formal_parameters,
            description_template_valueser=lambda: {})


def _do_CLI(monitor, sin, sout, serr, near_fmt, do_diff, near_coll, ps_path):

    if 'help' == near_fmt:
        from data_pipes.cli import SPLAY_FORMAT_ADAPTERS
        return SPLAY_FORMAT_ADAPTERS(sout, serr)

    _opened = open_new_lines_via_sync(
            ps_path, near_coll, monitor.listener, near_fmt)

    if do_diff:
        line_consumer = _FancyDiffLineConsumer(
                stdout=sout,
                near_collection_path=near_coll,
                tmp_file_path='z/tmp',  # #open [#459.P] currently hard-coded
                )
    else:
        line_consumer = _LineConsumer_via_STDOUT(sout)

    with _opened as lines, line_consumer as receive_line:
        for line in lines:
            receive_line(line)

    return monitor.exitstatus


_do_CLI.__doc__ = _desc


def open_new_lines_via_sync(  # #testpoint
        producer_script_path,
        near_collection,
        listener,
        near_format=None,  # gives a hint, if filesystem path extension ! enuf
        cached_document_path=None,  # for tests
        ):

    from kiss_rdb import collectionerer
    near_coll = collectionerer().collection_via_path(
            collection_path=near_collection,
            adapter_variant='THE_ADAPTER_VARIANT_FOR_STREAMING',
            format_name=near_format,
            listener=listener)
    if near_coll is None:
        return _empty_context_manager()

    # resolve the function for syncing from the near collection reference

    def capability_path():
        yield ('CLI', 'modality functions')
        yield ('new_document_lines_via_sync', 'CLI modality function')

    new_lines_via = near_coll.DIG_FOR_CAPABILITY(capability_path(), listener)
    if new_lines_via is None:
        return _empty_context_manager()

    # resolve the producer script from the far collection reference (for now)

    if hasattr(producer_script_path, 'HELLO_I_AM_A_PRODUCER_SCRIPT'):
        ps = producer_script_path
    else:
        # #open [#873.K] after you load markdown tables the new way,
        # load the producer script the new way too, then get rid of this file

        from data_pipes.format_adapters.producer_script import (
                producer_script_module_via_path)

        ps = producer_script_module_via_path(
                producer_script_path, listener)

        if ps is None:
            return _empty_context_manager()

    # money

    class ContextManager:

        def __enter__(self):
            self._exit_me = None
            o = ps.open_traversal_stream(listener, cached_document_path)
            _dictionaries = o.__enter__()
            self._exit_me = o

            return new_lines_via(
                    stream_for_sync_is_alphabetized_by_key_for_sync=ps.stream_for_sync_is_alphabetized_by_key_for_sync,  # noqa: E501
                    stream_for_sync_via_stream=ps.stream_for_sync_via_stream,
                    dictionaries=_dictionaries,
                    near_keyerer=ps.near_keyerer,
                    filesystem_functions=None,
                    listener=listener)

        def __exit__(self, *_3):
            o = self._exit_me
            self._exit_me = None
            if o is None:
                return False
            return o.__exit__(*_3)

    return ContextManager()


class _FancyDiffLineConsumer:

    def __init__(self, stdout, near_collection_path, tmp_file_path):
        self._tmp_file = open(tmp_file_path, 'w+')
        self._sout = stdout
        self._near_collection_path = near_collection_path

    def __enter__(self):
        return self._receive_line

    def _receive_line(self, line):  # (Case3070)
        self._tmp_file.write(line)

    def __exit__(self, ex, *_):

        if ex is None:
            self._close_normally()
        return False

    def _close_normally(self):

        sout = self._sout

        from_path = self._near_collection_path

        use_fromfile = 'a/%s' % from_path
        use_tofile = 'b/%s' % from_path

        # (the thing doesn't output this line but we need it to use gitx)
        sout.write("diff %s %s\n" % (use_fromfile, use_tofile))

        to_IO = self._tmp_file
        del self._tmp_file
        to_IO.seek(0)

        YUCK_to_lines = [x for x in to_IO]
        to_IO.close()

        with open(from_path) as lines:
            YUCK_from_lines = [x for x in lines]

        from difflib import unified_diff

        _lines = unified_diff(
                YUCK_from_lines,
                YUCK_to_lines,
                fromfile=use_fromfile,
                tofile=use_tofile,
                )

        for line in _lines:
            sout.write(line)

        return False


class _LineConsumer_via_STDOUT:

    def __init__(self, sout):
        self._sout = sout

    def __enter__(self):
        return self._receive_line

    def _receive_line(self, line):
        self._sout.write(line)

    def __exit__(self, *_):
        return False


def _empty_context_manager():
    from data_pipes import TheEmptyIteratorContextManager
    return TheEmptyIteratorContextManager()


def cli_for_production():
    import sys as o
    exit(_CLI(o.stdin, o.stdout, o.stderr, o.argv))

# #history-A.3: no more formal parameters. cheap arg parse not older API's
# #history-A.2: map-for-sync abstracted out of this
# #history-A.1: replace hand-written argparse with agnostic modeling
# #born.
