module Skylab::Brazen::TestSupport

  module CLI::Expectations

    PUBLIC = true

    class << self

      def [] tcc

        tcc.include TestSupport_::Expect_Stdout_Stderr::Test_Context_Instance_Methods

        tcc.send :define_method, :expect, tcc.instance_method( :expect )  # :+#this-rspec-annoyance

        tcc.include self

        NIL_
      end

      def mock_stderr_instance

        MOCK_STDERR__
      end
    end  # >>

    def mock_stderr_instance_for_CLI_expectations

      MOCK_STDERR__
    end

    def invoke * argv
      using_expect_stdout_stderr_invoke_via_argv argv
    end

    def invocation_strings_for_expect_stdout_stderr
      get_invocation_strings_for_expect_stdout_stderr
    end

    def _pn
      get_invocation_strings_for_expect_stdout_stderr.join SPACE_
    end

    s_a = nil
    define_method :get_invocation_strings_for_expect_stdout_stderr do

      # override if you want the would-be program name in your assertions
      # to look more natural. see [#ts-029]#hook-out:1.

      s_a ||= [ 'xaz'.freeze ].freeze
    end

    # ~ assertion phase (ad-hocs)

    ## ~~ exposures to other facilities

    def flush_help_screen_to_tree

      _st = sout_serr_line_stream_for_contiguous_lines_on_stream :e

      Home_::TestSupport::CLI::Expect_Section.tree_via_line_stream_ _st
    end

    ## ~~ our own

    def expect_unexpected_argument s
      expect :e, "unexpected argument #{ s.inspect }"
    end

    def expect_unrecognized_action sym
      expect "unrecognized action \"#{ sym }\""
    end

    def expect_whine_about_unrecognized_option x
      expect "invalid option: #{ x }"
    end

    def expect_express_all_known_actions

      _s = expect( :styled ) { |x| x }  # IDENTITY_
      _a = /\Aknown actions are \('([^\)]+)'\)\z/.match( _s )[ 1 ].split( "', '" )

      _s_a = the_list_of_all_visible_actions_for_CLI_expectations

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
      expect :styled, "usage: #{ _pn } <action> [..]"
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

      _expect_styled_invite_to _pn
    end

    def expect_specific_invite_line_to * sym_a

      _expect_styled_invite_to _pn, * sym_a
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
  end
end
