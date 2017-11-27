require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] string - magnetics - `unparenthesize` (& core) " do

    TS_[ self ]
    use :string

    it "loads" do
      subject_module_
    end

    it 'empty string - no match' do
      expect( subject( '' ) ).to be_nil
    end

    it "empty parens - matches" do
      expect( subject( '()' ) ).to eql [ '(', nil, ')' ]
    end

    it "parenthesis pair with trailing paren - ok" do
      expect( subject( '()))' ) ).to eql [ '(', '))', ')' ]
    end

    it "plain old word - doesn't parse (why bother?)" do
      expect( subject( 'foo' ) ).to be_nil
    end

    it "word ending with one punctuation - parses" do
      expect( subject( 'foo!' ) ).to eql [ nil, 'foo', '!' ]
    end

    it "stress test - ok" do
      expect( subject(  '<(foo, bar!?)!?:.!>' ) ).to eql [ '<', '(foo, bar!?)', '!?:.!>' ]
    end

    def subject s
      md = subject_module_.unparenthesize_message_string::UNPARENTHESIZE_RX___.match s
      if md
        [ md[ :open ], md[ :body ], md[ :close ] ]  # not 'captures'
      end
    end
  end
end
