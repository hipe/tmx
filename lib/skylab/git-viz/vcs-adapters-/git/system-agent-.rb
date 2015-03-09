module Skylab::GitViz

  module VCS_Adapters_::Git

    class System_Agent_  # read [#008] the agent narrative for a statement of purpose

      def self.call * a, & p
        new( * a, & p ).execute
      end

      def initialize listener_x
        @on_event_selectively = listener_x
        if block_given?
          yield args = Args__.new
          @cmd_s_a, @chdir_pathname, @system_conduit = args.to_a
        end
        @system_conduit or raise ::ArgumentError, "system conduit not present"
        nil
      end

      class Args__
        def initialize
          @cmd_s_a = @chdir_pathname = @system_conduit = nil
        end
        def set_cmd_s_a x
          @cmd_s_a = x ; nil
        end
        def set_chdir_pathname x
          @chdir_pathname = x ; nil
        end
        def set_system_conduit x
          @system_conduit = x ; nil
        end
        def to_a
          [ @cmd_s_a, @chdir_pathname, @system_conduit ]
        end
      end

    private

      def get_any_nonzero_count_output_line_stream_from_cmd
        ok = exec_command
        ok && gt_output_line_stream_from_command_result
      end

      # [#hl-119] #de-vowelated names are used: 'gt' below is short for 'get'

      def gt_output_line_stream_from_command_result
        peek_s = @o.gets
        if peek_s
          gt_output_line_stream_when_one_output_line peek_s
        else
          gt_any_output_line_stream_when_no_first_output_line
        end
      end

      def gt_any_output_line_stream_when_no_first_output_line
        peek_s = @e.gets
        if peek_s
          x = unexpected_errput peek_s
          expect_zero_exitstatus
          x
        else
          expect_zero_exitstatus
        end
      end

      def gt_output_line_stream_when_one_output_line line_s
        gets_p = -> do
          gets_p = -> do
            line_s = @o.gets
            if line_s
              line_s.chomp!  # #storypoint-45
              line_s
            else
              gets_p = __finish_the_stream_with_a_proc
              line_s
            end
          end
          line_s
        end
        GitViz_.lib_.power_scanner :init, -> do
         line_s.chomp!
        end, :gets, -> do
          gets_p[]
        end
      end

      def __finish_the_stream_with_a_proc
        line_s = @e.gets
        if line_s
          unexpected_errput line_s
        end
        expect_zero_exitstatus
        EMPTY_P_
      end

      def unexpected_errput line_s

        begin

          -> line_s_ do
            @on_event_selectively.call :error, :expression, :unexpected_stderr do | y |
              y << line_s_
            end
          end[ line_s ]  # this event is built around line as it is now

          line_s = @e.gets
          if line_s
            redo
          else
            break
          end
        end while nil

        INTERRUPT__
      end

      def expect_zero_exitstatus
        d = @w.value.exitstatus
        if d.nonzero?
          @on_event_selectively.call :error, :expression, :unexpected_exitstatus do | y |
            y << d
          end
        end
      end

      def exec_command
        ok = rslv_that_command_arguments_are_set
        ok && exec_resolved_command
      end

      def rslv_that_command_arguments_are_set
        @chdir_pathname.nil? and raise "sanity - set chdir_pathname to non-nil"
        @cmd_s_a or raise "sanity - @cmd_s_a must be set"
        PROCEDE__
      end

      def exec_resolved_command
        ok = if @chdir_pathname
          prepare_to_exec_cmd_from_dir
        else
          @cmd_opt_a = @cmd_opt_h = nil ; PROCEDE__
        end
        ok && exec_cmd
      end

      def prepare_to_exec_cmd_from_dir
        @cmd_opt_h = { chdir: @chdir_pathname.to_path }
        stat = err = nil
        stat_or_enoent_of_pn @chdir_pathname,
          -> st { stat = st }, -> e { err = e }
        if err
          prepare_exec_when_enonent err
        else
          @stat = stat
          prepare_exec_when_path_exists
        end
      end

      def stat_or_enoent_of_pn pn, yes_p, no_p
        yes_p[ pn.stat ]
      rescue ::Errno::ENOENT => e
        no_p[ e ]
      end

      def prepare_exec_when_enonent e

        emit_command_and_command_options

        @on_event_selectively.call :error, :expression, :cannot_execute_command do | y |
          y << e.message
        end

        INTERRUPT__
      end

      def prepare_exec_when_path_exists

        if FTYPE_WHITE_S_A.include? @stat.ftype
          @cmd_opt_a = [ @cmd_opt_h ]
          PROCEDE__

        else

          emit_command_and_command_options

          me = self
          @on_event_selectively.call :error, :expression, :cannot_execute_command do |y|
            me.__express_wrong_ftype_into_under y, self
          end

          INTERRUPT__
        end
      end
      FTYPE_WHITE_S_A = %w( directory ).freeze

      public( def __express_wrong_ftype_into_under y, expag

        act = @stat.ftype

        expag.calculate do
          y << "path is #{ act }, must have #{ or_ FTYPE_WHITE_S_A }"
        end

        NIL_
      end )

      def exec_cmd
        emit_command_and_command_options
        @i, @o, @e, @w = @system_conduit.popen3( * @cmd_s_a, * @cmd_opt_a )
        PROCEDE__
      end

      def emit_command_and_command_options

        @on_event_selectively.call :next_system, :command do
          Next_System_Command___[ @cmd_s_a, @cmd_opt_h ]
        end

        NIL_
      end

      Next_System_Command___ = Callback_::Event.data_event_class_factory.new(
        :command_s_a, :any_nonzero_length_option_h )

      INTERRUPT__ = false
      PROCEDE__ = true

    end
  end
end
