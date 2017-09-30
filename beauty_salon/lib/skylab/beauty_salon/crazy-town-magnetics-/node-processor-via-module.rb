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

      # -- grammar symbol services

      def __child_association_via_symbol_and_offset_ sym, d

        # NOTE - the below might become procedurally generated or etc. ("RX")
        md = /\A
          (?<any> any_ )?

          (?:
           (?<zero_or_more> zero_or_more_ ) |
           (?<one_or_more> one_or_more_ )
          )?

          (?<stem>  .+   )
          _

          (?<probablistic_group>
            (?!component)
            [a-z]*[a-rt-z]
          )
          s?
          (?<component>
            _component
          )?
        \z/x.match sym
        md || fail

        # -- lvars not matchdata (for some) just for readability

        if md.offset( :zero_or_more ).first
          has_expectation_of_zero_or_more = true
          has_plural_arity = true
        elsif md.offset( :one_or_more ).first
          has_plural_arity = true
        end

        is_any = md.offset( :any ).first
        is_component = md.offset( :component ).first
        pgroup = md[ :probablistic_group ].intern

        # -- use the lvars

        same = -> o do
          o.association_symbol = sym
          o.offset = d
        end

        if is_component

          # #open #here6
          has_plural_arity && readme
          is_any && readme
          :expression == pgroup || readme

          ComponentAssociation___.define do |o|
            o.stem_symbol = md[ :stem ].intern
            same[ o ]
          end
        else
          StructuredChildAssociation___.define do |o|
            # (which ivars are set show a "feature bias")
            if :expression != pgroup
              o.group_symbol = pgroup
              o.group_information = __group_etc pgroup
            end
            if has_plural_arity
              o.has_plural_arity = true
              if has_expectation_of_zero_or_more
                o.has_expectation_of_zero_or_more = true
              end
            end
            if is_any
              o.is_any = true
            end
            same[ o ]
          end
        end
      end

      def __group_etc pgroup
        cache = ( @___groups_cache ||= {} )
        cache.fetch pgroup do
          _h = @module.const_get :GROUPS, false
          _a = _h.fetch pgroup  # ..
          x = ::Hash[ _a.map { |sym| [ sym, true ] } ].freeze
          cache[ pgroup ] = x
          x
        end
      end

      # --

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

        # NOTE - when grammar is implemented through the "structured" approach
        # comprehensively, there should be no need for soft lookup ever (right?) #todo

        # while #open [#022] acceptance 4

        if :send == ref_sym
          dereference ref_sym
        else
        c = __valid_const_via_normal_name_symbol ref_sym
        if c
          _dereference_via_internal_key c
        end
        end
      end

      def dereference sym
        _c = __class_const_via_name_symbol sym
        cls = @_items_module.const_get _c, false  # :#here4
        cls.tap_class  # see
        cls
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

          # redundant with #here4, do a thing to the class only once
          _cls = @_items_module.const_get c, false
          _cls.__receive_constituent_construction_services_ self

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

    class TRAVERSAL_EXPERIMENT__  # (maybe rename to "recurse")

      def self.call ast, recv, gram_symbol

        ai = gram_symbol.children_association_index

        cx = ast.children
        num_children = cx.length

        if ai.minimum_number_of_children > num_children
          raise MyException__.new :minimum_number_of_children_not_satisfied
        end

        if (( max = ai.maximum_number_of_children )) && max < num_children
          raise MyException__.new :maximum_number_of_children_exceeded
        end

        ascs = ai.associations

        visit = -> x, asc do  # #todo
          if x
            if (( gi = asc.group_information )) && ! gi[ x.type ]
              raise MyException__.new :group_affiliation_not_met
            end
            recv[ x, asc ]
          elsif asc.is_any
            recv[ x, asc ]
          else
            raise MyException__.new :missing_expected_child
          end
        end

        if ai.has_plural_arity_as_index

          ai.for_offsets_stretched_to_length num_children do |o|

            o.first_third do |d|
              visit[ cx.fetch( d ), ascs.fetch( d ) ]
            end

            asc = ascs.fetch ai.offset_of_association_with_plural_arity
            o.middle_third do |cx_d|
              visit[ cx.fetch( cx_d ), asc ]
            end

            o.final_third do |cx_d, asc_d|
              visit[ cx.fetch( cx_d ), ascs.fetch( asc_d ) ]
            end
          end
        else
          cx.each_with_index do |x, d_|
            visit[ x, ascs.fetch( d_ ) ]
          end
        end
        NIL
      end

      class << self
        alias_method :[], :call
      end  # >>
    end

    # ==

    class GrammarSymbol

      class << self

        def inherited chld
          chld.__init_as_grammar_symbol_class
        end

        def __init_as_grammar_symbol_class
          @__mutex_for_define_children = nil
        end

        def __receive_constituent_construction_services_ x  # #testpoint
          @_constituent_construction_services = x
        end

        def _constituent_construction_services
          @_constituent_construction_services  # hi.
        end

        def children * sym_a
          remove_instance_variable :@__mutex_for_define_children  # implicit assertion - only once
          @_child_associations_index = :__child_associations_index_initially
          @__unevaluated_definition_of_children = sym_a
        end

        # -- read

        def accept_visitor_by ast, & p
          TRAVERSAL_EXPERIMENT__[ ast, p, self ]
        end

        # ~

        def dereference_component__ sym  # #testpoint
          _d = _component_index.fetch( sym )
          children_association_index.associations.fetch _d
        end

        def component_index_has_reference_as_function__
          h = _component_index
          -> k do
            h.key? k  # hi.
          end
        end

        def component_index_to_symbolish_reference_scanner__  # #testpoint
          _h = _component_index
          Scanner_[ _h.keys ]
        end

        def _component_index
          send( @_component_index ||= :__component_index_initially )
        end

        def __component_index_initially
          @_component_index = :__component_index
          ai = children_association_index
          if ! ai.has_components
            self._COVER_ME__meh_no_components_meh__
          end
          @__component_index = ComponentIndex_via_AssociationIndex___[ ai ]
          send @_component_index
        end

        def __component_index
          @__component_index
        end

        # ~

        def children_association_index
          send @_child_associations_index
        end

        def __child_associations_index_initially

          @_child_associations_index = :__child_associations_index_subsequently

          _sym_a = remove_instance_variable :@__unevaluated_definition_of_children
          svcs = @_constituent_construction_services

          index_of_plural = nil
          once = -> d do
            index_of_plural = d ; once = nil
          end

          a = []
          has_components = false

          _sym_a.each_with_index do |sym, d|

            asc = svcs.__child_association_via_symbol_and_offset_ sym, d

            if asc.is_component

              if asc.has_plural_arity
                self._COVER_ME__cant_be_both_component_and_have_plural_arity__
              end
              has_components = true

            elsif asc.has_plural_arity
              once[ d ]
            end

            a.push asc
          end

          # (we can't write methods until we know if there's a plural)

          ai = ChildAssociationIndex___.new index_of_plural, has_components, a.freeze

          if index_of_plural

            num_ascs = a.length
            ai.for_offsets_stretched_to_length num_ascs do |o|

              o.first_third do |d|
                a.fetch( d )._write_methods_for_non_plural_ self, d
              end

              neg = - num_ascs
              o.middle_third do |d|

                # make a reader for variable-length segment of the children.
                # we don't know beforehand how many children we will have
                # (only that the number accords to our arity category :#here5).
                # the subject range for any given actual array of children is
                # a function of: the formal offset of the subject association,
                # the number of formals, and the number of actual children.

                _hard_offset = d + neg
                0 > _hard_offset || fail
                a.fetch( d ).__write_methods_for_plural_ self, _hard_offset
              end

              o.final_third do |d|
                a.fetch( d )._write_methods_for_non_plural_ self, d + neg
              end
            end
          else
            a.each_with_index do |asc, d|
              asc._write_methods_for_non_plural_ self, d
            end
          end

          @__CAI = ai
          send @_child_associations_index
        end

        def __child_associations_index_subsequently
          @__CAI
        end

        def tap_class  # hacky thing to set breakpoints for particular classes, from the "grammar"
          NOTHING_
        end

        def GRAMMAR_SYMBOL_IS_OLD_WAY
          false
        end

        alias_method :via_node_, :new
        undef_method :new
      end  # >>

      def initialize n

        # if you're using this class for wrapping (not just traversal), we
        # bring out the big guns. the next line:
        #
        #   - evaluates the association definitions if they haven't
        #     been evaluatied yet, which writes methods to our class (yikes!)

        _ai = self.class.children_association_index

        _ai.associations.each do |asc|

          instance_variable_set asc.appropriate_ivar, asc.method_name_for_read_initially
        end
        @_node_ = n  # so named because @ordinary_ivars are in userspace
      end

      def new_by & edit
        CrazyTownMagnetics_::StructuredNode_via_Writes.call_by do |o|
          o.structured_node = self
          o.edit = edit
        end
      end

      def _node_children_normalized_BS
        @___node_children_normalized_BS ||= __node_children_normalized_BS
      end

      def __node_children_normalized_BS
        # of children/each child, assert trueish-ness (any-ness), group,
        # and children length. (the lattermost is assumed #here5)
        a = []
        self.class.accept_visitor_by @_node_ do |x, _asc|
          a.push x
        end
        a.freeze
      end

      def _build_structured_child_BS ast
        _svcs = self.class._constituent_construction_services
        _cls = _svcs.dereference ast.type
        _cls.via_node_ ast
      end

      # -- special interests

      def to_code
        # #copy-paste modified from #here7
        # (we know we want to improve this but we are locking it down)

        lib = Home_.lib_
        # ~(it's futile trying to get rid of the warning - maybe
        _unp = lib.unparser
        # ~)
        _unp.unparse @_node_
      end

      def begin_lineno__
        _node_location.first_line
      end

      def end_lineno__
        _node_location.last_line
      end

      def _node_location
        @_node_.location
      end

      alias_method :node_location, :_node_location  # meh

      attr_reader(
        :_node_,
      )
    end

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

        def GRAMMAR_SYMBOL_IS_OLD_WAY
          true
        end

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
        # #copy-pasted to #here7
        # (we know we want to improve this but we are locking it down)
        Home_.lib_.unparser.unparse @node
      end

      # --
      #   these are insane but it's OK. the first time they are called, they
      #   ** REWRITE THE METHOD OF THE ACTUAL CLASS ** (not singleton class)

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

      def node_location  # meh
        @node.location
      end
    end

    # ==

    ComponentIndex_via_AssociationIndex___ = -> ai do
      # -
        hard_offset_via_component_stem_symbol = {}

        ascs = ai.associations
        num_assocs = ascs.length

        ai.for_offsets_stretched_to_length num_assocs do |o|

          o.first_third do |d|
            asc = ascs.fetch d
            if asc.is_component
              hard_offset_via_component_stem_symbol[ asc.stem_symbol ] = d
            end
          end

          o.middle_third do |_|
            NOTHING_
          end

          neg = - num_assocs
          o.final_third do |d|
            asc = ascs.fetch d
            if asc.is_component
              hard_offset_via_component_stem_symbol[ asc.stem_symbol ] = d + neg
            end
          end
        end

        hard_offset_via_component_stem_symbol
      # -
    end

    # ==

    class ChildAssociationIndex___

      def initialize d, has_components, a
        len = a.length
        if d
          if a.fetch( d ).has_expectation_of_zero_or_more
            min = len - 1
          else
            min = len
          end
          @number_of_associations_at_the_end = len - d - 1
          @offset_of_association_with_plural_arity = d
          @has_plural_arity_as_index = true
        else
          min = len
          max = len
        end

        if has_components
          @has_components = true
        end

        @minimum_number_of_children = min
        @maximum_number_of_children = max
        @associations = a
        freeze
      end

      def for_offsets_stretched_to_length num_children, & p

        # assume has plural arity. abstract the traversal of an array of
        # real children, associated with their corresponding associations.
        # could be efficitized, but meh

        a = [] ; TheseHooks___.new a, p
        first, mid, final = a ; a = nil

        here = @offset_of_association_with_plural_arity
        here.times( & first )

        cx_d = here
        num_at_end = @number_of_associations_at_the_end
        stop_here = num_children - num_at_end - 1

        begin
          mid[ cx_d ]
          stop_here == cx_d and break
          cx_d += 1
          redo
        end while above

        asc_d = here
        num_at_end.times do
          cx_d += 1 ; asc_d += 1
          final[ cx_d, asc_d ]
        end
        NIL
      end

      attr_reader(
        :associations,
        :has_components,
        :has_plural_arity_as_index,
        :minimum_number_of_children,
        :maximum_number_of_children,
        :number_of_associations_at_the_end,
        :offset_of_association_with_plural_arity,
      )
    end

    class TheseHooks___
      def initialize a, p
        @a = a ; p[ self ] ; remove_instance_variable :@a  # sanity
      end
      def first_third & p
        @a[0] = p
      end
      def middle_third & p
        @a[1] = p
      end
      def final_third & p
        @a[2] = p
      end
    end

    CommonChildAssociation__ = ::Class.new Common_::SimpleModel

    class ComponentAssociation___ < CommonChildAssociation__

      # #open :#here6: from the inside and outside, this is undergoing an
      # "emergent design" incubation period. for one thing it needs a name change

      def initialize
        yield self
        super
      end

      attr_accessor(
        :stem_symbol,
      )

      def _write_methods_for_non_plural_ cls, hard_offset

        # currently while we assume that COMPONENT is a simple primary,
        # likewise keep the reading simple - memoization wouldn't gain anything

        cls.send :define_method, @stem_symbol do
          @_node_.children.fetch hard_offset
        end
      end

      def type_symbol
        # here is a key point of #open [#007.F] - see how we would like this
        # to be declared instead of us just assuming it here:
        :symbol
      end

      def group_information
        NOTHING_
      end

      def is_component
        true
      end

      def has_plural_arity
        false
      end
    end

    class StructuredChildAssociation___ < CommonChildAssociation__

      def initialize
        yield self
        @method_name_for_read_subsequently = :"__#{ @association_symbol }_subsequently"
        super
      end

      attr_accessor(
        :group_information,
        :group_symbol,
        :has_expectation_of_zero_or_more,  # assume `has_plural_arity`
        :has_plural_arity,
        :is_any,
      )

      def __write_methods_for_plural_ cls, hard_offset

        r = @offset .. hard_offset

        _write_memoizing_methods cls, @association_symbol do
          cx = @_node_.children
          cx.frozen? || sanity
          sublist = cx[ r ].freeze
          # (you could maintain a mapping between offset systems instead, but meh)
          SickMemoizerBro___.new sublist.length do |d|
            ast = sublist.fetch d
            ast || sanity
            _build_structured_child_BS ast
          end
        end
      end

      def _write_methods_for_non_plural_ cls, hard_offset  # put at for STRUCT CHILD

        # NOTE move this comment #todo
        # here is an example of where we expose structured recursion to the
        # same kind of structural validation we assert when traversing otherwise

        _write_memoizing_methods cls, @association_symbol do
          _x_a = _node_children_normalized_BS
          ast = _x_a.fetch hard_offset
          if ast
            _build_structured_child_BS ast
          end
        end
      end

      attr_reader(
        :method_name_for_read_subsequently,
      )

      def is_component
        false
      end
    end

    class CommonChildAssociation__

      def initialize
        @appropriate_ivar = :"@#{ @association_symbol }"
        @method_name_for_read_initially = :"__#{ @association_symbol }_initially"
        freeze
      end

      attr_accessor(
        :association_symbol,
        :offset,
      )

      def _write_memoizing_methods cls, m, & p

        # an abstraction of the common pattern for implementing a lazily
        # memoized property by using an ivar (named exactly as the property)
        # that holds a method name used to read the property.

        asc = self ; ivar = @appropriate_ivar ; k = @association_symbol

        cls.class_exec do

          define_method m do
            send instance_variable_get ivar
          end

          define_method asc.method_name_for_read_initially do
            _x = instance_exec( & p )
            ( @_structured_child_cache_ ||= {} )[ k ] = _x
            instance_variable_set ivar, asc.method_name_for_read_subsequently
            send instance_variable_get ivar
          end

          define_method asc.method_name_for_read_subsequently do
            @_structured_child_cache_.fetch k
          end
        end
        NIL
      end

      attr_reader(
        :appropriate_ivar,
        :method_name_for_read_initially,
      )
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

    Readers__ = ::Module.new

    # ==

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

    class MyException__ < ::Exception  # #testpoint

      def initialize sym
        @symbol = sym
      end

      def message
        @symbol.id2name.gsub UNDERSCORE_, SPACE_
      end

      attr_reader(
        :symbol,
      )
    end

    # ==

    class SickMemoizerBro___

      def initialize d, & p
        @_state_via_offset = ::Array.new d
        @_cached_value_via_offset = ::Array.new d
        @_proc = p
        @length = d
      end

      def dereference d
        state = @_state_via_offset.fetch d
        if state
          :cached == state || no
          @_cached_value_via_offset.fetch d
        else
          @_state_via_offset[ d ] = :locked
          @_cached_value_via_offset[ d ] = @_proc[ d ]
          @_state_via_offset[ d ] = :cached
          dereference d
        end
      end

      attr_reader(
        :length,
      )
    end

    # ==

    COLON_COLON_ = '::'

    # ==
    # ==
  end
end
# #broke-out from "selector via string"
