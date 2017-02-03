require_relative 'test-support'

module Skylab::Yacc2Treetop::TestSupport

  # <-

describe "[y2] CLI integration" do

  TS_[ self ]

  context "(reactive model)" do

    use :expect_event

    it "minimal normal case works" do

      _yacc_file = ::File.join( FIXTURES_PATH, '050.sequences.y3' )

      io = Home_::Build_string_IO__[]

      d = subject_API.translate(
        :downstream_IO, io,
        :wrap_in_grammar, 'Bingo::Bongo',
        :yacc_file, _yacc_file,
        & event_log.handle_event_selectively )

      expect_no_more_events
      d.should be_zero

      io.string.should eql <<-HERE.unindent
        # Autogenerated from yacc2treetop. Edits may be lost.
        module Bingo
          grammar Bongo
            # who hah yah yah
            # yah yah

            rule selectors_group
              selector ( COMMA S* selector )*
            end
          end
        end
      HERE
    end

    def subject_API
      Home_
    end
  end

  context "(CLI)" do

    use :memoizer_methods
    use :expect_CLI

    context 'doing nothing' do

      invoke

      it 'fails' do
        results_in_error_exitstatus_
      end

      it 'expecting' do

        _against _first_line
        expect :e, /\Aexpecting <yacc-file>\z/
      end

      it 'usage & invite' do

        _expect_usage_and_invited
      end
    end

    context 'asking for help' do

      invoke '-h'

      it 'succeeds' do
        results_in_success_exitstatus
      end

      it 'usage' do
        _index_of( 'usage' ).should eql 0
      end

      it 'description' do
        _index_of( 'description' ).should eql 2
      end

      it 'options' do
        _index_of( 'options' ).should eql 4
      end

      def _index_of s
        ___help_screen_state.lookup_index s
      end

      shared_subject :___help_screen_state do

        help_screen_oriented_state_via_invocation_state invocation_state_
      end
    end

    context 'giving 2 args' do

      invoke 'one', 'two'

      it 'fails' do
        results_in_error_exitstatus_
      end

      it 'unexpected' do

        _against _first_line
        expect :e, 'unexpected argument "two"'
      end

      it 'usage & invite' do
        _expect_usage_and_invited
      end
    end

    context 'giving it a nonexistant filename' do

      invoke_by do
        ::File.join TestSupport_.dir_path, 'not-there.yacc'
      end

      it 'fails' do
        results_in_error_exitstatus_
      end

      it 'writes specific complaint, usage, invite to stderr' do

        stdout_stderr_against_emission _first_line
        expect :e, /\ANo such file or directory: [-_\/\.a-zA-Z0-9]+\.yacc\z/
      end

      it 'invite' do
        _expect_invited
      end
    end

    context 'giving it a good filename' do

      invoke_by do
        ::File.join FIXTURES_PATH, '060.choice-parse.y3'
      end

      it 'succeeds' do
        results_in_success_exitstatus
      end

      it 'writes a treetop grammar to stdout' do

        expect :o, "# Autogenerated from yacc2treetop. Edits may be lost."
        expect :o, "rule simple_selector_sequence"
        expect :o, "  ( type_selector / universal )"
        expect :o, /\A    \( HASH \/ class \//
        expect :o, 'end'
        expect_no_more_lines
      end
    end

    it "[tmx] integration (stowaway)", TMX_CLI_integration: true do

      ::Skylab::Common::Autoloader.require_sidesystem :TMX

      cli = ::Skylab::TMX.test_support.begin_CLI_expectation_client

      cli.invoke 'yacc2treetop', '--ping'

      cli.expect_on_stderr "hello from yacc2treetop."

      cli.expect_succeed_under self
    end

    # (the below is experimental fringe to feed into [#br-007])

    # -- the general shape of invocation (exitstatus)

    def results_in_error_exitstatus_
      invocation_state_.exitstatus.should match_common_error_code_
    end

    def match_common_error_code_
      eql result_for_failure_for_expect_stdout_stderr
    end

    def results_in_success_exitstatus
      invocation_state_.exitstatus.should be_zero
    end

    # -- macros (predicates over several lines)

    def _expect_usage_and_invited

      _penultimate_line.should match_ __usage_line

      _expect_invited
    end

    # -- invalid / unexpected / expecting

    # -- usage (syntax summaries, suggestions)

    _share :__usage_line do

      expectation :styled, :e, 'usage: y2tt [opts] { <yacc-file> | "-" }'
    end

    # -- invitations

    def _expect_invited

      _last_line.should match_ ___invite_line
    end

    _share :___invite_line do

      expectation :styled, :e, 'y2tt -h for help'
    end

    # -- set subject

    def _against em
      stdout_stderr_against_emission em
    end

    def _first_line
      _lines.fetch 0
    end

    def _penultimate_line
      _lines.fetch( -2 )
    end

    def _last_line
      _lines.fetch( -1 )
    end

    def _lines
      invocation_state_.lines
    end

  end  # end CLI context
end  # end file describe
# ->
end  # end test support module
