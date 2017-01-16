module Skylab::Zerk

  module CLI::Table

    module Models_::FillField

      # the main challenge here is one of discrete arithmetic.
      # generally the thing is
      #
      #   1) calculate the projected would-be width of the table as-is,
      #      taking into account the widths of the separator glyphs and the
      #      widths of the non-fill fields (according to the page survey).
      #      the fill fields should not have any width at this point.
      #
      #   2) determine how much width you have left by subtracting the above
      #      term from the `target_final_width` of the page design.
      #
      #   3) - if you have zero or negative width left, you are done.
      #
      #      - otherwise, if the width you have left (which is a positive
      #        integer) is less than the number of fill fields you have,
      #        also you are done. (it's all-or-nothing; we don't play
      #        favorites by giving some fields some and others none.)
      #        (this might change, as it's contrary to the "spillover"
      #        philosophy.)
      #
      #      - otherwise you have at least one "pixel" of width to
      #        distribute to each fill field. this positive nonzero integer
      #        of width is the "discrete pool". distribute this pool to the
      #        participants using the "spillover" algorithm of [ba].
      #
      # the above forms the foundation for the logic #here-1.

      class << self

        def build_index_by & p
          BuildIndex___.new( & p ).execute
        end
      end  # >>

      # ==

      class BuildIndex___  # near SimpleModel_

        def initialize
          yield self
        end

        attr_accessor(
          :all_defined_fields,
          :input_to_output_offset_map,
          :order_array,
        )

        def execute

          __validate_positions_and_prepare_to_slice

          if @_plain_field_count.zero?

            my_ord_a = @order_array
          else

            ord_a = @order_array[ 0, @_plain_field_count ]
            my_ord_a = @order_array[ @_plain_field_count .. -1 ].freeze
          end

          if @_parts_mode
            _total_parts = @total_parts
          end

          FillFieldIndex___.define do |o|
            o.all_defined_fields = @all_defined_fields
            o.input_to_output_offset_map = @input_to_output_offset_map
            o.my_order_array = my_ord_a
            o.plain_order_of_operations_offset_array = ord_a
            o.total_parts = _total_parts
          end
        end

        def __validate_positions_and_prepare_to_slice

          # assert that the summary fields (plain or fill) in execution
          # order follow the pattern
          #     P* F+
          # and make note of the number of plain fields.

          @_on_plain_field = :__on_plain_field_when_OK
          @_on_fill_field = :__on_first_fill_field

          @_plain_field_count = 0

          fields = @all_defined_fields
          @order_array.each do |d|
            fld = fields.fetch d
            if fld.is_summary_field_fill_field
              send @_on_fill_field, fld
            else
              send @_on_plain_field
            end
          end

          remove_instance_variable :@_on_plain_field
          remove_instance_variable :@_on_fill_field
          NIL
        end

        def __on_plain_field_when_OK
          @_plain_field_count += 1
        end

        def __on_first_fill_field fld

          # here we validate the use of `parts` across the fill fields.
          # (they must be all-or-nothing). :#here-2 assumes this.

          x = fld.parts
          if x
            @_parts_mode = true
            @total_parts = x
            @_on_fill_field = :__on_fill_field_expect_parts
          else
            @_parts_mode = false
            @_on_fill_field = :__on_fill_field_expect_no_parts
          end

          @_on_plain_field = :__on_plain_field_when_not_OK
        end

        def __on_plain_field_when_not_OK
          self._COVER_ME__all_non_fill_summary_fields_must_be_executed_before_all_fill_summary_fields__  # #todo
        end

        def __on_fill_field_expect_no_parts fld
          if fld.parts
            self._COVER_ME__expected_no_parts_but_had_parts__  # #todo
          end
        end

        def __on_fill_field_expect_parts fld
          x = fld.parts
          if x
            @total_parts += x
          else
            self._COVER_ME__expected_parts_but_had_no_parts__  # #todo
          end
        end

        def __on_fill_field_normally
          NOTHING_  # no need to count or anything.
        end
      end  # >>

      # ==

      class FillFieldIndex___ < SimpleModel_

        def to_tuple_mutator_for_XX page_data, invo
          TupleMutator___.factory page_data, self, invo
        end

        attr_accessor(
          :all_defined_fields,
          :input_to_output_offset_map,
          :my_order_array,
          :plain_order_of_operations_offset_array,
          :total_parts,
        )
      end

      # ==

      class TupleMutator___

        # most of the work here is at construction.
        # the responsibility of the subject is to receive in order each
        # intermediate tuple of the page and for each fill cel in that
        # tuple, call its callback with a row client in order to acquire
        # the string to populate the fill cel with.

        class << self
          def factory _1, _2, _3
            new( _1, _2, _3 ).__flush_to_tuple_mutator
          end
          private :new
        end  # >>

        def initialize page_data, index, invo

          @_field_survey_writer = page_data.field_survey_writer
          @__input_to_output_offset_map = index.input_to_output_offset_map

          @all_defined_fields = index.all_defined_fields
          @invocation = invo
          @my_order_array = index.my_order_array
          @total_parts = index.total_parts

          @_number_of_fill_fields = @my_order_array.length
        end

        def __flush_to_tuple_mutator

          # the bulk of this will attempt to be a faithful
          # implementation of the pseudocode :#here-1.

          if __there_is_enough_extra_width_available_to_go_around
            __DISTRIBUTE_THE_WIDTH_TO_THE_CELS_USING_THE_SPILLOVER_ALGORITHM
          else
            __since_there_is_not_enough_width_you_get_NOTHING
          end
        end

        def __there_is_enough_extra_width_available_to_go_around

          w = __total_available_width_for_pool

          if @_number_of_fill_fields > w
            UNABLE_
          else
            @_width_in_discrete_pool = w
            ACHIEVED_
          end
        end

        def __since_there_is_not_enough_width_you_get_NOTHING

          BlankWriter___.new @my_order_array, @all_defined_fields, @_field_survey_writer
        end

        def __total_available_width_for_pool

          current_table_width = __current_table_width

          target_final_width = @invocation.design.target_final_width

          if ! target_final_width
            self._COVER_ME__decide_on_some_default_and_cover_it_for_target_final_width  # #todo
          end

          target_final_width - current_table_width
        end

        def __current_table_width

          _  = Here_::Magnetics_::TableWidth_via_PageSurvey.call(
            @_field_survey_writer,
            @invocation.design,
          )
          _  # #todo
        end

        def __DISTRIBUTE_THE_WIDTH_TO_THE_CELS_USING_THE_SPILLOVER_ALGORITHM

          sparse_widths = []
          cel_renderers = []

          st = __discrete_width_pair_stream
          begin
            pair = st.gets
            pair || break

            w = pair.value_x
            field_offset = pair.name_x

            fs = @_field_survey_writer.dereference field_offset
            fs.width_of_widest_string < w || fail
            fs.maybe_widen_width_of_widest_string w

            sparse_widths[ field_offset ] = w

            fld = @all_defined_fields.fetch field_offset

            _ins = ColumnBasedResourcesForClient___.new(
              w, @__input_to_output_offset_map, @invocation )

            p = fld.fill_field_proc[ _ins ]
            p.respond_to? :call or self._COVER_ME__strange_shape  # #todo

            cel_renderers[ field_offset ] = p

            redo
          end while nil

          @_cel_renderers = cel_renderers
          @_sparse_widths = sparse_widths
          self
        end

        def __discrete_width_pair_stream

          tot = @total_parts

          # we validated that the use of `parts` is all-or-nothing #here-2.
          # it's "all" if `tot` is true-ish, otherwise "nothing".

          if tot

            use_denominator = tot

            real_st = Common_::Stream.via_times @_number_of_fill_fields do |dd|

              @all_defined_fields.fetch( @my_order_array.fetch dd ).parts
            end
          else

            use_denominator = @_number_of_fill_fields

            real_st = Common_::Stream.via_times @_number_of_fill_fields do
              1
            end
          end

            width_integer_st = Basic_[]::Algorithm::

          DiscreteStream_via_NumeratorStream_and_DiscretePool_and_Denominator.call(
            real_st,
            @_width_in_discrete_pool,  # an integer
            use_denominator,
          )

          # because we simplified the above to be a plain old stream of
          # integers and not qualified pairs, we gotta pay it back here

          dd = -1

          Common_.stream do

            width_d = width_integer_st.gets
            if width_d
              dd += 1
              Common_::Pair.via_value_and_name width_d, @my_order_array.fetch( dd )
            end
          end
        end

        def populate_or_overwrite_typified_cels mutable_a

          row_rsx = RowBasedResourcesForClient___.new mutable_a

          @my_order_array.each do |d|

            _w = @_sparse_widths.fetch d

            fld = @all_defined_fields.fetch d

            s = @_cel_renderers.fetch( d )[ row_rsx ]

            if fld.is_in_place_of_input_field  # #table-spot-5 repetition
              mutable_a.fetch( d ) || self._SANITY
            else
              mutable_a.fetch( d ) && self._SANITY
            end

            if ! s.respond_to? :ascii_only?
              self._COVER_ME__produced_fill_value_was_not_a_string__  # #todo
            end

            if _w != s.length
              self._COVER_ME__length_of_produced_fill_string_was_not_the_right_length_  # #todo
            end

            mutable_a[ d ] = @_field_survey_writer.
              see_then_typified_mixed_via_value_and_index s, d
          end
          NIL
        end
      end

      # ==

      # (vaguely similar to #table-spot-4)

      class ColumnBasedResourcesForClient___

        def initialize w, a, invo

          @__invo = invo
          @__input_to_output_offset_map = a
          @width_allocated_for_this_column = w
        end

        def read_observer sym
          @__invo.read_observer_ sym
        end

        def field_offset_via_input_offset__ dd
          @__input_to_output_offset_map.fetch dd
        end

        attr_reader(
          :width_allocated_for_this_column,
        )
      end

      class RowBasedResourcesForClient___

        def initialize arr
          @__arr = arr
        end

        def row_typified_mixed_at_field_offset_softly d  # 2 defs here, 1x [ze]
          @__arr[ d ]
        end
      end

      # ==

      class BlankWriter___

        # send an empty string to each participanting cel.

        def initialize order_a, fields, field_survey_writer
          @__all_fields = fields
          @__field_survey_writer = field_survey_writer
          @__order_array = order_a
        end

        def populate_or_overwrite_typified_cels mutable_a

          @__order_array.each do |d|

            fld = @__all_fields.fetch d

            if fld.is_in_place_of_input_field  # #table-spot-5 repetition
              mutable_a.fetch( d ) || self._SANITY
            else
              mutable_a.fetch( d ) && self._SANITY
            end

            mutable_a[ d ] = @__field_survey_writer.
              see_then_typified_mixed_via_value_and_index EMPTY_S_, d
          end
          NIL
        end
      end

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
    end
  end
end
# #tombstone: no more `background_glyph`; chunk of doc explaining old fill issues
