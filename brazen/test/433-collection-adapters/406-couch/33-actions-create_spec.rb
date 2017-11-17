require_relative '../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] collections - couch - actions - create (COVER edit sess, precons)" do

    TS_[ self ]
    use :want_event

    it "with no name: mersing required attr: argument error" do

      # #lend-coverage to [#sn-008.6]

      _rx = /\bmissing required attributes 'workspace-path' and 'name'/

      begin
        call_API :collection, :couch, :create
      rescue Home_::Field_::MissingRequiredAttributes => e
      end

      e.message.should match _rx
    end

    it "with no workspace path: mersing required attr: argument error" do

      begin
        call_API :collection, :couch, :create, :name, 'zeep'
      rescue Home_::Field_::MissingRequiredAttributes => e
      end

      e.message.should match %r(\bmissing required attribute 'workspace-path')
    end

    it "with a noent workspace path" do

      call_API :collection, :couch, :create, :name, 'zeep',
        :workspace_path,
        TestSupport_::Fixtures.file( :not_here )

      _em = want_not_OK_event :start_directory_is_not_directory

      _sym = _em.cached_event_value.to_event.terminal_channel_symbol

      :start_directory_does_not_exist == _sym or fail

      want_fail
    end

    it "with an empty directory workspace path" do

      call_API(
        :collection, :couch, :create, :name, 'zeep',
        :workspace_path,
        TestSupport_::Fixtures.directory( :empty_esque_directory ),
      )

      _em = want_not_OK_event :resource_not_found

      ev = _em.cached_event_value.to_event

      :workspace_not_found == ev.terminal_channel_symbol or fail

      _em.cached_event_value.to_event.invite_to_action.should eql [ :init ]

      want_fail
    end
  end
end
