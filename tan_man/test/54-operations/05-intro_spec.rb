require_relative '../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - intro" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_CLI_or_API

    it "the API is called with `call` - the empty call reports as error" do

      call_API

      expect :error, :expression, :parse_error, :no_arguments do |a|

        expect_these_lines_in_array_ a do |y|
          y << /\Aavailable operators: '/
        end
      end

      expect_fail
    end

    context "call with strange name" do

      it "fails (soft error)" do
        _lines || fail
      end

      it "first line" do
        _lines.first == "unrecognized operator: 'wazii'" || fail
      end

      it "second line (flickering?)" do

        # (the number of items should be the number of commas plus two)

        _ = /\Aavailable operators: /.match( _lines.last ).post_match

        _d = Home_.lib_.basic::String.count_occurrences_in_string_of_string(
          _, ', ' )

        (9..9).should be_include _d
      end

      shared_subject :_lines do

        call_API :wazii, :wazoo

        lines = nil
        expect :error, :expression, :parse_error, :unknown_operator do |y|
          lines = y
        end

        expect_fail
        lines
      end
    end

    it "xtra tokens on a ping" do

      call_API :ping, :wahootey

      expect :error, :argument_error, :unknown_primary do |ev|

        _a = ev.express_into_under [], expression_agent
        expect_these_lines_in_array_ _a do |y|
          y << "unrecognized attribute :wahootey"
          y << "expecting no attributes"  # #lends-coverage to [#fi-008.15]
        end
      end

      expect_fail
    end

    it "sing sing sing to me" do

      call_API :ping

      expect :info, :ping do |ev|

        _y = ev.express_into_under [], expression_agent
        _y == [ "tannimous mannimous says *hello*" ] || fail
      end

      expect_result :hello_from_tan_man
    end
  end
end
