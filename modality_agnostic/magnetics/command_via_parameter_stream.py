"""
:[#503]
"""

from modality_agnostic.memoization import lazy


class SELF:  # :[#011]

    def __init__(
            self,
            name,
            command_module,
    ):
        command_mixed = command_module.Command

        self._parameters_index = _index_parameters(
          detailed_parameters=command_module.PARAMETERS,
          crude_parameters_callable=command_mixed,
        )

        if hasattr(command_mixed.__class__, '__init__'):  # #todo
            fellow = _ViaClass
        else:
            fellow = _ViaFunction

        self._implementation_adapter = fellow(
          mixed_command=command_mixed,
        )

        self.name = name

    @property
    def description(self):
        # #todo
        def f(o, style):
            o("«hello i am desc for '%s'»" % self.name)
        return f

    def EXECUTABLE_VIA_RESOURCER(self, resourcer):  # mutates resourcer
        idx = self._parameters_index
        actual_params_d = idx.begin_actual_arguments_dictionary()
        for name in idx.resource_name_string_list:
            _m = _METHOD_NAME_VIA_RESOURCE_PARAMETER_NAME[name]
            _x = getattr(self.__class__, _m)(self, resourcer)
            actual_params_d[name] = _x
        return self._implementation_adapter.executable_via_named_arguments_(
                actual_params_d)

    def _listener_argument_value(self, resourcer):
        _builder = resourcer.flush_modality_agnostic_listener_builder()
        return _builder()

    @property
    def formal_parameter_dictionary(self):
        return self._parameters_index.formal_parameter_dictionary

    @property
    def is_branch_node(self):
        return False


_METHOD_NAME_VIA_RESOURCE_PARAMETER_NAME = {
    '_listener': '_listener_argument_value',
}

_ViaCommon = object


class _ViaClass(_ViaCommon):

    def __init__(self, mixed_command):
        self._class = mixed_command

    def executable_via_named_arguments_(self, d):
        def f():
            _command_invocation = self._class(**d)
            return _command_invocation.execute()
        return f


class _ViaFunction(_ViaCommon):

    def __init__(self, mixed_command):
        self._function = mixed_command

    def executable_via_named_arguments_(self, d):
        cover_me('function-based command')


class _ParameterIndex:

    def __init__(
            self,
            formal_parameter_dictionary,
            resource_name_string_list,
    ):
        self.formal_parameter_dictionary = formal_parameter_dictionary
        self.resource_name_string_list = resource_name_string_list

    def begin_actual_arguments_dictionary(self):
        actual_params_d = {}
        if len(self.formal_parameter_dictionary) is not 0:
            cover_me('have fun')
        return actual_params_d


def cover_me(s):
    raise Exception('cover me: '+s)


def _index_parameters(
    detailed_parameters,
    crude_parameters_callable,
):
    """
    formal parameters = function parameters + parameter details (sort of)

    for this discussion it's essential to keep separate these three senses
    of "parameter":

      - function parameters: what we express in python code. (also "crude")
      - parameter details: what we express in our DSL-ish
      - formal parameters: what we are making here (the "sigma" of the two)

    by "details" we mean the meta-data that you provide about parameters
    (if you like, the meta-parameters or meta-associations).

    in detail (and more correctly) the parameters for which you provide
    details (in terms of their names) must be a subset of the function
    parameter (that is, those written in plain-old python).

    so there can be formal function parameters for which there are no
    details, however every detail must correspond to a formal function
    parameter.

    the algorithm: our result is a dictionary representing the "sigma"
    of the function parameters delineated. so start with a mutable,
    empty dictionary for this purpose.

    traverse every function parameter. at each one,

      - delete any detail structure (actually just a formal parameter
        structure) from the pool.

      - if there was no item above, use a default parameter structure
        (argument arity: (1,1)).

      - add the structure to a dictionary, using 'the_name' as a key.
        (you should not need to check for collisions, because python)

    if there are any items left in the pool, whine about them.
    otherwise, done.
    """

    formal_parameter_dictionary = {}
    resource_name_string_list = []

    dim_pool = __diminishing_pool_factory(detailed_parameters)

    import inspect
    params = inspect.signature(crude_parameters_callable).parameters

    for name in params:
        param = params[name]
        _sanity_check_function_parameter(param)
        if _UNDERSCORE == name[0]:
            resource_name_string_list.append(name)
        else:
            formal = dim_pool.my_pop(name)
            if formal is None:
                use_param = _default_formal_parameter()
            else:
                use_param = formal
            formal_parameter_dictionary[name] = use_param

    if len(dim_pool) != 0:
        raise dim_pool.to_exception()

    return _ParameterIndex(
        formal_parameter_dictionary=formal_parameter_dictionary,
        resource_name_string_list=resource_name_string_list,
    )


@lazy
def _default_formal_parameter():  # #testpoint
    import modality_agnostic.magnetics.parameter_via_definition as mag
    return mag(
            description=None,  # hi.
            default_value=None,  # hi.
            argument_arity=mag.arities.REQUIRED_FIELD,
    )


def __diminishing_pool_factory(params_d):
    if params_d is None:
        return _the_empty_diminishing_pool()
    else:
        return _DefinedParametersDiminishingPool(params_d)


class _DefinedParametersDiminishingPool:

    def __init__(self, params_d):
        self._my_params_d = params_d.copy()

    def to_exception(self):
        _s_a = self._my_params_d.keys()
        _message = (
                'this/these parameter detail(s) must have ' +
                'corresponding function parameters: (%s)') % ', '.join(_s_a)
        return _my_exception(_message)

    def my_pop(self, name):
        return self._my_params_d.pop(name, None)

    def __len__(self):
        return len(self._my_params_d)


@lazy
def _the_empty_diminishing_pool():

    # (we could do class-as-singleton but python reflection doesn't
    # recognize a `__len__` method written in that way.)

    class _TheEmptyDiminishingPool:
        def my_pop(self, _):
            return None

        def __len__(self):
            return 0
    return _TheEmptyDiminishingPool()


def _sanity_check_function_parameter(param):
    dflt = param.default
    if dflt != param.empty:
        _msg = "for '%s' use details to express a default"
        raise _my_exception(_msg % param.name)
    if param.kind != param.POSITIONAL_OR_KEYWORD:
        _msg = "'{n}' must be of kind POSITIONAL_OR_KEYWORD (had {k})"
        raise _my_exception(_msg.format(n=param.name, k=str(param.kind)))


def _my_exception(msg):  # #copy-pasted
    from modality_agnostic import Exception as MyException
    return MyException(msg)


_UNDERSCORE = '_'
"""magic - parameters with leading underscores are special"""


# #born. (minimal)
