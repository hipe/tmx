require_relative '../../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] collection adapters - git config - entity collection - list" do

    TS_[ self ]
    use :memoizer_methods
    use :collection_adapters_git_config_entity_collection

    it "entity collection builds" do
      entity_collection_one_immutable_ || fail
    end

    it "facade builds" do
      footwear_facade_immutable_ || fail
    end

    context "(this list)" do

      it "finds all items" do

        _list.length == 2 || fail
      end

      it "each item is of the approriate (same) class" do

        _list.map( & :class ).uniq == [ footwear_class_ ] || fail
      end

      it "the items are not flyweighted (any more); each is its own object" do

        first, second = _list
        first || fail
        first.object_id == second.object_id && fail
      end

      it "each item knows its locally unique identifier" do

        first, last = _list
        first._natural_key_string_ == my_favorite_cons_ || fail
        last._natural_key_string_ == "joggers" || fail
      end

      it "the items receive a crude umarshaling of the primitives" do

        _list.first.date_of_purchase == "2017 april" || fail
      end

      shared_subject :_list do
        footwear_facade_immutable_.to_stream_of_all_such_entities.to_a
      end
    end

    # ==
    # ==
  end
end
# #born years later, during massive refactor
