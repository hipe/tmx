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

from dataclasses import dataclass
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

    form_values = {k: v for k, v in hiddens}  # NOTE new in this iteration

    lines = asset_function(
            FORMAL_ATTRIBUTES=violation.values(),
            action='#',
            form_values=form_values,
            listener=None,
            WHAT=None)
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
        FORMAL_ATTRIBUTES,  # an iterator (or tuple)
        action='#',  # a string for the FORM html element attribute value.
        form_values=None,  # use the "use" keys and values as strings
        listener=None,  # will be used to complain about missing req'd hiddens
        WHAT=None,  # experimental mutable structure that holds UI messages
        margin='',
        indent='  '):

    """EXPERIMENT in form generation.."""
    # (the above appears in a CLI help form)

    general_message_lines = tms = None  # tms = targeted message structures
    if WHAT:
        general_message_lines, tms = WHAT

    # In a first pass, partition the hiddens from the non-hiddens
    hiddens = []
    non_hiddens = []

    # (currently single endpoint, namespaces getting munged #here4)
    if '#' != action:
        hiddens.append(_HiddenFormElement('action', action))

    form_values_pool = form_values.copy() if form_values else _empty_dict

    form_componenter = _build_form_componenter(tms, listener)

    attr_via_fpn = {}  # (fpn = form parameter name.
    for attr in FORMAL_ATTRIBUTES:

        # Determine existing value with the form values param
        fpn = attr.identifier_for_purpose(_FORM_KEY_PURPOSE)
        attr_via_fpn[fpn] = attr  # keep these keyed to fpm for later use

        ev = form_values_pool.pop(fpn, None)
        # (ev = existing form value)

        fc = form_componenter(ev, attr)
        if fc is None:
            continue
        (hiddens if fc.is_hidden_form_element else non_hiddens).append(fc)

    assert non_hiddens
    if form_values_pool:
        xx(f"oops: non-used form values: {tuple(form_values_pool.keys())!r}")

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
        for plain_line in (general_message_lines or ()):
            yield _html_escape(plain_line)

        # Attribute-specific messages that didn't get used yet :#here3 #todo
        for fpn, emi_tails in (tms.items() if tms else ()):
            attr = attr_via_fpn[fpn]
            for html in _htmls_via_emission_tails(emi_tails, attr, do_express_subject=True):
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
        for line in _TD_lines(stem, ch3_margin, ch4_margin, indent):
            yield line
        yield f'{ch2_margin}</tr>\n'

        if (scts := stem.message_structures):
            yield f'{ch3_margin}<tr><td class="SOMETHING_ABOUT_HANGING_INFO" colspan="2"><ul>\n'
            attr = attr_via_fpn[stem.form_element_name]
            for html in _htmls_via_emission_tails(scts, attr):
                yield f'{ch4_margin}<li>{html}</li>\n'
            yield f'{ch3_margin}</ul></td></tr>\n'

    if True:
        yield f'{ch2_margin}<tr>\n'
        yield f'{ch3_margin}<td colspan="2" class="the_buttons_tabledata">\n'
        yield f'{ch4_margin}<input type="submit" value="Submit">\n'
        yield f'{ch3_margin}</td>\n'
        yield f'{ch2_margin}</tr>\n'

    yield f'{ch_margin}</table>\n'
    yield f'{margin}</form>\n'


def _TD_lines(stem, ch3_margin, ch4_margin, indent):
    """(be super cute with when you break '<td></td>' into multiple lines)"""

    pcs = [ch3_margin, '<td>']
    itr = stem.to_html_lines(ch4_margin, indent)
    line = next(itr, None)
    if line:
        if '\n' == line[-1]:  #..
            pcs.append('\n')
            yield ''.join(pcs)
            pcs.clear()
            pcs.append(ch3_margin)
            while line:
                yield line
                line = next(itr, None)
        else:
            assert not next(itr, None)
            pcs.append(line)
    pcs.append('</td>\n')
    yield ''.join(pcs)


def _htmls_via_emission_tails(emi_tails, attr, do_express_subject=False):
    for emi_tail in emi_tails:
        for html in _htmls_via_emission_tail(emi_tail, attr, do_express_subject):
            yield html


def _htmls_via_emission_tail(emi_tail, attr, do_express_subject):
    category, predicate_strings = emi_tail
    del(category)  # one day we might allow selectively filtering out messages

    subject_string = attr.identifier_for_purpose(_LABEL_PURPOSE)

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


