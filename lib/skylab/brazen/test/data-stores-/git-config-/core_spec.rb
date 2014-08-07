require_relative 'test-support'

module Skylab::Brazen::TestSupport::Data_Stores_::Git_Config

  describe "[br] data stores: git config" do

    it "the empty string parses" do
      conf = Subject_[].parse_string EMPTY_S_
      conf.sections.length.should be_zero
    end
  end
end
