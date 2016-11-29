      # ==

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

      # ==
# #tombstone: no more `background_glyph`; chunk of doc explaining old fill issues
