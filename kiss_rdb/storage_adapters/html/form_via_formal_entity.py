"""
NOTES about implementation:
- The main isomorphisms between formal entity and html form:
  - The overall premise is that there's a one-to-one mapping between a formal
    entity's formal attributes and form elements; with mappings between the
    "typology" of formal attributes and the various form elements that exist
    in the html specification.
  - The above pattern has some interesting refinements, specifically around
    primary keys and foreign keys. see below "Dicussion of Foreign Keys" and
    "Disucssion of Primary Keys".
- Easy things easy, hard things possible:
  - We like to render our forms in tables but that shouldn't be a fixed choice.
    The API should have exposures or upgrade paths to go lower-level.
  - We like the idea of the client being able to configure how any one or more
    particular elements are rendered, arbitrarily being able to access all
    the metadata that would go into the expression of that formal/actual
    attribute for use in the client's custom rendering.
- Boring brass tacks:
  - The form's 'action' will have to be an option. It's a crucial part of
    a form, but it's not an interesting part of our work here.
  - We will soon have to give some thought about how this will be different
    for UPDATE-ing an existing entity vs. CREATE-ing a new one. Probably we
    will be able to pass "existing_entity" as an optional parameter. That
    entity may or may not have an EID. It could be that we use an entity _not_
    having an EID (somehow?) to indicate that it's a WIP entity.
  - Generally the top-down order on the html page of the element expression
    will isomorph with the formal order of the attributes BUT:
    - hidden form elements have no visual representation so they do not
      get rendered inside the table; they get rendered together before the
      table (could be after too).


Discussion of Foreign Keys:

Foreign keys won't typically have a straightforward expression in the form:
One does not simply express the formal foreign key with a text field to allow
the user to enter in the EID of the remote entity associated with the entity
you are creating/editing. (If you *did* want this, we *do* want such an
expression to be possible, however.)

Rather, what will be the most common real-world use-case (we anticipate) of
foreign keys will be where the foreign key is part of a one-to-many association
where the entity we are creating/updating is the on the "many" side,
and the foreign key
value is already known and not editable. For this common case, we plan
on using hidden form fields.

In cases both of CREATE-ing a new entity and UPDATE-ing an existing entity,
the above generality will hold: the foreign key value will be known and hidden
and not editable through the interaction (although essential, effectively
a required value).


Discussion of Primary Keys:

For editing an existing entity, we (axiomatically, almost tautologically)
don't ever want to allow the user to change the primary key value. By the
very definition of "identity", if you are changing the primary key value then
you aren't editing an existing entity, you are doing something else.

(Note we will take an exception to this around the "enum-like collection"
we imagine using; where we use natural keys and a relatively small number
of values in the collection, to be enum-like. In such cases you will probably
want to be able to make refinements to the primary keys (which are natural keys
and semantic).)

(Another note, we didn't want to but we're expecting that supporting
"compound keys" will be at thing..)

As such, when CREATE-ing the typical entity, no primary key value is passed
from client to server at all, and when UPDATE-ing an existing entity; the
primary key will be passed back and forth as a hidden field.
"""

import re


