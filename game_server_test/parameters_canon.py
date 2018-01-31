from game_server import memoize

from game_server_test.helper import magnetics

class command_modules:  # used as namespace yikes

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
    return magnetics.command().SELF(
        command_module = cls,
        name = 'my_command',
    )


def _generic_parameter():
  return magnetics.command()._default_formal_parameter()

# #born.
