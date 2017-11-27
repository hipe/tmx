require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] hash - hotstrings" do

    # we think we've seen some sort of builtin for this somewhere before
    # but A) we couldn't find it and B) the edge cases are such that it's
    # better that we write it ourselves anyway

    it "tries to find the shortest unique head-anchored substrings" do
      with 'closure', 'swift', 'scala'
      want 'c', 'sw', 'sc'
    end

    it "when strings are same in all but last letter - full strings" do
      with 'zap', 'zab'
      want 'zap', 'zab'
    end

    it "when strings are already unique - first letter" do
      with 'ep', 'pe'
      want 'e', 'p'
    end

    it "when one string is the head of another string - shorter becomes nil" do
      x = subject [ 'my', 'myopic' ]
      expect( x.first ).to be_nil
      expect( x.last.hotstring ).to eql 'myo'
    end

    it "with stream" do
      _st = Common_::Stream.via_nonsparse_array [ 'imagema', 'imogen' ]
      _have = subject _st
      _have.map( & :hotstring ) == %w( ima imo ) or fail
    end

    def with * s_a
      @result = subject s_a
    end

    def want * s_a
      expect( @result.map( & :hotstring ) ).to eql s_a
    end

    def subject a
      Home_::Hash::Hotstrings[ a ]
    end
  end
end
