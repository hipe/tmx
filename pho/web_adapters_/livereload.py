def SOMETHING_DUMPLING(path, listener, target=None):
    # (based directly on the cli command code that ships with liverelaod)

    from tornado import log
    log.enable_pretty_logging()

    port = 35729

    from livereload.server import Server
    server = Server()
    server.watcher.watch((target or path), delay=None)
    server.serve(host=None, port=port, root=path, open_url_delay=None)

# #born
