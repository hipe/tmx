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

        _want_this_same_table_from_this_same_design_and_input
      end

      shared_subject :design_ish_ do

        _common_base_design.redefine do |defn|

          defn.add_field_observer :_somename_1, :for_input_at_offset, 1 do |o|
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
            o << o.read_observer( :_somename_1 )
          end

        end
      end
    end

    context "the commonest of field observer implementatations.." do

      it "..are available through the `do_this` modifier. (here's SumTheNumerics)" do

        _want_this_same_table_from_this_same_design_and_input
      end

      shared_subject :design_ish_ do

        _common_base_design.redefine do |defn|

          defn.add_summary_row do |o|
            o << "(total)"
            o << o.read_observer( :_somename_2 )
          end

          defn.add_field_observer(
            :_somename_2,
            :do_this, :SumTheNumerics,
            :for_input_at_offset, 1,
          )
        end
      end
    end

    context "common field observer implementation: CountTheNonEmptyStrings" do

      it "also, multiple observers in one column" do

        _matr = [
          [ 'A' ],
          [ 3 ],
          [ 'B' ],
          [ 6.1 ],
          [ "\t " ],
          [ nil ],
        ]

        against_matrix_want_lines_ _matr do |y|
          y << "| A        |"
          y << "|      3   |"
          y << "| B        |"
          y << "|      6.1 |"
          y << "| \t        |"  # meh, out of scope
          y << "|          |"  # nil
          y << "| (9.1, 2) |"
        end
      end

      def design_ish_
        _this_one_design
      end
    end

    context "the one \"upcasts\" type from integer to float only lazily.." do

      it "..and the other is OK on a zero count of string-ish items" do

        _matr = [
          [ 3 ],
          [ 6 ],
        ]

        against_matrix_want_lines_ _matr do |y|
          y << "|      3 |"
          y << "|      6 |"
          y << "| (9, 0) |"
        end
      end

      def design_ish_
        _this_one_design
      end
    end

    def _want_this_same_table_from_this_same_design_and_input

      _matr = [
        [ 'coffee', 7.23 ],
        [ 'donut', 2.78 ],
      ]

      against_matrix_want_lines_ _matr do |y|
        y << '| coffee    |  7.23 |'
        y << '| donut     |  2.78 |'
        y << '| (total)   | 10.01 |'
      end
    end

    shared_subject :_this_one_design do

      _common_base_design.redefine do |defn|

        defn.add_summary_row do |o|

          _left_x = o.read_observer :_somename_1
          _right_x = o.read_observer :_somename_2
          o << "(#{ _left_x }, #{ _right_x })"
        end

        defn.add_field_observer(
          :_somename_1,
          :for_input_at_offset, 0,
          :do_this, :SumTheNumerics,
        )

        defn.add_field_observer(
          :_somename_2,
          :for_input_at_offset, 0,
          :do_this, :CountTheNonEmptyStrings,
        )
      end
    end

    shared_subject :_common_base_design do

      table_module_::Design.define do |defn|

        # (until recently the below was the production default)

        defn.separator_glyphs '| ', '   | ', ' |'
      end
    end
  end
end
# #tombstone: probably one day bring back this massive integration test from here for integration with [cm]
# #history: arrived in new home during unification
