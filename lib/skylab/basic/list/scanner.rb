module Skylab::Basic

  module List::Scanner

    def self.[] x
      if x.respond_to? :each_index
        List::Scanner::For::Array.new x
      end
    end

  end

  module List::Scanner::For

  end

  class List::Scanner::For::Array

    def initialize a
      idx = 0
      @eos = -> do
        idx >= a.length
      end
      @gets = -> do
        if ! @eos[]
          r = a.fetch idx
          idx += 1
          r
        end
      end
      @count = -> do
        idx
      end
      @index = -> do
        ( idx - 1 ) if idx.nonzero?
      end
    end

    def eos?
      @eos.call
    end

    def gets
      @gets.call
    end

    def count
      @count.call
    end
  end
end
