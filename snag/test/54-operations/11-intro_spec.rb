require_relative '../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] operations - intro" do

    TS_[ self ]
    use :operations

    # -- context: no argument

      it "API - no argument" do
        # :[#008.3]: #lend-coverage to [pl]
        call
        expect :error, :expression, :parse_error, :no_arguments do |msgs|
          expect_these_lines_in_array msgs do |y|
            y << %r(\Aavailable operators: ')
          end
        end
        expect_fail
      end

    # -- context: ping

      it "API - ping" do
        call :ping
        expect :info, :expression, :ping do |y|
          y == [ "snaggolio says *hello!*" ] || fail
        end
        expect_result :hello_from_snag
      end

    # --
  end
end
