module Skylab::Headless

  module Plugin::Host::Proxy

    # one might want to use this because their modality client (e.g CLI)
    # is doing cheeky magic and cannot afford to have its method namespace
    # (public or private) taken up, yet still it wants to appear outwardly
    # as a plugin host. now you get @plugin_host on initialize always.
    # this is :[#fa-010].

    # using `Headless::Plugin::Host::Proxy`:
    # comprehensive example:
    #
    #     class Cheeky_CLI_Client
    #       Headless::Plugin::Host::Proxy.enhance self do
    #         services :emphasize_text
    #       end
    #     private
    #       def emphasize_text x
    #         x.upcase
    #       end
    #     end
    #
    #     class Cheeky_Web_Client
    #       Headless::Plugin::Host::Proxy.enhance self do
    #         services [ :emphasize_text, :ivar ]
    #       end
    #       def initialize
    #         @emphasize_text = -> x { "<em>#{ x }</em>" }  # (didactic only!
    #       end                                  # do NOT use in real world.)
    #     end
    #
    #     cli = Cheeky_CLI_Client.new
    #     web = Cheeky_Web_Client.new
    #
    #     p = web.instance_variable_get( :@plugin_host ). # sad, nec. evil
    #       plugin_host_metaservices.call_service( :emphasize_text )
    #
    #     p.call( 'hi' ) # => '<em>hi</em>'
    #
    #     ms = cli.instance_variable_get( :@plugin_host ).
    #       plugin_host_metaservices
    #
    #     ms.call_service( :emphasize_text, 'hi' ) # => 'HI'
    #

    def self.enhance client_class, &blk
      client_class.class_exec do
        include Include_
        prepend Prepend_
        def self.client_can_broker_plugin_metaservices  # #search-for-it
          true
        end
        ph_class = if const_defined? :Plugin_Host_, false
          const_get :Plugin_Host_, false
        else
          const_set :Plugin_Host_, ::Class.new( Pxy_ )
        end
        Plugin::Host.enhance ph_class, &blk
      end
    end

    module Prepend_
      def initialize( * )
        @plugin_host = build_plugin_host
        super
      end
    end

    module Include_
    private
      def build_plugin_host
        self.class.const_get( :Plugin_Host_ ).new self
      end
    end

    class Pxy_

      include Plugin::Host::InstanceMethods_  # (early so we can override)

      def initialize client
        @plugin_host_metaservices = plugin_host_metaservices_class.new client
      end

      attr_reader :plugin_host_metaservices

    end
  end
end
