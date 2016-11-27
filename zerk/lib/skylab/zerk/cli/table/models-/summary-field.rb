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
      #   - a plain field with no metadata is represented as `nil`

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
      # (in the code we may refer to this grouping of one insertion
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
      # which we use to convert
      #
      #      # 0   1   2   3   4   5
      #       [ x0, x1, x2, x3, x4, x5 ]
      # to
      #
      #     [ x0, x1, x2, nil, x3, x4, nil, nil, x5 ]
      #
      # which finally becomes
      #
      #     [ x0, x1, x2, SF1, x3, x4, SF2, SF3, x5 ]

      class Index

        class << self
          alias_method :begin, :new
          undef_method :new
        end  # >>

        def initialize

          @_empty_arrays = []
          @_insertion_points = []
          @_last_insertion_point = -1
          @_last_summary_field_index = nil
          @_ord_array = []
          @_summary_field_count = 0
        end

        def receive_NEXT_summary_field fld, d

          __maybe_begin_pack d

          @_empty_arrays.last.push NOTHING_

          @_summary_field_count += 1
          ord_d = fld.summary_field_ordinal
          @_ord_array[ ord_d ] and fail self._COVER_ME__say_collision( ord_d )  # #todo
          @_ord_array[ ord_d ] = d

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

        def finish

          if @_summary_field_count != @_ord_array.length
            fail self._COVER_ME__say_missing_ordinals  # #todo
          end

          @_last_index = @_insertion_points.length - 1

          if @_last_index.nonzero?
            self._WALK_THROUGH_ALL_OF_THIS_VERY_CAREFULLY_README
            # we "feel" like 95% certain that it's all going to work as
            # intended, but it it doesn't it will be annoying to trace it
            # back to here so #cover-me
          end

          @indexes_of_summary_fields_in_visitation_order =
            remove_instance_variable( :@_ord_array )

          remove_instance_variable :@_last_insertion_point
          remove_instance_variable :@_last_summary_field_index
          remove_instance_variable :@_summary_field_count

          self
        end

        def visit_subtractively__ participant
          _visit :at_index_subtract_N_items, participant
          NIL
        end

        def visit_additively__ participant
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

        attr_reader(
          :indexes_of_summary_fields_in_visitation_order,
        )
      end

      class CollectionController

        def initialize index, invo
          @_index = index
          @__invocation = invo
        end

        def mutate_page_data page_data

          __expand_and_populate_the_field_surveys page_data
          __expand_and_populate_every_typified_tuple page_data
          NIL
        end

        def __expand_and_populate_the_field_surveys page_data

          @_index.visit_additively__ page_data.field_survey_writer
          NIL
        end

        def __expand_and_populate_every_typified_tuple page_data

          idx = @_index
          invo = @__invocation

          d_a = idx.indexes_of_summary_fields_in_visitation_order
          fields = invo.design.all_defined_fields
          fsw = page_data.field_survey_writer

          page_data.typified_tuples.each do |tuple|

            tuple.mutate_array_by do |mutable_a|

              idx.expand_array mutable_a

              row_cont = RowController___.new mutable_a, invo

              d_a.each do |d|
                _x = fields.fetch( d ).summary_field_proc[ row_cont ]
                mutable_a.fetch( d ) && self._SANITY  # #todo
                mutable_a[ d ] = fsw.typified_mixed_via_value_and_index _x, d
              end

              NIL
            end
          end
        end
      end

      # ==

      class RowController___

        def initialize arr, invo
          @__arr = arr
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
    end
  end
end
# #born during unification to replace legacy architecture for formulas
