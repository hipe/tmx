module Skylab::TMX

  class Magnetics_::GroupList_via_ItemList_to_be_Ordered_by_Chain

    # sort the list using the `after` attribute, which for now forms a
    # straight chain of nodes. one day it might become a tree but that
    # day is no today. (#spot-2 is conceptually related to this dynamic.)

    def initialize * three
      @item_array, @key, @is_forwards = three
    end

    def execute

      _item_stream = Stream_[ @item_array ]

      o = Common_::Stream::Ordered_via_DependencyTree.begin
      o.upstream = _item_stream

      o.identifying_key_by = -> item do
        item.filesystem_directory_entry_string  # hi.
      end

      key = @key
      o.reference_key_by = -> item do
        item.box[ key ]  # not fetch. the first item goes after nothing.
      end

      _st = o.execute

      _ary = _st.to_a

      [ Common_::Pair.via_value_and_name( _ary, :_tmx_no_value_for_this_group_ ) ]
    end
  end
end
