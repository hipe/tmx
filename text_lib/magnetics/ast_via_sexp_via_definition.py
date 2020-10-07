"""
the document object model for all strings as it pertains to taggings:

    [ document_pair [ document_pair [..]]]

    document_pair = separator_string tagging

this "structure grammar" is intended to work for all strings.

at #history-B.3 we buried [#705] a digraph explaining the formal structure
of taggings, because the structure changed.
"""

from modality_agnostic import lazy


"""
Born out of frustration with everything in this package that is not the
initial grammar (the *.ebnf files); experimental new rules (experiment was
a success):

- S-expressions ("sexps") are only ever implemented with plain old tuples.
  (There should be no classes calling themselves "sexp".)
- Every sexp's first component is a string signifying its BUSINESS TYPE.
  The set of business types is business-specific and up to the client.
- Every sexp of the same business type has the same LENGTH with fixed meanings
  for each of its BODY COMPONENTS. We say "formal" to differentiate between
  the component in the abstract and a specific component of a specific sexp.
- Every formal body component has a HARD TYPE that is fixed.
- Every formal (and actual) body component must be of the THREE hard types:
  STRING, SEXP, or a LIST (tuple) *of* *sexps*. (One proviso below.)
- For string body components, never use none, always use empty string
- For list, never use none always use empty tup
- The only time "none" permitted anywhere in a sexp is to signifying a sexp
  body component slot is unoccupied (where it makes grammatical sense).

- Optionally: if it's faithful it's faithful, and order matters

Now that we have completed the experiment, the code in this file is mostly
concerned with generating "AST" classes whose main job is to wrap a sexp
and give it convenience getter methods so you are never accessing components
by their offset.

The below notation: 's' for strings 'sexp' for sexp 'sexps' for the list type.
'as' associates the slot before it with the name after it, creating a getter
method. 'plus' is bleeding-edge experimental
"""


def _this_definition():
    yield 'top_thing', 'sexps', 'as', 'doc_pairs'
    yield 'not_tag_then_tag', 's', 'as', 'not_tag', 'sexp', 'as', 'tag'
    yield 'shallow_tagging', 's', 's', 'as', 'head_stem', 'plus', _shallow
    yield 'deep_tagging', 's', 's', 'as', 'head_stem', \
          'sexps', 'as', 'subcomponents', 'plus', _deep
    yield 'tagging_subcomponent', 's', 'sexp', 'as', 'body_slot'
    yield 'bracketed_lyfe', 's', 's', 'as', 'inside_string', 's'
    yield 'non_head_bare_tag_stem', 's', 'as', 'self_which_is_string'
    yield 'double_quoted_string', 's', 'sexps', 'as', 'alternating_pieces', 's'
    yield 'escaped_character', 's', 's', 'as', 'unescaped_character'
    yield 'raw_string', 's', 'as', 'self_which_is_string'


def _deep(cls):
    cls.is_deep = True


def _shallow(cls):
    cls.is_deep = False


def ast_via_sexp_(sx):
    coll = _lazy_classes_collection()
    return coll.AST_via_sexp(sx)


@lazy
def _lazy_classes_collection():
    return _lazy_classes_collection_via_AST_definitions(_this_definition())


def _lazy_classes_collection_via_AST_definitions(defs):

    def AST_via_sexp(sx):
        typ = sx[0]
        if typ not in class_cache:
            class_cache[typ] = build_class(defn_via_type[typ])
        return class_cache[typ](sx)

    def build_class(defn):
        stack = list(reversed(defn))
        typ = stack.pop()
        kwargs = {}
        comps = tuple(components_via_definition(kwargs, stack))
        return _build_derived_AST_class(typ, comps, coll, **kwargs)

    def components_via_definition(kwargs, stack):
        offset_in_foz = -1
        while True:
            offset_in_foz += 1
            hard_type = stack.pop()
            if hard_type not in _via_hard_type:
                if 'plus' == hard_type:
                    call_me, = stack  # ..
                    kwargs['extenso'] = call_me
                    break
                raise _DefinitionError(f"huh? '{hard_type}'")
            cname = None
            if len(stack) and 'as' == stack[-1]:
                stack.pop()
                cname = stack.pop()
                assert isinstance(cname, str)  # #[#022]

            fo = _build_formal_component(offset_in_foz, cname)
            itr = _via_hard_type[hard_type](fo, coll)
            row, = itr
            itr = iter(row)
            funcs = {k: next(itr) for k in itr}  # ick/meh
            fo.to_string_pieces = funcs.pop('to_string_pieces')
            fo.get_component = funcs.pop('get_component')
            assert not funcs
            yield fo
            if not len(stack):
                break

    class_cache = {}
    defn_via_type = {defn[0]: defn for defn in defs}

    class lazy_classes_collection:  # #class-as-namespace
        pass
    coll = lazy_classes_collection
    coll.AST_via_sexp = AST_via_sexp
    return coll


