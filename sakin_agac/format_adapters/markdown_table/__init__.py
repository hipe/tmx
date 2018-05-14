from sakin_agac.magnetics import (
        format_adapter_via_definition as _format_adapter,
        )

FORMAT_ADAPTER = _format_adapter(
        associated_filename_globs=('*.md',),
        format_adapter_module_name=__name__,
        )

# #born.
