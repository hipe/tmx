require_relative '../../test-support'

module Skylab::Brazen::TestSupport::Collection_Adapters__Couch_OMNI_MODULE

  ::Skylab::Brazen::TestSupport[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  describe "[br] collections - couch - actions - create (COVER edit sess, precons)" do

    extend TS_
    use :expect_event

    it "with no name: missing required property: argument error" do

      _rx = /\bmissing required properties 'workspace-path' and 'name'/
      begin
        call_API :collection, :couch, :create
      rescue ::ArgumentError => e
      end
      e.message.should match _rx
    end

    it "with no workspace path: missing required property: argument error" do
      begin
        call_API :collection, :couch, :create, :name, 'zeep'
      rescue ::ArgumentError => e
      end
      e.message.should match( /\bmissing required property 'workspace-path'/ )
    end

    it "with a noent workspace path" do

      call_API :collection, :couch, :create, :name, 'zeep',
        :workspace_path,
        TestSupport_::Fixtures.file( :not_here )

      expect_not_OK_event :start_directory_does_not_exist
      expect_failed
    end

    it "with an empty directory workspace path" do

      call_API :collection, :couch, :create, :name, 'zeep',
        :workspace_path,
        TestSupport_::Fixtures.dir( :empty_esque_directory )

      ev = expect_not_OK_event :workspace_not_found
      ev.to_event.invite_to_action.should eql [ :init ]
      expect_failed
    end
  end
end
