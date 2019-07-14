"""
description: for a given particular natural key field name, for each item

in the "near collection", see if you can pair it up with an item in the
"far collection" based on that natural key field name.

(the natural key field name is "declared" by the far collection.)

for each given near item, when a corresponding far item exists by the above
criteria, the values of those components in the near item that exist in the
far item are clobbered with the far values.

(the near item can have field names not in the far item, but if the far item
has field names not in the near item, we express this as an error and halt
further processing.)

(after this item-level merge, the far item is removed from a pool).

at the end of all this, each far item that had no corresponding near item
(i.e. that did not "pair up") is simply appended to the near collection.

(this is a synopsis of an algorithm that is described [#447] more formally.)
"""

_desc = __doc__
# #[#874.5] file used to be executable script and may need further changes


from data_pipes import common_producer_script
cli_lib = common_producer_script.common_CLI_library()
biz_lib = cli_lib




def _my_parameters(o, param):

    o['near_collection'] = param(
            description='«help for near_collection»',
            )

    o['near_format'] = param(
            description=biz_lib.try_help_('«the near_format»'),
            argument_arity='OPTIONAL_FIELD',
            )

    biz_lib.common_parameters_from_the_script_called_stream_(o, param)

    # (the following option *should* come from the above function call but it
    # is rarely used and probably not covered in scripts other than this one)
    o['far_format'] = param(
            description=biz_lib.try_help_('«the far_format»'),
            argument_arity='OPTIONAL_FIELD',
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


class _CLI:

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
        self.OK and biz_lib.maybe_express_help_for_format_(
                self, self._normal_args['near_format'])
        self.OK and biz_lib.maybe_express_help_for_format_(
                self, self._normal_args['far_format'])
        self.OK and setattr(self, '_listener', cl.listener_for_(self))
        self.OK and self.__call_over_the_wall()
        return self._pop_property('exitstatus')

    def __call_over_the_wall(self):

        self.exitstatus = 0  # now that u made it this far innocent til guilty

        _d = self._pop_property('_normal_args')
        _context_manager = OpenNewLines_via_Sync_(
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
                tmp_file_path='z/tmp',  # #todo
                )

    def __init_normal_args_via_namespace(self):
        ns = self._pop_property('_namespace')

        near_collection = getattr(ns, 'near-collection')
        self._near_collection = near_collection

        self._do_diff = ns.diff
        self._normal_args = {
                # (#open [#410.E] below)
                'near_collection': near_collection,
                'far_collection': getattr(ns, 'far-collection'),
                'near_format': ns.near_format,
                'far_format': ns.far_format,
                }

    _pop_property = _pop_property


class OpenNewLines_via_Sync_:  # #testpoint

    def __init__(
        self,
        near_collection,
        far_collection,
        listener,
        near_format=None,
        far_format=None,
        custom_mapper_OLDSCHOOL=None,
    ):
        self.near_collection = near_collection
        self.far_collection = far_collection
        self.near_format = near_format
        self.far_format = far_format
        self._custom_mapper_OLDSCHOOL = custom_mapper_OLDSCHOOL
        self._listener = listener
        self.OK = True

    def __enter__(self):
        self.OK and self.__resolve_far_collection_reference()
        self.OK and self.__resolve_near_collection_reference()
        self.OK and self.__resolve_function()
        if not self.OK:
            return
        lines = self.__do_new_doc_lines_via_sync()
        if True:  # ..
            for line in lines:
                yield line

    def __exit__(self, *_):
        return False  # we do not trap exceptions

    def __do_new_doc_lines_via_sync(self):

        far_cr = self._pop_property('_far_collection_reference')
        near_cr = self._pop_property('_near_collection_reference')

        # the real filesystem gets injected at the top of the UI stack
        from script_lib import filesystem_functions as fsf

        _ = self._pop_property('__new_doc_lines_via_sync')
        return _(
                far_collection_reference=far_cr,
                near_collection_reference=near_cr,
                custom_mapper_OLDSCHOOL=self._custom_mapper_OLDSCHOOL,
                filesystem_functions=fsf,
                listener=self._listener,
                )

    def __resolve_function(self):

        def dig_f():

            # the FA might not have defined any such functions for the modality
            yield ('CLI', 'modality functions')

            # the FA might not have defined this particular function
            yield ('new_document_lines_via_sync', 'CLI modality function')

        _ = self._near_collection_reference.format_adapter.DIG_HOI_POLLOI(
                dig_f(), self._listener)

        self._required('__new_doc_lines_via_sync', _)

    def __resolve_near_collection_reference(self):
        _ = _pop_property(self, 'near_collection')
        __ = _pop_property(self, 'near_format')
        _ = biz_lib.collection_reference_via_(_, self._listener, __)
        self._required('_near_collection_reference', _)

    def __resolve_far_collection_reference(self):
        _ = _pop_property(self, 'far_collection')
        __ = _pop_property(self, 'far_format')
        _ = biz_lib.collection_reference_via_(_, self._listener, __)
        self._required('_far_collection_reference', _)

    def _required(self, attr, x):
        if x is None:
            self.OK = False
        else:
            setattr(self, attr, x)

    _pop_property = _pop_property


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

        # #todo - rm to_IO.name (currently kept for debugging)

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


def cli_for_production():
    import sys as o
    _exitstatus = _CLI(o.stdin, o.stdout, o.stderr, o.argv).execute()
    exit(_exitstatus)

# #history-A.2: map-for-sync abstracted out of this
# #history-A.1: replace hand-written argparse with agnostic modeling
# #born.
