require_relative 'test-support'

module Skylab::Basic::TestSupport::Hash::Pair_Enumerator

  ::Skylab::Basic::TestSupport::Hash[ Pair_Enumerator_TestSupport = self ]

  include CONSTANTS

  Basic = ::Skylab::Basic  # increase its visibility for below modules

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::Basic::Hash::Pair_Enumerator" do
    context "context 1" do
      Sandbox_1 = Sandboxer.spawn
      it "argument error raisal:" do
        Sandbox_1.with self
        module Sandbox_1
          -> do
            Basic::Hash::Pair_Enumerator.new( [ :a, :b, :c ] )
          end.should raise_error( ArgumentError,
                       ::Regexp.new( "\\Aodd\\ number\\ of\\ arguments" ) )
        end
      end
    end
    context "context 2" do
      Sandbox_2 = Sandboxer.spawn
      it "`each_pair` as if it were a hash:" do
        Sandbox_2.with self
        module Sandbox_2
          ea = Basic::Hash::Pair_Enumerator.new [ :a, :b, :c, :d ]
          ::Hash[ ea.each_pair.to_a ].should eql( { a: :b, c: :d } )
        end
      end
    end
  end
end
