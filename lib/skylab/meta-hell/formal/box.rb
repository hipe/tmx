module Skylab::MetaHell

  class Formal::Box  # read [#020] the formal box narrative #storypoint-5

    # ~ fun ways to create a box

    class << self

      def enumerator
        Box_::Enumerator__
      end

      def open_box
        Box_::Open__
      end

      def struct
        Box_::Struct__
      end

      def via_hash h  # #storypoint-40
        box = new
        box.instance_exec do
          h.each do |k, v|
            add k, v
          end
        end
        box
      end

      def with_items * x_a
        via_item_iambic x_a
      end

    private

      def via_item_iambic x_a
        box = new
        ( x_a.length % 2 ).zero? or fail 'sanity - odd number of args'
        box.instance_exec do
          0.step( x_a.length - 1, 2 ).each do |i|
            add x_a[ i ], x_a[ i + 1 ]
          end
        end
        box
      end
    end  # >>
    Box_ = self
  end

  Formal::Box::InstanceMethods = ::Module.new

  module Formal::Box::InstanceMethods::Readers  # ~ #storypoint-75

    # ~ high-level aggregate values w/o a lot of mov. parts

    def length
      @order.length
    end

    def count
      if block_given?
        @order.count do |i|
          yield @hash.fetch i
        end
      else
        length
      end
    end

    def get_names
      @order.dup
    end

    def names  # :+#deprecation:imminent
      @order.dup
    end

    def _order # #hacks-only
      @order
    end

    def _raw_constituency  # you must really have a death wish
      [ @order, @hash ]
    end

    #  ~ inspection of individual membership (ascending by complexity)

    def has? key
      @hash.key? key
    end

    # :+#algorithm
    def if? name, found_p, not_found_p=EMPTY_P_  # #storypoint-115
      if @hash.key? name
        found_p[ @hash.fetch name ] if found_p
      else
        whn_if_not_found name, not_found_p
      end
    end
  private
    def whn_if_not_found name, not_found_p
      not_found_p ||= -> do raise ::NameError, say_name_not_found( name ) end
      d = not_found_p.arity.abs
      a = [] ; d.nonzero? and a << self ; 1 < d and a << name
      not_found_p[ * a ]
    end
    def say_name_not_found name
      "name not found: #{ name.inspect }"
    end
  public

    # ~ `each` and its derivatives

    def each & p  # #storypoint-130
      if p && 2 == p.arity && ! @enumerator_class
        each_pair( & p )
      else
        _deep_each p
      end
    end

    def each_pair
      if block_given?
        d = -1 ; last = @order.length - 1
        while d < last
          d += 1
          yield (( kx = @order.fetch d )), @hash.fetch( kx )
        end ; nil
      else
        to_enum :each_pair
      end
    end

    def _deep_each p  # this has bells and whistles at the expense of frames
      ( @enumerator_class || Formal::Box::Enumerator__ ).new( -> y do
        @order.each do |k|
          y.yield k, @hash.fetch( k ) # always give the yielder 3 args (norm'd)
        end
      end, self )._each( & p )
    end

    [ :detect, :defectch, :filter, :map, :reduce, :select, :which ].each do |m|
      define_method m do |* a, & p|
        each.send m, * a, & p  # delegate all these to the enumerator
      end
    end

    def at *names  # #storypoint-155
      names.map { |n| @hash.fetch n }
    end

    def at_with_name name_a, & p  # supposed to sound like "each_with_index"
      ::Enumerator.new do |y|
        name_a.each do |i|
          y.yield fetch( i ), i
        end
        nil
      end.instance_exec do
        p ? each( & p ) : self
      end
    end

    def to_pair_scan
      d = -1 ; last = @order.length - 1 ; _Pair = Callback_::Box.pair
      Callback_.scan do
        if d < last
          i = @order.fetch d += 1
          _Pair.new @hash.fetch( i ), i
        end
      end
    end

    def get_value_stream
      d = -1 ; last = @order.length - 1
      Callback_::Scn.new do
        if d < last
          @hash.fetch @order.fetch d += 1 or raise "can't scan: false-ish value"
        end
      end
    end

    # ~ `fetch` and its derivatives (pre-order-ish)

    def fetch key, & else_p  # #storypoint-165
      @hash.fetch key, & else_p
    end

    def fetch_at_position ref, &els
      ok = true ; r = nil
      key = @order.fetch ref do
        ok = false
        els ||= -> { @order.fetch ref }  # ick but meh
        r = els[ * [ ref ][ 0, els.arity.abs ] ]
      end
      ok and r = @hash.fetch( key )
      r
    end

    def first & p
      fetch_at_position 0, & p
    end

    def last & p
      fetch_at_position( -1, & p )
    end

    # ~ `fuzzy_fetch` and family

    def fuzzy_fetch search_ref, when_zero, when_one, when_many  # #storypoint-200
      match_box = fuzzy_reduce search_ref
      case match_box.length
      when 0 ; when_zero[]
      when 1 ; when_one[ match_box.first ]
      else   ; when_many[ match_box ]
      end
    end

    def _fuzzy_reduce ref, tuple  # #storypoint-205
      Formal::Box::Fuzzy_reduce__[ self, ref, tuple ]
    end

    private :_fuzzy_reduce
  end

  module Formal::Box::Fuzzy_reduce__

    def self.[] box, search_x, three_p, collapse_p=nil  # #storypoint-225
      rx = /\A#{ ::Regexp.escape search_x.to_s.downcase }/i
      match = matched_name = nil
      name_consumer = ::Enumerator::Yielder.new do |name|
        if rx =~ name.to_s
          match = true
          matched_name = name
          raise ::StopIteration
        end
      end
      MetaHell_::Formal::Box.new.instance_exec do
        box.reduce self do |memo, (k, v)|
          match = false
          three_p[ k, v, name_consumer ] rescue ::StopIteration
          if match
            kk, vv = if collapse_p then collapse_p[ k, v ] else [ k, v ] end
            add kk, MatchData.new( matched_name, kk, vv )
          end
          memo
        end
      end
    end
    MatchData = ::Struct.new :string_matched, :name, :item
  end

  module Formal::Box::InstanceMethods::Readers

    def invert  # just like ::Hash#invert, but can bork
      new = get_box_base_copy
      o = @order ; h = @hash
      new.instance_exec do
        o.each do |k|
          add h.fetch( k ), k
        end
      end
      new
    end

    # ~ methods that produce new box-like non-boxes ( & support )

    # :+#algorithm
    def to_hash
      @hash.dup
    end

    def to_struct  # caveat [#052], full doc [#054]
      produce_struct_class.new( * values )
    end

    def produce_struct_class
      Formal::Box::Struct__.produce_struct_class_from_box self
    end

    # ~ #storypoint-245, :+[#021] a custom implementation
    def dupe
      dup
    end
    def initialize_copy otr
      init_copy( * otr.get_args_for_copy )
      super otr
    end
  protected
    def get_args_for_copy
      [ * get_args_for_base_copy, @order, @hash ]
    end
  private
    def init_copy * args_for_base, order, hash
      @order = order.dup
      @hash = hash.class[ order.map do |k|  # (h.class e.g ::Hash)
        [ k, dupe_constituent_value( hash.fetch k ) ]
      end ]
      init_base( * args_for_base )
    end
    def dupe_constituent_value x  # #storypoint-270
      if x.respond_to? :dupe
        x.dupe
      elsif ! x || ::TrueClass === x || ::Symbol === x || ::Numeric === x
        x
      else
        x.dup
      end
    end
    # ~ ~
    Formal::Box::Get_base_copy__ = -> do  # #storypoint-275
      otr = self.class.allocate
      otr.initialize_base_copy self
      otr
    end
  public
    define_method :get_box_base_copy, Formal::Box::Get_base_copy__
  protected
    def initialize_base_copy otr
      init_base( * otr.get_args_for_base_copy ) ; nil
    end
    def get_args_for_base_copy
      [ @enumerator_class ]
    end
    alias_method :get_arguments_for_base_copy, :get_args_for_base_copy
    public :get_arguments_for_base_copy
  private
    def init_base enumerator_class
      @order ||= [] ; @hash ||= {} ; @enumerator_class = enumerator_class ; nil
    end
  end

  module Formal::Box::InstanceMethods::Mutators  # ~ #storypoint-280

  private  # ~ private methods that add to the box's contituency

    def accept item  # convenience `store`-ish for nodes like this
      add item.local_normal_name, item  # might go away, hella smell #todo
      nil
    end

    def add local_normal_name, x  # #storypoint-290
      @hash.key?( local_normal_name ) and raise ::NameError, "already set - #{
        }#{ local_normal_name }"
      @order << local_normal_name
      @hash[ local_normal_name ] = x
      x
    end

    # ~ private methods that change existing values

    def change name, value        # constituent with `name` must exist. replace
      res = @hash.fetch name      # it with `value` and result is the previous
      @hash[name] = value         # value. (used to be called `replace` but
      res                         # that is a poor name considering
    end                           # what `Hash#replace` means)

    def sort_names_by! & p
      @order.sort_by!( & p )
      nil
    end

    # ~ nerks that remove constituents (alphabetical, narrative order)

    # :+#algorithm
    def clear                     # clears all constituent data from membership
      @order.clear                # (but of course does not cascade out). does
      @hash.clear                 # not touch non-constituent ivars.
      nil
    end

    def partition! & p  # #storypoint-320
      box = get_box_base_copy
      remove_a = [ ]  # atomicize it i don't know  why
      outer = self
      box.instance_exec do
        outer.each do |k, v|      # yes we could use filters but meh
          if p[ k, v ]
            add k, v
            remove_a << k
          end
        end
      end
      delete_multiple remove_a    # (result is values)
      box
    end

    def delete i
      delete_multiple( [ i ] )[ 0 ]
    end

    # :+#algorithm
    def delete_multiple name_a  # #storypoint-340
      idx_a = name_a.map do |n|
        @hash.fetch n  # just assert that it is there
        @order.index( n ) or raise ::NameError, "key not found: #{ n.inspect }"
      end
      idx_a.sort!.reverse!.each do |idx|  # we pervertedly allow the nil key wtf
        @order[ idx, 1 ] = EMPTY_A_
      end
      name_a.map do |n|
        @hash.delete n
      end
    end

    # :+#algorithm
    def partition_where_name_in! *name_a  # convenience wrapper - slice out sub-box
      partition! do |k, _|        # composed of any of the members whose name
        name_a.include? k         # is in the list of names. mutates receiver
      end                         # when any matches as with partition!
    end

    # ~ the private method that prevents future change

    def freeze
      super
      @hash.freeze ; @order.freeze
      self
    end
  end

  class Formal::Box

    include Formal::Box::InstanceMethods::Readers
    include Formal::Box::InstanceMethods::Mutators

    def initialize
      @order = [] ; @hash = {} ; @enumerator_class = nil
    end

    # ~ #storypoint-370

    def [] k
      fetch k
    end

    def to_a
      values
    end

    def values
      @order.map do |k|
        @hash.fetch k
      end
    end
    # ~
  end

  class Formal::Box::Open__ < Formal::Box

    def self.hash_controller hash  # be careful, you can easily corrupt things
      around_hash hash
    end

    # ~ mutators made public (we might just do it whole hog..)

    public :accept, :add, :change, :clear, :freeze  # #exp

    public :partition_where_name_in!, :sort_names_by!

    # ~ simple aliases

    alias_method :[]=, :add  # #exp  use wisely! it's more strict

    # ~ mutators added

    attr_writer :enumerator_class # #exp
  end

  class Formal::Box::Enumerator__ < ::Enumerator  # #storypoint-405

    alias_method :metahell_original_initialize, :initialize

    def initialize p, box_x=nil
      p.respond_to?( :call ) or raise ::ArgumentError
      @normal_consume_p = p
      @arity_override = nil
      init_with_box box_x
      super( & method( :visit ) )
    end
  private
    def init_with_box box_x
      if box_x
        if box_x.respond_to? :allocate
          @box_p = nil
          @box_class = box_x
        else
          @box_p = -> { box_x }
          @box_class = box_x.class
        end
      else
        @box_p = nil
        @box_class = Formal::Box
      end ; nil
    end
    def visit y
      @normal_consume_p[ y ]
    end

    # :+[#021] our custom implementation:

    define_method :get_base_copy_enumerator, Formal::Box::Get_base_copy__
  protected
    def initialize_base_copy otr
      init_base( * otr.get_args_for_base_copy ) ; nil
    end
    def init_base box_class, box_p, arity_override
      @box_class, @box_p, @arity_override = box_class, box_p, arity_override
      @arity_override ||= nil
    end
    def get_args_for_base_copy
      [ @box_class, @box_p, @arity_override ]
    end
    # ~
  public

    def box_map & p  # #storypoint-410
      if p
        _box_map Formal::Box, p
      else
        self
      end
    end

    def _box_map box_class, p
      ea = self
      box_class.new.instance_exec do
        ea.each do |k, v|
          add k, p[ v ]
        end
        self
      end
    end

    def _each & p  # just saves us from making 1 extra object
      if p
        each( & p )
      else
        self
      end
    end

    def each & p
      if p
        if @arity_override
          arity = @arity_override
          @arity_override = nil
        else
          arity = p.arity
        end
        normalize = NORM_P_P__[ arity ]
        super( & -> k, v do
          p[ * normalize[ k, v ] ]
        end )
      else
        super( )
      end
    end

    def map &p
      if p && 2 == p.arity
        @arity_override = 2
      end
      super( & p )
    end

    def reduce * a, & p  # this one is tricky - we have to err on
      @arity_override = 2 if p  # the side of being hash-like
      super( * a, & p )
    end

    # :+#algorithm
    def defectch key_p, else_p=nil  # #storypoint-480
      @arity_override = 2  # you want the below detect to always get 2 ICK
      norm = NORM_P_P__[ key_p.arity ]
      found = res = nil
      detect do |k, v|
        if key_p[ * norm[ k, v ] ]
          found = true
          res = 2 == key_p.arity ? [ k, v ] : v
          true
        end
      end
      if found
        res
      elsif else_p
        else_p[]
      else
        raise ::KeyError, "value not found matching <#Proc@#{
          }#{ key_p.source_location.join ':' }>"
      end
    end

    def filter * a, & p
      p and a << p
      1 == a.length or raise ::ArgumentError, "expecting 1 { proc | block }"
      _filter a.first
    end

    def _filter p
      normalize = NORM_P_P__[ p.arity ]
      outer = self
      child = get_base_copy_enumerator
      child.instance_exec do
        metahell_original_initialize(& method( :visit ))
        @normal_consume_p = -> normal_yielder do
          outer.each do |k, v|
            if p[ * normalize[ k, v ] ]
              normal_yielder.yield k, v
            end
          end
        end
      end
      child
    end

    def select & p  # #storypoint-515
      _filter( p ).to_box
    end

    NORM_P_P__ = -> do  # #storypoint-525
      one_p = -> _k, v do [ v ] end
      h = { -1 => one_p , 1 => one_p , 2 => -> *a { a } }
      h.default_proc = -> h_, k_ do
        raise ::ArgumentError, "arity not supported: #{ k_ }"
      end
      h.freeze
    end.call

    def to_box  # #storypoint-530
      otr = @box_p[] if @box_p
      box = if otr
        otr.get_box_base_copy
      else
        @box_class.new
      end
      ea = self
      box.instance_exec do
        ea.each do |k, v|
          add k, v
        end ; nil
      end
      box
    end

    alias_method :which, :filter  # #experimental
  end

  class Formal::Box::Algorithms < Formal::Box  # experiment

    def initialize a, h
      @order = a ; @hash = h
      @enumerator_class = nil
    end

    public :delete_multiple

    def new_box_and_mutate_by_partition_at * sym_a
      bx = Callback_::Box.new
      sym_a.each do | sym |
        if @hash.key? sym
          _x = @hash.delete sym
          @order[ @order.index( sym ), 1 ] = EMPTY_A_
        else
          _x = nil
        end
        bx.add sym, _x
      end
      bx
    end
  end

  class Formal::Box  # just be careful
    def self.around_hash hash
      allocate.instance_exec do
        @order = hash.keys ; @hash = hash ; init_base nil ; self
      end
    end
  end
end
