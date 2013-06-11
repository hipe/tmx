module Skylab::Basic

  module List::Scanner

    def self.[] x
      if x.respond_to? :each_index
        List::Scanner::For::Array.new x
      elsif x.respond_to? :read
        List::Scanner::For::Read.new x
      else
        raise "#{ self } can't resolve a scanner for ::#{ x.class }"
      end
    end
  end

  module List::Scanner::For

    extend MAARS

  end

  class List::Scanner::For::Array

    # in theory array can be mutated mid-scan.
    # it just maintains two indexes internally, one from the begnining
    # and one from the end, and checks current array length against these two
    # at every `gets` or `rgets`.

    # (leave this line intact, this is when we flipped it back - as soon as
    # the number of functions outnumbered the number of [i]vars it started
    # to feel silly. however we might one day go back and compare the one vs.
    # the other with [#bm-001])

    def initialize a
      @idx = @ridx = 0
      @a = a
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
  end
end
