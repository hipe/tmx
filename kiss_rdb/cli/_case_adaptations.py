"""
DISCUSSION

for now, this is architected to make "absolute contact" as a sort of
specification assertion of what metadata is available (even though for now
we don't use all the metadata.)
"""


def WHINE_ABOUT(echo, channel_tail, dim_pool):
    # dim_pool = "diminishing pool"

    if 'input_error_type' in dim_pool:
        # (the presence of this component does not necessarily imply
        #  `error_category == "input_error"` as of #history-A.1)

        use_error_type = dim_pool.pop('input_error_type')
    else:
        raise Exception(f'Cover me wahoo: {channel_tail[0]}')

    _these[use_error_type](echo, **dim_pool)


def _attribute_value_error(
        echo,
        reason,
        attribute_name,
        unsanitized_attribute_value,
        suggestion_sentence_phrase=None,
        ):

    def f():  # (Case6067)
        yield f'Could not set {repr(attribute_name)}'

        if len(unsanitized_attribute_value) <= 22:  # see 22
            yield f' to {repr(unsanitized_attribute_value)}'

        yield f' because {reason}.'

    _pieces = tuple(f())
    echo(''.join(_pieces))
    if suggestion_sentence_phrase is not None:
        echo(f'{suggestion_sentence_phrase}.')  # ..


def _not_found(
        echo,
        reason,
        identifier_string,
        did_traverse_whole_file,
        did_reach_end_of_stream=None,
        lineno=None,
        line=None,
        ):

    echo(reason)  # (Case6064)


def _collection_not_found(
        echo,
        reason,
        ):

    echo(reason)  # (Case5918)


_these = {
        'attribute_value_error': _attribute_value_error,
        'not_found': _not_found,
        'collection_not_found': _collection_not_found,
        }


# #history-A.1
# #abstracted.
