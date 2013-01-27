module Skylab::MetaHell
  class Formal::Box               # yo dog a formal box is like a hash (ordered)
                                  # that you can customize the strictness and
                                  # like other things too
    def each &block
      enum = nil
      enum = Formal::Box::Enumerator.new do |y|
        @order.each(&
          if 1 == enum.block_arity # goof around compat. with hash-style itr.
            -> k { y << @hash[k] }
          else
            -> k { y << [k, @hash[k]] }
          end
        )
      nil
      end
      if block
        enum.each(& block)
      else
        enum
      end
    end

    def fetch key, &otherwise
      @hash.fetch key, &otherwise
    end

    alias_method :[], :fetch      # this is not like a hash, it is strict,
                                  # use `fetch` if you need hash-like softness

    def has? key
      @hash.key? key
    end

    def if? name, found, not_found
      if @hash.key? name
        found[ @hash.fetch name ]
      else
        not_found[ ]
      end
    end

    def names
      @order.dup
    end

    def length
      @order.length
    end

    def _order                    # tiny optimization ..?
      @order
    end

  protected

    def initialize
      @order = [ ]
      @hash = { }
    end

    def accept attr
      add attr.normalized_name, attr
      nil
    end

    def add normalized_name, x
      @hash.key?( normalized_name ) and raise ::NameError, "already set - #{
        }#{ normalized_name }"
      @order << normalized_name
      @hash[ normalized_name ] = x
      nil
    end

    def clear
      @order.clear
      @hash.clear
      nil
    end
                                  # this is just one very experimental
                                  # of many possible default implementations.
    def dupe
      new = self.class.allocate
      o, h = @order, @hash
      new.instance_exec do
        @order = o.dup
        @hash = h.class[ o.map do |k|  # (h.class e.g ::Hash)
          [ k, _dupe( h[k] ) ]
        end ]
      end
      new
    end

    # dupe an arbitrary constituent value for use in duping. we hate this,
    # it is tracked by [#mh-014]. this is a design issue that should be
    # resolved per box.
    def _dupe x
      if ! x || ::TrueClass === x || ::Symbol === x || ::Numeric === x
        x
      elsif x.respond_to? :dupe
        x.dupe
      else
        x.dup
      end
    end

    def replace name, value
      res = @hash.fetch name
      @hash[name] = value
      res
    end
  end

  class Formal::Box::Enumerator < ::Enumerator
    # what if we wanted boxes to act like hashes when it comes to iteration?

    attr_reader :block_arity      # ridiculous experiments, this can't be right

    [ :each, :map, :reduce, :select ].each do |m| # etc egads
      define_method m do |*a, &b|
        @block_arity = ( b.arity if b )
        super( *a, &b )
      end
    end

  protected

    def initialize
      super
      @block_arity = nil
    end
  end
end
