require_relative 'test-support'

module Skylab::Headless::TestSupport::Plugin::Host::Proxy

  ::Skylab::Headless::TestSupport::Plugin::Host[ Proxy_TestSupport = self ]

  include CONSTANTS

  Headless = ::Skylab::Headless  # increase its visibility for below modules

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::Headless::Plugin::Host::Proxy" do
    context "context 1" do
      Sandbox_1 = Sandboxer.spawn
      it "usage:" do
        Sandbox_1.with self
        module Sandbox_1
          class CheekyWebClient
            Headless::Plugin::Host::Proxy.enhance self do
              services [ :emphasize_text, :ivar ]
            end
            def initialize
              @emphasize_text = -> x { "<em>#{ x }</em>" }  # (didactic only!
            end                                  # do NOT use in real world.)
          end

          class CheekyCLI_Client
            Headless::Plugin::Host::Proxy.enhance self do
              services [ :emphasize_text, :ivar ]
            end
            def initialize
              @emphasize_text = -> x { x.upcase }
            end
          end

          web = CheekyWebClient.new
          cli = CheekyCLI_Client.new

          web.class.method_defined?( :plugin_host ).should eql( false )
          web.class.private_method_defined?( :plugin_host ).should eql( true )

          webf, clif = [ web, cli ].map do |clnt|
            ph = clnt.send :plugin_host
            ph.call_plugin_host_service(
              ph.plugin_services._story.fetch_service( :emphasize_text ),
              nil, nil )
          end

          webf[ 'hi' ].should eql( '<em>hi</em>' )
          clif[ 'hi' ].should eql( 'HI' )
        end
      end
    end
  end
end
