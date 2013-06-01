module Skylab::MetaHell

  class Formal::Box               # yo dog a formal box is like a hash (ordered)
                                  # that you can customize the strictness of and
                                  # like other things too. by default none of
                                  # its public members mutate its composition.

    # EDIT: Formal::Box sounds a lot like the "Associative container"
    #   from http://en.wikipedia.org/wiki/Container_(abstract_data_type)
    # but is sort of "stable" in the sense used in List_of_data_structures,
    # except its order is mutable.

    FUN = -> do

      o = { }

      o[:produce_offspring] = -> do  # (see `produce_offspring_box`)
        base_a = base_args
        self.class.allocate.instance_exec do
          base_init( * base_a )
          self
        end
      end

      # `fuzzy_reduce` -
      # `ref` with be turned into a regex with the usual simple algorithm.
      # your tuple is called with (k, x, y) once for each item in `box`.
      # with `k` being each key and `x` being each corresponding value.
      # in your tuple, yield to `y` with `<<` each string name from `x`
      # (or even `k`) that you want to see if it matches against the ref.
      # Result is a new box with zero or more `Formal::Box::MatchData`.
      # *NOTE* this implementation is ignorant of the idea of an exact match,
      # so for a ref of "fo" against ["fo", "foo"], result is 2 matches.
      #

      o[:fuzzy_reduce] = -> box, ref, tuple, collapse=nil do
        rx = /\A#{ ::Regexp.escape ref.to_s.downcase }/
        match = nil
        matched_name = nil
        name_consumer = ::Enumerator::Yielder.new do |name|
          if rx =~ name.to_s
            match = true
            matched_name = name
            raise ::StopIteration
          end
        end
        MetaHell::Formal::Box.new.instance_exec do
          box.reduce( self ) do |memo, (k, v)|
            match = false
            tuple[ k, v, name_consumer ] rescue ::StopIteration
            if match
              kk, vv = if collapse then collapse[ k, v ] else [ k, v ] end
              add kk, Formal::Box::MatchData.new( matched_name, kk, vv )
            end
            memo
          end
        end
      end

      Formal::Box::MatchData = ::Struct.new :string_matched, :name, :item

      st = ::Struct.new(* o.keys ).new ; o.each { |k, v| st[k] = v } ; st.freeze

    end.call

    #         ~ fun ways to create a box ~

    def self.from_hash h
      # (the "optimization" you are thinking of is probably a bad idea!)
      box = new  # h.each(& box.method( :add ) )  # strange - `each` wouldn't
      box.instance_exec do
        h.each do |k, v|
          add k, v
        end
      end
      box
    end
  end

  module Formal::Box::InstanceMethods
  end  # box module

  module Formal::Box::InstanceMethods::Readers

    #  ~ readers - presented in categories, and the categories are
    #  ordered by vaguely how `heavy` their gestalt result is, ascending.
    #  (NOTE there are 2 methods here that do actually mutate the
    #  receiver, but they are private. can you find them?) ~

    #         ~ high-level aggregate values w/o a lot of mov. parts ~

    def length
      @order.length
    end

    def names
      @order.dup
    end

    def _order                    # tiny optimization ..? BE CAREFUL FOO
      @order
    end


    #         ~ inspection of indiv. membership (asc. by complexity) ~

    def has? key
      @hash.key? key
    end

    # `if?` - if an entry exists with `name` (if `has?` `name`), call `found`
    # with the value. Otherwise call `not_found`, which will be passed
    # zero one or two args consisting of [box [`name`]] based on its arity.

    def if? name, found, not_found=Null_f_
      if @hash.key? name
        found[ @hash.fetch name ] if found
      else
        not_found ||= -> { raise ::NameError, "name not found: #{name.inspect}"}
        x = not_found.arity.abs
        a = [ ]
        a << self if x > 0
        a << name if x > 1
        not_found[ * a ]
      end
    end

    Null_f_ = -> { }

    #                 ~ `each` and its derivatives ~

    # `each` - if block given, yield each name-value pair (or just value
    # per block arity) (and result will likely be nil/undefined.).
    # otherwise, if no block given, result is the enumerator.
    # (this serves as a downstream implementation for lots of other
    # readers so be very careful if you attempt to rewrite it in your
    # box subclass, e.g - your version should internally use a formal
    # box enumerator-like, one that has a normalized (2-arg) consumer
    # and is capable of producing filtered offspring, whatever i mean
    # by that.)

    def each &b
      ( @enumerator_class || Formal::Box::Enumerator ).new( -> y do
        @order.each do |k|
          y.yield k, @hash.fetch( k ) # always give the yielder 3 args (norm'd)
        end
      end, self )._each( &b )
    end

    [ :detect, :defectch, :filter, :map, :reduce, :select, :which ].each do |m|
      define_method m do |*a, &b|
        each.send m, *a, &b       # delegate all these to the enumerator
      end
    end

    def at *names                 # exactly `::Hash#values_at` but the name
      names.map { |n| @hash.fetch n }  # doesn't collide with `Struct#values_at`
    end                           # which weirdly only works with ints.
                                  # (also uses hash "risc" b.c ..)

    #         ~ `fetch` and its derivatives (pre-order-ish) ~

    def fetch key, &otherwise     # just like ::Hash#fetch (see)
      @hash.fetch key, &otherwise
    end

    # (the above is probably aliased to '[]' in the box class.)

    def fetch_at_position ref, &els
      res = nil
      begin
        ok = true
        key = @order.fetch ref do
          ok = false
          els ||= -> { @order.fetch ref }  # ick but meh
          res = els[ * [ ref ][ 0, els.arity.abs ] ]
        end
        ok or break
        res = @hash.fetch key do
          ok = false
          els ||= -> { @hash.fetch key }  # ick but meh
          res = els[ * [ key ][ 0, els.arity.abs ] ]
        end
      end while nil
      res
    end

    def first &b
      fetch_at_position 0, &b
    end

    def last &b
      fetch_at_position( -1, &b )
    end

    #                   ~ `fuzzy_fetch` and family ~

    # `fuzzy_fetch` - This is a higher-level, porcelain-y convenience method,
    # written as an #experimental attempt to corral repetitive code like
    # this into one place (was [#mh-020]).
    # To use it your box subclass must implement `fuzzy_reduce` (usually in
    # about one line) (see). Internally, `fuzzy_fetch` produces a subset
    # box of the items that match the _string_ per your fuzzy_reduce
    # method (actually in theory some of this could be applied towards
    # arbitrary search criteria but for now it is geared towards
    # user-entered strings..)
    # If none was matched in the search, `when_zero` is called with no
    # arguments. If one, `when_one` is called with
    # **the matching `Formal::Box::Matchdata` object (see)**, which has
    # the matched item in it with other metadata (some algos like to know
    # what search string was used, or which of several searched-against strings
    # was matched). If more than one item was matched, `when_many` is called
    # with the whole box of matchdatas. Result is the result of the particular
    # callback (of the three) that was called (exactly one will be
    # called, because the three callbacks cover in a non-overlapping way
    # the set of non-negative integers, to put too fine a point on it).

    def fuzzy_fetch search_ref, when_zero, when_one, when_many
      match_box = fuzzy_reduce search_ref
      case match_box.length
      when 0 ; when_zero[]
      when 1 ; when_one[ match_box.first ]
      else   ; when_many[ match_box ]
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

    def _fuzzy_reduce ref, tuple
      Formal::Box::FUN.fuzzy_reduce[ self, ref, tuple ]
    end

    private :_fuzzy_reduce

    def invert                    # (just like ::Hash#invert, but can bork)
      new = produce_offspring_box
      o = @order ; h = @hash
      new.instance_exec do
        o.each do |k|
          add h.fetch( k ), k
        end
      end
      new
    end

    #         ~ methods that produce new box-like non-boxes ~

    def to_hash
      @hash.dup
    end

    def to_struct                 # (see implementor for justification)
      Formal::Box.const_get( :Struct, false ).produce self
    end

    #         ~ methods that assist in producing new boxes ~

  private

    # `dupe` - if your subclass very carefully overrides (and calls up to!)
    # dupe_args / dupe_init correctly, you could have relatively painless duping
    # The duplicate is supposed to 1) a new box object of same class as
    # receiver with 2) (for the non-constituent ivars like @enumerator_class)
    # ivars that refer to the same objects as the first and 3) constituent
    # elements that are in the same order as the receiver, and whose each
    # value is a dupe of the original for some definition of dupe (which is
    # determined by `dupe_constituent_value` which you may very well want to
    # rewrite in your box subclass).

    def dupe
      dupe_a = dupe_args
      self.class.allocate.instance_exec do
        dupe_init(* dupe_a )
        self
      end
    end
    public :dupe

    def dupe_args                 # for initting full duplicates, see `dupe`
      [ * base_args, @order, @hash ]
    end

    def dupe_init *base_args, order, hash  # (see `dupe`)
      @order = order.dup
      @hash = hash.class[ order.map do |k|  # (h.class e.g ::Hash)
          [ k, dupe_constituent_value( hash.fetch k ) ]
      end ]
      base_init(* base_args )
      nil
    end
                                  # (base_args/base_init tracked by [#mh-021])
    def base_args                 # for initting duplicates that may not have
      [ @enumerator_class ]       # the same constitent data (elements).
    end

    def base_init enumerator_class  # (see `base_args`) receiver is expected
      @order ||= [ ]              # to be coherent (can function as a box)
      @hash ||= { }               # after `base_args` was called on it.
      @enumerator_class = enumerator_class
    end


    # dupe an arbitrary constituent value for use in duping. we hate this,
    # it is tracked by [#mh-014]. this is a design issue that should be
    # resolved per box.

    def dupe_constituent_value x
      if x.respond_to? :dupe
        x.dupe
      elsif ! x || ::TrueClass === x || ::Symbol === x || ::Numeric === x
        x
      else
        x.dup
      end
    end

    # like `dupe` but don't bring over any of # the constituent elements.
    # Used all over the place for methods that result in # a new box.

    define_method :produce_offspring_box, & Formal::Box::FUN.produce_offspring
  end

  module Formal::Box::InstanceMethods::Mutators

    #   ~ these are all the nerks that add, change, and remove the
    # box members that make up its constituency. they a) all all private
    # by default but can be opened up as necessary and b) are here because
    # we might want to make some strictly read-only box-likes. ~

  private
      #         ~ private methods that add to the box's contituency ~

    def accept item               # convenience `store`-ish for nodes like this
      add item.normalized_name, item  # might go away, hella smell #todo
      nil
    end
                                  # (note there is not even a private version
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
      x
    end

    #         ~ private methods that change existing values ~

    def change name, value        # constituent with `name` must exist. replace
      res = @hash.fetch name      # it with `value` and result is the previous
      @hash[name] = value         # value. (used to be called `replace` but
      res                         # that is a poor name considering
    end                           # what `Hash#replace` means)

    def sort_names_by! &func
      @order.sort_by!(& func )
      nil
    end

    #         ~ nerks that remove constituents (alpha. order) ~

    def clear                     # clears all constituent data from membership
      @order.clear                # (but of course does not cascade out). does
      @hash.clear                 # not touch non-constituent ivars.
      nil
    end

    # `partition!`
    # TL;DR: For all the members that match `func`, take them out of this
    # box and put them in a new box. In more detail:
    # (it's like an ::Enumerable#partition but one result instead of two,
    # and it mutates the receiver. It's like ::Hash#delete_if whose
    # result is effectively the deleted virtual hash.)
    # Result is a new box that is spawned from this box (so same class, and
    # same "non-constituent" ivars, initted with `base_args`) whose
    # constituency is the set of zero or more name-value pairs that resulted in
    # true-ish when passed to `func` (which must take 2 args). Each matched
    # name-value pair is removed from the reciever. No matter what you end
    # up with two boxes where once there was one and still the same total
    # number of members.

    def partition! &func
      box = produce_offspring_box
      remove_a = [ ]  # atomicize it i don't know  why
      outer = self
      box.instance_exec do
        outer.each do |k, v|      # yes we could use filters but meh
          if func[ k, v ]
            add k, v
            remove_a << k
          end
        end
      end
      delete_multiple remove_a    # (result is values)
      box
    end

    empty_a = [ ].freeze          # (ocd)

                                  # batch-delete, bork on key not found.

    define_method :delete_multiple do |name_a|
      idx_a = name_a.map do |n|
        @hash.fetch n  # just assert that it is there
        @order.index( n ) or raise ::NameError, "key not found: #{ n.inspect }"
      end
      idx_a.sort!.reverse!.each do |idx|  # we pervertedly allow the nil key wtf
        @order[ idx, 1 ] = empty_a
      end
      name_a.map do |n|
        @hash.delete n
      end
    end

    def partition_by_keys! *name_a  # convenience wrapper - slice out a sub-box
      partition! do |k, _|        # composed of any of the members whoe name
        name_a.include? k         # was in the list of names. might mutate
      end                         # receiver.
    end

    #        ~ the private method that prevents future change ~

    def freeze
      super
      @hash.freeze ; @order.freeze
      self
    end
  end

  class Formal::Box
    include Formal::Box::InstanceMethods::Readers
    include Formal::Box::InstanceMethods::Mutators

    alias_method :[], :fetch      # so '[]' is not as with hash - it is strict.
    # Proffered for "readability". (actually think ::Struct if it bothers
    # you)  use `fetch` if you need hash-like softness) (it is not above so
    # we can avoid overwriting ::Struct's native implementation in the hack
    # over there.)

    def values                    # (here so as not to overwrite struct's v.)
      @order.map { |n| @hash.fetch n }  # (use "hash risc" for 2 reasons)
    end

    alias_method :to_a, :values

  private

    def initialize                # (subclasses call super( ) of course!)
      @order = [ ]
      @hash = { }
      @enumerator_class = nil
      # (don't change the above without looking carefully at `base_args` et. al)
    end
  end

  class Formal::Box::Open < Formal::Box

    def self.hash_controller hash  # be careful, you can easily corrupt things
      around_hash hash
    end

    #   ~ mutators made public (we might just do it whole hog..) ~
    public :accept, :add, :change, :clear, :freeze  # #exp

    public :partition_by_keys!, :sort_names_by!

    #    ~ simple aliases ~
    alias_method :[]=, :add  # #exp  use wisely! it's more strict

    #   ~ mutators added ~
    attr_writer :enumerator_class # #exp
  end

  class Formal::Box::Enumerator < ::Enumerator

    # this exists a) because it makes sense to use enumerator for enumerating
    # and b) to wrap up all the crazines we do with hash-like iteration

    # `box_map` - result is a new Box that will have the same keys in the same
    # order as the virtual box represented by this enumerator at the time
    # of this call, but whose each value will be the result of passing the
    # value of *this* virtual box to `func`. Result is not of the
    # same box class as the one that created this enumerator,
    # just a generic formal box (because presumably the constituent elements
    # of the result box are not necessarily of the same "type" as the
    # box you called this on). (You can use `_box_map` to specify the
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

    ONE_ = -> k, v { [ v ] }      # (these are the normalizers we use to
                                  # yield either one or two values out per
    TWO_ = ->( *a ) { a }         # element as appropriate)

    norm_h = ::Hash.new do |h, k|
      raise ::ArgumentError, "arity not supported: #{ k }"
    end

    norm_h[1]  = ONE_             # (these are the permissable arities your
    norm_h[-1] = ONE_             # block (to whatever) can have and then
    norm_h[2]  = TWO_             # the corresponding normalizer we use to
                                  # yeild each name-value pair out)

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
      super( *a, &func )
    end

    # `defectch` - fetch-like detect
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
      @arity_override = 2  # you want the below detect to always get 2 ICK
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

    define_method :_filter do |func|
      normalize = norm_h[ func.arity ]
      outer = self
      child = produce_offspring_enumerator
      child.instance_exec do
        metahell_original_initialize(& method( :visit ))
        @normalized_yielder_consumer = -> normal_yielder do
          outer.each do |k, v|
            if func[ * normalize[ k, v ] ]
              normal_yielder.yield k, v
            end
          end
        end
      end
      child
    end
                                  # Array#select result is array, Hash is hash..
    def select &func
      _filter( func ).to_box
    end
                                   # if you want to collapse back down to a box
    def to_box                     # after a chain of e.g. filters or whatever
      otr = @box_ref.call if @box_ref
      box = if otr
        otr.send :produce_offspring_box
      else
        @box_class.new
      end
      ea = self
      box.instance_exec do
        ea.each do |k, v|
          add k, v
        end
        nil
      end
      box
    end

    alias_method :which, :filter  # #experimental

  private

    alias_method :metahell_original_initialize, :initialize

    def initialize func, box_x=nil
      func.respond_to?( :call ) or raise ::ArgumentError, "f?: #{ func.class }"
      @normalized_yielder_consumer = func
      super(& method( :visit ) )
      @arity_override = nil
      if box_x
        if box_x.respond_to? :allocate
          @box_ref = nil
          @box_class = box_x
        else
          @box_ref = -> { box_x }
          @box_class = box_x.class
        end
      else
        @box_ref = nil
        @box_class = Formal::Box
      end
      nil
    end

    def base_args
      [ @box_class, @box_ref, @arity_override ]
    end

    def base_init box_class, box_ref, arity_override
      @box_class, @box_ref, @arity_override =
        box_class, box_ref, arity_override
      @arity_override ||= nil
    end

    define_method :produce_offspring_enumerator, &
      Formal::Box::FUN.produce_offspring

    def visit y
      @normalized_yielder_consumer[ y ]
    end
  end

  class Formal::Box   # just be careful
    def self.around_hash hash
      allocate.instance_exec do
        @order = hash.keys
        @hash = hash
        base_init nil
        self
      end
    end
  end
end
