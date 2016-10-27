require_relative '../../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] slowie - operations - cover" do

    TS_[ self ]
    use :slowie
    use :slowie_fail_fast

    it "coverage is disabled, but at least it tells you this" do

      call :cover

      expect :error, :expression, :furloughed do |y|

        y.first.include? '"cover" is furloughed' or fail
      end

      expect_result UNABLE_
    end
  end
end
