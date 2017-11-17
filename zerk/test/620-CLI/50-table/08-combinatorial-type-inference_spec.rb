require_relative '../../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] CLI table - combinatorial type inference" do

    TS_[ self ]
    use :memoizer_methods
    use :CLI_table

    context "(elements)" do

      it "type inference happens - by default, strings align L, ints R" do

        _matr = [
          [ 'a',  1 ],
          [ 'bbb', 2222 ],
          [ 'cc',  33],
        ]

        against_matrix_want_lines_ _matr do |y|
          y << "( a  ;    1 )"
          y << "( bbb; 2222 )"
          y << "( cc ;   33 )"
        end
      end

      it "if any integer is negative, it will \"push\" the column wider by one" do

        _matr = [
          [ 'a',  1 ],
          [ 'bbb', -2222 ],
        ]

        against_matrix_want_lines_ _matr do |y|
          y << "( a  ;     1 )"
          y << "( bbb; -2222 )"
        end
      end

      it "floats are detected, line up on the decimal, get trailing zeros" do

        _matr = [
          [ 'a',  1.11 ],
          [ 'bbb', 222.2 ],
          [ 'cc',  33.0 ],
        ]

        against_matrix_want_lines_ _matr do |y|
          y << "( a  ;   1.11 )"
          y << "( bbb; 222.2  )"
          y << "( cc ;  33.0  )"
        end
      end

      it "a negative such float can \"push\" the column wider by one" do

        _matr = [
          [ 'a',  1.11 ],
          [ 'bbb', -222.2 ],
        ]

        against_matrix_want_lines_ _matr do |y|
          y << "( a  ;    1.11 )"
          y << "( bbb; -222.2  )"
        end
      end

      it "if mix of integers and floats, lined up on IMAGINARY decimal point" do

        _matr = [
          [ 1.230 ],
          [ 4 ],
          [ 56.789 ],
        ]

        against_matrix_want_lines_ _matr do |y|
          y << "(  1.23  )"
          y << "(  4     )"
          y << "( 56.789 )"
        end
      end

      it "how are booleans lined up? to the R (unlike strings)"  do

        _matr = [
          [ true ],
          [ false ],
        ]

        against_matrix_want_lines_ _matr do |y|
          y << "(  true )"
          y << "( false )"
        end
      end
    end

    context "(combinatorials)" do

      it "a mix of nil, false, true, strings and integers" do

        _matr = [
            [ 'wolulu' ],
            [ nil ],
            [ 123 ],
            [ 'pishnu vanathay' ],
            [ 45 ],
            [ false ],
            [ true ],
        ]

        against_matrix_want_lines_ _matr do |y|
          y <<  '( wolulu          )'
          y <<  '(                 )'
          y <<  '(             123 )'
          y <<  '( pishnu vanathay )'
          y <<  '(              45 )'
          y <<  '(           false )'
          y <<  '(            true )'
        end
      end

      it "the decimal line up, intermixed with strings" do

        _matr = [
            [ 0.123, 4.56 ],
            [ 'hi', 78.9 ],
            [ 45.6, 'hey' ],
        ]

        against_matrix_want_lines_ _matr do |y|
          y <<  '(  0.123;  4.56 )'
          y <<  '( hi    ; 78.9  )'
          y <<  '( 45.6  ; hey   )'
        end
      end

      it "just strings and just integers, with nil-holes" do

        _matr = [
            [ 'foo', -4567 ],
            [ nil, 89 ],
            [ 'bo', nil ],
        ]

        against_matrix_want_lines_ _matr do |y|
          y <<  '( foo; -4567 )'
          y <<  '(    ;    89 )'
          y <<  '( bo ;       )'
        end
      end
    end

    context "(mixed integration tests LEGACY)" do

      it "[..] something magical happens" do

        _matr = [
          [ -1.1122, 'blah' ],
          [ 1, 2 ],
          [ 34.5, 56 ],
          [ 1.348, -3.14 ],
          [ 1234.567891, 0 ],
        ]

        against_matrix_want_lines_ _matr do |y|
          y << '  -1.1122 blah '
          y << '   1       2   '
          y << '  34.5    56   '
          y << '   1.348  -3.14'
          y << '1234.5679  0   '  # NOTE it got chomped - 5 is max
        end
      end

      it "when you have a mixed \"type\" column - used to use the mode, no longer" do

        _matr = [
          [ 123,  123,       1233,   3.1415 ],
          [ 'j',  'meeper',  'eff',  3.14 ],
          [ 12,   1.2,       'ef',   23.1415 ],
          [ 1,    1,         'e',    0 ],
        ]

        against_matrix_want_lines_ _matr do |y|
          y << '123  123   1233  3.1415'
          y << 'j   meeper eff   3.14  '
          y << ' 12    1.2 ef   23.1415'
          y << '  1    1   e     0.0   '
        end
      end

      shared_subject :design_ish_ do

        table_module_.default_design.redefine do |defn|

          defn.separator_glyphs EMPTY_S_, SPACE_, EMPTY_S_
        end
      end
    end

    shared_subject :design_ish_ do

      table_module_.default_design.redefine do |defn|

        defn.separator_glyphs '( ', '; ', ' )'
      end
    end
  end
end
# #tombstone: test for styled header
# #tombstone: pulled in a test that used to use the mode, does no longer
# #history: rewrote during unification.
