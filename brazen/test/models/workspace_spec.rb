require_relative '../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] models workspace" do

    TS_[ self ]
    use :expect_event

    it "ping the workspace silo" do

      call_API :workspace, :ping

      expect_event :ping, 'hello from (app_name)'
      expect_no_more_events

      @result.should eql :_hello_from_brazen_
    end

    it "when provide path=(empty dir) and maxdirs=1, workspace directory is empty" do

      _prepare_ws_tmpdir

      call_API(
        :status,
        :path, @ws_tmpdir.to_path,
        :max_num_dirs, 1,
      )

      em = @result

      em.category.should eql [ :info, :resource_not_found ]

      x = em.emission_value_proc.call
      x and fail

      em = @event_log.gets
      ev = em.cached_event_value.to_event

      ev.num_dirs_looked.should eql 1
      ev.start_path.should eql @ws_tmpdir.to_path

      expect_no_more_events
    end

    it "when provide 'good' path and maxdirs=`, OK" do

      _prepare_ws_tmpdir <<-O.unindent
        --- /dev/null
        +++ b/#{ cfg_filename }
        @@ -0,0 +1 @@
        +[ whatever ]
      O

      call_API(
        :status,
        :path, @ws_tmpdir.to_path,
        :max_num_dirs, 1,
      )

      em = @result

      em.category.should eql [ :info, :resource_exists ]

      ev = em.emission_value_proc.call

      _exp = ::File.join @ws_tmpdir.to_path, cfg_filename

      ev.config_path.should eql _exp

      expect_no_more_events
    end

    it "summarize with empty path" do

      _prepare_ws_tmpdir

      call_API :workspace, :summarize,
        :path, @ws_tmpdir.to_path

      expect_not_OK_event :resource_not_found

      expect_failed
    end

    it "summarize (a development proxy of 'plural_noun')" do

      _prepare_ws_tmpdir <<-O.unindent
        --- /dev/null
        +++ b/#{ cfg_filename }
        @@ -0,0 +1,6 @@
        +[ poet-or-author "elizabeth bishop" ]
        +foo = fa
        +[ vocabulary "foo" ]
        +[ poet-or-author "anais nin" ]
        +[ vocabulary "bar" ]
        +[ a-single-thing ]
      O

      call_API :workspace, :summarize,
        :path, __ws_tmpdir.to_path

      expect_no_events

      em = @result
      em.category.should eql [ :info, :summary ]
      ev = em.emission_value_proc.call

      ev.express_into_under y=[], black_and_white_expression_agent_for_expect_event
      scn = Home_::Common_::Stream.via_nonsparse_array y
      scn.gets.should match %r(\Asummary of «.+#{ ::Regexp.escape cfg_filename }»:\z)
      scn.gets.should match %r(\A[^[:alnum:]]*2 poet or authors\z)
      scn.gets.should match %r(\A[^[:alnum:]]*2 vocabularies\z)
      scn.gets.should match %r(\A[^[:alnum:]]*1 a single thing\z)
      scn.gets.should eql "3 sections total"
      scn.gets.should be_nil
    end

    def _prepare_ws_tmpdir s=nil

      td = prepared_tmpdir

      if s
        td.patch s
      end

      @ws_tmpdir = td
      NIL_
    end

    def __ws_tmpdir  # hacks only
      TestLib_::Tmpdir_controller_instance[]
    end
  end
end
