# at #birth, covered by a client. experimental public API


def THROWING_LISTENER(*a):
    error_or_info, shape, *chan_tail, payloader = a
    if 'info' == error_or_info:
        return
    assert('error' == error_or_info)
    assert('structure' == shape)  # ..

    separate_with_spaces = []

    if len(chan_tail):
        _what_kind = chan_tail[0].replace('_', ' ')  # "input error"
        separate_with_spaces.append(f'{_what_kind}:')

    sct = payloader()
    if 'reason' in sct:
        use_reason = sct['reason']

        # (we are ignoring lots of metadata. elsewhere for this.)
    else:
        _these = ', '.join(sct.keys())
        use_reason = f"(unknown reason, keys: ({_these}))"

    separate_with_spaces.append(use_reason)

    _message = ' '.join(separate_with_spaces)
    raise _Exception(_message)


def COLLECTION_VIA_DIRECTORY(directory, listener=THROWING_LISTENER):

    schema = SCHEMA_VIA_COLLECTION_PATH(directory, listener)
    if schema is None:
        return

    from .magnetics_ import collection_via_directory

    return collection_via_directory.collection_via_directory_and_schema(
            collection_directory_path=directory,
            collection_schema=schema,
            )


def SCHEMA_VIA_COLLECTION_PATH(collection_path, listener=THROWING_LISTENER):
    from .magnetics_ import (
        schema_via_file_lines,
        )
    return schema_via_file_lines.SCHEMA_VIA_COLLECTION_PATH(
        collection_path, listener)


class _Exception(Exception):
    pass


# #birth.
