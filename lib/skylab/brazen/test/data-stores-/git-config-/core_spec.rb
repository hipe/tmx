require_relative 'test-support'

module Skylab::Brazen::TestSupport::Data_Stores_::Git_Config

  describe "[br] data stores: git config" do

    it "the empty string parses" do
      expect_no_sections_from EMPTY_S_
    end

    it "one space parses" do
      expect_no_sections_from SPACE_
    end

    def expect_no_sections_from str
      conf = Subject_[].parse_string str
      conf.sections.length.should be_zero
    end
  end
end
