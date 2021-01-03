def func(path, listener, port, target=None):
    # (based directly on the cli command code that ships with livereload)

    from tornado import log
    log.enable_pretty_logging()

    from livereload.server import Server
    server = Server()
    server.watcher.watch((target or path), delay=None)
    server.serve(host=None, port=port, root=path, open_url_delay=None)

# #born
