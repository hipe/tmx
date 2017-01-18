module Skylab::Basic

  module List

    class LineStream_via_Array < Common_::MonadicMagneticAndModel

      # read [#023] (in [#022]) the array scanner narrative

      def initialize a
        @a = a ; @idx = @ridx = 0 ; nil
      end

      def reset
        @idx = @ridx = 0
        nil
      end

      def gets
        if ! eos?
          fetchs
        end
      end

      def ungets
        if @idx < 0
          when_no_ungets
        else
          @idx -= 1
        end ; nil
      end

      private def when_no_ungets
        raise ::IndexError, "attempt to `ungets` past beginning"
      end

      def fetchs
        x = @a.fetch @idx
        @idx += 1
        x
      end

      def fetch_chunk num
        if 0 <= num && num <= remaining_count
          do_fetch_chunk num
        else
          when_bad_chunk num
        end
      end
    private
      def do_fetch_chunk d
        a = ( d - 1 ).downto( 0 ).map do |d_|
          @a.fetch( @idx + d_ )
        end
        @idx += d
        a.reverse!
        a
      end
      def when_bad_chunk d
        _s = "at least #{ d } more element#{ 's' if 1 != d } #{
          }#{ 1 == d ? 'is' : 'are' } expected."
        raise ::IndexError, _s
      end
    public

      def rgets
        if ! eos?
          @ridx += 1
          @a.fetch( -1 * @ridx )
        end
      end

      def lineno
        @idx.nonzero?
      end

      def count
        @idx
      end

      def remaining_count
        @a.length - @ridx - @idx
      end

      def index
        if @idx.nonzero?
          @idx - 1
        end
      end

      def terminate
        @ridx = @idx = @a.length
        nil
      end

      def eos?
        @idx >= ( @a.length - @ridx )
      end

      # ~ comport to old [hl] array scanner, #todo:during-merge coverage

      def arr
        @a
      end

      def length
        @a.length
      end

      def pos
        @idx
      end
    end
  end
end
