require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] scn - multi-step" do

    it "simply wraps an init-phase along with a 'gets' phase and enumerates" do

      a = d = last = nil

      scn = Home_::Scn.multi_step :init, -> do
        a = [ :a, :b, :c ] ; d = -1 ; last = a.length - 1
      end, :gets, -> do
        a.fetch( d += 1 ) if d < last
      end

      scn.each.to_a.should eql %i( a b c )
    end
  end
end
