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

    def initialize a
      idx = nil ; ridx = nil
      ( @reset = -> do
        idx = 0 ; ridx = 0
        nil
      end ).call
      @eos = -> do
        idx >= ( a.length - ridx )
      end
      @gets = -> do
        if ! @eos[]
          r = a.fetch idx
          idx += 1
          r
        end
      end
      @rgets = -> do
        if ! @eos[]
          ridx += 1
          a.fetch( -1 * ridx )
        end
      end
      @count = -> do
        idx
      end
      @index = -> do
        ( idx - 1 ) if idx.nonzero?
      end
      @terminate = -> do
        ridx = idx = a.length
        nil
      end
    end

    def eos?
      @eos.call
    end

    def gets
      @gets.call
    end

    # NOTE does not affect `count`.  if

    def rgets
      @rgets.call
    end

    def count
      @count.call
    end

    def terminate
      @terminate.call
    end

    def reset
      @reset.call
    end

    # [#bm-001] you see what the above pattern looks like don't you ..
  end
end
