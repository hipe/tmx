"""
description: for each entity in a far collection, try match it
to an entity in the near collection using the "sync key" of each entity.

If a match is made, the subset of attributes that are set in both entities
will be updated in the near entity to have the values from the far entity.

Attributes set in the near entity that are not set in the far entity are
preserved; but if there any attributes in the far that are not in the near,
this will express an error and halt further processing.
"""
# NOTE some of the content of the above text is covered by (Case3066)
# [#447] describes the above algorithm more formally


from data_pipes import common_producer_script
cli_lib = common_producer_script.common_CLI_library()
biz_lib = cli_lib


_desc = __doc__


def _my_parameters(o, param):

    o['near_collection'] = param(
            description='«help for near_collection»',
            )

    o['near_format'] = param(
            description=biz_lib.try_help_('«the near_format»'),
            argument_arity='OPTIONAL_FIELD',
            )

    o['producer_script'] = param(
            description='«help for producer_script»',
            )

    def diff_desc():  # be like [#511.3]
        yield "show only the changed lines as a diff"

    o['diff'] = param(
            description=diff_desc,
            argument_arity='FLAG',
            )


def _pop_property(self, prop):
    from data_pipes import pop_property
    return pop_property(self, prop)


class _CLI:  # #open [#607.4] de-customize this custom CLI

    def __init__(self, *_four):
        # (Case3061)
        self.stdin, self.stdout, self.stderr, self.ARGV = _four  # #[#608.6]
        self.exitstatus = 5  # starts as guilty til proven innocent
        self.OK = True

    def execute(self):
        cl = cli_lib
        cl.must_be_interactive_(self)
        self.OK and cl.parse_args_(self, '_namespace', _my_parameters, _desc)
        self.OK and self.__init_normal_args_via_namespace()
        self.OK and biz_lib.maybe_express_help_for_format(
                self, self._normal_args['near_format'])
        self.OK and setattr(self, '_listener', cl.listener_for_(self))
        self.OK and self.__call_over_the_wall()
        return self._pop_property('exitstatus')

    def __call_over_the_wall(self):

        self.exitstatus = 0  # now that u made it this far innocent til guilty

        _d = self._pop_property('_normal_args')
        _context_manager = open_new_lines_via_sync(
                **_d,
                listener=self._listener,
                )

        if self._do_diff:
            line_consumer = self.__build_line_consumer_for_dyff_lyfe()
        else:
            line_consumer = _LineConsumer_via_STDOUT(self.stdout)

        with _context_manager as lines, line_consumer as receive_line:
            for line in lines:
                receive_line(line)

    def __build_line_consumer_for_dyff_lyfe(self):
        return _FancyDiffLineConsumer(
                stdout=self.stdout,
                near_collection_path=self._near_collection,
                tmp_file_path='z/tmp',  # #open [#459.P] currently hard-coded
                )

    def __init_normal_args_via_namespace(self):
        ns = self._pop_property('_namespace')

        near_collection = getattr(ns, 'near-collection')
        self._near_collection = near_collection

        self._do_diff = ns.diff
        self._normal_args = {
                # #open [#459.M]: dashes to underscores is getting annoying:
                'producer_script_path': getattr(ns, 'producer-script'),
                'near_collection': near_collection,
                'near_format': ns.near_format,
                }

    _pop_property = _pop_property


def open_new_lines_via_sync(  # #testpoint
        producer_script_path,
        near_collection,
        listener,
        near_format=None,  # gives a hint, if filesystem path extension ! enuf
        cached_document_path=None,  # for tests
        ):

    from kiss_rdb import collection_via_collection_path
    near_coll = collection_via_collection_path(
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

        from kiss_rdb.cli.LEGACY_stream import module_via_path
        ps = module_via_path(producer_script_path, listener)

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

        to_IO = _pop_property(self, '_tmp_file')
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


class _empty_context_manager:  # :[#459.O] the empty context manager
    def __enter__(self):
        return ()

    def __exit__(self, *_3):
        return False


def cli_for_production():
    import sys as o
    _exitstatus = _CLI(o.stdin, o.stdout, o.stderr, o.argv).execute()
    exit(_exitstatus)

# #history-A.2: map-for-sync abstracted out of this
# #history-A.1: replace hand-written argparse with agnostic modeling
# #born.
