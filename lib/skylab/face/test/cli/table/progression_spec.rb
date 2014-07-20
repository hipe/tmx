require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Table

  describe "[fa] CLI table progression" do

    it "loads" do
      subject
    end

    it "basic two-pass aligns right" do
      subject[ :read_rows_from,
        [ [ 'abcde', 0.123 ], [ 4.56, 'fghijk' ] ],
         * typical ]

      expect '| abcde |  0.123 |'
      expect '|  4.56 | fghijk |'
      done
    end

    it "the decimal line up, intermixed with strings" do
      subject[ :read_rows_from,
        [ [ 0.123, 4.56 ], [ 'hi', 78.9 ], [ 45.6, 'helllo' ] ],
         * visible ]

      expect '|_ 0.123_|_  4.56_|'
      expect '|_    hi_|_ 78.90_|'
      expect '|_45.600_|_helllo_|'
      done
    end

    it "just strings and just integers, with nil-holes" do
      subject[ :read_rows_from,
        [['foo', -4567], [nil, 89], ['bo', nil]], * visible ]
      expect '|_foo_|_-4567_|'
      expect '|_   _|_   89_|'
      expect '|_bo _|_     _|'
      done
    end

    def subject
      Subject__[]
    end

    def typical
      [ :left, '| ', :right, ' |', :sep, ' | ',
        :write_lines_to, write_lines_to ]
    end

    def visible
      [ :left, '|_', :right, '_|', :sep, '_|_',
        :write_lines_to, write_lines_to ]
    end

    def write_lines_to
      ( @y ||= [] ).method( :push )
    end

    def expect s
      @y.shift.should eql s
    end

    def done
      @y.length.should be_zero
    end
  end
end
