from sakin_agac.magnetics import (
        format_adapter_via_definition as _format_adapter,
        )
from sakin_agac import (
        cover_me,
        sanity,
        )


def _new_lines_via_sync(**kwargs):
    return _Thing(**kwargs).execute()


class _Thing:

    def __init__(
            self,
            far_collection_reference,
            near_collection_reference,
            filesystem_functions,
            listener,
            ):
        self._OK = True
        self._mutex = None
        self._near_collection_reference = near_collection_reference
        self._far_collection_reference = far_collection_reference
        self._filesystem_functions = filesystem_functions
        self._listener = listener

    def execute(self):
        self._OK and self.__resolve_sessioner()
        if self._OK:
            return self  # #coverpoint5.2. (return self or another thing)

    def __resolve_sessioner(self):
        sessioner = self._far_collection_reference.session_for_sync_request(
                self._filesystem_functions, self._listener)
        if sessioner is None:
            self._OK = False  # #coverpoint5.1
        else:
            self._sessioner = sessioner

    def TEMPORARY_THING(self):
        """we want to trip the error without having good design, just to

        get these cases covered and the rumskalla code out"""

        self._OK or sanity()
        del(self._mutex)
        eek = _new_lines_via_sync_session(self)
        for line in eek:
            cover_me('x2')
            return iter(())
        return None  # #coverpoint7.3


def _new_lines_via_sync_session(self):

    from .magnetics import newstream_via_farstream_and_nearstream as mag

    _far_format_adapter = self._far_collection_reference.format_adapter

    _nearstrem_path = self._near_collection_reference.collection_identifier_string  # noqa: E501

    yikes = [
            ('tail_line', True),
            ('business_object_row', False),
            ('table_schema_line_two_of_two', False),
            ('table_schema_line_one_of_two', False),
            ('head_line', True),
            ]

    # #open [#410.F] a lot will change here - this is impure as it is

    with self._sessioner as sync_request:
        if sync_request is None:
            return   # #coverpoint7.1 WE HATE THIS

        _sync_params = sync_request.release_sync_parameters()
        _item_stream = sync_request.release_item_stream()
        _nkfn = _sync_params.natural_key_field_name

        _tagged_items = mag(
                # the streams:
                farstream_items=_item_stream,
                nearstream_path=_nearstrem_path,

                # the sync parameters:
                natural_key_field_name=_nkfn,
                farstream_format_adapter=_far_format_adapter,

                listener=self._listener,
                )

        for tag, item in _tagged_items:
            top = yikes[-1]
            if top[0] != tag:
                if 'markdown_table_unable_to_be_synced_against_' == tag:
                    break
                yikes.pop()
                top = yikes[-1]
                if top[0] != tag:
                    cover_me('weahh')
            if top[1]:
                yield item
            else:
                yield item.to_line()


# --

_functions = {
        'CLI': {
            'new_lines_via_sync': _new_lines_via_sync,
            },
        }

FORMAT_ADAPTER = _format_adapter(
        functions_via_modality=_functions,
        associated_filename_globs=('*.md',),
        format_adapter_module_name=__name__,
        )

# #born.
