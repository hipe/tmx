module Skylab::Human

  # levenshtein distance is kind of amazing
  #
  #     _a = [ :apple, :banana, :ernana, :onono, :strawberry, :orange ]
  #
  #     _a_ = Home_::Levenshtein.via(
  #       :item_string, "bernono",
  #       :items, _a,
  #       :stringify_by, :id2name.to_proc,
  #       :closest_N_items, 3 )
  #
  #     _a_  # => [ :ernana, :onono, :banana ]

  class Levenshtein  # :[065]

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
        __do_execute
      else
        false
      end
    end

    def __do_execute

      __init_initial_list_of_winners
      __maybe_shorten_final_list_of_winners
      __flush_final_list_of_winners
    end

    def __maybe_shorten_final_list_of_winners

      #   - this method is an auxiliary (not ancillary) "aesthetic adjustment".
      #     it's a fine-tuning detail. it's OK to erase this whole method.
      #
      #   - secondly, the code is (of course) the authoritative reference
      #     on what happens here. the pseudocode below is a sketch and has
      #     known differences from what the code actually does.
      #
      #   - thirdly, coverage is very poor for this. it was developed
      #     visually, and even in client sidesystems its effect is not
      #     covered directly.

      # this is an aesthetic adjustment because it "doesn't sound right"
      # to have "far" matches next to "near" matches, for example:
      #
      #     unrecognized fruit "bernerner". did you mean "bununu", "banana", "benene", "apple" or "strawberry"?
      #
      # the first three are "so close", it sounds weird to include the last two.

      # e.g., if the list at this point meets ALL these criteria:
      #
      #   - the list is "long" (longer than the target number of items)
      #
      #   - there is a "stark" increase in the distance at some point
      #     (have fun figuring out how we define "stark")
      #
      #   - if after you would truncate the list by cutting off all items
      #     after the stark increase, there is still more than one item (or not)
      #
      # then truncate the list in this manner.
      # :[#008.2] borrow coverage from [my]
      # :[#065.2] refers to all of the above and below.

      if @closest_N_items < @_winners.length

        last_dist = @_winners.last.distance

        if ( @_winners.first.distance * 2 ) < last_dist

          index = @_winners.length.times.detect do |d|
            last_dist == @_winners[ d ].distance
          end

          if 1 < index
            @_winners[ index .. -1 ] = EMPTY_A_
          end
        end
      end
      NIL
    end

    def __init_initial_list_of_winners

      target_s = @item_string

      scn = __scanner

      @_see = :__see_for_the_first_time
      string = @stringify_by

      until scn.no_unparsed_exists
        @_item_x = scn.gets_one
        _candidate_s = string[ @_item_x ]
        @_distance = ::Levenshtein.distance _candidate_s, target_s  # integer
        send @_see
      end
      NIL
    end

    def __flush_final_list_of_winners

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

    def __scanner

      mixed = remove_instance_variable :@items  # not idempotent

      if ::Array.try_convert mixed
        Scanner_[ mixed ]

      elsif mixed.respond_to? :gets
        mixed.flush_to_scanner

      else
        mixed  # assume scanner
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
