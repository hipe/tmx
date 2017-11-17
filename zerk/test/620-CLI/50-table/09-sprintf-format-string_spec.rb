require_relative '../../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] CLI table - sprintf format string" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI_table

    context "minimal - if you're sure of your range characterisitcs.." do

      shared_subject :design_ish_ do

        table_module_.default_design.redefine do |o|

          o.add_field  # nothing for the left column

          o.add_field(
            :sprintf_format_string_for_nonzero_floats, 'wee: %5.2f',
          )
        end
      end

      it "(builds)" do
        design_ish_
      end

      it "..you can supply a plain old (\"static\") format string for sprintf" do

        _matr = [
          [ 'xx', 1.23456 ],
          [ 'yyy', -1.23456 ],
        ]

        against_matrix_want_lines_ _matr do |y|
          y << '| xx  | wee:  1.23 |'
          y << '| yyy | wee: -1.23 |'
        end
      end

      it "..and the format will be widened if necessary to fit other content" do

        _matr = [
          [ 'xx', 1.23456 ],
          [ 'yyy', -1.23456 ],
          [ 'zz', '(total: xxxxx)' ],
        ]

        against_matrix_want_lines_ _matr do |y|
          y << '| xx  |     wee:  1.23 |'
          y << '| yyy |     wee: -1.23 |'
          y << '| zz  | (total: xxxxx) |'
        end
      end

      it "..however if your number is too big you break the layout" do

        # :#table-coverpoint-E-1

        _matr = [
          [ 'ok', 1.23456 ],
          [ 'too big', -12345.6 ],
        ]

        against_matrix_want_lines_ _matr do |y|
          y << '| ok      | wee:  1.23 |'
          y << '| too big | wee: -12345.60 |'  # NOTE broken layout - column too wide
        end
      end

      it "in this particular case, BOTH kinds of zeros are treated as floats" do

        _matr = [
          [ 'xx', 1.23456 ],
          [ 'yyy', -1.23456 ],
          [ 'zz', 0 ],
          [ 'zz2', 0.0 ],
        ]

        against_matrix_want_lines_ _matr do |y|
          y << '| xx  | wee:  1.23 |'
          y << '| yyy | wee: -1.23 |'
          y << '| zz  | wee:  0.00 |'
          y << '| zz2 | wee:  0.00 |'
        end
      end
    end

    context "with { floats, integers } * { positive, negative, zeros }" do

      it "(builds)" do
        design_ish_
      end

      it "..we do some wicked hackery to make the whole-number parts line up" do

        # #table-coverpoint-E-2

        _matr = [
          [ 'blunt header 1', 'blunt header 2' ],
          [ 'integer', 3 ],
          [ 'negative integer', -99 ],
          [ 'zero as integer', 0 ],
          [ 'positive float', 3.456789 ],
          [ 'negative float', -3.456789 ],
          [ 'zero as float', 0.0 ],
        ]

        against_matrix_want_lines_ _matr do |y|

          y << '| blunt header 1   | blunt header 2 |'
          y << '| integer          |           3    |'
          y << '| negative integer |         -99    |'
          y << '| zero as integer  |           0    |'
          y << '| positive float   |      hi:  3.46 |'
          y << '| negative float   |      hi: -3.46 |'
          y << '| zero as float    |           0    |'
        end
      end

      shared_subject :design_ish_ do

        table_module_.default_design.redefine do |defn|

          defn.add_field  # nothing

          defn.add_field(
            :sprintf_format_string_for_nonzero_floats, 'hi: %5.2f',
          )
        end
      end
    end
  end
end
# #born: during unification as a more granular, focused test node
