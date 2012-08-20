module Skylab::Headless
  class Parameter::Controller::Minimal
    include Parameter::Controller::InstanceMethods
    include SubClient::InstanceMethods
    def errors_count ; request_runtime.errors_count end # here
    def formal_parameters ; params.class.parameters end
  end
end
