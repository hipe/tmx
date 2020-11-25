def common_exception_class():
    return _main_asset_module().MyException_


def _main_asset_module():
    from script_lib import curses_yikes as module
    return module

# #born
