module Skylab::TanMan

  class API::Actions::Graph::Example::Set < API::Action
    extend API::Action::Parameter_Adapter

    param :name, accessor: true, required: true

    param :resource_name, accessor: true, default: :local,
      enum: [:local, :global], required: true

  protected

    def execute
      res = nil
      begin
        controllers.config.ready? or break
        pathname = services.examples.normalize self.name, -> e { error e }
        if ! pathname
          res = pathname
          break
        end
        res = controllers.config.set_value :example,
          pathname.to_s, resource_name
      end while nil
      res
    end
  end
end
