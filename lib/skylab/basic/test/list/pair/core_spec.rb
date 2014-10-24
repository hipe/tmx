require_relative '../test-support'

module Skylab::Basic::TestSupport::List

  describe "[ba] Hash::Pair_Enumerator" do
    context "usage: you must construct it with an array with an even number of args." do
      Sandbox_1 = Sandboxer.spawn
      it "failure to do so will result in immediate argument error raisal" do
        Sandbox_1.with self
        module Sandbox_1
          ea = Subject_[].build_each_pairable_via_even_iambic [ :a, :b, :c, :d ]
          ::Hash[ ea.each_pair.to_a ].should eql( { a: :b, c: :d } )
        end
      end
    end
  end
end
