def run_compound_area_via_definition(defn):
    func = _curses_adapter_module().run_compound_area_via_definition
    return func(defn)


def open_curses_session():
    return _top_module().build_this_crazy_context_manager_()


def input_controller_via_CCA(cca):  # cca = concrete compound area
    from script_lib.curses_yikes.compound_area_via_children import \
        input_controller_via_CCA_ as func
    return func(cca)


def concretize(h, w, aa, listener=None):
    return aa.concretize_via_available_height_and_width(h, w, listener)


def function_for_building_abstract_compound_areas():
    from script_lib.curses_yikes import compound_area_via_children as modul
    return modul.abstract_compound_area_via_children_


def common_exception_class():
    return _top_module().MyException_


def _curses_adapter_module():
    import script_lib.curses_yikes.curses_adapter as module
    return module


def _top_module():
    from script_lib import curses_yikes as module
    return module

# #born
