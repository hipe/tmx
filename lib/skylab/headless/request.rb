module Skylab::Headless
  module Request end
  module Request::Runtime end
  class Request::Runtime::Minimal < Struct.new(
    :io_adapter,   :params,   :parameter_controller,
    :io_adapter_f, :params_f, :parameter_controller_f
  )
    extend Headless::Parameter::Definer::ModuleMethods
    include Headless::Parameter::Definer::InstanceMethods::StructAdapter
    def errors_count ; io_adapter.errors_count end # *very* experimental here
    param :io_adapter,           builder: :io_adapter_f
    param :params,               builder: :params_f
    param :parameter_controller, builder: :parameter_controller_f
  end
end
