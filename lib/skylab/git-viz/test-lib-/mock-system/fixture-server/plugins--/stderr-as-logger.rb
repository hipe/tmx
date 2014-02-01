module Skylab::GitViz

  class Test_Lib_::Mock_System::Fixture_Server

    class Plugins__::Stderr_As_Logger

      def initialize host
        @did_swap = @error_code = nil ; @host = host ; @original_stderr = nil
        @serr_p = host.stderr_reference
      end

      def on_build_option_parser op
        op.on '--stderr-path <path>', "write informational message to <path>",
          "(the same messages that are otherwise written to STDERR)" do |path|
          @y = @host.get_qualified_stderr_line_yielder
          @pathname = ::Pathname.new path
          @dir_pn = @pathname.dirname
          procure_a_switch_to_path_now
        end
      end
    private
      def procure_a_switch_to_path_now
        if @dir_pn.directory?
          open_path_and_switch_to_path
        else
          when_is_not_directory
        end ; nil
      end
      def when_is_not_directory
        @y << "cannot open logfile, no such directory: #{ @dir_pn }"
        @error_code = GENERAL_ERROR_ ; nil
      end

    public
      def on_options_parsed
        @error_code
      end
    private

      def open_path_and_switch_to_path
        ec = open_path
        ec || switch_to_path
      end

      def open_path
        @open_filehandle = @pathname.open 'a+'
        PROCEDE_
      rescue ::StandardError => e
        @y << "can't open logfile: #{ e }"
        GENERAL_ERROR_
      end

      def switch_to_path
        @did_swap ||= true
        @y << "swapping-in a new stderr, further errput will go there: #{
          } #{ @open_filehandle.path }."
        prev_stderr = @host.swap_stderr @open_filehandle
        if @original_stderr
          @y << "closing intermediate logfile"
          prev_stderr.close
        else
          @original_stderr = prev_stderr
        end
        @serr_p[].puts "--- #{ my_name } started logging at #{ formatted_now }"
        PROCEDE_
      end

    public
      def on_finalize
        @did_swap and swap_back
        SILENT_
      end
    private

      def swap_back
        @serr_p[].puts "--- #{ my_name } closing logfile at #{ formatted_now }"
        my_fh = @host.swap_stderr @original_stderr
        @original_stderr = nil
        my_fh.close
        SILENT_
      end

      def my_name
        @host.name.as_human
      end

      def formatted_now
        ::Time.now.to_s
      end
    end
  end
end
