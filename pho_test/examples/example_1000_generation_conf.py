def generation_service_config(use_environ, listener):

    # Make sure if you fail, you do it before you yield anything
    intermed_dir = _procure_intermediate_dir(use_environ, listener)
    if not intermed_dir:
        return
    # (OK: now you can't fail)

    yield 'main_pooligan_gen_controller', 'SSG_controller'

    def defn():
        yield 'SSG_adapter', 'peloogan'
        yield 'source_directory', '[pooli intermed dir]'
    yield defn

    yield 'pooli_intermed_dir', 'SSG_intermediate_directory'

    def defn():
        yield 'SSG_adapter', 'peloogan'
        yield 'path', intermed_dir
    yield defn


def _procure_intermediate_dir(use_environ, listener):

    k = 'PHO_PELICAN_INTERMEDIATE_DIR'
    intermed_dir = use_environ.get(k, None)
    if intermed_dir:
        return intermed_dir

    def _():
        yield "Can't run server because can't load config because"
        yield f"missing required environment variable: {k!r}"
        yield '(for now, there is no default for this but maybe one day)'
    listener('error', 'expression', 'missing_required_environment_variable', _)


# #history-B.4: got rid of use of forward reference in path
# #born
