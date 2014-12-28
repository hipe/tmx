require_relative '../../../../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] models - survey upstream set" do

    Expect_event_[ self ]

    extend TS_

    it "add strange prefix" do
      freshly_initted_against 'zoidberg'
      ev = expect_not_OK_event :extra_properties
      black_and_white_lines( ev ).should eql(
        [ "unrecognized prefix 'zoidberg'", "did you mean 'file'?" ] )
      expect_failed
    end

    it "add noent file" do
      freshly_initted_against 'file:wazoo.json'
      expect_not_OK_event :errno_enoent
      expect_failed
    end

    def freshly_initted_against s

      call_API :survey, :upstream, :set,
        :path, freshly_initted_path,
        :upstream_identifier, s

    end

    it "add strange extension file" do

      call_API :survey, :upstream, :set,
        :path, various_extensions_path,
        :upstream_identifier, 'file:strange-ext.beefer'

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

    it "add valid upstream file on workspace with existing upstream" do

      td = prepare_tmpdir_with_patch_and_do_common :some_config_file

      expect_common_OK

      ___expect_detail td
    end

    it "add valid upstream on a workspace with multiple upstreams" do

      td = prepare_tmpdir_with_patch :many_upstreams

      s = content_of_the_file td

      d = count_lines s

      call_API_with_td_and_file td, big_JSON_file

      expect_common_OK

      s_ = content_of_the_file td

      d_ = count_lines s_

      d.should eql 13
      d_.should eql 8

      o = TestSupport_::Expect_line.shell s_

      o.advance_to_next_nonblank_line

      o.next_nonblank_line.should match %r(\bupstream ".+not\.json\")

      o.next_nonblank_line.should match %r(\bzafarelli )
      o.next_line.should match %r(\Akeep-this=)

      o.next_nonblank_line.should match %r(\byou-can-stay )

    end

    it "unset - no" do
      call_API :survey, :upstream, :unset, :path, freshly_initted_path
      expect_not_OK_event :no_upstream_set
      expect_failed
    end

    it "unset - yes" do
      td = prepare_tmpdir_with_patch :many_upstreams
      call_API :survey, :upstream, :unset, :path, td.to_path
      ev = expect_OK_event :deleted_upstream
      expect_event :datastore_resource_committed_changes
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

    def prepare_tmpdir_with_patch sym
      td = prepare_tmpdir
      td.patch_via_path TS_::Fixtures::Patches[ sym ]
      td
    end

    def big_JSON_file
      ::File.join various_extensions_path, 'cull-survey/not.json'
    end

    def various_extensions_path
      TS_::Fixtures::Directories[ :upstreams_with_various_extensions ]
    end

    def call_API_with_td_and_file td, file

      call_API :survey, :upstream, :set,
        :path, td.to_path,
        :upstream_identifier, "file:#{ file }"

      nil
    end

    # ~ expect

    def expect_common_OK

      expect_OK_event :json_upstream
      ev = expect_OK_event :datastore_resource_committed_changes
      ev.to_event.is_completion.should eql true
      expect_succeeded
    end

    def ___expect_detail td

      s = content_of_the_file td

      count_lines( s ).should eql 2

      s.should be_include big_JSON_file  # sketchy because marshaling
    end

    def content_of_the_file td
      ::File.read( td.to_pathname.join( config_path ).to_path )
    end

    def count_lines s

      TestSupport_._lib.basic::String.
        count_occurrences_in_string_of_string( s, NEWLINE_ )
    end
  end
end
