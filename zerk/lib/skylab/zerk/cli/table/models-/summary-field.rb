module Skylab::Zerk

  module CLI::Table

    module Models_::SummaryField

      # summary fields are crazy: first, they are stored in a sparse
      # array in "packs". here are four fields in three packs:
      #
      #       [f1], [ f2, f3 ], nil, [f4]
      #
      # each *typified* tuple:
      #
      #            [A][B][C]
      #
      # is expanded to to fit the N packs and each of their M elements:
      #
      #         [ ][A][ ][ ][B][C][ ]
      #
      # each pack (slot) represents an insertion into the array. the offset
      # of the pack is the offset of the insertion point. the number of
      # items in the pack is how many blank spaces are inserted there.
      #
      # now we have the fully expanded, sparse "typified tuple".
      #
      # then the procs of the summary fields are called in the order of
      # their ordinal integer (arbitrary order, user-provided) to populate
      # the expanded typified tuple as necessary.
      #
      #        [f1][A][f2][f3][B][C][f4]
      #
      # in one *row* each proc gets *the same* "row-controller instance".
      # (but a new row controller is created for each row). through this
      # controller the invocation can be reached, as well as those cels
      # of the row that have been caculated already.

      class CollectionController

        def initialize sf_def, invo
          @crazy_array = sf_def
          @invocation = invo
        end

        def mutate_page_data page_data
          Money___.new( page_data, @crazy_array, @invocation ).execute
          NIL
        end
      end

      # ==

      class Money___

        def initialize sct, cr_a, invo
          @build_field_survey = sct.field_survey_by
          @crazy_array = cr_a
          @field_surveys = sct.field_surveys
          @invocation = invo
          @typified_mixed_via_value_and_index = sct.typified_mixed_via_value_and_index_by
          @typified_tuples = sct.typified_tuples
        end

        def execute

          empty_arrays = []              # [[nil], [nil,nil], [nil]]
          insertion_offsets = []         # [0, 1, 3]

          flat_guys = []                 # [f1][ ][f2][f3][ ][ ][f4]
          indexes_into_flat_guys = []    # [0,2,3,6]

          @crazy_array.each_with_index do |fi_a, d|
            if fi_a
              empty_a = []
              fi_a.each do |fi|
                empty_a.push nil
                indexes_into_flat_guys.push flat_guys.length
                flat_guys.push fi
              end
              empty_arrays.push empty_a
              insertion_offsets.push d
            end
            flat_guys.push nil
          end

          @_flat_guys = flat_guys
          @_indexes_into_flat_guys = indexes_into_flat_guys
          __init_visitation_order

          # --

          start_at_end = insertion_offsets.length - 1

          stretch_this_array = -> arr do
            d = start_at_end
            begin
              arr[ insertion_offsets.fetch( d ), 0 ] = empty_arrays.fetch d
              if d.zero?
                break
              end
              d -= 1
              redo
            end while above
          end

          # --

          stretch_this_array[ @field_surveys ]

          indexes_into_flat_guys.each do |d|
            x = @field_surveys.fetch d
            x && fail
            @field_surveys[ d ] = @build_field_survey[]
          end

          # --

          @typified_tuples.each do |tuple|

            tuple.replace_array_by do |arr|
              arr = arr.dup
              stretch_this_array[ arr ]
              __mutate_tuple_array arr
              arr
            end
          end

          NIL
        end

        def __init_visitation_order

          a = []
          count = 0

          @_indexes_into_flat_guys.each do |d_|
            count += 1

            hi = @_flat_guys.fetch d_

            ord = hi.summary_field_ordinal

            d = a[ord]
            if d
              fail __say_collision ord
            end
            a[ ord ] = d_
          end

          if count != a.length
            fail __say_sparse a
          end

          @__visitation_order = a

          NIL
        end

        def __mutate_tuple_array arr

          row_controller = RowController___.new arr, @invocation

          @__visitation_order.each do |guy_d|

            _field = @_flat_guys.fetch guy_d

            arr[ guy_d ] && self._SANITY

            _x = _field.summary_field_proc[ row_controller ]

            __accept_value arr, _x, guy_d
          end
          NIL
        end

        def __accept_value arr, x, guy_d

          _tm = @typified_mixed_via_value_and_index[ x, guy_d ]

          arr[ guy_d ] = _tm

          NIL
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
