require_relative '../../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] collection adapters - git config - mutable - canon" do

    TS_[ self ]
    use :collection_adapters_git_config_mutable

    it "the empty string parses" do
      want_no_sections_from EMPTY_S_
      expect( unparse ).to eql EMPTY_S_
    end

    it "one space parses" do
      want_no_sections_from SPACE_
      expect( unparse ).to eql SPACE_
    end

    it "a section parses" do
      a_section_parses
      want_unparses
    end

    it "a section and a comment parses" do
      a_section_and_a_comment_parses
      want_unparses
    end

    it "some comments and one section parses" do
      some_comments_and_one_section_parses
      want_unparses
    end

    it "the subsection name parses" do
      the_subsection_name_parses
      want_unparses
    end

    it "two section names parse" do
      two_section_names_parse
      want_unparses
    end

    it "a bare word not in a section fails (with more detail)" do

      with 'moby'

      chan_i_a = nil
      ev = nil

      _x = subject_module_document_via_string_ @input_string do |*i_a, &ev_p|
        chan_i_a = i_a
        ev = ev_p[]
        :_BR_NO_SEE_
      end

      _x == false || fail

      expect( chan_i_a ).to eql [ :error, :config_parse_error ]
      ev.terminal_channel_symbol == :config_parse_error || fail
      expect( ev.parse_error_category_symbol ).to eql :expected_open_square_bracket
      expect( ev.lineno ).to eql 1
      expect( ev.column_number ).to eql 1
      expect( ev.line ).to eql 'moby'
    end

    it "a simple assignment works" do
      a_simple_assignment_works
      want_unparses
    end

    it "a variety of other assignments work" do
      a_variety_of_other_assignments_work
      want_unparses
    end

    def want_config & p
      super do |config|
        @document = config
        p[ config ]
      end
    end

    def want_unparses
      out_s = @document.unparse
      expect( out_s ).to eql @input_string
    end

    def unparse
      @document.unparse
    end
  end
end