def _CLI(sin, sout, serr, argv):
    # (moved here from another file at #history-C.1)

    def usage_lines():
        yield "usage: <command-to-generate-sexp-lines> | {{prog_name}} -file - [opts ..]\n"
        yield "usage: {{prog_name}} -file SEXP_FILE [opts ..]\n"  # [#857.13] #608.20]

    def description(invo):
        docstring = asset_function.__doc__
        for line in invo.description_lines_via_docstring(docstring):
            yield line
        yield "Options:\n"
        yield "  -action ACTION        The html form element attribute value.\n"
        yield "                        Probably required, but is \"option\" for readability.\n"
        yield "  -omit FATTR_NAME      Don't express this formal attribute in the form.\n"
        yield "  -hidden NAME=VALUE    To build the form may require some hidden form vars,\n"
        yield "                        e.g. an existing foreign key name/value (e.g. a parent).\n"
        yield "                        Pass the option multiple times for multiple NAME=VALUE pairs.\n"

    # (variables we need because we parse in two passes)
    prog_name_long = argv[0]
    asset_function = html_form_via_SOMETHING_ON_THE_MOVE_
    from script_lib.via_usage_line import build_invocation

    # Parse the first part
    invo = build_invocation(
            sin, sout, serr, argv,
            usage_lines=tuple(usage_lines()),
            docstring_for_help_description=description)
    rc, pt = invo.returncode_or_parse_tree()
    if rc is not None:
        return rc
    dct = pt.values
    del pt
    path = dct.pop('sexp_file', None)
    stack = invo.argv_stack
    if len(stack):
        assert path == stack[-1]  # ick #todo
        stack.pop()
    use_argv = (prog_name_long, *reversed(stack))
    assert not dct

    # Parse the second part
    # At writing, this syntactic macro is not yet supported:
    # usage_line = 'usage: {{prog_name}} [-hidden=PAIR [-hidden=PAIR [..]]]\n'

    refinements_on_hidden_parameter = \
        (('value_constraint', _value_constraint_on_hidden_parameter), \
         ('value_normalizer', _value_normalizer_on_hidden_parameter))

    refinements_on_omit_parameter = \
        (('value_constraint', _value_constraint_on_omit_parameter), \
         ('value_normalizer', _value_normalizer_on_omit_parameter))

    usage_line = ('usage: {{prog_name}} [-action=ACTION] '
                  '[-hidden=PAIR] [-omit=FATTR_NAME]\n')

    rc, pt = build_invocation(
            sin, sout, serr, use_argv, (usage_line,),
            docstring_for_help_description=description,
            parameter_refinements={
                '-hidden': refinements_on_hidden_parameter,
                '-omit': refinements_on_omit_parameter,
            }).returncode_or_parse_tree()

    if rc is not None:
        return rc

    dct = pt.values
    action = dct.pop('action', None)
    hiddens = dct.pop('hidden', ())
    omits = dct.pop('omit', ())
    assert not dct

    # == (done parsing)

    if path:
        assert sin.isatty()
        fh = open(path)
    else:
        assert not sin.isatty()
        fh = sin

    with fh:  # #here1
        from kiss_rdb.magnetics_.abstract_schema_via_sexp import \
                abstract_schema_via_sexp_lines_ as func
        abs_sch = func(fh)  # listener one day

    if abs_sch is None:
        return 3

    for last_key in abs_sch.TO_FORMAL_ENTITY_KEYS():
        pass
    use_fent = abs_sch[last_key]

    violation = use_fent._columns
    for omit_k in omits:
        violation.pop(omit_k)

    coll = _DUMMY_COLL(use_fent)

    form_values = {k: v for k, v in hiddens}  # NOTE new in this iteration

    lines = html_form_via_SOMETHING_ON_THE_MOVE_(
            coll=coll,
            action='#',
            form_values=form_values,
            listener=None,
            WHAT=([], {}))
    w = sout.write
    for line in lines:
        w(line)
    return 0


def _value_constraint_on_hidden_parameter(token):
    md = re.match(r'(?P<name>[a-zA-Z_]+)=(?P<val>[^=]*)$', token)
    if md:
        return ('value_constraint_memo', md)
    def reason():
        yield 'early_stop_reason', 'failed_value_constraint', '<hidden-var>'
        yield 'stderr_line', f"must look like 'foo_bar=baz': {token!r}\n"
        yield 'returncode', 123
    return 'early_stop', reason


def _value_normalizer_on_hidden_parameter(
        existing_value, token, value_constraint_memo):
    name, value = value_constraint_memo.groups()
    if existing_value:
        return 'use_value', (*existing_value, (name, value))
    return 'use_value', ((name, value),)


def _value_constraint_on_omit_parameter(token):
    md = re.match(r'(?P<fattr_name>[a-z_]+)$', token)  # ..
    if md:
        return ('value_constraint_memo', md)
    def reason():
        yield 'early_stop_reason', 'failed_value_constraint', '<fattr-name>'
        yield 'stderr_line', f"must look like 'foo_bar': {token!r}\n"
        yield 'returncode', 123
    return 'early_stop', reason


def _value_normalizer_on_omit_parameter(
        existing_value, token, value_constraint_memo):
    fattr_name = value_constraint_memo['fattr_name']
    if existing_value:
        return 'use_value', (*existing_value, fattr_name)
    return 'use_value', (fattr_name,)


