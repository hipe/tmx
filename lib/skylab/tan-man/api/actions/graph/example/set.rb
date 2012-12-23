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
        break( res = pathname ) if ! pathname
        res = controllers.config.set_value(
                Models::Example::Collection::CONFIG_PARAM,
                pathname.to_s, resource_name )
      end while nil
      res
    end
  end
end
