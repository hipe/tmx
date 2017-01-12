require_relative '../test-support'

module Skylab::System::TestSupport

  describe "[sy] filesystem (stub)" do

    TS_[ self ]

    it "loads" do
      __subject
    end

    def __subject
      services_.filesystem
    end
  end
end
