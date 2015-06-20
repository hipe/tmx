module Skylab::Brazen

  class CLI::Expression_Frames::Table::Actor

    class Field_Strategies_::Fill < Argumentative_strategy_class_[]

      PROPERTIES = [
        :argument_arity, :custom, :property, :fill
      ]

      def initialize plugin_ID, resources
        super
      end

      def receive_stream_after__fill__ st

        _x = Model___.new_via_polymorphic_stream_passively st

        @resources.current_field.add_component :fill, _x

        @resources.touch_role :_fill_ do

          [ :mutate_per, Change_wiring___ ]
        end

        KEEP_PARSING_
      end

      class Model___

        attr_reader(
          :glyph,
          :parts_float,
        )

        Callback_::Actor.methodic self

        def initialize & edit_p
          instance_exec( & edit_p )
        end

      private

        def glyph=
          @glyph = gets_one_polymorphic_value
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

      module Change_wiring___ ; class << self

        def [] row_formatter

          # (the fact that we change the row receiver when there is
          #  a target width is a bit OCD; chalk it up as an exercise)

          row_formatter.user_matrix_receiver.replace_row_receiver_by do | prev |

            Row_Receiver___.new prev
          end

          row_formatter.session_for_adding_dependency(
            User_Data_Receiver___.new
          ) do | y |
            y << :user_data_metrics
          end

          NIL_
        end
      end ; end

      class User_Data_Receiver___

        def receive_user_data_metrics udm
          Width_Distribution_Calculation___.new( udm ).execute
        end
      end

      class Row_Receiver___

        # as an exercise, the point of this row receiver is to be placed
        # in front of the default one, and all it does is it skips entirely
        # the act of producing a "content" string for those user datapoints
        # that are nil (because the cels that correspond to such fields are
        # typically nil, and there's no point in turning them into empty
        # strings, because of the custom celifiers that are produced).

        def initialize drr

          @_downstream_row_receiver = drr
        end

        def receive_user_row x_a

          @_downstream_row_receiver.session_for_adding_content_row do | o |

            x_a.each_with_index do | x, d |

              if ! x.nil?
                o.for_current_content_row_receive_user_datapoint x, d
              end
            end
          end
        end
      end

      class Width_Distribution_Calculation___

        # for the one or more "fill" columns, decide how wide each such
        # column can be (if at all) given how wide the user data columns
        # are, how wide the glyphs are, and the target width of the table.
        #
        # the mutable "column widths" hash gets mutated with the results.

        def initialize user_data_metrics
          @_udm = user_data_metrics
        end

        def execute

          udm = remove_instance_variable :@_udm

          @_fill_column_index_a = []
          fld_a = udm.fields
          @_maxes = udm.column_widths
          num_fields = fld_a.length
          @_part_f_a = []

          total_used_width = 0
          @_total_parts_f = 0.0

          fld_a.each_with_index do | fld, d |

            fill = fld[ :fill ]

            if fill
              fill_f = fill.parts_float || 1.0
              @_total_parts_f += fill_f
              @_part_f_a.push fill_f
              @_fill_column_index_a.push d
            else
              total_used_width += @_maxes.fetch( d )
              # by this selfsame comment as declaration, the width
              # of all non-fill columns must be known by now
            end
          end

          total_used_width += ( udm.left_w + udm.right_w )
          if 1 < num_fields
            total_used_width += ( udm.sep_w * ( num_fields - 1 ) )
          end

          @_available_width = udm.target_width - total_used_width

          if 1 > @_available_width
            __when_no_remaining_width
          else
            __when_remaining_width
          end
        end

        def __when_no_remaining_width

          # even though zero is supposed to be the default value for the
          # hash, we explicitly zero out the columns because `fetch`.

          @_fill_column_index_a.each do | d |
            @_maxes[ d ] = 0
          end
          NIL_
        end

        def __when_remaining_width

          # each fill column, get it its fraction of the available width
          # rounded down, with the spillover algorithm :+[#073.B]

          spillover_f = 0.0

          @_part_f_a.each_with_index do | part_f, idx |

            d, f = ( @_available_width * part_f ).divmod @_total_parts_f

            spillover_f += f

            if @_total_parts_f <= spillover_f
              spillover_f -= @_total_parts_f
              d += 1
            end

            @_maxes[ @_fill_column_index_a.fetch( idx ) ] = d
          end

          NIL_
        end
      end
    end
  end
end
