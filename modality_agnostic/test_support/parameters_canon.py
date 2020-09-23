"""the "parameters cannon" is a collection of formal parameters

representing the most common use-cases, useful in testing.
"""


def command_module(original_method):  # #decorator
    key = original_method.__name__

    def use_method(self):
        if key in self._cache:
            return self._cache[key]
        from modality_agnostic.magnetics import formal_parameter_via_definition
        res = original_method(formal_parameter_via_definition)
        self._cache[key] = res
        return res

    return use_method


class _CommandModules:

    def __init__(self):
        self._cache = {}

    @property
    @command_module
    def category_5_required_list_minimal(param):
        class MyModule:  # #class-as-namespace

            def Command(reqo_listo):
                pass

            def desc_f(style):  # [#511.4] lineser with styler
                style.hello_styler()
                yield 'howdy ho'

            PARAMETERS = {
                'reqo_listo': param.define(
                    argument_arity=param.arities.REQUIRED_LIST,
                    description=desc_f,
                 ),
            }
        return MyModule

    @property
    @command_module
    def category_3_optional_list_minimal(param):
        class MyModule:  # #class-as-namespace
            def Command(listo_boyo, wingo_wanno):
                pass

            def fake_desc(name):
                def lineser(style):  # [#511.4] lineser with styler
                    style.hello_styler()
                    yield f"«desc for parm '{ name }'»"
                return lineser

            PARAMETERS = {
                'listo_boyo': param.define(
                    argument_arity=param.arities.OPTIONAL_LIST,
                    description=fake_desc('boyo'),
                 ),
                'wingo_wanno': param.define(
                    argument_arity=param.arities.REQUIRED_FIELD,
                    description=fake_desc('wanno'),
                 ),
            }
        return MyModule

    @property
    @command_module
    def category_2_optional_field_minimal(param):
        class MyModule:  # #class-as-namespace

            def Command(opto_fieldo):
                pass

            def desc_f(style):  # [#511.4] lineser with styler
                yield 'i am opto fieldo'
                _ = style.em('hello')
                yield f'line 2 {_}'

            PARAMETERS = {
                'opto_fieldo': param.define(
                    argument_arity=param.arities.OPTIONAL_FIELD,
                    description=desc_f,
                 ),
            }
        return MyModule

    @property
    @command_module
    def category_1_flag_minimal(param):
        class MyModule:  # #class-as-namespace

            def Command(this_flag):
                pass

            def desc_f(style):  # [#511.4] lineser with styler
                style.hello_styler()
                yield 'ohai mami'

            PARAMETERS = {
                'this_flag': param.define(
                    argument_arity=param.arities.FLAG,
                    description=desc_f,
                 ),
            }
        return MyModule

    @property
    def weird_parameter_shape_NOT_MEMOIZED(self):
        class MyModule:  # #class-as-namespace
            def Command(ohai, **kw_arggos):
                pass
            PARAMETERS = None
        return MyModule

    @property
    def dont_do_defaults_NOT_MEMOIZED(self):
        class MyModule:  # #class-as-namespace
            def Command(fez_boz=1234):
                pass
            PARAMETERS = None
        return MyModule

    @property
    def one_inside_one_outside_NOT_MEMOIZED(self):

        # == BEGIN
        from modality_agnostic.magnetics.formal_parameter_via_definition import (  # noqa: E501
                define)
        gen_parm = define('desc 4 gen_parm', argument_arity='REQUIRED_FIELD')

        def _generic_parameter():
            return gen_parm
        # == END

        class MyModule:  # #class-as-namespace
            def Command(foo_bar, biff_baz):
                pass

            PARAMETERS = {
                'foo_bar': _generic_parameter(),
                'boozo_bozzo': _generic_parameter(),
                'biffo': _generic_parameter(),
            }
        return MyModule

    @property
    def two_crude_function_parameters_by_function(self):

        class MyModule:  # #class-as-namespace

            def Command(foo_bar, biff_baz):

                yield f'here is foo bar: "{foo_bar}"'
                yield f'here is biff baz: "{biff_baz}"'
            PARAMETERS = None
        return MyModule

    @property
    def two_crude_function_parameters_by_class(self):  # category 5
        class MyModule:  # #class-as-namespace
            class Command:
                def __init__(self, foo_bar, biff_baz):
                    pass
            PARAMETERS = None
        return MyModule


command_modules = _CommandModules()

# #born.
