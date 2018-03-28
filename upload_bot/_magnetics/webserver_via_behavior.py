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
        make_response,
        )
import sys


def _SELF(behaviors, **kwargs):

    global _mutex
    del _mutex  # if this fails, something is wrong

    global _responders

    respos = behaviors.responders_via_expression_agent(None)
    for k in _responder_names:
        _responders[k] = respos[k]

    app.run(debug=True, **kwargs)


app = Flask(__name__)


@app.route('/ping')
def ping():
    return _respond_to_ping(None)


def responder(f):
    k = f.__name__[1:]
    _responder_names.append(k)

    def g(slack_event):
        return _responders[k](_Response(), slack_event)
    return g


_responders = {}
_mutex = None
_responder_names = []


@responder
def _respond_to_ping():
    pass


def destructive(f):
    def g(self, *a, **ka):
        self._touch()
        return f(self, *a, **ka)

    return g


class _Response:

    def __init__(self):
        self._mutex = None

    @destructive
    def respond_via_string(self, big_string):
        return make_response(big_string, 200, {
            'content_type': 'text/html',
            })

    @destructive
    def respond_customly(self, s, num, dct):  # ..
        return make_response(s, num, dct)

    def _touch(self):
        del self._mutex


# == EXPERIMENT
class _SelfAsCallableModule:
    def __call__(self, behaviors, **kwargs):
        return _SELF(behaviors, **kwargs)


sys.modules[__name__] = _SelfAsCallableModule()
# == END EXPERIMENT

# #born.
