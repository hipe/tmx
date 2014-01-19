module Skylab::GitViz

  module VCS_Adapters_::Git

    class System_Agent_  # read [#008] the agent narrative for a statement of purpose

      def self.call * a, & p
        new( * a, & p ).execute
      end

      def initialize listener
        @listener = listener
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

      def get_any_nonzero_count_output_line_scanner_from_cmd
        ok = exec_command
        ok && gt_output_line_scanner_from_command_result
      end

      # [#hl-119] #de-vowelated names are used: 'gt' below is short for 'get'

      def gt_output_line_scanner_from_command_result
        peek_s = @o.gets
        if peek_s
          gt_output_line_scanner_when_one_output_line peek_s
        else
          gt_any_output_line_scanner_when_no_first_output_line
        end
      end

      def gt_any_output_line_scanner_when_no_first_output_line
        peek_s = @e.gets
        if peek_s
          r = unexpected_errput peek_s
          expect_zero_exitstatus
          r
        else
          expect_zero_exitstatus
        end
      end

      def gt_output_line_scanner_when_one_output_line line_s
        gets_p = -> do
          gets_p = -> do
            line_s = @o.gets
            if line_s
              line_s.chomp!  # #storypoint-45
              line_s
            else
              gets_p = fnsh_the_scanner_with_a_proc
              line_s
            end
          end
          line_s
        end
        Power_Scanner__[ :init, -> do
         line_s.chomp!
        end, :gets, -> do
          gets_p[]
        end ]
      end

      def fnsh_the_scanner_with_a_proc
        line_s = @e.gets
        line_s and unexpected_errput line_s
        expect_zero_exitstatus
        MetaHell::EMPTY_P_
      end

      def unexpected_errput line_s
        begin
          line_s.chomp!
          @listener.call :unexpected_stderr, :line do line_s end
          line_s = @e.gets
        end while line_s
        INTERRUPT__
      end

      def expect_zero_exitstatus
        d = @w.value.exitstatus
        if d.nonzero?
          @listener.call :unexpected, :exitstatus do d end
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
        @listener.call :cannot_execute_command, :string do
          e.message
        end
        INTERRUPT__
      end

      def prepare_exec_when_path_exists
        if FTYPE_WHITE_S_A.include? @stat.ftype
          @cmd_opt_a = [ @cmd_opt_h ]
          PROCEDE__
        else
          emit_command_and_command_options
          @listener.call :cannot_execute_command, :string do
            say_wrong_ftype
          end
          INTERRUPT__
        end
      end
      FTYPE_WHITE_S_A = %w( directory ).freeze

      def say_wrong_ftype
        "path is #{ @stat.ftype }, must have #{ FTYPE_WHITE_S_A * ' or ' }"
      end

      def exec_cmd
        emit_command_and_command_options
        @i, @o, @e, @w = @system_conduit.popen3( * @cmd_s_a, * @cmd_opt_a )
        PROCEDE__
      end

      def emit_command_and_command_options
        @listener.call :next_system, :command do
          Command__.new @cmd_s_a, @cmd_opt_h
        end ; nil
      end

      class Command__  # just a wrapper used in reporting, currently
        def initialize cmd_s_a, any_nonzero_length_option_h
          @any_nonzero_length_option_h = any_nonzero_length_option_h
          @command_s_a = cmd_s_a
          nil
        end
        attr_reader :command_s_a, :any_nonzero_length_option_h
      end

      INTERRUPT__ = false
      Power_Scanner__ = GitViz::Lib_::Basic[]::List::Scanner::Power
      PROCEDE__ = true

    end
  end
end
