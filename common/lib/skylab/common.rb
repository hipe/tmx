module Skylab ; end

module Skylab::Common

  class << self

    def [] mod, * x_a
      self::Bundles.edit_module_via_mutable_iambic mod, x_a
    end

    def const_sep
      CONST_SEP_
    end

    def describe_into_under y, expag
      y << "(as a reactive node, [co] is some ancient artifact..)"
    end

    def distill * a
      if a.length.zero?
        Distill_
      else
        Distill_[ * a ]
      end
    end

    def lib_
      @___lib ||= produce_library_shell_via_library_and_app_modules self::Lib_, self
    end

    # memoize defined below

    def produce_library_shell_via_library_and_app_modules lib_mod, app_mod
      Home_::Librication__[ lib_mod, app_mod ]
    end

    def stream( & p )
      Home_::Stream.new( & p )
    end

    def test_support  # #[#ts-035]
      if ! Home_.const_defined? :TestSupport
        require_relative '../../test/test-support'
      end
      Home_::TestSupport
    end
  end  # >>

  module Actor  # see [#fi-016] the actor narrative

    module ProcLike
      def call * a, & p
        new( * a, & p ).execute
      end
      alias_method :[], :call
    end

    class Dyadic
      class << self
        def _call x, y, & p
          new( x, y, & p ).execute
        end
        alias_method :[], :_call
        alias_method :call, :_call
        private :new
      end  # >>
    end

    class Monadic
      class << self
        def _call x, & p
          new( x, & p ).execute
        end
        alias_method :[], :_call
        alias_method :call, :_call
        private :new
      end  # >>
    end
  end

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

    def add_to_front k, x
      had = true
      @h.fetch k do
        @a[ 0, 0 ] = [ k ]
        @h[ k ] = x
        had = nil
      end
      if had
        raise ::KeyError, _say_wont_clobber( k )
      end
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

    def add k, x
      had = true
      @h.fetch k do
        had = false
        @a.push k
        @h[ k ] = x ; nil
      end
      if had
        raise ::KeyError, _say_wont_clobber( k )
      end
    end

    # -- reduction

    # ~ ..given nothing

    def first_name
      @a.first
    end

    def length
      @a.length
    end

    # ~ ..given a position

    def at_position d
      @h.fetch name_at_position d
    end

    def name_at_position d
      @a.fetch d
    end

    # ~ ..given a name or names

    def has_name k
      @h.key? k
    end

    def index k
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

    def get_names  # #[#bs-028]B
      @a.dup
    end

    def each_name
      @a.each do |k|
        yield k
      end
      NIL_
    end

    def to_name_stream
      Home_::Stream.via_nonsparse_array @a
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
      Scn.new do
        if d < last
          @h.fetch @a.fetch d += 1
        end
      end
    end

    def to_value_stream
      d = -1 ; last = @a.length - 1
      Home_.stream do
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

    def to_pair_stream

      d = -1
      last = @a.length - 1

      Home_.stream do
        if d < last
          k = @a.fetch d += 1
          Pair.via_value_and_name @h.fetch( k ), k
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
  end

  class Polymorphic_Stream  # mentor :[#fi-034]

    class << self

      def the_empty_polymorphic_stream
        @__teps ||= via_array EMPTY_A_
      end

      def try_convert x  # :+[#056]

        if x.respond_to? :gets

          x.flush_to_polymorphic_stream  # while it works..

        elsif x.respond_to? :each_index
          via_array x

        elsif x.respond_to? :read

          Home_.lib_.system.IO.polymorphic_stream_via_readable x

        elsif x.respond_to? :each

          Home_.lib_.basic::Enumerator.polymorphic_stream_via_eachable x

        elsif x.respond_to? :ascii_only?

          Home_.lib_.basic::String.polymorphic_stream_via_string x
        else
          UNABLE_
        end
      end

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
      "unexpected: #{ Home_.lib_.basic::String.via_mixed current_token }"
    end

    def flush_to_stream

      Home_.stream do
        if unparsed_exists
          gets_one
        end
      end
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

    def gets_one
      x = current_token
      advance_one
      x
    end

    def current_token
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

    self
  end

  # knownnesses (see [#004])

  Knownish__ = -> x do
    if x
      Known_Known[ x ]
    else
      KNOWN_UNKNOWN
    end
  end

  class Known_Unknown

    class << self
      alias_method :via_reasoning, :new
      undef_method :new
    end  # >>

    def initialize x_o
      @reasoning = x_o
    end

    def to_qualified_known_around asc
      Qualified_Knownness.via_association asc
    end

    def to_known_known
      NIL_  # UNKNOWN_
    end

    def new_with_value x
      Known_Known[ x ]
    end

    attr_reader(
      :reasoning,  # #[#ze-030]#A
    )

    def is_effectively_known
      false
    end

    def is_known_known
      false
    end

    def is_qualified
      false
    end
  end

  KNOWN_UNKNOWN = Known_Unknown.via_reasoning nil

  class Known_Known

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
      @value_x = x
    end

    def to_qualified_known_around asc
      Qualified_Knownness.via_value_and_association @value_x, asc
    end

    def to_known_known
      self
    end

    def new_with_value x
      self.class[ x ]
    end

    def is_effectively_known
      ! @value_x.nil?
    end

    attr_reader :value_x

    def is_known_known
      true
    end

    def is_qualified
      false
    end
  end

  class Qualified_Knownness  # [#004]

    class << self

      def via_association asc
        new nil, false, asc
      end

      _CA = nil ; p = -> do
        p = nil
        _CA = Home_.lib_.basic::Minimal_Property.via_variegated_symbol :argument
      end

      define_method :via_value_and_symbol do | x, sym |

        _asc = if :argument == sym
          _CA || p[]
        else
          Home_.lib_.basic::Minimal_Property.via_variegated_symbol sym
        end

        via_value_and_association x, _asc
      end

      def via_value_and_association x, asc
        new x, true, asc
      end

      alias_method :[], :via_value_and_association  # use IFF it's clear

      alias_method :via_value_and_had_and_association, :new
      private :new
    end  # >>

    def initialize x, is_knkn, asc

      @association = asc

      @is_known_known = is_knkn
      if is_knkn
        @value_x = x
      end
    end

    def to_knownness
      if @is_known_known
        Known_Known[ @value_x ]
      else
        KNOWN_UNKNOWN
      end
    end

    def new_with_value x
      self.class.via_value_and_had_and_association x, true, @association
    end

    def new_with_association asc
      self.class.via_value_and_had_and_association(
        ( @value_x if @is_known_known ),
        @is_known_known,
        asc )
    end

    def to_unknown
      self.class.via_association @association
    end

    def is_effectively_known

      # munge nil-ness with being unknown. NOTE: this is provided as a
      # convenience only. use it IFF it fits with your semantics/logic

      if @is_known_known
        ! @value_x.nil?
      else
        false
      end
    end

    def value_x
      if @is_known_known
        @value_x
      else
        raise __say_is_known_unknown
      end
    end

    def __say_is_known_unknown
      "#{ description } is a known unknown - do not request its value"
    end

    def description  # look good for [#010]
      "«qualified-knownness#{ ":#{ name.as_slug }" }»"  # :+#guillemets
    end

    def name_symbol
      name.name_symbol
    end

    def name
      @association.name
    end

    attr_reader(
      :association,
      :is_known_known,
    )

    def is_qualified
      true
    end
  end

  Pair = ::Struct.new :value_x, :name_x do  # :[#055].

    class << self
      alias_method :via_value_and_name, :new
      undef_method :[]
      undef_method :new
    end  # >>

    alias_method :name_symbol, :name_x  # as you like it
    alias_method :to_sym, :name_x

    def new_with_value x
      self.class.new x, name_symbol
    end
  end

  class Bound_Call  # :[#059].

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

      def each_const_value_method
        self::Boxxy_::EACH_CONST_VALUE_METHOD_P
      end

      def names_method
        self::Boxxy_::NAMES_METHOD_P
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
          __process_argument_stream x_a
        end
        p = remove_instance_variable :@block
        if p
          p[ self ]
        end
        __apply
        NIL
      end

      def __process_argument_stream x_a

        @argument_stream = Polymorphic_Stream.via_array x_a

        if @argument_stream.current_token.respond_to? :ascii_only?
          __when_path
        end

        while @argument_stream.unparsed_exists
          send PROCESS_WHICH___.fetch @argument_stream.gets_one
        end
        NIL
      end

      def __when_path
        @do_extend_methods = true
        @path = @argument_stream.gets_one
      end

      PROCESS_WHICH___ = {
        boxxy: :__when_boxxy,
        methods: :__when_methods,
        autoloaderized_parent_module: :__when_autoloaderized_parent_module,
      }

      def __when_autoloaderized_parent_module
        @do_extend_methods = true
        @autoloaderized_parent_module = @argument_stream.gets_one
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

            @boxxy_original_methods__ ||= BoxxyOriginalMethods___.__for self  # [#030] #note-1

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
        _boxxy_controller.constants__
      end

      def const_defined? sym, inherit=true
        _boxxy_controller.const_is_defined__ sym, inherit
      end

      def const_missing sym
        _boxxy_controller.const_missing__ sym
      end

      def _boxxy_controller
        @___boxxy_controller ||= Here_::Boxxy_::Controller.new self
      end

      attr_reader(
        :boxxy_original_methods__
      )
    end

    BoxxyOriginalMethods___ = ::Struct.new :const_defined, :constants, :const_get do
      def self.__for mod
        new mod.method( :const_defined? ), mod.method( :constants ), mod.method( :const_get )
      end
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
        _ = Here_::ConstMissing_.new( x, self ).execute
        _
      end

      def entry_tree
        kn = ( @____file_tree_knownness ||= begin
          Knownish__[ Here_::FileTree_::Via_module.new( self, File_tree_cache___ ).execute ]
        end )
        kn.value_x if kn.is_known_known
      end

      def parent_module
        pedigree_.parent_module__
      end

      def pedigree_
        @_pedigree ||= Here_::ComponentModels__::Pedigree.via_module__( self )
      end

      def dir_path
        @___dir_path_is_known_is_known ||= Here_::ComponentModels__::Touch_dir_path[ self ]
        @dir_path  # can be nil
      end
    end

    File_tree_cache___ = Lazy_.call do
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

    EXTNAME = '.rb'.freeze

    CORE_ENTRY_STEM = 'core'.freeze
    CORE_FILE = "#{ CORE_ENTRY_STEM }#{ EXTNAME }".freeze
    DOT_DOT_ = '..'
    NameError = ::Class.new ::NameError
    NODE_PATH_IVAR_ = :@dir_path
  end

  Autoloader[ Actor ]
  Autoloader[ Box ]

  class Name  # see [#060]

    class << self

      # -- "library" nodes

      def labelize * a
        if a.length.zero?
          Home_::Name::Modality_Functions::Labelize
        else
          Home_::Name::Modality_Functions::Labelize[ * a ]
        end
      end

      def lib
        Home_::Name__
      end

      def module_moniker * a
        if a.length.zero?
          Home_::Name__::Unique_Features::Module_moniker
        else
          Home_::Name::Modality_Functions::Module_moniker[ * a ]
        end
      end

      def empty_name_for__ x
        Home_::Name::Conversion_Functions::Empty_name_for[ x ]
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

          d = s.rindex CONST_SEP_
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

      def as_camelcase_const
        _const.as_camelcase_const
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
        _stem_.___const_when_stem
      end

      def ___const_when_stem
        @___did_attempt_const ||= ___attempt_const
        @_const
      end

      def ___attempt_const
        @_const = Here_._via_stem_ self
        ACHIEVED_
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

      s_a = @value_x_.split SPLITTER_RX___, -1

      # downcase the piece IFF it doesn't look like an acroynym

      s_a.each do | s |
        s.gsub! DOWNCASER_RX___, & :downcase
      end

      s_a
    end

    def as_camelcase_const
      @___camelcase ||= ___build_camelcase
    end

    def ___build_camelcase
      @x_ = _stem_._stem_value_x_
      _titlecase_the_pieces
      _join_using_ EMPTY_S_
      remove_instance_variable :@x_
    end

    def as_const  # symbol
      @value_x_as_symbol_ ||= @value_x_.intern
    end

    def as_approximation
      @___approximation ||= Distill_[ @value_x_ ]
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
        _stem_.___LwU_when_stem
      end

      def ___LwU_when_stem
        @___LwU ||= Here_._via_stem_ self
      end
    end

    def _interpret_
      _no_trailing_separators_
      _join_using_ UNDERSCORE_
      _downcase_
    end

    def _express_
      @value_x_.split UNDERSCORE_  # NOTE trailing separators lost
    end

    def as_lowercase_with_underscores_symbol
      @value_x_as_symbol_ ||= @value_x_.intern
    end

    def as_lowercase_with_underscores_string
      @value_x_
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
        _stem_.___human_when_stem.as_human
      end

      def ___human_when_stem
        @___human ||= Here_._via_stem_ self
      end
    end  # >>

    def _interpret_
      _no_trailing_separators_
      _join_using_ SPACE_
    end

    def _express_
      @value_x_.split SPACE_
    end

    def as_human
      @value_x_
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

      def as_slug
        _stem_.___slug_when_stem.as_slug
      end

      def ___slug_when_stem
        @___slug ||= Here_._via_stem_ self
      end
    end  # >>

    def _interpret_
      # NOTE slugs preserve trailing "separators"
      _join_using_ DASH_
      _downcase_
    end

    def _express_
      @value_x_.split DASH_, -1  # NOTE keep trailing separators
    end

    def as_slug
      @value_x_
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
        _stem_.___variegated_when_stem
      end

      def ___variegated_when_stem
        @___variegated ||= Here_._via_stem_ self
      end
    end

    def _interpret_
      _no_trailing_separators_
      _join_using_ UNDERSCORE_
    end

    def _express_

      # perserve trailing separators IFF they were in the original symbol [sg]

      @value_x_.split UNDERSCORE_, -1
    end

    def as_ivar= x
      @_ivar = x
    end

    def as_ivar
      @_ivar ||= :"@#{ @value_x_ }"
    end

    def as_parts
      _stem_._stem_value_x_
    end

    def as_variegated_string
      @value_x_  # eek
    end

    def as_variegated_symbol
      @value_x_as_symbol_ ||= @value_x_.intern
    end
  end

  class Name  # re-open as common base

    class << self

      def _via_stem_ stem
        new.__via_stem stem
      end

      def _via_normal_string_ s
        new.finish_via_normal_string s
      end

      def _via_normal_symbol_ sym
        new.finish_via_normal_symbol sym
      end

      private :new
    end  # >>

    def __via_stem stem

      @x_ = stem._stem_value_x_
      self._interpret_
      x = remove_instance_variable :@x_
      if x
        @value_x_ = x
        @_stem = stem
        self
      else
        x  # cannot produce a name for this context from this stem
      end
    end

    def finish_via_normal_symbol sym
      @value_x_as_symbol_ = sym
      finish_via_normal_string sym.id2name
    end

    def finish_via_normal_string s
      @value_x_ = s ; self
    end

    def _stem_
      x = ( @_stem ||= ___resolve_stem )
      if true == x  # ick but prettier graphs
        self
      else
        x
      end
    end

    def ___resolve_stem
      x = self._express_
      x or fail
      @stem_value_x_ = x
      true
    end

    def _stem_value_x_
      @stem_value_x_
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

  Distill_ = -> do  # [#026]:#the-distill-function  :+[#bm-002]
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
    o = Home_.lib_.human::NLP::EN.const_get( const, false ).call.dup
    o.express_none_by { '[none]' }
    -> a do
      o.with_list( a ).say
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

  class Scn < ::Proc  # see [#049]

    class << self

      def aggregate * scn_a
        Home_::Scn__::Aggregate.new scn_a
      end

      def the_empty_stream
        @_tes_ ||= new do end
      end

      def multi_step * x_a
        if x_a.length.zero?
          Home_::Scn__::Multi_Step__
        else
          Home_::Scn__::Multi_Step__.new_via_iambic x_a
        end
      end

      def peek
        Home_::Scn__::Peek__
      end

      def try_convert x
        Home_::Scn__.try_convert x
      end
    end

    alias_method :gets, :call
  end

  ACHIEVED_ = true
  CONST_SEP_ = '::'.freeze
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''.freeze  # think of all the memory you'll save
  KEEP_PARSING_ = true
  NIL_ = nil
  NILADIC_TRUTH_ = -> { true }

  SPACE_ = ' '.freeze
  UNABLE_ = false

  Autoloader[ self, DIR_PATH__ ]
  # #dogfood
end
