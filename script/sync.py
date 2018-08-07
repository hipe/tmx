#!/usr/bin/env python3 -W error::Warning::0

_description_of_sync = """
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

(this is a synopsis of an algorithm that is described [#407] more formally.)
"""


def _my_parameters(o, param):

    o['near_collection'] = param(
            description='«help for near_collection»',
            )

    def __thing_two_desc(o, style):
        o('«help for {}'.format(style.em('far_collection')))
        o('2nd line')

    o['far_collection'] = param(
             description=__thing_two_desc,
             )

    def _plus_etc(s):
        def f(o, style):
            o("{} (try 'help')".format(s))
        return f

    o['near_format'] = param(
            description=_plus_etc('«the near_format»'),
            argument_arity='OPTIONAL_FIELD',
            )

    o['far_format'] = param(
            description=_plus_etc('«the far_format»'),
            argument_arity='OPTIONAL_FIELD',
            )

    def diff_desc(o, _):
        o("show only the changed lines as a diff")

    o['diff'] = param(
            description=diff_desc,
            argument_arity='FLAG',
            )


def _pop_property(self, prop):
    from sakin_agac import pop_property
    return pop_property(self, prop)


class _CLI:  # #coverpoint

    def __init__(self, sin, sout, serr, argv):
        self._sin = sin
        self._sout = sout
        self._serr = serr
        self._argv = argv

    def execute(self):
        self._exitstatus = 5
        self._OK = True
        self._OK and self.__be_sure_interactive()
        self._OK and self.__resolve_namespace_via_parse_args()
        self._OK and self.__resolve_normal_args_via_namespace()
        self._OK and self.__maybe_express_help_for_format()
        self._OK and self.__init_listener()
        self._OK and self.__call_over_the_wall()
        return self._pop_property('_exitstatus')

    def __call_over_the_wall(self):

        self._exitstatus = 0  # now that u made it this far innocent til guilty

        _d = self._pop_property('_normal_args')
        _context_manager = OpenNewLines_via_Sync_(
                **_d,
                listener=self._listener,
                )

        if self._do_diff:
            line_consumer = self.__build_line_consumer_for_dyff_lyfe()
        else:
            line_consumer = _LineConsumer_via_STDOUT(self._sout)

        with _context_manager as lines:
            with line_consumer as receive_line:
                for line in lines:
                    receive_line(line)

    def __build_line_consumer_for_dyff_lyfe(self):
        return _FancyDiffLineConsumer(
                stdout=self._sout,
                near_collection_path=self._near_collection,
                tmp_file_path='z/tmp',  # #todo
                )

    def __init_listener(self):
        # sadly we have to make another one of these
        from script_lib.magnetics import listener_via_resources as lib

        def f(head_channel, *a):
            if 'error' == head_channel:
                # (there can be multiple such emissions)
                self._stop(6)  # meh
            express(head_channel, *a)
        express = lib.listener_via_stderr(self._serr)
        self._listener = f

    def __maybe_express_help_for_format(self):

        self._format_adapters_module = _format_adapters_module()

        arg = self._normal_args
        if 'help' in (arg['near_format'], arg['far_format']):
            self._serr.write(
                 "(just FYI, 'help' does the same thing "
                 "whether it is passed to '--near-format' or '--far-format')\n"
                 )
            self.__express_help_for_format()

    def __express_help_for_format(self):
        sout = self._sout
        serr = self._serr
        serr.write('the filename extension can imply a format adapter.\n')
        serr.write('(or you can specify an adapter explicitly by name.)\n')
        serr.write('known format adapters (and associated extensions):\n')
        count = 0
        for (k, mod) in self._format_adapters_module.to_name_value_pairs():
            _these = ', '.join(mod.FORMAT_ADAPTER.associated_filename_globs)
            sout.write('    {} ({})\n'.format(k, _these))
            count += 1
        serr.write('({} total.)\n'.format(count))
        self._stop_successfully()

    def __resolve_normal_args_via_namespace(self):
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

    def __resolve_namespace_via_parse_args(self):

        from script_lib.magnetics import (
                parse_stepper_via_argument_parser_index as stepperer,
                )

        reso = stepperer.SIMPLE_STEP(
                self._sin, self._serr, self._argv, _my_parameters,
                description=_description_of_sync,
                )
        if reso.OK:
            self._namespace = reso.namespace
        else:
            self._stop(reso.exitstatus)  # #coverpoint6.1.2

    def __be_sure_interactive(self):
        if not self._sin.isatty():
            self.__when_STDIN_is_noninteractive()

    def __when_STDIN_is_noninteractive(self):
        serr = self._serr
        serr.write("cannot yet read from STDIN.\n")
        serr.write("(but maybe one day if there's interest.)\n")
        self._fail_generically()

    def _fail_generically(self):
        self._stop(5)

    def _stop_successfully(self):
        self._stop(0)

    def _stop(self, exitstatus):
        self._exitstatus = exitstatus
        self._OK = False

    _pop_property = _pop_property


