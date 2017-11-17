require_relative '../../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] collection adaptes - git config - mutable - sections" do

    TS_[ self ]
    use :want_event
    use :collection_adapters_git_config_mutable

    context "to an empty document" do

      with_empty_document

      it "add a section" do
        el = touch_section 'foo'
        want_document_content "[foo]\n"
        el._category_symbol_ == :_section_or_subsection_ || fail
      end

      it "add a section with an invalid name" do

        _secs = document.sections

        _p = event_log.handle_event_selectively

        ok = _secs.touch_section 'foo_bar', & _p

        ok == Home_::UNABLE_ || fail

        want_one_event :invalid_section_name do |ev|
          ev.invalid_section_name == 'foo_bar' || fail
        end
      end

      it "add a section with a subsection" do
        touch_section 'bar', 'foo'
        want_document_content "[foo \"bar\"]\n"
      end

      it "add a section with a subsection with an invalid name" do

        _secs = document.sections

        _p = event_log.handle_event_selectively

        ok = _secs.touch_section "bar\nbaz", 'foo', & _p

        want_event :invalid_subsection_name,

          /\Asubsection names can contain any characters except newline #{
           }\(\(ick "bar\\n"\)\)\z/

        ok.should eql Home_::UNABLE_
      end
    end

    context "to a document with one section" do

      # :#cov1.1

      with_a_document_with_a_section_called_foo

      it "add a section that comes lexcially before" do
        touch_section 'fo'
        want_document_content "[fo]\n[foo]\n"
      end

      it "add the same section (does add, retrieves!)" do
        secto = touch_section 'foo'
        want_document_content "[foo]\n"

        secto_ = touch_section 'foo'
        secto.should be_respond_to :subsection_string
        secto_.object_id.should eql secto.object_id
      end

      it "add a section that comes lexcially after" do
        touch_section 'fooo'
        want_document_content "[foo]\n[fooo]\n"
      end
    end

    context "to a document with one subsection" do

      with_a_document_with_one_subsection_called_foo_bar

      it "add a subsection that comes before (because ss)" do
        touch_section 'baq', 'foo'
        want_document_content "[foo \"baq\"]\n[foo \"bar\"]\n"
      end

      it "add a section that comes before" do
        touch_section 'foo'
        want_document_content "[foo]\n[foo \"bar\"]\n"
      end

      it "add the same subsection" do
        touch_section 'bar', 'foo'
        want_document_content "[foo \"bar\"]\n"
      end

      it "add a subsection that comes after" do
        touch_section 'baz', 'foo'
        want_document_content "[foo \"bar\"]\n[foo \"baz\"]\n"
      end

      it "add a section that comes after" do
        touch_section 'fooz'
        want_document_content "[foo \"bar\"]\n[fooz]\n"
      end
    end

    context "to a document with two subsections" do

      with_a_document_with_two_sections

      it "add a section that comes in the middle" do
        touch_section 'camma'
        want_document_content "[beta]\n[camma]\n[delta]\n"
      end
    end
  end
end
