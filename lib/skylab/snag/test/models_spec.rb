require_relative 'test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models" do

    extend TS_
    use :expect_event

    it "loads" do
      Snag_::Models_
    end
  end
end
