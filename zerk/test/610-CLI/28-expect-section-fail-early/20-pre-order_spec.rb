require_relative '../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI support - expect section - .." do

    TS_[ self ]
    use :memoizer_methods

    it "to pre-order stream" do

      _tree = _subject.tree_via :string, _string

      st = _tree.to_pre_order_stream

      _1 = st.gets
      _2 = st.gets
      _3 = st.gets
      _4 = st.gets
      _5 = st.gets
      _6 = st.gets

      _1.x.string.should eql "head\n"
      _2.x.string.should eql "  mouth\n"
      _3.x.string.should eql "body\n"
      _4.x.string.should eql "  leg\n"
      _5.should be_nil
      _6.should be_nil
    end

    memoize :_string do
      <<-HERE.unindent
        head
          mouth
        body
          leg
      HERE
    end

    memoize :_subject do
      TS_.lib_( :CLI_support_expect_section )
    end
  end
end
