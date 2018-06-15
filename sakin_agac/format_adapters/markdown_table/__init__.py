from sakin_agac.magnetics import (
        format_adapter_via_definition as _format_adapter,
        )
from sakin_agac import (
        cover_me,
        pop_property,
        )


class _My_OpenNewLines_via_Sync:

    def __init__(
            self,
            far_collection_reference,
            near_collection_reference,
            filesystem_functions,
            listener,
            ):
        self._close_me_stack = []
        self._OK = True
        self._mutex = None
        self._near_collection_reference = near_collection_reference
        self._far_collection_reference = far_collection_reference
        self._filesystem_functions = filesystem_functions
        self._listener = listener

    def __enter__(self):
        # (experimentally we do all work on enter, none on construction)

        del(self._mutex)
        self._OK and self.__resolve_sessioner()
        self._OK and self.__resolve_sync_request()
        if self._OK:
            _ = self.__iterate_via_sync_request()
            return _  # #todo
        else:
            return iter(())  # #provision [#410.F]
        # (was #coverpoint5.2 - now gone)

    def __iterate_via_sync_request(self):

        sync_request = pop_property(self, '_sync_request')

        _far_format_adapter = self._far_collection_reference.format_adapter

        _nearstrem_path = self._near_collection_reference.collection_identifier_string  # noqa: E501

        yikes = [
            ('tail_line', True),
            ('business_object_row', False),
            ('table_schema_line_two_of_two', False),
            ('table_schema_line_one_of_two', False),
            ('head_line', True),
        ]

        _sync_params = sync_request.release_sync_parameters()
        _item_stream = sync_request.release_item_stream()
        _nkfn = _sync_params.natural_key_field_name

        # --
        # #coverpoint6.2 (overloaded):
        _use_far_item_stream = (x for x in _item_stream if 'header_level' not in x)  # noqa: E501
        # --

        from .magnetics import newstream_via_farstream_and_nearstream as mag
        tagged_items = mag(
                # the streams:
                farstream_items=_use_far_item_stream,
                nearstream_path=_nearstrem_path,

                # the sync parameters:
                natural_key_field_name=_nkfn,
                farstream_format_adapter=_far_format_adapter,

                listener=self._listener,
                )

        for tag, item in tagged_items:
            top = yikes[-1]
            if top[0] != tag:
                if 'markdown_table_unable_to_be_synced_against_' == tag:
                    # #coverpoint5.3
                    break
                yikes.pop()
                top = yikes[-1]
                if top[0] != tag:
                    cover_me('weahh')
            if top[1]:
                yield item
            else:
                yield item.to_line()

    def __resolve_sync_request(self):
        # (#coverpoint7.1 is failure)

        cm = pop_property(self, '_sessioner')
        self._close_me_stack.append(cm)
        _ = cm.__enter__()
        self._required('_sync_request', _)

    def __resolve_sessioner(self):
        _ = self._far_collection_reference.session_for_sync_request(
                self._filesystem_functions, self._listener)

        # (sessioner false is #coverpoint5.10
        self._required('_sessioner', _)

    def __exit__(self, *_):
        while 0 != len(self._close_me_stack):
            _cm = self._close_me_stack.pop()
            _cm.__exit__(*_)
            """don't pass exception (for now) because confusing.
            result is ignored because confusing.
            #[#410.G] (track nested context managers closing each other)
            #coverpoint7.3
            """
        return False  # never trap exceptions

    def _required(self, prop, x):  # ..
        if x is None:
            self._OK = False
        else:
            setattr(self, prop, x)


# --

_functions = {
        'CLI': {
            'open_new_lines_via_sync': _My_OpenNewLines_via_Sync,
            },
        }

FORMAT_ADAPTER = _format_adapter(
        functions_via_modality=_functions,
        associated_filename_globs=('*.md',),
        format_adapter_module_name=__name__,
        )

# #born.
