require_relative '../../../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] models - survey upstream set" do

    Expect_event_[ self ]

    extend TS_

    it "a random string with no prefix - treated as path" do
      freshly_initted_against 'zoidberg'
      expect_not_OK_event :path_must_be_absolute
      expect_failed
    end

    it "use a strange prefix" do
      freshly_initted_against "zoidberg:no see"
      ev = expect_not_OK_event :extra_properties
      black_and_white_lines( ev ).should eql(
        [ "unrecognized prefix 'zoidberg'", "did you mean 'file'?" ] )
      expect_failed
    end

    it "use the 'file' prefix but noent" do
      freshly_initted_against 'file:wazoo.json'
      expect_not_OK_event :errno_enoent
      expect_failed
    end

    def freshly_initted_against s

      call_API :survey, :edit,
        :upstream, s,
        :path, freshly_initted_path

    end

    it "to an existing survey try to set an upstream with a strange extension" do

      call_API :survey, :edit,
        :path, various_extensions_path,
        :upstream, 'file:strange-ext.beefer'

      ev = expect_not_OK_event :extra_properties

      s_a = black_and_white_lines ev

      s_a.first.should eql "unrecognized extension '.beefer'"
      s_a.last.should eql "did you mean '.json' or '.markdown'?"

      expect_no_more_events
    end

    it "add existent file with good extension on fresh workspace" do

      prepare_tmpdir_with_patch_and_do_common :freshly_initted

      expect_common_OK
    end

    it "add valid upstream file on workspace with existing, erroneous upstream" do

      td = prepare_tmpdir_with_patch_and_do_common :some_config_file

      expect_not_OK_event :path_must_be_absolute

      expect_common_OK

      __expect_detail td
    end

    it "add valid upstream on a workspace with multiple upstreams" do

      td = prepare_tmpdir_with_patch :many_upstreams

      s = content_of_the_file td

      d = count_lines s

      call_API_with_td_and_file td, big_JSON_file

      expect_not_OK_event :path_must_be_absolute

      expect_common_OK

      s_ = content_of_the_file td

      d_ = count_lines s_

      d.should eql 13
      d_.should eql 9

      o = TestSupport_::Expect_line.shell s_

      o.advance_to_next_nonblank_line

      o.next_nonblank_line.should match %r(\bupstream ".+not\.json\")

      o.next_nonblank_line.should eql "adapter = json\n"

      o.next_nonblank_line.should match %r(\bzafarelli )
      o.next_line.should match %r(\Akeep-this=)

      o.next_nonblank_line.should match %r(\byou-can-stay )

    end

    it "unset - no" do
      call_API :survey, :edit,
        :upstream, Cull_::EMPTY_S_,
        :path, freshly_initted_path

      expect_not_OK_event :no_upstream_set
      expect_failed
    end

    it "unset - yes" do

      td = prepare_tmpdir_with_patch :many_upstreams

      call_API :survey, :edit,
        :upstream, Cull_::EMPTY_S_,
        :path, td.to_path

      expect_not_OK_event :path_must_be_absolute
      ev = expect_OK_event :deleted_upstreams
      expect_event :collection_resource_committed_changes
      s = black_and_white ev
      s.should eql "deleted 3 'upstreams'"
      expect_succeeded
    end

    def prepare_tmpdir_with_patch_and_do_common sym
      td = prepare_tmpdir_with_patch sym
      call_API_with_td_and_file td, big_JSON_file
      td
    end

    # ~ prepare & execute

    def big_JSON_file
      ::File.join various_extensions_path, 'cull-survey/not.json'
    end

    def various_extensions_path
      dir :upstreams_with_various_extensions
    end

    def call_API_with_td_and_file td, file

      call_API :survey, :edit,
        :upstream, "file:#{ file }",
        :path, td.to_path

      nil
    end

    # ~ expect

    def expect_common_OK

      expect_OK_event :json_upstream
      ev = expect_OK_event :collection_resource_committed_changes
      ev.to_event.is_completion.should eql true
      expect_succeeded
    end

    def __expect_detail td

      scn = TestSupport_::Expect_Line::Scanner.via_string(
        content_of_the_file td )

      scn.next_line.should eql "#ohai\n"
      scn.next_line.should match %r(\A\[upstream "file:)
      scn.next_line.should eql "adapter = json\n"
      scn.next_line.should be_nil

    end

    def count_lines s

      TestSupport_.lib_.basic::String.
        count_occurrences_in_string_of_string( s, NEWLINE_ )
    end
  end
end
