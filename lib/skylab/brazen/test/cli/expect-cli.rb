require_relative 'test-support'  # some clients come in from the top

module Skylab::Brazen::TestSupport::CLI

  module Expect_CLI

    class << self

      def [] tcm

        tcm.include TestSupport_::Expect_Stdout_Stderr::Test_Context_Instance_Methods
        tcm.send :define_method, :expect, tcm.instance_method( :expect )  # :+#this-rspec-annoyance
        tcm.include self

        mem = Yikes_memoizer_for___[ tcm ]

        mem.call :program_name_for_expect_CLI do
          invocation_strings_for_expect_stdout_stderr.join SPACE_
        end

        mem.call :invocation_strings_for_expect_stdout_stderr do
          get_invocation_strings_for_expect_stdout_stderr.
            each( & :freeze ).freeze
        end

        mem.call :short_category_s
      end

      def mock_stderr_instance

        MOCK_STDERR__
      end
    end  # >>

    def mock_stderr_instance_for_expect_CLI

      MOCK_STDERR__
    end

    def invoke * argv
      using_expect_stdout_stderr_invoke_via_argv argv
    end

    # ~ assertion phase (ad-hocs)

    ## ~~ exposures to other facilities

    def flush_help_screen_to_tree

      _st = sout_serr_line_stream_for_contiguous_lines_on_stream :e

      Home_::TestSupport::CLI::Expect_Section.tree_via_line_stream_ _st
    end

    ## ~~ our own

    def expect_whine_about_unrecognized_action x
      expect :styled,
        %r(\Aunrecognized action:? ['"]?#{ ::Regexp.escape x }['"]?\z)i
    end

    def expect_whine_about_unrecognized_option x
      expect "invalid option: #{ x }"
    end

    def expect_express_all_known_actions

      _s = expect( :styled ) { |x| x }  # IDENTITY_
      _a = /\Aknown actions are \('([^\)]+)'\)\z/.match( _s )[ 1 ].split( "', '" )

      _s_a = the_list_of_all_visible_actions_for_expect_CLI

      h = ::Hash[ _s_a.map { |s| [ s, true ] } ]

      _a.each do | s |
        h.delete( s ) or fail self.__TODO_say_extra_action( s )
      end

      if h.length.nonzero?
        fail self.__TODO_say_missing_actions( h.keys )
      end
    end

    def expect_generic_expecting_line
      expect :styled, "expecting <action>"
    end

    def expect_usaged_and_invited
      expect_usage_line
      expect_generically_invited
    end

    def expect_usage_line
      expect :styled, "usage: #{ program_name_for_expect_CLI } <action> [..]"
    end

    def expect_generically_invited
      expect_generic_invite_line
      expect_failed
    end

    def expect_specifically_invited_to sym
      expect_specific_invite_line_to sym
      expect_failed
    end

    def expect_generic_invite_line

      _expect_styled_invite_to program_name_for_expect_CLI
    end

    def expect_specific_invite_line_to * sym_a

      _expect_styled_invite_to program_name_for_expect_CLI, * sym_a
    end

    def _expect_styled_invite_to * parts

      # we are saving name inflection for when we need it

      parts.push '-h'
      expect :styled, "use '#{ parts * SPACE_ }' for help"
    end

    def result_for_failure_for_expect_stdout_stderr
      _memo.generic_error
    end

    MOCK_STDERR__ = class Mock_Stderr___
      def write s
        nil  # NIL_
      end
      self
    end.new

    define_method :_memo, ( Callback_.memoize do

      a = [] ; a_ = []

      es = Home_::API.exit_statii

      a.push :generic_error ; a_.push es.fetch( :generic_error )

      Memo___ = ::Struct.new( * a ).new( * a_ )
    end )

    Yikes_memoizer_for___ = -> cls do

      -> m, & p do

        val_p = nil

        cls.send :define_method, m do

          if val_p
            val_p[]
          else
            x = instance_exec( & p )
            val_p = -> { x }
            x
          end
        end
      end
    end
  end
end
