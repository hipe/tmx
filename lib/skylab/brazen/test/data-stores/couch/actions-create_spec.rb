require_relative '../../test-support'

module Skylab::Brazen::TestSupport::Datastores__Couch__Actions__Create

  ::Skylab::Brazen::TestSupport[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  describe "[br] datastores - couch - actions - create (COVER edit sess, precons)" do

    Constants::TestLib_::Expect_event[ self ]

    extend TS_

    it "with no name: missing required property: argument error" do
      begin
        call_API :datastore, :couch, :create
      rescue ::ArgumentError => e
      end
      e.message.should match(
        /\bmissing required properties 'workspace-path' and 'name'/ )
    end

    it "with no workspace path: missing required property: argument error" do
      begin
        call_API :datastore, :couch, :create, :name, 'zeep'
      rescue ::ArgumentError => e
      end
      e.message.should match( /\bmissing required property 'workspace-path'/ )
    end

    it "with a noent workspace path" do

      call_API :datastore, :couch, :create, :name, 'zeep',
        :workspace_path,
        TestSupport_::Data::Universal_Fixtures[ :not_here ]

      expect_not_OK_event :start_directory_does_not_exist
      expect_failed
    end

    it "with an empty directory workspace path" do

      call_API :datastore, :couch, :create, :name, 'zeep',
        :workspace_path,
        TestSupport_::Data::Universal_Fixtures[ :empty_esque_directory ]

      ev = expect_not_OK_event :workspace_not_found
      ev.to_event.invite_to_action.should eql [ :init ]
      expect_failed
    end
  end
end
