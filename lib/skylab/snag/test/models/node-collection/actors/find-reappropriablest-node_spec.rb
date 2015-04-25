require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - node collection [..] find reappropriablest node" do

    extend TS_

    it "if no nodes match the criteria, result is nil" do

      _against <<-HERE.unindent
        [#5] (#was:) hi
        [#3] (#was:) hi
        [#5] (#was:) hi
      HERE

      _gimme.should be_nil
    end

    it "after criteria, the search space is reduced to lowest was's count" do

      _against <<-HERE.unindent
        [#5] (#was:) #done (#was:) #hole
        [#3] (#was:) #hole
        [#2] #done #hole (#was) (#was)
      HERE

      _gimme.ID.to_i.should eql 3
    end

    it "after above, the item with the lowest ID wins" do

      _against <<-HERE.unindent
        [#55] #done (#was:)
        [#22] #done (#was:)
        [#33] #done (#was:)
      HERE

      _gimme.ID.to_i.should eql 22
    end

    it "having extended content also disqualifies the item" do

      _against_path ::File.join(
        Fixture_tree_[ :reappropriate_modest ], 'derk/ershues.mani' )

      _gimme.ID.to_i.should eql 3
    end

    def _against_path path

      @col = Snag_::Models_::Node_Collection.new_via_path path
      NIL_
    end

    def _against s

      _BU_ID = Snag_.lib_.basic::String::Byte_Upstream_Identifier.new s
      @col = Snag_::Models_::Node_Collection.new_via_upstream_identifier _BU_ID
      NIL_
    end

    def _gimme
      _subject.call @col.to_entity_stream
    end

    def _subject
      Snag_::Models_::Node_Collection::Actors_::Find_reappropriablest_node
    end
  end
end
