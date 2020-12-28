def generation_service_config(use_environ):
    intermed_dir = use_environ['PHO_PELICAN_INTERMEDIATE_DIR']  # ..

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

# #history-B.4: got rid of use of forward reference in path
# #born
