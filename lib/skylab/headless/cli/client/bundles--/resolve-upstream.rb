module Skylab::Headless

  module CLI::Client

    class Bundles__::Resolve_upstream  # read [#022] CLI upstr..

      MetaHell::Funcy[ self ]

      def initialize client
        # #todo:during-merge use schlurp
        @argv = client.instance_variable_get :@argv
        @argv or fail 'sanity'
        @err_p = client.method :emit_error_line
        @get_stx_p = client.method :argument_syntax_for_action_i
        @par_lbl_p = client.method :parameter_label
        @IO_adptr = client.instance_variable_get :@IO_adapter
        @instream = @IO_adptr.instream
        @relevant_action_i = client.send :default_action_i
        @result = CEASE_X__ ; nil
      end
      CEASE_X__ = CLI::Action::CEASE_X ; PROCEDE_X__ = CLI::Action::PROCEDE_X

      def execute
        @argv_d = @argv.length.zero? ? NO_ARGV__ : SOME_ARGV__
        @term_d = @instream.tty? ? INTERACTIVE__ : NONINTERACTIVE__
        decide
      end
    private
      def decide
        case @argv_d | @term_d
        when NONINTERACTIVE__ | NO_ARGV__ ; try_instream
        when INTERACTIVE__ | NO_ARGV__ ; try_argv
        when INTERACTIVE__ | SOME_ARGV__ ; try_argv
        when NONINTERACTIVE__ | SOME_ARGV__ ; ambiguous
        else wat end
      end
      NO_ARGV__ = NONINTERACTIVE__ = 0 ; SOME_ARGV__ = 1 ; INTERACTIVE__ = 2
      def try_instream
        PROCEDE_X__  # nothing to do.
      end

      def ambiguous
        emit_error_string say_ambiguous  # #storypoint-20
        CEASE_X__
      end
      def say_ambiguous
        "cannot resolve ambiguous upstream modality paradigms -- #{
          }both STDIN and #{ infile_moniker } appear to be present."
      end
      def try_argv
        case @argv.length <=> 1
        when -1 ; when_argv_length_is_zero
        when  0 ; when_argv_length_is_one
        when  1 ; when_argv_length_greater_than_one
        end
      end
      def when_argv_length_is_zero
        emit_error_string "expecting: #{ infile_moniker }"
        CEASE_X__
      end
      def when_argv_length_greater_than_one
        emit_error_string say_too_much_arg
        CEASE_X__
      end
      def say_too_much_arg  # #todo:during-merge
        d = @argv.length
        "unexpected argument#{ 's' unless 1 == d }: #{
         @argv.map( & :inspect ) * TERM_SEPARATOR_STRING_ }. #{
          }expecting #{ infile_moniker }"
      end
      def when_argv_length_is_one
        @pathname = ::Pathname.new @argv.shift
        attempt_to_open_pathname
      end
      def attempt_to_open_pathname
        @stat = @pathname.stat
        when_pathname_exist
      rescue ::Errno::ENOENT => @e
        when_pathname_not_exist
      end
      def when_pathname_not_exist
        emit_error_string say_not_found
        CEASE_X__
      end
      def say_not_found
        "#{ infile_moniker } not found: #{ @pathname }"
      end
      def when_pathname_exist
        if FILE_S__ == @stat.ftype
          when_pathname_is_file
        else
          when_pathname_is_not_file
        end
      end
      FILE_S__ = 'file'.freeze
      def when_pathname_is_not_file
        emit_error_string say_is_not_file
        CEASE_X__
      end
      def say_is_not_file
        "#{ infile_moniker } is #{ @stat.ftype }: #{ @pathname }"
      end
      def when_pathname_is_file
        current_IO = @IO_adptr.instream
        current_IO && ! current_IO.tty? && ! current_IO.closed? and
          fail "sanity - won't overwrite existing open instream"
       @IO_adptr.instream = @pathname.open READ_MODE__
         # the above is #open-filehandle-1 --  don't loose track!
       PROCEDE_X__
      end
      READ_MODE__ = 'r'.freeze

      # ~

      def emit_error_string s
        @err_p[ s ] ; nil
      end

      def infile_moniker  # #todo:during-merge use expag instead
        # a hack to show whatever same label would be used in e.g. missing arg
        _stx = @get_stx_p[ @relevant_action_i ]
        _par = _stx.fetch_argument_at_index 0
        @par_lbl_p[ _par ]
      end  # (the above code as-is is a case study for :+[#bs-012])
    end
  end
end
