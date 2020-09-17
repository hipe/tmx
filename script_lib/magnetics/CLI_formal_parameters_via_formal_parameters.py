"""DISCUSSION

When we #abstracted we also sunsetted integration with vendor argparse.

When we #abstracted we sunsetted #wish [#008.E] `from gettext import gettext`

[#502] discusses different ways to conceive of parameters in terms of ther
argument arity. Here we could either follow the "lexicon" (`is_required`,
`is_flag`, `is_list`) or the numbers. We go the numbers route for no
particular resason.
"""


# == BEGIN

def CLI_function_via_command_module(command_module):

    mixed_command = command_module.Command
    formal_parms_dict = command_module.PARAMETERS

    if formal_parms_dict is None:
        from modality_agnostic.magnetics.formal_parameter_via_definition import (  # noqa: E501
                parameter_index_via_mixed)
        param_index = parameter_index_via_mixed(mixed_command)
        formals = param_index.parameters_that_do_not_start_with_underscores
    else:
        formals = formal_parms_dict.items()
        param_index = None

    _CLI_foz = tuple(CLI_formal_parameters_via_formal_parameters(formals))

    def do_CLI(mon, sin, sout, serr, *actuals):

        leng = len(formals)
        assert len(actuals) == leng
        kwargs = {formals[i][0]: actuals[i] for i in range(0, leng)}

        if param_index is not None:
            assert 0 == len(param_index.parameters_that_start_with_underscores)

        if hasattr(mixed_command, 'execute'):  # not `callable`
            x = mixed_command(**kwargs).execute()
        else:
            x = mixed_command(**kwargs)

        for raw_line in x:
            sout.write(f'{raw_line}\n')  # _eol

        return 0  # for now

    s = mixed_command.__doc__
    if s is None:
        s = command_module.__doc__
    do_CLI.__doc__ = s

    def CLI(sin, sout, serr, argv):
        from script_lib.cheap_arg_parse import cheap_arg_parse
        return cheap_arg_parse(
                do_CLI, sin, sout, serr, argv, formal_parameters=_CLI_foz)

    return CLI


def __infer_formals(mixed_command):
    # (this used to happen in modality agnostic before #abstracted)
    # #todo now we need to de-dup this with the past

    from modality_agnostic.magnetics.formal_parameter_via_definition import (
            define)
    from inspect import signature, _empty as signature_nothing

    assert callable(mixed_command)  # for class, will be similar

    for name, param in signature(mixed_command).parameters.items():

        assert '_' != name[0]  # we used to do a thing

        annotation = param.annotation
        default = param.default

        assert annotation is signature_nothing  # this would be "cool"
        assert default is signature_nothing  # this would be "cool"

        # [#607.J] crappy desc bug below
        use_description = f"xx (no desc for '{name.replace('_', '-')}')"
        use_default = None
        use_argument_arity = 'REQUIRED_FIELD'

        _formal = define(use_description, use_default, use_argument_arity)
        yield name, _formal

# == END


def CLI_formal_parameters_via_formal_parameters(formal_parameters):
    _use_options, _use_args, _the_one_glob = __first_pass(formal_parameters)
    return __second_pass(_use_options, _use_args, _the_one_glob)


def __second_pass(use_optionals, use_positionals, use_globby):
    # convert the partitioned formals into CLI formals (definitions of)

    def slug():
        return normal_name.replace('_', '-')

    def meta_var():
        return _meta_var_via(normal_name)

    def desc_lines():
        lines = _desc_lines_via_description_value(formal_param.description)
        if len(lines):
            return lines
        return ('xx #todo 1324',)

    for normal_name, formal_param in use_optionals:
        r = formal_param.argument_arity_range
        mini = r.start
        maxi = r.stop

        assert mini is not None  # we never go to negative unbounded

        if 0 == mini:
            if 0 == maxi:
                yield (f'--{slug()}', *desc_lines())  # flag
            elif 1 == maxi:
                yield (f'--{slug()}={meta_var()}', *desc_lines())  # option
            else:
                assert maxi is None  # optional list
                yield (f'--{slug()}={meta_var()}*', *desc_lines())
        else:
            assert 1 == mini
            if 1 == maxi:
                # min 1 max 1 is normally a positional argument, but #here1

                yield (f'--{slug()}={meta_var()}!', *desc_lines())
            else:
                assert maxi is None  # assume unbounded. (max 0 never w min 1
                # this would have been the globby but the slot is taken

                yield (f'--{slug()}={meta_var()}+', *desc_lines())

        # NOTE no expression of the CLI formal of the "counting flag". so,
        # it's not a clean 1-to-1 isomorphicism between these 2 systems

    for normal_name, formal_param in use_positionals:
        r = formal_param.argument_arity_range
        mini = r.start
        maxi = r.stop
        assert 1 == mini
        assert 1 == maxi
        yield (slug(), *desc_lines())

    if use_globby is not None:
        normal_name, formal_param = use_globby
        r = formal_param.argument_arity_range
        mini = r.start
        maxi = r.stop
        assert maxi is None

        if 1 == mini:
            # add required list (globby)
            yield (f'{slug()}+', *desc_lines())
        else:
            assert 0 == mini
            # add optional list (globby)
            yield (f'{slug()}*', *desc_lines())


def __first_pass(formal_parameters):
    # partion the formal parameters into three categories:
    # optionals (included demoted positionals), positionals,
    # and zero or one that wins the "globby" slot

    optionals_of_several_kinds = []
    regular_positional_arguments = []
    listy_parameters = []

    for normal_name, formal_param in formal_parameters:
        item = (normal_name, formal_param)

        r = formal_param.argument_arity_range
        mini = r.start
        maxi = r.stop
        if 0 == mini:
            if 0 == maxi:
                optionals_of_several_kinds.append(item)
            elif 1 == maxi:
                optionals_of_several_kinds.append(item)
            else:
                assert maxi is None
                listy_parameters.append(item)
        else:
            assert 1 == mini
            if 1 == maxi:
                regular_positional_arguments.append(item)
            else:
                assert maxi is None
                listy_parameters.append(item)

    # heuristic: more than three is too many positionals. convert to optionals
    if 3 < len(regular_positional_arguments):  # #here1
        # NOTE this means the backend will have to check required-ness
        use_positionals = regular_positional_arguments[-3:]
        for item in regular_positional_arguments[0:-3]:
            optionals_of_several_kinds.append(item)
    else:
        use_positionals = regular_positional_arguments

    # you can have a max of one globby fellow. last one wins.
    leng = len(listy_parameters)
    if leng:
        if 1 == leng:
            use_globby, = listy_parameters
        else:
            # NOTE rendering this and parsing this will be hard
            *several, use_globby = listy_parameters
            for item in several:
                optionals_of_several_kinds.append(item)
    else:
        use_globby = None

    return optionals_of_several_kinds, use_positionals, use_globby


def _desc_lines_via_description_value(mixed):

    if isinstance(mixed, str):
        return (mixed,)

    if callable(mixed):
        from inspect import signature  # [#008.12]
        _yes = (0, 1).index(len(signature(mixed).parameters))
        if _yes:
            from . import STYLER_
            return tuple(mixed(STYLER_))  # ..
        return tuple(mixed())

    assert mixed is None
    return ()


def _meta_var_via(normal_name):
    # EXPERIMENTAL & part novelty:
    # given an optional field named eg. "--important-file", name
    # its argument moniker 'FILE' rather than'IMPORTANT_FILE'
    import re
    return re.search('[^_]+$', normal_name)[0].upper()


def xx():
    raise Exception('write me')

# #abstracted.
