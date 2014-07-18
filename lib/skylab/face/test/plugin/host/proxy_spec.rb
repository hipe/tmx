require_relative 'test-support'

module Skylab::Face::TestSupport::Plugin::Host::Proxy

  ::Skylab::Face::TestSupport::Plugin::Host[ self ]

  include CONSTANTS

  Face = ::Skylab::Face

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "[fa] Plugin::Host::Proxy" do
    context "using `Face::Plugin::Host::Proxy`" do
      Sandbox_1 = Sandboxer.spawn
      it "comprehensive example" do
        Sandbox_1.with self
        module Sandbox_1
          class Cheeky_CLI_Client
            Face::Plugin::Host::Proxy.enhance self do
              services :emphasize_text
            end
          private
            def emphasize_text x
              x.upcase
            end
          end

          class Cheeky_Web_Client
            Face::Plugin::Host::Proxy.enhance self do
              services [ :emphasize_text, :ivar ]
            end
            def initialize
              @emphasize_text = -> x { "<em>#{ x }</em>" }  # (didactic only!
            end                                  # do NOT use in real world.)
          end

          cli = Cheeky_CLI_Client.new
          web = Cheeky_Web_Client.new

          p = web.instance_variable_get( :@plugin_host ). # sad, nec. evil
            plugin_host_metaservices.call_service( :emphasize_text )

          p.call( 'hi' ).should eql( '<em>hi</em>' )

          ms = cli.instance_variable_get( :@plugin_host ).
            plugin_host_metaservices

          ms.call_service( :emphasize_text, 'hi' ).should eql( 'HI' )
        end
      end
    end
  end
end