def _build_form_componenter(tms, listener):
    # mcvn = model class via name

    def form_componenter(ev, fa):

        # Foreign key references are hidden (for now)
        if fa.is_foreign_key_reference:
            return form_component_for_foreign_key(ev, fa)

        # Primary keys get nothing on CREATE, pass-thru on UPDATE
        if fa.is_primary_key:
            if ev is None:
                return
            return hidden_form_component(ev, fa)

        # Now that you know it's not hidden, we have to resolve a rendering strat
        # (before #history-C.5 we used to do this lazily at render time)
        cr = resolve_component_renderer(fa)
        msg_scts = (tms and tms.pop(form_key(fa), None))  # :#here3
        return _NonHiddenFormElement(fa, cr, ev, msg_scts)

    def form_component_for_foreign_key(ev, fa):
        if ev is None:
            return _explain_FKs_must_be_provided(listener, fpn())
            # (confusingly, render a form that cannot be used :#here2)
        return hidden_form_component(ev, fa)

    def hidden_form_component(ev, fa):
        return _HiddenFormElement(form_key(fa), ev)

    def form_key(fa):
        return fa.identifier_for_purpose(_FORM_KEY_PURPOSE)

    resolve_component_renderer = _build_component_rendererer(
            tms, listener)

    return form_componenter


@dataclass
class _NonHiddenFormElement:
    formal_attribute:object
    component_renderer:callable
    existing_value:object = None
    message_structures:tuple = None

    def to_html_lines(self, margin, indent):
        return self.component_renderer(self, margin, indent)

    @property
    def attribute_label(self):
        return self.formal_attribute.identifier_for_purpose(_LABEL_PURPOSE)

    @property
    def form_element_ID(self):
        return self._formal_name

    @property
    def form_element_name(self):
        return self._formal_name

    @property
    def _formal_name(self):  # legacy name
        return self.formal_attribute.identifier_for_purpose(_FORM_KEY_PURPOSE)

    is_hidden_form_element = False


# == BEGIN XXX

def EXPERIMENTAL_populate_form_values_(ent, fe, listener):
    # NOTE we're really not sure we want to "know" about entities.
    # wouldn't it be better to just take dicts?
    # NOTE keeping this close to render-related derivations (below) for now

    for fa in fe.to_formal_attributes():
        attr = fa.identifier_for_purpose(_DATACLASS_FIELD_NAME_PURPOSE)
        mixed = getattr(ent, attr)
        if mixed is None:
            continue
        fpn = fa.identifier_for_purpose(_FORM_KEY_PURPOSE)
        # we endcode it XXX elsewhere
        yield fpn, mixed

# == END XXX


def _build_component_rendererer(tms, listener):
    # at #history-C.4 "component renderer" not "expression strategy" (reasons)

    def resolve_component_renderer(fa):
        base_type = fa.type_macro.LEFTMOST_TYPE
        base_func = renderer_via_base_type[base_type]  # ..
        mixed = base_func(fa)
        if isinstance(mixed, str):
            return getattr(_self_module(), mixed)
        assert callable(mixed)
        return mixed

    renderer_for, renderer_via_base_type = _build_keyed_decorator()

    @renderer_for('text')
    def _(fa):
        tm = fa.type_macro
        if tm.kind_of('paragraph'):
            return 'render_as_textarea'

        if tm.kind_of('line'):
            return 'render_as_input_type_text'  # ..

        return 'render_as_input_type_text'  # ..

    @renderer_for('int')
    def _(_):
        return 'render_as_input_type_text'  # ..

    @renderer_for('tuple')
    def _(fa):
        tm = fa.type_macro
        orig = tm.generic_alias_origin_

        if not orig:
            xx("does this ever happen?")

        assert tuple == orig  # because of something in [#872.H]
        arg, = tm.generic_alias_args_  # ..
        if str == arg:
            # like "paragraph" but by dataclass not recinf (experimental)
            return 'render_as_textarea'
        if isinstance(arg, str):
            # Assume this is a "fent" name [#872.H]
            return _fall_back_to_view_only_component_renderer(fa)

        xx(f"unhandled tuple parameterization {tm.string!r}")

    @renderer_for('instance_of_class')
    def _(fa):
        return 'render_as_input_type_text'  # away soon

    return resolve_component_renderer


def _fall_back_to_view_only_component_renderer(fa):
    """If for whatever reason we want to render a component of the
    entity as view-only, here we fall-back to the generated entity
    VIEW facilities. (Our founding reason was because making a
    one-to-many UI component was too hard/out of scope.)
    """

    from kiss_rdb.storage_adapters.html.view_via_formal_entity import \
            component_renderer_via_formal_attribute as func

    vendor_component_renderer = func(fa, attr='existing_value')

    def my_component_renderer(stem, margin, indent):
        return vendor_component_renderer(stem, margin, indent)
    return my_component_renderer



