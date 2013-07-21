module Skylab::TanMan

  class API::Actions::Graph::Starter::Set < API::Action
    extend API::Action::Parameter_Adapter

    param :name, accessor: true, required: true

    param :resource_name, accessor: true, default: :local,
      enum: [:local, :global], required: true

  private

    def execute
      res = nil
      begin
        controllers.config.ready? or break
        pathname = services.starters.normalize self.name, -> h { error h }
        break( res = pathname ) if ! pathname
        res = controllers.config.set_value(
                Models::Starter::Collection::CONFIG_PARAM,
                pathname.to_s, resource_name )
      end while nil
      res
    end

    attr_reader :verbose # compat
  end
end
