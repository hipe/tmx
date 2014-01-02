require_relative 'test-support'

module Skylab::Basic::TestSupport::List::Scanner::Power

  ::Skylab::Basic::TestSupport::List::Scanner[ self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "[ba] list scanner power (\"power scanner\")" do

    it "simply wraps an init-phase along with a 'gets' phase and enumerates" do
      a = d = last = nil
      scn = Basic::List::Scanner::Power[ :init, -> do
        a = [ :a, :b, :c ] ; d = -1 ; last = a.length - 1
      end, :gets, -> do
        a.fetch( d += 1 ) if d < last
      end ]
      scn.each.to_a.should eql %i( a b c )
    end
  end
end
