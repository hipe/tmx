require_relative 'test-support'

module Skylab::Basic::TestSupport::Hash::Order_Proxy

  ::Skylab::Basic::TestSupport::Hash[ self ]

  include Constants

  extend TestSupport_::Quickie

  Basic_ = Basic_

  Sandboxer = TestSupport_::Sandbox::Spawner.new

  describe "[ba] Hash::Order_Proxy" do
    context "a proxy around a hash that tracks in order every key of every `aset` call" do
      Sandbox_1 = Sandboxer.spawn
      it "for dark hacks" do
        Sandbox_1.with self
        module Sandbox_1
          h = { }
          op = Basic_::Hash::Order_Proxy.new h

          op[ :foo ] = :bar
          op[ :bing ] = :baz
          op[ :foo ] = :biff
          op[ :boffo ] = :bingo

          h.keys.should eql( [ :foo, :bing, :boffo ] )
          op.aset_k_a.should eql( [ :foo, :bing, :foo, :boffo ] )
        end
      end
    end
  end
end
