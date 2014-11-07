require_relative 'test-support'

module Skylab::Basic::TestSupport::Hash

  describe "[ba] hash - deterine hotstrings" do

    # we think we've seen some sort of builtin for this somewhere before
    # but A) we couldn't find it and B) the edge cases are such that it's
    # better that we write it ourselves anyway

    it "tries to find the shortest unique head-anchored substrings" do
      with 'closure', 'swift', 'scala'
      expect 'c', 'sw', 'sc'
    end

    it "when strings are same in all but last letter - full strings" do
      with 'zap', 'zab'
      expect 'zap', 'zab'
    end

    it "when strings are already unique - first letter" do
      with 'ep', 'pe'
      expect 'e', 'p'
    end

    it "when one string is the head of another string - shorter becomes nil" do
      x = subject [ 'my', 'myopic' ]
      x.first.should be_nil
      x.last.hotstring.should eql 'myo'
    end

    def with * s_a
      @result = subject s_a
    end

    def expect * s_a
      @result.map( & :hotstring ).should eql s_a
    end

    def subject a
      Subject_[].determine_hotstrings a
    end
  end
end
