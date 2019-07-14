"""this is HIGHLY experimental and GUARANTEEED to change ARCHITECTURALLY..

the primary objective is to rid ourselves of a deep coupling (dependence)
on flask. (it's useful for what it is but we'd be shooting ourselves in
the foot to build the assumption of flask deep into our stack.)

as such, this is a thin abstraction layer that gets "injected" with an
expression-agent-like thing that is basically just a wrapper around flask
stuff, but done so in a way that this file can be pointed at a different
web server library with little-to-no change.

a charitable reading would be to see this as something like a pillar of an
MVC, but that's overly charitable. this is more like a flask app without
using it by name.
"""

import time
import sys


class _Behaviorer:

    def __init__(self, secrets):
        self.secrets = secrets

    def responders_via_expression_agent(self, expag):
        if expag is not None:
            raise Exception('no')
        return _build_all_responder_functions(self.secrets)


def _build_all_responder_functions(secrets):

    app_tok = secrets.VERIFICATION_TOKEN

    def responder_that_verifies_application_token(f):

        def g(response, slack_event):
            return _verify_application_token(response, slack_event, f, app_tok)

        responder_via_name[f.__name__] = g
        return assert_not_called

    def responder(f):
        responder_via_name[f.__name__] = f
        return assert_not_called

    responder_via_name = {}

    def assert_not_called(*args, **kwargs):
        raise Exception('never actually called')

    # ==

    @responder_that_verifies_application_token
    def respond_to_url_verification(response, slack_event):
        # (Case501)
        return response.respond_in_JSON_via_simple_dictionary(
                challenge=slack_event['challenge'],
                )

    @responder
    def respond_to_ping(response, slack_event):
        _tmpl = 'hello from {} 🙂!<br>\nthe current server time is {}.'
        s = __name__
        _me = s[0:(s.index('.'))]
        _time_fmt = '%Y-%m-%d %H:%M:%S %z'
        _time_s = time.strftime(_time_fmt, time.localtime())
        _big_s = _tmpl.format(_me, _time_s)
        return response.respond_via_string(_big_s)

    return responder_via_name


def _verify_application_token(response, slack_event, f, expected):
    actual = slack_event['token']
    if expected == actual:
        return f(response, slack_event)
    else:

        # NOTE - security bad - don't send our verification token to
        # arbitrary clients (Case499)

        _msg = (
          'I AM NOT FOR PRODUCTION\n' +
          'Invalid Slack verification token:\n' +
          'received: {} expected: {}\n\n'.format(actual, expected)
          )

        response.log('\nyikes:\n{}'.format(_msg))

        # tell slack not to retry (during development)
        x = response.respond_customly(_msg, 403, {'X-Slack-No-Retry': 1})
        return x


# == EXPERIMENT
class _SelfAsCallableModule:
    def __call__(self, secrets):
        return _Behaviorer(secrets)


sys.modules[__name__] = _SelfAsCallableModule()
# == END EXPERIMENT

# #born.
