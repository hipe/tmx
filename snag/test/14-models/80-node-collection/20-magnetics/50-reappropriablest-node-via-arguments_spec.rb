require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - node collection [..] find reappropriablest node" do

    TS_[ self ]
    use :memoizer_methods

    it "if no nodes match the criteria, result is nil" do

      _against <<-HERE.unindent
        [#5] (#was:) hi
        [#3] (#was:) hi
        [#5] (#was:) hi
      HERE

      expect( _gimme ).to be_nil
    end

    it "after criteria, the search space is reduced to lowest was's count" do

      _against <<-HERE.unindent
        [#5] (#was:) #done (#was:) #hole
        [#3] (#was:) #hole
        [#2] #done #hole (#was) (#was)
      HERE

      expect( _gimme.ID.to_i ).to eql 3
    end

    it "after above, the item with the lowest ID wins" do

      _against <<-HERE.unindent
        [#55] #done (#was:)
        [#22] #done (#was:)
        [#33] #done (#was:)
      HERE

      expect( _gimme.ID.to_i ).to eql 22
    end

    it "having extended content also disqualifies the item" do

      _against_path ::File.join(
        Fixture_tree_[ :reappropriate_modest ], 'derk/ershues.mani' )

      expect( _gimme.ID.to_i ).to eql 3
    end

    def _against_path path

      _invo_rsx = invocation_resources_

      @col = Home_::Models_::NodeCollection.via_path path, _invo_rsx
      NIL_
    end

    def _against s

      _invo_rsx = invocation_resources_

      _BU_ID = Home_.lib_.basic::String::ByteUpstreamReference.via_big_string s

      @col = Home_::Models_::NodeCollection.via_upstream_reference _BU_ID, _invo_rsx
      NIL_
    end

    def _gimme
      _subject.call @col.to_entity_stream, invocation_resources_
    end

    def _subject
      Home_::Models_::NodeCollection::Magnetics_::ReappropriablestNode_via_Arguments
    end
  end
end
