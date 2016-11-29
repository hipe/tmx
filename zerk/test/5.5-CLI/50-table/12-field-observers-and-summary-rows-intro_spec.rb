require_relative '../../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] CLI table - field observers and summary rows intro" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI_table

    context "build field observers and summary row into the design" do

      it "builds" do
        design_ish_
      end

      it "here is the longhand form of making a \"total\" cel (summary row)" do

        # there is no shorthand yet, not sure if there ever will be #track [#057]

        _matr = [
          [ 'coffee', 7.23 ],
          [ 'donut', 2.78 ],
        ]

        against_matrix_expect_lines_ _matr do |y|
          y << '| coffee    |  7.23 |'
          y << '| donut     |  2.78 |'
          y << '| (total)   | 10.01 |'
        end
      end

      shared_subject :design_ish_ do

        table_module_.default_design.redefine do |defn|

          defn.separator_glyphs '| ', '   | ', ' |'

          defn.add_field_observer :zizzio, :for_input_at_offset, 1 do |o|
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

          defn.add_summary_row do |o|
            o << "(total)"
            o << o.read_observer( :zizzio )
          end

        end  # design
      end  # shared subject
    end  # context
  end
end
# #tombstone: probably one day bring back this massive integration test from here for integration with [cm]
# #history: arrived in new home during unification