def _build_derived_AST_class(business_type, foz, coll, extenso=None):
    class cls(_AST):
        def _to_string_pieces(self):
            for fo in foz:
                for pc in fo.to_string_pieces(self):
                    yield pc

        @property
        def _CX(self):  # just for development
            return tuple(fo.component_name for fo in foz if fo.component_name)

        __repr__ = _define_repr_method(business_type)

    for fo in foz:
        cname = fo.component_name
        if cname is None:
            continue
        setattr(cls, cname, property(_define_getter_via_formal(fo, coll)))

    cls.__name__ = business_type  # not sure why it seems necessary out here

    if extenso:
        extenso(cls)
    return cls


class _AST:
    def __init__(self, sexp):
        self._sexp = sexp
        self._cached_components = {}

    def _to_string(self):
        return ''.join(self._to_string_pieces())

    @property
    def _type(self):
        return self._sexp[0]


def _define_getter_via_formal(fo, coll):
    def get_this_component(self):
        return fo.get_component(self)
    return get_this_component


def _build_formal_component(offset_in_foz, cname):
    class formal_component:  # #class-as-namespace
        component_name, offset_in_formals = cname, offset_in_foz
        offset_in_sexp = offset_in_foz + 1
    return formal_component


# == Formal Hard Types (crazy visitor pattern)

def _hard_type(hard_type_name):
    def decorator(via_coll):
        assert hard_type_name not in _via_hard_type
        _via_hard_type[hard_type_name] = via_coll
    return decorator


_via_hard_type = {}


@_hard_type('sexps')
def _(fo, coll):

    def to_string_pieces(host):
        for ch in fo.get_component(host):
            for pc in ch._to_string_pieces():
                yield pc

    def build_component(tup):
        assert isinstance(tup, tuple)  # #[#022]
        if not len(tup):
            return ()
        assert _looks_like_sexp(tup[0])
        return tuple(ast_via_sexp(sx) for sx in tup)

    get_component = _build_lazy_get_component(build_component, fo)

    ast_via_sexp = coll.AST_via_sexp
    yield 'to_string_pieces', to_string_pieces, 'get_component', get_component


@_hard_type('sexp')
def _(fo, coll):

    def to_string_pieces(host):
        return fo.get_component(host)._to_string_pieces()

    def build_component(sx):
        if sx is None:
            return  # (Case1030)
        assert _looks_like_sexp(sx)
        return ast_via_sexp(sx)

    get_component = _build_lazy_get_component(build_component, fo)

    ast_via_sexp = coll.AST_via_sexp
    yield 'to_string_pieces', to_string_pieces, 'get_component', get_component


def _build_lazy_get_component(build_component, fo):
    def get_component(host):
        if oif not in host._cached_components:
            host._cached_components[oif] = build_component(host._sexp[ois])
        return host._cached_components[oif]
    oif, ois = fo.offset_in_formals, fo.offset_in_sexp
    return get_component


@_hard_type('s')
def _(fo, coll):
    def to_string_pieces(host):
        return (host._sexp[ois],)

    def get_component(parent):
        return parent._sexp[fo.offset_in_sexp]

    ois = fo.offset_in_sexp
    yield 'to_string_pieces', to_string_pieces, 'get_component', get_component


# ==

def _define_repr_method(business_type):

    def __repr__(self):
        return ''.join(s for row in repr_pcs(self) for s in row)

    def repr_pcs(self):
        yield '<', __name__, '.', _build_derived_AST_class.__name__
        yield '.<generated>.', business_type,
        yield ' object at ', str(id(self)), '>'

    return __repr__


def _looks_like_sexp(sx):
    yes = isinstance(sx, tuple)  # #[#022]
    yes and (yes := isinstance(sx[0], str))
    yes and (yes := 1 < len(sx))
    return yes


class _DefinitionError(RuntimeError):
    pass

# #pending-rename: probably eventually to 'lazy AST classes via definition' and
#     move the actual definitions to the client
# #history-B.3: blind rewrite intruducing simplified sexps
# #history-A.2: yet another new and improved model to accomodate quotes
# #history-A.1: begin actually using this to build native structures from AST's
# #born.
