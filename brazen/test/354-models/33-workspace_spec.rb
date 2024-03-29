require_relative '../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] models workspace" do

    TS_[ self ]
    use :want_event

    it "ping the workspace silo" do

      call_API :workspace, :ping

      want_event :ping, 'hello from (app_name_string)'
      want_no_more_events

      expect( @result ).to eql :_hello_from_brazen_
    end

    it "when provide path=(empty dir) and maxdirs=1, workspace directory is empty" do

      _prepare_ws_tmpdir

      call_API(
        :status,
        :path, @ws_tmpdir.to_path,
        :max_num_dirs, 1,
      )

      em = @result

      expect( em.category ).to eql [ :info, :resource_not_found ]

      x = em.emission_value_proc.call
      x and fail

      em = @event_log.gets
      ev = em.cached_event_value.to_event

      expect( ev.num_dirs_looked ).to eql 1
      expect( ev.start_path ).to eql @ws_tmpdir.to_path

      want_no_more_events
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

      expect( em.category ).to eql [ :info, :resource_existed ]

      ev = em.emission_value_proc.call

      _exp = ::File.join @ws_tmpdir.to_path, cfg_filename

      expect( ev.config_path ).to eql _exp

      want_no_more_events
    end

    it "summarize with empty path" do

      _prepare_ws_tmpdir

      call_API :workspace, :summarize,
        :path, @ws_tmpdir.to_path

      want_not_OK_event :resource_not_found

      want_fail
    end

    it "summarize (a development proxy of 'plural_noun')" do

      # :#cov2.1 (enter config as entity collection)

      _workspace_path = fixture_path_ 'directory-001-shambalamba'

      call_API(
        :workspace, :summarize,
        :path, _workspace_path,
      )

      want_no_events

      em = @result
      expect( em.category ).to eql [ :info, :summary ]
      ev = em.emission_value_proc.call

      _expag = black_and_white_expression_agent_for_want_emission
      _actual = ev.express_into_under [], _expag

      _ = '[^[:alnum:]]*'

      want_these_lines_in_array_ _actual do |y|

        y << %r(\Asummary of «.+#{ ::Regexp.escape cfg_filename }»:\z)
        y << %r(\A#{ _ }2 poet or authors\z)
        y << %r(\A#{ _ }2 vocabularies\z)
        y << %r(\A#{ _ }1 a single thing\z)
        y << "3 sections total"
      end
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
