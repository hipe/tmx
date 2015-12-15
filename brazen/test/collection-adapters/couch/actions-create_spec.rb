require_relative '../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] collections - couch - actions - create (COVER edit sess, precons)" do

    TS_[ self ]
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

      _em = expect_not_OK_event :start_directory_is_not_directory

      _sym = _em.cached_event_value.to_event.terminal_channel_symbol

      :start_directory_does_not_exist == _sym or fail

      expect_failed
    end

    it "with an empty directory workspace path" do

      call_API :collection, :couch, :create, :name, 'zeep',
        :workspace_path,
        TestSupport_::Fixtures.dir( :empty_esque_directory )

      _em = expect_not_OK_event :resource_not_found

      ev = _em.cached_event_value.to_event

      :workspace_not_found == ev.terminal_channel_symbol or fail

      _em.cached_event_value.to_event.invite_to_action.should eql [ :init ]

      expect_failed
    end
  end
end
