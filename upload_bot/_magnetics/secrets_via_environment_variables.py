"""a more specific thing implemented as a more general thing:

in terms of its objectives (the more specific thing), it exists to:

    - verify early whether all the environment variables it expects to
      be set are set, and whether they "look right". do this before
      the webserver starts, so we aren't throwing such errors while
      responding to web requests.

    - serve as an abstraction layer (separation of concerns) between
      the part that reads environment variables and the rest of the system
      (which need not be aware of this implementation detail.)

    - suggest an upgrade path if ever we wanted to do some kind of more
      formalized config solution that did some combination of reading from
      files and from the environment.

in terms of its tactics (the more general thing):

    - since all elements are required for now, at its essence all this is
      is a collection of name-value pairs, whose values are regexes. this
      can be used as a "model" to validate the actual against the expected.

    - as such the bulk of this module tries to act ignorant of its
      specific application.

    - a side benefit of the above is that we can test behavior without
      hard-wiring test specifics to business specifics.
"""

import sys


def _SELF(unsanitized_collection):
    """the only public entrypoint to this module...

    raises exception if something's missing, otherwise results in
    a collection struct with properties named after the requisite names.
    """

    global _SELF  # redefine selfsame function on first call!

    def _SELF(unsanitized_collection):
        return collectioner(unsanitized_collection)  # #hi.

    o = regex_based_validator
    collectioner = _collectioner_via_collection_model({
        'BOT_USER_OATH_ACCESS_TOKEN': o('^xoxb-[0-9]+-[A-Za-z0-9]+$'),
        'VERIFICATION_TOKEN': o('^[A-Za-z0-9]{5,30}$'),  # 24 length prob
        },
        items_plural='environment variables',
        )

    return _SELF(unsanitized_collection)


def _collectioner_via_collection_model(collection_model, **kwargs):
    def f(unsanitized_collection):
        return _work(unsanitized_collection, collection_model, **kwargs)
    return f


def _work(unsanitized_collection, collection_model, items_plural):

    def __main():
        ok and __normalize_names()
        ok and __normalize_values()
        if ok:
            return __flush()

    def __flush():
        one_of_these = _SanitizedCollection()
        for k in collection_model:
            setattr(one_of_these, k, unsanitized_collection[k])
        return one_of_these

    def __normalize_values():

        def listener(template, ** kwargs):  # EXPERIMENTAL interface
            kwargs['variable_moniker'] = "'{}'".format(k)
            kwargs['actual_value_moniker'] = repr(act_x)  # probably OK here
            error_messages.append(template.format(** kwargs))

        loop_ok = True
        error_messages = []
        k = None
        act_x = None
        for (k, pat_x) in collection_model.items():
            act_x = unsanitized_collection[k]
            _local_ok = pat_x(act_x, listener)
            if not _local_ok:
                loop_ok = False

        if not loop_ok:
            raise _my_exception('. '.join(error_messages))

    def __normalize_names():

        missing = None
        for k in collection_model:
            if k in unsanitized_collection:
                continue
            if missing is None:
                missing = []
            missing.append(k)

        if missing is not None:
            _ = '({})'.format(', '.join(missing))
            raise _my_exception('missing required {}: {}', items_plural, _)

    ok = True  # for now always true b.c we always raise, but this could cnge
    return __main()


def regex_based_validator(s):
    import re
    rx = re.compile(s)

    def f(s, listener):
        _ = rx.search(s)
        if _ is None:
            listener(
                    '{variable_moniker} must match {pattern_moniker} '
                    '(had: {actual_value_moniker})',
                    pattern_moniker=rx.pattern,
                    )
            return _NOT_OK
        else:
            return _OK
    return f


class _SanitizedCollection:

    def __iter__(self):
        return self.__dict__.__iter__()

    def __getitem__(self, k):
        return getattr(self, k)


def _my_exception(msg, *items):
    from upload_bot.run import Exception as _MyException
    return _MyException(msg, *items)


_NOT_OK = False
_OK = True


# == EXPERIMENT
class _SelfAsCallableModule:

    def __call__(self, x):
        return _SELF(x)

    @property
    def regex_based_validator(self):
        return regex_based_validator

    @property
    def _collectioner_via_collection_model(self):  # #testpoint (yuck!)
        return _collectioner_via_collection_model


sys.modules[__name__] = _SelfAsCallableModule()
# == END EXPERIMENT


if '__main__' == __name__:

    # == BEGIN #[#024] (they don't make it easy)
    import os
    path = os.path
    import sys
    sub_sub_project_dir = path.dirname(path.abspath(__file__))
    project_dir = path.dirname(path.dirname(sub_sub_project_dir))
    a = sys.path
    if sub_sub_project_dir != a[0]:
        raise Exception('sanity')
    a[0] = project_dir
    # == END

    col = _SELF(os.environ)
    o = print
    o('# (DO NOT PUT THIS INFORMATION INTO VERSION CONTROL)')
    o('# (OR OTHERWISE INSECURE LOCATION)')
    for k in col:
        o("export {}={}".format(k, repr(col[k])))


# #born.
