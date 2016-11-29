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
      # the above forms the foundation for the logic #here.

      class << self

        def build_index fill_a, ord_a, fields
          BuildIndex___.new( fill_a, ord_a, fields ).execute
        end
      end  # >>

      # ==

      class BuildIndex___

        def initialize fill_a, ord_a, fields
          @_all_defined_fields = fields
          @_fill_field_offsets = fill_a
          @_order_array = ord_a
        end

        def execute

          __validate_positions_and_prepare_to_slice

          if @_plain_field_count.zero?

            my_ord_a = @_order_array
          else

            ord_a = @_order_array[ 0, @_plain_field_count ]
            my_ord_a = @_order_array[ @_plain_field_count .. -1 ].freeze
          end

          if @_parts_mode
            _total_parts = @_total_parts
          end

          Index___.new _total_parts, ord_a, my_ord_a, @_all_defined_fields
        end

        def __validate_positions_and_prepare_to_slice

          # assert that the summary fields (plain or fill) in execution
          # order follow the pattern
          #     P* F+
          # and make note of the number of plain fields.

          @_on_plain_field = :__on_plain_field_when_OK
          @_on_fill_field = :__on_first_fill_field

          @_plain_field_count = 0

          fields = @_all_defined_fields
          @_order_array.each do |d|
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
            @_total_parts = x
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
            @_total_parts += x
          else
            self._COVER_ME__expected_parts_but_had_no_parts__  # #todo
          end
        end

        def __on_fill_field_normally
          NOTHING_  # no need to count or anything.
        end
      end  # >>

      # ==

      class Index___

        def initialize total_parts, ord_a, my_ord_a, all_defined_fields

          @_all_defined_fields__ = all_defined_fields
          @_my_order_array__ = my_ord_a
          @_total_parts__ = total_parts

          @plain_order_of_operations_offset_array = ord_a
        end

        def to_tuple_mutator_for_XX page_data, invo

          TupleMutator___.factory page_data, invo, self
        end

        attr_reader(
          :_all_defined_fields__,
          :_my_order_array__,
          :plain_order_of_operations_offset_array,
          :_total_parts__,
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
          def factory * a
            new( * a ).__factory
          end
          private :new
        end  # >>

        def initialize page_data, invo, index

          @_all_defined_fields = index._all_defined_fields__
          @_design = invo.design
          @_field_survey_writer = page_data.field_survey_writer
          @__invocation = invo
          @_my_order_array = index._my_order_array__
          @_total_parts = index._total_parts__

          @_number_of_fill_fields = @_my_order_array.length
        end

        def __factory

          # the bulk of this will attempt to be a faithful
          # implementation of the pseudocode :#here.

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

          BlankWriter___.new @_my_order_array, @_all_defined_fields, @_field_survey_writer
        end

        def __total_available_width_for_pool

          current_table_width = __current_table_width

          target_final_width = @_design.target_final_width

          if ! target_final_width
            self._COVER_ME__decide_on_some_default_and_cover_it_for_target_final_width  # #todo
          end

          target_final_width - current_table_width
        end

        def __current_table_width

          _  = Here_::Magnetics_::TableWidth_via_PageSurvey.call(
            @_field_survey_writer,
            @_design,
          )
          _  # #todo
        end

        def __DISTRIBUTE_THE_WIDTH_TO_THE_CELS_USING_THE_SPILLOVER_ALGORITHM

          sparse_widths = []

          st = __discrete_stream
          begin
            pair = st.gets
            pair || break

            w = pair.value_x
            field_offset = pair.name_x

            fs = @_field_survey_writer.dereference field_offset
            fs.width_of_widest_string < w || fail
            fs.maybe_widen_width_of_widest_string w

            sparse_widths[ field_offset ] = w

            redo
          end while nil

          @_sparse_widths = sparse_widths
          self
        end

        def __discrete_stream

          tot = @_total_parts

          # we validated that the use of `parts` is all-or-nothing #here-2.
          # it's "all" if `tot` is true-ish, otherwise "nothing".

          if tot

            use_total = tot

            thing_stream = Stream_.call @_my_order_array do |field_offset|

              _field = @_all_defined_fields.fetch field_offset

              Common_::Pair.via_value_and_name _field.parts, field_offset
            end
          else
            use_total = @_number_of_fill_fields

            thing_stream = Stream_.call @_my_order_array do |field_offset|

              Common_::Pair.via_value_and_name 1, field_offset
            end
          end

          __discrete_stream_via thing_stream, @_width_in_discrete_pool, use_total
        end

        def __discrete_stream_via num_stream, discrete_pool, denominator

          result = []

          easier = num_stream.to_a

          these = []
          names = []
          easier.each do |o|
            these.push o.value_x
            names.push o.name_x
          end

          thing_1 = -> do
            1 == denominator || self._THIS_IS_A_HARDCODED_MOCK
            [1] == these || self._THIS_IS_A_HARDCODED_MOCK
          end

          case discrete_pool
          when 7
            thing_1[]
            result.push [ 7, names.fetch( 0 )]
          when 1
            thing_1[]
            result.push [ 1, names.fetch( 0 )]
          when 22

            11 == denominator || self._THIS_IS_A_HARDCODED_MOCK
            [4, 7] == these || self._THIS_IS_A_HARDCODED_MOCK
            result.push [ 8, names.fetch( 0 )]
            result.push [ 14, names.fetch( 1 )]
          else
            fail "make a thing for thing: #{ discrete_pool }"
          end

          Stream_.call result do |a|
            Common_::Pair.via_value_and_name( * a )
          end
        end

        def __discrete_stream_via_AT_INTEGRATION num_stream, discrete_pool, denominator

          _ = Home_.lib_.basic::
          DiscreteStream_via_NumeratorStream_and_DiscretePool_and_Denominator.call(
            num_stream,
            @discrete_pool,  # an integer
            denominator,
          )
          _  # todo
        end

        def populate_or_overwrite_typified_cels mutable_a

          @_my_order_array.each do |d|

            w = @_sparse_widths.fetch d

            fld = @_all_defined_fields.fetch d

            _cc = CelControllerForClient__.new w, mutable_a, @__invocation

            s = fld.fill_field_proc[ _cc ]

            if fld.is_in_place_of_input_field  # #table-spot-5 repetition
              mutable_a.fetch( d ) || self._SANITY
            else
              mutable_a.fetch( d ) && self._SANITY
            end

            if ! s.respond_to? :ascii_only?
              self._COVER_ME__produced_fill_value_was_not_a_string__  # #todo
            end

            if w != s.length
              self._COVER_ME__length_of_produced_fill_string_was_not_the_right_length_  # #todo
            end

            mutable_a[ d ] = @_field_survey_writer.typified_mixed_via_value_and_index s, d
          end
          NIL
        end
      end

      # ==

      class CelControllerForClient__  # (similar to #table-spot-4)

        def initialize w, arr, invo
          @__arr = arr
          @available_width_for_this_column = w
          @__invo = invo
        end

        def row_typified_mixed_at d
          @__arr.fetch d
        end

        def read_observer sym
          @__invo.read_observer_ sym
        end

        attr_reader(
          :available_width_for_this_column,
        )
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
              typified_mixed_via_value_and_index EMPTY_S_, d
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
