module Skylab::Basic

  module List::Scanner

    class For::Array  # read [#023] (in [#022]) the array scanner narrative

      def initialize a
        @a = a ; @idx = @ridx = 0 ; nil
      end
      def reset
        @idx = @ridx = 0
        nil
      end
      def eos?
        @idx >= ( @a.length - @ridx )
      end
      def gets
        fetchs if ! eos?
      end
      def ungets
        @idx < 0 and raise ::IndexError, "attempt to `ungets` past beginning"
        @idx -= 1
      end
      def fetchs
        r = @a.fetch @idx
        @idx += 1
        r
      end
      def fetch_chunk num
        0 <= num && num <= remaining_count or raise ::IndexError, "at least #{
          }#{ num } more element#{ 's' if 1 != num } #{
          }#{ 1 == num ? 'is' : 'are' } expected."
        r = ( num - 1 ).downto( 0 ).map do |i|
          @a.fetch( @idx + i )
        end
        @idx += num
        r.reverse
      end
      def rgets
        if ! eos?
          @ridx += 1
          @a.fetch( -1 * @ridx )
        end
      end
      def line_number
        @idx.nonzero?
      end
      def count
        @idx
      end
      def remaining_count
        @a.length - @ridx - @idx
      end
      def index
        @idx - 1 if @idx.nonzero?
      end
      def terminate
        @ridx = @idx = @a.length
        nil
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
