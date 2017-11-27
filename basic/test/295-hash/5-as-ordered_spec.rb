require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] hash - as ordered" do

    it "so it acts like a hash, but it memoizes the order of `aset` keys" do

      h = { }
      op = Home_::Hash::As_Ordered.new h

      op[ :foo ] = :bar
      op[ :bing ] = :baz
      op[ :foo ] = :biff
      op[ :boffo ] = :bingo

      expect( h.keys ).to eql [ :foo, :bing, :boffo ]
      expect( op.aset_k_a ).to eql [ :foo, :bing, :foo, :boffo ]
    end
  end
end
