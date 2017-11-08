# frozen_string_literal: true

require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy town reports - echo file paths', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :my_reports

    it 'API const loads' do
      Home_::API || fail
    end

    it 'the "file paths" report (the equivalent of `ping`) - just echos the paths, no parse' do

      same = %w( floofie flaffie )

      # -
        _anticipate_no_emissions
        _st = _call do |o|
          o.argument_paths = same
        end
      # -

      _actual = _st.to_a
      _actual == same || fail
    end

    context 'if you pass pass a strange macro name' do

      # :#coverpoint4.1

      it 'fails' do
        _fails
      end

      it 'first message' do
        _msg = _messages.fetch(0)
        _msg == %q(unknown macro: 'foo_bar'.) || fail
      end

      it 'second message' do
        _msg = _messages.fetch(1)
        _msg == "expecting 'method'" || fail  # ..
      end

      shared_subject :_messages do
        # (make it look like two lines when it is mushed to one, just for etc)
        msgs = _tuple.fetch 1
        if 1 == msgs.length
          msgs.fetch(0).split %r((?<=\.)[ ]), 2
        else
          msgs
        end
      end

      shared_subject :_tuple do
        _expect_failure_tuple_by_call :parse_error do |o|
          o.macro_string = 'foo-bar'
        end
      end
    end

    it 'if you pass multiple ways, it whines' do

      _anticipate :error, :expression, :argument_error do |y|
        y == [%q(can't have both --files-file and <files>)] || fail  # ..
      end

      _x = _call do |o|
        o.macro_string = 'method'
        o.argument_paths = [ 'hizz' ]
        o.files_file = 'ffxx1'
      end
      _x.nil? || fail
    end

    it %q(if you don't pass the one kind of parameter corresponding to macro, whines) do

      _anticipate :error, :expression, :argument_error do |y|
        y == [%q(when you employ 'macro', you must employ 'files', not 'files_file')] || fail
      end

      _x = _call do |o|
        o.macro_string = 'method'
        o.files_file = 'ffxx2'
      end

      _x.nil? || fail
    end

    it %q(if you don't pass any, whines) do

      _anticipate :error, :expression, :argument_error do |y|
        y == ["must have one of --files-file, <files> or --corpus-step"] || fail  # ..
      end

      _x = _call do |o|
        o.macro_string = 'method'
      end

      _x.nil? || fail
    end

    same = [ 'aa', 'bb' ]

    it 'you need to pass a delimiter' do

      _anticipate :error, :expression, :argument_error do |y|
        y == ['expecting delimiter ":" or "/" at end of macro string'] || fail
      end

      _x = _call do |o|
        o.macro_string = 'method'
        o.argument_paths = same
      end

      _x.nil? || fail
    end

    it 'you need to pass a search term' do

      _anticipate :error, :expression, :argument_error do |y|
        y == ['expecting unsanitized before string near ":"'] || fail
      end

      _x = _call do |o|
        o.macro_string = 'method::'
        o.argument_paths = same
      end

      _x.nil? || fail
    end

    it 'MONEY' do

      _anticipate_no_emissions

      _st = _call do |o|
        o.macro_string = 'method:fixed_string1'
        o.argument_paths = [
          Ruby_current_version_dir_[],
          Fixture_function_dir_[],
        ]
      end

      _st = _st.map_by do |path|
        Stem_via_filesystem_path_[ path ]
      end

      expect_these_lines_in_array_ _st do |y|
        # (this order is system dependend. #fragile-test)
        y << '500-expression-grouping'
        y << 'la-la-010'
        y << 'la-la-020'
      end
    end

    # ==

    def _messages
      _tuple.fetch 1
    end

    def _fails
      _x = _tuple.first
      _x.nil? || fail
    end

    def _expect_failure_tuple_by_call * chan

      msgs = nil
      _anticipate :error, :expression, * chan do |y|
        msgs = y
      end

      _x = _call do |o|
        yield o
      end

      [ _x, msgs ]
    end

    def _anticipate * chan, & msg

      spy = Common_.test_support::Expect_Emission_Fail_Early::Spy.new
      spy.expect_emission msg, chan
      @EMISSION_SPY = spy ; nil
    end

    def _anticipate_no_emissions
      @EMISSION_SPY = nil
    end

    def _call

      spy = remove_instance_variable :@EMISSION_SPY
      if spy
        _use_listener = spy.listener
      end

      _use_p = -> o do
        yield o
        o.listener = _use_listener
      end

      same = -> do
        call_report_ _use_p, :echo_file_paths
      end

      if spy
        spy.call_by do
          same[]
        end
        spy.execute_under self
      else
        same[]
      end
    end

    def expression_agent
      Expression_agent_preferred_[]
    end

    def ignore_emissions_whose_terminal_channel_is_in_this_hash
      NOTHING_
    end

    # ==
    # ==
  end
end
# #broke-out of sibling
