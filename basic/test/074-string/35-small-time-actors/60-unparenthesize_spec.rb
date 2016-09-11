require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] string - small time actors - `unparenthesize` (& core) " do

    extend TS_
    use :string

    it "loads" do
      subject_module_
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
      md = subject_module_.unparenthesize_message_string::UNPARENTHESIZE_RX___.match s
      if md
        [ md[ :open ], md[ :body ], md[ :close ] ]  # not 'captures'
      end
    end
  end
end
