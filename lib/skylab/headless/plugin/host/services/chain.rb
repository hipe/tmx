module Skylab::Headless

  class Plugin::Host::Services::Chain

    # experimental core of the whole headless world. a proxy.
    # this is the fifth center of the universe. i don't know how we
    # ended up with so many. (there may only be four..)

    def initialize a
      @a = a
      @cache_h = { }
    end

    # `build_host_proxy` - we want to sidestep dealing with this until we
    # absolutely need it (if ever). services that need to be chain-friendly
    # for now must be ingestable and ingested. NOTE services that use a host
    # proxy for now we default to using the lastmost (deepest) services in the
    # chain because that's how it used to work.

    def build_host_proxy plugin_client
      @a.last.build_host_proxy plugin_client
    end

    def has_service? i
      _index_for_services_for_service i
    end

    def host_descriptor
      "(#{ @a.map { |x| x.host_descriptor } * ', ' })"
    end

    def _index_for_services_for_service i
      @cache_h.fetch i do
        index = @a.length.times.reduce nil do |_, idx|
          @a.fetch( idx ).has_service? i and break idx
        end
        @cache_h[ i ] = index
      end
    end
    private :_index_for_services_for_service

    # `call_host_service` - assusmes you checked `has_service?`

    def call_host_service pstory, i
      @a.fetch( _index_for_services_for_service i ).
        call_host_service( pstory, i )
    end
  end
end
