module Skylab::Human

  # levenshtein distance is kind of amazing
  #
  #     _a = [ :apple, :banana, :ernana, :onono, :strawberry, :orange ]
  #
  #     _a_ = Home_::Levenshtein.with(
  #       :item_string, "bernono",
  #       :items, _a,
  #       :stringify_by, :id2name.to_proc,
  #       :closest_N_items, 3 )
  #
  #     _a_  # => [ :ernana, :onono, :banana ]

  class Levenshtein

    Attributes_actor_.call( self,
      :item_string,
      :items,  # if not array, assumed to be stream
      :closest_N_items,
      :stringify_by,
      :map_result_items_by,
      :aggregate_by,
    )

    def initialize
      @aggregate_by = nil
      @map_result_items_by = nil
      super
      @stringify_by ||= IDENTITY_
    end

    def execute
      if @item_string && @items && @closest_N_items
        __via_OK_ivars_execute
      else
        false
      end
    end

    def __via_OK_ivars_execute

      target_s = @item_string

      st = __stream

      @_see = :__see_for_the_first_time
      string = @stringify_by

      begin
        @_item_x = st.gets
        @_item_x || break
        _candidate_s = string[ @_item_x ]
        @_distance = ::Levenshtein.distance _candidate_s, target_s  # integer
        send @_see
        redo
      end while above

      # zero-length lists meh, need coverage

      p = @map_result_items_by || IDENTITY_
      a = @_winners.map do |sct|
        p[ sct.item ]
      end
      if @aggregate_by
        @aggregate_by[ a ]
      else
        a
      end
    end

    def __see_for_the_first_time

      @_winners = [ _build_candidate ]
      @_threshold_distance = @_distance
      @_when_farther_than_threshold = :__when_farther_than_threshold_at_first
      @_see = :__see_normally
      NIL
    end

    def __see_normally

      case @_distance <=> @_threshold_distance
      when -1
        __when_found_a_closer_item
      when 1
        send @_when_farther_than_threshold
      when 0
        __when_same_distance_as_threshold
      end
      NIL
    end

    def __when_found_a_closer_item

      # insert the new item in the appropriate place in the memoized list so
      # that the list remains sorted (with the closest item as the first
      # item in the list).

      found = nil
      @_winners.each_with_index do |sct, d|
        if sct.distance > @_distance
          found = d
          break
        end
      end

      found ||= @_winners.length  # if no item found, concat it to the end

      @_winners[ found, 0 ] = [ _build_candidate ]

      if @closest_N_items < @_winners.length
        __shorten_the_list
      end
      NIL
    end

    def __shorten_the_list

      # don't shorten the list if a span of same-distance items crosses
      # the threshold. otherwise shorten it eliminating the whole span.

      len = @_winners.length
      d = len - 1
      distance_of_last_item = @_winners[ d ].distance
      begin
        d.zero? && break
        d_ = d - 1
        if distance_of_last_item == @_winners[ d_ ].distance
          d = d_
          redo
        end
        break
      end while above

      if d >= @closest_N_items
        @_winners[ d ... len ] = EMPTY_A_
      end
      NIL
    end

    def __when_farther_than_threshold_at_first

      # if you have reached the item limit, then just discard this and future
      # items that are further out than the threshold. otherwise push this
      # item to the list of memoized items and increase the threshold.
      # because the item is certainly further than all others in the memoized
      # list, there is no need to find a correct insertion point - the item
      # is always concatted to the end of the list.

      if @_winners.length >= @closest_N_items
        @_when_farther_than_threshold = :__no_op
      else
        @_threshold_distance = @_distance
        @_winners.push Candidate__[ @_distance, @_item_x ]
      end
      NIL
    end

    def __when_same_distance_as_threshold

      # if we do this, we probably increase the number of resultant items
      # beyond the provided limit. but if we don't do this, we arbitrarily
      # omit some items and not others that have the same distance score.

      @_winners.push Candidate__[ @_distance, @_item_x ]
      NIL
    end

    def __stream

      if ::Array.try_convert @items
        Common_::Stream.via_nonsparse_array @items
      else
        remove_instance_variable :@items  # not idempotent
      end
    end

    def _build_candidate
      Candidate__.new @_distance, @_item_x
    end

    def __no_op
      NOTHING_
    end

    Candidate__ = ::Struct.new :distance, :item

    Home_.lib_.levenshtein  # load it

    EMPTY_A_ = []
  end
end
# #tombstone: simpler but crude array-based algo
