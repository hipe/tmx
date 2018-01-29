class SELF:  # :[#011]

    def __init__(self,
      name,
      command_module,
    ):

        params_dict = command_module.PARAMETERS
        if params_dict:
            cover_me('wahoo')
        else:
            self.has_parameters = False

        command_mixed = command_module.Command
        if hasattr(command_mixed.__class__, '__init__'):  # #todo
            fellow = _ViaClass
        else:
            fellow = _ViaFunction

        self._implementation_adapter = fellow(
          mixed_command = command_mixed,
        )

        self.name = name

    def EXECUTABLE_VIA_RESOURCER(self, resourcer):  # mutates resourcer
        actual_params_d = {}
        ada = self._implementation_adapter
        for name in ada.resource_parameter_names:
            _m = _METHOD_NAME_VIA_RESOURCE_PARAMETER_NAME[name]
            _x = getattr(self.__class__, _m)(self, resourcer)
            actual_params_d[name] = _x
        return ada.executable_via_named_arguments_(actual_params_d)

    def _listener_argument_value(self, resourcer):
        _builder = resourcer.flush_modality_agnostic_listener_builder()
        return _builder()

    @property
    def is_branch_node(self):
        return False


_METHOD_NAME_VIA_RESOURCE_PARAMETER_NAME = {
    '_listener' : '_listener_argument_value',
}

class _ViaCommon:
    def __init__(self,
      mixed_command,
    ):
        business_parameters, resources = _index_parameters_via_function(mixed_command)
        self.resource_parameter_names = resources
        self.BUSINESS_PARAMETERS = business_parameters
        # ..

class _ViaClass(_ViaCommon):

    def __init__(self, mixed_command):
        super().__init__(mixed_command)
        self._class = mixed_command

    def executable_via_named_arguments_(self, d):
        def f():
            _command_invocation = self._class( ** d )
            return _command_invocation.execute()
        return f

class _ViaFunction(_ViaCommon):

    def __init__(self, mixed_command):
        super().__init__(mixed_command)
        self._function = mixed_command

    def executable_via_named_arguments_(self, d):
        cover_me('function-based command')


def _index_parameters_via_function(command_function):
    business_parameters = []
    resources = []
    import inspect
    _sig = inspect.signature(command_function)
    params = _sig.parameters
    for param_name in params:
        param = params[param_name]
        dflt = param.default
        if dflt != param.empty:
            cover_me('defaults')
        if param.kind != param.POSITIONAL_OR_KEYWORD:
            cover_me('no design yet for this kind of guy: '+str(param.kind))
        if _UNDERSCORE == param_name[0]:
            resources.append(param_name)
        else:
            cover_me('parameters')
            business_parameters.append(param_name)
    return business_parameters, resources


_UNDERSCORE = '_'
"""magic - parameters with leading underscores are special"""

# #born. (minimal)
