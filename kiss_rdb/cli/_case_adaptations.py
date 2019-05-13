"""
DISCUSSION

for now, this is architected to make "absolute contact" as a sort of
specification assertion of what metadata is available (even though for now
we don't use all the metadata.)
"""


def WHINE_ABOUT(echo, dim_pool):
    # dim_pool = "diminishing pool"
    _type = dim_pool.pop('input_error_type')
    _these[_type](echo, **dim_pool)


def _attribute_value_error(
        echo,
        reason,
        attribute_name,
        unsanitized_attribute_value,
        suggestion_sentence_phrase=None,
        ):

    def f():  # (Case830)
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
        did_reach_end_of_stream,
        lineno,
        line,
        ):

    echo(reason)  # (Case818)


def _collection_not_found(
        echo,
        reason,
        ):

    echo(reason)  # (Case812)


_these = {
        'attribute_value_error': _attribute_value_error,
        'not_found': _not_found,
        'collection_not_found': _collection_not_found,
        }


# #abstracted.
