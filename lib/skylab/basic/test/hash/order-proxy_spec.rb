require_relative 'test-support'

module Skylab::Basic::TestSupport::Hash::Order_Proxy

  ::Skylab::Basic::TestSupport::Hash[ self ]

  include Constants

  extend TestSupport_::Quickie

  Basic_ = Basic_

  Subject_ = -> * x_a, & p do
    if x_a.length.nonzero? || p
      Basic_::Hash::Order_Proxy[ * x_a, & p ]
    else
      Basic_::Hash::Order_Proxy
    end
  end

  describe "[ba] Hash::Order_Proxy" do

    it "acts like a hash, but it memoizes the order of `aset` keys" do
      h = { }
      op = Subject_[].new h

      op[ :foo ] = :bar
      op[ :bing ] = :baz
      op[ :foo ] = :biff
      op[ :boffo ] = :bingo

      h.keys.should eql [ :foo, :bing, :boffo ]
      op.aset_k_a.should eql [ :foo, :bing, :foo, :boffo ]
    end
  end
end
