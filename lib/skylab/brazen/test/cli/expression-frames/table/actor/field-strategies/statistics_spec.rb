require_relative '../../../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI - expr-fr - table - actor - stats" do

    extend TS_
    use :CLI_expression_frames_table_actor_support

    it "minimal example of a formula" do

      subject_[

        :left, '( ', :right, ' )', :sep, ' - ',

        :header, :none,

        :field,
          :gather_statistics,

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

    it "basic two-pass aligns right", wip: true do

      subject_[ :read_rows_from,
        [ [ 'abcde', 0.123 ], [ 4.56, 'fghijk' ] ],
         * __typical ]

      _expect '| abcde |  0.123 |'
      _expect '|  4.56 | fghijk |'
      done_
    end

    def __typical

      [ :left, '| ', :right, ' |', :sep, ' | ',
        :write_lines_to, _write_lines_to ]
    end

    it "the decimal line up, intermixed with strings", wip: true do

      subject_[ :read_rows_from,
        [ [ 0.123, 4.56 ], [ 'hi', 78.9 ], [ 45.6, 'helllo' ] ],
         * _visible ]

      _expect '|_ 0.123_|_  4.56_|'
      _expect '|_    hi_|_ 78.90_|'
      _expect '|_45.600_|_helllo_|'
      done_
    end

    it "just strings and just integers, with nil-holes", wip: true do

      subject_[ :read_rows_from,
        [['foo', -4567], [nil, 89], ['bo', nil]], * _visible ]

      _expect '|_foo_|_-4567_|'
      _expect '|_   _|_   89_|'
      _expect '|_bo _|_     _|'
      done_
    end

    def _visible
      [ :left, '|_', :right, '_|', :sep, '_|_',
        :write_lines_to, _write_lines_to ]
    end

    def _expect s
      gets_.should eql s
    end
  end
end
