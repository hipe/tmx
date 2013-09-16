require_relative 'test-support'

module Skylab::InformationTactics::TestSupport::Levenshtein

  ::Skylab::InformationTactics::TestSupport[ self ]

  include CONSTANTS

  InformationTactics = ::Skylab::InformationTactics

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::InformationTactics::Levenshtein" do
    context "levenshtein distance" do
      Sandbox_1 = Sandboxer.spawn
      it "is kind of amazing" do
        Sandbox_1.with self
        module Sandbox_1
          A_ = [ :apple, :banana, :ernana, :onono, :strawberry, :orange ]
          a = InformationTactics::Levenshtein::Closest_n_items_to_item[ 3, A_, :bernono ]

          a.should eql( [ :onono, :ernana, :banana ] )
        end
      end
    end
  end
end
