require_relative 'test-support'

module Skylab::InformationTactics::TestSupport

  describe "[it] Levenshtein" do

    it "levenshtein distance is kind of amazing" do
      a = [ :apple, :banana, :ernana, :onono, :strawberry, :orange ]

      a_ = IT_::Levenshtein.with(
        :item, :bernono,
        :items, a,
        :closest_N_items, 3 )

      a_.should eql [ :onono, :ernana, :banana ]
    end
  end
end
