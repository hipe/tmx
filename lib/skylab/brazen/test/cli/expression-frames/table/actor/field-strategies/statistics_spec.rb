require_relative '../../../../test-support'

module Skylab::Brazen::TestSupport

  describe "[fa] CLI table progression", wip: true do

    it "loads" do
      _subject
    end

    it "basic two-pass aligns right" do

      _subject[ :read_rows_from,
        [ [ 'abcde', 0.123 ], [ 4.56, 'fghijk' ] ],
         * __typical ]

      _expect '| abcde |  0.123 |'
      _expect '|  4.56 | fghijk |'
      _done
    end

    def __typical

      [ :left, '| ', :right, ' |', :sep, ' | ',
        :write_lines_to, _write_lines_to ]
    end

    it "the decimal line up, intermixed with strings" do

      _subject[ :read_rows_from,
        [ [ 0.123, 4.56 ], [ 'hi', 78.9 ], [ 45.6, 'helllo' ] ],
         * _visible ]

      _expect '|_ 0.123_|_  4.56_|'
      _expect '|_    hi_|_ 78.90_|'
      _expect '|_45.600_|_helllo_|'
      _done
    end

    it "just strings and just integers, with nil-holes" do

      _subject[ :read_rows_from,
        [['foo', -4567], [nil, 89], ['bo', nil]], * _visible ]

      _expect '|_foo_|_-4567_|'
      _expect '|_   _|_   89_|'
      _expect '|_bo _|_     _|'
      _done
    end

    def _visible
      [ :left, '|_', :right, '_|', :sep, '_|_',
        :write_lines_to, _write_lines_to ]
    end

    def _write_lines_to

      @_y ||= []
    end

    def _subject

      @_counter = -1
      Brazen_::CLI::Expression_Frames::Table::Actor
    end

    def _expect s

      @_y.fetch( @_counter += 1 ).should eql s
    end

    def _done
      @_y.length.should eql ( @_counter + 1 )
    end
  end
end
