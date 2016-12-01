module Skylab::Zerk

  module CLI

    class HorizontalMeter

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

        THESE__ = [
          :background_glyph,
          :denominator,
          :foreground_glyph,
          :target_final_width,
        ]  # #here

        def denominator= x
          @_user_denominator_rational = Rational( x )
          x
        end

        attr_writer(  # :#here
          :background_glyph,
          :foreground_glyph,
          :target_final_width,
        )

        def % x

          # (this method name is as it is only because of `String#%`)

          user_x_rational = Rational( x )

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

            st = Home_.lib_.basic::Algorithm::
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

        THESE__.each do |sym|
          define_method sym do |x|
            @_.send :"#{ sym }=", x
            NIL
          end
        end
      end

#==BEGIN TABLE-SPECIFIC

      class << self
        def add_max_share_meter_field_to_table_design design_dsl, & p
          TableIntegrationSession___.new design_dsl do |dsl|
            p[ dsl ]
          end.execute
          NIL
        end
      end  # >>

      For_table_page_column_build_new_observation_of_max = -> o do

        max = 0.0  # (might change to integer whenever)

        o.on_typified_mixed do |tm|
          if tm.is_numeric && max < tm.value
            max = tm.value
          end
        end

        o.read_observer_by do
          max
        end

        NIL
      end

      For_table_design_add_total_summary_row_for_column = -> defn, col, label do

        # (stowaway in proximity to above. is :#spot-8)

        observer_key = :"_total_of_column__#{ col }__"  # hopefully unique name

        # --

        defn.add_summary_row do |o|
          o << "(total)"
          o << o.read_observer( observer_key )
        end

        # -- (will probably snip)

        defn.add_field_observer observer_key, :for_input_at_offset, col do |o|

          total = 0.0

          o.on_typified_mixed do |tm|
            if tm.is_numeric
              total += tm.value
            end
          end

          o.read_observer_by do
            total
          end
        end

        # -- (end will probably snip)
        NIL
      end

      class TableIntegrationSession___

        def initialize dsl

          @table_design_DSL = dsl

          @_meter_prototype = Here_._begin_
          @_meter_DSL = DSL__.new @_meter_prototype

          yield TableIntegrationDSL___.new self

          remove_instance_variable :@_meter_DSL

          @_meter_prototype._normalize_and_freeze_
        end

        def __receive_meter_DSL_parameter_ x, sym
          @_meter_DSL.send sym, x
        end

        attr_writer(
          :for_input_at_offset,
        )

        # --

        def execute

          hopefully_unique_name = :"_max_for_column__#{ @for_input_at_offset }__"

          @for_input_at_offset || self._COVER_ME_missing_required_argument  # #todo

          @table_design_DSL.add_field_observer(
            hopefully_unique_name,
            :for_input_at_offset, @for_input_at_offset,
            & For_table_page_column_build_new_observation_of_max
          )

          @table_design_DSL.add_field(
            :fill_field,
            :order_of_operation, 0,  # .. needs reflection API from table #todo
          ) do |col_rsx|

            w = col_rsx.width_allocated_for_this_column

            denom = col_rsx.read_observer hopefully_unique_name

            meter_format = @_meter_prototype.redefine do |o|

              o.denominator denom

              o.target_final_width w
            end

            empty_placeholder = SPACE_ * w

            -> row_rsx do

              tm = row_rsx.row_typified_mixed_at @for_input_at_offset
              if tm.is_numeric
                d_or_f = tm.value

                if denom < d_or_f

                  # watching this nastiness - #open [#058] this happens when
                  # we add a summary row and have fill fields - we can't
                  # discern easily that this is a summary row and that we
                  # should not give it the same visualization (because
                  # presumably it's a max share viz. and not a total share viz.)

                  empty_placeholder
                else
                  meter_format % d_or_f
                end
              else
                empty_placeholder
              end
            end
          end

          NIL
        end
      end

      # ==

      class TableIntegrationDSL___

        def initialize _
          @_ = _
        end

        def for_input_at_offset d
          @_.for_input_at_offset = d
        end

        THESE__.each do |sym|
          define_method sym do |x|
            @_.__receive_meter_DSL_parameter_ x, sym
          end
        end
      end

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
