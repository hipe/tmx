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

    it "some comments and one section parses" do
      some_comments_and_one_section_parses
      expect_unparses
    end

    it "the subsection name parses" do
      the_subsection_name_parses
      expect_unparses
    end

    it "two section names parse" do
      two_section_names_parse
      expect_unparses
    end

    it "a bare word not in a section fails (with more detail)" do
      with 'moby'
      ev = subject.parse_string @input_string do |x| x end  # IDENTITY_
      ev.terminal_channel_i.should eql :expected_open_square_bracket
      ev.line_number.should eql 1
      ev.column_number.should eql 1
      ev.line.should eql 'moby'
    end

    it "a simple assignment works" do
      a_simple_assignment_works
      expect_unparses
    end

    it "a variety of other assignments work" do
      a_variety_of_other_assignments_work
      expect_unparses
    end

    def expect_config & p
      super do |config|
        @document = config
        p[ config ]
      end
    end

    def subject
      Brazen_::Data_Stores_::Git_Config::Mutable
    end

    def expect_unparses
      out_s = @document.unparse
      out_s.should eql @input_string
    end

    def unparse
      @document.unparse
    end
  end
end
