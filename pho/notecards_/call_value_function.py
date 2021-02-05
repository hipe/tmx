from inspect import signature as _inspect_signature
from collections import namedtuple as _nt
import re as _re


def func(bent, expression_string, memo, bcoll, listener):

    def main():
        func_name, args_parse_tree = resolve_function_name_and_args()
        args = resolve_arg_values(args_parse_tree)
        funco = resolve_function(func_name)
        check_number_of_args(args, funco)
        return call_function(args, funco)

    def call_function(args, funco):
        func, memo_yikes = funco.func, funco.memo_yikes
        wval = func(*args, bent, memo_yikes, bcoll, listener)
        if wval is None:
            xx(f"fun, we've never covered failure (from {funco.locator!r})")
        x, = wval  # ..
        return x

    def check_number_of_args(args, funco):
        if funco.num_args == len(args):
            return
        xx(f"{funco.locator!r} was called with {len(args)} args, "
           f"needs {funco.num_args}")

    def resolve_function(func_name):

        # If we've memoized it before, use that
        if (funcs := memo.get('funcs')) is None:
            memo['funcs'] = (funcs := {})
        if (funco := funcs.get(func_name)):
            return funco

        # Resolve it and memoize it [#883.S.5]
        funco = _load_function_once(func_name, memo, bcoll, listener)
        funcs[func_name] = funco
        return funco

    def resolve_arg_values(args_parse_tree):
        return tuple(do_resolve_arg_values(args_parse_tree))

    def do_resolve_arg_values(args_parse_tree):

        for typ, x in args_parse_tree:

            # If it's a literal value (a string), use that
            if 'literal_value' == typ:
                yield x
                continue

            # If it's a variable name whole value we resolved before, use that
            assert 'variable_name' == typ
            if (varis := memo.get('varis')) is None:
                memo['varis'] = (varis := {})
            if x in varis:
                yield varis[x]
                continue

            # Otherwise, resolve the value and memoize it [#882.S.4]
            value = resolve_variable_value_once(x)
            varis[x] = value
            yield value

    def resolve_variable_value_once(var_name):
        return _resolve_variable_value_once(
            var_name, memo, bcoll, listener)

    def resolve_function_name_and_args():
        return _parse_function_call(expression_string, listener)

    stop = _Stop
    try:
        return main()
    except stop:
        pass


_Funco = _nt('_Funco', ('num_args', 'func', 'locator', 'memo_yikes'))


def _load_function_once(func_name, memo, bcoll, listener):
    dct = _produce_raw_dict(
        memo, 'value_function',
        'funcs_as_unparsed_dict', 'VALUE_FUNCTION_RIGHT_HAND_SIDES',
        bcoll, listener)

    # Get func locator expression right hand side as it appeared in schema.rec
    rhs = dct.get(func_name)
    if rhs is None:
        from pho.magnetics_.text_via import oxford_join as func
        or_list = func(dct.keys(), ' or ')  # does repr
        xx(f"No function {func_name!r}. Did you mean {or_list}?")

    # Split a function locator like this "foo.bar.baz" into "foo.bar", "baz"
    md = _function_locator_rx.match(rhs)
    if md is None:
        xx(f"Doesn't look like function location (need 'foo.bar.baz') {rhs!r}")

    # Load the module and get the function
    head, tail = md.groups()
    from importlib import import_module as func
    mod = func(head)  # ..
    func = getattr(mod, tail)  # ..
    num = _validate_signature(func, rhs)
    return _Funco(num, func, rhs, {})


def _validate_signature(func, locator):
    act_stack = list(_inspect_signature(func).parameters.values())
    exp_stack = list(_formals)

    while True:
        exp_name = exp_stack.pop()
        if 0 == len(act_stack):
            xx(f"{locator!r} must take at least {len(_formals)} params")

        param = act_stack.pop()

        if exp_name != param.name:
            xx("this will probably change but very strict for now: "
               f"{locator!r} parameter {param.name!r} should be "
               f"called {exp_name!r}")

        if param.kind != param.POSITIONAL_OR_KEYWORD:
            xx(f"expected {locator!r} parameter {param.name!r} "
               f"to be POSITIONAL_OR_KEYWORD, had {param.kind!s}")

        if 0 == len(exp_stack):
            break

    res = len(act_stack)
    assert all(param.kind == param.POSITIONAL_OR_KEYWORD
               for param in act_stack)  # right? getting crazy
    return res


