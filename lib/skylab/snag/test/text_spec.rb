require_relative 'test-support'

module Skylab::Snag::TestSupport::Unparenthesize__

  ::Skylab::Snag::TestSupport[ self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  describe '[sg] text (unparenthesize)' do

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
      md = Snag_::CLI::UNPARENTHESIZE_RX__.match s
      md and [ md[ :open ], md[ :body ], md[ :close ] ]  # not 'captures'
    end
  end
end
