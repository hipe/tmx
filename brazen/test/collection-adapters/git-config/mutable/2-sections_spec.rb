require_relative '../../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] collection adaptes - git config mutable sections", wip: true do

    TS_[ self ]
    use :expect_event
    use :collection_adapters_git_config_mutable

    context "to an empty document" do

      with_empty_document

      it "add a section" do
        x = touch_section 'foo'
        expect_document_content "[foo]\n"
        expect_no_events
        x.category_symbol.should eql :section_or_subsection
      end

      it "add a section with an invalid name" do
        _secs = document.sections
        ok = _secs.touch_section 'foo_bar'
        ok.should eql Home_::UNABLE_
        expect_one_event :invalid_section_name do |ev|
          ev.invalid_section_name.should eql 'foo_bar'
        end
      end

      it "add a section with a subsection" do
        touch_section 'bar', 'foo'
        expect_document_content "[foo \"bar\"]\n"
      end

      it "add a section with a subsection with an invalid name" do
        _secs = document.sections
        ok = _secs.touch_section "bar\nbaz", 'foo'
        expect_event :invalid_subsection_name,
          /\Asubsection names can contain any characters except newline #{
           }\(\(ick "bar\\n"\)\)\z/
        ok.should eql Home_::UNABLE_
      end
    end

    context "to a document with one section" do

      with_a_document_with_a_section_called_foo

      it "add a section that comes lexcially before" do
        touch_section 'fo'
        expect_document_content "[fo]\n[foo]\n"
      end

      it "add the same section (does add, retrieves!)" do
        secto = touch_section 'foo'
        expect_document_content "[foo]\n"

        secto_ = touch_section 'foo'
        secto.should be_respond_to :subsect_name_s
        secto_.object_id.should eql secto.object_id
      end

      it "add a section that comes lexcially after" do
        touch_section 'fooo'
        expect_document_content "[foo]\n[fooo]\n"
      end
    end

    context "to a document with one subsection" do

      with_a_document_with_one_subsection_called_foo_bar

      it "add a subsection that comes before (because ss)" do
        touch_section 'baq', 'foo'
        expect_document_content "[foo \"baq\"]\n[foo \"bar\"]\n"
      end

      it "add a section that comes before" do
        touch_section 'foo'
        expect_document_content "[foo]\n[foo \"bar\"]\n"
      end

      it "add the same subsection" do
        touch_section 'bar', 'foo'
        expect_document_content "[foo \"bar\"]\n"
      end

      it "add a subsection that comes after" do
        touch_section 'baz', 'foo'
        expect_document_content "[foo \"bar\"]\n[foo \"baz\"]\n"
      end

      it "add a section that comes after" do
        touch_section 'fooz'
        expect_document_content "[foo \"bar\"]\n[fooz]\n"
      end
    end

    context "to a document with two subsections" do

      with_a_document_with_two_sections

      it "add a section that comes in the middle" do
        touch_section 'camma'
        expect_document_content "[beta]\n[camma]\n[delta]\n"
      end
    end
  end
end
