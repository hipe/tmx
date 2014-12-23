require_relative 'test-support'

module Skylab::Face::TestSupport::Plugin::Host::Metaservices::Chain

  ::Skylab::Face::TestSupport::Plugin::Host::Metaservices[ self ]

  include Constants

  extend TestSupport_::Quickie

  Face_ = Face_

  describe "[fa] Plugin::Host::Metaservices_::Chain_" do

    it "usage" do
      class API_Client
        Face_::Plugin::Host.enhance self do
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
        Face_::Plugin::Host::Proxy.enhance self do  # proxy, for grease
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

      Chain_ = Face_::Plugin::Host::Metaservices_::Chain_.new [
        Modality_Client::Plugin_Host_::Plugin_Host_Metaservices_,
        API_Client::Plugin_Host_Metaservices_ ]

      api = API_Client.new
      web = Modality_Client.new

      msvcs = Chain_.new [
        web.instance_variable_get(:@plugin_host).plugin_host_metaservices,
        api.plugin_host_metaservices
      ]

      ( !! ( msvcs.moniker =~ /Modality.+API/ ) ).should eql true

      msvcs.call_service( :do_some_mode_thing ).should eql 'whatever'
                                                  # first thing in chain

      msvcs.call_service( :emphasize_text, 'hi' ).should eql 'HI'
                                                  # last thing in chain

      msvcs.call_service( :show_a_path, '/foo/bar' ).should eql '(safe path) bar'
                                                  # earliest thing in chain

      svcs = msvcs.build_proxy_for Face_::Plugin::Metaservices_::OMNI_

      svcs.do_some_mode_thing.should eql 'whatever'
      svcs.emphasize_text( 'hi' ).should eql 'HI'
      svcs.show_a_path( 'x/y' ).should eql '(safe path) y'
    end
  end
end
