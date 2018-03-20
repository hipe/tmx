# -- BEGIN (very closely related to [#024]) get `sys.path` right
def _():
    """normalize `sys.path`

    python makes the assumption that you want the parent directory of your
    entrypoint file prepended to your `sys.path`. in our case that is not
    what we want. in our case:

      - do *not* prepend the dirname of our entrypoint file to `sys.path`.
        (to do so would encourage a smell - module names should be fully
        qualified from the top of our project, not the top of our sub-project.)

      - we are in the entrypoint file (for now) for running the server.

      - we want `sys.path` to be not our own entrypoint directory, but dirname

      - (in a function so lvars don't get confused with "local" exports)
    """

    from os import path
    dirname = path.dirname

    sub_project_dir = dirname(path.abspath(__file__))
    project_dir = dirname(sub_project_dir)

    a = sys.path
    current_head_path = a[0]

    if sub_project_dir == current_head_path:
        """the parent directory of *this file* is at the head of `sys.path`.
        assume this file is the entrypoint file, ergo we are not in some
        kind of test suite. normalize the `sys.path` to follow the guidelines
        set out at [#204].
        """
        a[0] = project_dir
    else:
        raise Exception("we've never loaded this file under tests before")

    _writable_tmpdir = path.join(project_dir, 'writable-tmpdir')

    return (
            _writable_tmpdir,
            sub_project_dir,
            project_dir,
            )

import sys
(writable_tmpdir,
sub_project_dir,
project_dir,
) = _()
# -- END

from flask import (
        Flask,
        flash,
        redirect,
        render_template,
        url_for,
)


import grep_dump.forms as forms

# -- BEGIN this is a thing to move to a separate file one day maybe

class Config:
    SECRET_KEY = 'one_day_make_this_more_secure'  # #todo
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

app.config.from_object(Config)


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


@app.route('/index')
@app.route('/')
def index():
    return render_template('index.html')



