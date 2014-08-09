require_relative 'test-support'

module Skylab::Brazen::TestSupport::Data_Stores_::Git_Config::Mutable_Sections

  describe "[br] data stores: git config mutable assignments" do

    extend TS_

    context "to a section with no assignments" do

      with_a_document_with_a_section_called_foo

      it "add an assignment (bool)" do
        sect = document.sections[ :foo ]
        sect[ :'is-on' ] = true
        expect_document_content "[foo]\nis-on = true\n"
      end

      it "quotes will not be used if not necessary" do
        document.sections[ :foo ][ :hi ] = 'foo bar'
        expect_document_content "[foo]\nhi = foo bar\n"
      end

      it "quotes will be used if leading space" do
        document.sections[ :foo ][ :hi ] = ' foo'
        expect_document_content "[foo]\nhi = \" foo\"\n"
      end

      it "things get escaped" do
        _sect = document.sections[ :foo ]
        _sect[ :hi ] = "\\ \" \n \t \b"
        expect_document_content "[foo]\nhi = \"\\\\ \\\" \\n \\t \\b\"\n"
      end
    end

    context "change one existing" do

      with_a_document_with_one_section_with_one_assignment

      it "changes it (minimal)" do
        document.sections[ :foo ][ :bar ] = 'win'
        expect_document_content "[foo]\nbar = win\n"
      end

      it "changes it when quotes are necessary to add" do
        document.sections[ :foo ][ :bar ] = ' a'
        expect_document_content "[foo]\nbar = \" a\"\n"
      end
    end

    context "change one existing (from quotes to no quotes)" do

      with_content "[foo]\nbar = \" a\"\n"

      it "changes it when quotes can be removed" do
        document.sections[ :foo ][ :bar ] = 11
        expect_document_content "[foo]\nbar = 11\n"
      end
    end
  end
end
