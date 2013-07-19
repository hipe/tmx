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

    # #hacks-only -

    def _a ; @a end  # READ ONLY
    def _h ; @h end  # READ ONLY
    def _ivars ; [ @a, @h ] end  # HACKS ONLY
  end
end
