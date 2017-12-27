module Skylab::Basic

  class Algorithm::BucketList_that_is_FairlyDistributed_via_WeightedTupleStream_and_N_Buckets  # [#ba-059]

    # this is what we generally call the :[#059] "divvy algorithm". in synopsis:
    #
    #   - partition the argument list (as a stream) into argument N
    #     (two or more) buckets in such a way that the weight of the
    #     items is distributed "fairly".
    #
    #   - the result is the N buckets as an array of "bucket" objects.
    #     note that there will be empty buckets IFF the number of buckets
    #     exceeds the number of items in the list.
    #
    #   - see "the grocery analogy" at the end.
    #
    # this is the "divvy algorithm":
    #
    # given:
    #
    #   - an argument that is a two or greater N representing
    #     a number of "buckets" to produce
    #
    #   - a stream of tuples (struct-ishes) where each tuple has a
    #     `main_quantity` component that is a nonzero positive number
    #
    # the result is the N buckets with the items distributed in an
    # "as evenly as possible" manner.
    #
    #   - each bucket will maintain a "total" representing the
    #     total of the "main quantities" of each item in the bucket.
    #
    #   - sort the list in descending order by size
    #
    #   - for each item in the list,
    #
    #     - find the first bucket with the minimum total.
    #       (at each step, finding the minimum will require traversing
    #        all buckets. this search will be "inefficient" the first
    #        few times, as all totals will be zero, but meh.)
    #
    #     - place the item in that bucket and update its total.
    #
    #
    # that it!. the result is buckets with items as evenly as possibly
    # distributed.
    #
    # here is an arbitrary "weighted list". it's a sampling of U.S
    # presidents and their supposed body weight in pounds. (we tried to
    # include the heaviest few, the lightest few, and a few recent ones.)
    #
    #   obama     180
    #   w. bush   194
    #   taft      332
    #   cleveland 275
    #   trump     246
    #   jackson   154
    #   madison   122

    # a first example:
    #
    #     buckets = _subject_module[ _presidents_as_stream, 3 ]
    #
    #     buckets.length  # => 3
    #
    #     # from partitioning the list by hand, we got:
    #     #   486    455    562
    #     #   taft  clev  trump
    #     #   jack  obam   bush
    #     #                madi
    #
    #     buckets.map( & :total )  # => [ 486, 455, 562 ]

    # the grocery analogy: let's say you were trying to pack 10 items into
    # three grocery bags, and you wanted the weight of the items distributed
    # as evenly as possible. how we would do it here is we would:
    #
    #   1) line up the items (on the floor or whatever) in descending
    #      order by weight.
    #
    #   2) put item 1 in bag 1, item 2 in bag 2, item 3 in bag three.
    #      actually you could go ahead and put item 4 into bag three too.
    #
    #   3) put item 5 in whichever bag is now the lightest.
    #      put item 6 in whichever bag is now the lightest.
    #      and so on.
    #
    # that's it.

    class << self

      def call st, d
        _define do |o|
          o.number_of_buckets = d
          o.upstream = st
        end.execute
      end

      alias_method :[], :call

      def prototype
        _define do |o|
          yield o
        end._freeze
      end

      def _define & p
        new( & p )._validate
      end

      private :new  # 1x
    end  # >>

    # -

      def new_by
        otr = dup
        yield otr
        otr._validate._freeze
      end

      def initialize
        @main_quantity_method_name = :main_quantity
        @number_of_buckets = nil
        yield self
      end

      alias_method :_freeze, :freeze
      undef_method :freeze

      private :dup

      attr_writer(
        :main_quantity_method_name,
        :number_of_buckets,
        :upstream,
      )

      def call upst
        invo = dup
        invo.upstream = upst
        invo.execute
      end
      alias_method :[], :call

      def _validate
        if @number_of_buckets
          if 0 < @number_of_buckets
            self
          else
            raise __say
          end
        else
          self
        end
      end

      def __say
        "`number_of_buckets` must be positive nonzero #{
          }(had #{ @number_of_buckets })"
      end

      def execute

        @__one_thru_index_of_last_bucket = 1 ... @number_of_buckets

        # (
        @_offset_of_final_bucket = @number_of_buckets - 1
        @_offset_of_current_bucket = -1
        @_place_in_bucket = :__place_in_bucket_for_first_row
        # )

        @_buckets = @number_of_buckets.times.map { THE_EMPTY_BUCKET___ }

        @_offset_of_last_zero_placement = nil

        __flush_sorted_tuples.each do |rec|
          send @_place_in_bucket, rec
        end

        remove_instance_variable :@_buckets
      end

      def __place_in_bucket_for_first_row rec

        if @_offset_of_final_bucket == @_offset_of_current_bucket
          remove_instance_variable :@_offset_of_current_bucket
          @_place_in_bucket = :__place_in_bucket_after_first_pass
          send @_place_in_bucket, rec
        else
          @_offset_of_current_bucket += 1
          if rec.number.zero?
            @_offset_of_last_zero_placement = @_offset_of_current_bucket
          end
          @_buckets[ @_offset_of_current_bucket ] = Bucket___.new rec
        end
        NIL
      end

      def __place_in_bucket_after_first_pass rec
        # one you have placed things in the N buckets
        case 0 <=> rec.number
        when -1
          __place_in_bucket_normally rec
        when 0
          __place_zero_in_some_bucket rec
        else
          self._DESIGN_ME_COVER_ME_negatives_  # #here-1
        end
        NIL
      end

      def __place_zero_in_some_bucket rec

        # OCD - if you have more than one zero-numbered node and we did not
        # do this special treatment, all those zero-numbered nodes would
        # always be placed in whatever the lightest bucket happens to be
        # at that moment. (the records are sorted, so all zero-numbered
        # nodes are adjacent. each zero-numbered node adds no weight to the
        # total of the bucket, so whichever bucket happens to be lightest
        # at the moment stays the lightest while these items are added.)
        #
        # with more than one zero-numbered item, this would produce a
        # divvy with (subjectively) an arbitrary or unbalanced-feeling
        # distribution of *items* (if not weight). so we simply round-robin
        # distribute the zeros, like a dealer dealing cards to players.

        d = if @_offset_of_last_zero_placement
          if @_offset_of_final_bucket == @_offset_of_last_zero_placement
            0
          else
            @_offset_of_last_zero_placement + 1
          end
        else
          0
        end
        @_buckets[ d ].add_tuple rec
        @_offset_of_last_zero_placement = d
        NIL
      end

      def __place_in_bucket_normally rec

        min_total = @_buckets.first.total
        offset_of_min_total_bucket = 0

        @__one_thru_index_of_last_bucket.each do |d|
          tot = @_buckets.fetch( d ).total
          if min_total > tot
            min_total = tot
            offset_of_min_total_bucket = d
          end
        end

        @_buckets[ offset_of_min_total_bucket ].add_tuple rec
        NIL
      end

      def __flush_sorted_tuples

        m = remove_instance_variable :@main_quantity_method_name
        a = []
        up_st = remove_instance_variable :@upstream
        begin
          tuple = up_st.gets
          tuple || break
          num = tuple.send m
          case 0 <=> num
          when -1
            a.push Record__[ num, tuple ]
          when 0
            # hi.
            a.push Record__[ num, tuple ]
          else
            self._DESIGN_ME_COVER_ME__main_quantity_is_below_zero__  # #here-1
          end
          redo
        end while above
        a.sort_by do |rec|
          - rec.number
        end
      end

    # -

    # ==

    Record__ = ::Struct.new(
      :number,
      :tuple,
    )

    # ==

    class Bucket___

      def initialize rec
        @total = rec.number
        @_tuples = [ rec.tuple ]
      end

      def add_tuple rec
        @total += rec.number  # if you switch from ints to floats you'll be sorry
        @_tuples.push rec.tuple ; nil
      end

      # --

      def first_child
        @_tuples.fetch 0
      end

      def children_count
        @_tuples.length
      end

      def to_child_stream
        Stream_[ @_tuples ]
      end

      attr_reader(
        :total,
      )

      def declared_total
        NOTHING_
      end
    end

    module THE_EMPTY_BUCKET___ ; class << self
      def total
        0
      end
    end ; end

    # ==
    # ==
  end
end
