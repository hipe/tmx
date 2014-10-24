require_relative 'test-support'

module Skylab::Basic::TestSupport::String

  describe "[ba] string unparenthesize (and core)" do

    it "loads" do
      Basic_::String
    end

    it 'empty string - no match' do
      subject( '' ).should be_nil
    end

    it "empty parens - matches" do
      subject( '()' ).should eql [ '(', nil, ')' ]
    end

    it "parenthesis pair with trailing paren - ok" do
      subject( '()))' ).should eql [ '(', '))', ')' ]
    end

    it "plain old word - doesn't parse (why bother?)" do
      subject( 'foo' ).should be_nil
    end

    it "word ending with one punctuation - parses" do
      subject( 'foo!' ).should eql [ nil, 'foo', '!' ]
    end

    it "stress test - ok" do
      subject(  '<(foo, bar!?)!?:.!>' ).
        should eql [ '<', '(foo, bar!?)', '!?:.!>' ]
    end

    def subject s
      md = Basic_::String.unparenthesize_message_string::UNPARENTHESIZE_RX__.match s
      if md
        [ md[ :open ], md[ :body ], md[ :close ] ]  # not 'captures'
      end
    end
  end
end
