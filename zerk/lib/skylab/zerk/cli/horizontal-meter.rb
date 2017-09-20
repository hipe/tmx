module Skylab::Zerk

  module CLI

    class HorizontalMeter  # notes at [#059]

      # formerly known as a "lipstick", this simple ASCII visualization is
      # typically used to show a "max share meter" in a table (which is
      # visually similar to the "+" and "-" visualization that appears in
      # for example `git log -1 --stat`).

      # because the parts having to do with CLI tables are hypothetically
      # distinct and certainly more specialized than just the concerns of
      # the generic "meter", they have been "cordoned off" in this file;
      # however in practice we only ever use such meters in tables.

      class << self

        def define
          o = _begin_
          yield DSL__.new o
          o._normalize_and_freeze_
        end

        alias_method :_begin_, :new
        undef_method :new
      end  # >>

      # -
        def initialize
          @_additive_normalizer_rational = nil
          NOTHING_  # hi.
        end

        def initialize_copy _
          NOTHING_  # hi.
        end

        def redefine
          otr = dup
          yield DSL__.new otr
          otr._normalize_and_freeze_
        end

        def _normalize_and_freeze_
          @background_glyph ||= BACKGROUND_GLYPH___
          @foreground_glyph ||= FOREGROUND_GLYPH___
          freeze
        end

        plain_old_writers = [
          :background_glyph,
          :foreground_glyph,
          :target_final_width,
        ]

        METER_ATTRIBUTES___ = [
          :denominator,
          :negative_minimum,
          * plain_old_writers,
        ]

        def negative_minimum= d  # see [#059.A] about topic
          if -1 < d
            self._ARGUMENT_ERROR__negative_minimum_must_be_negative
          end
          @_additive_normalizer_rational = Rational( -d )
          d
        end

        def denominator= x
          @_user_denominator_rational = Rational( x )
          x
        end

        attr_writer(
          * plain_old_writers
        )

        def % x

          # (this method name is as it is only because of `String#%`)

          user_x_rational = Rational( x )

          if @_additive_normalizer_rational
            user_x_rational += @_additive_normalizer_rational
          end

          user_width_of_right_hand_side_rational =
            @_user_denominator_rational - user_x_rational

          if 0 > user_width_of_right_hand_side_rational
            ::Kernel._K  # see #tombstone-B
          else
            __normally user_x_rational, user_width_of_right_hand_side_rational
          end
        end

        def __normally user_x_rational, user_width_of_right_hand_side_rational

          # even though it's a trivial case, as a #contact-exercise
          # we're using this guy because this is squarely its domain.

          # if the below gives us trouble, we can simplify it so that we
          # close the gap between the left side and the rest with plain
          # old subtraction of integers. instead, to stress-test the remote
          # node we want to see if it lands on the end cleanly on its own..

          _always_2 = [ user_x_rational, user_width_of_right_hand_side_rational ]

          _number_stream = Stream_[ _always_2 ]

            st = Basic_[]::Algorithm::
          DiscreteStream_via_NumeratorStream_and_DiscretePool_and_Denominator[
            _number_stream,
            @target_final_width,
            @_user_denominator_rational,
          ]

          _left_width = st.gets
          right_width = st.gets  # moneyshot
          _no = st.gets
          _no && fail

          buffer = @foreground_glyph * _left_width  # might be zero

          if right_width.nonzero?
            buffer << ( @background_glyph * right_width )
          end

          buffer
        end
      # -

      # ==

      class DSL__

        def initialize _
          @_ = _
        end

        METER_ATTRIBUTES___.each do |sym|
          define_method sym do |x|
            @_.send :"#{ sym }=", x
            NIL
          end
        end
      end

