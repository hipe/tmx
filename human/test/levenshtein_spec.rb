require_relative 'test-support'

module Skylab::Human::TestSupport

  describe "[hu] levenshtein" do

    it "levenshtein distance is kind of amazing" do

      _a = [ :apple, :banana, :ernana, :onono, :strawberry, :orange ]

      _a_ = Home_::Levenshtein.with(
        :item, :bernono,
        :items, _a,
        :closest_N_items, 3 )

      _a_.should eql [ :onono, :ernana, :banana ]
    end
  end
end
