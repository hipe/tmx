def notecard_via_definition(identifier_string, core_attributes, listener):

    dct = validate_and_normalize_core_attributes_(
        identifier_string, core_attributes, listener)

    if dct is None:
        return

    return _Notecard(identifier_string=identifier_string, **dct)


def validate_and_normalize_core_attributes_(
        identifier_string, core_attributes, listener):

    # == validate against an allow-list (implicity for now) and default None's

    dct = _normalize_core_attribute_names(**core_attributes)  # :#here1

    # == hard-coded validations

    def fail(msg):
        def lineser():
            yield f"in '{identifier_string}', {msg}"
        listener('error', 'expression', 'entity_has_invalid_composition', lineser)  # noqa: E501

    # setup
    has_parent = dct['parent'] is not None
    has_previous = dct['previous'] is not None
    has_natty_key = dct['natural_key'] is not None
    has_heading = dct['heading'] is not None
    has_body = dct['body'] is not None

    has_parent_or_previous = has_previous or has_parent

    # mutual exclusivity: natural key vs heading
    if has_natty_key:
        if has_heading:
            return fail("can't have both natural_key and heading")
        dct['heading_is_natural_key'] = True
        dct['heading'] = dct.pop('natural_key')
    else:
        if not (has_heading or has_parent_or_previous):
            return fail("when no parent or previous, must have heading or natural_key")  # noqa: E501
        dct['heading_is_natural_key'] = False
        dct.pop('natural_key')

    # conditional requirement: :[#883.2]
    if not (has_parent_or_previous or has_heading or has_natty_key):
        return fail('notecards with no parent or previous must have heading')

    # mutual exclusivity: can't have both parent and previous
    if has_parent and has_previous:
        return fail("can't have both previous and parent")

    # required field: body
    if not has_body:
        return fail("body cannot be none (for now)")

    # ad-hoc enum
    if (s := dct['hierarchical_container_type']) is not None:
        if s != 'document':
            return fail("for now the only hierarchical_container_type is 'document' (had {s!r})")  # noqa: E501

    # == end hard-coded validations
    return dct


def _normalize_core_attribute_names(  # sort of #[#022] wish for strong types?
        parent=None,
        previous=None,
        natural_key=None,
        hierarchical_container_type=None,
        heading=None,
        document_datetime=None,
        body=None,
        children=None,
        next=None,
        annotated_entity_revisions=None,
        ):

    """this may look like it doesn't do anything but if you don't have this

    as a check then for example the user could write a field called
    `identifier_string` that overwrites (or doesn't) the actual identifier
    string. AFTER doing this check we can munge business & non business fields

    Furthermore this populates not-present elements with None which is
    something that is assumed further downstream at #here1
    """

    if children is not None and not isinstance(children, tuple):
        assert(isinstance(children, list))
        children = tuple(children)

    return {
            'parent': parent,
            'previous': previous,
            'natural_key': natural_key,
            'hierarchical_container_type': hierarchical_container_type,
            'heading': heading,
            'document_datetime': document_datetime,
            'body': body,
            'children': children,
            'next': next,
            'annotated_entity_revisions': annotated_entity_revisions,
            }


class _Notecard:

    def __init__(
            self, parent, previous,
            hierarchical_container_type, identifier_string,
            heading_is_natural_key, heading, document_datetime,
            body, children, next, annotated_entity_revisions):

        self.parent_identifier_string = parent
        self.previous_identifier_string = previous
        self.hierarchical_container_type = hierarchical_container_type
        self.identifier_string = identifier_string
        self.heading_is_natural_key = heading_is_natural_key  # not used yet..
        self.heading = heading
        self.document_datetime = document_datetime
        self.body = body
        self.children = children
        self.next_identifier_string = next
        self.annotated_entity_revisions = annotated_entity_revisions

    def to_dictionary_two_deep(self):
        core_attrs = self.to_core_attributes()
        return {
                'identifier_string': self.identifier_string,
                'core_attributes': core_attrs}

    def to_core_attributes(self):
        def o(k, attr=None):
            x = getattr(self, (attr or k))
            if x is None:
                return
            dct[k] = x
        dct = {}
        o('parent', 'parent_identifier_string')
        o('previous', 'previous_identifier_string')
        o('hierarchical_container_type')

        if self.heading_is_natural_key:
            dct['natural_key'] = self.heading
        else:
            o('heading')

        o('document_datetime')
        o('body')
        o('children')
        o('next', 'next_identifier_string')
        o('annotated_entity_revisions')
        return dct

# #history-A.1: it becomes doubly-linked list
# #abtracted
