require_relative '../../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] slowie - operations - cover" do

    TS_[ self ]
    use :want_emission_fail_early
    use :slowie

    it "coverage is disabled, but at least it tells you this" do

      call :cover

      want :error, :expression, :furloughed do |y|

        y.first.include? '"cover" is furloughed' or fail
      end

      ignore_these_common_emissions_

      want_result UNABLE_
    end
  end
end
