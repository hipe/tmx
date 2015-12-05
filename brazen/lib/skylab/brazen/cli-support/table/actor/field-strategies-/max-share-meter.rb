module Skylab::Brazen

  class CLI_Support::Table::Actor

    class Field_Strategies_::Max_Share_Meter

      ARGUMENTS = [
        :argument_arity, :custom, :property, :max_share_meter,
      ]

      ROLES = nil

      Table_Impl_::Strategy_::Has_arguments[ self ]

      def initialize x
        @parent = x
      end

      def receive_stream_after__max_share_meter__ st

        guy = Guy___.new_via_polymorphic_stream_passively st
        d = guy.of_column or raise ::ArgumentError

        fld = @parent.current_field
        par = @parent.field_parent

        fld.add_component :fill, guy.fill

        par.touch_dynamic_dependency(
          Field_Strategies_::Fill::Dynamic_Dependency )

        fld.add_component :formula_proc, ( -> row, col do

          d_or_f = row[ d ]
          if d_or_f
            1.0 * d_or_f / col.column_at( d )[ :stats ].numeric_max
          end
        end )

        fld.receive_stringifier nil
          # pass the above value thru as an argument

        fld.celifier_builder = Celifier_builder___

        par.touch_dynamic_dependency(
          Field_Strategies_::Statistics::Dynamic_Dependency )

        KEEP_PARSING_
      end

      Celifier_builder___ = -> mtx do

        fld = mtx.field

        fill = fld[ :fill ]

        bg_glyph = fill.background_glyph
        glyph = fill.glyph
        width = mtx.column_width

        final = if fill.do_from_right
          -> num_pluses, num_spaces do
            "#{ bg_glyph * num_spaces }#{ glyph * num_pluses }"
          end
        else
          -> num_pluses, num_spaces do
            "#{ glyph * num_pluses }#{ bg_glyph * num_spaces }"
          end
        end

        -> max_share_f do

          if max_share_f  # none for header row

            num_pluses = ( max_share_f * width ).floor
            final[ num_pluses, width - num_pluses ]
          end
        end
      end

      class Guy___

        Callback_::Actor.methodic self

        class << self
          alias_method :new_via_polymorphic_stream_passively, :new
        end

        attr_reader(
          :fill,
          :of_column
        )

        def initialize st

          d = st.current_token

          process_polymorphic_stream_passively st

          if d == st.current_token
            try_again = true
          end

          @fill = Field_Strategies_::Fill::Fill_Model.new do

            process_iambic_fully [
              :background_glyph, DEFAULT_BACKGROUND_GLYPH___,
              :glyph, DEFAULT_GLYPH___
            ]

            process_polymorphic_stream_passively st
          end

          if try_again
            process_polymorphic_stream_passively st
          end
        end

      private

        def of_column=
          @of_column = gets_one_polymorphic_value
          KEEP_PARSING_
        end

        DEFAULT_GLYPH___ = '+'.freeze
        DEFAULT_BACKGROUND_GLYPH___ = SPACE_

      end
    end
  end
end
