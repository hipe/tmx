require_relative '../../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - hear - meaning - apply" do

    TS_[ self ]
    use :expect_line

    it "add meaning"

    it "associate meaning" do

      s = <<-HERE.unindent
        digraph{
          # done: style=filled
          foo [label="foo"]
        }
      HERE

      call_API(
        :hear,
        :word, %w( foo is done ),
        :input_string, s,
        :output_string, s )

      expect_OK_event :updated_attributes
      @output_s = s
      excerpt( 2 .. 2 ).should eql "  foo [label=\"foo\", style=filled]\n"
    end
  end
end
