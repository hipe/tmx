"""(this module is a more specific thing implemented as a more general thing:)

sepcifically it exists only to:

    - serve as an abstraction layer (separation of concerns) between
      the part that reads environment variables and the rest of the system
      (which need not be aware of this implementation detail.)

    - suggest an upgrade path if ever we wanted to do some kind of more
      formalized config solution that did some combination of reading from
      files and from the environment.

    - provide an early warning if we did not set some required value,
      which is preferable to more happenstance, later warnings

more generally:

    - since all elements are required for now, at its essence all this is
      is a collection of name-value pairs, whose values are regexes. this
      can be used as a "model" to validate the actual against the expected.

    - as such the bulk of this module tries to act ignorant of its
      specific application.

    - a side benefit of the above is that we can test behavior without
      hard-wiring test specifics to business specifics.
"""


def SELF(unsanitized_collection):
    """the only public entrypoint to this module...

    raises exception if something's missing, otherwise results in
    a collection struct with properties named after the requisite names.
    """

    global SELF  # redefine selfsame function on first call!

    def SELF(unsanitized_collection):
        return collectioner(unsanitized_collection)  # #hi.

    o = regex_based_validator
    collectioner = _collectioner_via_collection_model({
        'BOT_USER_OATH_ACCESS_TOKEN': o('^xoxb-[0-9]+-[A-Za-z0-9]+$'),
        },
        items_plural='environment variables',
        )

    return SELF(unsanitized_collection)


def _collectioner_via_collection_model(collection_model, **kwargs):
    # #testpoint
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
    from upload_bot import Exception as _MyException
    return _MyException(msg, *items)


_NOT_OK = False
_OK = True


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

    col = SELF(os.environ)
    o = print
    o('# (DO NOT PUT THIS INFORMATION INTO VERSION CONTROL)')
    o('# (OR OTHERWISE INSECURE LOCATION)')
    for k in col:
        o("export {}={}".format(k, repr(col[k])))


# #born.
