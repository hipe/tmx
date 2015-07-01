module Skylab::Brazen

  class CLI::Expression_Frames::Table::Actor

    class Field_Strategies_::Fill

      ARGUMENTS = [
        :argument_arity, :custom, :property, :fill,
      ]

      ROLES = nil

      Table_Impl_::Strategy_::Has_arguments[ self ]

      def initialize x
        @parent = x
      end

      def dup
        self._DESIGN_ME
      end

      def receive_stream_after__fill__ st  # see article [#096.I]

        _fill = Fill_Model.new_via_polymorphic_stream_passively st

        @parent.current_field.add_component :fill, _fill

        @parent.field_parent.touch_dynamic_dependency Dynamic_Dependency

        KEEP_PARSING_
      end

      class Fill_Model  # (this is so great how simple it is)

        attr_reader(
          :background_glyph,
          :do_from_right,
          :glyph,
          :parts_float,
        )

        Callback_::Actor.methodic self

        def initialize & edit_p
          @background_glyph = SPACE_
          instance_exec( & edit_p )
        end

      private

        def background_glyph=
          @background_glyph = gets_one_polymorphic_value
          KEEP_PARSING_
        end

        def glyph=
          @glyph = gets_one_polymorphic_value
          KEEP_PARSING_
        end

        def from_right=
          @do_from_right = true
          KEEP_PARSING_
        end

        def parts=
          x = gets_one_polymorphic_value
          @parts_float = if x
            x.to_f
          end
          KEEP_PARSING_
        end
      end

      class Dynamic_Dependency  # adapt to [pl]

        def initialize _
          freeze
        end

        def dup _
          self
        end

        def roles
          [ :unused_width_consumer ]
        end

        def subscriptions
          NIL_
        end

        def receive_unused_width w, client

          o = Width_Distribution_Calculation___.new
          o.fields = client.field_array
          o.unused_width = w
          o.mutable_column_widths = client.mutable_column_widths
          o.execute
          NIL_
        end
      end

      class Width_Distribution_Calculation___

        # for the one or more "fill" columns, decide how wide each such
        # column can be (if at all) given how wide the user data columns
        # are, how wide the glyphs are, and the target width of the table.
        #
        # the mutable "column widths" hash gets mutated with the results.

        attr_writer(
          :fields,
          :mutable_column_widths,
          :unused_width,
        )

        def execute

          @_fill_column_index_a = []
          @_part_f_a = []
          @_total_parts_f = 0.0

          @fields.each_with_index do | fld, d |

            fill = fld[ :fill ]
            fill or next

            @_fill_column_index_a.push d

            fill_f = fill.parts_float || 1.0
            @_total_parts_f += fill_f
            @_part_f_a.push fill_f
          end

          if 1 > @unused_width
            __when_no_remaining_width
          else
            __when_remaining_width
          end
        end

        def __when_no_remaining_width

          # even though zero is supposed to be the default value for the
          # hash, we explicitly zero out the columns because `fetch`.

          @_fill_column_index_a.each do | d |
            @mutable_column_widths[ d ] = 0
          end
          NIL_
        end

        def __when_remaining_width

          # each fill column, get it its fraction of the available width
          # rounded down, with the spillover algorithm :+[#073.B]

          spillover_f = 0.0

          @_part_f_a.each_with_index do | part_f, idx |

            d, f = ( @unused_width * part_f ).divmod @_total_parts_f

            spillover_f += f

            if @_total_parts_f <= spillover_f
              spillover_f -= @_total_parts_f
              d += 1
            end

            @mutable_column_widths[ @_fill_column_index_a.fetch( idx ) ] = d
          end

          NIL_
        end
      end
    end
  end
end
