module Skylab::Basic

  class Box

    # (this was written way after "formal box" as a lightweight segway to it)

    def initialize
      @a = [ ] ; @h = { }
    end

    def dupe
      a = @a.dup ; h = @h.dup
      self.class.allocate.instance_exec do
        @a = a ; @h = h ; self
      end
    end

    def freeze
      @a.freeze ; @h.freeze ; super
    end

    def length
      @a.length
    end

    def has? k
      @h.key? k
    end

    def get_names
      @a.dup
    end

    def values
      @a.map( & @h.method( :fetch ) )
    end

    def fetch k, &p
      @h.fetch k, &p
    end

    def [] k  # should be used to trigger the default_proc only
      @h[ k ]
    end

    def to_a
      @a.map { |k| [ k , @h.fetch( k ) ] }
    end

    def map &p
      @a.map { |k| p[ @h.fetch k ] }
    end

    def each_pair &p
      @a.each { |k| p[ k, @h.fetch( k ) ] }
    end

    def get_value_scanner  # only useful when all vals are known to be trueish
      d = -1 ; last = @a.length - 1
      Scn__.new do
        @h[ @a[ d += 1 ] ] if d < last
      end
    end
    class Scn__ < ::Proc ; alias_method :gets, :call end

    #  ~ mutators ~

    def touch k
      if_has k, nil, -> { k } ; nil
    end

    def add_or_change k, x
      if_has k, -> _ { x }, -> { x }
    end

    def add_or_modify k, add_p, modify_p
      if_has k, modify_p, add_p
    end

    def has_or_add k, p
      if_has k, nil, p ; nil
    end

    def change k, x
      modify k, -> _ { x }
    end

    def modify k, p
      if_has k, p, -> do
        raise ::KeyError, "no such box element: #{ k.inspect }"
      end
    end

    def add_iambic a
      ( a.length % 2 ).zero? or fail 'sanity - odd number of args'
      0.step( a.length - 1, 2 ).each do |i|
        add a[ i ], a[ i + 1 ]
      end
      nil
    end

    def add k, x
      if_has k,
        -> _ do no_clobber_existing k end,
        -> { x } ; nil
    end

    def prepend k, x
      if @h.key? k
        no_clobber_existing k
      else
        @a.unshift k ; @h[ k ] = x ; nil
      end
    end

  private

    def if_has k, yes_p, no_p
      if @h.key? k
        if yes_p
          @h[ k ] = yes_p[ @h.fetch k ]
        end
      elsif no_p
        @a << k ; @h[ k ] = no_p[]
      end ; nil
    end

    def no_clobber_existing k
      raise ::KeyError, "collision - won't clobber existing #{ k }"
    end

  public

    def delete k
      if @h.key? k then fetch_and_delete k end
    end
    #
    def fetch_and_delete k
      r = @h.fetch k
      @a[ @a.index( k ), 1 ] = MetaHell::EMPTY_A_ ; @h.delete k
      r
    end

    # #hacks-only -

    def _a ; @a end  # READ ONLY
    def _h ; @h end  # READ ONLY
    def _ivars ; [ @a, @h ] end  # HACKS ONLY
  end
end
