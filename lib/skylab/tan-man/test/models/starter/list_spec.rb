require_relative 'test-support'

module Skylab::TanMan::TestSupport::Models::Starter

  describe "[tm] models starter list" do

    extend TS_

    it "lists the two items, from the filesystem" do

      call_API :starter, :ls

      expect_OK_event :item do |ev|
        ev.flyweighted_entity.local_entity_identifier_string.should eql 'digraph.dot'
      end

      expect_OK_event :item do |ev|
        ev.flyweighted_entity.local_entity_identifier_string.should eql 'holy-smack.dot'
      end

      expect_OK_event :number_of_items_found do |ev|
        ev.to_event.count.should eql 2
      end

      expect_succeeded
    end
  end
end
