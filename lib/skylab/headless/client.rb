module Skylab::Headless
  module Client end
  module Client::InstanceMethods
    include Headless::SubClient::InstanceMethods
    def build_parameter_controller # can be broken down further if desired
      Headless::Parameter::Controller::Minimal.new(request_runtime)
    end
    def build_params
      params_class.new
    end
    def build_request_runtime
      request_runtime_class.new(
        nil, nil, nil,
        ->{build_io_adapter}, ->{build_params}, ->{build_parameter_controller}
      )
    end
    def initialize ; end # override parent-child type constructor from s.c.
    def infer_valid_action_names_from_public_instance_methods
      a = [] ; _a = self.class.ancestors ; m = nil
      a << m if IGNORE_THIS_CONSTANT !~ m.to_s until ::Object == (m = _a.shift)
      a.map { |_m| _m.public_instance_methods false }.flatten
    end
    def parameter_controller
      @parameter_controller ||= build_parameter_controller
    end
    def request_runtime ; @request_runtime ||= build_request_runtime end
    def request_runtime_class ; Headless::Request::Runtime::Minimal end
  end
  IGNORE_THIS_CONSTANT = /\A#{to_s}\b/
end
