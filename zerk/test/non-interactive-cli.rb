module Skylab::Zerk::TestSupport

  module Non_Interactive_CLI

    # just a hopefully semi-thin layer on top of "expect stdout stderr"

    PUBLIC = true  # [dt]

    def self.[] tcc
      Use_::Expect_stdout_stderr[ tcc ]
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
            x = instance_exec( & p )  # tombstone has DSL
          end
          x
        end
      end
    # -

    # -
      # -- assertion for general state

      def output line_content
        o = Expectation_over_Whole_State___.new
        o._expected_single_output_line_content = line_content
        o.finish
      end

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

      def be_line_about_expecting_compound_or_operation
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

        curr = niCLI_state.invocation.top_frame

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

      def assemble_big_string_on e_or_o

        buffer = ""
        _niCLI_state_lines.each do |li|
          if e_or_o == li.stream_symbol
            buffer.concat li.string
          end
        end
        buffer
      end

      # REMINDER: `line` means emission-line (the structure). we don't
      # convert them this early because we often have to de-style them
      # and that is part of the assertion, not done here.

      def to_output_line_stream
        Common_::Stream.via_nonsparse_array( niCLI_state.lines ).map_reduce_by do |li|
          if :o == li.stream_symbol
            li.string
          end
        end
      end

      def only_line
        a = _niCLI_state_lines
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
        _niCLI_state_lines.fetch 0
      end

      def second_line
        _niCLI_state_lines.fetch 1
      end

      def last_line
        _niCLI_state_lines.fetch( -1 )
      end

      def third_and_final_line
        a = _niCLI_state_lines
        3 == a.length or fail
        a.fetch 2
      end

      def __line_content_hack d
        a = _niCLI_state_lines
        s = a.fetch( d ).string
        s.chomp!
        a[ d ] = :_used_
        s
      end

      def number_of_lines
        _niCLI_state_lines.length
      end

      def _niCLI_state_lines
        niCLI_state.lines
      end

      # -- exitstatus & derived

      def fails
        exitstatus.should be_nonzero
      end

      def expect_exitstatus_for_referent_not_found_
        expect_exitstatus_for :referent_not_found
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

      def argv * argv  # see DSL tombstone
        argv_array argv
      end

      def argv_array argv

        using_expect_stdout_stderr_invoke_via_argv argv

        # based off of `flush_frozen_state_from_expect_stdout_stderr`:

        My_State___.new(
          remove_instance_variable( :@exitstatus ),
          release_lines_for_expect_stdout_stderr,
          remove_instance_variable( :@invocation ),
        )
      end

      My_State___ = ::Struct.new(
        :exitstatus,
        :lines,
        :invocation,
        :freeform_x,  # [sa]
      )

      def subject_CLI

        # strange looking because: this is a hook-out for our one dependency
        # lib. normally it produces an ordinary class. but the [ze] niCLI
        # is not yet "class-based" but [see].
        #
        # our urge is to memoize this (somehow) "alongside" the state that
        # we are memoizing, but there is no real reason to.

        cli = Home_::NonInteractiveCLI.begin

        _class = subject_root_ACS_class

        cli.root_ACS_by do  # #cold-model
          _class.new_cold_root_ACS_for_niCLI_test
        end

        cli.to_classesque
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

    # ==

    class Expectation_over_Whole_State___

      attr_writer(
        :_expected_single_output_line_content,
      )

      def finish
        self
      end

      def matches? state
        state.exitstatus.zero? or fail
        a = state.lines
        a.length == 1 or fail
        s = a.first.string
        _yes = s.chomp!
        if _yes
          if s == @_expected_single_output_line_content
            ACHIEVED_
          else
            @__had_s = s
            _fail_by :__say_line_did_not_match
          end
        else
          _fail_by :__say_line_did_not_end_with_newline  # not written
        end
      end

      def _fail_by m
        raise send m
      end

      def __say_line_did_not_match
        "expected #{ @_expected_single_output_line_content.inspect }, had #{ @__had_s.inspect }"
      end
    end

    Here_ = self
  end
end
# #tombstone: we once had room for a more sophisticated DSL but didn't use it
# #tombstone: we once built state \"manually\" with our own structure
