module Skylab::Headless

  class Plugin::Host::Services::Chain

    # experimental core of the whole headless world. a proxy.
    # this is the fifth center of the universe. i don't know how we
    # ended up with so many. (there may only be four..)

    # `initialize` - `host_module` will get mutated and populated.

    def initialize a, host_module
      @a, @host_module = a, host_module
      @cache_h = { }
    end

    # `build_host_proxy` - chain-friendly host proxy class omg

    def build_host_proxy plugin_client
      ( if @host_module.const_defined? :Host_Proxy_Chain_
        @host_module.const_get :Host_Proxy_Chain_
      else
        @host_module.const_set :Host_Proxy_Chain_, Hstpxy_.produce( @a )
      end ).new @a, plugin_client
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

  class Plugin::Host::Services::Chain::Hstpxy_

    # `produce` - internally this creates a "services matrix" that represents
    # each of the services that each of the modality clients (e.g) offers,
    # in order of service and then client. for now, a service request to
    # this proxy resolves itself simply by dispatching the request to the
    # first client that it found that has the service.

    def self.produce svcs_a
      a = [ ] ; h = { }
      svcs_a.each_with_index do |svcs, index|
        svcs._story.all_service_names.each do |i|
          a.fetch( h.fetch( i ) do
            a[ idx = a.length ] = [ i ]
            h[ i ] = idx
          end ) << index
        end
      end
      # `a` # =>  [[:out, 0], [:err, 0], [:save, 0, 1]] ..
      ::Class.new( self ).class_exec do
        const_set :A_, a ; const_set :H_, h
        a.each do |i, *_|
          define_method i do |*ary|  # blocks? eew no.
            @dispatch.call i, ary
          end
        end
        self
      end
    end

    def initialize svc_a, plugin_client
      a, h = self.class::A_, self.class::H_
      pstory = plugin_client.plugin_story

      @dispatch = -> i, ary do
        # 1) look up the service by name in the ordered service matrix `a`
        # 2) fetch that row, and fetch the first (1) index of the tuple.
        # 3) that index is an index into `svc_a`, the actual host svcs obj.
        # 4) (yes we could cache this)
        svc_a.fetch( a.fetch( h.fetch( i ) ).fetch( 1 ) ).
          call_host_service pstory, i, ary
      end
    end
  end
end
