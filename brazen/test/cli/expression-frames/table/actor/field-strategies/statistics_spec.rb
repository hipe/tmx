require_relative '../../../../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI - expr-fr - table - actor - stats" do

    extend TS_
    use :CLI_expression_frames_table_actor_support

    _SUBJECT_SYMBOL = :gather_statistics

    it "minimal example of a formula" do

      subject_[

        :left, '( ', :right, ' )', :sep, ' - ',

        :header, :none,

        :field,
          _SUBJECT_SYMBOL,

        :field,
          :formula,
          -> row, cols do

            1.0 * row[ 0 ] / cols.column_at( 0 )[ :stats ].numeric_max
          end,

        :read_rows_from,
          [ [ 1, nil ],
            [ 2, nil ] ],

        :write_lines_to, write_lines_to_,
      ]

      _expect "( 1 - 0.5 )"
      _expect "( 2 - 1.0 )"
      done_
    end

    it "without subject a column of integers is align left" do

      subject_[ :field, :read_rows_from, [ [ 123 ], [ 45 ] ], * _common ]

      _expect '| 123 |'
      _expect '| 45  |'
      done_
    end

    it "with subject (same) is aligned right" do

      subject_[
        :field,
        _SUBJECT_SYMBOL,
        :read_rows_from, [ [ 123 ], [ 45 ] ], * _common ]

      _expect '| 123 |'
      _expect '|  45 |'
      done_
    end

    it "without subject a column of floats is align left" do

      subject_[ :field, :read_rows_from, [ [ 1.234 ], [ 567.89 ] ], * _common ]
      _expect '| 1.234  |'
      _expect '| 567.89 |'
      done_
    end

    it "with subject for (same) column lines up by decimal, trailing zeros" do

      subject_[ :field,
                _SUBJECT_SYMBOL,
                :read_rows_from, [ [ 1.234 ], [ 56.78 ] ], * _common ]

      _expect '|  1.234 |'
      _expect '| 56.780 |'
      done_
    end

    it "without subject when you have a mix of integer and float" do

      subject_[
        :field,
        :read_rows_from, _rows_mix, * _common ]

      _expect '| 1.23   |'
      _expect '| 4      |'
      _expect '| 56.789 |'
      done_
    end

    it "with subject (same) lines up IMAGINARY decimal place" do

      subject_[
        :field,
        _SUBJECT_SYMBOL,
        :read_rows_from, _rows_mix, * _common ]

      _expect '|  1.230 |'
      _expect '|  4     |'
      _expect '| 56.789 |'
      done_
    end

    def _rows_mix
      [
        [ 1.23 ],
        [ 4 ],
        [ 56.789 ],
      ]
    end

    it "a mix of nil, false, true, strings and integers" do

      subject_[
        :field,
        _SUBJECT_SYMBOL,
        :read_rows_from,
        [
          [ 'wolulu' ],
          [ nil ],
          [ 123 ],
          [ 'pishnu vanathay' ],
          [ 45 ],
          [ false ],
          [ true ],
        ],
        * _common ]

      _expect '| wolulu          |'
      _expect '|                 |'
      _expect '| 123             |'
      _expect '| pishnu vanathay |'
      _expect '|  45             |'
      _expect '| false           |'
      _expect '| true            |'
      done_
    end

    it "the decimal line up, intermixed with strings" do

      subject_[

        :field, _SUBJECT_SYMBOL, :field, _SUBJECT_SYMBOL,

        :read_rows_from,
        [
          [ 0.123, 4.56 ],
          [ 'hi', 78.9 ],
          [ 45.6, 'helllo' ],
        ],

        * _older ]

      _expect '|_ 0.123_|_ 4.56 _|'
      _expect '|_hi    _|_78.90 _|'
      _expect '|_45.600_|_helllo_|'
      done_
    end

    it "what's up with negatives" do

      subject_[
        :field,
        _SUBJECT_SYMBOL,
        :read_rows_from, [ [ -4567 ], [ 89 ] ], * _common ]

      _expect '| -4567 |'
      _expect '|    89 |'
      done_
    end

    it "just strings and just integers, with nil-holes" do

      subject_[
        :field, _SUBJECT_SYMBOL, :field, _SUBJECT_SYMBOL,
        :read_rows_from,
        [
          [ 'foo', -4567 ],
          [ nil, 89 ],
          [ 'bo', nil ],
        ], * _older,
      ]

      _expect '|_foo_|_-4567_|'
      _expect '|_   _|_   89_|'
      _expect '|_bo _|_     _|'
      done_
    end

    def _older
      [
        :header, :none,
        :left, '|_', :right, '_|', :sep, '_|_',
        :write_lines_to, write_lines_to_,
      ]
    end

    def _common
      [
        :header, :none,
        :left, '| ',
        :right, ' |',
        :sep, ' | ',
        :write_lines_to, write_lines_to_,
      ]
    end

    def _expect s
      gets_.should eql s
    end
  end
end
