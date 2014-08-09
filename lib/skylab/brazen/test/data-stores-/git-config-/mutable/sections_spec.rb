require_relative 'test-support'

module Skylab::Brazen::TestSupport::Data_Stores_::Git_Config::Mutable_Sections

  describe "[br] data stores: git config mutable sections" do

    extend TS_

    context "to an empty document" do

      with_empty_document

      it "add a section" do
        document.sections.touch_section 'foo'
        expect_document_content "[foo]\n"
      end

      it "add a section with an invalid name" do
        x = document.sections
        -> do
          x.touch_section 'foo_bar'
        end.should raise_error super_subject::ParseError,
          "invalid section name: \"foo_bar\""
      end

      it "add a section with a subsection" do
        document.sections.touch_section 'foo', 'bar'
        expect_document_content "[foo \"bar\"]\n"
      end

      it "add a section with a subsection with an invalid name" do
        x = document.sections
        -> do
          x.touch_section 'foo', "bar\nbaz"
        end.should raise_error super_subject::ParseError,
          /\Aexpected subsection name \(1:7\)/
      end
    end

    context "to a document with one section" do

      it "add a section that comes lexcially before"

      it "add the same section"

      it "add a section that comes lexcially after"
    end

    context "to a document with one subsection" do

      it "add a subsection that comes before"

      it "add the same subsection"

      it "add a subsection that comes after"

      it "add the same section (but no subsection)"
    end

    context "to a document with two subsections" do

      it "add a section that comes in the middle"

    end
  end
end
