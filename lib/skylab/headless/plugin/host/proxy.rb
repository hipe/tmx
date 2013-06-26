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
    #     class CheekyWebClient
    #       Headless::Plugin::Host::Proxy.enhance self do
    #         services [ :emphasize_text, :ivar ]
    #       end
    #       def initialize
    #         @emphasize_text = -> x { "<em>#{ x }</em>" }  # (didactic only!
    #       end                                  # do NOT use in real world.)
    #     end
    #
    #     class CheekyCLI_Client
    #       Headless::Plugin::Host::Proxy.enhance self do
    #         services [ :emphasize_text, :ivar ]
    #       end
    #       def initialize
    #         @emphasize_text = -> x { x.upcase }
    #       end
    #     end
    #
    #     web = CheekyWebClient.new
    #     cli = CheekyCLI_Client.new
    #
    #     web.class.method_defined?( :plugin_host )  # => false
    #     web.class.private_method_defined?( :plugin_host )  # => false
    #
    #     webf, clif = [ web, cli ].map do |clnt|
    #       ph = clnt.instance_variable_get :@plugin_host
    #       ph.call_plugin_host_service(
    #         ph.plugin_services._story.fetch_service( :emphasize_text ),
    #         nil, nil )
    #     end
    #
    #     webf[ 'hi' ]  # => '<em>hi</em>'
    #     clif[ 'hi' ]  # => 'HI'
    #

    -> do
      define_singleton_method :enhance do |client_cls, &defn_blk|
        if client_cls.const_defined? :Plugin_Host_, false
          fail "sanity - already exists - #{ client_cls::Plugin_Host_ }"
        elsif client_cls.private_method_defined? :plugin_host
          fail "sanity - private method defined - plugin_host"
        elsif client_cls.method_defined? :plugin_host
          fail "sanity - method defind - plugin_host"
        end
        client_cls.class_exec do
          cls = const_set :Plugin_Host_, ::Class.new( Pxy_ )
          Plugin::Host.enhance cls, &defn_blk
          def self.does_bestow_plugin_services ; true end  # meh
          prepend OMG_
        end
        nil
      end
    end.call

    module OMG_
      def initialize( * )
        @plugin_host = self.class.const_get( :Plugin_Host_ ).new self
        super
      end
    end

    class Pxy_
      include Plugin::Host::InstanceMethods  # (so we can override)
      -> do
        technique_h = nil
        define_method :initialize do |client|
          @dispatch = -> svc, a, b do
            technique_h.fetch( svc.technique )[ client, svc, a, b ]
          end
        end
        def call_plugin_host_service svc, a, b
          @dispatch[ svc, a, b ]
        end
        technique_h = {
          ivar: -> client, svc, a, b do
            if b or a and a.length.nonzero?
              raise "sanity - no not pass arguments to an ivar-based service"
            end
            client.instance_variable_get svc.ivar_name
          end,
          method: -> client, svc, a, b do
            client.send svc.method_name, *a, &b
          end
        }
      end.call
    end
  end
end