class OpenNewLines_via_Sync_:  # #testpoint

    def __init__(
        self,
        near_collection,
        far_collection,
        listener,
        near_format=None,
        far_format=None,
        sneak_this_in=None,
    ):
        self.near_collection = near_collection
        self.far_collection = far_collection
        self.near_format = near_format
        self.far_format = far_format
        self._sneak_this_in = sneak_this_in
        self._listener = listener
        self._format_adapters_module = _format_adapters_module()
        self._OK = True
        self._OK and self.__resolve_far_collection_reference()
        self._OK and self.__resolve_near_collection_reference()
        self._OK and self.__resolve_function()

    def __enter__(self):
        """(reminder: on failure, just use the empty iterator)"""

        if self._OK:
            self.__resolve_runtime_manager_for_new_document_line_stream()
            # (the fact that the above is called on enter is a bit arb..)
        if self._OK:
            _wat = self._context_manager.__enter__()
            return _wat  # #todo
        else:
            return iter(())

    def __exit__(self, *_):
        if self._OK:
            return self._context_manager.__exit__(*_)  # #[#410.G] track nested
        else:
            return False  # we do not trap exceptions

    def __resolve_runtime_manager_for_new_document_line_stream(self):

        _cm_via = self._pop_property('__open_new_lines_via_sync')

        far_cr = self._pop_property('_far_collection_reference')
        near_cr = self._pop_property('_near_collection_reference')

        # (it's significant that we inject the real filesystem at the top)
        from script_lib import (
                filesystem_functions as fsf,
                )

        _cm = _cm_via(
                far_collection_reference=far_cr,
                near_collection_reference=near_cr,
                sneak_this_in=self._sneak_this_in,
                filesystem_functions=fsf,
                listener=self._listener,
                )

        self._required('_context_manager', _cm)

    def __resolve_function(self):

        def dig_f():

            # the FA might not have defined any such functions for the modality
            yield ('CLI', 'modality functions')

            # the FA might not have defined this particular function
            yield ('open_new_lines_via_sync', 'CLI modality function')

        _x = self._near_collection_reference.format_adapter.DIG_HOI_POLLOI(
                dig_f(), self._listener)

        self._required('__open_new_lines_via_sync', _x)

    def __resolve_near_collection_reference(self):
        self._resolve_collection_reference(
                '_near_collection_reference', 'near_collection', 'near_format')

    def __resolve_far_collection_reference(self):
        self._resolve_collection_reference(
                '_far_collection_reference', 'far_collection', 'far_format')

    def _resolve_collection_reference(self, dest_prop, coll_k, format_k):
        tup = self.__tuple_for_reference(coll_k, format_k)
        if tup is None:
            self._stop()
        else:
            coll_id, FA_NAME, format_adapter_module = tup
            _fa = format_adapter_module.FORMAT_ADAPTER
            _ref = _fa.collection_reference_via_string(coll_id)
            setattr(self, dest_prop, _ref)

    def __tuple_for_reference(self, coll_k, format_k):
        format_identifier = self._pop_property(format_k)
        collection_identifier = self._pop_property(coll_k)

        pair = self._format_adapters_module.procure_format_adapter(
                collection_identifier=collection_identifier,
                format_identifier=format_identifier,
                listener=self._listener,
                )
        if pair:
            return (collection_identifier, *pair)

    def _required(self, prop, x):
        if x is None:
            self._stop()
        else:
            setattr(self, prop, x)

    def _stop(self):
        self._OK = False

    _pop_property = _pop_property


class _FancyDiffLineConsumer:

    def __init__(self, stdout, near_collection_path, tmp_file_path):
        self._tmp_file = open(tmp_file_path, 'w+')
        self._sout = stdout
        self._near_collection_path = near_collection_path

    def __enter__(self):
        return self._receive_line

    def _receive_line(self, line):  # #coverpoint6.2
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


def _format_adapters_module():
    """by putting this in a function that is called 2x in this file..

    (virtually a singleton object), we free ourselves from passing it from
    the higher-level modality- to the lower-level API-endpiont; so that
    callers to the latter need not concern themselves with it as a
    parameter. (but note it's a challenge to OCD that this is called 2x
    per typical invocation.)
    """

    import sakin_agac.format_adapters as mod
    return mod


if __name__ == '__main__':
    from json_stream_via_url_and_selector import normalize_sys_path_
    normalize_sys_path_()
    import sys as o
    _exitstatus = _CLI(o.stdin, o.stdout, o.stderr, o.argv).execute()
    exit(_exitstatus)

# #history-A.1: replace hand-written argparse with agnostic modeling
# #born.
