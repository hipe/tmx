module Skylab::Zerk::TestSupport

  module Non_Interactive_CLI

    # just a hopefully semi-thin layer on top of "expect stdout stderr"

    def self.[] tcc
      TS_::Expect_Stdout_Stderr[ tcc ]
      tcc.send :define_singleton_method, :given, Given___
      tcc.include self
    end

    # -
      Given___ = -> & p do

        # does two things: 1) holds a context for a hopefully obvious DSL
        # (right now consisting of only the term `argv`), a DSL for
        # expressing all the input conditions that go into a testable
        # invocation and 2) each time you call `given`, whatever (`it`)
        # tests are sibling to this `given` (and below recursively; unless
        # there is another nested `given` somewhere); all of these tests will
        # share *the same instance* (the *same* instance) of a [#ts-042]
        # "dangerously memoized" "state" structure (tuple):

        yes = true ; x = nil
        define_method :niCLI_state do
          if yes
            yes = false
            x = __build_state_for_niCLI_by( & p )
          end
          x
        end
      end
    # -

    # -
      # -- assertion of line content

      def be_general_invite_line_from_root

        s_a = invocation_strings_for_expect_stdout_stderr

        _exp = expectation :styled,
          :e, "use '#{ s_a.join SPACE_ } -h' for help"

        match_ _exp
      end

      def look_like_full_splay_of_ * s_a

        _s_a_ = s_a.map { |s| "'#{ s }'" }

        be_line :styled, :e,
          "expecting <compound-or-operation>: { #{ _s_a_.join ' | ' } }"
      end

      def be_expecting_line_unadorned__
        be_line :styled, :e, 'expecting <compound-or-operation>'
      end

      def be_stack_sensitive_usage_line
        be_line :styled, :e, "usage: '#{ _build_pn } <compound-or-operation> [..]'"
      end

      def be_invite_with_no_focus
        be_line :styled, :e, "see '#{ _build_pn } -h' for more."
      end

      def be_invite_with_option_focus
        _niCLI_be_invite 'options'
      end

      def be_invite_with_argument_focus
        _niCLI_be_invite 'arguments'
      end

      def _niCLI_be_invite s
        be_line :styled, :e, "see '#{ _build_pn } -h' for more about #{ s }"
      end

      def _build_pn

        curr = niCLI_state.invocation.top_frame_

        s_a = []
        begin
          nf = curr.name
          nf or break
          s_a.push nf.as_slug
          curr = curr.next_frame_
          redo
        end while nil

        s_a_ = invocation_strings_for_expect_stdout_stderr.dup
        s_a.reverse!
        s_a_.concat s_a
        s_a_.join SPACE_
      end

      # REMINDER: `line` means emission-line (the structure). we don't
      # convert them this early because we often have to de-style them
      # and that is part of the assertion, not done here.

      def only_line
        a = _lines_tuple
        1 == a.length or fail
        a.fetch 0
      end

      def first_line_content
        __line_content_hack 0
      end

      def first_line_string
        first_line.string
      end

      def first_line
        _lines_tuple.fetch 0
      end

      def second_line
        _lines_tuple.fetch 1
      end

      def last_line
        _lines_tuple.fetch( -1 )
      end

      def third_and_final_line
        a = _lines_tuple
        3 == a.length or fail
        a.fetch 2
      end

      def __line_content_hack d
        a = _lines_tuple
        s = a.fetch( d ).string
        s.chomp!
        a[ d ] = :_used_
        s
      end

      def number_of_lines
        _lines_tuple.length
      end

      def _lines_tuple
        niCLI_state.lines
      end

      # -- exitstatus & derived

      def fails
        exitstatus.should be_nonzero
      end

      def expect_exitstatus_for_referent_not_found_
        expect_exitstatus_for :_referent_not_found_
      end

      def expect_exitstatus_for k
        _d = Home_::Non_Interactive_CLI::Exit_status_for___[ k ]
        exitstatus.should eql _d
      end

      def succeeds
        exitstatus.should be_zero
      end

      def exitstatus
        niCLI_state.exitstatus
      end

      # -- invocation

      def coarse_parse_via_invoke * argv  # see also "help screens"

        using_expect_stdout_stderr_invoke_via_argv argv
        # (result is nil. ivars are set.)
        _lines = release_lines_for_expect_stdout_stderr
        TS_::Non_Interactive_CLI::Help_Screens::Coarse_Parse.new _lines
      end

      def __build_state_for_niCLI_by & p

        @_tmp_for_niCLI = DSL_Argument_Receiver___.new

        instance_exec( & p )  # typically only `argv` is called

        _argv, = remove_instance_variable( :@_tmp_for_niCLI ).to_a

          # (the above may grow when we test input beyond ARGV..)

        _build_state_for_niCLI_via _argv
      end

      def build_state_for_niCLI_via_invoke__ * argv
        _build_state_for_niCLI_via argv
      end

      def _build_state_for_niCLI_via argv

        using_expect_stdout_stderr_invoke_via_argv argv

        # based off of `flush_frozen_state_from_expect_stdout_stderr`:

        My_State___.new(
          remove_instance_variable( :@exitstatus ),
          release_lines_for_expect_stdout_stderr,
          remove_instance_variable( :@invocation ),
        )
      end

      My_State___ = ::Struct.new :exitstatus, :lines, :invocation

      def subject_CLI

        # strange looking because: this is a hook-out for our one dependency
        # lib. normally it produces an ordinary class. but the [ze] niCLI
        # is not yet "class-based" but [see].
        #
        # our urge is to memoize this (somehow) "alongside" the state that
        # we are memoizing, but there is no real reason to.

        cli = Home_::NonInteractiveCLI.begin

        _class = subject_root_ACS_class

        cli.root_ACS = -> & oes_p do

          _class.new_cold_root_ACS_for_niCLI_test( & oes_p )
        end

        cli.to_classesque
      end

      DSL_Argument_Receiver___ = ::Struct.new :argv
      def argv * argv
        @_tmp_for_niCLI.argv = argv ; nil
      end

      # TestSupport_::Memoization_and_subject_sharing[ self ]

      define_method :invocation_strings_for_expect_stdout_stderr, ( Lazy_.call do
        [ 'xyzi' ]
      end )

      # -- assertion support

      def result_for_failure_for_expect_stdout_stderr
        Home_::GENERIC_ERROR_EXITSTATUS
      end
    # -

    Here_ = self
  end
end
# #tombstone: we once built state \"manually\" with our own structure
