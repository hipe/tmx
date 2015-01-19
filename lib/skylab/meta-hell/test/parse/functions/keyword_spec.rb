require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Parse

  describe "[mh] parse functions - keyword" do

    extend TS_

    memoize_subject do
      Subject_[].fuzzy_matcher 'foobie',
        :minimum_number_of_characters, 3
    end

    it "won't match if number of chars is under the minimum" do
      subject[ 'f' ].should be_nil
    end

    it "will match if number of chars is at the minimum" do
      subject[ 'foo' ].should eql true
    end

    it "will match if number of characers is over the minimum" do
      subject[ 'foob' ].should eql true
    end

    it "won't match if whole string does not match" do
      subject[ 'foobie-doobie' ].should be_nil
    end
  end
end