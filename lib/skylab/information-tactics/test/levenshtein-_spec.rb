require_relative 'test-support'

module Skylab::InformationTactics::TestSupport::Levenshtein_

  ::Skylab::InformationTactics::TestSupport[ Levenshtein__TestSupport = self ]

  include CONSTANTS

  InformationTactics = ::Skylab::InformationTactics

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::InformationTactics::Levenshtein_" do
    context "levenshtein distance" do
      Sandbox_1 = Sandboxer.spawn
      it "is kind of amazing" do
        Sandbox_1.with self
        module Sandbox_1
          A_ = [ :apple, :banana, :ernana, :onono, :strawberry, :orange ]
          a = InformationTactics::Levenshtein_[ 3, A_, :bernono ]

          a.should eql( [ :onono, :ernana, :banana ] )
        end
      end
    end
  end
end
