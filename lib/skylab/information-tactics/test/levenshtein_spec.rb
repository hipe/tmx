require_relative 'test-support'

module Skylab::InformationTactics::TestSupport::Levenshtein

  ::Skylab::InformationTactics::TestSupport[ self ]

  include Constants

  extend TestSupport_::Quickie

  IT_ = IT_

  Sandboxer = TestSupport_::Sandbox::Spawner.new

  describe "[it] Levenshtein" do
    context "levenshtein distance" do
      Sandbox_1 = Sandboxer.spawn
      it "is kind of amazing" do
        Sandbox_1.with self
        module Sandbox_1
          a = [ :apple, :banana, :ernana, :onono, :strawberry, :orange ]
          a_ = Subject_[].with(
            :item, :bernono,
            :items, a,
            :closest_N_items, 3 )
          a_.should eql( [ :onono, :ernana, :banana ] )
        end
      end
    end

    Subject_ = -> do
      IT_::Levenshtein
    end
  end
end
