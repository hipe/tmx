module Skylab::TanMan

  class API::Actions::Graph::Example::Set < API::Action
    extend API::Action::Parameter_Adapter

    param :name, accessor: true, required: true

    param :resource_name, accessor: true, default: :local,
      enum: [:local, :global], required: true

  protected

    def execute
      result = nil
      begin
        config.ready? or break
        sanitized = service.examples.normalize self.name,
          -> e { error e }
        if ! sanitized
          result = sanitized
          break
        end
        result = config.set_value :example, sanitized, resource_name
      end while nil
      result
    end
  end
end
