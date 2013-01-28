module Skylab::MetaHell
  class Formal::Box               # yo dog a formal box is like a hash (ordered)
                                  # that you can customize the strictness and
                                  # like other things too. by default none of
                                  # its public members mutate its composition.

                                  # (this list is here so it can be near the
                                  # other one but it might not be yet used
                                  # here. very #exploratory/#experimental:)
    canonical_derived_methods = [ :map, :select ].freeze

    define_singleton_method :canonical_derived_methods do
      canonical_derived_methods
    end
                                  # convenience delegators to the enumerator
    [ :detect, :defectch, :filter, :map, :reduce, :select ].each do |m|
      define_method m do |*a, &b|
        each.send m, *a, &b
      end
    end

    def each *a, &b
      Formal::Box::Enumerator.new( -> y do
        @order.each do |k|
          y.yield k, @hash.fetch( k ) # always give the yielder 2 args (norm'd)
        end
      end )._each( *a, &b )
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

    def _each &func # just saves us from making 1 extra object
      if func
        each( &func)
      else
        self
      end
    end

    ONE_ = -> k, v { [ v ] }

    TWO_ = ->( *a ) { a }

    norm_h = ::Hash.new do |h, k|
      raise ::ArgumentError, "arity not supported: #{ k }"
    end

    norm_h[1]  = ONE_
    norm_h[-1] = ONE_
    norm_h[2]  = TWO_

    define_method :each do |&func|
      if func
        if @arity_override
          arity = @arity_override
          @arity_override = nil
        else
          arity = func.arity
        end
        normalize = norm_h[ arity ]
        super( & -> k, v do
          func[ * normalize[ k, v ] ]
        end )
      else
        super( )
      end
    end

    Formal::Box.canonical_derived_methods.each do |m|
      define_method m do |&func|
        if func && 2 == func.arity
          @arity_override = 2
          super(& func )
        else
          super(& func )
        end
      end
    end

    def reduce *a, &func          # this one is tricky - we have to err on
      @arity_override = 2 if func # the side of being hash-like
      super(*a, &func)
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

    define_method :defectch do |key_func, else_func=nil|
      @arity_override = 2 # you want the below detect to always get 2
      norm = norm_h[ key_func.arity ]
      found = res = nil
      detect do |k, v|
        if key_func[ * norm[ k, v ] ]
          found = true
          res = 2 == key_func.arity ? [ k, v ] : v
          true
        end
      end
      if found
        res
      elsif else_func
        else_func[]
      else
        raise ::KeyError, "value not found matching <#Proc@#{
          }#{ key_func.source_location.join ':' }>"
      end
    end

    define_method :filter do |func|
      normalize = norm_h[ func.arity ]
      outer = self
      inner = self.class.new( -> normal_yielder do
        outer.each do |k, v|
          if func[ * normalize[ k, v ] ]
            normal_yielder.yield k, v
          end
        end
      end )
      inner
    end

  protected

    alias_method :metahell_original_initialize, :initialize

    def initialize func
      super(& method( :visit ) )
      @arity_override = nil
      @normalized_yielder_consumer = func
    end

    def visit y
      @normalized_yielder_consumer[ y ]
    end
  end
end
