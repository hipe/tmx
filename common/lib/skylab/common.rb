module Skylab ; end

module Skylab::Common

  class << self

    def [] mod, * x_a
      # #todo no
      self::Bundles.edit_module_via_mutable_iambic mod, x_a
    end

    def describe_into_under y, expag
      y << "(as a reactive node, [co] is some ancient artifact..)"
    end

    def lib_
      @___lib ||= produce_library_shell_via_library_and_app_modules self::Lib_, self
    end

    # memoize defined below

    def produce_library_shell_via_library_and_app_modules lib_mod, app_mod
      Home_::Librication__[ lib_mod, app_mod ]
    end

    def stream( & p )
      Stream.by( & p )
    end

    def test_support  # #[#ts-035]
      if ! Home_.const_defined? :TestSupport
        require_relative '../../test/test-support'
      end
      Home_::TestSupport
    end
  end  # >>

  # -- hybrid "magnetic" (function implemented by class) and model

  # (experiments while we let some dust settle..)

  class SimpleModel
    class << self
      alias_method :define, :new
      undef_method :new
    end  # >>
    def initialize
      yield self
      freeze
    end
    private :dup
  end

  class MagneticBySimpleModel < SimpleModel  # ~10x
    class << self
      def call_by & p
        define( & p ).execute
      end
      def prototype_by & p
        define( & p ).freeze
      end
      private :define  # or not, but track it
    end
    def initialize
      yield self  # not freezing by default - magnets usu. want to mutate
    end
  end

  class SimpleModelAsMagnetic < SimpleModel  # experimental variant
    class << self
      alias_method :call_by, :define
      undef_method :define
    end  # >>
  end

  class MonadicMagneticAndModel
    class << self
      alias_method :call, :new
      alias_method :[], :call
      undef_method :new
    end  # >>
  end

  # -- used to be "actors" now "magnets" - see [#fi-016] the "actor" narrative

  module ProcLike
    def call * a, & p
      new( * a, & p ).execute
    end
    alias_method :[], :call
  end

  class Dyadic
    class << self
      def call x, y, & p
        new( x, y, & p ).execute
      end
      alias_method :[], :call
      private :new
    end  # >>
  end

  class Monadic
    class << self
      def call x, & p
        new( x, & p ).execute
      end
      alias_method :[], :call
      private :new
    end  # >>
  end

  # --

  Home_ = self

  class Box  # :[#061]

    class << self

      def the_empty_box
        @___the_empty_box ||= new.freeze
      end

      def via_integral_parts a, h
        allocate.__init a, h
      end
    end  # >>

    # -- intialization & related

    def initialize
      @a = [] ; @h = {}
    end

    def __init a, h
      @a = a ; @h = h
      self
    end

    def initialize_copy _otr_
      @_algorithms = nil
      @a = @a.dup ; @h = @h.dup ; nil
    end

    def freeze
      @a.freeze ; @h.freeze ; super
    end

    # -- mutation

    def merge_box! otr  # [tm]
      a = otr.a_ ; h = otr.h_
      a.each do | k |
        if ! @h.key? k
          @a.push k
        end
        @h[ k ] = h.fetch k
      end
      NIL_
    end

    def add_or_replace k, add_p, replace_p
      had = true
      x = @h.fetch k do
        had = false
      end
      if had
        @h[ k ] = replace_p[ x ]
      else
        @a.push k
        @h[ k ] = add_p.call
      end
    end

    def replace k, x_
      had = true
      x = @h.fetch k do
        had = false
      end
      if had
        @h[ k ] = x_
        x
      else
        raise ::KeyError, _say_not_found( k )
      end
    end

    def replace_by k, & p
      had = true
      x = @h.fetch k do
        had = false
      end
      if had
        x_ = p[ x ]
        @h[ k ] = x_
        x_
      else
        raise ::KeyError, _say_not_found( k )
      end
    end

    def remove k, & else_p
      d = @a.index k
      if d
        @a[ d, 1 ] = EMPTY_A_
        @h.delete k
      elsif else_p
        else_p[]
      else
        raise ::KeyError, _say_not_found( k )
      end
    end

    def set k, x
      @h.fetch k do
        @a.push k
      end
      @h[ k ] = x ; nil
    end

    def touch_array_and_push k, x
      touch_array( k ).push x ; nil
    end

    def touch_array k
      touch( k ) { [] }
    end

    def touch k, & p
      @h.fetch k do
        @a.push k
        @h[ k ] = p.call
      end
    end

    def add_to_front k, x
      add_at_offset 0, k, x
    end

    def add k, x
      had = true
      @h.fetch k do
        @a.push k
        @h[ k ] = x
        had = false
      end
      if had
        raise ::KeyError, _say_wont_clobber( k )
      end
    end

    def add_at_offset d, k, x
      had = true
      @h.fetch k do
        @a[ d, 0 ] = [ k ]
        @h[ k ] = x
        had = false
      end
      if had
        raise ::KeyError, _say_wont_clobber( k )
      end
    end

    # -- reduction

    # ~ ..given nothing

    def first_key
      @a.first
    end

    def length
      @a.length
    end

    # ~ ..given a position

    def at_offset d
      @h.fetch key_at_offset d
    end

    def key_at_offset d
      @a.fetch d
    end

    # ~ ..given a name or names

    def has_key k
      @h.key? k
    end

    def offset_of k
      @a.index k
    end

    def at * k_a
      k_a.map( & @h.method( :[] ) )
    end

    def [] k
      @h[ k ]
    end

    def fetch k, & p
      @h.fetch k, & p
    end

    # -- mapping and visitation

    # ~ ad-hoc in-universe

    def to_collection
      Box::As__::Collection[ self ]
    end

    def to_new_mutable_box_like_proxy
      dup
    end

    def to_mutable_box_like_proxy
      self
    end

    def algorithms  # bridge to legacy
      @_algorithms ||= Box::Algorithms__.new( @a, @h, self )
    end

    # ~ ..of names

    def get_keys  # #[#bs-028.6]
      @a.dup
    end

    def each_key
      @a.each do |k|
        yield k
      end
      NIL_
    end

    def to_key_stream & p
      Stream.via_nonsparse_array @a, & p
    end

    # ~ ..of values

    def each_value
      @a.each do |k|
        yield @h.fetch k
      end
      NIL_
    end

    def to_value_minimal_stream
      d = -1 ; last = @a.length - 1
      MinimalStream.by do
        if d < last
          @h.fetch @a.fetch d += 1
        end
      end
    end

    def to_value_stream
      d = -1 ; last = @a.length - 1
      Stream.by do
        if d < last
          @h.fetch @a.fetch d += 1
        end
      end
    end

    # ~ ..of both names & values

    def each_pair
      @a.each do |k|
        yield k, @h.fetch( k )
      end
      NIL_
    end

    def to_pair_stream  # assumes your keys are symbols..

      d = -1
      last = @a.length - 1

      Stream.by do
        if d < last
          k = @a.fetch d += 1
          QualifiedKnownKnown.via_value_and_symbol @h.fetch( k ), k
        end
      end
    end

    # -- collaboration & support

    def a_
      @a
    end

    def h_
      @h
    end

    def _say_wont_clobber k
      "won't clobber existing '#{ k }'"
    end

    def _say_not_found k
      "key not found: #{ k.inspect }"
    end

    def box
      self
    end
    # #tombstone: Box::InstanceMethods (barely a thing)
  end

  # ==

  MinimalStream = ::Class.new ::Proc

  class Stream < MinimalStream  # :[#016.2] (see)

    class << self

      def define & p
        Stream::Magnetics::ResourceReleasingStream_via[ p, self ]
      end

      def via_range r, & map
        Stream::Magnetics::Stream_via_Range[ map, r, self ]
      end

      def via_times d, & map
        Stream::Magnetics::Stream_via_Times[ map, d, self ]
      end

      def via_item x
        once() { x }
      end

      def once & prc
        p = -> do
          p = EMPTY_P_
          prc[]
        end
        by() { p[] }
      end

      def via_nonsparse_array a, & map
        d = -1 ; last = a.length - 1
        st = by do
          if d < last
            a.fetch d += 1
          end
        end
        if block_given?
          st.map_reduce_by( & map )
        else
          st
        end
      end
    end  # >>

    def initialize upst=nil, & p
      @upstream = upst
      super( & p )
    end

    attr_reader :upstream

    InstanceMethods = ::Module.new
    include InstanceMethods
  end

  module Stream::InstanceMethods

    # NOTE all of the below methods mutate the receiver - they all flush

    # -- flushers that convert to other paradigms (box, scanner, enumerator)

    # ~ see also simliar-looking dedicated children nodes that build lazily

    def flush_to_box_keyed_to_method m  # 5x
      reduce_into Box.new do |bx|
        -> x do
          bx.add x.send( m ), x
        end
      end
    end

    def flush_to_NO_DEPS_ZERK_scanner  # #open [#ze-068]
      ::NoDependenciesZerk::Scanner_by.new do
        call
      end
    end

    def flush_to_scanner
      Stream::Magnetics::Scanner_via_Stream[ self ]
    end

    def each
      begin
        x = gets
        x || break
        yield x
        redo
      end while above
    end

    def flush_to_count  # 3x
      _reduce_classically( 0 ) { |memo| memo + 1 }
    end

    def flush_to_last  # 2x
      _reduce_classically( NOTHING_ ) { |_memo, x| x }
    end

    # -- flushers that produce new streams

    # ~ expand: produce a new stream that is longer thru flushing
    #   see also [#016.3] compound stream

    def expand_by  # 37x
      p = nil ; st = nil ; main = nil
      advance = -> do
        begin
          o = gets
          o or ( p = EMPTY_P_ and break )
          st = yield o
          st || redo
          x = st.gets
          x || redo
          p = main
          break
        end while above
        x
      end
      main = -> do
        x = st.gets
        x or ( p = advance )[]
      end
      p = advance
      new_by do
        p[]
      end
    end

    # ~ produce a new stream that is mapped and reduced

    def map_reduce_by  # 22x
      new_by do
        begin
          x = gets
          x || break
          x_ = yield x
        end until x_
        x_
      end
    end

    # ~ reduce in the classical sense: shorten the stream based on some criteria

    def reduce_by & p  # 35x
      new_by do
        begin
          x = gets
          x || break
        end until yield x
        x
      end
    end

    # ~ produce a new stream that is mapped. (doesn't reduce - falsish interrupts)

    def map_by  # 100+
      new_by do
        x = gets
        if x
          yield x
        end
      end
    end

    # ~ result is memo after receiveing every item with `<<`, interspersed
    #   with the separator. the stream equivalent of `ary.join(" and ")`

    def join_into_with_by memo, separator  # 6x
      main = -> x do
        memo << separator
        memo << yield( x )
      end
      p = -> x do
        memo << yield( x )
        p = main
      end
      reduce_into( memo ) { -> x { p[ x ] } }
    end

    def to_a  # 50+?
      join_into []
    end

    # ~ result is memo after receiving every item with `<<`

    def join_into memo, & map  # 11x
      map ||= IDENTITY_
      reduce_into memo do
        -> x do
          memo << map[ x ]
        end
      end
    end

    # ~ result is memo after traversing the stream with whatever proc is yielded

    def reduce_into memo  # 3x here, 1x there
      p = yield memo
      begin
        x = gets
        x || break
        p[ x ]
        redo
      end while above
      memo
    end

    # ~ experiment

    def _reduce_classically memo
      begin
        x = gets
        x || break
        memo = yield memo, x
        redo
      end while above
      memo
    end

    # ~ result is the map of any first item whose map is trueish

    def flush_until_map_detect  # ONEx [ts]
      begin
        x = gets
        x || break
        x_ = yield x
      end until x_
      x_
    end

    # ~ result is any first item whose map is trueish

    def flush_until_detect  # 12x
      begin
        x = gets
        x || break
      end until yield x
      x
    end

    # -- support

    def new_by & p
      self.class.by @upstream, & p
    end
  end

  module THE_EMPTY_STREAM ; class << self
    include Stream::InstanceMethods
    def gets
      NOTHING_
    end
    def new_by
      self  # when mapping, reducing, expanding, never do anything
    end
  end ; end

  module THE_EMPTY_MINIMAL_STREAM ; class << self
    def gets
      NOTHING_
    end
  end ; end

  class MinimalStream  # exactly [#016.1]
    class << self
      alias_method :by, :new
      undef_method :new
    end
    alias_method :gets, :call  # `call` is left defined for [#060.1] (no deps)
  end

  # ==

  module THE_EMPTY_SCANNER ; class << self
    def no_unparsed_exists
      true
    end
  end ; end

  class Scanner  # :[#069]., #[#069]

    class << self

      def via * x_a
        new 0, x_a
      end

      def via_array x_a
        new 0, x_a
      end

      alias_method :via_start_index_and_array, :new
      private :new
    end  # >>

    def reinitialize d, x_a
      @d = d ; @x_a = x_a ; @x_a_length = x_a.length
    end

    alias_method :initialize, :reinitialize

    def flush_remaining_to_array
      x = @x_a[ @d .. -1 ]
      @d = @x_a_length
      x
    end

    def flush_to_each_pairer
      p = -> & yield_p do
        while unparsed_exists
          yield_p[ gets_one, gets_one ]
        end
      end
      p.singleton_class.send :alias_method, :each_pair, :call  # while etc
      p
    end

    def gets_last_one
      x = gets_one
      assert_empty
      x
    end

    def assert_empty
      if unparsed_exists
        raise ::ArgumentError, ___say_unexpected
      end
    end

    def ___say_unexpected
      "unexpected: #{ Home_.lib_.basic::String.via_mixed head_as_is }"
    end

    def flush_to_stream
      Stream.by do
        if unparsed_exists
          gets_one
        end
      end
    end

    def gets_one
      x = head_as_is
      advance_one
      x
    end

    def no_unparsed_exists
      @x_a_length == @d
    end

    def unparsed_exists
      @x_a_length != @d
    end

    def unparsed_count
      @x_a_length - @d
    end

    def head_as_is
      @x_a.fetch @d
    end

    def previous_token
      @x_a.fetch @d - 1
    end

    def current_index
      @d
    end

    def advance_one
      @d += 1 ; nil
    end

    def current_index= d  # assume is valid index
      @d = d
    end

    # ~ hax (for "collaborators")

    # ~~ experimental "from end" parsing for [#hu-053]

    def random_access_ d  # negative only for now
      if d < 0
        d_ = @x_a_length + d
        if 0 <= d_
          @x_a.fetch d_
        end
      end
    end

    def pop_
      @x_a.fetch( @x_a_length -= 1 )
    end

    def backtrack_one
      @d.zero? and raise ::IndexError
      @d -= 1
      NIL_
    end

    def reverse_advance_one_
      @x_a_length -= 1
      nil
    end

    def array_for_read
      @x_a
    end

    attr_accessor :x_a_length
  end

  module Pair  # :[#055].
    class << self
      def via_value_and_name x, nm
        ValueAndNamePair___.new x, nm
      end
      def via_value_and_name_symbol x, sym
        ValueAndNameSymbolPair___.new x, sym
      end
    end  # >>
    CommonPair__ = ::Class.new
    class ValueAndNamePair___ < CommonPair__
      def initialize x, nm
        @name = nm
        super x
      end
      attr_reader :name
    end
    class ValueAndNameSymbolPair___ < CommonPair__
      def initialize x, sym
        @name_symbol = sym
        super x
      end
      attr_reader :name_symbol
    end
    class CommonPair__
      def initialize x
        @value = x
      end
      def new_with_value x
        self.class.new x, name_symbol
      end
      attr_reader :value
    end
  end

  class BoundCall  # :[#059].

    class << self

      def by & p
        new nil, p, :call
      end

      def the_empty_call
        @tec ||= new EMPTY_P_, :call
      end

      def via_args_and_method_name a, mn, & p
        new a, nil, mn, & p
      end

      def via_receiver_and_method_name rc, mn, & p
        new nil, rc, mn, & p
      end

      def via_value x, & p
        new nil, -> { x }, :call, & p
      end

      alias_method :[], :new
      private :new
    end  # >>

    def initialize args, receiver, method_name, & p  # volatility order (subjective)
      @args = args
      @block = p
      @method_name = method_name
      @receiver = receiver
    end

    attr_reader :args, :block, :method_name, :receiver
  end

  # == knownnesses (see [#004])

  class QualifiedKnownness

    class << self

      def via_value_and_had_and_association x, yes, asc
        if yes
          QualifiedKnownKnown.via_value_and_association x, asc
        else
          QualifiedKnownUnknown.via_association asc
        end
      end

      private :new
    end  # >>
  end

  KnownUnknownMethods__ = ::Module.new
  KnownKnownMethods__ = ::Module.new

  class QualifiedKnownKnown < QualifiedKnownness
    include KnownKnownMethods__

    class << self

      def via_value_and_symbol x, sym
        new( x )._init_via_symbol sym
      end

      def via_value_and_association x, asc
        new( x )._init_via_association asc
      end

      alias_method :[], :via_value_and_association  # use IFF it's clear
      private :new
    end  # >>

    def initialize x
      @value = x
    end

    def new_with_value x  # stay close to #here1
      # YUCK
      if instance_variable_defined? :@_association
        self.class.via_value_and_association x, @_association
      else
        self.class.via_value_and_symbol x, @_name_symbol
      end
    end

    def to_unknown
      QualifiedKnownUnknown.via_association @_association  # ..
    end

    def to_knownness
      KnownKnown[ @value ]
    end
  end

  class QualifiedKnownUnknown < QualifiedKnownness
    include KnownUnknownMethods__

    class << self

      def via_symbol sym
        new._init_via_symbol sym
      end

      def via_association asc
        new._init_via_association asc
      end
    end  # >>

    def new_with_value x  # stay close to #here1
      QualifiedKnownKnown.via_value_and_association x, @_association  # ..
    end

    def to_knownness
      KNOWN_UNKNOWN
    end
  end

  class QualifiedKnownness

    def _init_via_symbol sym
      @association = :__association_via_name_symbol_ONCE
      @name_symbol = :_name_symbol
      @_name_symbol = sym ; self
    end

    def _init_via_association asc
      @name_symbol = :_name_symbol_via_association
      @association = :_association
      @_association = asc
      freeze
    end

    def name
      # :[#004.3.1]: for a thing to be an "association" it must expose a [#060] name with:
      association.name
    end

    def association
      send @association
    end

    def name_symbol
      send @name_symbol
    end

    def __association_via_name_symbol_ONCE
      @association = :_association
      @_association = Home_.lib_.basic::MinimalProperty.via_variegated_symbol(
        remove_instance_variable :@_name_symbol )
      @name_symbol = :_name_symbol_via_association
      freeze
      send @association
    end

    def _association
      @_association
    end

    def _name_symbol_via_association
      # :[#004.3.2]: for a thing to be an "association" it must:
      @_association.name_symbol
    end

    def _name_symbol
      @_name_symbol
    end

    def is_qualified
      true
    end
  end

  UnqualifiedKnownness__ = ::Class.new

  class KnownKnown < UnqualifiedKnownness__
    include KnownKnownMethods__

    class << self

      def yes_or_no x
        x ? trueish_instance : falseish_instance
      end

      def falseish_instance
        @___falseish_instance ||= new false
      end

      def trueish_instance
        @___trueish_instance ||= new true
      end

      alias_method :[], :new
      private :new
    end  # >>

    def initialize x
      @value = x
    end

    def to_qualified_known_around asc
      QualifiedKnownKnown.via_value_and_association @value, asc
    end

    def new_with_value x
      self.class[ x ]
    end
  end

  class KnownUnknown < UnqualifiedKnownness__
    include KnownUnknownMethods__

    class << self
      alias_method :via_reasoning, :new
      private :new
    end

    def initialize x
      @reasoning = x
    end

    def to_qualified_known_around asc
      QualifiedKnownUnknown.via_association asc
    end

    attr_reader(
      :reasoning,
    )
  end
  KNOWN_UNKNOWN = KnownUnknown.via_reasoning nil

  class UnqualifiedKnownness__

    def is_qualified
      false
    end
  end

  module KnownUnknownMethods__

    def is_effectively_trueish
      false
    end

    def is_effectively_known
      false
    end

    def is_known_known
      false
    end
  end

  module KnownKnownMethods__

    def is_effectively_trueish
      @value
    end

    def is_effectively_known
      ! @value.nil?
    end

    attr_reader :value

    def is_known_known
      true
    end
  end

  # ==

  Without_extension = -> path do
    path[ 0 ... path.rindex( DOT_ ) ]
  end

  DOT_ = '.'

  DIR_PATH__ = Without_extension[ __FILE__ ]

  Lazy = -> & p do  # etc
    x = nil ; yes = true
    -> do
      if yes
        yes = false
        x = p[]
      end
      x
    end
  end
  Lazy_ = Lazy  # for use by this sidesystem

  module Autoloader  # [#024]

    class << self

      def [] mod, * x_a, & p

        if x_a.length.nonzero? || block_given?
          Autoloaderization___.new( mod, x_a, & p ).execute
        else
          mod.respond_to? NODE_PATH_METHOD_ and raise Here_::Say_::Not_idempotent[ mod ]
          mod.extend Methods__
        end
        mod
      end

      alias_method :call, :[]

      def const_reduce cp, fm, & p
        const_reduce_by do |o|
          o.from_module = fm
          o.const_path = cp
          o.receive_name_error_by = p
        end
      end

      def const_reduce_by
        Here_::Value_via_ConstPath.call_by do |o|
          yield o
          o.file_tree_cache_by = File_tree_cache__
        end
      end

      # --

      def at *a
        @at_h ||= {}
        a.map { |i| @at_h.fetch( i ) { @at_h[ i ] = method i } }
      end

      def build_require_sidesystem_proc * i_a  # #open [#053]
        _build_require_proc i_a do |x|
          Memoize.call do
            require_sidesystem x
          end
        end
      end

      def build_require_stdlib_proc * i_a
        _build_require_proc i_a do |x|
          Memoize.call do
            require_stdlib x
          end
        end
      end

      def _build_require_proc i_a, & p
        case i_a.length <=> 1
        when -1 ; p
        when  0 ; p[ i_a.first ]
        when  1 ; i_a.map( & p.method( :call ) )
        end
      end

      def require_quietly const_i_or_path_s
        __without_warning do
          if VALID_CONST_RX_ =~ const_i_or_path_s
            require_stdlib const_i_or_path_s
          else
            require const_i_or_path_s
          end
        end
      end

      def __without_warning
        prev = $VERBOSE ; $VERBOSE = nil
        r = yield  # 'ensure' is out of scope
        $VERBOSE = prev ; r
      end

      define_method :require_sidesystem, -> do

        universal_top_level_entry = "skylab"

        require_via_const = -> const_sym do  # assume not loaded

          _name_function = Name.via_const_symbol const_sym
          _loadable_slug = _name_function.as_lowercase_with_underscores_string
          _load_path = ::File.join universal_top_level_entry, _loadable_slug

          require _load_path
        end

        produce_via_const = -> const_i do
          if ! ::Skylab.const_defined? const_i, false
            require_via_const[ const_i ]
          end
          ::Skylab.const_get const_i, false
        end

        require_sidesystem = -> * i_a do

          case i_a.length <=> 1
          when -1 ; require_sidesystem
          when  0 ; produce_via_const[ i_a.first ]
          else    ; i_a.map( & produce_via_const )
          end
        end
      end.call

      def require_stdlib const_i
        require const_i.downcase.to_s  # until it's useful to, no inflection
        ::Object.const_get const_i
      end
    end  # >>

    class Autoloaderization___

      def initialize mod, x_a, & p
        @arguments = x_a
        @autoloaderized_parent_module = nil
        @block = p
        @do_boxxy = nil
        @do_extend_methods = nil
        @FS_entry_string = nil
        @mod = mod
        @path = nil
      end

      def execute
        x_a = remove_instance_variable :@arguments
        if x_a
          __process_argument_array x_a
        end
        p = remove_instance_variable :@block
        if p
          p[ self ]
        end
        __apply
        NIL
      end

      def __process_argument_array x_a

        @argument_scanner = Scanner.via_array x_a

        if @argument_scanner.head_as_is.respond_to? :ascii_only?
          __when_path
        end

        until @argument_scanner.no_unparsed_exists
          send PROCESS_WHICH___.fetch @argument_scanner.gets_one
        end
        NIL
      end

      def __when_path
        @do_extend_methods = true
        @path = @argument_scanner.gets_one
      end

      PROCESS_WHICH___ = {
        boxxy: :__when_boxxy,
        methods: :__when_methods,
        autoloaderized_parent_module: :__when_autoloaderized_parent_module,
      }

      def __when_autoloaderized_parent_module
        @do_extend_methods = true
        @autoloaderized_parent_module = @argument_scanner.gets_one
        NIL
      end

      def __when_boxxy
        @do_boxxy = true
      end

      def __when_methods
        @do_extend_methods = true
      end

      def _filesystem_entry_string= x
        @do_extend_methods = true
        @FS_entry_string = x
      end

      # ~

      def __apply

        autoloaderized_parent_module = @autoloaderized_parent_module
        do_boxxy = @do_boxxy ; do_extend_methods = @do_extend_methods
        fs_entry = @FS_entry_string
        path = @path

        @mod.module_exec do

          if do_extend_methods
            extend Methods__
          end

          if autoloaderized_parent_module
            @_pedigree = Here_::ComponentModels__::Pedigree.
              via_module_and_parent_module__(
                self, autoloaderized_parent_module )
          end

          if path
            fs_entry and raise ::ArgumentError
            instance_variable_defined? :@dir_path and self._SANITY
            @dir_path = path

          elsif fs_entry
            @_entry_name = Name.via_slug fs_entry
          end

          if do_boxxy
            @boxxy_original_constants_method_ = method :constants  # [#030] #note=1

            if ! respond_to? NODE_PATH_METHOD_
              extend Methods__
            end

            extend BoxxyMethods____
          end
        end
        NIL
      end
    end

    Here_ = self
    NODE_PATH_METHOD_ = :dir_path

    module BoxxyMethods____

      def constants
        boxxy_module_as_feature_branch.boxxy_enhanced_constants_
      end

      def const_missing sym

        # $i += 1 ; $stderr.puts "(BL:#{ DBG_NUM_FORMAT_ % $i } #{ self }::#{ sym })"

        nv = boxxy_module_as_feature_branch.name_and_value_for_const_missing_ sym
        if nv
          nv.const_value
        else
          super
        end
      end

      def boxxy_const_guess_via_slug slug

        # we suggest the equivalent to either `as_const` or `as_camelcase_const_string`

        NOTHING_  # take default
      end

      def boxxy_module_as_feature_branch
        @___boxxy_OB ||= Here_::Boxxy_::FeatureBranch_via_Module[ self ]
      end

      attr_reader(
        :boxxy_original_constants_method_
      )
    end

    module Methods__

      Here_[ Here_ ]  # our own dogfood - as soon as this module is defined

      # -- autoloader writing

    private

      def stowaway const_sym, relative_path
        ( @stowaway_hash_ ||= {} )[ const_sym ] = relative_path
      end

      def lazily const_sym, & definition
        ( @stowaway_hash_ ||= {} )[ const_sym ] = definition
      end

    public
      attr_reader :stowaway_hash_  # :[#031]

      # -- autoload "reading"

      def const_missing x  # accept symbol or string

        # $i += 1 ; $stderr.puts "(AL:#{ DBG_NUM_FORMAT_ % $i } #{ self }::#{ x })"

        nv = Here_::ConstMissing_.new( x, self ).execute
        if nv
          nv.const_value
        else
          super
        end
      end

      def entry_tree
        kn = ( @___entry_tree_knownness ||= __entry_tree_knownness )
        if kn.is_known_known
          kn.value
        end
      end

      def __entry_tree_knownness
        x = Here_::FileTree_::Via_module.new( self, File_tree_cache__ ).execute
        x ? KnownKnown[ x ] : KNOWN_UNKNOWN
      end

      def parent_module
        pedigree_.parent_module__
      end

      def pedigree_
        @_pedigree ||= Here_::ComponentModels__::Pedigree.via_module__ self
      end

      def dir_path
        @___dir_path_is_known_is_known ||= Here_::ComponentModels__::Touch_dir_path[ self ]
        @dir_path  # can be nil
      end
    end

    File_tree_cache__ = Lazy_.call do
      Here_::FileTree_::Cache[ ::Dir ]
    end

    Is_probably_module = -> x do
      x.respond_to? :module_exec
    end

    dir = ::File.join DIR_PATH__, 'autoloader'
    autoload :ComponentModels__, ::File.join( dir, 'component-models--' )
    autoload :ConstMissing_, ::File.join( dir, 'const-missing-' )
    autoload :FileTree_, ::File.join( dir, 'file-tree-' )
    autoload :Say_, ::File.join( dir, 'say-' )

    CorrectConst_ = ::Struct.new :const_value, :correct_const_symbol

    EXTNAME = '.rb'.freeze

    CORE_ENTRY_STEM = 'core'.freeze
    CORE_FILE = "#{ CORE_ENTRY_STEM }#{ EXTNAME }".freeze
    DEBUG_IO_ = $stderr
    DO_DEBUG_ = false
    DOT_DOT_ = '..'
    NameError = ::Class.new ::NameError
    NODE_PATH_IVAR_ = :@dir_path
  end

  Autoloader[ Scanner ]
  Autoloader[ Box ]
  Autoloader[ Stream ]

  class Name  # see [#060]

    class << self

      # -- "library" nodes

      def labelize * a
        if a.length.zero?
          Name::Modality_Functions::Labelize
        else
          Name::Modality_Functions::Labelize[ * a ]
        end
      end

      def lib
        Home_::Name__
      end

      def module_moniker * a
        if a.length.zero?
          Home_::Name__::Unique_Features::Module_moniker
        else
          Name::Modality_Functions::Module_moniker[ * a ]
        end
      end

      def empty_name_for__ x
        Name::ConversionFunctions::Empty_name_for[ x ]
      end
    end  # >>

    # -- higher-level derivatives (for [#ac-007] expressive events usually)

    def express_into_under y, expag  # #hook-out [#br-023]
      name = self
      expag.calculate do
        y << nm( name )
      end
      KEEP_PARSING_
    end

    def description_under _expag
      as_human
    end

    def description
      as_slug
    end

    def name  # use a name object as a mock for something else
      self
    end

    TRAILING_DASHES_RX = /-+\z/  # was once used here, now no longer

    Autoloader[ self ]
  end

  same = Name  # common base class

  class Const_Name < same

    Here_ = self
    class Home_::Name
      class << self

        def via_module mod
          via_module_name mod.name
        end

        def via_module_name s

          d = s.rindex CONST_SEPARATOR
          if d
            s = s[ d + 2 .. -1 ]
          end
          Here_._via_normal_string_ s
        end

        def via_const_symbol const_sym
          via_const_string const_sym.id2name
        end

        def via_const_string s

          if VALID_CONST_RX_ =~ s
            Here_._via_normal_string_ s
          else
            raise Autoloader::NameError, Here_::Say_::Wrong_const_name[ s ]
          end
        end

        def via_valid_const_string_ s
          Here_._via_normal_string_ s
        end
      end  # >>

      def as_const_symbol= sym  # #experimental (as #here)
        o = _center_name_
        if o.instance_variable_defined? :@_const
          o.instance_variable_get( :@_const ).as_const_symbol = sym
        else
          o.__receive_const_when_none sym
          sym
        end
      end

      def as_camelcase_const_string
        o = _const
        o && o.as_camelcase_const_string
      end

      def AS_CONST_STRING
        o = _const
        o && o.AS_CONST_STRING
      end

      def as_const
        o = _const
        o && o.as_const
      end

      def as_approximation
        o = _const
        o && o.as_approximation
      end

      def _const
        _center_name_.__const_when_center_name
      end

      def __const_when_center_name
        @_did_attempt_const ||= __attempt_const
        @_const
      end

      def __attempt_const
        @_const = Here_._via_center_name_ self
        ACHIEVED_
      end

      def __receive_const_when_none sym
        @_did_attempt_const = true
        @_const = Here_.via_const_symbol sym ; nil
      end
    end

    def _interpret_

      _titlecase_the_pieces
      _join_using_ UNDERSCORE_

      # certainly not all names isomorph into valid consts (covered)

      if VALID_CONST_RX_ !~ @x_
        @x_ = false
      end
    end

    def _express_

      # break up the const string into universally normal pieces

      # for each trailing underscore, we want one trailing empty string

      s_a = @surface_value_.split SPLITTER_RX___, -1

      # downcase the piece IFF it doesn't look like an acroynym

      s_a.each do | s |
        s.gsub! DOWNCASER_RX___, & :downcase
      end

      s_a
    end

    def as_camelcase_const_string
      @___camelcase_string ||= ___build_camelcase_string
    end

    def ___build_camelcase_string  # covered

      @x_ = _center_name_._deep_value_

      d = 0
      while @x_.last.length.zero?
        @x_.pop
        d += 1
      end

      _titlecase_the_pieces

      _join_using_ EMPTY_S_

      if d.nonzero?
        @x_.concat UNDERSCORE_ * d
      end

      remove_instance_variable :@x_
    end

    def as_const_symbol= sym
      @surface_value_as_symbol_ = sym
    end

    def as_const  # symbol
      @surface_value_as_symbol_ ||= @surface_value_.intern
    end

    def AS_CONST_STRING
      @surface_value_
    end

    def as_approximation

      @___approximation ||= Distill[ @surface_value_ ]
    end

    def _titlecase_the_pieces
      @x_ = @x_.map do | s |
        s.sub UPCASER_RX___, & :upcase
      end ; nil
    end

    DOWNCASER_RX___ = /[A-Z](?=[a-z])/
    SPLITTER_RX___ = /(?<=[a-z])(?=[A-Z])|_/
    UPCASER_RX___ = /\A[a-z]/
  end

  VALID_CONST_RX_ = /\A[A-Z][a-z_A-Z0-9]*\z/

  class Lowercase_with_Underscores____ < same

    Here_ = self
    class Home_::Name
      class << self

        def via_lowercase_with_underscores_string s
          Here_._via_normal_string_ s
        end

        def via_lowercase_with_underscores_symbol sym
          Here_._via_normal_symbol_ sym
        end
      end  # >>

      def as_lowercase_with_underscores_symbol
        _LwU.as_lowercase_with_underscores_symbol
      end

      def as_lowercase_with_underscores_string
        _LwU.as_lowercase_with_underscores_string
      end

      def _LwU
        _center_name_.___LwU_when_center_name
      end

      def ___LwU_when_center_name
        @___LwU ||= Here_._via_center_name_ self
      end
    end

    def _interpret_
      _no_trailing_separators_
      _join_using_ UNDERSCORE_
      _downcase_
    end

    def _express_
      @surface_value_.split UNDERSCORE_  # NOTE trailing separators lost
    end

    def as_lowercase_with_underscores_symbol
      @surface_value_as_symbol_ ||= @surface_value_.intern
    end

    def as_lowercase_with_underscores_string
      @surface_value_
    end
  end

  class Human____ < same

    Here_ = self
    class Home_::Name
      class << self

        def via_human s
          Here_._via_normal_string_ s
        end
      end  # >>

      def as_human
        _center_name_.___human_when_center_name.as_human
      end

      def ___human_when_center_name
        @___human ||= Here_._via_center_name_ self
      end
    end  # >>

    def _interpret_
      _no_trailing_separators_
      _join_using_ SPACE_
    end

    def _express_
      @surface_value_.split SPACE_
    end

    def as_human
      @surface_value_
    end
  end

  class Slug < same

    Here_ = self
    class Home_::Name
      class << self

        def via_slug s
          Here_._via_normal_string_ s
        end
      end  # >>

      def as_slug= s  # #experimental (:#here)
        o = _center_name_
        if o.instance_variable_defined? :@_slug
          o._slug_when_center_name.as_slug = s
        else
          o.instance_variable_set :@_slug, Here_.via_slug( s )  # ..
        end
      end

      def as_slug
        _center_name_._slug_when_center_name.as_slug
      end

      def _slug_when_center_name
        @_slug ||= Here_._via_center_name_ self
      end
    end  # >>

    def _interpret_
      # NOTE slugs preserve trailing "separators"
      _join_using_ DASH_
      _downcase_
    end

    def _express_
      @surface_value_.split DASH_, -1  # NOTE keep trailing separators
    end

    def as_slug= s
      @surface_value_ = s
    end

    def as_slug
      @surface_value_
    end
  end

  class Variegated_Name____ < same

    Here_ = self
    class Home_::Name
      class << self

        def via_variegated_string s
          Here_._via_normal_string_ s
        end

        def via_variegated_symbol sym
          Here_._via_normal_symbol_ sym
        end
      end  # >>

      def as_ivar
        _vari.as_ivar
      end

      def as_parts
        _vari.as_parts
      end

      def as_variegated_string
        _vari.as_variegated_string
      end

      def name_symbol  # work with [fi] events
        as_variegated_symbol
      end

      def as_variegated_symbol
        _vari.as_variegated_symbol
      end

      def _vari
        _center_name_.___variegated_when_center_name
      end

      def ___variegated_when_center_name
        @___variegated ||= Here_._via_center_name_ self
      end
    end

    def _interpret_
      _no_trailing_separators_
      _join_using_ UNDERSCORE_
    end

    def _express_

      # perserve trailing separators IFF they were in the original symbol [sg]

      @surface_value_.split UNDERSCORE_, -1
    end

    def as_ivar= x
      @_ivar = x
    end

    def as_ivar
      @_ivar ||= :"@#{ @surface_value_ }"
    end

    def as_parts
      _center_name_._deep_value_
    end

    def as_variegated_string
      @surface_value_  # eek
    end

    def as_variegated_symbol
      @surface_value_as_symbol_ ||= @surface_value_.intern
    end
  end

  class Name  # re-open as common base

    class << self

      def _via_center_name_ nm
        new.__via_center_name nm
      end

      def _via_normal_string_ s
        new.finish_via_normal_string s
      end

      def _via_normal_symbol_ sym
        new.finish_via_normal_symbol sym
      end

      private :new
    end  # >>

    def initialize
      @_center_name_via = :__center_name_when_unknown
    end

    def __via_center_name nm

      @x_ = nm._deep_value_
      self._interpret_
      x = remove_instance_variable :@x_
      if x
        @surface_value_ = x
        @_center_name_via = :__center_name_via_ivar
        @_center_name = nm
        self
      else
        x  # cannot produce a name for this context from this stem
      end
    end

    def finish_via_normal_symbol sym
      @surface_value_as_symbol_ = sym
      finish_via_normal_string sym.id2name
    end

    def finish_via_normal_string s
      @surface_value_ = s ; self
    end

    def _center_name_
      send @_center_name_via
    end

    def __center_name_when_unknown
      x = _express_
      x or fail
      @deep_value_ = x
      @_center_name_via = :__center_name_via_self
      self
    end

    def __center_name_via_self
      self
    end

    def __center_name_via_ivar
      @_center_name
    end

    def _deep_value_
      @deep_value_
    end

    def _no_trailing_separators_  # assume at least 1 piece, not all empty

      if @x_.last.length.zero?
        s_a = @x_.dup
        begin
          s_a.pop
          if s_a.last.length.zero?
            redo
          end
          break
        end while nil
        @x_ = s_a
      end
      NIL_
    end

    def _join_using_ s
      @x_ = @x_.join s ; nil
    end

    def _downcase_
      @x_ = @x_.downcase ; nil
    end
  end

  # -- done

  Attributes_actor_ = -> cls, * a do
    Home_.lib_.fields::Attributes::Actor.via cls, a
  end

  Const_value_via_parts = -> x_a do  # :+[#ba-034]
    x_a.reduce ::Object do |mod, x|
      mod.const_get x, false
    end
  end

    DASH_ = '-'.freeze
    UNDERSCORE_ = '_'.freeze

  Distill = -> do  # [#026]:#the-distill-function  :+[#bm-002]
    black_rx = /[-_ ]+(?=[^-_])/  # preserve final trailing underscores & dashes
    dash = DASH_.getbyte 0
    empty_s = ''.freeze
    undr = UNDERSCORE_.getbyte 0
    -> x do
      s = x.to_s.gsub black_rx, empty_s
      d = 0 ; s.setbyte d, undr while dash == s.getbyte( d -= 1 )
      s.downcase.intern
    end
  end.call

  Memoize = -> & p do
    p_ = -> do
      x = p[]
      p_ = -> { x }
      x
    end
    -> do
      p_[]
    end
  end

  define_singleton_method :memoize, Memoize

  # --

  build_oxford = -> const do

    _proto = Home_.lib_.human::NLP::EN.const_get( const, false ).call
    exp = _proto.redefine do |o|
      o.express_none_by { '[none]' }
    end

    -> a do
      exp.with_list( a ).say
    end
  end

  oxford_and = -> aa do
    oxford_and = build_oxford[ :Oxford_AND_prototype ]
    oxford_and[ aa ]
  end

  oxford_or = -> aa do
    oxford_or = build_oxford[ :Oxford_OR_prototype ]
    oxford_or[ aa ]
  end

  Oxford_and = -> a do
    oxford_and[ a ]
  end

  Oxford_or = -> a do
    oxford_or[ a ]
  end

  # --

  module Lib_  # #[#ss-001]

    sidesys = Autoloader.build_require_sidesystem_proc

    Stdlib_option_parser = -> do
      require 'optparse'
      ::OptionParser
    end

    strange = Lazy_.call do

      _LENGTH_OF_A_LONG_LINE = 120
      o = Basic[]::String.via_mixed.dup
      o.max_width = _LENGTH_OF_A_LONG_LINE
      o.to_proc
    end

    Strange = -> x do
      strange[][ x ]
    end

    StringScanner = Lazy_.call do
      require 'strscan'
      ::StringScanner
    end

    System = -> do
      System_lib[].services
    end

    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
    Fields = sidesys[ :Fields ]
    Human = sidesys[ :Human ]
    Parse = sidesys[ :Parse ]
    Plugin = sidesys[ :Plugin ]
    System_lib = sidesys[ :System ]
    Test_support = sidesys[ :TestSupport ]
  end

  # --

      # #todo
      # $i = 0 ; DBG_NUM_FORMAT_ = "%3i"  # #todo

  ACHIEVED_ = true
  CONST_SEPARATOR = '::'.freeze
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> { NOTHING_ }  # to say hi
  EMPTY_S_ = ''.freeze  # think of all the memory you'll save
  KEEP_PARSING_ = true
  IDENTITY_ = -> x { x }
  NIL_ = nil
  NIL = nil  # #open [#sli-116.C]
  NILADIC_TRUTH_ = -> { true }
  NOTHING_ = nil

  SPACE_ = ' '.freeze
  UNABLE_ = false

  Autoloader[ self, DIR_PATH__ ]
  # #dogfood
end
# #tombstone-A: `try_convert` for scanner
