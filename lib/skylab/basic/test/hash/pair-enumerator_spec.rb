require_relative 'test-support'

module Skylab::Basic::TestSupport::Hash::Pair_Enumerator

  ::Skylab::Basic::TestSupport::Hash[ self ]

  include CONSTANTS

  Basic = ::Skylab::Basic

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::Basic::Hash::Pair_Enumerator" do
    context "usage: you must construct it with an array with an even number of args." do
      Sandbox_1 = Sandboxer.spawn
      it "failure to do so will result in immediate argument error raisal" do
        Sandbox_1.with self
        module Sandbox_1
          -> do
            Basic::Hash::Pair_Enumerator.new( [ :a, :b, :c ] )
          end.should raise_error( ArgumentError,
                       ::Regexp.new( "\\Aodd\\ number\\ of\\ arguments" ) )
        end
      end
      it "iterate over those elements using `each_pair` as if it were a hash" do
        Sandbox_1.with self
        module Sandbox_1
          ea = Basic::Hash::Pair_Enumerator.new [ :a, :b, :c, :d ]
          ::Hash[ ea.each_pair.to_a ].should eql( { a: :b, c: :d } )
        end
      end
    end
  end
end
