require_relative '.././test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] paths" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_CLI_or_API

    # (largely the tests here are for covering integration of the MSTk
    #  with the use of a simple attributes actor which remarkably seems
    #  to work out well and required only a few lines..)

    context "missing" do

      it "fails" do
        _tuple || fail
      end

      it "explains" do

        expect_these_lines_in_array_ _tuple do |y|
          y << "missing required parameters :path and :verb\n"
        end
      end

      shared_subject :_tuple do

        call_API :paths

        lines = nil
        expect :error, COMMON_MISS_ do |ev|
          lines = black_and_white_lines ev
        end

        expect_fail

        lines
      end
    end

    context "extra" do

      it "fails" do
        _tuple || fail
      end

      it "explains (only the first unrecognized token)" do

        expect_these_lines_in_array_ _tuple do |y|
          y << 'unrecognized attribute :wiz'
        end
      end

      shared_subject :_tuple do

        call_API :paths, :wiz, :waz, :wazoozle

        lines = nil
        expect :error, :argument_error, :unknown_primary do |ev|
          lines = black_and_white_lines ev
        end

        expect_fail

        lines
      end
    end

    context "(swap in other expag)" do

      it "strange verb" do

        call_API :paths, :path, :generated_grammar_dir, :verb, :wiznippl

        expect :error, :unrecognized_verb do |ev|
          _a = black_and_white_lines ev
          expect_these_lines_in_array_ _a do |y|
            y << 'unrecognized verb "wiznippl". did you mean "retrieve"?'
          end
        end

        expect_fail
      end

      it "strange noun" do

        call_API :paths, :path, :waznoozle, :verb, :retrieve

        expect :error, :unknown_path do |ev|
          _a = black_and_white_lines ev
          expect_these_lines_in_array_ _a do |y|
            y << 'unknown path "waznoozle". did you mean "generated-grammar-dir"?'
          end
        end

        expect_fail
      end

      it "retrieves (and possibly generates) the GGD path" do

        # it may or may not emit events based on whether the dir already existed
        call_API :paths, :path, :generated_grammar_dir, :verb, :retrieve

        ignore_emissions_whose_terminal_channel_symbol_is :creating_directory  # #open [#086]

        _result = execute

        _tail = ::File.basename _result

        _tail == Home_.lib_.tmpdir_stem || fail
      end

      def black_and_white_expression_agent_for_expect_emission
        expression_agent_for_CLI_TM
      end
    end

    # ==
    # ==
  end
end