_formals = 'bent', 'memo', 'bcoll', 'listener'


def _resolve_variable_value_once(var_name, memo, bcoll, listener):
    dct = _produce_raw_dict(
        memo, 'value_function_variable',
        'vars_as_unparsed_dict', 'VALUE_FUNCTION_VARIABLE_RIGHT_HAND_SIDES',
        bcoll, listener)

    if var_name not in dct:
        from pho.magnetics_.text_via import oxford_join as func
        or_list = func(dct.keys(), ' or ')  # does repr
        xx(f"No variable {var_name!r}. Did you mean {or_list}?")

    value_string = dct[var_name]
    assert value_string  # because #here1
    return value_string


def _produce_raw_dict(memo, schema_varname, mem_k, attr, bcoll, listener):
    if (dct := memo.get(mem_k)) is not None:
        return dct

    coll_path = bcoll.KISS_COLLECTION_.MIXED_COLLECTION_IDENTIFIER
    lines = getattr(bcoll._coll, attr)
    if not lines:
        xx(f"needs to but doesn't define a {schema_varname} - {coll_path}")

    dct = {}
    for line in lines:
        md = _simple_name_then_value_rx.match(line)
        if md is None:
            xx(f"Oops did not match very simple thing: {line!r}")
        k, rhs = md.groups()
        if k in dct:
            xx(f"oops: can't re-define component: {k!r}")
        dct[k] = rhs
    memo[mem_k] = dct
    return dct


def _build_function_call_parser():

    def egads(string, listener):
        tlistener = build_throwing_listener(listener)
        scn = StringScanner(string, tlistener)
        return main(scn)

    def main(scn):
        # (there is a much simpler version of something like this at [#882.T])

        func_name = scn.scan_required(func_name_symbol)
        scn.skip_required(open_paren)

        def do_args():
            if scn.skip(close_paren):  # #here2
                return
            while True:
                if (s := scn.scan(variable_name_symbol)):
                    yield 'variable_name', s
                elif (s := scn.scan(hacky_mixed_value_sym)):
                    yield 'literal_value', s
                else:
                    scn.whine_about_expecting(
                        variable_name_symbol, hacky_mixed_value_sym)
                if scn.skip(close_paren):  # #here2
                    return
                scn.skip_required(comma)
        return func_name, tuple(do_args())

    def build_throwing_listener(listener):
        def use_listener(sev, *rest):
            listener(sev, *rest)
            if 'error' == sev:
                raise stop()

    from text_lib.magnetics.string_scanner_via_string import \
        StringScanner, \
        pattern_via_description_and_regex_string as o

    func_name_symbol = o('function_name', iden)
    open_paren = o('open_paren', r'\(')
    variable_name_symbol = o('variable_name', iden)
    comma = o('comma', r',[ ]*')
    close_paren = o('close_paren', r'\)')
    hacky_mixed_value_sym = o('hacky_mixed_value', '[^,)]+')  # assume not var

    stop = _Stop

    return egads


class _Stop(RuntimeError):
    pass


iden = '[a-zA-Z_][a-zA-Z0-9_]*'


_parse_function_call = _build_function_call_parser()


_simple_name_then_value_rx = _re.compile(r"""
    (?P<component_name>
        [a-z_]+
    )
    [ ]+
    (?P<right_hand_side>
        [^ ].*  # #here1
    )
    \Z
""", _re.VERBOSE)


_function_locator_rx = _re.compile(f"""
    (?P<module_name>
        {iden}(?:\\.{iden})*
    )\\.
    (?P<function_name>
        {iden}
    )
    \\Z
""", _re.VERBOSE)


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #born