def html_form_via_SOMETHING_ON_THE_MOVE_(
        coll,  # experimentally expanded from just a fent
        action='#',  # a string for the FORM html element attribute value.
        form_values=None,  # use the "use" keys and values as strings
        listener=None,  # will be used to complain about missing req'd hiddens
        WHAT=None,  # experimental mutable structure that holds UI messages
        margin='',
        indent='  '):

    """EXPERIMENT in form generation.."""
    # (the above appears in a CLI help form)

    # In a first pass, partition the hiddens from the non-hiddens
    hiddens = []
    non_hiddens = []

    # (currently single endpoint, namespaces getting munged #here4)
    if '#' != action:
        hiddens.append(_HiddenFormElement('action', action))

    for stem in _stems(coll, form_values, listener, WHAT):
        (hiddens if stem.is_hidden_form_element else non_hiddens).append(stem)

    assert non_hiddens

    # Precompute some things used in loops before outputting any html
    def do(i):
        return f"{margin}{indent * i}"
    ch_margin, ch2_margin, ch3_margin, ch4_margin = (do(i) for i in range(1, 5))
    h = _html_escape_function()

    # Open the form before opening the table (hiddens don't go in the table)

    if '#' == action:
        _ = '#'
    else:
        _ = '/'  # #here4

    yield (f'{margin}<form '
           'method="post" '  # for now, hard-coded
           f'action="{_}" '
           'class="kiss-generated">\n')

    # Do the hiddens before opening the table
    for hidden in hiddens:
        for line in hidden.to_html_lines(ch_margin, indent):
            yield line

    # Open the table before doing each visible element (row)
    yield f'{ch_margin}<table class="SOMETHING_SPECIFIC_SOON">\n'

    # Put any general messages at the top (like messages from #here2)

    def htmls():
        # General messages intended as general messages
        for plain_line in (WHAT or _empty_what())[0]:
            yield _html_escape(plain_line)

        # Attribute-specific messages that didn't get used yet :#here3 #todo
        for k, emi_tails in (WHAT or _empty_what())[1].items():
            for html in _htmls_via_emission_tails(emi_tails, k, coll, do_express_subject=True):
                yield html

    htmls = tuple(htmls())
    if htmls:
        yield f'{ch2_margin}<tr><td colspan="2"><ul>\n'
        for html in htmls:
            yield f'{ch3_margin}<li>{html}</li>\n'
        yield f'{ch2_margin}</ul></td></tr>\n'

    for stem in non_hiddens:
        yield f'{ch2_margin}<tr>\n'
        _ = h(stem.attribute_label)
        yield f'{ch3_margin}<th><label for="{stem.form_element_ID}">{_}</label></th>\n'
        yield f'{ch3_margin}<td>\n'
        for line in stem.to_html_lines(ch4_margin, indent):
            yield line
        yield f'{ch3_margin}</td>\n'
        yield f'{ch2_margin}</tr>\n'

        if (scts := stem.message_structures):
            yield f'{ch3_margin}<tr><td class="SOMETHING_ABOUT_HANGING_INFO" colspan="2"><ul>\n'
            for html in _htmls_via_emission_tails(scts, stem.snake_name, coll):
                yield f'{ch4_margin}<li>{html}</li>\n'
            yield f'{ch3_margin}</ul></td></tr>\n'

    if True:
        yield f'{ch2_margin}<tr>\n'
        yield f'{ch3_margin}<td colspan="2">\n'
        yield f'{ch4_margin}<input type="submit" value="Submit">\n'
        yield f'{ch3_margin}</td>\n'
        yield f'{ch2_margin}</tr>\n'

    yield f'{ch_margin}</table>\n'
    yield f'{margin}</form>\n'


def _htmls_via_emission_tails(emi_tails, k, coll, do_express_subject=False):
    for emi_tail in emi_tails:
        for html in _htmls_via_emission_tail(emi_tail, k, coll, do_express_subject):
            yield html


def _htmls_via_emission_tail(emi_tail, k, coll, do_express_subject):
    category, predicate_strings = emi_tail
    del(category)  # one day we might allow selectively filtering out messages

    _ = coll.name_converter.snake_store_key_via_use_key(k)
    subject_string = _.replace('_', ' ')  # human_via ..

    def subject_string_is_already_at_head():
        pos = predicate_string.find(' ')  # or use regex meh idc
        if -1 == pos:
            return
        return subject_string == predicate_string[:pos]

    is_first = True
    for predicate_string in predicate_strings:
        if not do_express_subject:
            yes_subject = False
        elif subject_string_is_already_at_head():
            yes_subject = False
        elif is_first:
            yes_subject = True
        else:
            yes_subject = True  # or change it if you dare

        head_pcs = (subject_string,) if yes_subject else ()
        yield _html_escape(' '.join((*head_pcs, predicate_string)))


