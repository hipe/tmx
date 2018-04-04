"""this is an experiment to see if we can keep the webbiness of this..

all in here (in this module (file)). also:

    - we want our indent level of the endpoint functions to be at the
      toplevel (flush to the left of the file), in keeping with the
      tradition of every single flask app you've ever seen probably

    - to meet the above provision, we have to do some hacking with scope

    - at birth (at #born) this was based entirely off of
      https://github.com/slackapi/Slack-Python-Onboarding-Tutorial.git
      (but completely overhauled architecturally)

experimental:

    - we want that the "behaviors" are _implemented_ outside this file.

    - however, the _set_ of behaviors ("soft endpoints") is determined here.

    - just before server startup, we ensure that the behaviors knows
      about all the responders it is expected to implement

    - static code analysis (with `flake8`) ensures that every place we
      call for a responder in our internal function bodies (in this module)
      has a corresponding responder function defined.

    - using the `@responder` decorator ensures that we note every responder
      in a list

    - when we receive the behaviors we request etc
"""

from flask import (
        Flask,
        jsonify,
        make_response,
        render_template,
        request,
        url_for,
        )
import json
import time
import random


def CALL_ME(behaviors, **kwargs):

    global _mutex
    del _mutex  # if this fails, something is wrong

    global _responders

    respos = behaviors.responders_via_expression_agent(None)
    for k in _responder_names:
        _responders[k] = respos[k]

    app.run(debug=True, **kwargs)


def __templates_dir():

    from os import path
    dn = path.dirname

    _sub_project_dir = dn(dn(__file__))
    _templates = path.join(_sub_project_dir, 'templates')
    return _templates


_templates_dir = __templates_dir()

app = Flask(
        __name__,
        template_folder=_templates_dir,
        )


class _Config:
    """(this is not a class for making instances. only used as a namespace.)

    one day schlurp in some of this from file, probably.
    """

    same = 'redis://localhost:6379/0'  # (that's the redis default port)
    CELERY_BROKER_URL = same
    CELERY_RESULT_BACKEND = same
    del same


app.config.from_object(_Config)


do_celery = True  # for now allow us to regress back from celery easily
if do_celery:

    from celery import (
            Celery,
            )

    celery = Celery(
            app.import_name,
            broker=app.config['CELERY_BROKER_URL']
            )
    celery.conf.update(app.config)


@app.route('/wahoo')
def ___wahooo():
    return render_template('index.html', some_message='ohai')


if do_celery:

    @app.route('/wahoo')
    def ___wahooo_TWO():
        return render_template('index.html', some_message='ohai')

    @app.route('/longtask', methods=['POST'])
    def longtask():
        task = long_task.apply_async()  # NOTE CHANGE THIS XXX TODO
        return jsonify({}), 202, {
                'Location': url_for('taskstatus', task_id=task.id),
                }

    @app.route('/status/<task_id>')
    def taskstatus(task_id):
        task = long_task.AsyncResult(task_id)
        if task.state == 'PENDING':
            response = {
                'state': task.state,
                'current': 0,
                'total': 1,
                'status': 'Pending...'
            }
        elif task.state != 'FAILURE':
            response = {
                'state': task.state,
                'current': task.info.get('current', 0),
                'total': task.info.get('total', 1),
                'status': task.info.get('status', '')
            }
            if 'result' in task.info:
                response['result'] = task.info['result']
        else:
            # something went wrong in the background job
            response = {
                'state': task.state,
                'current': 1,
                'total': 1,
                'status': str(task.info),  # this is the exception raised
            }
        return jsonify(response)


@app.route('/slack-action-endpoint', methods=[
    'POST',  # for url_verification
    ])
def slack_action_endpoint():
    """(was called 'listener' over there)"""

    slack_event = json.loads(request.data)

    type_s = slack_event['type']

    if 'url_verification' == type_s:
        return _respond_to_url_verification(slack_event)
    else:
        raise Exception('cover me')


@app.route('/ping')
def ping():
    return _respond_to_ping(None)


# == END WEB ROUTES

# == CELERY TASKS

if do_celery:

    @celery.task(bind=True)
    def long_task(self):
        """Background task that runs a long function with progress reports."""

        verb = ['Starting up', 'Booting', 'Repairing', 'Loading', 'Checking']
        adjective = ['master', 'radiant', 'silent', 'harmonic', 'fast']
        noun = ['solar array', 'particle reshaper', 'cosmic ray', 'orbiter',
                'bit']

        message = ''
        total = random.randint(10, 50)
        for i in range(total):
            if not message or random.random() < 0.25:
                message = '{0} {1} {2}...'.format(random.choice(verb),
                                                  random.choice(adjective),
                                                  random.choice(noun))
            self.update_state(
                    state='PROGRESS',
                    meta={
                        'current': i,
                        'total': total,
                        'status': message,
                        },
                    )

            time.sleep(1)

        return {
                'current': 100,
                'total': 100,
                'status': 'Task completed!',
                'result': 42,
                }

# == END CELERY TASKS


def responder(f):
    k = f.__name__[1:]
    _responder_names.append(k)

    def g(slack_event):
        return _responders[k](_Response(), slack_event)
    return g


_responders = {}
_mutex = None
_responder_names = []


# == BEGIN experimental DSL-ish - these are forward declarations of functions

@responder
def _respond_to_url_verification():
    pass


@responder
def _respond_to_ping():
    pass

# == END experimental DSL-ish


def destructive(f):
    def g(self, *a, **ka):
        self._touch()
        return f(self, *a, **ka)

    return g


class _Response:

    def __init__(self):
        self._mutex = None

    @destructive
    def respond_in_JSON_via_simple_dictionary(self, **kwargs):
        _big_s = json.dumps(kwargs)
        return make_response(_big_s, 200, {
            'content_type': 'application/json',
            })

    @destructive
    def respond_via_string(self, big_string):
        return make_response(big_string, 200, {
            'content_type': 'text/html',
            })

    @destructive
    def respond_customly(self, s, num, dct):  # ..
        return make_response(s, num, dct)

    def log(self, s):
        """(placeholder for the idea)"""
        print(s)

    def _touch(self):
        del self._mutex


# #history-A.1: begin to play with celery
# #born.
