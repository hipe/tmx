require_relative '../../test-support'

module Skylab::Parse::TestSupport

  describe "[pa] functions - keyword" do

    TS_[ self ]

    memoize_subject_parse_function_ do

      Home_.fuzzy_matcher 'foobie', :minimum_number_of_characters, 3
    end

    it "won't match if number of chars is under the minimum" do

      expect( _subject[ 'f' ] ).to be_nil
    end

    it "will match if number of chars is at the minimum" do

      expect( _subject[ 'foo' ] ).to eql true
    end

    it "will match if number of characers is over the minimum" do

      expect( _subject[ 'foob' ] ).to eql true
    end

    it "won't match if whole string does not match" do

      expect( _subject[ 'foobie-doobie' ] ).to be_nil
    end

    alias_method :_subject, :subject_parse_function_
  end
end
