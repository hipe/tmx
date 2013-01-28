module Skylab::MetaHell
  class Formal::Box               # yo dog a formal box is like a hash (ordered)
                                  # that you can customize the strictness and
                                  # like other things too. by default none of
                                  # its public members mutate its composition.

                                  # (this list is here so it can be near the
                                  # other one but it might not be yet used
                                  # here. very #exploratory/#experimental:)
    canonical_methods = [ :detect, :each, :map, :reduce, :select ].freeze

    define_singleton_method :canonical_methods do canonical_methods end

                                  # convenience delegators to the enumerator
    [ :detect, :defectch, :map, :reduce, :select ].each do |m|  # +1 -1
      define_method m do |*a, &b|
        each.send m, *a, &b
      end
    end

    def each *a, &b
      Formal::Box::Enumerator.new( -> y do
        @order.each do |k|
          y.yield k, @hash.fetch( k )
        end
      end ).each( *a, &b )
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

    def invert
      new = self.class.new
      o = @order ; h = @hash
      new.instance_exec do
        o.each do |k|
          add h[k], k
        end
      end
      new
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

    def accept attr               # convenience `store`-ish for nodes like this
      add attr.normalized_name, attr
      nil
    end
                                  # (note there is not even a protected version
                                  # of `store` ([]=) because it is contrary
                                  # to Box's desire to be explicit about things.
                                  # The equivalent of `store` for a box requires
                                  # you to state whether you are adding new
                                  # or replacing existing.)
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
    end                           # this is just one very experimental
                                  # of many possible default implementations.
    def dupe                      # if you subclassed box you will likely need
      new = self.class.allocate   # to write your own wrapper to this!
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
    # this exists a) because it makes sense to use enumerator for enumerating
    # and b) to wrap up all the crazines we do with hash-like iteration

    Formal::Box.canonical_methods.each do |m|
      define_method m do |*a, &b|
        b && ! @arity_set and base_arity_around b
        super( *a, &b )
      end
    end

    # defectch - fetch-like detect
    # similar to fetch but rather than using a key to retrieve the item,
    # use a function (like ordinary `detect`) and retrieve the first matching
    # item. Ordinary `fetch` allows you to pass a block to be invoked in case
    # an item with such a key is not found. This is like that but it is a
    # second function, not a block that you pass (this one accepts no block..).
    # Like ordinary `fetch`, if no `else` function is provided an error is
    # raised when the item is not found. Furthermore, the shape of the result
    # you get is contingent on the the arity of your first function oh lawd.
    # Whether or not using this constitues a smell is left to the discretion
    # of the user.

    def defectch key_func, else_func=nil
      base_arity_around key_func
      is_found = nil
      res = normalized_detect( -> args do
        b = key_func[ *args ]
        b and is_found = true
        b
      end )
      if is_found
        res
      elsif else_func
        else_func[]
      else
        raise ::KeyError, "value not found matching <#Proc@#{
          }#{ key_func.source_location.join ':' }>"
      end
    end

  protected

    alias_method :metahell_original_initialize, :initialize

    def initialize func
      super(& method( :visit ) )
      @arity_set = nil
      @func = func
    end

    def base_arity_around b
      @hot_arity = b.arity
      @arity_set = true
      nil
    end

    def dupe *arity
      new = self.class.allocate
      f = @func
      new.instance_exec do
        metahell_original_initialize(& method( :visit ) )
        @func = f
        if arity.length.nonzero?
          @hot_arity = arity.first
          @arity_set = true
        else
          @arity_set = nil
        end
        nil
      end
      new
    end

    def normalized_detect normalized_upstream
      filter = if 2 == @hot_arity
        ->( ( k, v) ) do
          normalized_upstream[ [ k, v ] ]
        end
      else
        -> v do
          normalized_upstream[ [ v ] ]
        end
      end
      otr = dupe @hot_arity # #todo this might not be necessary
      k, v = otr.detect(& filter )
    end

    def visit y
      arity = @arity_set ? @hot_arity : -1
      case arity
      when 1, -1
        @func[ Formal::Box::Enumerator::Yielder.new -> args do
          y << args[ 1 ] # hm..
        end ]
      when 2
        @func[ y ]
      else
        raise ::ArgumentError, "arity? #{ arity } (did you go thru each?)"
      end
    end
  end

  class Formal::Box::Enumerator::Yielder # proxies 1 or -1 args blocks

    def yield *x                  # accept user's strange args
      @func[ x ]
    end

    alias_method :<<, :yield

  protected

    def initialize func
      @func = func
    end
  end
end
