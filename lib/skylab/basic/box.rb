module Skylab::Basic

  class Box

    # (this was written way after "formal box" as a lightweight segway to it)

    def initialize
      @a = [ ] ; @h = { }
    end

    def length
      @a.length
    end

    def has? i
      @h.key? i
    end

    def get_names
      @a.dup
    end

    def values
      @a.map( & @h.method( :fetch ) )
    end

    def fetch i, &b
      @h.fetch i, &b
    end

    def [] i  # should be used to trigger the default_proc only
      @h[ i ]
    end

    def to_a
      @a.map { |i| [ i , @h.fetch( i ) ] }
    end

    def map &p
      @a.map { |i| p[ @h.fetch i ] }
    end

    #  ~ mutators ~

    def touch k
      @h.key? k or add k, k
      nil
    end

    def add i, x
      @h.key? i and raise ::KeyError, "collision - won't clobber existing #{i}"
      @a << i
      @h[ i ] = x
      nil
    end

    def modify i, p
      @h[ i ] = p[ @h.fetch( i ) ]
      nil
    end

    def add_or_modify i, p, p_
      if @h.key? i
        modify i, p_
      else
        add i, p[]
      end
      nil
    end

    # #hacks-only -

    def _a ; @a end  # READ ONLY
    def _h ; @h end  # READ ONLY
    def _ivars ; [ @a, @h ] end  # HACKS ONLY
  end
end
