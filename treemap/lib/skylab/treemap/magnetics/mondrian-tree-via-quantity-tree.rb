module Skylab::Treemap

  class Magnetics::MondrianTree_via_QuantityTree < Common_::Actor::Monadic

    # (supplementary notes in [#003])

    # this is the central node of this project. the algorithm is based on
    # a whiteboard sketch that came to us in a flash of inspiration years
    # after we had put this on the backburner out of frustration over 3rd
    # party solutions.

    # reasons we don't use an existing algorithm or code from elsewhere
    # are discussed at #note-1. suffice it to say there are several.

    # the general idea is that you subdivide a rectangle recursively
    # in a manner that is proportional to your tree of data. the result
    # is a "mesh" that (EDIT)

    # the central algorithm can be simpified by understanding that it
    # recurses on itself in two regards: one is that it treats each branch
    # node of the input tree as a flat list of nodes (some of those nodes
    # are branch nodes into which it recurses); and two is that at each
    # such branch it subdivides the "current" rectangle into two smaller
    # rectangles in a recursive manner to be discussed below.

    # (we'll mention now that there may be an optimization possible that
    # would change the "two" of the above and much of the algo below; but
    # we're holding off on exploring this for now. see #note-4.)

    # so then the focus becomes these two questions:
    # (1) what is the structure of this flat list of tuples? and
    # (2) how is this list expressed in terms of subdividing a rectangle?

    # (1) is easy: each item of the tuple *must* have a `main_quantity`
    # which can be any positive nonzero number. this quantity is the central
    # input for the algorithm. each item will also have (probably) some kind
    # of identifying data that is carried through to the final output
    # structure. for now we call it `label_string` but imagine it is any
    # other thing; like maybe an image or even a tuple of things, like
    # a label, a color and an image. if this makes no sense, an example
    # is next.

    # (2) is where the fun begins:
    #
    # there might be a more efficient form of this algorithm, but this
    # will get us started:
    #
    # generally this:
    #
    # - there is always a "current rectangle", which at the start is
    #   the argument rectangle.
    #
    # - if the tuple list is zero items long, we are done. (this is probably
    #   an error case - it probably never makes sense to have a branch node
    #   with zero nodes.)
    #
    # - otherwise if the tuple list is one item long, this is a base case
    #   where we stop the algorithm for this rectangle. associate this
    #   item tuple with this rectangle (somehow). this case will be
    #   referenced below.
    #
    # - otherwise (and the list is more than one item long),
    #
    #   - the overall goal here is that we break up our 2..N items in
    #     this branch node into two sub-branches where the "weights" of
    #     the items are as evenly distributed as possible. for this we
    #     will use the [#ba-059] "divvy algorithm" which is like a box-
    #     packing algorithm meant to break up the weight of the items
    #     "fairly".  (but keep in mind, though, that it's possible for
    #     this break up to be "very" lopsided, depending on the data.)
    #
    #     from an unsorted list of tuples like this:
    #
    #         [["ps4", $230], ["xbox 360", $150], ["wii u", $290], [..]]
    #
    #     it produces buckets like this:
    #
    #          bucket 1              bucket 2
    #          wii u    $290         xbox one $250
    #          xbox 360 $150              ps4 $230
    #          ps3      $170
    #          total:   $610         total:   $480
    #
    #     (but see the source of the remote node for a better example.)
    #
    #   - you now have two buckets, each with 1..N items in it, and for
    #     each bucket a total weight of the bucket.
    #
    #   - you have a given rectangle. let's say it's:
    #
    #         +--------------+
    #         |              |
    #         |              |
    #         +--------------+
    #
    #     you're going to split this rectangle into two in proportions
    #     relative to the data. but first we have to decide whether to
    #     split it vertically or horizontally. to do this we'll use our
    #     "portrait-landscape-threshold" concept which is described at
    #     #note-3 and behaves mostly as expected.
    #
    #     so, if the rectangle (per its aspect ratio) is categorized as
    #     "portrait", we'll split it with the split running (um)
    #     horizontally. otherwise (and it's landscape) we'll split it
    #     with the split running vertically. note that all rectangles must
    #     categorize into one of these two, so for the square case, the
    #     sub-algorithm must have a policy for that.
    #
    #     so, now we know what orientation to run the split in, we have
    #     to decide exactly where to split it. let's say the current
    #     rectangle categorized as "landscape". so the split will run
    #     vertically.
    #
    #     now, review the totals of the two buckets. they are $610 and $480.
    #     add them up to get the "total total" ($1090) and ask: what share
    #     of this total-total is occupied by each of these totals? for the
    #     $610 total, it is about 56%, and for the other total it is the
    #     rest (about 44%). so the idea is, for each bucket, we calculate
    #     this term (always between 0.0 and 1.0 exclusive, colloquially
    #     expressed as percents). we call this term the "total share".
    #
    #     so we draw the split at a point 56% of the way over:
    #
    #         +--------------+
    #         |        |     |
    #         |        |     |
    #         +--------------+
    #
    #     now we have a sub-rectangle for bucket one, and another for
    #     bucket two. really, that's it! you repeat the algorithm
    #     for each rectangle until the bucket at that rectangle is of
    #     size one. note that each subsequent division of a sub-rectangle
    #     will chose whatever orientation "steers" the mesh towards an
    #     aesthetic objective per the "portrait-landscape-threshold"
    #
    # but remember #note-4 which is about how all of this might change.

      def initialize qt

        @quantity_tree = qt
        yield self
        @portrait_landscape_threshold_rational ||= Rational( 1 )  # ..
        @target_rectangle ||= [ 0, 0, 1, 1 ]
        __init_scaler_translator
        freeze
      end

      attr_writer(

        # (the following are ordered "highest-level" to "lowest-level".)

        :target_rectangle,

        # expressed in either two or four numeric components representing
        #   [ x, y, ] width, height
        # this serves both to start the algorithm off with a "current
        # rectangle" (the only significance being its aspect ratio),
        # and also this feeds into the "scaler translator" this is produced,
        # which some (not all) clients will use for expression.
        #
        # by default this is a "normal unit rectangle" of [ 0, 0, 1, 1 ]


        :portrait_landscape_threshold_rational,

        # this positive rational number determines when a rectangle is
        # considered "portrait" vs. "landscape", which in turn determines
        # whether a rectangle is split horizontally or vertically.
        #
        # the current rectangle's height divided by its width is compared
        # against this threshold. if this ratio meets or exceeds this
        # threshold, it's classified as portrait otherwise landscape.
        #
        # when a rectangle needs to be divided, the "slice" will be made
        # along the horizontal axis IFF the rectangle is classified as
        # portrait, otherwise (and it's landscape) the slice will be made
        # vertically.
        #
        # the default is 1.0, meaning that squares and taller are classified
        # as "portrait" and so will be divided horizontally upon division.
        # as this threshold is made greater than 1, the threshold for being
        # considered "portrait" is increased. 2.0 would mean you have to be
        # twice as tall as you are wide (or taller) to be considered
        # portrait, and so on.
        #
        # if you want to tend towards wider rectangles being produced,
        # bring this threshold downward from 1.0.
        #
        # if this threshold is 0.0 or below, behavior is undefined.
        # (probably you end up never splitting vertically, so probably
        # you end up with a mesh that looks like a wide ladder with
        # many rungs.)
      )

      def execute

        # the trick is, although we do the clever thing with subdividing
        # rects *in half* by bucketing a list of items into two buckets
        # (and so on recursively), we don't want the produced mesh to
        # reflect this always-by-two division. rather, any two terminal
        # data nodes that are siblings in the data should always correspond
        # to sub-rectangles that are siblings in the same parent rectangle.
        # (not that they should be physically close, just that the tree
        # structure of the mesh should follow the same structure of the data,
        # not the recursive execution path of our algorithm.)

        bucketser = __bucketer

        denominator_for = -> quant_tree do
          if quant_tree.declared_total
            self._FUN__declared_total__
          else
            quant_tree.total
          end
        end

        subdivide_along_buckets = nil

        recurse_into_quant = -> quant_tree, normal_rect do  # 2x

          # (#optimization possible here - if 2 == number of children and..)

          quant_tree.is_branch || self._SANITY

          _buckets = bucketser[ quant_tree.to_child_stream ]

          _denom = denominator_for[ quant_tree ]

          assoced_a = []

          subdivide_along_buckets[ assoced_a, _buckets, _denom, normal_rect ]

          AssociatedNonterminalNode___.new normal_rect, assoced_a.freeze
        end

        recurse_into_tall_bucket = nil

        subdivide_along_buckets = -> assoced_a, buckets, denom, normal_rect do  # 2x

          subd = normal_rect.build_sequential_subdivider__ buckets.length, denom

          buckets.each do |bucket|
            sub_rect = subd[ bucket.total ]
            case 1 <=> bucket.child_count
            when 0
              node = bucket.first_child
              if node.has_children
                node.IS_QUANTITY_TREE__ || fail  # #todo temp sanity
                _bn = recurse_into_quant[ node, sub_rect ]
                assoced_a.push _bn
              else
                _an = AssociatedTerminalNode___.new sub_rect, node
                assoced_a.push _an
              end
            when -1
              recurse_into_tall_bucket[ assoced_a, sub_rect, bucket ]
            else
              self._COVER_ME__zero_children_in_bucketish__probably_error__
            end
          end
          NIL
        end

        recurse_into_tall_bucket = -> assoced_a, normal_rect, bucket do

          1 < bucket.child_count || self._ASSUMPTION_FAILED

          _buckets = bucketser[ bucket.to_child_stream ]

          subdivide_along_buckets[ assoced_a, _buckets, bucket.total, normal_rect ]

          NIL
        end

        _initial_rect = __initial_normal_rect

        _associated_node = recurse_into_quant[ @quantity_tree, _initial_rect ]

        MondrianTree___.new _associated_node, @_scaler_translator
      end

      def __initial_normal_rect

        Home_::Models_::NormalRectangle.new( 0, 0, 1,
          @_scaler_translator.normal_rectangle_height,
          @portrait_landscape_threshold_rational,
        )
      end

      def __bucketer

        _ = Basic_::Algorithm::
        BucketList_that_is_FairlyDistributed_via_WeightedTupleStream_and_N_Buckets.
            prototype(
        ) do |o|
          o.number_of_buckets = 2  # #note-4
          o.main_quantity_method_name = :main_quantity
        end
        _  # #todo
      end

      def __init_scaler_translator

        user_a = @target_rectangle
        case user_a.length
        when 2
          user_a = [ 0, 0, * user_a ]
        when 4
        else
          self._ARGUMENT_ERROR__rectangle_must_have_two_or_four_components__
        end

        @_scaler_translator = Basic_::Rasterized::ScalerTranslator.
          via_normal_rectangle( * user_a )

        NIL
      end
    # -
    # ==

    # NOTE for the convenience of writing during development, some
    # related models are in here. but they should break out as appropriate.

    # ==

    class MondrianTree___

      def initialize an, ts
        @associated_node = an
        @scaler_translator = ts
      end

      attr_reader(
        :associated_node,
        :scaler_translator,
      )
    end

    # ==

    class AssociatedNonterminalNode___

      def initialize rect, a
        @associated_nodes = a
        @normal_rectangle = rect
      end

      attr_reader(
        :associated_nodes,
        :normal_rectangle,
      )

      def is_branch
        true
      end
    end

    # ==

    class AssociatedTerminalNode___

      def initialize rect, tuple  # (tuple is a Models::Node)
        @normal_rectangle = rect
        @tuple = tuple
      end

      attr_reader(
        :normal_rectangle,
        :tuple,
      )

      def is_branch
        false
      end
    end

    # ==

    # ==

    Require_basic_[]
  end
end
# #born after years and years of anticipation
