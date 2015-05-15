require_relative 'test-support'

module Skylab::Brazen::TestSupport::Collection_Adapters::Git_Config

  describe "[br] data stores: git config" do

    extend TS_

    it "the empty string parses" do
      expect_no_sections_from EMPTY_S_
    end

    it "one space parses" do
      expect_no_sections_from SPACE_
    end

    it "a section and a comment parses" do
      a_section_and_a_comment_parses
    end

    it "some comments and one section parses" do
      some_comments_and_one_section_parses
    end

    it "the subsection name parses" do
      the_subsection_name_parses
    end

    it "two section names parse" do
      two_section_names_parse
    end

    it "a bare word not in a section fails" do
      a_bare_word_not_in_a_section_fails
    end

    it "a simple assignment works" do
      a_simple_assignment_works
    end

    it "a variety of other assignments work" do
      a_variety_of_other_assignments_work
    end

    def subject
      Brazen_::Collection_Adapters::Git_Config
    end

  end
end
