from flask import (
        Flask,
        flash,
        redirect,
        render_template,
        url_for,
)
import werkzeug.serving as ws
import sys

_ws_log = ws._log  # fail early if this non-API function disappears


if True:  # because #history-A.4 if you must know
    from os import path
    dirname = path.dirname

    sub_project_dir = dirname(path.abspath(__file__))
    project_dir = dirname(sub_project_dir)
    writable_tmpdir = path.join(project_dir, 'writable-tmpdir')


import grep_dump.forms as forms  # noqa: E402

# -- BEGIN this is a thing to move to a separate file one day maybe


class _Config:  # :#here1

    SECRET_KEY = 'one_day_make_this_more_secure'  # #open [#207.B]
    """the secret key is supposed to be secret, as the strength of the
    tokens and signatures generated with it depends on no person outside
    of the trusted maintainers of the application knowing it
    """

    pass

# -- END

    """flask will behave wierd (silently) only for the serving of

    static files UNLESS you have the root path be an absolute path
    (if your root path is 'foo-bar', when a static file is attempted to
    be served it will first look and see if the path to be served
    ('foo-bar/static/file') is absolute, and since it isn't, it uses
    the root path (again) and tries to send 'foo-bar/foo-bar/static/file',
    and so always 404's on it). life would be nicer if flask complained that
    the root path is not absolute..)

    :#here2
    """


app = Flask(
        'grep_dump',
        instance_path=sub_project_dir,
        root_path=sub_project_dir,  # #here2
        )

app.config.from_object(_Config)


def __build_jobser():  # (next to where we build app above)

    def listener(*a):
        chan = a[0:-1]
        msg = a[-1]
        if 'info' != chan[0]:
            raise Exception('no')
        for line in msg(None):
            _ws_log('info', line)

    def _build_job(x):  # IDENTITY_
        import grep_dump._magnetics.indexed_tree_via_dump_and_job as mag
        return mag.IndexingJob(x)

    import grep_dump._magnetics.jobs_via_directory as mag  # near [#204]

    return mag.Jobser(
            dir_path=writable_tmpdir,
            wrapper_class=_build_job,
            listener=_listener,
        )


jobser = __build_jobser()


@app.route('/chimi-churri')
def chiminius_churrious():
    import time
    return render_template(
            'blue-ranger-template.html',
            time_s=str(time.time()),
            )


@app.route('/upload-dump', methods=['GET', 'POST'])
def upload_dump():
    form = forms.FileUploadForm()
    job_num = None
    if form.validate_on_submit():
        import grep_dump._magnetics.indexed_tree_via_dump_and_job as mag
        job = mag.JOB_VIA_WEB_FIELD(form.json_file_path, jobser)
        if job is not None:
            job_num = job.job_number

    return render_template(
            'upload-dump.html',
            job_number=job_num,
            form=form,
            title='Upload Time',
            )


@app.route('/search', methods=['GET', 'POST'])
def search():
    form = forms.SearchForm()
    if form.validate_on_submit():
        _big_s = repr(form.data)
        flash('Search requested: {}'.format(_big_s))
        return redirect(url_for('index'))
    else:
        return render_template('search.html', title='Search Time', form=form)


@app.route('/reindex-dump')
def reindex_dump():
    import time
    return render_template('reindex-dump.html', time_s=str(time.time()))


@app.route('/reindex-dump-job-progress')
def reindex_dump_job_progress():
    import time
    return '{"one_zing":"two zing ' + str(time.time()) + '"}'


@app.route('/')
def index():
    return render_template('index.html')


def _run_server_forever_custom(app):
    """closed scope just for splaying & preparing our parameters to werkzeug

    so:
      - splay out *all* the available parameters so they are visible.
      - better than app.run() (or maybe about the same)
      - the obvious ones of these should be moved to config when appropriate
    """

    host = '127.0.0.1'  # the default from there
    port = 5000  # the default from there
    debug = True  # the defatult is False. note here its corollaries
    app.debug = debug  # look how awful this is (as done in source)

    use_reloader = app.debug  # should the server automatically restart etc?
    use_reloader = False   # reloader cant't work with jobser (#here4)
    use_debugger = app.debug  # should the werkzeug debugging system be used?

    use_evalex = True  # enable exception evaluation feature (interactive
    extra_files = None  # a list of files the reloader should watch (after..)
    reloader_interval = 5  # how frequently does reloader check (seconds)
    reloader_type = 'watchdog'  # {watchdog|stat} (stat is horrible)
    threaded = False  # should the process handle each req in sep thread?
    processes = 1  # if > 1, use new process for each req. up to this count
    request_handler = None  # you can inject one other than the default
    static_files = None  # (later for this.. NOTE)
    passthrough_errors = True  # true means barf on errors (raise thru server)
    ssl_context = None  # a (sic) for the connection. meh NOTE

    # ws.run_simple(  # :#here3
    _my_run_simple(
            hostname=host,
            port=port,
            application=app,
            use_reloader=use_reloader,
            use_debugger=use_debugger,
            use_evalex=use_evalex,
            extra_files=extra_files,
            reloader_interval=reloader_interval,
            reloader_type=reloader_type,
            threaded=threaded,
            processes=processes,
            request_handler=request_handler,
            static_files=static_files,
            passthrough_errors=passthrough_errors,
            ssl_context=ssl_context,
            )


