module Skylab::Human

  # levenshtein distance is kind of amazing
  #
  #     _a = [ :apple, :banana, :ernana, :onono, :strawberry, :orange ]
  #
  #     _a_ = Home_::Levenshtein.with(
  #       :item, :bernono,
  #       :items, _a,
  #       :closest_N_items, 3 )
  #
  #     _a_  # => [ :onono, :ernana, :banana ]

  class Levenshtein

    Attributes_actor_.call( self,
      :item,
      :items,
      :closest_N_items,
      :aggregation_proc,
      :item_proc,
    )

    def initialize
      super
      @aggregation_proc ||= IDENTITY_
      @item_proc ||= IDENTITY_
    end

    def execute
      if @item && @items && @closest_N_items
        via_OK_ivars_execute
      else
        false
      end
    end

  private

    def via_OK_ivars_execute
      extra_s = @item.to_s
      item_a = []
      @items.each do |item_x|
        item_a.push(
          Item__.new(
            item_x,
            ::Levenshtein.distance( item_x.to_s, extra_s ) ) )
      end
      item_a.sort_by!( & :distance_d )
      @item_a = item_a
      via_sorted_items
    end

    def via_sorted_items
      _sub_slice_item_a = @item_a[ 0, @closest_N_items ]
      _value_x_a = _sub_slice_item_a.map do |item|
        @item_proc[ item.item_x ]
      end
      @aggregation_proc[ _value_x_a ]
    end

    Item__ = ::Struct.new :item_x, :distance_d

    Home_.lib_.levenshtein  # load it
  end
end
