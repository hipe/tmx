module Skylab::Zerk

  module CLI::Table

    module Models_::SummaryField

      # given the axioms,
      #
      #   - plain fields and summary fields are stored together inline
      #     in one array, with their positions isomorphic to their
      #     positions in the final, rendered output table.
      #
      #   - plain fields and summary fields can occur in any arrangement,
      #     provided that there is at least one plain field.
      #
      #   - a plain field with no metadata is always represented as `nil`,
      #     and `nil` in this context always represents such a field.
      #

      # imagine an as-stored sparse list of defined fields with some
      # summary fields.
      #
      #     [ f0, nil, f2, sf1, f3, nil, sf3, sf4, f5 ]
      #
      # given the axioms, we can induce that the (imaginary) subset
      # list of plain fields looks like
      #
      #     [ f0, nil, f2, f3, nil, f5 ]
      #
      # which is simply the as-stored list with the summary fields removed.
      #
      # these six plain fields correspond to six assumed elements of
      # each incoming mixed tuple.
      #
      #     [ x0, x1, x2, x3, x4, x5 ]
      #
      # any N-tuple has the N+1 possible "insertion points".
      #
      #      0   1   2   3   4   5  6
      #
      # (that is; you can insert before the first element, after the
      # last element, or between any adjacent elements.) (yes, it is
      # then not accurate to call this structure a "tuple".)
      #
      # now, given the original array, group contiguous spans of summary
      # fields by their insertion point
      #
      #      0   1    2   3        4    5            6
      #     [ f0, nil, f2, sf1, f3, nil, sf3, sf4, f5 ]
      #
      # at insertion point 3 there is ONE summary field to insert
      # at insertion point 5 there are TWO summary fields to insert
      #
      # (in the code we refer to this grouping of one insertion
      # point with its 1-N summary fields as a "pack".)
      #
      # from all this, we derive our "expander data" as one list of
      # "insertion points"
      #
      #     [ 5, 3 ]  # insertion points (we insert from end to beginning)
      #
      # and one PARALLEL list of "empty arrays"
      #
      #     [ [nil, nil], [nil] ]  # empty arrays
      #
      # which we use to "expand" the mutable array
      #
      #      # 0   1   2   3   4   5
      #       [ x0, x1, x2, x3, x4, x5 ]
      # to
      #
      #     [ x0, x1, x2, nil, x3, x4, nil, nil, x5 ]
      #
      # which finally gets populated with the summary values to become
      #
      #     [ x0, x1, x2, SF1, x3, x4, SF2, SF3, x5 ]

      class << self
        def begin_index
          BuildMasterIndex___.new
        end
      end  # >>

      # ==

      class BuildMasterIndex___

        def initialize

          @_empty_arrays = []
          @_offsets_of_fill_fields = nil
          @_offsets_of_overwriters = nil
          @_insertion_points = []
          @_last_insertion_point = -1
          @_last_summary_field_index = nil
          @_number_of_summary_fields = 0
          @_order_array = []
        end

        def receive_NEXT_summary_field fld, d

          if fld.is_summary_field_fill_field
            ( @_offsets_of_fill_fields ||= [] ).push d
          end

          if fld.is_in_place_of_input_field
            ( @_offsets_of_overwriters ||= [] ).push d
          else

            __maybe_begin_pack d

            @_empty_arrays.last.push NOTHING_
          end

          @_number_of_summary_fields += 1
          ord_d = fld.summary_field_ordinal
          @_order_array[ ord_d ] and fail self._COVER_ME__say_collision( ord_d )  # #todo
          @_order_array[ ord_d ] = d

          NIL
        end

        def __maybe_begin_pack d

          _is_subsequent_in_pack = ( d - 1 ) == @_last_summary_field_index
          @_last_summary_field_index = d

          if ! _is_subsequent_in_pack
            __begin_pack d
          end
        end

        def __begin_pack d

          this_insertion_point = d - @_last_insertion_point - 1

          @_last_insertion_point = this_insertion_point

          @_insertion_points.push this_insertion_point

          @_empty_arrays.push []

          NIL
        end

        # -- finish

        def finish defined_fields

          # -- validate

          if @_number_of_summary_fields != @_order_array.length
            fail self._COVER_ME__say_missing_ordinals  # #todo
          end
          remove_instance_variable :@_number_of_summary_fields

          # -- any array expander

          _array_expander = __flush_any_array_expander

          over_a = remove_instance_variable :@_offsets_of_overwriters

          fill_a = remove_instance_variable :@_offsets_of_fill_fields
          ord_a = remove_instance_variable :@_order_array

          if fill_a

            fill_a.freeze

            fill_index = Here_::Models_::FillField.build_index(
              fill_a, ord_a, defined_fields )

            plain_ord_a = fill_index.plain_order_of_operations_offset_array
              # nil if all were fill fields
          else
            plain_ord_a = ord_a.freeze
          end

          if plain_ord_a
            plain_summary_index = PlainSummaryFieldIndex___.new plain_ord_a, defined_fields
          end

          MasterIndex___.new _array_expander, over_a, plain_summary_index, fill_index
        end

        def __flush_any_array_expander
          ArrayExpander___.via(
            remove_instance_variable( :@_empty_arrays ),
            remove_instance_variable( :@_insertion_points ),
          )
        end
      end

      # ==

      class MasterIndex___

        def initialize array_expander, overwriters, plain_index, fill_index

          @_array_expander__ = array_expander
          @_offsets_of_overwriters__ = overwriters
          @_plain_index__ = plain_index
          @_fill_index__ = fill_index

          @_OCD_method__ = if array_expander
            if plain_index
              if fill_index
                :OCD_yes_yes_yes
              else
                :OCD_yes_yes_no
              end
            else
              :OCD_yes_no_yes
            end
          elsif plain_index
            if fill_index
              :OCD_no_yes_yes
            else
              :OCD_no_yes_no
            end
          else
            :OCD_no_no_yes
          end
        end

        def mutate_page_data page_data, invo
          MutatePageData___.new( page_data, invo, self ).execute
        end

        attr_reader(
          :_array_expander__,
          :_offsets_of_overwriters__,
          :_plain_index__,
          :_fill_index__,
          :_OCD_method__,
        )
      end

      # ==

      class MutatePageData___

        def initialize page_data, invo, idx

          @_page_data = page_data
          @_invocation = invo
          @__OCD_method_name = idx._OCD_method__

          @_array_expander = idx._array_expander__
          @__offsets_of_overwriters = idx._offsets_of_overwriters__
          @_plain_index = idx._plain_index__
          @_fill_index = idx._fill_index__
        end

        def execute

          if @_array_expander
            @_array_expander.__visit_additively_ @_page_data.field_survey_writer
          end

          d_a = @__offsets_of_overwriters
          if d_a
            @_page_data.field_survey_writer.clear_these d_a
          end
          d_a = nil

          if @_plain_index

            @_plain_page_editor = @_plain_index.
              to_tuple_mutator_for_XX @_page_data, @_invocation

          end

          if @_fill_index

            @_fill_page_editor = @_fill_index.
              to_tuple_mutator_for_XX @_page_data, @_invocation
          end

          ocd_method_name = @__OCD_method_name

          @_page_data.typified_tuples.each do |tuple|

            tuple.mutate_array_by do |mutable_a|

              send ocd_method_name, mutable_a
            end
          end
          NIL
        end

        def OCD_yes_yes_yes a
          @_array_expander.expand_array a
          @_plain_page_editor.populate_or_overwrite_typified_cels a
          @_fill_page_editor.populate_or_overwrite_typified_cels a
          NIL
        end

        def OCD_yes_yes_no a
          @_array_expander.expand_array a
          @_plain_page_editor.populate_or_overwrite_typified_cels a
          NIL
        end

        def OCD_yes_no_yes a
          @_array_expander.expand_array a
          @_fill_page_editor.populate_or_overwrite_typified_cels a
          NIL
        end

        def OCD_no_yes_yes a
          @_plain_page_editor.populate_or_overwrite_typified_cels a
          @_fill_page_editor.populate_or_overwrite_typified_cels a
          NIL
        end

        def OCD_no_yes_no a
          @_plain_page_editor.populate_or_overwrite_typified_cels a
          NIL
        end

        def OCD_no_no_yes a
          @_fill_page_editor.populate_or_overwrite_typified_cels a
          NIL
        end
      end

      # ==

      class PlainSummaryFieldIndex___

        def initialize ord_a, field_a
          @defined_fields = field_a
          @operation_order_array = ord_a
        end

        def to_tuple_mutator_for_XX page_data, invo
          PlainSummaryTupleMutator___.new page_data, invo, self
        end

        attr_reader(
          :defined_fields,
          :operation_order_array,
        )
      end

      # ==

      class PlainSummaryTupleMutator___

        def initialize page_data, invo, index

          @__all_defined_fields = index.defined_fields
          @__field_survey_writer = page_data.field_survey_writer
          @__operation_order_array = index.operation_order_array
          @__page_data = page_data
          @__invocation = invo
        end

        def populate_or_overwrite_typified_cels mutable_a

          fields = @__all_defined_fields

          fsw = @__field_survey_writer

          row_cont = RowControllerForClient__.new mutable_a, @__invocation

          @__operation_order_array.each do |d|

            fld = fields.fetch d

            _x = fld.summary_field_proc[ row_cont ]

            if fld.is_in_place_of_input_field  # #table-spot-5 repetition
              mutable_a.fetch( d ) || self._SANITY
            else
              mutable_a.fetch( d ) && self._SANITY
            end

            mutable_a[ d ] = fsw.typified_mixed_via_value_and_index _x, d
          end

          NIL
        end
      end

      # ==

      class RowControllerForClient__  # (similar to #table-spot-4)

        # FOR CLIENT

        def initialize mutable_a, invo
          @__arr = mutable_a
          @__invo = invo
        end

        def row_typified_mixed_at d
          @__arr.fetch d
        end

        def read_observer sym
          @__invo.read_observer_ sym
        end
      end

      # ==

      class ArrayExpander___

        class << self

          def via empty_a, insertion_point_a  # freezes the arguments

            _yes = case insertion_point_a.length <=> 1

            when 0  # one insertion point
              true


            when 1  # multiple insertion points

              self._WALK_THROUGH_ALL_OF_THIS_VERY_CAREFULLY_README
              # we "feel" like 95% certain that it's all going to work as
              # intended, but it it doesn't it will be annoying to trace it
              # back to here so #cover-me
              true

            when -1
              false

            else
              self._SANITY
            end

            if _yes
              new empty_a.freeze, insertion_point_a.freeze
            end
          end

          private :new
        end  # >>

        def initialize empt_a, insp_a

          @_last_index = insp_a.length - 1

          @_empty_arrays = empt_a
          @_insertion_points = insp_a
        end

        def __visit_additively_ participant
          _visit :at_index_add_N_items, participant
          NIL
        end

        def _visit m, participant
          @_last_index.downto 0 do |d|
            participant.send( m,
              @_insertion_points.fetch( d ),
              @_empty_arrays.fetch( d ).length,
            )
          end
          NIL
        end

        def expand_array mutable_a
          d = @_last_index
          begin
            mutable_a[ @_insertion_points.fetch( d ), 0 ] = @_empty_arrays.fetch d
            d.zero? && break
            d -= 1
            redo
          end while above
          NIL
        end
      end

      # ==
    end
  end
end
# #born during unification to replace legacy architecture for formulas