def _my_run_simple(
        hostname, port, application, use_reloader,
        use_debugger, use_evalex,
        extra_files, reloader_interval,
        reloader_type, threaded,
        processes, request_handler, static_files,
        passthrough_errors, ssl_context,
        ):

    """copy-paste-modify of werkzeug with a wishlist feature hack-added

    mainly this exists because the whole http server stack (an inheritance
    hierarchy four classes deep!) does not have a listener/hook interface.

    so the only thing this function accomplishes is to copy-paste what we
    need from `werkzeug.serving.run_simple()` *plus* we hold on to the
    server so we can hack it #here4. details:

      - this is a refactoring of `werkzeug.serving.run_simple`

      - if you want to see what the server would be like without this mostly
        redundant hackery, comment-in #here3 (NOTE you will be WITHOUT jobser).

      - we follow the structure there as much as is practical to do (while
        pruning some unnecesary stuff out

      - spiked at #history-A.1 (the first one, oops)

    """

    if use_debugger:
        from werkzeug.debug import DebuggedApplication
        application = DebuggedApplication(application, use_evalex)
    if static_files:
        from werkzeug.wsgi import SharedDataMiddleware
        application = SharedDataMiddleware(application, static_files)

    def _log_startup(sock):
        _ssl = (lambda: ssl_context is None and 'http' or 'https')()
        _hn = hostname
        _prt = sock.getsockname()[1]
        _msg = '(Press CTRL+C to quit)'
        _ws_log('info', ' * Running on %s://%s:%d/ %s', _ssl, _hn, _prt, _msg)

    def _inner():
        fd = None
        s = os.environ.get('WERKZEUG_SERVER_FD')
        if s is not None:
            fd = int(s)

        srv = ws.make_server(hostname, port, application, threaded,
                             processes, request_handler,
                             passthrough_errors, ssl_context,
                             fd)
        # :#here4:
        if use_reloader:
            _ = ' * WARNING: reloader is on so jobser will not be used!'
            _ws_log('warn', _)
        else:
            # _try_to_capture_that_lyfe(srv)  # doesn't add much
            _hackishly_start_jobser_at_server_start(srv)
            _hackishly_stop_jobser_at_server_stop(srv)

        if fd is None:
            _log_startup(srv.socket)

        srv.serve_forever()

    import os
    if use_reloader:
        if os.environ.get('WERKZEUG_RUN_MAIN') != 'true':
            import socket
            addr_fam = socket.AF_INET
            s = socket.socket(addr_fam, socket.SOCK_STREAM)
            s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            _ai = socket.getaddrinfo(hostname, port, addr_fam,
                                     socket.SOCK_STREAM, socket.SOL_TCP)
            _sock_addr = _ai[0][4]  # all this is is (host, port)
            s.bind(_sock_addr)
            s.set_inheritable(True)

            os.environ['WERKZEUG_SERVER_FD'] = str(s.fileno())
            s.listen(ws.LISTEN_QUEUE)
            _log_startup(s)

        from werkzeug._reloader import run_with_reloader
        run_with_reloader(_inner, extra_files, reloader_interval,
                          reloader_type)
    else:
        _inner()


def USE_ME(srv):
    orig_f = srv.server_close

    def f():
        print("LIFE IS WHAT YOU MAKE OF IT")
        orig_f()

    srv.server_close = f


def hack_hook(method_name):
    def real_decorator(new_behavior):
        def hack_instance(inst):
            orig_f = getattr(inst, method_name)

            def new_f():
                new_behavior()
                orig_f()
            setattr(inst, method_name, new_f)
        return hack_instance
    return real_decorator


def _try_to_capture_that_lyfe(srv):
    def on_ctrl_c(signal, frame):

        print('You pressed Ctrl+C!')
        print(r"For now, we're JUST EXITING THIS RAW")

        sys.exit(0)

    import signal
    signal.signal(signal.SIGINT, on_ctrl_c)


@hack_hook('serve_forever')
def _hackishly_start_jobser_at_server_start():
    jobser.enter()


@hack_hook('server_close')
def _hackishly_stop_jobser_at_server_stop():
    """..

    (reminder:)
      - werkzeug.serving.BaseWSGIServer ->
      - http.server.HTTPServer ->
      - socketserver.TCPServer.server_close()  # closes socket
      - socketserver.BaseServer.server_close()  # does nothing
    """

    jobser.exit()


if __name__ == '__main__':
    _run_server_forever_custom(app)


# #history-A.4
# #history-A.3 learned we can't use jobser with reloader
# #history-A.1 (can be temporary) when we injected "jobser"
# #history-A.1 (as referenced)
# #born.
