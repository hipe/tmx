module Skylab::TanMan
  class API::Actions::Graph::Example::Set < API::Achtung::SubClient
    param :name, accessor: true, required: true

    param :resource_name, accessor: true, default: :local,
      enum: [:local, :global], required: true

  protected
    def execute
      config.ready? or return
      normalized_validated_name = nil
      service.examples.normalize self.name do |o|
        o.on_success { |v| normalized_validated_name = v }
        o.on_failure { |e| error e }
      end or return
      config.set_value :example, normalized_validated_name, resource_name
      true
    end
  end
end
