module Skylab ; end

module Skylab::Callback

  class << self

    def [] mod, * x_a
      self::Bundles.apply_iambic_on_client x_a, mod
    end

    def pair
      Pair_
    end

    def produce_library_shell_via_library_and_app_modules lib_mod, app_mod
      Callback_::Librication__[ lib_mod, app_mod ]
    end

    def scan( & p )
      if block_given?
        Callback_::Scan.new( & p )
      else
        Callback_::Scan
      end
    end

    alias_method :stream, :scan

    def test_support
      Callback_::Test
    end
  end

  module Actor  # see [#042] the actor narrative

    class << self

      def [] cls, * i_a
        via_client_and_iambic cls, i_a
      end

      def call cls, * i_a
        via_client_and_iambic cls, i_a
      end

      def methodic cls, * i_a
        Actor::Methodic__.via_client_and_iambic cls, i_a
      end

      def methodic_lib
        Actor::Methodic__
      end

      def via_client_and_iambic cls, i_a
        cls.extend MM__ ; cls.include self
        while i_a.length.nonzero?
          case i_a.first
          when :properties
            i_a.shift
            absrb_prps i_a, cls
            break
          else
            raise ::ArgumentError, i_a.first
          end
        end ; nil
      end
    private
      def absrb_prps i_a, cls
        box = cls.actor_property_box_for_write
        d = -1 ; last = i_a.length - 1 ; i = nil
        box.add i = i_a.fetch( d += 1 ), :"@#{ i }" while d < last ; nil
      end
    end

    BX_ = :ACTOR_PROPERTY_BOX___
    D__ = :ACTOR_PROPERTY_BOX_LENGTH_MARKER_FOR_ARGLIST__

    module MM__

      def [] * a
        new do
          process_arglist_fully a
        end.execute
      end

      def via_arglist a, & p
        new do
          process_arglist_fully a
          p and p[ self ]
        end.execute
      end

      def with * x_a, & p  # #note-70
        new do
          process_iambic_fully x_a
          p and p[ self ]
        end.execute
      end

      def build_with * x_a, & p
        new do
          process_iambic_fully x_a
          p and p[ self ]
        end
      end

      def via_iambic x_a, & p
        new do
          process_iambic_fully x_a
          p and p[ self ]
        end.execute
      end

      def build_via_iambic x_a
        new do
          process_iambic_fully x_a
        end
      end

      def curry
        -> * preset_arglist do
          cls = ::Class.new self
          cls.extend Actor::Curried__::Module_Methods
          cls.include Actor::Curried__::Instance_Methods
          cls.accept_arglist_for_curry preset_arglist
          cls
        end
      end

      def curry_with * x_a
        cls = ::Class.new self
        cls.extend Actor::Curried__::Module_Methods
        cls.include Actor::Curried__::Instance_Methods
        cls.accept_iambic_for_curry x_a
        cls
      end

      def members
        const_get( BX_ ).get_names
      end

      def actor_property_box_for_write
        if const_defined? BX_
          if const_defined? BX_, false
            self._TEST_ME  # strange - re-opeing. should be OK
            const_get BX_, false
          else
            bx = const_get BX_
            const_set D__, bx.length
            const_set BX_, bx.dup
          end
        else
          const_set D__, 0
          const_set BX_, Box.new
        end
      end

      def actor_property_box_for_arglist
        @actor_property_box_for_arglist ||= prdc_actor_prop_box_for_arglist
      end

    private

      def prdc_actor_prop_box_for_arglist
        d = const_get D__
        if d.zero?
          const_get BX_
        else
          build_property_box_slice_for_arglist
        end
      end

      def build_property_box_slice_for_arglist
        d = const_get D__
        bx = const_get BX_
        bx_ = bx.class.new
        d.upto( bx.length - 1 ) do |d_|
          i, ivar = bx.fetch_pair_at_position d_
          bx_.add i, ivar
        end
        bx_
      end
    end

    def initialize & p
      super( & nil )
      p and instance_exec( & p )
    end

  private

    def process_arglist_fully a
      box = self.class.actor_property_box_for_arglist
      a.length.times do |d|
        instance_variable_set box.fetch_at_position( d ), a.fetch( d )
      end ; nil  # #etc
    end

    def process_iambic_fully x_a
      box = self.class.const_get BX_
      x_a.each_slice( 2 ) do |i, x|
        instance_variable_set box.fetch( i ), x
      end ; nil
    end

    def process_iambic_stream_fully st
      bx = self.class.const_get BX_
      while st.unparsed_exists
        instance_variable_set bx.fetch( st.gets_one ), st.gets_one
      end
      KEEP_PARSING_
    end

    def process_iambic_passively x_a
      box = self.class.const_get BX_
      d = -2 ; last = x_a.length - 2
      while d < last
        d += 2
        ivar = box[ x_a.fetch( d ) ]
        if ivar
          instance_variable_set ivar, x_a.fetch( d + 1 )
        else
          x = d
          break
        end
      end
      x
    end

    def iambic_stream_via_iambic_array x_a
      Iambic_Stream_via_Array_.new 0, x_a
    end

    def ivar_box
      self.class.const_get BX_
    end
  end

  Callback_ = self

  class Box

    def initialize
      @a = [] ; @h = {}
    end

    def freeze
      @a.freeze ; @h.freeze ; super
    end

    def initialize_copy _otr_
      @a = @a.dup ; @h = @h.dup ; nil
    end

    def length
      @a.length
    end

    def has_name i
      @h.key? i
    end

    def index i
      @a.index i
    end

    def first_name
      @a.first
    end

    def fetch_at_position d
      @h.fetch @a.fetch d
    end

    def fetch_name_at_position d
      @a.fetch d
    end

    def fetch_pair_at_position d
      [ @a.fetch( d ), @h.fetch( @a.fetch d ) ]
    end

    def at * a
      a.map( & @h.method( :[] ) )
    end

    def get_names
      @a.dup
    end

    def [] i
      @h[ i ]
    end

    def fetch i, & p
      @h.fetch i, & p
    end

    def at_position d
      @h.fetch @a.fetch d
    end

    def to_name_stream
      Callback_::Scan.via_nonsparse_array @a
    end

    def to_value_stream
      d = -1 ; last = @a.length - 1
      Scn.new do
        if d < last
          @h.fetch @a.fetch d += 1
        end
      end
    end

    def to_value_scan
      d = -1 ; last = @a.length - 1
      Callback_.scan do
        if d < last
          @h.fetch @a.fetch d += 1
        end
      end
    end

    def to_pair_scan
      d = -1 ; last = @a.length - 1
      Callback_.scan do
        if d < last
          i = @a.fetch d += 1
          Pair_.new @h.fetch( i ), i
        end
      end
    end

    def each_name
      @a.each do |i| yield i end ; nil
    end

    def each_value
      @a.each do |i| yield @h.fetch( i ) end ; nil
    end

    def each_pair
      @a.each do |i| yield i, @h.fetch( i ) end ; nil
    end

    # ~ mutators

    def ensuring_same_values_merge_box! otr
      a = otr.a ; h = otr.h
      a.each do |i|
        had = true
        m_i = @h.fetch i do
          had = false
        end
        if had
          m_i == @h.fetch( i ) or raise "merge failure near #{ m_i }"
        else
          @a.push i ; @h[ i ] = h.fetch i
        end
      end ; nil
    end

    def set i, x
      @h.fetch i do
        @a.push i
      end
      @h[ i ] = x ; nil
    end

    def add_if_not_has i, & p
      @h.fetch i do
        @a.push i
        @h[ i ] = p.call
      end ; nil
    end

    def add_or_assert i, x_
      has = true
      x = @h.fetch i do
        has = false
      end
      if has
        x == x_ or raise "assertion failure - not equal: (#{ x }, #{ x_ })"
        nil
      else
        @a.push i ; @h[ i ] = x_ ; true
      end
    end

    def add_or_replace i, add_p, replace_p
      has = true
      x = @h.fetch i do
        has = false
      end
      if has
        @h[ i ] = replace_p[ x ]
      else
        @a.push i
        @h[ i ] = add_p.call
      end
    end

    def add i, x
      had = true
      @h.fetch i do had = nil ; @a.push i ; @h[ i ] = x end
      had and raise ::KeyError, "won't clobber existing '#{ i }'"
    end

    def replace i, x_
      had = true
      x = @h.fetch i do
        had = false
      end
      had or raise ::KeyError, say_not_found( i )
      @h[ i ] = x_ ; x
    end

    def replace_by i, & p
      had = true
      x = @h.fetch i do
        had = false
      end
      had or raise ::KeyError, say_not_found( i )
      @h[ i ] = p[ x ]
    end

    def remove i
      d = @a.index( i ) or raise ::KeyError, say_not_found( i )
      @a[ d, 1 ] = EMPTY_A_
      @h.delete i
    end

    private def say_not_found i
      "key not found: #{ i.inspect }"
    end

  protected
    attr_reader :a, :h

    class << self

      def the_empty_box
        @teb ||= new.freeze
      end

      def pair
        Pair_
      end
    end
  end

  Iambic_Stream_via_Array_ = class Iambic_Stream  # :[#046]

    def reinitialize d, x_a
      @d = d ; @x_a = x_a ; @x_a_length = x_a.length
    end

    alias_method :initialize, :reinitialize

    def has_no_more_content
      @x_a_length == @d
    end

    def unparsed_exists
      @x_a_length != @d
    end

    def unparsed_count
      @x_a_length - @d
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

    def flush_remaining_to_array
      x = @x_a[ @d .. -1 ]
      @d = @x_a_length
      x
    end

    def advance_one
      @d += 1 ; nil
    end

    def current_index= d  # assume is valid index
      @d = d
    end

    def gets_one
      x = current_token ; advance_one ; x
    end

    # ~ hax (for "collaborators")

    def array_for_read
      @x_a
    end

    attr_accessor :x_a_length

    class << self
      def via_array x_a
        new 0, x_a
      end
    end

    self
  end

  Pair_ = ::Struct.new :value_x, :name_i  # :[#055].
  class Pair_
    def with_name_i i
      self.class.new value_x, i
    end
  end


  # ~ the #employment story

  module Autoloader  # read [#024] the new autolaoder narrative

    class << self
      def [] mod, * x_a
        if x_a.length.zero?
          mod.respond_to? :dir_pathname and raise say_not_idempotent( mod )
          mod.extend Methods__
        else
          employ_iambic_fully x_a, mod
        end
        mod
      end
    private
      def say_not_idempotent mod  # #not-idemponent
        "this operation is not idempotent. autoloader will not enhance #{
          }an object that already responds to 'dir_pathname': #{ mod }"
      end
      def employ_iambic_fully x_a, mod   # [ dir_pn ] [ 'boxxy' ]
        Employment_Parse__.new( self, x_a, mod ).parse
      end
    end

    class Employment_Parse__
      def initialize employee_mod, x_a, employer_mod
        @actual_p_a = []
        @employer_mod = employer_mod
        @possible_p_a = POSSIBLE_P_A_
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
        "unexpected argument #{ Callback_::Lib_::Strange[ x ] }. #{
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

    class << self  # methods that implement the different employment features

      def dir_pathname_argument x
        if x.respond_to? :relative_path_from
          -> mod do
            mod.module_exec do
              @dir_pathname = x
              extend Methods__
            end
          end
        end
      end

      def methods_keyword x
        if :methods == x
          -> mod do
            mod.module_exec do
              extend Methods__
            end
          end
        end
      end

      def boxxy_keyword x
        if :boxxy == x
          -> mod do
            mod.respond_to? :dir_pathname or
              mod.extend Methods__
            mod.extend self::Boxxy_::Methods ; nil
          end
        end
      end
    end

    POSSIBLE_P_A_ = [
      method( :dir_pathname_argument ),
      method( :methods_keyword ),
      method( :boxxy_keyword )
    ].freeze


    Methods__ = ::Module.new

    self[ self ]  # eat our own dogfood as soon as possible for #grease

    # ~ the dir_pathname feature & related (e.g child class)

    module Methods__
      def dir_pathname
        @_did_resolve_dir_pathname ||= rslv_dir_pathname
        @dir_pathname
      end
      def autoloader_name
        @did_orient_for_autoloader ||= orient_for_autoloader
        @autoloader_name
      end
    private
      def rslv_dir_pathname
        @dir_pathname ||= rslv_any_dir_pathname
        true
      end
      def rslv_any_dir_pathname
        mod = autoloader_parent_module
        mod.respond_to? :dir_pathname or raise ::NoMethodError,
          autoloader_say_no_dirpathname( mod )
        dpn = mod.dir_pathname
        dpn and dpn.join @autoloader_name.as_slug
      end
      def autoloader_say_no_dirpathname mod
        "needs 'dir_pathname': #{ mod }"
      end
      def autoloader_parent_module
        @did_orient_for_autoloader ||= orient_for_autoloader
        @autoloader_parent_module
      end
      def orient_for_autoloader
        s_a = name.split CONST_SEP_
        @autoloader_name = Name.via_const s_a.pop
        @autoloader_parent_module = Module_path_value_via_parts[ s_a ]
        true
      end
    end

    # :#the-file-story

    module Methods__
      def const_missing i
        Const_Missing_.new( self, i ).resolve_some_x
      end
    end

    class Const_Missing_
      def initialize mod, i
        @name = Name.any_valid_via_const( i ) || Name.via_variegated_symbol( i )
        @mod = mod ; nil
      end
      def resolve_some_x
        stow_h = @mod.stowaway_h
        if stow_h && stow_h[ @name.as_const ]
          rslv_some_x_when_stowaway
        else
          ( et = @mod.entry_tree ) and et.has_directory and
            np = et.normpath_from_distilled( @name.as_distilled_stem )
          if np
            @normpath = np
            send @normpath.method_name_for_state
          else
            raise_uninitialized_constant_name_error
          end
        end
      end
    private
      def raise_uninitialized_constant_name_error
        _say = "uninitialized constant #{
          }#{ @mod.name }::#{ @name.as_const } #{
           }and no directory[file] #{
            }#{ @mod.dir_pathname }/#{ @name.as_slug }[#{ EXTNAME_ }]"
        raise ::NameError, _say
      end
      def rslv_some_x_when_not_loaded
        if @normpath.can_produce_load_file_path
          rslv_some_x_via_normpath
        else
          rslv_some_x_when_directory
        end
      end
      def rslv_some_x_via_normpath
        load_normpath
        rslv_some_x_after_loaded
      end
      def load_normpath
        @normpath.value_is_known and self._HOLE  # probably just do it, yeah?
        @normpath.change_state_to :loaded  # no autoviv. for this last one
        @load_file_path = @normpath.get_load_file_path
        load @load_file_path
      end
      def rslv_some_x_after_loaded
        x = lookup_x_after_loaded
        @mod.autoloaderize_with_normpath_value @normpath, x
        x
      end
    public def lookup_x_after_loaded
        const_i = name_as_const
        if @mod.const_defined? const_i, false
          @mod.const_get const_i, false
        else
          fzzy_lookup method :rslv_some_x_via_different_casing_or_scheme
        end
      end
      def name_as_const
        @name.as_const
      end ; public :name_as_const
      def rslv_some_x_via_different_casing_or_scheme correct_i
        # we don't cache it here (anymore), but we might cache this x elsewhere
        @mod.const_get correct_i, false
      end
      def fzzy_lookup one_p, zero_p=nil, many_p=nil  # assume no exact match
        fzzy_lookup_name_in_mod @name, @mod, one_p, zero_p, many_p
      end
    public( def fzzy_lookup_name_in_mod name, mod, one_p=nil, zero_p=nil, many_p=nil
        a = [] ; stem = name.as_distilled_stem
        mod.constants.each do |i|
          stem == Distill_[ i ] and a << i
        end
        case a.length <=> 1
        when -1 ; zero_p or raise ::NameError, say_zero( name, mod ) ; zero_p[]
        when  0 ; one_p ? one_p[ a.first ] : mod.const_get( a.first, false )
        when  1 ; many_p[ a ]
        end
      end )
      def say_zero name, mod
        "#{ mod.name }::( ~ #{ name.as_slug } ) #{
          }must be but does not appear to be defined in #{
           }#{ @load_file_path }"
      end
    end

    EXTNAME = EXTNAME_ = '.rb'.freeze

    class Normpath_
      def initialize parent_pn, file_entry, dir_entry
        @dir_entry = dir_entry ; @file_entry = file_entry
        block_given? and yield self
        if file_entry
          @norm_pathname = parent_pn.join file_entry.entry_s
        end
        if dir_entry
          @dir_pn ||= parent_pn.join dir_entry.entry_s
          @norm_pathname ||= @dir_pn
        end
        SANITY_CHECK__[ @norm_pathname ]
        @parent_pn = parent_pn
        @state_i = :not_loaded
        @value_is_known = false
      end
      def to_path  # #todo:during-development
        @norm_pathname.to_path
      end
      SANITY_CHECK__ = -> do
        h = {}
        -> pn do
          h.fetch pn do
            h[ pn ] = true ; false
          end and raise "autoloader implementation failure: #{
            }entry tree redundantly created for #{ pn }"
        end
      end.call
      def can_produce_load_file_path
        @file_entry || has_corefile
      end
      def get_load_file_path
        @file_entry or self._NO_LOAD_FILE_PATH_BECAUSE_NO_FILE_ENTRY
        @norm_pathname.to_path
      end

      # ~~ experimental association of normpath with node value

      attr_reader :value_is_known
      def set_value x
        @value_is_known and raise say_value_already_known( x )
        @value_is_known = true
        @value_x = x ; nil
      end
      def known_value
        @value_is_known or self._VALUE_NOT_KNOWN
        @value_x
      end
    private
      def say_value_already_known x
        ick = -> x_ { ::Module === x_ ? x_ : "a #{ x_.class }" }
        "can't associate normpath with #{ ick[ x ] }. it is already #{
          }associated with #{ ick[ @value_x ] } (for #{ @norm_pathname })."
      end
    end

    class File_Entry_
      def initialize entry_s, corename
        @corename = corename ; @entry_s = entry_s
      end
      attr_reader :entry_s
    end

    class Dir_Entry_
      def entry_s
        @corename
      end
    end

    class Entry_Tree_ < Normpath_  # read [#024]:introduction-to-the-entry-tree

      def to_stream  # :+#public-API, #the-fuzzily-unique-entry-scanner, #fuzzy-sibling-pairs
        @did_index_all ||= index_all
        a = @stem_i_a ; d = -1 ; last = a.length - 1
        Callback_.scan do
          if d < last
            @normpath_lookup_p[ a.fetch d += 1 ]
          end
        end
      end

      def get_load_file_path
        if @h.key? CORE_FILE_
          @norm_pathname.join( CORE_FILE_ ).to_path
        else
          super
        end
      end

      def some_dir_pathname
        @dir_pn or self._NO_DIR_PATHNAME
      end

      SNGL_LTR = 'D'.freeze
    end

    module Methods__
      def autoloaderize_with_normpath_value np, x
        np.set_value x
        _is_module_esque = x.respond_to? :module_exec  # not all x are modules.
        if _is_module_esque && ! x.respond_to?( :dir_pathname )
          Autoloader[ x, np.get_some_dir_pathname ]  # some x wire themselves.
        end
        # all x with a corresponding dir must take this now to avoid redundant
        # filesystem hits. in the case of of nodes that first resolve their
        # dir tree then XYZZY
        if np.has_directory and x.respond_to? :did_resolve_entry_tree
          if x.did_resolve_entry_tree
            # [#032] document why & when this gets here (e.g via the [sg] client)
          else
            # when dir exists but no file, WTF
            x.set_entry_tree np
          end
        end ; nil
      end
    protected
      def set_entry_tree x
        did_resolve_entry_tree and self._SANITY
        @did_resolve_entry_tree = true
        @any_built_entry_tree = x ; nil
      end
    end

    class File_Normpath_ < Normpath_
      def has_directory
        false
      end
      def get_some_dir_pathname
        @dir_pn ||= bld_dpn
      end
      def some_dir_pathname
        @dir_pn ||= bld_dpn
      end
    private
      def bld_dpn
        @parent_pn.join @file_entry.corename
      end
      SNGL_LTR = 'F'.freeze
    end

    class Entry_Tree_
      def has_directory
        true
      end
      def get_some_dir_pathname
        @dir_pn
      end
    end

    # ~ the entry tree sub-story

    module Methods__
      def entry_tree
        @did_resolve_entry_tree ||= rslv_entry_tree_by_looking_upwards
        @any_built_entry_tree
      end
      attr_reader :did_resolve_entry_tree
    private
      def rslv_entry_tree_by_looking_upwards
        any_dpn = dir_pathname
        apm = autoloader_parent_module or self._HOLE
        apm.respond_to? :entry_tree and pet = apm.entry_tree
        if pet
          np = pet.normpath_from_distilled @autoloader_name.as_distilled_stem
          np and np.has_directory and et = np
        end
        @any_built_entry_tree = if et
          et
        elsif any_dpn
          LOOKAHEAD_[ any_dpn ]
        end
        true
      end
    end

    LOOKAHEAD_ = -> do  # #on-the-ugliness-of-global-caches
      h = { }
      -> pn do
        et = h[ pn.dirname ]
        if et
          et_ = et.normpath_from_distilled Distill_[ pn.basename.to_path ]
        end
        if et_
          et_
        else
          h.fetch pn do
            h[ pn ] = Entry_Tree_.new pn.dirname, nil,
              Dir_Entry_.new( pn.basename.to_path )
          end
        end
      end
    end.call

    class Dir_Entry_
      def initialize entry_s
        @corename = entry_s
      end
    end

    class Entry_Tree_

      def initialize parent_pn, file_entry, dir_entry
        super parent_pn, file_entry, dir_entry  # trip sanity checks early
        @normpath_lookup_p = -> i do
          @did_index_all = index_all
          @normpath_lookup_p[ i ]
        end
        make_directory_listing_cache
      end
    private
      def make_directory_listing_cache
        a = [] ; h = {}
        foreach_entry_s do |entry_s|
          DOT__ == entry_s.getbyte( 0 ) and next
          md = WHITE_DIR_ENTRY_RX__.match entry_s
          md or next
          _entry = if md[2]
            File_Entry_.new md[0], md[1]
          else
            Dir_Entry_.new md[0]
          end
          a << entry_s
          h[ entry_s ] = _entry
        end
        a.sort!  # #must-sort
        @a = a.freeze ; @h = h.freeze ; nil
      end
      DOT__ = '.'.getbyte 0
      EXTNAME_RXS_ = ::Regexp.escape EXTNAME_
      WHITE_DIR_ENTRY_RX__ = /\A([a-z][-_a-z0-9]*)(#{ EXTNAME_RXS_ })?\z/

      def foreach_entry_s & p
        ::Dir.foreach @dir_pn.to_path, &p
      rescue ::Errno::ENOENT
      end
    end

    # ~ the indexing sub-story

    class Entry_Tree_
      def normpath_from_distilled stem_i
        @normpath_lookup_p[ stem_i ]
      end
    private
      def index_all  # from the set of all entries eagerly build the set of
        # all mutable norm paths (a set whose size will be lesser than or
        # equal to the size of the input set). along the way also make note of
        # the distilled stems that correspond to the three "any"'s. the actual
        # norm paths are built and cached on demand.

        stem_a = [] ; mnp_h = {}
        touch_mnp = -> stem_i do
          mnp_h.fetch stem_i do
            stem_a << stem_i
            mnp_h[ stem_i ] = Mutable_Normpath_.new @dir_pn
          end
        end
        @any_corefile_i = @any_file_i = @any_dir_i = nil
        @a.each do |entry_s|
          entry = @h.fetch entry_s
          stem_i = Distill_[ entry.corename ]
          mnp = touch_mnp[ stem_i ]
          if entry.looks_like_file
            mnp.see_file_entry entry
            if entry.is_corefile
              @any_file_i = @any_corefile_i = stem_i
            elsif ! @any_file_i
              @any_file_i = stem_i
            end
          else
            mnp.see_dir_entry entry
            @any_dir_i ||= stem_i
          end
        end
        normpath_h = ::Hash.new do |h, stem_i|
          mnp = mnp_h[ stem_i ]
          h[ stem_i ] = if mnp
            file_entry, dir_entry = mnp.to_a
            if dir_entry
              Entry_Tree_.new @dir_pn, file_entry, dir_entry
            else
              File_Normpath_.new @dir_pn, file_entry, dir_entry
            end
          end
        end
        @normpath_lookup_p = -> stem_i do
          normpath_h[ stem_i ]
        end
        @stem_i_a = stem_a
        true
      end
    end

    class File_Entry_
      attr_reader :corename
      def looks_like_file
        true
      end
    end

    class Dir_Entry_
      attr_reader :corename
      def looks_like_file
        false
      end
    end

    class Mutable_Normpath_
      def initialize parent_pn
        @dir_entry = @file_entry = nil
        @parent_pn = parent_pn
      end
      def see_file_entry e
        @file_entry and self._HOLE_too_many_entries_for_same_stem e
        @file_entry = e
      end
      def see_dir_entry e
        @dir_entry and self._HOLE_too_many_entries_for_same_stem e
        @dir_entry = e
      end
      def to_a
        [ @file_entry, @dir_entry ]
      end
    end

    # ~ the state sub-story

    class Normpath_
      attr_reader :state_i
      def method_name_for_state
        METHODS__.fetch @state_i
      end
      METHODS__ = {
        not_loaded: :rslv_some_x_when_not_loaded,
        loading: :rslv_some_x_when_loading,
        loaded: :rslv_some_x_when_loaded
      }
      STATES__ = {
        not_loaded: { loading: true, loaded: true },
        loading: { loaded: true },
        loaded: { }  # EMPTY_H_
      }
      def assert_state i
        @state_i == i or fail "expected state '#{ i }' had '#{ @state_i }' #{
          }for node #{ @norm_pathname }"
      end
      def change_state_to i
        STATES__.fetch( @state_i )[ i ] or raise say_bad_state_transition( i )
        @state_i = i ; nil
      end
    private
      def say_bad_state_transition i
        a = STATES__[ @state_i ].keys
        _s = if a.length.zero?
          "'#{ i }' is a final state and does not transition to any others"
        else
          "valid state(s): (#{ a * ', ' })"
        end
        _s_ = " - #{ @norm_pathname }"
        "cannot change state from '#{ @state_i }' to '#{ i }'. #{ _s }#{ _s_ }"
      end
    end

    # ~ the loaded story

    class Const_Missing_
    private
      def rslv_some_x_when_loaded
        fzzy_lookup method :rslv_some_x_via_different_casing_or_scheme
      end
    end

    # ~ the stowaway story [#031]

    module Methods__
      attr_reader :stowaway_h
    private
      def stowaway i, relpath
        ( @stowaway_h ||= {} )[ i ] = relpath ; nil
      end
    end

    class Const_Missing_

      def rslv_some_x_when_stowaway  # [cu] relies on this heavily
        x = @mod.stowaway_h.fetch @name.as_const
        if x.respond_to? :split
          Autoloader::Stowaway_Actors__::Produce_x[ self, x ]
        else
          x.call
        end
      end

      attr_reader :name, :mod
    end

    class Normpath_

      attr_reader :norm_pathname

      def name_i  # :+#public-API
        name_for_lookup.as_variegated_symbol
      end

      def name  # :+#public-API
        name_for_lookup
      end

      def name_for_lookup
        @nm ||= Name.via_slug ( @file_entry || @dir_entry ).corename
      end
    end

    class Entry_Tree_

      def add_imaginary_normpath_for_correct_name name, dpn=nil  # #stow-3
        h = ( @imaginary_h ||= {} )
        i = name.as_distilled_stem
        h.key? i and self._NAME_COLLISION
        _dir_entry = Dir_Entry_.new name.as_slug
        et = Entry_Tree_.new @dir_pn, nil, _dir_entry do |et_|
          dpn and et_.set_dir_pathname dpn
        end
        h[ i ] = et
        et
      end

      attr_reader :imaginary_h

      def set_dir_pathname dpn
        @dir_pn = dpn ; nil
      end
    end

    # ~ the loading story (bolsters two others)

    class Const_Missing_
      def rslv_some_x_when_loading  # :#spot-1
        @mod.produce_autoloderized_module_for_const_missing self
      end
      def some_normpath
        @normpath or self._NO_NORMPATH
      end
    end

    module Methods__
      def produce_autoloderized_module_for_const_missing cm
        # assume this is coming from code in a written file and so
        # the received name is the correct casing / scheme
        np = cm.some_normpath
        np.change_state_to :loaded
        new_mod = const_set cm.name_as_const, ::Module.new
        autoloaderize_with_normpath_value np, new_mod
        new_mod
      end
    end

    # :#the-directory-story

    class Const_Missing_
    private
      def rslv_some_x_when_directory  # [#024]:find-some-file
        make_adjunct_chain
        rslv_adjunct_value
        @adjunct_chain.length > 1 and cleanup_adjuct_chain
        @adjunct_value
      end

      def make_adjunct_chain
        @normpath.change_state_to :loading
        a = [ @normpath ]
        node = @normpath
        until node.can_produce_load_file_path
          node_ = node.any_file_normpath
          node_ ||= node.any_dir_normpath
          node_ or raise ::NameError, say_no_recurse( node )
          node = node_
          node.change_state_to :loading
          a << node
        end
        @adjunct_chain = a ; nil
      end

      def say_no_recurse dir
        "cannot determine correct casing and scheme for #{ @mod.name }::#{
          }( ~ #{ @name.as_slug } ) - directory is effectively empty: #{
           }#{ dir.norm_pathname }"
      end

      def get_load_file_path
        @file_entry or self._NO_LOAD_FILE_PATH_BECAUSE_NO_FILE_ENTRY
        @norm_pathname.to_path
      end

      def rslv_adjunct_value
        the_target_normpath = @normpath
        @normpath = @adjunct_chain.last  # eew/meh
        load_normpath  # #spot-1
        @normpath = the_target_normpath
        @adjunct_value = lookup_x_after_loaded
        @normpath = the_target_normpath
        if ! @normpath.value_is_known
          # #todo:covered-by-subsystem-not-node
          @mod.autoloaderize_with_normpath_value @normpath, @adjunct_value
          @normpath.change_state_to :loaded
        end
        @adjunct_value.did_resolve_entry_tree or self._SANITY ; nil
      end

      def cleanup_adjuct_chain  # [#024]:created-modules
        a = @adjunct_chain ; from_mod = @adjunct_value
        d = 0 ; last = a.length - 1  # the first el we start on is the 2nd el!
        while d < last
          np = a.fetch d += 1
          if np.value_is_known
            mod = np.known_value
          else  # e.g the file declared the module itself
            if :loading == np.state_i
              np.change_state_to :loaded
            end
            mod = fzzy_lookup_name_in_mod np.name_for_lookup, from_mod
            from_mod.autoloaderize_with_normpath_value np, mod
          end
          if np.has_directory and d < last ||
              mod.respond_to?( :did_resolve_entry_tree )
            mod.did_resolve_entry_tree or self._SANITY
          end
          np.assert_state :loaded
          from_mod = mod
        end
        nil
      end
    end

    class Normpath_
      def represents_file_immediately
        @file_entry
      end
    end

    class Entry_Tree_
      def any_file_normpath
        @did_index_all ||= index_all
        @any_file_i and normpath_from_distilled @any_file_i
      end
      def any_dir_normpath
        @did_index_all ||= index_all
        @any_dir_i and normpath_from_distilled @any_dir_i
      end
    end

    # ~ the corefile story (:#the-corefile-story)

    class Entry_Tree_
    private
      def has_corefile
        @did_index_all ||= index_all
        @any_corefile_i
      end
      # normpath_from_distilled @any_corefile_i
    end

    class Normpath_
      def file_is_corefile
        @file_entry.is_corefile
      end
    end

    class File_Entry_
      def is_corefile
        CORE_ == @corename  # or CORE_FILE_ == @entry_s
      end
    end

    CORE_ = 'core'.freeze
    CORE_FILE_ = "#{ CORE_ }#{ EXTNAME_ }".freeze

    # ~ the const_reduce integration

    module Methods__
      def const_reduce a=nil, & p
        Autoloader.const_reduce do |cr|
          cr.from_module self
          if a
            cr.const_path a
            p and p[ cr ]
          else
            p[ cr ]
          end
        end
      end
    end

    def self.const_reduce *a, &p
      self::Const_Reduction__::Dispatch[ a, p ]
    end

    class Entry_Tree_
      def get_require_file_path
        @h.key? CORE_FILE_ or raise ::LoadError, "cannot determine a path #{
         }to require: #{ @dir_entry.corename }/#{ CORE_FILE_ } does not #{
          }exist. did #{ @dir_entry.corename }#{ EXTNAME_ } fail to load? (#{
           }in #{ @parent_pn })"
        "#{ @parent_pn.to_path }/#{ @dir_entry.corename }/#{ CORE_ }"
      end
    end

    class File_Normpath_
      def get_require_file_path
        @parent_pn.join( @file_entry.corename ).to_path
      end
    end
  end

  Autoloader[ Actor ]

  module Autoloader  # ~ service methods outside the immediate scope of a.l
    module Methods__
      def autoloaderize_with_filename_child_node fn, cn
        Autoloader[ cn, dir_pathname.join( fn ) ] ; nil
      end
    end
  end

  module Autoloader  # ~ service procs outside immediate scope of autoload.

    class << self

      def at *a
        @at_h ||= {}
        a.map { |i| @at_h.fetch( i ) { @at_h[ i ] = method i } }
      end

      def build_require_sidesystem_proc * i_a  # #open [#053]
        proc_or_call_or_map i_a do |x|
          memoize do
            require_sidesystem x
          end
        end
      end

      def build_require_stdlib_proc * i_a
        proc_or_call_or_map i_a do |x|
          memoize do
            require_stdlib x
          end
        end
      end
    private
      def proc_or_call_or_map i_a, & p
        case i_a.length <=> 1
        when -1 ; p
        when  0 ; p[ i_a.first ]
        when  1 ; i_a.map( & p.method( :call ) )
        end
      end
    public

      def default_core_file  # #n.c
        CORE_FILE_
      end

      def each_const_value_method
        self::Boxxy_::EACH_CONST_VALUE_METHOD_P
      end

      def memoize *a, &p
        Memoize_.via_arglist_and_proc a, p
      end

      def names_method
        self::Boxxy_::NAMES_METHOD_P
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
          x = Callback_.dir_pathname.dirname.to_path ; sl_path = -> { x } ; x
        end

        require_via_const = -> const_i do
          require "#{ sl_path[] }/#{  Name.via_const( const_i ).as_slug }/core"
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
    end
  end

  class Name  # will freeze any string it is constructed with
    # this only supports the simplified inflection necessary for this app.
    class << self

      def is_valid_const const_i
        VALID_CONST_RX__ =~ const_i
      end

      def lib
        Callback_::Name__
      end

      def any_valid_via_const const_i
        VALID_CONST_RX__ =~ const_i and
          allocate_with :initialize_with_const_i, const_i
      end

      def via_const const_i
        VALID_CONST_RX__ =~ const_i or raise ::NameError, say_wrong( const_i )
        allocate_with :initialize_with_const_i, const_i
      end

      def via_human human_s
        allocate_with :initialize_with_human, human_s
      end

      def via_module mod
        allocate_with :initialize_with_const_i,
          mod.name.split( CONST_SEP_ ).last
      end

      def via_slug s
        allocate_with :initialize_with_slug, s
      end

      def via_variegated_symbol i
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
      @as_slug = human_s.gsub( SPACE__, DASH_ ).downcase.freeze
      initialize
    end
    def initialize_with_slug s
      @as_slug = s.freeze
      initialize
    end
    def initialize_with_variegated_symbol i
      @as_variegated_symbol = i
      @as_slug = i.to_s.gsub( NORMALIZE_CONST_RX__, DASH_ ).
        gsub( UNDERSCORE_, DASH_ ).downcase.freeze
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
    def as_distilled_stem
      @as_distilled_stem ||= Distill_[ as_const ]
    end
    def as_doc_slug
      @as_doc_slug ||= build_doc_slug
    end
    def as_human
      @as_human ||= build_human
    end
    def as_ivar
      @as_ivar ||= bld_ivar
    end
    def as_lowercase_with_underscores_symbol
      @a_lwus ||= build_lwus
    end
    def as_parts
      @as_parts ||= as_variegated_string.split( UNDERSCORE_ ).freeze
    end
    def as_slug
      @as_slug ||= build_slug
    end
    def as_trimmed_variegated_symbol
      @as_trimmed_variegated_symbol ||= build_trimmed_variegated_symbol
    end
    def as_variegated_string
      @as_variegated_string ||= as_variegated_symbol.id2name.freeze
    end
    def as_variegated_symbol
      @as_variegated_symbol ||= build_variegated_symbol
    end
  private
    def build_doc_slug
      as_normalized_const.gsub( SLUGIFY_CONST_RX__, & :downcase ).
        gsub( UNDERSCORE_, DASH_ ).freeze
    end
    def build_human
      s = as_slug.dup
      s.gsub! TRAILING_DASHES_RX__, EMPTY_S_
      s.gsub! DASH_, SPACE__
      s.freeze
    end
    def build_lwus
      as_slug.gsub( DASH_, UNDERSCORE_ ).downcase.intern
    end
    def bld_ivar
      :"@#{ as_variegated_symbol }"
    end
    def build_slug
      as_normalized_const.gsub( UNDERSCORE_, DASH_ ).downcase.freeze
    end
    def build_variegated_symbol
      s = as_slug.dup
      s.gsub! DASH_, UNDERSCORE_
      s.intern
    end
    def build_trimmed_variegated_symbol
      s = as_slug.dup
      s.gsub! TRAILING_DASHES_RX__, EMPTY_S_
      s.gsub! DASH_, UNDERSCORE_
      s.intern
    end
    def as_normalized_const
      as_const.to_s.gsub NORMALIZE_CONST_RX__, UNDERSCORE_
    end
    def resolve_camelcase_const
      @camelcase_const_is_resolved = true
      @camelcase_const = ( i = as_const and
        i.to_s.gsub( UNDERSCORE_, THE_EMPTY_STRING__ ).intern  )
      true
    end
    def resolve_const
      @const_is_resolved = true
      @as_const = Constify_if_possible_[ as_variegated_symbol.to_s ]
    end

    NORMALIZE_CONST_RX__ = /(?<=[a-z])(?=[A-Z])/
    SLUGIFY_CONST_RX__ = /[A-Z](?=[a-z])/
    SPACE__ = ' '.freeze
    TRAILING_DASHES_RX__ = /-+\z/
    THE_EMPTY_STRING__ = ''.freeze
    VALID_CONST_RX__ = /\A[A-Z][A-Z_a-z0-9]*\z/
  end

  # ~ public and protected consts and any related public accessor methods

  def self.const_sep
    CONST_SEP_
  end

  CONST_SEP_ = '::'.freeze

  Constify_if_possible_ = -> do
    white_rx = %r(\A[a-z][-_a-z0-9]*\z)i
    gsub_rx = /([-_]+)([a-z])?/
    -> s do
      if white_rx =~ s
        s_ = s.gsub( gsub_rx ) do
          "#{ UNDERSCORE_ * $~[1].length }#{ $~[2].upcase if $~[2] }"
        end
        s_[0] = s_[0].upcase
        s_.intern
      end
    end
  end.call

  DASH_ = '-'.freeze

  def self.distill * a
    if a.length.zero?
      Distill_
    else
      Distill_[ * a ]
    end
  end

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

  EMPTY_A_ = [].freeze

  EMPTY_P_ = -> { }

  EMPTY_S_ = ''.freeze  # think of all the memory you'll save

  KEEP_PARSING_ = true

  def self.memoize *a, &p
    Memoize_.via_arglist_and_proc a, p
  end

  module Memoize_
    class << self
      def via_arglist_and_proc a, p
        if a.length.zero?
          if p
            self[ p ]
          else
            self
          end
        else
          p and a.push p
          self[ a.fetch a.length - 1 << 1 ]
        end
      end

      def [] p
        p_ = -> do
          x = p[] ; p_ = -> { x } ; x
        end
        -> { p_.call }
      end
    end
  end

  Module_path_value_via_parts = -> x_a do  # :+[#ba-034]
    x_a.reduce ::Object do |mod, x|
      mod.const_get x, false
    end
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

  PATH_SEP_ = '/'.freeze

  class Scn < ::Proc  # see [#049]

    class << self

      def aggregate * scn_a
        Callback_::Scn__::Aggregate.new scn_a
      end

      def articulators
        Callback_::Scn__::Articulators
      end

      def the_empty_stream
        @_tes_ ||= new do end
      end

      def multi_step * x_a
        if x_a.length.zero?
          Callback_::Scn__::Multi_Step__
        else
          Callback_::Scn__::Multi_Step__.build_via_iambic x_a
        end
      end

      def peek
        Callback_::Scn__::Peek__
      end

      def try_convert x
        Callback_::Scn__.try_convert x
      end
    end

    alias_method :gets, :call
  end

  require 'pathname'  # ~ eat our own dogfood, necessarily at the end

  Autoloader[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]
end
