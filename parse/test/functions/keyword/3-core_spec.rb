require_relative '../../test-support'

module Skylab::Parse::TestSupport

  describe "[pa] functions - keyword" do

    extend TS_

    memoize_subject_parse_function_ do

      Home_.fuzzy_matcher 'foobie', :minimum_number_of_characters, 3
    end

    it "won't match if number of chars is under the minimum" do

      _subject[ 'f' ].should be_nil
    end

    it "will match if number of chars is at the minimum" do

      _subject[ 'foo' ].should eql true
    end

    it "will match if number of characers is over the minimum" do

      _subject[ 'foob' ].should eql true
    end

    it "won't match if whole string does not match" do

      _subject[ 'foobie-doobie' ].should be_nil
    end

    alias_method :_subject, :subject_parse_function_
  end
end
