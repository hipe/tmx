module Skylab::BeautySalon

  class CrazyTownMagnetics_::NodeProcessor_via_Module

    # see "declarative (structural) grammar reflection" :[#022.A]

    # implementation-wise, we employ the [#ze-051] "operator branch" pattern
    #
    #   - superficially simliar to [#ze-051.2] but it's simple enough we
    #     might as well re-write it. (we don't take an index-first approach
    #     here.)
    #
    #   - NOTE we are grafting "new way" into "old way" .. maybe do the
    #     coverage thing while #open [#022]

    class << self
      alias_method :[], :new
      private :new
    end  # >>

    # -
      def initialize mod

        h = mod::IRREGULAR_NAMES
        if h
          @_lookup_class_const = :__lookup_class_const_initially
          @_irregulars_pool = h.dup
        else
          @_lookup_class_const = :_derive_class_const_normally
        end

        @_const_via_symbol = {}
        @_do_index = true
        @_items_module = mod::Items
        @_valid_const_via_normal_name_symbol = {}
        @module = mod
      end

      def specific_tupling_or_generic_tupling_for n
        cache = ( @___class_via_node_type ||= {} )
        k = n.type
        _cls = cache.fetch k do
          cls = lookup_softly k
          cls ||= GenericTupling___
          cache[ k ] = cls
          cls
        end
        _cls.via_node_ n
      end

      def procure ref_sym, & listener
        cls = lookup_softly ref_sym
        if cls
          cls
        else
          __when_not_found listener, ref_sym
        end
      end

      def lookup_softly ref_sym
        c = __valid_const_via_normal_name_symbol ref_sym
        if c
          _dereference_via_internal_key c
        end
      end

      def dereference sym
        _c = __class_const_via_name_symbol sym
        @_items_module.const_get _c, false
      end

      def __when_not_found listener, ref_sym

        me = self
        listener.call :error, :expression, :parse_error do |y|
          me.__levenshtein_into y, ref_sym
        end
        UNABLE_
      end

      def __levenshtein_into y, ick_sym

        @_do_index && __index_all

        _sym_a = @_valid_const_via_normal_name_symbol.keys

        _s_a = _sym_a.map { |sym| "'#{ sym }'" }

        y << %(currently we don't yet have metadata for grammar symbol '#{ ick_sym }'.)
        y << "(currently we have it for #{ Common_::Oxford_and[ _s_a ] }.)"
      end

      def __class_const_via_name_symbol sym
        c = @_const_via_symbol[ sym ]
        if ! c
          c = send @_lookup_class_const, sym
          @_const_via_symbol[ sym ] = c
        end
        c
      end

      def __lookup_class_const_initially sym
        c = @_irregulars_pool.delete sym
        if c
          if @_irregulars_pool.length.zero?
            remove_instance_variable :@_irregulars_pool
            @_lookup_class_const = :_derive_class_const_normally
          end
          c
        else
          _derive_class_const_normally sym
        end
      end

      def _derive_class_const_normally sym
        Common_::Name.via_lowercase_with_underscores_symbol( sym ).
            as_camelcase_const_string.intern
      end

      def __valid_const_via_normal_name_symbol ref_sym
        c = @_valid_const_via_normal_name_symbol[ ref_sym ]
        if c
          c
        else
          __valid_const_via_lookup_and_cache ref_sym
        end
      end

      def __valid_const_via_lookup_and_cache ref_sym
        c_s = __internal_key_via_normal_name_symbol ref_sym
        if @module.const_defined? c_s, false
          c = c_s.intern
          @_valid_const_via_normal_name_symbol[ ref_sym ] = c
          c
        end
      end

      def __index_all

        @_do_index = false

        @module.constants.each do |c|

          _ref_sym = __normal_symbol_name_via_internal_key c

          # any of these that we have already seen we are creating
          # redundantly (because we don't index early). ich muss sein

          @_valid_const_via_normal_name_symbol[ _ref_sym ] = c
        end
      end

      def _dereference_via_internal_key c
        @module.const_get c, false
      end

      def __internal_key_via_normal_name_symbol ref_sym
        Common_::Name.via_variegated_symbol( ref_sym ).as_camelcase_const_string
      end

      def __normal_symbol_name_via_internal_key c
        Common_::Name.via_const_symbol( c ).as_variegated_symbol
      end

    # -

    # ==

    Tupling = ::Class.new  # (forward declaration)

    class GenericTupling___ < Tupling

      def to_description
        @node.type.id2name
      end
    end

    class Tupling

      # NOTE - this name will change
      # NOTE - this is the oldschool guy. subject to get rewritten fully

      class << self
        alias_method :via_node_, :new
        undef_method :new
      end  # >>

      def initialize n
        @node = n
        # (can't freeze because we derive things lazily e.g #here1) :#here2
      end

      def new_by
        mutable = self.class.allocate
        mutable.__init_as_recorder
        yield mutable
        mutable.__finish_mutation_against @node
      end

      def __init_as_recorder
        @_pending_writes_ = []
      end

      def __finish_mutation_against node

        _a_a = remove_instance_variable :@_pending_writes_

        shallowly_mutable_array = node.children.dup

        _a_a.each do |(d, x)|  # #here3
          shallowly_mutable_array[ d ] = x
        end

        shallowly_mutable_array.freeze

        _new_properties = { location: node.location }

        @node = node.updated(
          nil,
          shallowly_mutable_array,
          _new_properties,
        )

        self  # not freezing because #here2
      end

      def to_code
        # (we know we want to improve this but we are locking it down)
        Home_.lib_.unparser.unparse @node
      end

      # --
      #   these are insane but it's OK. the first time they are called, they
      #   ** REWRITE THE METHOD OF THE ACTUAL CLASS ** (not singleton class)

      def _lazy_auto_setter_ x

        m = caller_locations( 1, 1 )[0].base_label.intern

        cmp = _component_via_symbol m[ 0 ... -1 ].intern

        _method_body = Writers__.const_get( cmp._via_, false )[ m, cmp ]

        _redefine_method _method_body, m

        send m, x  # dogfood
      end

      def _lazy_auto_getter_

        m = caller_locations( 1, 1 )[0].base_label.intern

        cmp = _component_via_symbol m

        _method_body = Readers__.const_get( cmp._via_, false )[ m, cmp ]

        _redefine_method _method_body, m

        send m  # dogfood
      end

      def _redefine_method method_body, m
        cls = self.class
        cls.send :undef_method, m
        cls.send :define_method, m, method_body
      end

      def _component_via_symbol sym
        self.class::COMPONENTS.fetch sym
      end

      # --

      def begin_lineno__
        @node.location.first_line
      end

      def end_lineno__
        @node.location.last_line
      end

      def node_loc  # meh
        @node.loc
      end
    end

    # ==

    class Component

      # NOTE - might deprecate - holdover from old way

      class << self
        alias_method :[], :new
        undef_method :new
      end  # >>

      def initialize offset: nil, type: nil, via: nil
        @offset = offset
        type and @type_symbol = type
        via and @_via_ = via
        freeze
      end

      attr_reader(
        :offset,
        :type_symbol,
        :_via_,
      )
    end

    #
    # Component readers and writers
    #

    Writers__ = ::Module.new
    Readers__ = ::Module.new

    # ==

    Writers__::Symbol_via_symbol = -> cmp_sym, cmp do
      -> sym do
        @_pending_writes_.push [ cmp.offset, sym ] ; sym  # per #here3
      end
    end

    Readers__::Symbol_via_symbol = -> cmp_sym, cmp do

      Memoize_into_ivar__.call cmp_sym, cmp do |offset|
        -> do
          sym = @node.children[ offset ]
          ::Symbol === sym || fail
          sym
        end
      end
    end

    # ==

    Readers__::String_via_module_identifier = -> cmp_sym, cmp do

      Memoize_into_ivar__.call cmp_sym, cmp do |offset|
        -> do
          _sym_a = Symbol_array_via_module_identifier_recursive__[ @node.children[ offset ] ]
          _sym_a.join( COLON_COLON_ ).freeze
        end
      end
    end

    #
    # component readers and writers (support)
    #

    # support for component readers

    Symbol_array_via_module_identifier_recursive__ = -> n do

      # :#temporary-spot-1

      if :const == n.type
        a = n.children
        2 == a.length || fail
        recu = a[0]
      end

      res_a = if recu
        Symbol_array_via_module_identifier_recursive__[ recu ]
      else
        []
      end

      case n.type
      when :const
        c = a[1]
        ::Symbol === c || fail
        res_a.push c
      when :cbase
        # test_support/lib/skylab/test_support.rb:2
        res_a.push NOTHING_
      when :self
        res_a.push :self  # meh
      else
        self._COVER_ME___weahhhh___
      end
    end

    # support for component writers

    Memoize_into_ivar__ = -> cmp_sym, cmp, & pp do

      p = pp[ cmp.offset ]
      ivar = :"@___GENERATED_#{ cmp_sym }"
      -> do
        if instance_variable_defined? ivar
          instance_variable_get ivar
        else
          x = instance_exec( & p )
          instance_variable_set ivar, x  # :#here1
          x
        end
      end
    end

    # ==

    COLON_COLON_ = '::'

    # ==
    # ==
  end
end
# #broke-out from "selector via string"
