require_relative 'test-support'

module Skylab::Basic::TestSupport::Hash::As_Ordered

  ::Skylab::Basic::TestSupport::Hash[ self ]

  include Constants

  extend TestSupport_::Quickie

  Home_ = Home_

  describe "[ba] hash - as ordered" do

    it "acts like a hash, but it memoizes the order of `aset` keys" do
      h = { }
      op = Home_::Hash::As_Ordered.new h

      op[ :foo ] = :bar
      op[ :bing ] = :baz
      op[ :foo ] = :biff
      op[ :boffo ] = :bingo

      h.keys.should eql [ :foo, :bing, :boffo ]
      op.aset_k_a.should eql [ :foo, :bing, :foo, :boffo ]
    end
  end
end
