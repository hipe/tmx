require_relative '../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] operations - intro" do

    TS_[ self ]
    use :operations

    # -- context: no argument

      it "API - no argument" do
        # :[#008.3]: #lend-coverage to [pl]
        call
        want :error, :expression, :parse_error, :no_arguments do |msgs|
          want_these_lines_in_array msgs do |y|
            y << %r(\Aavailable operators: ')
          end
        end
        want_fail
      end

    # -- context: ping

      it "API - ping" do
        call :ping
        want :info, :expression, :ping do |y|
          y == [ "snaggolio says *hello!*" ] || fail
        end
        want_result :hello_from_snag
      end

    # --
  end
end