def render_as_textarea(stem, margin, indent):
    attrs = _render_form_el_attrs(stem, rows=4, cols=50)  # ..

    # XXX see:
    """Note: spaces between these two: "<textarea></textarea>" will show up
    as the text value of the input element. We are fine-tuning to what
    extent this is true for the whitespace before and/or after existing non-ws
    content. :#here5
    Since we will be avoiding putting leading margin ahead of "</textarea>"
    for the above reason, we will also do so for the opening tag, so that
    they line up vertically.
    """

    pcs = []
    itr = _html_lines_via_existing_value(stem.existing_value, margin)
    line = next(itr, None)
    if not line:
        pcs.append(margin)
    pcs.append(f'<textarea {attrs}>')
    if line:
        pcs.append('\n')
        yield ''.join(pcs)
        pcs.clear()
        while line:
            assert '\n' == line[-1]
            yield line
            line = next(itr, None)

    pcs.append('</textarea>\n')
    yield ''.join(pcs)


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

# == END copy-pasted list


def render_as_placeholder_or_IDK(stem, margin, indent):
    yield "<p>WAT DO</p>\n"


# == Explanations

def _explain_FKs_must_be_provided(listener, fpn):
    def lines():
        yield "is required to generate form."
    listener('error', 'expression', 'about_field',
             fpn, 'missing_required_hidden', lines)


# ==

class _HiddenFormElement:  # :+#stem

    # NOTE gonna wrap the whole formal attribute if it's useful

    def __init__(self, attribute_name, existing_value):
        assert re.match(r'^[a-zA-Z0-9_]+$', attribute_name)
        assert re.match(r'^[a-zA-Z0-9_]+$', existing_value)
        self.existing_value = existing_value
        self.attribute_name = attribute_name

    def to_html_lines(self, indent, margin):
        use_value = _encode_primitive_value(self.existing_value)
        yield (f'{margin}<input type="hidden" name="{self.attribute_name}" '
               f'value="{use_value}">\n')

    is_hidden_form_element = True


def _html_lines_via_existing_value(existing_value, margin):
    if existing_value is None:
        return

    lines = re.split('(?<=\n)(?=.)', existing_value)

    h = _html_escape_function()
    for line in lines:

        # (no leading margin: it shows up "cosmetically" in text area) #here5
        # pcs = [margin, h(line)]
        pcs = [h(line)]

        if 0 == len(line) or '\n' != line[-1]:
            pcs.append('\n')
        yield ''.join(pcs)


# ==

def _render_as_input_type(typ, stem, margin, ind):
    def kw():
        ev = stem.existing_value
        if ev is None:
            return
        yield 'value', _encode_primitive_value(ev)
    kw = {k: v for k, v in kw()}
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


def _encode_primitive_value(mixed):
    if isinstance(mixed, str):
        return _html_escape(mixed)
    xx("this is straightforward (probably) but not covered - {type(mixed)}")


def _html_escape(s):
    return _html_escape_function()(s)


def _html_escape_function():
    from html import escape as func
    return func


# :#here4 :[#872.C]: #feat:namespace_for_CGI_params munging namespaces

def _build_keyed_decorator():
    def for_which(key):
        def decorator(func):
            dct[key] = func
        return decorator
    dct = {}
    return for_which, dct


# ==

def _self_module():
    memo = _self_module
    if memo.value is None:
        from sys import modules as modz
        memo.value = modz[__name__]
    return memo.value


_self_module.value = None


def xx(msg=None):
    head = "finish this/cover this"
    raise RuntimeError(''.join((head, *((': ', msg) if msg else ()))))


_LABEL_PURPOSE = 'label', 'UI_LABEL_PURPOSE'
_FORM_KEY_PURPOSE = 'key', 'HTML_FORM_PARAMETER_NAME_PURPOSE'
_DATACLASS_FIELD_NAME_PURPOSE = ('DATACLASS_FIELD_NAME_PURPOSE_',)
_empty_dict = {}


if '__main__' == __name__:
    from sys import stdin, stdout, stderr, argv
    exit(_CLI(stdin, stdout, stderr, argv))

# #history-C.5
# #history-C.4
# #history-C.3 enter "identifier for purpose"; formal attributes not collections
# #history-C.2
# #history-C.1
# #born
