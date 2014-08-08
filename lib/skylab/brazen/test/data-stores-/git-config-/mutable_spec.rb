require_relative 'test-support'

module Skylab::Brazen::TestSupport::Data_Stores_::Git_Config

  describe "[br] data stores: git config (mutable!)" do

    extend TS_

    it "the empty string parses" do
      expect_no_sections_from EMPTY_S_
      unparse.should eql EMPTY_S_
    end

    it "one space parses" do
      expect_no_sections_from SPACE_
      unparse.should eql SPACE_
    end

    def subject
      Brazen_::Data_Stores_::Git_Config::Mutable
    end

    def unparse
      @document.unparse
    end
  end
end
