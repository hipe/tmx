require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] magnetics - SS via CB" do

    TS_[ self ]
    use :memoizer_methods
    use :files

    with_big_file_path do
      special_file_path_ :the_readme_document
    end

    # NOTE - true to the spirit of doc-test, all of these tests here
    # use as input a chunk of text in the above document, a document
    # which itself describes the behavior we are covering here.

    it "loads" do
      _subject
    end

    shared_subject :_items do

      DT_IS_SS_via_CB_Struct = ::Struct.new(
        :first,
        :second,
        :third,
        :fourth,
        :fifth,
        :sixth,
        :seventh,
      )

      o = DT_IS_SS_via_CB_Struct.new

      with_comment_block_in_ad_hoc_fake_file :ad_hoc_one
      st = _subject[ @comment_block ]

      o.first = st.gets
      o.second = st.gets
      o.third = st.gets
      o.fourth = st.gets
      o.fifth = st.gets
      o.sixth = st.gets
      o.seventh = st.gets
      o
    end

    it "every time you indent by less than 4 spaces, it's still a text block" do

      _items.first.a.last.should match %r(\bstill text because it's 3 deeper\b)
    end

    it "as soon as we jump in 4 spaces deeper (or more) from prev, is code block" do

      _items.second.a.fetch( 0 ).should match %r(\Abut as soon)
    end

    it "a newline (blank linke) inine in the code block does not break it" do

      _items.second.a.fetch( -2 ).should eql NEWLINE_
    end

    it "as long as we stay within the local margin, it's still code" do

      _items.second.a.last.should match %r(\bbecause code span\b)
    end

    it "no matter how deep the indent, a bullet character is text" do

      _items.third.a.fetch( -2 ).should match %r(\Aeven though very deep)
    end

    it "such a bullet item sets a new local margin" do

      _items.third.a.fetch( -1 ).should match %r(\Athis too, because new local margin)
    end

    it "(confirm that this is code, had trailing whitespace)" do
      _items.fourth.a.should eql( [
        "and then here is code because 4\n",
        NEWLINE_,
        NEWLINE_,
      ] )
    end

    it "that final nonblank line is text" do

      text_line_a = _items.fifth.a
      text_line_a.length.should eql 1
      text_line_a.first.should match %r(\bthis line is text\b)
    end

    it "trailing whitespace lines are ignored" do

      o = _items
      o.sixth.should be_nil
      o.seventh.should be_nil
    end

    def _subject
      magnetics_module_::SpanStream_via_CommentBlock
    end
  end
end
