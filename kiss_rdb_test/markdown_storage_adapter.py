# == Decorators used here (experimental, might abstract)

def _lazy_load_function_from(module_name, name=None):  # #decorator, #[#510.6]
    def decorator(orig_f):
        def use_f(*a):
            from importlib import import_module
            mod = import_module(module_name)
            func = getattr(mod, attr)
            return func(*a)
        attr = (name or orig_f.__name__)
        return use_f
    return decorator


def _lazy_function(orig_f):  # #decorator, #[#510.6]
    def use_f(*a, **kw):
        if not len(really_use_f):
            really_use_f.append(orig_f())
        return really_use_f[0](*a, **kw)
    really_use_f = []  # ick/meh
    return use_f


# == Used as Default Arguments

@_lazy_load_function_from(
        'modality_agnostic.test_support.common',
        'throwing_listener')
def throwing_listener():
    pass


_throwing_listener = throwing_listener


# == Resolve Collections

def open_entities_via_lines_and_listener(lines, listener):
    coll = _collection_via_mixed(lines, listener)
    return coll.open_entity_traversal(listener)


def collection_via_real_path(path, listener):
    from kiss_rdb import collectionerer as func
    mcoll = func()
    return mcoll.collection_via_path(path, listener)


def _collection_via_mixed(
        x, listener=_throwing_listener, opn=None, iden_er_er=None):
    fh, _mc = _asset_resource_and_controller_via_testing_resource(x)
    return _collection_via_resource(fh, listener, opn, iden_er_er=iden_er_er)


collection_via_mixed_test_resource = _collection_via_mixed


def _collection_via_resource(
        x, listener=_throwing_listener, opn=None, iden_er_er=None):
    sa_mod = _adapter_module()
    from kiss_rdb import collection_via_storage_adapter_and_path as func
    return func(sa_mod, x, listener, opn=opn, iden_er_er=iden_er_er)


collection_via_resource = _collection_via_resource


# == Resolve Smaller Components

@_lazy_function
def single_table_document_scanner_via_lines():
    def do(fp, listener):
        assert hasattr(fp, '__next__')  # [#022]
        return func(fp, listener, which_table=None, iden_er_er=iden_er_er)
    sa = _adapter_module()
    func = sa._single_table_doc_scanner_via_lines
    iden_er_er = sa._build_identifier_builder
    return do


@_lazy_function
def row_AST_via_line():
    def use_func(line, listener):
        asset_func = build_asset_func(listener)
        try:
            return asset_func(line, 0)  # catch stop?
        except stop:
            pass
    mod = _adapter_module()
    build_asset_func = mod._build_row_AST_via_line
    stop = mod._Stop
    return use_func


# == Libs

def complete_schema_via_row_ASTs(row1, row2):
    func = _adapter_module().complete_schema_via_
    return func(row1, row2)


@_lazy_load_function_from(
        'kiss_rdb_test.common_initial_state',
        'pretend_resource_and_controller_via_mixed')
def _asset_resource_and_controller_via_testing_resource():
    pass


def _adapter_module():
    import kiss_rdb.storage_adapters_.markdown_table as module
    return module


def xx(msg=None):
    raise RuntimeError(''.join(('write me', *((': ', msg) if msg else ()))))

# #abstracted