def _stems(coll, form_values, listener, WHAT):
    def monadic_nothing(_):
        pass

    # Determine existing value with the form vlaues param
    if form_values:
        any_existing_value_of = form_values.get
    else:
        any_existing_value_of = monadic_nothing

    # Determine if it has value factory with this
    _ = getattr(coll.dataclass, 'VALUE_FACTORIES', _empty_dict)
    has_value_factory = _.__contains__

    # Determine if it's the primary key with this
    store_fent = coll.abstract_entity_derived_from_store(listener=None)
    # (before #history-C.2 this used to be abstract_entity_derived_from_dataclass)

    pkfn = store_fent.primary_key_field_name
    if pkfn is None:
        is_primary_key = monadic_nothing
    else:
        def is_primary_key(k):
            return pkfn == k

    f = coll.name_converter.use_key_via_snake_store_key
    for attr in store_fent.to_formal_attributes():
        ssk = attr.column_name  # ssk = snake store key
        k = f(ssk)  # k = use key

        # If the field has a value factory, it receives no form expression
        if has_value_factory(k):
            continue
        s = any_existing_value_of(k)

        # Foreign key references are hidden
        if attr.is_foreign_key_reference:
            if s is None:
                if not listener:
                    xx(f"oops, provide value for hidden parameter {ssk!r}")
                def lines():
                    yield "is required to generate form."
                listener('error', 'expression', 'error_about_field',
                         k, 'missing_required_hidden', lines)
                # (confusingly, above is populated but not used :#here2)
                continue
                # (badly, we are rendering the form but it cannot be used #todo)
            yield _HiddenFormElement(ssk, s)
            continue

        # Primary keys get nothing on CREATE, pass-thru on UPDATE
        if is_primary_key(ssk):
            if s is None:
                continue
            yield _HiddenFormElement(ssk, s)
            continue

        # All others get visual representation, probably
        msg_scts = (WHAT or _empty_what())[1].pop(k, None)  # :#here3
        yield _NonHiddenFormElement(attr, s, msg_scts)


class _NonHiddenFormElement:

    def __init__(self, attr, existing_value=None, message_structures=None):
        self.message_structures = message_structures
        self.existing_value = existing_value
        self.formal_attribute = attr

    def to_html_lines(self, margin, indent):
        strat = self._inferred_expression_strategy
        mod = _self_module()
        func = getattr(mod, strat)
        return func(self, margin, indent)

    @property
    def attribute_label(self):
        return self._formal_name.replace('_', ' ').title()

    @property
    def form_element_ID(self):
        return self._formal_name

    @property
    def form_element_name(self):
        return self._formal_name

    @property
    def snake_name(self):
        return self._formal_name

    @property
    def _inferred_expression_strategy(self):
        return _expression_strategy_via_type_macro(self.formal_attribute.type_macro)

    @property
    def _formal_name(self):
        return self.formal_attribute.column_name

    is_hidden_form_element = False


def _expression_strategy_via_type_macro(tm):
    if tm.kind_of('text'):
        if tm.kind_of('paragraph'):
            return 'render_as_textarea'

        if tm.kind_of('line'):
            return 'render_as_input_type_text'  # ..

        return 'render_as_input_type_text'  # ..

    if tm.kind_of('int'):
        return 'render_as_input_type_text'  # ..

    if tm.kind_of('tuple'):
        if tm.kind_of('tuple[str]'):
            # like "paragraph" but by dataclass not recinf (experimental)
            return 'render_as_textarea'

    xx(f"unhandled type {tm.string!r}")


def render_as_textarea(stem, m, indent):  # m = margin
    attrs = _render_form_el_attrs(stem, rows=4, cols=50)  # ..
    yield f'{m}<textarea {attrs}>\n'
    for line in _html_lines_via_existing_value(stem.existing_value, m):
        yield line
    yield f'{m}</textarea>\n'


# == BEGIN copy-pasted list from https://www.w3schools.com/html/html_form_input_types.asp
# (this might just be a reminder (for now) that all these types are here)

def render_as_input_type_button(*_, **__):
    xx()


def render_as_input_type_checkbox(*_, **__):
    xx()


def render_as_input_type_color(*_, **__):
    xx()


def render_as_input_type_date(*_, **__):
    xx()


def render_as_input_type_datetime_local(*_, **__):
    xx()


