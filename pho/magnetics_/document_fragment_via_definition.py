

def document_fragment_via_definition(
        listener,
        identifier_string,
        core_attributes,
        ):

    # == validation that causes runtime error implicitly

    dct = _normalize_core_attribute_names(**core_attributes)

    # == hard-coded validations

    nat_key = dct.pop('natural_key')
    heading = dct.pop('heading')

    if nat_key is None:
        if heading is None:
            cover_me('probably OK but cover')
        else:
            heading_is_natural_key = False
            use_heading = heading
    elif heading is None:
        heading_is_natural_key = True
        use_heading = nat_key
    else:
        cover_me("can't have both natural_key and heading")

    body = dct.pop('body')
    if body is None:
        cover_me("body cannot be none")

    # == end hard-coded validations

    return _DocumentFragment(
            identifier_string,
            heading=use_heading,
            heading_is_natural_key=heading_is_natural_key,
            body=body,
            **dct
            )


def _normalize_core_attribute_names(  # #[#008.D]
        parent=None,
        natural_key=None,
        heading=None,
        body=None,
        previous=None,
        ):

    """this may look like it doesn't do anything but if you don't have this

    as a check then for example the user could write a field called
    `identifier_string` that overwrites (or doesn't) the actual identifier
    string. AFTER doing this check we can munge business & non business fields
    """

    return {
            'parent': parent,
            'natural_key': natural_key,
            'heading': heading,
            'body': body,
            'previous': previous,
            }


class _DocumentFragment:  # #testpoint

    def __init__(
            self,
            identifier_string,
            heading,
            heading_is_natural_key,
            body,
            parent,
            previous,
            # next ..
            ):

        self.identifier_string = identifier_string
        self.parent_identifier_string = parent
        self.heading = heading
        self.heading_is_natural_key = heading_is_natural_key  # not used yet..
        self.body = body
        self.previous_identifier_string = previous


def cover_me(msg=None):
    raise Exception('cover me' if msg is None else f'cover me: {msg}')

# #abtracted
