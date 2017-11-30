module Skylab::Brazen::TestSupport

  module CLI_Support::Expectations  # :[#007].

    # frozen state support & matchers for common CLI behavior
    #
    # possibly generic enough to be used outside of [br] maybe - our rubric
    # is exemplified by the fact that we model the success exitstatus but
    # not failure exitstatii here, because the former is almost universally
    # `0` but the latter is not.
    #
    # see also the more detailed "CLI behavior", with whose sections
    # our sections fugue.

    PUBLIC = true

    class << self

      def [] tcc
        tcc.include TestSupport_::Want_Stdout_Stderr::Test_Context_Instance_Methods
        tcc.include self
        NIL_
      end

      def mock_stderr_instance

        MOCK_STDERR__
      end
    end  # >>

    # -- freeze an invocation as a shared state

    def line_oriented_state_from_invoke * argv
      line_oriented_state_from_invoke_using(
        :mutable_argv, argv,
        :prefix, argv_prefix_for_want_stdout_stderr,
      )
    end

    def line_oriented_state_from_invoke_using * x_a

      using_want_stdout_stderr_invoke_via_iambic x_a

      _state = flush_frozen_state_from_want_stdout_stderr

      Line_Oriented_State___.new _state
    end

    # -- invocation

    def invoke * argv
      using_want_stdout_stderr_invoke_via_argv argv
    end

    def invocation_strings_for_want_stdout_stderr
      get_invocation_strings_for_want_stdout_stderr
    end

    s_a = nil
    define_method :get_invocation_strings_for_want_stdout_stderr do

      # override if you want the would-be program name in your assertions
      # to look more natural. see [#ts-029]#hook-out:1.

      s_a ||= [ 'xaz'.freeze ].freeze
    end

    def mock_stderr_instance_for_CLI_expectations

      MOCK_STDERR__
    end

    # -- the general shape of invocation (exitstatus, which streams)

    def result_for_failure_for_want_stdout_stderr
      Home_::CLI_Support::GENERIC_ERROR_EXITSTATUS
    end

    def match_successful_exitstatus
      eql Home_::CLI_Support::SUCCESS_EXITSTATUS
    end

    # -- macros (predicates over several lines)

    def want_usaged_and_invited
      want_usage_line
      want_generically_invited
    end

    # -- invalid / unexpected / expecting

    def want_whine_about_unrecognized_option s

      want_stdout_stderr_via invalid_option s
    end

    def invalid_option sw

      expectation "invalid option: #{ sw }"
    end

    def want_unrecognized_action sym

      want_stdout_stderr_via unrecognized_action sym
    end

    def unrecognized_action sym

      expectation "unrecognized action \"#{ sym }\""
    end

    def want_expecting_action_line

      want_stdout_stderr_via expecting_action_line
    end

    def expecting_action_line

      expectation :styled, "expecting <action>"
    end

    def want_unexpected_argument s

      want_stdout_stderr_via unexpected_argument s
    end

    def unexpected_argument s

      expectation :e, "unexpected argument #{ s.inspect }"
    end

    # -- usage (syntax summaries, suggestions)

    def want_usage_line
      want :styled, "usage: #{ _sub_program_name } <action> [..]"
    end

    def want_express_all_known_actions

      _s = want( :styled ) { |x| x }  # IDENTITY_
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

    # -- item-by-item parsing of helpscreens (oldchool)

    def want_option sym, rx=nil
      if rx
        _xtra_rxs = "[ ]{10,}.*#{ rx.source }.*"
      end
      s = sym.id2name
      want %r(\A[ ]{4,}-#{ s[0] }, --#{ s }#{ _xtra_rxs }\z)
    end

    def want_item sym, * x_a

      a = []

      if :styled == x_a.first
        a.push x_a.shift
      end

      rx = x_a.shift
      if rx
        _xtra_rxs = ".*#{ rx.source }.*"
      end

      s = sym.id2name

      a.push %r(\A[ ]{4,}<?#{ ::Regexp.escape s }>?[ ]{10,}#{ _xtra_rxs }\z)

      x = want( * a )

      while x_a.length.nonzero?
        d = x_a.length
        a.clear

        if :styled == x_a.first
          a.push x_a.shift
        end

        rx = x_a.first
        if rx
          x_a.shift
          a.push %r(\A[ ]{15,}.*#{ rx.source }.*\z)
        end

        d == x_a.length and raise ::ArgumentError, "#{ x_a.first.inspect }"

        x = want( * a )
      end
      x
    end

    # -- invitations

    def want_generically_invited
      want_generic_invite_line
      want_fail
    end

    def want_specifically_invited_to sym
      want_specific_invite_line_to sym
      want_fail
    end

    def want_generic_invite_line

      _want_styled_invite_to _sub_program_name
    end

    def want_specific_invite_line_to * sym_a

      _want_styled_invite_to _sub_program_name, * sym_a
    end

    def _sub_program_name

      get_invocation_strings_for_want_stdout_stderr.join SPACE_
    end

    def _want_styled_invite_to * parts

      want_stdout_stderr_via _styled_invite_to_parts parts
    end

    def styled_invite_to * parts

      _styled_invite_to_parts parts
    end

    def _styled_invite_to_parts parts

      parts.push Home_::CLI_Support::SHORT_HELP  # "-h"

      expectation :styled, "use '#{ parts * SPACE_ }' for help"
    end

    # -- bridge to help-screen-oriented shared state

    def only_line_of_section d

      node = state_.tree.children.fetch d
      if node.children_count.zero?
        node.x
      else
        expect( node.children_count ).to be_zero
      end
    end

    def first_line_of_section d

      state_.tree.children.fetch( d ).x
    end

    def section_child d, d_

      state_.tree.children.fetch( d ).children.fetch( d_ ).x
    end

    # -- bridge to line-oriented shared state

    def first_line
      state_.first_line
    end

    def second_line
      state_.second_line
    end

    def last_line
      state_.last_line
    end

    # --

    class Line_Oriented_State___

      def initialize state

        @exitstatus = state.exitstatus
        @_lines = state.lines
      end

      def stream_set
        @___ss ||= ___build_stream_set
      end

      def ___build_stream_set

        h = {}

        @_lines.each do | line_o |
          h[ line_o.stream_symbol ] = nil
        end

        h.keys.sort.freeze
      end

      def number_of_lines
        @_lines.length
      end

      def first_line
        @_lines.fetch 0
      end

      def second_line
        @_lines.fetch 1
      end

      def penultimate_line
        @_lines.fetch( -2 )
      end

      def last_line
        @_lines.fetch( -1 )
      end

      attr_reader(
        :exitstatus,
      )
    end

    MOCK_STDERR__ = class Mock_Stderr___
      def write s
        nil  # NIL_
      end
      self
    end.new
  end
end
