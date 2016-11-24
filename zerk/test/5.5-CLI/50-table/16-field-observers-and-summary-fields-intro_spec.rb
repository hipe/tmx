require_relative '../../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] CLI table - field observers and summary fields intro" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI_table

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
          y << '|  coffee |  0.7223 |  7.23  |'
          y << '|  donut  |  0.2777 |  2.78  |'
        end
      end
    end

    shared_subject :design_ish_ do

      table_module_.default_design.redefine do |defn|

        defn.add_field_observer :zazzio, :observe_field, 1 do |o|
          total = 0.0
          o.on_typified_mixed do |tm|
            if tm.is_numeric
              total += tm.value
            end
          end
          o.retrieve_by do
            total
          end
        end

        defn.add_field  # nothing

        defn.add_field :summary_field, 0 do |o|

          total = o.read_observer :zazzio

          tm = o.row_typified_mixed_at 2  # use the index after stretching
          if tm.is_numeric
            tm.value.to_f / total
          end
        end

        defn.add_field  # nothing

      end  # redefine (table)
    end  # shared subject
  end  # describe
end  # module
# #history: tests related to type inference corralled into sibling file
