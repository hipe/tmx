def sub_magnetic(stem):
    import importlib
    _fa = subject_format_adapter().FORMAT_ADAPTER
    pieces = [_fa.format_adapter_module_name]
    pieces.append('magnetics')
    pieces.append(stem)
    _full_name = '.'.join(pieces)
    return importlib.import_module(_full_name)


def subject_format_adapter():
    import sakin_agac.format_adapters.markdown_table as x
    return x

# #born.
