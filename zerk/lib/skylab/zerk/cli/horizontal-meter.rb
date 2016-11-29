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
          :denominator,
          :background_glyph,
          :foreground_glyph,
          :target_final_width,
        ]

        attr_writer( * THESE__ )

        def % x

          _ratio = ( x.to_f / @denominator )

          left_count_f = _ratio * @target_final_width

          left_count_d = left_count_f.to_i

          if left_count_f != left_count_d
            $stderr.puts "#{ '<' * 80 }\n  [ze] dropping modulo for now - eventually use etc here \n#{ '>'* 80 }\n\n"
          end

          left_count_f = nil

          if left_count_d > @target_final_width

            # ICK workaround for total cels until #open [#058]

            buffer = "(!#{ x }!)"
            if buffer.length > @target_final_width
              buffer[ 0, @target_final_width ]
            else
              buffer << ( SPACE_ * ( @target_final_width - buffer.length ) )
            end
          else

            buffer = @foreground_glyph * left_count_d

            buffer << ( @background_glyph * ( @target_final_width - left_count_d ) )
          end
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
# #tombstone: full rewrite/reconception during unification
