require_relative '../test-support'

module Skylab::TestSupport::TestSupport::DocTest

  describe "[ts] doc-test - intermediate streams - SS via CB" do

    extend TS_

    with_big_file_path do
      Top_TS_.doc_path_( 'issues/015-the-doc-test-narrative.md' )
    end

    it "loads" do
      subject
    end

    it "the comprehensive example in the document parses" do

      with_comment_block_in_ad_hoc_fake_file :ad_hoc_one
      o = subject[ @comment_block ]

      text_line_a = o.gets.a
      text_line_a.last.should match %r(still text because it's 3 deeper)

      code_span_line_a = o.gets.a
      code_span_line_a[ -2 ].should eql Home_::NEWLINE_
      code_span_line_a.last.should match %r(\bbecause code span\b)

      text_line_a = o.gets.a
      text_line_a[ -2 ].should match %r(\Aeven though very deep)
      text_line_a.last.should match %r(\Athis too, because new local margin)

      code_span_line_a = o.gets.a
      code_span_line_a.length.should eql 3  # trailing whites

      text_line_a = o.gets.a

      text_line_a.length.should eql 1
      text_line_a.first.should match %r(\bthis line is text\b)

      o.gets.should be_nil
      o.gets.should be_nil
    end

    def subject
      Subject_[]::Intermediate_Streams_::
        Node_stream_via_comment_block_stream::Span_stream_via_comment_block__
    end
  end
end
