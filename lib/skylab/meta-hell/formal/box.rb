module Skylab::MetaHell
  class Formal::Box               # yo dog a formal box is like a hash (ordered)
                                  # that you can customize the strictness and
                                  # like other things too. by default none of
                                  # its public members mutate its composition.

    [ :detect, :defectch, :filter, :map, :reduce, :select, :which ].each do |m|
      define_method m do |*a, &b|
        each.send m, *a, &b
      end
    end

    def each &b
      Formal::Box::Enumerator.new( -> y do
        @order.each do |k|
          y.yield k, @hash.fetch( k ) # always give the yielder 2 args (norm'd)
        end
      end, self.class )._each( &b )
    end

    def fetch key, &otherwise
      @hash.fetch key, &otherwise
    end

    def fetch_index ref, &otherwise
      begin
        key = @order.fetch ref    # (we can't let the user's logic break ours)
        @hash.fetch key           # (this whole thing is actually just for
      rescue ::IndexError => e    # `first`, which is actually only used
        if otherwise then otherwise[ ref ] else # in a test attotw.)
          raise e
        end
      end
    end

    alias_method :[], :fetch      # this is not like a hash, it is strict,
                                  # use `fetch` if you need hash-like softness

    def first &b
      fetch_index 0, &b
    end

    # fuzzy_fetch
    # This is a higher-level, porcelain-y convenience function, written as an
    # #experimental attempt to corral repetitive code like this into one place.
    # (and it will likely be moved to an InstanceMethods one day [#mh-020])
    # To use it, your box subclass must implement `fuzzy_reduce` (usually in
    # about one line) (see). Internally, it creates a subset box of the items
    # that match the string per your fuzzy_reduce method. If none was matched
    # `when_zero` is called with no arguments. If one, `when_one` is called
    # with **the matching `Formal::Box::Matchdata` object (see)**, which has
    # the matched item in it with other metadata (some algos like to know
    # what search string was used, or which of several searched-against strings
    # was matched). If more than one item was matched, `when_many` is called
    # with the whole box of matchdatas. Result is result of the callback.
    #

    def fuzzy_fetch search_ref, when_zero, when_one, when_many
      match_box = fuzzy_reduce search_ref
      case match_box.length
      when 0 ; when_zero[]
      when 1 ; when_one[ match_box.first ]
      else   ; when_many[ match_box ]
      end
    end

    def has? key
      @hash.key? key
    end

    def if? name, found, not_found
      if @hash.key? name
        found[ @hash.fetch name ]
      else
        not_found ||= -> { raise ::NameError, "name not found: #{name.inspect}"}
        x = not_found.arity.abs
        a = [ ]
        a << self if x > 0
        a << name if x > 1
        not_found[ * a ]
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

    def last &b
      fetch_index( -1, &b )
    end

    def length
      @order.length
    end

    def _order                    # tiny optimization ..?
      @order
    end

  protected

    def initialize                # (subclasses call super( ) of course!)
      @order = [ ]
      @hash = { }
    end

    alias_method :_meta_hell_formal_box_core_init, :initialize # see `to_box`

    # base_args / base_init       # #todo

    # --*--

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

    #   `fuzzy_reduce` via `_fuzzy_reduce`
    # `fuzzy_reduce` is typically used as a backend for `fuzzy_fetch` (see).
    # In your box subclass, implement a method `fuzzy_reduce ref` and for its
    # body you will typically call `_fuzzy_reduce`, passing it a string as
    # a search query, and a function that takes three arguments. the function
    # will be called once for each item in your box, and will be passed the
    # item's name, value, and a yielder. Pass into the yielder whatever
    # string(s) you want to represent the item by in this search:
    #
    #     def fuzzy_reduce ref                            # `slug` e.g. is
    #       _fuzzy_reduce ref, -> k, v, y { y << v.slug } # something your items
    #     end                                             # respond to, stringy
    #
    # Internally, e.g _fuzzy_reduce will use a regex created from the search
    # ref and match it against each string you yield, stopping at the first
    # match per item (but still the broader search continues over each item).
    # The result is a new box whose names correspond to the matching subset
    # of names in your box, and whose values will be one Formal::Box::MatchData
    # per item (see).
    #
    # If your items have multiple aliases or keywords to be searched
    # against (i.e. not just one "name" string), just loop over them and
    # yield each one to the yielder, which is what it's there for.
    #
    # (The reason you have to implement a `fuzzy_reduce` yourself is because
    # it would be a bit of a smell for this library to assume how to induce
    # one or more strings for your items.)
    #

    def _fuzzy_reduce ref, tuple               # tuple gets (k, x, y). yield
      rx = /\A#{ ::Regexp.escape ref.to_s.downcase }/ # each name you want to
      match = nil                                     # try. box result.
      matched_name = nil
      name_consumer = ::Enumerator::Yielder.new do |name|
        if rx =~ name.to_s
          match = true
          matched_name = name
          raise ::StopIteration
        end
      end
      me = self
      MetaHell::Formal::Box.new.instance_exec do
        me.reduce( self ) do |memo, (k, v)|
          match = false
          tuple[ k, v, name_consumer ] rescue ::StopIteration
          if match
            add k, Formal::Box::MatchData.new( matched_name, k, v )
          end
          memo
        end
      end
    end

    def replace name, value
      res = @hash.fetch name
      @hash[name] = value
      res
    end
  end

  class Formal::Box::Open < Formal::Box
    public :accept, :add  # #exp
  end

  class Formal::Box::Enumerator < ::Enumerator
    # this exists a) because it makes sense to use enumerator for enumerating
    # and b) to wrap up all the crazines we do with hash-like iteration

    attr_writer :box_instance  # for hacks, near `to_box`

    # box_map - result is a new Box that will have the same keys in the same
    # order as the virtual box represented by this enumerator at the time
    # of this call, but whose each value will be result of passing the
    # value of *this* virtual box to `func`.  Result is not not of the
    # same box class as the one that created this enumerator,
    # just a generic formal box. (You can use `_box_map` to specify the
    # class.)

    def box_map &func
      if func
        _box_map Formal::Box, func
      else
        self # why would you pass no block i don't know but this is just
      end    # for compat. with Enumerable.
    end

    def _box_map box_class, func
      ea = self
      box_class.new.instance_exec do
        ea.each do |k, v|
          add k, func[ v ]
        end
        self
      end
    end

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

    alias_method :metahell_original_each, :each

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

    [ :map ].each do |m|
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

    def filter *args, &func
      args.push func if func
      args.length == 1 or raise ::ArgumentError, "expecting 1 { proc | block }"
      _filter args.first
    end

                                  # Array#select result is array, Hash is hash..
    def select &func
      _filter( func ).to_box
    end
                                   # if you want to collapse back down to a box
    def to_box                     # after a chain of e.g. filters or whatever
      ea = self                    # (base_args/base_init tracked by [#mh-021])
      ba = @box_instance.call.send :base_args if @box_instance
      @box_class.allocate.instance_exec do
        _meta_hell_formal_box_core_init
        ea.each do |k, v|
          add k, v
        end
        base_init(* ba ) if ba    # (designed not to be too hackable..)
        self
      end
    end

    alias_method :which, :filter  # #experimental

  protected

    alias_method :metahell_original_initialize, :initialize

    def initialize func, box_class=Formal::Box, box_instance=nil
      func.respond_to?( :call ) or raise ::ArgumentError, "f?: #{ func.class }"
      ::Class === box_class or raise ::ArgumentError, "c?: #{ box_class.class }"
      super(& method( :visit ) )
      @arity_override = nil
      @box_class = box_class
      @normalized_yielder_consumer = func
      @box_instance = box_instance
    end

    define_method :_filter do |func|
      normalize = norm_h[ func.arity ]
      outer = self
      self.class.new( -> normal_yielder do
        outer.each do |k, v|
          if func[ * normalize[ k, v ] ]
            normal_yielder.yield k, v
          end
        end
      end, @box_class, @box_instance )
    end

    def visit y
      @normalized_yielder_consumer[ y ]
    end
  end

  Formal::Box::MatchData = ::Struct.new :string_matched, :name, :item

end
