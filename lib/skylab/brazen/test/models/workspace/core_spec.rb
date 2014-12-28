require_relative 'test-support'

module Skylab::Brazen::TestSupport::Models::Workspace

  describe "[br] models workspace" do

    extend TS_

    it "ping the workspace silo" do
      call_API :workspace, :ping
      expect_event :ping, 'hello from (app_name)'
      expect_no_more_events
      @result.should eql :_hello_from_brazen_
    end

    it "when provide path=(empty dir) and maxdirs=1, workspace directory is empty" do
      prepare_ws_tmpdir
      call_API :status,
        :path, @ws_tmpdir.to_path, :max_num_dirs, 1
      expect_OK_event :resource_not_found do |ev|
        ev_ = ev.to_event
        ev_.num_dirs_looked.should eql 1
        ev_.start_pathname.should eql @ws_tmpdir
      end
      expect_neutralled
    end

    it "when provide 'good' path and maxdirs=`, OK" do
      prepare_ws_tmpdir <<-O.unindent
        --- /dev/null
        +++ b/#{ cfn }
        @@ -0,0 +1 @@
        +[ whatever ]
      O
      call_API :status,
        :path, @ws_tmpdir.to_path, :max_num_dirs, 1
      expect_OK_event :resource_exists do |ev|
        ev_ = ev.to_event
        ev_.pathname.should eql @ws_tmpdir.join( cfn )
      end
      expect_succeeded
    end

    it "summarize with empty path" do
      prepare_ws_tmpdir
      call_API :workspace, :summarize,
        :path, @ws_tmpdir.to_path
      expect_not_OK_event :resource_not_found
      expect_failed
    end

    it "summarize (a development proxy of 'plural_noun')" do

      prepare_ws_tmpdir <<-O.unindent
        --- /dev/null
        +++ b/#{ cfn }
        @@ -0,0 +1,6 @@
        +[ poet-or-author "elizabeth bishop" ]
        +foo = fa
        +[ vocabulary "foo" ]
        +[ poet-or-author "anais nin" ]
        +[ vocabulary "bar" ]
        +[ a-single-thing ]
      O

      call_API :workspace, :summarize,
        :path, ws_tmpdir.to_path

      ev = expect_event :summary
      ev.render_all_lines_into_under y=[], black_and_white_expression_agent_for_expect_event
      scn = Brazen_::Callback_.stream.via_nonsparse_array y
      scn.gets.should match %r(\Asummary of «.+#{ ::Regexp.escape cfn }»:\z)
      scn.gets.should match %r(\A[^[:alnum:]]*2 poet or authors\z)
      scn.gets.should match %r(\A[^[:alnum:]]*2 vocabularies\z)
      scn.gets.should match %r(\A[^[:alnum:]]*1 a single thing\z)
      scn.gets.should eql "3 sections total"
      scn.gets.should be_nil
      expect_succeeded

    end
  end
end