def _run_server_forever_custom(app):
    """
    firstly, note that this is ALL likely to be temporary.
    (we mean this WHOLE function :#here1.)

    that said, this undifferentiated chunky mass of code is towards 2
    problems. our description of the problems:

        1) we need to manage the allocation and cleanup of our "jobs"
           directory tree (basically just a tempdir with arbitrary depth).

        2) when we used to just run the app with this 👇 (#history-A.1),

               app.run(debug=True)

           we would get warnings that the socket wasn't closed down
           when we stopped the server with Ctrl-C.

    analysis of the problem: if (2) is already not happening as it should,
    (1) will be even more annoying and cludgy to address. also:

    (1) is primary, but if (2) is actually substantive and we can address
    that too, then maybe we can offer a patch to the lib one day..
    (in the time between when we started working on this with python 3.5
    to 3.6 (now), this may have been fixed. we're not sure yet.)

    so, our objectives:

        1) orchestrate the cleanup of our own facilities in concert
           with server start and stop.

        2) do what you have to do to get the the server to close that
           socket on normal server shutdown (and maybe even abnormal
           server shutdown too.) when you narrow down the problem,
           get rid of the cruft (in a latter commit).

    more analysis of the problem: the canonic call to `app.run` we replace
    (shown above) leads to a mostly "straight" "stack" of calls to wrapper-
    ish functions and methods. each line below represents one "frame" of
    this stack, where each line represents a call that calls each next line:

        (flask app) app.run [1]
        (werkzeug.serving) run_simple [2]
        (") make_server [3]
        (") serve_forever [4]
        [http.server.HTTPServer.serve_forever] [5]
        socketserver.TCPServer.serve_forever [6]

    notes about each frame of the stack (numbers in brackets are "pieces"):

    [1]: flask app.run: (host, port, debug, werkzeug_options). flask choses
         expected defaults for host and port and use_reloader and use_debugger

    [2]: werkzeug.serving.run_simple: (recognizes 15 parameters). this does
         a lot, including binding and listening. unfortunately this is also
         the problem area that we want to address XXX

    [3]: (") make_server: this is exactly factory pattern. we can probably
         un-abstract it, as long as we are using one process and one
         thread.. (but when not, we can probably call this function?)

    [4]: (") serve_forever: a thin wrapper that ensures `server_close`
         (which is an empty hook-in)

    [5]: serve_forever: super().

    [6]: socketserver.TCPServer.serve_forever: read the note here
         (near their XXX). it .. gives pause..
    """

    # === PROLOGUE A (this stuff)

    def on_ctrl_c(signal, frame):

        print('You pressed Ctrl+C!')
        print(r"For now, we're JUST EXITING THIS RAW")

        # real_sock = socket.fromfd(fd, socket.AF_INET, socket.SOCK_STREAM)
        # real_sock.close()

        sys.exit(0)

    import signal
    signal.signal(signal.SIGINT, on_ctrl_c)

    # === PIECE 1

    host = '127.0.0.1'  # the default from there
    port = 5000  # the default from there
    debug = True  # NOT the default
    app.debug = debug  # look how awful this is (as done in source)

    use_reloader = app.debug  # should the server automatically restart etc?
    use_debugger = app.debug  # should the werkzeug debugging system be used?
    use_reloader = False  # NOTE - override above. see where it is used below

    # NOTE skipping some details

    # === PIECE 2  (reminder: this is the big one)

    use_evalex = True  # enable exception evaluation feature (interactive
    # debugging). requires a non-forking server.
    extra_files = None  # meh
    reloader_interval = 3  # how frequently check reloader in seconds (dflt 1)
    reloader_type = 'auto'  # {stat|watchdog}
    threaded = False  # should the process handle each req in sep thread?
    processes = 1  # if > 1, use new process for each req. up to this count
    request_handler = None  # you can inject one other than the default
    static_files = None  # (later for this.. NOTE)
    passthru_errors = True  # true means barf on errors (raise thru server)
    ssl_context = None  # a (sic) for the connection. meh NOTE

    import werkzeug
    if use_debugger:
        from werkzeug.debug import DebuggedApplication
        app = DebuggedApplication(app, use_evalex)

    if static_files:
        from werkzeug.wsgi import SharedDataMiddleware
        app = SharedDataMiddleware(app, static_files)

    # NOTE we're gonna skip bringing in reloader stuff for now
    if use_reloader:
        raise Exception('we did not bring this over yet. avoiding it for now.')

    fd = None  # because we're not using reloader, this is always nothing

    # === PIECE 3 (we explode werkzeug.make_server)
    # (deconstructing it does not gain us much but it's thin)
    # (the source should be refactored to pass args in only 1 place)

    if threaded:
        raise Exception('see source')

    if processes > 1:
        raise Exception('see source')

    import werkzeug.serving as ws

    srv = ws.BaseWSGIServer(host, port, app, request_handler,
            passthru_errors, ssl_context, fd)

    # ~begin copy-paste-ish of `log_startup`
    if fd is None:
        _sock = srv.socket
        _prt = _sock.getsockname()[1]
        _ssl = (lambda: ssl_context is None and 'http' or 'https')()
        _hn = host
        _msg = '(Press CTRL+C to quit)'
        ws._log('info', ' * Running on %s://%s:%d/ %s', _ssl, _hn, _prt, _msg)
    # ~end

    # === (INJECTED)

    def _listener(*a):
        chan = a[0:-1]
        msg = a[-1]
        if 'info' != chan[0]:
            raise Exception('no')
        for line in msg(None):
            ws._log('info', line)

    def _identity(x):  # IDENTITY_
        return x

    import grep_dump._magnetics.jobs_via_directory as mod  # near [#204]
    jobser = mod.Jobser(
            dir_path=writable_tmpdir,
            wrapper_class=_identity,
            listener=_listener,
            )

    # === PIECE 4 (werkzeug.serving.BaseWSGIServer.serve_forever)

    # for now, we're exploding this to say hello to it.  also, could use
    # refactor: catching KeyboardInterrupt is confusing, adds nothing.

    # srv.serve_forever()  # OR:

    from http.server import HTTPServer

    srv.shutdown_signal = False
    jobser.enter()
    try:
        HTTPServer.serve_forever(srv)  # (this is piece 5)
    finally:
        jobser.exit()
        print('closing that one socket')
        srv.server_close()

    # === PIECE 5

    # (super())

    # === PIECE 6

    # from socketserver import TCPServer
    # tcp_server = TCPServer.xxx()
    # tcp_server.serve_forever()

    # === END (reminder: the above WHOLE function will probably go. #here1)


if __name__ == '__main__':
    _run_server_forever_custom(app)


# #history-A.1 (can be temporary) when we injected "jobser"
# #history-A.1 (as referenced)
# #born.
