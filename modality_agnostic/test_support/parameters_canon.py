"""the "parameters cannon" is a collection of formal parameters

representing the most common use-cases, useful in testing.
"""


from modality_agnostic.memoization import (
        memoize,
        )


class command_modules:  # used as namespace yikes

    @memoize
    def category_5_required_list_minimal():

        class MyModule:

            def Command(reqo_listo):
                pass

            def desc_f(o, style):
                o('howdy ho')

            param = _parameter()
            PARAMETERS = {
                'reqo_listo': param(
                    argument_arity=param.arities.REQUIRED_LIST,
                    description=desc_f,
                 ),
            }
        return _command_via_fake_module(MyModule)

    @memoize
    def category_3_optional_list_minimal():
        class MyModule:
            def Command(listo_boyo, wingo_wanno):
                pass

            def fake_desc(name):
                def f(o, style):
                    o("«desc for parm '%s'»" % name)
                return f

            param = _parameter()
            PARAMETERS = {
                'listo_boyo': param(
                    argument_arity=param.arities.OPTIONAL_LIST,
                    description=fake_desc('boyo'),
                 ),
                'wingo_wanno': param(
                    argument_arity=param.arities.REQUIRED_FIELD,
                    description=fake_desc('wanno'),
                 ),
            }
        return _command_via_fake_module(MyModule)

    @memoize
    def category_2_optional_field_minimal():

        class MyModule:

            def Command(opto_fieldo):
                pass

            def desc_f(o, style):
                o('i am opto fieldo')
                o('line 2 '+style.em('hello'))

            mag = _parameter()
            PARAMETERS = {
                'opto_fieldo': mag(
                    argument_arity=mag.arities.OPTIONAL_FIELD,
                    description=desc_f,
                 ),
            }
        return _command_via_fake_module(MyModule)

    @memoize
    def category_1_flag_minimal():

        class MyModule:

            def Command(this_flag):
                pass

            def desc_f(o, style):
                o('ohai mami')

            mag = _parameter()
            PARAMETERS = {
                'this_flag': mag(
                    argument_arity=mag.arities.FLAG,
                    description=desc_f,
                 ),
            }
        return _command_via_fake_module(MyModule)

    def weird_parameter_shape_NOT_MEMOIZED():
        class MyModule:
            def Command(ohai, **kw_arggos):
                pass
            PARAMETERS = None
        return _command_via_fake_module(MyModule)

    def dont_do_defaults_NOT_MEMOIZED():
        class MyModule:
            def Command(fez_boz=1234):
                pass
            PARAMETERS = None
        return _command_via_fake_module(MyModule)

    def one_inside_one_outside_NOT_MEMOIZED():
        class MyModule:
            def Command(foo_bar, biff_baz):
                pass
            PARAMETERS = {
                'foo_bar': _generic_parameter(),
                'boozo_bozzo': _generic_parameter(),
                'biffo': _generic_parameter(),
            }
        return _command_via_fake_module(MyModule)

    @memoize
    def two_crude_function_parameters_by_function():
        class MyModule:
            def Command(foo_bar, biff_baz):
                pass
            PARAMETERS = None
        return _command_via_fake_module(MyModule)

    @memoize
    def two_crude_function_parameters_by_class():  # category 5
        class MyModule:
            class Command:
                def __init__(self, foo_bar, biff_baz):
                    pass
            PARAMETERS = None
        return _command_via_fake_module(MyModule)


def _command_via_fake_module(cls):
    return _command().SELF(
        command_module=cls,
        name='my_command',
    )


def _generic_parameter():
    return _command()._default_formal_parameter()


def _command():
    import modality_agnostic.magnetics.command_via_parameter_stream as x
    return x


def _parameter():
    import modality_agnostic.magnetics.parameter_via_definition as x
    return x

# #born.
