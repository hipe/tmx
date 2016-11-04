require_relative '../../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] slowie - operations - intro" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_emission_fail_early
    use :slowie

    it "loads" do
      Home_::Slowie
    end

    context "strange" do

      it "first line talkin bout unknown" do

        _lines.first == "unknown primary :strange" || fail
      end

      it "second line talkin bout expecting" do
        _lines.last.include?( "expecting :" ) || fail
      end

      shared_subject :_lines do

        call :strange

        lines = nil
        expect :error, :expression, :parse_error, :unknown_primary do |y|
          lines = y
        end

        expect_result UNABLE_

        lines
      end
    end

    it "ping" do

      call :ping

      expect :info, :expression, :ping do |y|

        y.first == "ping: Skylab::Zerk::API::ArgumentScannerExpressionAgent" || fail
      end

      ignore_emissions_whose_terminal_channel_symbol_is :operator_resolved

      expect_result :_hello_from_slowie_
    end
  end
end
