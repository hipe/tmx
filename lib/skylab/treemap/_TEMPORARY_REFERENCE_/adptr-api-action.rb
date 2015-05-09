module Skylab::Treemap

  module Adapter::InstanceMethods::API_Action # (was [#024])

    include Adapter::InstanceMethods::Action

  private

    def _adapter_init
      @adapter_action_cache = { }
    end

    def adapter_api_action
      with_adapter_api_action IDENTITY_
    end

    def with_adapter_api_action func
      res = false
      begin
        @adapter_name or break( send_error_string "adapter name not set" )
        res = resolve_adapter( @adapter_name ) or break
        res = res.item.resolve_api_action_class( normalized_action_name,
          -> e do
            send_error_string e
          end )
        action = @adapter_action_cache.fetch( res ) do |k|
          @adapter_action_cache[ k ] = k.new self
        end
        res = func[ action ]
      end while nil
      res
    end
  end
end
