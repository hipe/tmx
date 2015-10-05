module Skylab::Git

  module Models_::Branches  # create

    Brazen_ = ::Skylab::Brazen

    Autoloader_[ ( Actions = ::Module.new ), :boxxy ]

    class Actions::ReNumber < Brazen_::Action  # :[#012].

      Brazen_::Model::Entity.call( self,

        :desc, -> y do

     # until we re-integrate w/ n.curses and/or word-wrap (if ever):
     #12345_(10)12345_(20)12345_(30)12345_(40)12345_(50)12345_(60)12345_(70)12345_(80)

y << nil  # eek
y << "an experimental tool for an esoteric (and now arcane) branch-based workflow:"
y << "for those of your branches whose name starts with an integer, this tool"
y << "produces the rename commands (as strings) necessary to mutate the series,"
y << "by either \"closing gaps\" or expanding ranges as you like:"
y << nil
y << "if you have branches (1,2,3,9,10) and you are OCD about that gap in the middle"
y << "(between 3 and 9), you can close the gap by saying to yourself: \"self, that"
y << "current distance between 3 and 9 is 6. I want that distance to be 1. ergo I"
y << "want that distance to go down by 5.\" so to close this gap between these items"
y << "by this much, use the arguments (3, 9, -5) (which can be read as \"shrink the"
y << "distance bewteen 3 and 9 by 5.\"). this transformation produces the series"
y << "(1,2,3,4,5)."
y << nil
y << "in this same vein but the other direction, you can expand any sub-range of the"
y << "series by using a positive instead of negative integer for the change term:"
y << "against (5,10,15,16,20), (15, 16, +4) should give you (5,10,15,20,24)."
y << nil
y << "some details:"
y << nil
y << "unless otherwise stated, if the argument data does not meet the below criteria"
y << "then the utility will explain why it cannot be used as a request."
y << nil
y << "the \"from\" integer must be less than the \"to\" integer. both must refer to"
y << "actual items in the series, not just points with the series' range."
y << nil
y << "the operation categorizes the items of your series into a sparse series of"
y << "three categories: the span under your range, the span in your range and the"
y << "span above your range. any items in the first category are never moved. any"
y << "in the third category are always shifted upwards or downwards by the argument"
y << "amount."
y << nil
y << "as corollary to 2 points back, the first and last categories may be empty but"
y << "the middle category will always have at least two items. as for this \"segment\","
y << "the transformation involves breaking the target range up into more or less"
y << "equal parts, one part allocated for each item that was in the argument range."
y << "the first item is never moved."
y << nil
y << "because this scaling operation involves the imprecision of floating-point math,"
y << "we employ a \"spillover\" algorithm whereby each particular item ends up"
y << "\"snapping\" into a discrete integer-sized bucket in a manner that distributes"
y << "the items more or less proportionally across the target range."
y << nil
y << "we assume but to not prove here that this \"spillover\" approach produces"
y << "results that are more attractive (both algorithmically and in terms of results)"
y << "than would be achieved by simple rounding down or up."
y << nil
y << "also for this middle category, for all contractions that touch N items, the"
y << "target distance must be at a minimum N-1."
        end,

        :required, :property, :branch_name_stream,

        :required,
        :non_negative_integer,
        :property, :from,

        :required,
        :non_negative_integer,
        :property, :to,

        :required,
        :ad_hoc_normalizer, -> arg, & x_p do

          _normer = Brazen_.lib_.basic.normalizers.number(
            :number_set, :integer,
            :recognize_positive_sign,
          )

          if arg.is_known
            _normer.normalize_argument arg, & x_p
          else
            arg
          end
        end,
        :property, :plus_or_minus
      )

      def produce_result

        ok = __validate_terms
        ok &&= __resolve_branch_collection
        ok &&= __resolve_sorted_item_box_of_valid_length
        ok &&= __validate_item_constituency
        ok &&= __resolve_renames
        ok && __deliver_renames
      end

      def __resolve_branch_collection

        _st = @argument_box.fetch( :branch_name_stream ).map_by do | line_x |

          line_x.chomp!
          line_x
        end

        bc = Home_::Models::Branch_Collection.via_name_stream _st

        if bc
          @_branch_collection = bc ; ACHIEVED_
        else
          bc
        end
      end

      def __validate_terms

        h = @argument_box.h_
        @_from = h[ :from ]
        @_to = h[ :to ]
        @_plus_or_minus = h[ :plus_or_minus ]
        @_is_contraction = 0 > @_plus_or_minus

        if @_to <= @_from
          self._COVER_ME_bad_range
        else
          ACHIEVED_
        end
      end

      def __resolve_sorted_item_box_of_valid_length

        st = @_branch_collection.to_stream.map_reduce_by do | br |

          md = NUMBERED_BRANCH_RX__.match br.name_string
          if md
            Models_::Item.new md, br
          end
        end

        bx = Callback_::Box.new
        begin
          item = st.gets
          item or break

          bx.touch item.to_i do
            []
          end.push item
          redo
        end while nil

        case bx.length
        when 0, 1
          __when_zero_or_one bx.length
        else
          bx.a_.sort!
          @_item_box = bx ; ACHIEVED_
        end
      end

      def __when_zero_or_one d

        bc = @_branch_collection

        @on_event_selectively.call :error, :expression, :too_few_branches do | y |

          st = bc.to_stream
          one = st.gets
          _s = if one
            _ = one.name_string
            two = st.gets
            if two
              three = st.gets
              same = "began with an integer"
              __ = two.name_string
              if three
                "of #{ val _ }, #{ val __ } etc; none #{ same }"
              else
                "of #{ val _ } and #{ val __ }, neither #{ same }"
              end
            else
              "cannot do name transformations to only one branch: #{ val _ }"
            end
          else
            "no branches in input!"
          end
          y << _s
        end
        UNABLE_
      end

      def __validate_item_constituency

        bx = @_item_box

        h = @argument_box.h_
        miss_a = nil

        [ :from, :to ].each do | sym |

          d = h.fetch sym

          if ! bx.has_name d
            ( miss_a ||= [] ).push d
          end
        end

        if miss_a
          __when_failed_constituency miss_a
        else
          ACHIEVED_
        end
      end

      def __when_failed_constituency miss_a

        @on_event_selectively.call :error, :expression, :strange_items do | y |

          # #open [#hu-034] `sp_` was borky for this..

          _s_a = miss_a.map( & method( :ick ) )

          y << "#{ and_ _s_a } must be in the collection"

        end
        UNABLE_
      end

      def __resolve_renames

        o = if @_is_contraction
          Sessions_::Contraction.new( & @on_event_selectively )
        else
          Sessions_::Expansion.new( & @on_event_selectively )
        end

        o.from = @_from
        o.to = @_to
        o.item_box = @_item_box

        if @_is_contraction
          o.minus = @_plus_or_minus
        else
          o.plus = @_plus_or_minus
        end

        rn = o.execute

        if rn
          @_central_renames = rn
        else
          rn
        end
      end

      def __deliver_renames

        a = @_central_renames.dup

        # (we could be clever and make this a concatenation of two streams,
        # one of a static array and one of a functionally defined stream;
        # but currently we deem that more difficult to work with.)

        # find the index of the last item in "the range". from that item
        # up to the final item in the series, move the item arithmetically.

        d_a = @_item_box.a_

        ( d_a.index( @_to ) + 1 ).upto( d_a.length - 1 ) do | d |

          item_d = d_a.fetch d
          a.push [ item_d, ( item_d + @_plus_or_minus ) ]
        end

        # assume that the renames are in ascending order of first term.
        #
        # for expansions, you *always* avoid collisions by performing the
        # moves in reverse order:
        #
        # imagine moving items (1,2,3) to (1,3,5). when you rename 2 to 3,
        # you don't want the existing 3 to get clobbered. renaming 3 to 5
        # first avoids this.
        #
        # by similar inference, for contractions we *must* alwyas perform
        # the moves in order:
        #
        # imagine moving items (1,3,5) to (1,2,3). etc.

        if ! @_is_contraction
          a.reverse!
        end

        Callback_::Stream.via_nonsparse_array( a ).expand_by do | (d, d_) |

          _item_o_a = @_item_box.fetch d

          Callback_::Stream.via_nonsparse_array _item_o_a do | item_o |

            Models_::Rename.new d_, item_o
          end
        end
      end

      # ~

      Models_ = ::Module.new

      class Models_::Rename

        def initialize new_d, item_o

          @_item_o = item_o
          @_new_d = new_d
        end

        def express_into_under y, _expag

          y << "#{ GIT_EXE_ } branch -m #{ from_name } #{ to_name }"
        end

        def from_name

          @_item_o.x.name_string
        end

        def to_name

          # make the new number string be a zero-padded string of the same
          # width as the old number string unless the new number needs more
          # width than this, in which case add width as necessary.
          #
          # when there is would-be loss in width (e.g from "10" to "9")
          # the new number string will use the width of the old.
          #
          # so note that overall, width may be added but is never removed.

          item = @_item_o

          rest = item.rest  # any

          name_s = item.x.name_string

          number_width = name_s.length
          if rest
            number_width -= rest.length
          end

          _fmt = "%0#{ number_width }d"

          _number_s_ = _fmt % @_new_d

          "#{ _number_s_ }#{ rest }"
        end
      end

      class Models_::Item

        attr_reader( :to_i, :rest, :x )

        def initialize md, x

          @rest = md[ :rest ]

          @to_i = md[ :number_string ].to_i

          @x = x
        end
      end

      NUMBERED_BRANCH_RX__ = /\A(?<number_string>\d+)(?<rest>.+)?\z/

      # ~

      Sessions_ = ::Module.new

      Same__ = ::Class.new

      class Sessions_::Expansion < Same__

        attr_writer :plus

        def execute

          init_categories_
          init_derived_ivars_
          @_target_distance = @_current_distance + @plus
          produce_moves_ @plus
        end
      end

      class Sessions_::Contraction < Same__

        attr_writer :minus

        def execute

          # classify the series into three categories, ignoring the first

          init_categories_
          init_derived_ivars_
          @_target_distance = @_current_distance + @minus

          _ok = __validate_contraction_terms
          _ok and produce_moves_ @minus
        end

        def __validate_contraction_terms

          # axiom: the minium target distance is the number of items minus one.

          if @_target_distance < @_min_distance

            __when_too_much_squeeze
          else
            ACHIEVED_
          end
        end

        def __when_too_much_squeeze

          from = @from ; to = @to ; num = @_num_scale_items
          dc = @minus ; td = @_target_distance ; md = @_min_distance

          @on_event_selectively.call :error, :expression, :too_much_squeeze do | y |

            y << "between #{ from } and #{ to } there are #{ num } items."

            y << "desired contraction of #{ dc } #{
              }would bring distance down to #{ td }, but distance cannot #{
               }go below #{ md } for #{ num } items."
          end

          UNABLE_
        end
      end

      class Same__

        attr_writer :from, :item_box, :to

        def initialize & p
          @on_event_selectively = p
        end

        def init_derived_ivars_

          @_current_distance = @to - @from
          @_num_scale_items = @scale_these_.length
          @_min_distance = @_num_scale_items - 1
          NIL_
        end

        def init_categories_

          st = @item_box.to_name_stream
          begin
            d = st.gets
            d or break
            if @from > d
              redo
            end
            break
          end while nil

          if d && @to >= d

            scale_these = [ d ]
            begin
              d = st.gets
              d or break
              if @to >= d
                scale_these.push d
                redo
              end
              break
            end while nil
          end

          if d
            shift_these = [ d ]
            begin
              d = st.gets
              d or break
              shift_these.push d
              redo
            end while nil
          end

          @scale_these_ = scale_these
          @shift_these_ = shift_these
          NIL_
        end

        def produce_moves_ plus_or_minus

          # the first item is just a boundary marker; it doesn't actually
          # move. the last items's move distance is defined as being equal
          # to the argument amount of change. that leaves the remaining
          # zero or more items as needing some kind of "scale down". we
          # attempt something like [#br-073.B] the spillover algorithm.

          moves = []

          add_this_amount_per_item_f =
            1.0 * @_target_distance / ( @_num_scale_items - 1 )

          current_remainder_f = 0.0
          current_item = @scale_these_.first

          ( 1 ... ( @_num_scale_items - 1 ) ).each do | d |

            _before_d = @scale_these_.fetch d

            _f = current_item + add_this_amount_per_item_f

            after_d, f_ = _f.divmod 1

            current_remainder_f += f_

            if 1.0 <= current_remainder_f
              current_remainder_f -= 1.0
              after_d += 1
            end

            current_item = after_d

            moves << [ _before_d, after_d ]
          end

          item = @scale_these_.last

          moves << [ item, item + plus_or_minus ]
        end
      end
    end
  end
end
#  :+#tombstone: [#br-069] a snitch
