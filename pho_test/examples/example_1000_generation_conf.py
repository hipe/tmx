def generation_service_config():

    yield 'main_pooligan_gen_controller', 'SSG_controller'

    def defn():
        yield 'SSG_adapter', 'peloogan'
        yield 'source_directory', '[pooli intermed dir]'
    yield defn

    yield 'pooli_intermed_dir', 'SSG_intermediate_directory'

    def defn():
        yield 'SSG_adapter', 'peloogan'
        yield 'path', '[favorite temp dir]', 'peloogan_intermed_dir'
    yield defn

    yield 'favorite_temp_dir', 'filesystem_path', 'z'

# #born
