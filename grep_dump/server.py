# NOTE - #todo - nowhere is it reflected that we used `pip install` to get:
#
#     Flask-WTF        0.14.2


from flask import (
        Flask,
        flash,
        redirect,
        render_template,
        url_for,
)


import forms

# -- BEGIN this is a thing to move to a separate file one day maybe

class Config:
    SECRET_KEY = 'one_day_make_this_more_secure'  # #todo
    """the secret key is supposed to be secret, as the strength of the
    tokens and signatures generated with it depends on no person outside
    of the trusted maintainers of the application knowing it
    """

    pass

# -- END

def __build_root_path():
    """flask will behave wierd (silently) only for the serving of

    static files UNLESS you have the root path be an absolute path
    (if your root path is 'foo-bar', when a static file is attempted to
    be served it will first look and see if the path to be served
    ('foo-bar/static/file') is absolute, and since it isn't, it uses
    the root path (again) and tries to send 'foo-bar/foo-bar/static/file',
    and so always 404's on it). life would be nicer if flask complained that
    the root path is not absolute..)
    """

    from os import path as p
    return p.dirname(p.abspath(__file__))

_root_path = __build_root_path()

app = Flask('grep_dump',
        root_path = _root_path,
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
    return '{"one_zing":"two zing ' + str(time.time()) + '"}';


@app.route('/index')
@app.route('/')
def index():
    return render_template('index.html')


if __name__ == '__main__':
    app.run(debug=True)

# #born.
