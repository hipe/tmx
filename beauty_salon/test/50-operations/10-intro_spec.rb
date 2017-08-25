# frozen_string_literal: true

require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] operations - intro' do

    TS_[ self ]
    use :memoizer_methods
    use :expect_emission_fail_early
    use :modality_agnostic_interface_things

    context '1.1) strange arg' do

      it 'fails' do
        _tuple || fail
      end

      it 'whines' do
        _actual = _tuple.first.first
        _actual == %q(unrecognized operator: 'wazoo') || fail
      end

      it 'splays' do

        _actual = _tuple.first.last

        _expected = _line_about_available_operators

        _actual == _expected || fail
      end

      shared_subject :_tuple do

        call :wazoo

        tuple = []
        expect :error, :expression, :parse_error, :unknown_operator do |lines|
          tuple.push lines
        end

        expect_API_result_for_failure_
        tuple
      end
    end

    context '0) no arg' do

      it 'fails' do
        _tuple || fail
      end

      it 'only line one' do
        _actual = _tuple.first
        _actual == [ _line_about_available_operators ] || fail
      end

      shared_subject :_tuple do

        call

        tuple = []
        expect :error, :expression, :parse_error, :no_arguments do |lines|
          tuple.push lines
        end

        expect_API_result_for_failure_
        tuple
      end
    end

    context '1.3) moneytown' do

      it 'result is symbol' do
        _tuple || fail
      end

      it 'expression is styled' do
        _actual = _tuple.first
        _actual == [ '[bs] says *hello*' ] || fail
      end

      shared_subject :_tuple do

        call :ping

        tuple = []
        expect :info, :expression, :hello do |y|
          tuple.push y
        end

        expect_result :hello_from_beauty_salon
        tuple
      end
    end

    -> do
      line = nil
      define_method :_line_about_available_operators do
        line ||= __build
      end
    end.call

    def __build

      _these = all_toplevel_actions_normal_symbols_.map { |s| "'#{ s }'" }

      my_oxford_and_ "available operator", ": ", _these
    end

    def expect_API_result_for_failure_
      expect_result nil
    end

    def expression_agent
      ::NoDependenciesZerk::API_InterfaceExpressionAgent.instance
    end

    def ignore_emissions_whose_terminal_channel_is_in_this_hash
      NOTHING_
    end

    def subject_API
      Home_::API::API2  # #open [#023]
    end
  end
end
# born.
