module Skylab ; end

module Skylab::Callback

  class << self

    def [] mod, * x_a
      self::Bundles.edit_module_via_mutable_iambic mod, x_a
    end

    def const_sep
      CONST_SEP_
    end

    def describe_into_under y, expag
      y << "(as a reactive node, [ca] is some ancient artifact..)"
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

    def test_support
      Home_::Test
    end
  end  # >>

  module Actor  # see [#042] the actor narrative

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

    class << self

      def [] cls, * i_a
        edit_module_via_mutable_iambic cls, i_a
      end

      def call cls, * i_a
        edit_module_via_mutable_iambic cls, i_a
      end

      def methodic cls, * i_a
        Actor::Methodic.edit_module_via_iambic cls, i_a
      end

      def edit_module_via_mutable_iambic cls, i_a

        cls.extend MM___
        cls.include self

        while i_a.length.nonzero?
          case i_a.first
          when :properties
            i_a.shift
            __absorb_fields i_a, cls
            break
          else
            raise ::ArgumentError, i_a.first
          end
        end ; nil
      end

    private

      def __absorb_fields i_a, cls

        bx = cls.__formal_fields_ivar_box_for_write

        d = -1 ; last = i_a.length - 1

        while d < last
          sym = i_a.fetch d += 1
          bx.add sym, :"@#{ sym }"
        end
      end
    end

    BX_ = :ACTOR_PROPERTY_BOX___

    module Call_Methods_

      def [] * a, & oes_p
        call_via_arglist a, & oes_p
      end

      def call * a, & oes_p
        call_via_arglist a, & oes_p
      end

      def with * x_a, & oes_p  # :+[#bs-028] reserved method name
        call_via_iambic x_a, & oes_p
      end

      def call_via_arglist a, & oes_p
        new do
          @on_event_selectively ||= oes_p
          process_arglist_fully a
        end.execute
      end

      def call_via_iambic x_a, & oes_p
        new do
          @on_event_selectively ||= oes_p
          process_iambic_fully x_a
        end.execute
      end

      def backwards_curry
        -> * xx_a do
          new do
            _init_instance_as_curry
            process_arglist_fully_as_rcurry_ xx_a
          end
        end
      end

      def curry_with * x_a, & oes_p
        new do
          oes_p and @on_event_selectively ||= oes_p
          _init_instance_as_curry
          process_iambic_fully_as_curry_ x_a
        end
      end

      def new_via_polymorphic_stream_passively st
        new do
          bx = formal_fields_ivar_box_for_read_
          begin
            ivar = bx.fetch st.current_token do end
            ivar or break
            st.advance_one
            instance_variable_set ivar, st.gets_one
            if st.no_unparsed_exists
              break
            end
            redo
          end while nil
        end
      end
    end

    module MM___

      include Call_Methods_

      def members
        const_get( BX_ ).get_names
      end

      def __formal_fields_ivar_box_for_write
        if const_defined? BX_
          if const_defined? BX_, false
            self._COVER_ME  # re-opening. should be ok, but we never do it
            const_get BX_, false
          else
            const_set BX_, const_get( BX_ ).dup
          end
        else
          const_set BX_, Box.new
        end
      end
    end

    def initialize & edit_p
      super( & nil )
      if edit_p
        instance_exec( & edit_p )
      end
    end

  private

    def _init_instance_as_curry

      _REMAINDER_BOX = formal_fields_ivar_box_for_read_.dup

      define_singleton_method :remainder_box_ do
        _REMAINDER_BOX
      end
      extend Actor::Curried__::Instance_Methods
      nil
    end

    def process_arglist_fully a
      bx = formal_fields_ivar_box_for_read_
      a.length.times do |d|
        instance_variable_set bx.at_position( d ), a.fetch( d )
      end
      NIL_
    end

    def process_iambic_fully x_a

      bx = formal_fields_ivar_box_for_read_

      x_a.each_slice 2 do |i, x|
        instance_variable_set bx.fetch( i ), x
      end

      NIL_
    end

    def process_polymorphic_stream_fully st
      bx = formal_fields_ivar_box_for_read_
      while st.unparsed_exists
        instance_variable_set bx.fetch( st.gets_one ), st.gets_one
      end
      KEEP_PARSING_
    end

    def process_iambic_passively x_a
      process_polymorphic_stream_passively polymorphic_stream_via_iambic x_a
    end

    def process_polymorphic_stream_passively st
      bx = formal_fields_ivar_box_for_read_
      while st.unparsed_exists
        ivar = bx[ st.current_token ]
        ivar or break
        st.advance_one
        instance_variable_set ivar, st.gets_one
      end
      KEEP_PARSING_  # we never fail softly
    end

    def polymorphic_stream_via_iambic x_a
      Polymorphic_Stream.via_array x_a
    end

    def formal_fields_ivar_box_for_read_
      self.class.const_get BX_
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
      @h.fetch name_at_position_ d
    end

    def name_at_position_ d
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
      @_alogrithms ||= Box::Algorithms__.new( @a, @h, self )
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
  end

  class Polymorphic_Stream  # :[#046]

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
      if unparsed_exists
        raise ::ArgumentError, __say_unexpected
      end
      x
    end

    def __say_unexpected
      "unexpected: #{ Home_.lib_.basic::String.via_mixed current_token }"
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

    # ~~ experimental "from end" parsing for [#cb-047]

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

  module KNOWN_UNKNOWN ; class << self

    def to_qualified_known_around asc
      Qualified_Knownness.via_association asc
    end

    def new_with_value x
      Known_Known[ x ]
    end

    def is_effectively_known
      false
    end

    def is_known_known
      false
    end

    def is_qualified
      false
    end

  end ; end

  class Known_Known

    class << self

      alias_method :[], :new
      private :new
    end  # >>

    def initialize x
      @value_x = x
    end

    def to_qualified_known_around asc
      Qualified_Knownness.via_value_and_association @value_x, asc
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
        _CA = Home_.lib_.basic::Minimal_Property.via_variegated_symbol :against
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
      name.as_variegated_symbol
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
      private :new
      private :[]
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
    end  # >>

    def initialize args, receiver, method_name, & p  # volatility order (subjective)
      @args = args
      @block = p
      @method_name = method_name
      @receiver = receiver
    end

    def members
      [ :args, :block, :method_name, :receiver ]
    end

    attr_reader :args, :block, :method_name, :receiver

  end

  DOT_ = '.'
  EMPTY_H_ = {}.freeze

  module Autoloader  # read [#024] the new autoloader narrative

    class << self

      def [] mod, * x_a, & p

        if x_a.length.nonzero? || p

          Effect_edit_session___.new( mod, x_a, & p ).execute

        else

          mod.respond_to? :dir_pathname and raise __say_not_idempotent( mod )
          mod.extend Methods__
        end
        mod
      end
      alias_method :call, :[]

      def __say_not_idempotent mod  # #not-idemponent
        "this operation is not idempotent. autoloader will not enhance #{
          }an object that already responds to 'dir_pathname': #{ mod }"
      end
    end  # >>

    Methods__ = ::Module.new

    self[ self ]  # eat our own dogfood as soon as possible for #grease

    class Effect_edit_session___  # assume nonzero tokens

      # this is the *only* way to apply "modifiers" to an autoloaderization

      def initialize mod, x_a, & edit_p

        @edit_p = edit_p
        @in_st = if x_a.length.nonzero?
          Polymorphic_Stream.via_array x_a
        end
        @mod = mod
      end

      def execute

        @_do_boxxy = nil ; @_do_common = nil
        @_FS_entry_string = nil
        @_path = nil ; @_pmod = nil

        if @edit_p
          @edit_p[ self ]
        end

        if @in_st

          x = @in_st.current_token
          if x.respond_to? :ascii_only?
            _process_path_phrase
          end

          while @in_st.unparsed_exists
            send :"process__#{ @in_st.gets_one }__phrase"
          end
        end

        __flush
        NIL_
      end

      # ~ three idioms: `_internal`, `_internal_setter=`, `etc__public__etc`

      def process__boxxy__phrase

        @_do_boxxy = true
      end

      def _filesystem_entry_string= x
        @_do_common = true
        @_FS_entry_string = x
        x
      end

      def process__methods__phrase

        @_do_common = true
      end

      def _process_path_phrase

        @_do_common = true
        @_path = @in_st.gets_one
      end

      # alias_method :process__path__phrase, :_process_path_phrase  # makes it public

      def _presumably_autoloaderized_parent_module= x

        @_do_common = true
        @_pmod = x
        x
      end

      # ~

      def __flush  # see #note-785

        do_boxxy = @_do_boxxy ; do_common = @_do_common
        fs_entry = @_FS_entry_string ; path = @_path
        pmod = @_pmod

        @mod.module_exec do

          if do_common
            extend Methods__
          end

          if pmod
            @_parent_module_is_known_is_known = true
            @_parent_module = pmod
          end

          if path

            if fs_entry
              raise ::ArgumentError
            end

            if instance_variable_defined? :@dir_pathname

              self._SANITY
            end

            @dir_pathname = ::Pathname.new path

          elsif fs_entry

            @_filesystem_entry_name = Name.via_slug fs_entry
          end

          if do_boxxy

            if ! respond_to? :dir_pathname
              extend Methods__
            end

            extend Autoloader_::Boxxy_::Methods
          end
        end
        NIL_
      end
    end

    # ~ the dir_pathname feature & related (e.g child class)

    module Methods__

      def dir_pathname

        @___dpn_is_known_is_known ||= __resolve_dir_pathname
        @dir_pathname
      end

      def __resolve_dir_pathname

        @dir_pathname ||= __produce_any_dir_pathname
        true
      end

      def __produce_any_dir_pathname

        _resolve_parent_module_and_filesystem_entry_name

        pmod = @_parent_module

        if ! pmod.respond_to? :dir_pathname
          raise ::NoMethodError, __autoloader_say_no_dirpathname( pmod )
        end

        dpn = pmod.dir_pathname
        if dpn
          dpn.join @_filesystem_entry_name.as_slug
        end
      end

      def __autoloader_say_no_dirpathname mod
        "needs 'dir_pathname': #{ mod }"
      end

      def _resolve_parent_module_and_filesystem_entry_name

        @_parent_module_is_known_is_known ||= _induce_parent_module

        @_filesystem_entry_name ||= __isomoprh_filesystem_entry_name

        NIL_
      end

      def _induce_parent_module  # memoizes another along the way

        s_a = name.split CONST_SEP_
        const_basename = s_a.pop

        @_filesystem_entry_name ||= Name.via_const_string( const_basename )

        @_parent_module = Const_value_via_parts[ s_a ]

        true
      end

      def __isomoprh_filesystem_entry_name

        s = name  # `::Module#name`
        Home_::Name.via_const_string s[ s.rindex( CONST_SEP_ ) + 2 .. -1 ]
      end
    end

    # :#the-file-story

    module Methods__

      def const_missing x  # we have to accept both
        _ = Const_Missing__.new( self, x.to_s ).resolve_some_x
        _
      end
    end

    class Const_Missing__

      def initialize mod, s

        nf = Name.__via_valid_const_string s
        nf or self._WHERE
        @name = nf
        @mod = mod
      end

      def resolve_some_x

        stow_h = @mod.stowaway_h

        if stow_h && stow_h[ @name.as_const ]
          __result_when_stowaway
        else

          et = @mod.entry_tree

          if et && et.has_directory
            np = et.normpath_from_distilled( @name.as_distilled_stem )
          end

          if np
            @normpath = np
            send @normpath.method_name_for_state
          else
            __raise_uninitialized_constant_name_error
          end
        end
      end

      def __raise_uninitialized_constant_name_error
        _say = "uninitialized constant #{
          }#{ @mod.name }::#{ @name.as_const } #{
           }and no directory[file] #{
            }#{ @mod.dir_pathname }/#{ @name.as_slug }[#{ EXTNAME_ }]"
        raise ::NameError, _say
      end

      def __result_when_not_loaded

        if @normpath.can_produce_load_file_path
          __result_via_normpath
        else
          __result_when_directory
        end
      end

      def __result_via_normpath
        _load_normpath
        __result_after_loaded
      end

      def _load_normpath

        @normpath.value_is_known and self._HOLE  # probably just do it, yeah?
        @normpath.change_state_to :loaded  # no autoviv. for this last one
        @load_file_path = @normpath.get_load_file_path
        load @load_file_path
      end

      def __result_after_loaded

        x = lookup_x_after_loaded
        @mod.autoloaderize_with_normpath_value @normpath, x
        x
      end

      def lookup_x_after_loaded
        const_i = name_as_const
        if @mod.const_defined? const_i, false
          @mod.const_get const_i, false
        else
          _fuzzy_lookup method :_result_via_different_casing_or_scheme
        end
      end

      def name_as_const
        @name.as_const
      end

      def _result_via_different_casing_or_scheme correct_i
        # we don't cache it here (anymore), but we might cache this x elsewhere
        @mod.const_get correct_i, false
      end

      def _fuzzy_lookup one_p, zero_p=nil, many_p=nil  # assume no exact match
        fuzzy_lookup_name_in_module_ @name, @mod, one_p, zero_p, many_p
      end

      def fuzzy_lookup_name_in_module_ name, mod, one_p=nil, zero_p=nil, many_p=nil

        a = []
        stem = name.as_distilled_stem

        mod.constants.each do | sym |
          if stem == Distill_[ sym ]
            a.push sym
          end
        end

        case a.length <=> 1
        when -1
          if zero_p
            zero_p[]
          else
            raise ::NameError, __say_zero( name, mod )
          end

        when  0
          if one_p
            one_p[ a.first ]
          else
            mod.const_get a.first, false
          end

        when  1
          if many_p
            many_p[ a ]
          else
            raise ::NameError, __say_ambiguous( a, name, mod )
          end
        end
      end

      def __say_zero name, mod

        "#{ mod.name }::( ~ #{ name.as_slug } ) #{
          }must be but does not appear to be defined in #{
           }#{ @load_file_path }"
      end

      def __say_ambiguous const_a, name, mod

        "unhandled ambiguity - #{ name.as_slug.inspect } resolves to #{
         }#{ mod.name }::( #{ const_a * ' AND ' } )"
      end
    end

    EXTNAME = EXTNAME_ = '.rb'.freeze

    class Normpath_

      def initialize parent_pn, file_entry, dir_entry

        @file_entry = file_entry
        @dir_entry = dir_entry

        if block_given?
          yield self
        end

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
        @value_is_known and raise __say_value_already_known( x )
        @value_is_known = true
        @value_x = x ; nil
      end

      def known_value
        @value_is_known or self._VALUE_NOT_KNOWN
        @value_x
      end

      def __say_value_already_known x
        ick = -> x_ { ::Module === x_ ? x_ : "a #{ x_.class }" }
        "can't associate normpath with #{ ick[ x ] }. it is already #{
          }associated with #{ ick[ @value_x ] } (for #{ @norm_pathname })."
      end
    end

    class File_Entry_
      def initialize entry_s, corename
        @corename = corename
        @entry_s = entry_s
      end
      attr_reader :entry_s
    end

    class Dir_Entry_
      def entry_s
        @corename
      end
    end

    class Entry_Tree_ < Normpath_  # read [#024]:introduction-to-the-entry-tree

      def has_entry_for_slug s

        if @h.key? s
          true
        else
          @h.key? "#{ s }#{ EXTNAME_ }"
        end
      end

      def has_entry s
        @h.key? s
      end

      def to_stream_without_any__ entry_stem_symbol

        @_did_index_all ||= _index_all
        a = @stem_i_a

        indexes = ( 0 ... a.length.to_i ).to_a

        dd = a.index( entry_stem_symbol )
        if dd
          indexes[ dd, 1 ] = EMPTY_A_
        end

        d = -1 ; last = indexes.length - 1

        Home_.stream do
          if last != d
            @normpath_lookup_p[ a.fetch indexes.fetch d += 1 ]
          end
        end
      end

      def to_stream  # :+#public-API, #the-fuzzily-unique-entry-scanner, #fuzzy-sibling-pairs
        @_did_index_all ||= _index_all
        a = @stem_i_a ; d = -1 ; last = a.length - 1
        Home_.stream do
          if last != d
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
          Autoloader_[ x, np.some_dir_path ]  # some x wire themselves.
        end

        # all x with a corresponding dir must take this now so we can avoid
        # redundant filesystem hits.

        if np.has_directory and x.respond_to? :entry_tree_is_known_is_known_

          if x.entry_tree_is_known_is_known_
            # [#032] document why & when this gets here (e.g via the [sg] client)
          else
            # when dir exists but no file, WTF
            x.__set_entry_tree np
          end
        end
        NIL_
      end

    protected def __set_entry_tree x
        entry_tree_is_known_is_known_ and self._SANITY
        @entry_tree_is_known_is_known_ = true
        @any_built_entry_tree_ = x ; nil
      end
    end

    class File_Normpath_ < Normpath_

      def has_directory
        false
      end

      def some_dir_path
        some_dir_pathname.to_path
      end

      def some_dir_pathname
        @dir_pn ||= __build_dir_pathname
      end

      def __build_dir_pathname
        @parent_pn.join @file_entry.corename
      end

      SNGL_LTR = 'F'.freeze
    end

    class Entry_Tree_
      def has_directory
        true
      end
      def some_dir_path
        @dir_pn.to_path
      end
    end

    # ~ the entry tree sub-story

    module Methods__

      def entry_tree

        @entry_tree_is_known_is_known_ ||= __resolve_entry_tree_by_looking_upwards
        @any_built_entry_tree_
      end

      attr_reader :entry_tree_is_known_is_known_

      def __resolve_entry_tree_by_looking_upwards

        _resolve_parent_module_and_filesystem_entry_name

        pmod = @_parent_module
        pmod or self._HOLE

        if pmod.respond_to? :entry_tree
          pet = pmod.entry_tree
        end

        if pet

          np = pet.normpath_from_distilled(
            @_filesystem_entry_name.as_distilled_stem )

          if np && np.has_directory
            et = np
          end
        end

        @any_built_entry_tree_ = if et
          et
        else

          any_dpn = dir_pathname
          if any_dpn
            LOOKAHEAD_[ any_dpn ]
          end
        end

        true
      end
    end

    LOOKAHEAD_ = -> do  # #on-the-ugliness-of-global-caches

      h = {}

      -> pn do

        path = pn.to_path

        dir = ::File.dirname path
        entry = ::File.basename path

        et = h[ dir ]

        if et
          et_ = et.normpath_from_distilled Distill_[ entry ]
        end

        if et_
          et_
        else

          h.fetch path do

            h[ path ] = Entry_Tree_.new(
              ::Pathname.new( dir ),
              nil,
              Dir_Entry_.new( entry ) )
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
          @_did_index_all = _index_all
          @normpath_lookup_p[ i ]
        end
        __init_directory_listing_cache
      end

      def __init_directory_listing_cache

        a = []
        h = {}

        __foreach_entry_s do |entry_s|

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

        @a = a.freeze
        @h = h.freeze
        NIL_
      end

      DOT__ = DOT_.getbyte 0

      EXTNAME_RXS_ = ::Regexp.escape EXTNAME_

      WHITE_DIR_ENTRY_RX__ = /\A([a-z][-_a-z0-9]*)(#{ EXTNAME_RXS_ })?\z/

      def __foreach_entry_s & p

        ::Dir.foreach @dir_pn.to_path, &p

      rescue ::Errno::ENOENT, ::Errno::ENOTDIR
      end
    end

    # ~ the indexing sub-story

    class Entry_Tree_

      def normpath_from_distilled stem_i
        @normpath_lookup_p[ stem_i ]
      end

      def _index_all  # from the set of all entries eagerly build the set of
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
        not_loaded: :__result_when_not_loaded,
        loading: :__result_when_loading,
        loaded: :__result_when_loaded
      }

      STATES__ = {
        not_loaded: { loading: true, loaded: true },
        loading: { loaded: true },
        loaded: EMPTY_H_,
      }

      def assert_state i
        @state_i == i or fail "expected state '#{ i }' had '#{ @state_i }' #{
          }for node #{ @norm_pathname }"
      end

      def change_state_to i
        STATES__.fetch( @state_i )[ i ] or raise __say_bad_state_transition( i )
        @state_i = i ; nil
      end

      def __say_bad_state_transition i
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

    class Const_Missing__
      def __result_when_loaded
        _fuzzy_lookup method :_result_via_different_casing_or_scheme
      end
    end

    # ~ the stowaway story [#031]

    module Methods__

      attr_reader :stowaway_h

    private

      def stowaway sym, * a, & p

        if block_given?
          __stowaway_when_block sym, * a, & p
        else
          __stowaway_when_relpath sym, * a
        end
      end

      def __stowaway_when_relpath sym, relpath
        ( @stowaway_h ||= {} )[ sym ] = relpath ; nil
      end

      def __stowaway_when_block sym, & p
        ( @stowaway_h ||= {} )[ sym ] = p ; nil
      end
    end

    class Const_Missing__

      def __result_when_stowaway  # [cu] relies on this heavily

        x = @mod.stowaway_h.fetch @name.as_const
        if x.respond_to? :split
          Autoloader_::Stowaway_Actors__::Produce_x[ self, x ]
        else
          x.call
        end
      end

      attr_reader :name, :mod
    end

    class Normpath_

      attr_reader :norm_pathname

      def name_symbol  # :+#public-API
        name_for_lookup_.as_variegated_symbol
      end

      def name  # :+#public-API
        name_for_lookup_
      end

      def name_for_lookup_
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

    class Const_Missing__

      def __result_when_loading  # :#spot-1
        @mod.__produce_autoloderized_module_for_const_missing self
      end

      def some_normpath
        @normpath or self._NO_NORMPATH
      end
    end

    module Methods__
      def __produce_autoloderized_module_for_const_missing cm
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

    class Const_Missing__

    private

      def __result_when_directory  # [#024]:find-some-file

        make_adjunct_chain
        __resolve_adjunct_value
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

      def __resolve_adjunct_value

        the_target_normpath = @normpath
        @normpath = @adjunct_chain.last  # eew/meh
        _load_normpath  # #spot-1
        @normpath = the_target_normpath
        @adjunct_value = lookup_x_after_loaded
        @normpath = the_target_normpath
        if ! @normpath.value_is_known
          # #todo:covered-by-subsystem-not-node
          @mod.autoloaderize_with_normpath_value @normpath, @adjunct_value
          @normpath.change_state_to :loaded
        end
        @adjunct_value.entry_tree_is_known_is_known_ or self._SANITY
        NIL_
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
            mod = fuzzy_lookup_name_in_module_ np.name_for_lookup_, from_mod
            from_mod.autoloaderize_with_normpath_value np, mod
          end
          if np.has_directory and d < last ||
              mod.respond_to?( :entry_tree_is_known_is_known_ )
            mod.entry_tree_is_known_is_known_ or self._SANITY
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
        @_did_index_all ||= _index_all
        @any_file_i and normpath_from_distilled @any_file_i
      end

      def any_dir_normpath
        @_did_index_all ||= _index_all
        @any_dir_i and normpath_from_distilled @any_dir_i
      end
    end

    # ~ the corefile story (:#the-corefile-story)

    class Entry_Tree_
    private
      def has_corefile
        @_did_index_all ||= _index_all
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
        CORE_ == @corename
        # CORE_FILE_ == @entry_s
      end
    end

    CORE_ = 'core'.freeze
    CORE_FILE_ = "#{ CORE_ }#{ EXTNAME_ }".freeze

    # ~ the const_reduce integration (see spec for tombstones)

    def self.const_reduce *a, &p
      self::Const_Reduction__.new( a, & p ).execute
    end

    class Entry_Tree_

      def get_require_file_path

        if @h.key? CORE_FILE_
          "#{ @parent_pn.to_path }/#{ @dir_entry.corename }/#{ CORE_ }"
        else
          raise ::LoadError, __say_get_require_file_path
        end
      end

      def __say_get_require_file_path
        "cannot determine a path #{
         }to require: #{ @dir_entry.corename }/#{ CORE_FILE_ } does not #{
          }exist. did #{ @dir_entry.corename }#{ EXTNAME_ } fail to load? (#{
           }in #{ @parent_pn })"
      end
    end

    class File_Normpath_
      def get_require_file_path
        @parent_pn.join( @file_entry.corename ).to_path
      end
    end

    Autoloader_ = self
  end

  Autoloader[ Actor ]
  Autoloader[ Box ]

  module Autoloader  # ~ service methods outside the immediate scope of a.l

    module Methods__

      def autoloaderize_child_node x  # 1x

        Autoloader_.call x do | sess |
          sess._presumably_autoloaderized_parent_module = self
        end
      end

      def using_file_entry_string_autoloaderize_child_node s, x  # 1x

        Autoloader_.call x do | sess |
          sess._presumably_autoloaderized_parent_module = self
          sess._filesystem_entry_string = s
        end
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
          Memoize.call do
            require_sidesystem x
          end
        end
      end

      def build_require_stdlib_proc * i_a
        proc_or_call_or_map i_a do |x|
          Memoize.call do
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

      def names_method
        self::Boxxy_::NAMES_METHOD_P
      end

      def require_quietly const_i_or_path_s
        without_warning do
          if VALID_CONST_RX__ =~ const_i_or_path_s
            require_stdlib const_i_or_path_s
          else
            require const_i_or_path_s
          end
        end
      end

      def without_warning
        prev = $VERBOSE ; $VERBOSE = nil
        r = yield  # 'ensure' is out of scope
        $VERBOSE = prev ; r
      end

      define_method :require_sidesystem, -> do

        require_via_const = -> const_i do

          _compliant_slug = Name.via_const_symbol( const_i ).
            as_lowercase_with_underscores_symbol

          require "skylab/#{ _compliant_slug }"
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

    # -- higher-level derivatives (for [#br-035] expressive events usually)

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

          if VALID_CONST_RX__ =~ s
            Here_._via_normal_string_ s
          else
            raise ::NameError, ___say_wrong_const_name( s )
          end
        end

        def ___say_wrong_const_name x
          "wrong constant name #{ x }"
        end

        def __via_valid_const_string s
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

      def as_distilled_stem
        o = _const
        o && o.as_distilled_stem
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

      if VALID_CONST_RX__ !~ @x_
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

    def as_distilled_stem
      @___distilled_stem ||= Distill_[ @value_x_ ]
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

  VALID_CONST_RX__ = /\A[A-Z][A-Z_a-z0-9]*\z/

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

      def as_ivar= sym
        self._K   # for irregulars
        _vari.as_ivar = sym
      end

      def as_ivar
        _vari.as_ivar
      end

      def as_parts
        _vari.as_parts
      end

      def as_variegated_string
        _vari.as_variegated_string
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

    def as_parts  # special just for [br] silo reference symbols
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

  Oxford = -> separator, when_none_x, final_separator, a do

    y = Oxford_comma_into[ [], a, final_separator, separator ]
    if y.length.zero?
      when_none_x
    else
      y * EMPTY_S_
    end
  end

  Oxford_comma_into = -> y, a, final_separator, separator do

    st = Polymorphic_Stream.via_array a

    if st.unparsed_exists  # if there's a last one

      stack = []

      last_x = st.pop_
      stack.push -> do
        y << last_x
      end

      if st.unparsed_exists  # if there's a second to last one
        penult_x = st.pop_
        stack.push -> do
          y << penult_x
          y << final_separator
        end

        while st.unparsed_exists  # with the any remaining at indexes 0 .. N-3
          y << st.gets_one
          y << separator
        end
      end

      p = nil
      p[] while p = stack.pop
    end
    y
  end  # a storied history :#tombstone

  class Scn < ::Proc  # see [#049]

    class << self

      def aggregate * scn_a
        Home_::Scn__::Aggregate.new scn_a
      end

      def articulators
        Home_::Scn__::Articulators
      end

      def the_empty_stream
        @_tes_ ||= new do end
      end

      def multi_step * x_a
        if x_a.length.zero?
          Home_::Scn__::Multi_Step__
        else
          Home_::Scn__::Multi_Step__.new do
            process_iambic_fully x_a
          end
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
  Oxford_or = Oxford.curry[ ', ', '[none]', ' or ' ]
  Oxford_and = Oxford.curry[ ', ', '[none]', ' and ' ]
  PATH_SEP_ = ::File::SEPARATOR
  SPACE_ = ' '.freeze
  UNABLE_ = false

  Without_extension = -> path do

    path[ 0 ... path.rindex( DOT_ ) ]
  end

  require 'pathname'  # eat our own dogfood. necessary before below.

  Autoloader[ self, Without_extension[ __FILE__ ] ]
end