def render_as_input_type_email(*_, **__):
    xx()


def render_as_input_type_file(*_, **__):
    xx()


def render_as_input_type_hidden(*_, **__):
    xx()


def render_as_input_type_image(*_, **__):
    xx()


def render_as_input_type_month(*_, **__):
    xx()


def render_as_input_type_number(*_, **__):
    xx()


def render_as_input_type_password(*_, **__):
    xx()


def render_as_input_type_radio(*_, **__):
    xx()


def render_as_input_type_range(*_, **__):
    xx()


def render_as_input_type_reset(*_, **__):
    xx()


def render_as_input_type_search(*_, **__):
    xx()


def render_as_input_type_submit(*_, **__):
    xx()


def render_as_input_type_tel(*_, **__):
    xx()


def render_as_input_type_text(stem, *a, **kw):
    return _render_as_input_type('text', stem, *a, **kw)


def render_as_input_type_time(*_, **__):
    xx()


def render_as_input_type_url(*_, **__):
    xx()


def render_as_input_type_week(*_, **__):
    xx()


# == END


class _HiddenFormElement:  # :+#stem

    # NOTE gonna wrap the whole formal attribute if it's useful

    def __init__(self, attribute_name, existing_value):
        assert re.match(r'^[a-zA-Z0-9_]+$', attribute_name)
        assert re.match(r'^[a-zA-Z0-9_]+$', existing_value)
        self.existing_value = existing_value
        self.attribute_name = attribute_name

    def to_html_lines(self, indent, margin):
        yield (f'{margin}<input type="hidden" name="{self.attribute_name}" '
               f'value="{self.existing_value}">\n')

    is_hidden_form_element = True


def _html_lines_via_existing_value(existing_value, margin):
    if existing_value is None:
        return

    lines = re.split('(?<=\n)(?=.)', existing_value)

    h = _html_escape_function()
    for line in lines:
        pcs = [margin, h(line)]
        if 0 == len(line) or '\n' != line[-1]:
            pcs.append('\n')
        yield ''.join(pcs)


# ==

def _render_as_input_type(typ, stem, margin, ind):
    if stem.existing_value:
        kw = {value: _html_escape(stem.existing_value)}
    else:
        kw = _empty_dict
    attrs = _render_form_el_attrs(stem, type='text', **kw)
    yield f'{margin}<input {attrs}>\n'


def _render_form_el_attrs(stem, **kw):
    return ' '.join(_attr(k, v) for (k, v) in _form_el_attr_NV_pairs(stem, kw))


def _form_el_attr_NV_pairs(stem, kw):
    if (typ := kw.pop('type', None)):
        yield 'type', typ
    yield 'id', stem.form_element_ID
    yield 'name', stem.form_element_name
    for k, v in kw.items():
        yield k, v


def _attr(k, v):
    return f'{k}="{v}"'


def _html_escape(s):
    return _html_escape_function()(s)


def _html_escape_function():
    from html import escape as func
    return func


# ==

class _DUMMY_COLL:
    def __init__(self, abs_ent):
        self._abs_ent = abs_ent
        self._NC = None

    def abstract_entity_derived_from_store(self, listener=None):
        return self._abs_ent

    @property
    def name_converter(self):
        if self._NC is None:
            self._NC = _DUMMY_NAME_CONVERTER()
        return self._NC

    dataclass = None


def _IDENTITY(x):
    return x


class _DUMMY_NAME_CONVERTER:
    def __init__(self):
        self.snake_store_key_via_use_key = _IDENTITY
        self.use_key_via_snake_store_key = _IDENTITY


# :#here4 :[#872.C]: #feat:namespace_for_CGI_params munging namespaces

# ==

def _self_module():
    memo = _self_module
    if memo.value is None:
        from sys import modules as modz
        memo.value = modz[__name__]
    return memo.value


_self_module.value = None


def _empty_what():
    memo = _empty_what
    if memo.value is None:
        memo.value = ((), _empty_dict)
    return memo.value


_empty_what.value = None


def xx(msg=None):
    head = "finish this/cover this"
    raise RuntimeError(''.join((head, *((': ', msg) if msg else ()))))


_EVENTUALLY = None  # placeholder for future logic
_empty_dict = {}


if '__main__' == __name__:
    from sys import stdin, stdout, stderr, argv
    exit(_CLI(stdin, stdout, stderr, argv))

# #history-C.2
# #history-C.1
# #born
