# == Decorators used here (experimental, might abstract)

def lazy_load_function_from(module_name):  # #decorator, #[#510.6]
    def decorator(orig_f):
        def use_f(*a):
            from importlib import import_module
            return getattr(import_module(module_name), attr)(*a)
        attr = orig_f.__name__
        return use_f
    return decorator


def lazy_function(orig_f):  # #decorator, #[#510.6]
    def use_f(*a, **kw):
        if not len(really_use_f):
            really_use_f.append(orig_f())
        return really_use_f[0](*a, **kw)
    really_use_f = []  # ick/meh
    return use_f


# ==

@lazy_load_function_from('kiss_rdb_test.common_initial_state')
def pretend_file_via_path_and_big_string():
    pass


@lazy_load_function_from('kiss_rdb_test.common_initial_state')
def pretend_file_via_path_and_lines():
    pass


# ==

def collection_implementation_via_pretend_file(pfile, listener=None):

    # Provide a new definition of `open` that uses our fixture lines
    def opn(path):
        assert pfile.path == path
        return pfile

    return collection_implementation_via(pfile.path, listener, opn)


def collection_implementation_via(path, listener=None, opn=None):

    if listener is None:
        listener = throwing_listener

    from kiss_rdb.storage_adapters_.markdown_table import \
        COLLECTION_IMPLEMENTATION_VIA_SINGLE_FILE as ci_via

    return ci_via(path, listener, opn=opn)


def complete_schema_via_row_ASTs(row1, row2):
    from kiss_rdb.storage_adapters_.markdown_table import \
            complete_schema_via_ as build_complete_schemca
    return build_complete_schemca(row1, row2)


@lazy_function
def row_AST_via_line():
    def row_AST_via_line(line, listener):
        row_AST_via_line = _build_row_AST_via_line(listener, context_stack)
        return row_AST_via_line(line)

    from kiss_rdb.storage_adapters_.markdown_table import \
        _build_row_AST_via_line

    context_stack = ({'path': __file__},)

    return row_AST_via_line


@lazy_function
def tagged_row_ASTs_or_lines_via_lines():
    def tagged_row_ASTs_or_lines_via_lines(lines, listener):
        tagged_lines = _tagged_lines_via_lines(lines)
        return _tagged_row_ASTs_or_lines_via_tagged_lines(
                tagged_lines, listener, context_stack)

    context_stack = ({'path': __file__},)

    from kiss_rdb.storage_adapters_.markdown_table import \
        _tagged_row_ASTs_or_lines_via_tagged_lines, _tagged_lines_via_lines

    return tagged_row_ASTs_or_lines_via_lines


@lazy_load_function_from('modality_agnostic.test_support.common')
def throwing_listener():
    pass

# #abstracted
