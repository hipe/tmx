module Skylab ; end

module Skylab::Callback

  def self.[] mod, * x_a
    self::Bundles.apply_iambic_on_client x_a, mod
  end

  module Autoloader  # read [#024] the new autoloader narrative

    class << self

      def [] mod, * x_a
        if x_a.length.zero?
          mod.respond_to? :dir_pathname and raise say_not_idempotent( mod )
          mod.extend Triggering_Methods__, Universal_Base_Methods__
        else
          employ_iambic_fully x_a, mod
        end
        mod
      end

      def at *a
        @at_h ||= {}
        a.map { |i| @at_h.fetch( i ) { @at_h[ i ] = method i } }
      end

      def build_require_sidesystem_proc i
        memoize { require_sidesystem i }
      end

      def build_require_stdlib_proc i
        memoize { require_stdlib i }
      end

      def const_reduce *a, &p
        self::Const_Reduction__::Dispatch[ a, p ]
      end

      def memoize *a, &p
        Memoize_[ ( p ? a << p : a ).fetch a.length - 1 << 1 ]
      end

      def require_quietly const_i_or_path_s
        without_warning do
          if Name.is_valid_const const_i_or_path_s
            require_stdlib const_i_or_path_s
          else
            require const_i_or_path_s
          end
        end
      end
    private
      def without_warning
        prev = $VERBOSE ; $VERBOSE = nil
        r = yield  # 'ensure' is out of scope
        $VERBOSE = prev ; r
      end
    public

      define_method :require_sidesystem, -> do
        sl_path = -> do
          x = Callback.dir_pathname.dirname.to_path ; sl_path = -> { x } ; x
        end
        require_single_sidesystem = -> const_i do
          _stem = Name.from_const( const_i ).as_slug
          require "#{ sl_path[] }/#{ _stem }/core"
          ::Skylab.const_get const_i, false
        end
        p = -> * i_a do
          case i_a.length <=> 1
          when -1 ; p
          when  0 ; require_single_sidesystem[ i_a.first ]
          else    ; i_a.map( & require_single_sidesystem )
          end
        end
      end.call

      def require_stdlib const_i
        require const_i.downcase.to_s  # until it's useful to, no inflection
        ::Object.const_get const_i
      end
    end

    # ~ protected constants and their public accessor counterparts

    def self.default_core_file
      CORE_FILE_
    end

    EXTNAME = EXTNAME_ = '.rb'.freeze

      CORE_FILE_ = "core#{ EXTNAME_ }".freeze

    # ~ the default starter methods (read [#024]:the-four-method-modules-method)

    module Triggering_Methods__  # #the-triggering-methods

      def const_missing i
        insist_on_dir_pathname
        const_missing i
      end
      def dir_pathname
        insist_on_dir_pathname
        dir_pathname
      end
      def get_const_missing name_x, _guess_i  # #hook-in
        insist_on_dir_pathname
        Const_Missing__.new self, @dir_pathname, name_i
      end
      def pathname
        self._DO_ME  # #todo
      end
      def to_path
        insist_on_dir_pathname
        to_path
      end
    private
      def insist_on_dir_pathname
        s_a = name.split '::'
        last_s = s_a.pop
        mod = s_a.reduce( ::Object ) { |m, s| m.const_get s, false }
        mod.respond_to? :dir_pathname or raise ::NoMethodError, say_dpn( mod )
        extend Final_Methods__
        _dpn = mod.dir_pathname.join last_s.gsub( '_', '-' ).downcase
        set_dir_pn _dpn ; nil
      end
      def say_dpn mod
        "needs dir_pathname: #{ mod }"
      end
    end

    module Universal_Base_Methods__  # #the-universal-base-methods

      def enhance_autoloaded_value_with_dir_pathname x, dir_pathname
        if can_be_enhanced_for_autoloading x
          Autoloader[ x, dir_pathname ]
        end
      end
    private
      def can_be_enhanced_for_autoloading x  # not all autoloaded
        # objects are modules. some autoloaded modules might wire themselves
        ! x.respond_to? :dir_pathname and x.respond_to? :module_exec
      end

    public
      attr_reader :stowaway_h
    private
      def stowaway i, path
        ( @stowaway_h ||= {} )[ i ] = path ; nil
      end
    end

    self[ self ]  # this occurs at the earliest moment it can (for #grease)

    module Final_Methods__  # #the-final-methods
      def const_missing i
        @dir_pathname or super
        r = Const_Missing__.new( self, @dir_pathname, i ).load_and_get
        r
      end
      def const_missing_class
        :_has_one_  # #comport to oldschoool a.l
      end
      attr_reader :dir_pathname
      def to_path
        pathname.to_path
      end
      def pathname
        @dir_pathname.sub_ext EXTNAME_
      end
      def get_const_missing name_x, _guess_i  # #hook-in
        Const_Missing__.new self, @dir_pathname, name_x
      end
      def init_dir_pathname x  # #comport #storypoint-265
        set_dir_pn x
      end
      def set_dir_pn x  # compare more elaborate [sl] `init_dir_pathname`
        @dir_pathname = x ; nil
      end
    end

    # ~ the handling of extended autoloader options: [ dir_pn ] [ 'boxxy' ]

    class << self
    private
      def employ_iambic_fully x_a, mod
        Employment_Parse__.new( self, x_a, mod ).parse
      end
    public
      def possible_p_a
        self::POSSIBLE_P_A__
      end
    private

      # (when any of the below occur they are always processed in this order)

      def dir_pathname_argument x
        if x.respond_to? :relative_path_from
          -> mod do
            mod.module_exec do
              @dir_pathname = x
              extend Final_Methods__, Universal_Base_Methods__
            end
          end
        end
      end

      def methods_keyword x
        if :methods == x
          -> mod do
            mod.module_exec do
              extend Final_Methods__, Universal_Base_Methods__
            end
          end
        end
      end

      def boxxy_keyword x
        if :boxxy == x
          -> mod do
            mod.respond_to? :dir_pathname or
              mod.extend Triggering_Methods__, Universal_Base_Methods__
            mod.extend Boxxy_Methods__ ; nil
          end
        end
      end

      def say_not_idempotent mod  # #storypoint-50
        "this operation is not idempotent. autoloader will not enhance #{
          }an object that already responds to 'dir_pathname': #{ mod }"
      end
    end

    POSSIBLE_P_A__ = [
      method( :dir_pathname_argument ),
      method( :methods_keyword ),
      method( :boxxy_keyword )
    ].freeze

    class Employment_Parse__

      def initialize employee_mod, x_a, employer_mod
        @actual_p_a = []
        @employer_mod = employer_mod
        @possible_p_a = employee_mod.possible_p_a
        @possible_d_a = @possible_p_a.length.times.to_a
        @x_a = x_a
      end
      def parse
        begin
          p = nil ; x = @x_a.shift
          idx = @possible_d_a.index do |d|
            p = @possible_p_a.fetch( d )[ x ]
          end
          idx or raise ::ArgumentError, say_bad_term( x )
          @actual_p_a[ @possible_d_a.fetch idx ] = p
          @possible_d_a[ idx, 1 ] = EMPTY_A_
        end while @x_a.length.nonzero?
        flush
      end
    private
      def say_bad_term x
        "unexpected argument #{ Callback::Lib_::Inspect[ x ] }. #{
         }expecting #{ say_expecting }"
      end
      def say_expecting
        _a = @possible_d_a.map do |d|
          name_s = @possible_p_a.fetch( d ).name.to_s
          md = TERM_PARSER_NAME_MATCHER_RX__.match name_s
          stem, type = if md
            [ md[ 1 ], md[ 2 ].intern ]
          else
            [ name_s, :argument ]
          end
          send :"render_stem_as_#{ type }", stem
        end
        Oxford_or[ _a ]
      end

      TERM_PARSER_NAME_MATCHER_RX__ = %r(\A(.+)_(argument|keyword)\z)

      def render_stem_as_argument s
        "<#{ s }>"
      end
      def render_stem_as_keyword s
        "'#{ s }'"
      end
      def flush
        @actual_p_a.compact!
        @actual_p_a.each do |p|
          p[ @employer_mod ]
        end ; nil
      end
    end

    module Boxxy_Methods__  # #the-boxxy-methods
      def const_defined? const_i, up=false
        is_indexed_for_boxxy or constants
        yes = @boxxy_index.const_might_be_defined const_i
        yes or super
      end
      def constants
        a = super
        if ! is_indexed_for_boxxy
          index_for_boxxy a
        end
        [ * a, * @boxxy_a ]
      end
      attr_reader :is_indexed_for_boxxy
    private
      def index_for_boxxy a
        @is_indexed_for_boxxy = true
        @boxxy_index = Index_For_Boxxy_.
          new( @boxxy_a = [] , self, dir_pathname, a ).index ; nil
      end
    public
      def resolve_some_name_when_already_loaded name
        Boxxy_Correction_.new( self, name, @boxxy_index ).reify_correction
      end

      def enhance_autoloaded_value_with_dir_pathname x, dir_pathname
        if can_be_enhanced_for_autoloading x
          Autoloader[ x, dir_pathname, :boxxy ]
        end
      end
    end

    class Index_For_Boxxy_
      def initialize a, mod, dpn,  a_
        @boxxy_a = a ; @dir_pathname = dpn ; @existing_a = a_ ; @mod = mod
      end
      def index
        if @dir_pathname.exist?
          index_when_directory
        else
          index_when_no_directory
        end
      end
    private
      def index_when_no_directory
        Boxxy_Index_.new nil
      end
      def index_when_directory
        @paths = @dir_pathname.children false
        reduce_paths_to_normal_a
        get_busy
      end

      def reduce_paths_to_normal_a
        @normal_a = nil
        h = { }
        @paths.each do |pn|
          path = pn.to_path
          slug, extname = path.split SPLIT_EXTNAME_RX_
          ! extname || extname =~ EXTENSION_PASS_FILTER_RX_ or next
          const_i = Constify_if_possible_[ slug ]
          const_i or next
          h[ const_i ] and next  # e.g both "foo.rb" and "foo/"
          h[ const_i ] = true
          ( @normal_a ||= [] ) << const_i
        end ; nil
      end
      SPLIT_EXTNAME_RX_ = %r((?=\.[^.]+\z))
      EXTENSION_PASS_FILTER_RX_ = /\A(?:#{ ::Regexp.escape EXTNAME_ }|)\z/

      def get_busy
        @existing_a.length.nonzero? and pare_normals  # #storypoint-240
        @boxxy_a.concat @normal_a
        Boxxy_Index_.new( @boxxy_a )
      end
      def pare_normals
        loaded_h = ::Hash[ @existing_a.map { |i| [ Distill_[ i ], true ] } ]
        @normal_a.reject! { |i| loaded_h[ Distill_[ i ] ] } ; nil
      end
    end

    class Boxxy_Index_
      def initialize normal_a
        @normal_a = normal_a
        @distilled_h = if normal_a
          ::Hash[ @normal_a.map { |i| [ Distill_[ i ], i ] } ]
        end
      end
      def const_might_be_defined x
        @distilled_h && Name.is_valid_const( x ) &&
          @distilled_h.key?( Distill_[ x ] )
      end
      def make_correction correct_i
        norm_i = @distilled_h.fetch Distill_[ correct_i ]
        idx = @normal_a.index norm_i
        if idx
          @normal_a[ idx ] = nil
          @normal_a.compact!
        end  # #todo - oK?
      end
    end

    class Boxxy_Correction_
      def initialize mod, name, listener
        @listener = listener ; @mod = mod ; @name = name
      end
      def reify_correction
        @const_a = @mod.constants  # will have fakes in them
        @incorrect_i = @name.as_const
        @distilled = Distill_[ @incorrect_i ]
        @correct_i = @const_a.detect { |i| @distilled == Distill_[ i ] }
        if @correct_i && @correct_i != @incorrect_i
          flush_correction
        else
          just_say_no
        end
      end
    private
      def flush_correction
        @listener.make_correction @correct_i
        @mod.const_get @correct_i, false
      end
      def just_say_no
        raise ::NameError.new "#{ @mod }( ~ #{ @name.as_variegated_symbol } )#{
          } must be but appears not to be defined in #{ @mod.pathname }",
           @incorrect_i
      end
    end



    # ~ "runtime" implementation

    class Const_Missing__

      def initialize mod, dpn, i
        @dir_pathname = dpn ; @mod = mod
        @name = Name.any_valid_from_const(i) || Name.from_variegated_symbol(i)
      end

      attr_reader :mod

      def const
        @name.as_const
      end

      def load_and_get correction_proc=nil
        @correction_proc = correction_proc
        @d_pn = @dir_pathname.join @name.as_slug
        if Has_been_loaded__[ @d_pn.to_path ]
          load_and_get_when_has_been_loaded
        else
          load_and_get_via_loading
        end
      end

      Has_been_loaded__ = -> do  # "cache"
        h = { } ; -> s do
          h.fetch( s ) { h[ s ] = true ; nil }
        end
      end.call

    private

      def load_and_get_via_loading
        @f_pn = @d_pn.sub_ext EXTNAME_
        if h = @mod.stowaway_h and @stowaway_path = h[ @name.as_const ]
          load_stowaway
        elsif @f_pn.exist?
          when_file_exists
        elsif @d_pn.exist?
          when_dir_exists
        else
          when_neither_file_nor_dir_exist
        end
      end

      def when_neither_file_nor_dir_exist
        ex = ::NameError.exception "uninitialized constant #{
         }#{ @mod.name }::#{ @name.as_const } #{
          }and no directory[file] #{
           }#{ @d_pn.relative_path_from @dir_pathname }[#{ EXTNAME_ }]"
        a = caller_locations REMOVE_THIS_MANY_ELEMENTS_FROM_THE_STACK__
        a.map!( & :to_s )
        ex.set_backtrace a
        raise ex
      end

      REMOVE_THIS_MANY_ELEMENTS_FROM_THE_STACK__ = 4

      def when_file_exists
        load @f_pn.to_path
        after_file_was_loaded
      end

      def load_stowaway
        require @mod.dir_pathname.join( @stowaway_path ).to_path
        after_file_was_loaded
      end

      def after_file_was_loaded
        verify_const_defined_and_emit_correction
        mod = @mod.const_get @name.as_const
        if ! mod.respond_to? :dir_pathname
          enhance_loaded_value mod
        elsif ! mod.dir_pathname  # if a child class, e.g
          mod.set_dir_pn @d_pn
        end
        mod
      end

      def verify_const_defined_and_emit_correction
        i = @name.as_const or raise ::LoadError, say_cant_resolve_valid_cname
        @mod.const_defined? i, false or raise ::LoadError, say_not_defined
        @correction_proc and @correction_proc[] ; nil
      end

      def say_cant_resolve_valid_cname
        "can't resolve a valid const name from #{
          }'#{ @name.as_variegated_symbol }'"
      end

      def say_not_defined
        "'#{ @name.as_const }' was not defined in #{ @f_pn.basename }"
      end

      def when_dir_exists
        c_pn = @d_pn.join CORE_FILE_
        if c_pn.exist?
          @f_pn = c_pn
          when_file_exists
        else
          mod = @mod.const_set @name.as_const, ::Module.new
          enhance_loaded_value mod
          mod
        end
      end

      def enhance_loaded_value mod
        @mod.enhance_autoloaded_value_with_dir_pathname mod, @d_pn ; nil
      end
    public
      def correction_notification i
        @name.as_const == i or fail "sanity"  # just for compat with old
      end

    private
      def load_and_get_when_has_been_loaded
        @mod.resolve_some_name_when_already_loaded @name  # assumes a lot
      end
    end
  end  # ~ autoloader ends here

  class Name  # will freeze any string it is constructed with
    # this only supports the simplified inflection necessary for this app.
    class << self
      def any_valid_from_const const_i
        VALID_CONST_RX__ =~ const_i and
          allocate_with :initialize_with_const_i, const_i
      end
      def is_valid_const const_i
        VALID_CONST_RX__ =~ const_i
      end
      def from_const const_i
        VALID_CONST_RX__ =~ const_i or raise ::NameError, say_wrong( const_i )
        allocate_with :initialize_with_const_i, const_i
      end
      def from_human human_s
        allocate_with :initialize_with_human, human_s
      end
      def from_local_pathname pn
        allocate_with :initialize_with_local_pathname, pn
      end
      def from_variegated_symbol i
        allocate_with :initialize_with_variegated_symbol, i
      end
      private :new
    private
      def say_wrong const_i
        "wrong constant name #{ const_i }"
      end
      def allocate_with method_i, x
        new = allocate
        new.send method_i, x
        new
      end
    end
  private
    def initialize_with_const_i const_i
      @as_const = const_i
      @const_is_resolved = true
    end
    def initialize_with_human human_s
      @as_human = human_s.freeze
      @as_slug = human_s.gsub( SPACE__, DASH__ ).downcase.freeze
      initialize
    end
    def initialize_with_local_pathname pn
      @as_slug = pn.sub_ext( THE_EMPTY_STRING__ ).to_path.freeze
      initialize
    end
    def initialize_with_variegated_symbol i
      @as_variegated_symbol = i
      @as_slug = i.to_s.gsub( NORMALIZE_CONST_RX__, DASH__ ).
        gsub( UNDERSCORE__, DASH__ ).downcase.freeze
      initialize
    end
    def initialize
      @const_is_resolved = false
    end
  public
    def as_camelcase_const
      @camelcase_const_is_resolved ||= resolve_camelcase_const
      @camelcase_const
    end
    def as_const
      @const_is_resolved || resolve_const
      @as_const
    end
    def as_doc_slug
      @as_doc_slug ||= build_doc_slug
    end
    def as_human
      @as_human ||= build_human
    end
    def as_slug
      @as_slug ||= build_slug
    end
    def as_variegated_symbol
      @as_variegated_symbol ||= build_variegated_symbol
    end
  private
    def build_doc_slug
      as_normalized_const.gsub( SLUGIFY_CONST_RX__, & :downcase ).
        gsub( UNDERSCORE__, DASH__ ).freeze
    end
    def build_human
      as_slug.gsub( DASH__, SPACE__ ).freeze
    end
    def build_slug
      as_normalized_const.gsub( UNDERSCORE__, DASH__ ).downcase.freeze
    end
    def build_variegated_symbol
      as_slug.gsub( DASH__, UNDERSCORE__ ).intern
    end
    def as_normalized_const
      as_const.to_s.gsub NORMALIZE_CONST_RX__, UNDERSCORE__
    end
    def resolve_camelcase_const
      @camelcase_const_is_resolved = true
      @camelcase_const = ( i = as_const and
        i.to_s.gsub( UNDERSCORE__, THE_EMPTY_STRING__ ).intern  )
      true
    end
    def resolve_const
      @const_is_resolved = true
      @as_const = Constify_if_possible_[ as_variegated_symbol.to_s ]
    end

    DASH__ = '-'.freeze
    NORMALIZE_CONST_RX__ = /(?<=[a-z])(?=[A-Z])/
    SLUGIFY_CONST_RX__ = /[A-Z](?=[a-z])/
    SPACE__ = ' '.freeze
    THE_EMPTY_STRING__ = ''.freeze
    UNDERSCORE__ = '_'.freeze
    VALID_CONST_RX__ = /\A[A-Z][A-Z_a-z0-9]*\z/
  end


  # ~ consts & small procs used here, there, somewhere

  Callback = self

  Constify_if_possible_ = -> do
    white_rx = %r(\A[a-z][-_a-z0-9]*\z)i
    gsub_rx = /([-_]+)([a-z])?/
    -> s do
      if white_rx =~ s
        s_ = s.gsub( gsub_rx ) do
          "#{ '_' * $~[1].length }#{ $~[2].upcase if $~[2] }"
        end
        s_[0] = s_[0].upcase
        s_.intern
      end
    end
  end.call

  def self.distill
    Distill_
  end

  Distill_ = -> do  # [#026]:#the-distill-function  :+[#bm-002]
    black_rx = /[-_ ]+(?=[^-_])/  # preserve final trailing underscores & dashes
    dash = '-'.getbyte 0
    empty_s = ''.freeze
    undr = '_'.getbyte 0
    -> x do
      s = x.to_s.gsub black_rx, empty_s
      d = 0 ; s.setbyte d, undr while dash == s.getbyte( d -= 1 )
      s.downcase.intern
    end
  end.call

  EMPTY_A_ = [].freeze

  EMPTY_P_ = -> { }

  EMPTY_S_ = ''.freeze  # think of all the memory you'll save

  def self.memoize
    Memoize_
  end

  Memoize_ = -> p do
    p_ = -> { x = p[] ; p_ = -> { x } ; x }
    -> { p_.call }
  end

  Oxford = -> separator, none, final_sep, a do
    if a.length.zero?
      none
    else
      p = -> do
        h = { 0 => nil, 1 => final_sep }
        h.default_proc = -> _, _ do separator end
        h.method :[]
      end.call
      last = a.length - 1
      a[ 1 .. -1 ].each_with_index.reduce( [ a.first ] ) do |m, (s, d)|
        m << p[ last - d ] ; m << s ; m
      end * EMPTY_S_
    end
  end

  Oxford_or = Oxford.curry[ ', ', '[none]', ' or ' ]
  Oxford_and = Oxford.curry[ ', ', '[none]', ' and ' ]

  class Scn < ::Proc
    alias_method :gets, :call
  end


  # ~ "officious" final setup

  require 'pathname'

  Autoloader[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  stowaway :TestSupport, 'test/test-support'

end
