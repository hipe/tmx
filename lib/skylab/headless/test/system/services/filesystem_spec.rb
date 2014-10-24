require_relative 'test-support'

module Skylab::Headless::TestSupport::System::Services

  describe "[hl] system services filesystem" do

    extend TS_

    it "loads" do
      subject
    end

    def subject
      super.filesystem
    end
  end
end
