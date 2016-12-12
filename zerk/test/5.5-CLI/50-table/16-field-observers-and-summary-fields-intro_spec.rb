require_relative '../../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] CLI table - field observers and summary fields intro" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI_table

    begin_totalling = -> o do
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

    calculate_max_share = -> o, numerator_index, observer_sym do

      # numerator_index is the index of the column *after* stretching.
      # justified at [#050.B]

      total = o.read_observer observer_sym

      tm = o.row_typified_mixed_at_field_offset numerator_index

      if tm.is_numeric
        tm.value.to_f / total
      end
    end

    context "with a field observer and a summary field.." do

      it "(builds)" do
        design_ish_
      end

      it "..you can do calculations over the whole page" do

        _matr = [
          [ 'coffee', 7.23 ],
          [ 'donut', 2.78 ],
        ]

        against_matrix_expect_lines_ _matr do |y|
          y << '| coffee | 0.7223 | 7.23 |'
          y << '| donut  | 0.2777 | 2.78 |'
        end
      end

      shared_subject :design_ish_ do

        table_module_.default_design.redefine do |defn|

          defn.add_field_observer :zazzio, :for_input_at_offset, 1 do |o|
            begin_totalling[ o ]
          end

          defn.add_field  # nothing

          defn.add_field :summary_field, :order_of_operation, 0 do |o|

            calculate_max_share[ o, 2, :zazzio ]
          end

          defn.add_field  # nothing (not necessary)
        end
      end
    end

    context "you can do the above but use `in_place_of_input_field`" do

      it "(builds)" do
        design_ish_
      end

      it "(note the precision appears low only because the input divide roundly)" do

        _matr = [
          [ 4 ],
          [ 1 ],
        ]

        against_matrix_expect_lines_ _matr do |y|
          y << '| 0.8 |'
          y << '| 0.2 |'
        end
      end

      shared_subject :design_ish_ do

        table_module_.default_design.redefine do |defn|

          defn.add_field_observer :_total_of_col_0_, :for_input_at_offset, 0 do |o|
            begin_totalling[ o ]
          end

          defn.add_field(
            :summary_field,
            :order_of_operation, 0,
            :in_place_of_input_field,
          ) do |o|
            calculate_max_share[ o, 0, :_total_of_col_0_ ]
          end
        end
      end
    end

    context "the above plus a custom format" do

      it "(builds)" do
        design_ish_
      end

      it "works" do

        _matr = [
          [ 4 ],
          [ 1 ],
        ]

        against_matrix_expect_lines_ _matr do |y|
          y << '| % 80.00 |'
          y << '| % 20.00 |'
        end
      end

      shared_subject :design_ish_ do

        table_module_.default_design.redefine do |defn|

          defn.add_field_observer :_tot_, :for_input_at_offset, 0 do |o|
            begin_totalling[ o ]
          end

          defn.add_field(
            :summary_field,
            :order_of_operation, 0,
            :in_place_of_input_field,
            :sprintf_format_string_for_nonzero_floats, '%%%6.2f',
          ) do |o|

            f = calculate_max_share[ o, 0, :_tot_ ]
            if f
              f * 100  # because percent
            end
          end
        end
      end
    end
  end
end
# #history: tests related to type inference corralled into sibling file