#==BEGIN TABLE-SPECIFIC

      class << self

        def add_max_share_meter_field_to_table_design table_design_DSL
          sess = AddToTable.begin table_design_DSL
          yield sess
          sess.finish
          NIL
        end
      end  # >>

      # ==

      class AddToTable

        class << self
          alias_method :begin, :new
          undef_method :new
        end  # >>

        def initialize table_design_DSL

          @__mutable_meter_mutex = nil
          @_receive_meter_attribute = :__receive_first_meter_attribute

          @table_design_DSL = table_design_DSL
        end

        # -- writers (all "DSL" style)

        def __receive_first_meter_attribute x, sym
          mutable_meter_prototype Here_._begin_
          send @_receive_meter_attribute, x, sym
        end

        def mutable_meter_prototype o
          remove_instance_variable :@__mutable_meter_mutex
          @_receive_meter_attribute = :__receive_first_meter_attribute_when_have_prototype
          @_finish_meter_prototype = :__finish_meter_prototype_when_mutable
          @mutable_meter_prototype = o
          NIL
        end

        def meter_prototype o
          remove_instance_variable :@__mutable_meter_mutex
          @_receive_meter_attribute = :__CLOSED
          @_finish_meter_prototype = :__no_op
          @meter_prototype = o
          NIL
        end

        METER_ATTRIBUTES___.each do |sym|
          define_method sym do |x|
            send @_receive_meter_attribute, x, sym
          end
        end

        def __receive_first_meter_attribute_when_have_prototype x, sym
          @_meter_DSL = DSL__.new @mutable_meter_prototype
          @_receive_meter_attribute = :__receive_meter_attribute_normally
          send @_receive_meter_attribute, x, sym
        end

        def __receive_meter_attribute_normally x, sym
          @_meter_DSL.send sym, x
          NIL
        end

        def for_input_at_offset d
          @observer_key = :"_max_for_column__#{ d }__"  # ..
          @for_input_at_offset = d
          NIL
        end

        # --

        def finish
          send @_finish_meter_prototype
          add_field_observer
          __add_field
          NIL
        end

        def __finish_meter_prototype_when_mutable
          @_finish_meter_prototype = :__FINISHED_A
          remove_instance_variable :@_meter_DSL
          o = remove_instance_variable :@mutable_meter_prototype
          o._normalize_and_freeze_
          @meter_prototype = o
          NIL
        end

        def add_field_observer
          @table_design_DSL.add_field_observer(
            @observer_key,
            :for_input_at_offset, @for_input_at_offset,
            & For_table_page_column_build_new_observation_of_max___
          )
          NIL
        end

        def __add_field

          _observer_key = @observer_key

          add_field_derived_from_min_and_max_by do |col_rsx|
            col_rsx.read_observer _observer_key
          end
          NIL
        end

        def add_field_derived_from_min_and_max_by  # 1x [tab] 1x here

          @table_design_DSL.add_field(
            :fill_field,
            :order_of_operation_next,
          ) do |col_rsx|

            # what we do now with the min and max is exactly the subject
            # of [#059.1] "negative minimums", and [#050.2] (maybe a stub)

            min, max = yield col_rsx

            if 0 > min

              min_rational = Rational( min )
              denominator = Rational( max ) - min_rational  # ..
              negative_minimum = min_rational
            else

              denominator = max
              negative_minimum = NOTHING_
            end

            _field_offset = col_rsx.field_offset_via_input_offset__ @for_input_at_offset

            _cel_width = col_rsx.width_allocated_for_this_column

            BuildCelRenderer___.define do |o|
              o.cel_width = _cel_width
              o.denominator = denominator
              o.field_offset = _field_offset
              o.meter_prototype = @meter_prototype
              o.negative_minimum = negative_minimum
            end.execute
          end
        end

        def __no_op
          NOTHING_
        end
      end

      # ==

      For_table_page_column_build_new_observation_of_max___ = -> o do

        # (you might want to push this up to be a common observation function :#spot1.8)

        min = nil ; max = nil

        see_normally = -> num do
          if max < num
            max = num
          elsif min > num
            min = num
          end
        end

        see = -> num do
          min = num ; max = num
          see = see_normally
        end

        o.on_typified_mixed do |tm|
          if tm.is_numeric
            see[ tm.value ]
          end
        end

        o.read_observer_by do
          [ min, max ]  # #here-1
        end

        NIL
      end

      For_table_design_add_total_summary_row_for_column = -> defn, col, label do

        observer_key = :"_total_of_column__#{ col }__"  # hopefully unique name

        defn.add_summary_row do |o|
          o << "(total)"
          o << o.read_observer( observer_key )
        end

        defn.add_field_observer(
          observer_key,
          :do_this, :SumTheNumerics,
          :for_input_at_offset, col,
        )

        NIL
      end

      # ==
                  # watching this nastiness - #open [#058] this happens when
                  # we add a summary row and have fill fields - we can't
                  # discern easily that this is a summary row and that we
                  # should not give it the same visualization (because
                  # presumably it's a max share viz. and not a total share viz.)
                  # :#table-coverpoint-I-2

      class BuildCelRenderer___ < Home_::SimpleModel_

        def initialize
          @negative_minimum = nil
          super
        end

        attr_writer(
          :cel_width,
          :denominator,
          :field_offset,
          :meter_prototype,
          :negative_minimum,
        )

        def execute

          field_offset = @field_offset
          meter_format = __meter_format
          max = __max

        # -

        empty_placeholder = SPACE_ * @cel_width

        -> row_rsx do

          tm = row_rsx.row_typified_mixed_at_field_offset_softly field_offset

          if tm && tm.is_numeric

            d_or_f = tm.value

            if max < d_or_f
              # probably nasty case :#table-coverpoint-I-1, a total cel
              empty_placeholder
            else
              meter_format % d_or_f
            end
          else
            empty_placeholder
          end
        end
        # -
        end

        def __meter_format

          @meter_prototype.redefine do |o|

            d = @negative_minimum
            if d
              o.negative_minimum d
            end

            o.denominator @denominator
            o.target_final_width @cel_width
          end
        end

        def __max
          max = @denominator
          d = @negative_minimum
          if d
            max + d
          else
            max
          end
        end
      end

      # ==

#==END TABLE-SPECIFIC

      # ==

      BACKGROUND_GLYPH___ = SPACE_
      FOREGROUND_GLYPH___ = '+'.freeze
      Here_ = self

      # ==
    end
  end
end
# #tombstone-B: we used to have a thing that rendered an error string here
# #tombstone: full rewrite/reconception during unification
