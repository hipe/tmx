require_relative 'test-support'

module Skylab::Face::TestSupport::Plugin::Host::Metaservices_::Chain_

  ::Skylab::Face::TestSupport::Plugin::Host::Metaservices_[ self ]

  include CONSTANTS

  Face = ::Skylab::Face

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::Face::Plugin::Host::Metaservices_::Chain_" do
    context "#experimental core of the whole headless world: this proxy." do
      Sandbox_1 = Sandboxer.spawn
      it "usage" do
        Sandbox_1.with self
        module Sandbox_1
          class API_Client
            Face::Plugin::Host.enhance self do
              services :show_a_path, :emphasize_text
            end
          private
            def show_a_path x
              "(never see full path) #{ x }"
            end
            def emphasize_text x
              x.upcase
            end
          end

          class Modality_Client
            Face::Plugin::Host::Proxy.enhance self do  # proxy, for grease
              services :show_a_path, :do_some_mode_thing
            end
            def _ph ; @plugin_host end
          private
            def show_a_path x
              "(safe path) #{ x.split( '/' ).last }"
            end
            def do_some_mode_thing
              "whatever"
            end
          end

          Chain_ = Face::Plugin::Host::Metaservices_::Chain_.new [
            Modality_Client::Plugin_Host_::Plugin_Host_Metaservices_,
            API_Client::Plugin_Host_Metaservices_ ]

          api = API_Client.new
          web = Modality_Client.new

          msvcs = Chain_.new [
            web.instance_variable_get(:@plugin_host).plugin_host_metaservices,
            api.plugin_host_metaservices
          ]

          ( !! ( msvcs.moniker =~ /Modality.+API/ ) ).should eql( true )

          msvcs.call_service( :do_some_mode_thing ).should eql( 'whatever' )
                                                      # first thing in chain

          msvcs.call_service( :emphasize_text, 'hi' ).should eql( 'HI' )
                                                      # last thing in chain

          msvcs.call_service( :show_a_path, '/foo/bar' ).should eql( '(safe path) bar' )
                                                      # earliest thing in chain

          svcs = msvcs.build_proxy_for Face::Plugin::Metaservices_::OMNI_

          svcs.do_some_mode_thing.should eql( 'whatever' )
          svcs.emphasize_text( 'hi' ).should eql( 'HI' )
          svcs.show_a_path( 'x/y' ).should eql( '(safe path) y' )
        end
      end
    end
  end
end
