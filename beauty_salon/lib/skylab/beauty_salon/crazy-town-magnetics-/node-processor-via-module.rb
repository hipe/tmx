# frozen_string_literal: true

module Skylab::BeautySalon

  class CrazyTownMagnetics_::NodeProcessor_via_Module

    # see "declarative (structural) grammar reflection" :[#022.A]

    # implementation-wise, we employ the [#ze-051] "operator branch" pattern
    #
    #   - superficially simliar to [#ze-051.2] but it's simple enough we
    #     might as well re-write it. (we don't take an index-first approach
    #     here.)

    class << self
      alias_method :[], :new
      private :new
    end  # >>

    # -
      def initialize mod

        h = mod::IRREGULAR_NAMES
        if h
          @_unsanitized_const_for = :__unsanitized_const_complicatedly
          @_irregulars_pool = h.dup
        else
          @_unsanitized_const_for = :_unsanitized_const_derivationally
        end

        @_const_for_existent_prepared_class_via_symbol = {}
        @_items_module = mod::Items

        @module = mod
      end

      # -- grammar symbol services

      def __child_association_via_symbol_and_offset_ sym, d  # #testpoint

        # NOTE - the below might become procedurally generated or etc. ("RX")
        md = /\A
          (?<any> any_ )?

          (?:
           (?<zero_or_more> zero_or_more_ ) |
           (?<one_or_more> one_or_more_ )
          )?

          (?<rest> .+ )
        \z/x.match sym

        # -- first, depluralize (and finish using the matchdata)

        if md.offset( :zero_or_more ).first
          has_expectation_of_zero_or_more = true
          has_plural_arity = true
        elsif md.offset( :one_or_more ).first
          has_plural_arity = true
        end

        s_a = md[ :rest ].split UNDERSCORE_
        is_any = md.offset( :any ).first
        md = nil

        if has_plural_arity && /s\z/ =~ s_a.last

          # if the remainder string "looks plural" here what you really
          # mean is the singular form but YIKES will break for some inflections..

          s_a.last[ $~.offset( 0 ).first, 1 ] = EMPTY_S_
        end

        # -- then decice if NT or T

        if s_a.fetch( -1 ) == 'terminal'
          is_terminal = true
          s_a.pop
          terminal_type_sym = s_a.pop.intern
          stem = if s_a.length.zero?
            terminal_type_sym
          else
            s_a.join( UNDERSCORE_ ).intern
          end
        else
          group = s_a.last.intern
          s_a = nil  # nonterminals only use their full association name
        end

        # -- use the lvars

        same = -> o do
          o.association_symbol = sym
          o.offset = d
        end

        if is_terminal

          if has_plural_arity
            raise MyException__.new :terminals_cannot_currently_be_plural_for_lack_of_need
          end

          if is_any
            raise MyException__.new :we_have_never_needed_terminals_to_have_the_ANY_modifier
          end

          TerminalAssociation___.define do |o|
            o.stem_symbol = stem
            o.type_symbol = terminal_type_sym
            same[ o ]
          end
        else
          StructuredChildAssociation___.define do |o|
            # (which ivars are set show a "feature bias")
            if :expression != group
              o.group_symbol = group
              o.group_information = __group_etc group
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

      def __group_etc group
        cache = ( @___groups_cache ||= {} )
        cache.fetch group do
          _h = @module.const_get :GROUPS, false
          _a = _h.fetch group  # ..
          x = ::Hash[ _a.map { |sym| [ sym, true ] } ].freeze
          cache[ group ] = x
          x
        end
      end

      # --

      def procure__ k, & p
        _of k, -> c do
          _the c
        end, -> do
          _load k, IDENTITY_, -> do
            __when_not_found p, k
          end
        end
      end

      def some_structured_node_class_for__ k  # assume client caches result
        _of k, -> c do
          _the c
        end, -> do
          _load k, IDENTITY_, -> do
            GenericGrammarSymbol___  # after #open #[#022.E2] we shouldn't need these
          end
        end
      end

      def has_reference_FOR_TRANSITION_ASSUME_RESULT_IS_CACHED__ k
        _of k, MONADIC_TRUTH_, -> do
          _load k, MONADIC_TRUTH_, EMPTY_P_
        end
      end

      def dereference k
        _of k, -> c do
          _the c
        end, -> do
          _load k, IDENTITY_
        end
      end

      # --

      def __when_not_found listener, k

        me = self
        listener.call :error, :expression, :parse_error do |y|
          me.__levenshtein_into_under y, k, self
        end
        UNABLE_
      end

      def __levenshtein_into_under y, ick_sym, expag

        scn = __woot_scanner  # seee

        y << %(currently we don't yet have metadata for grammar symbol '#{ ick_sym }'.)

        expag.calculate do
          simple_inflection do
            _buff = oxford_join scn do |k|
              "'#{ k }'"
            end
            y << "(currently we have it for #{ _buff }.)"
          end
        end
      end

      def __woot_scanner

        # (we don't want to need this elsewhere. at full realization of #open [#022.E2]..)
        # (it's a serious headache to try to read from the cache and deal with irregular names)

        scn = Home_.lib_.zerk::No_deps[]::Scanner_via_Array.new @_items_module.constants
        same = -> c do
          Common_::Name.via_const_symbol( c ).as_lowercase_with_underscores_symbol
        end
        h = @module::IRREGULAR_NAMES
        if h
          inv = h.invert
          use = -> c do
            inv[ c ] || same[ c ]
          end
        else
          use = same
        end
        scn.map_by do |c|
          use[ c ]  # hi.
        end
      end

      # --

      def _of k, yes, no
        c = @_const_for_existent_prepared_class_via_symbol[ k ]
        if c
          yes[ c ]
        else
          no[]
        end
      end

      def _load k, recv_class, when_not_found=nil
        c = __unsanitized_const_for k
        finish_load = -> do
          cls = _the c
          cls.tap_class  # see
          @_const_for_existent_prepared_class_via_symbol[ k ] = c  # ONLY PLACE
          cls.__receive_constituent_construction_services_ self
          recv_class[ cls ]
        end
        if when_not_found
          if @_items_module.const_defined? c, false
            finish_load[]
          else
            when_not_found[]
          end
        else
          finish_load[]
        end
      end

      def _the c
        @_items_module.const_get c, false
      end

      # --

      def __unsanitized_const_for k
        send @_unsanitized_const_for, k
      end

      def __unsanitized_const_complicatedly sym
        c = @_irregulars_pool.delete sym
        if c
          if @_irregulars_pool.length.zero?
            @_irregulars_pool = nil
            @_unsanitized_const_for = :_unsanitized_const_derivationally
          end
          c
        else
          _unsanitized_const_derivationally sym
        end
      end

      def _unsanitized_const_derivationally k
        Common_::Name.via_lowercase_with_underscores_symbol( k ).
            as_camelcase_const_string.intern
      end
    # -

    # ==

    TRAVERSAL_EXPERIMENT___ = -> ast, recv, gram_symbol do
      # (maybe rename to "recurse")
      # -
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
      # -
    end

    # ==

    class GenericGrammarSymbol___

      # (for perhaps only one report.. should go away after #open [#022.E2])

      class << self
        alias_method :via_node_, :new
        undef_method :new
      end  # >>

      def initialize n
        @__node = n
      end

      def to_description
        @__node.type.id2name
      end
    end

    # ==

    class GrammarSymbol

      class << self

        def __receive_constituent_construction_services_ x  # #testpoint
          @_constituent_construction_services = x
        end

        def __constituent_construction_services
          @_constituent_construction_services  # hi.
        end

        def children * sym_a

          # (exactly as described in the implementation section of [#022.E])

          if self::ASSOCIATIONS
            raise MyException__.new :cannot_redefine_or_add_to_any_existing_children_definition
          end

          const_set :ASSOCIATIONS, LazilyEvaluatedChildren___.new( self, sym_a )
          NIL
        end

        # -- read

        def accept_visitor_by ast, & p
          TRAVERSAL_EXPERIMENT___[ ast, p, self ]
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
          if ! ai.has_writable_terminals
            self._COVER_ME__meh_no_components_meh__
          end
          @__component_index = ComponentIndex_via_AssociationIndex___[ ai ]
          send @_component_index
        end

        def __component_index
          @__component_index
        end

        # ~

        def MEMBERS  # not covered, use in development
          children_association_index.associations.map do |asc|
            asc._SYMBOL_FOR_MEMBERS_
          end
        end

        def children_association_index
          asc = self::ASSOCIATIONS
          if ! asc.__is_realized_
            asc.__realize_ @_constituent_construction_services
          end
          asc.__index_
        end
      end # >>
    end  # (will re-open)

    # ==

    class GrammarSymbol  # (re-open)

      class << self

        def tap_class  # hacky thing to set breakpoints for particular classes, from the "grammar"
          NOTHING_
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
        _svcs = self.class.__constituent_construction_services
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

      ASSOCIATIONS = nil  # as described in [#022.E]
      IS_BRANCHY = false  # experiment. [#007.G]
    end

    # ==

    class LazilyEvaluatedChildren___

      def initialize cls, sym_a

        @__class = cls
        @__is_realized_ = false
        @__unevaluated_definition_of_children = sym_a
      end

      def __realize_ svcs

        cls = remove_instance_variable :@__class
        @__is_realized_ = true

        _sym_a = remove_instance_variable :@__unevaluated_definition_of_children

        index_of_plural = nil
        once = -> d do
          index_of_plural = d ; once = nil
        end

        a = []
        has_writable_terminals = false

        _sym_a.each_with_index do |sym, d|

          asc = svcs.__child_association_via_symbol_and_offset_ sym, d

          if asc.is_terminal

            if asc.has_plural_arity
              cls._COVER_ME__cant_be_both_component_and_have_plural_arity__
            end
            has_writable_terminals = true

          elsif asc.has_plural_arity
            once[ d ]
          end

          a.push asc
        end

        # (we can't write methods until we know if there's a plural)

        ai = ChildAssociationIndex___.new index_of_plural, has_writable_terminals, a.freeze

        if index_of_plural

          num_ascs = a.length
          ai.for_offsets_stretched_to_length num_ascs do |o|

            o.first_third do |d|
              a.fetch( d )._write_methods_for_non_plural_ cls, d
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
              a.fetch( d ).__write_methods_for_plural_ cls, _hard_offset
            end

            o.final_third do |d|
              a.fetch( d )._write_methods_for_non_plural_ cls, d + neg
            end
          end
        else
          a.each_with_index do |asc, d|
            asc._write_methods_for_non_plural_ cls, d
          end
        end

        @__index_ = ai ;
        NIL
      end

      attr_reader(
        :__index_,
        :__is_realized_,
      )
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
            if asc.is_terminal
              hard_offset_via_component_stem_symbol[ asc.stem_symbol ] = d
            end
          end

          o.middle_third do |_|
            NOTHING_
          end

          neg = - num_assocs
          o.final_third do |d|
            asc = ascs.fetch d
            if asc.is_terminal
              hard_offset_via_component_stem_symbol[ asc.stem_symbol ] = d + neg
            end
          end
        end

        hard_offset_via_component_stem_symbol
      # -
    end

    # ==

    class ChildAssociationIndex___

      def initialize d, has_writable_terminals, a
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

        if has_writable_terminals
          @has_writable_terminals = true
        end

        @minimum_number_of_children = min
        @maximum_number_of_children = max
        @associations = a
        freeze
      end

      def for_offsets_stretched_to_length num_children, & p

        # assume has plural arity. abstract the traversal of an array of
        # real children, associated with their corresponding associations.
        # could be efficientized, but meh

        a = [] ; TheseHooks___.new a, p
        first, mid, final = a ; a = nil

        # -- the number of itmes in the 1st 3rd is equal to this one offset

        here = @offset_of_association_with_plural_arity
        here.times( & first )
        cx_d = here - 1

        # -- where we stop in the middle 3rd depends on how many children

        num_at_end = @number_of_associations_at_the_end
        last_offset_of_middle_run = num_children - num_at_end - 1

        until last_offset_of_middle_run == cx_d
          cx_d += 1
          mid[ cx_d ]
        end

        # -- the last 3rd iterates N times, but tell it the asc offset too

        asc_d = here  # will advance immediately
        num_at_end.times do
          cx_d += 1 ; asc_d += 1
          final[ cx_d, asc_d ]
        end
        NIL
      end

      attr_reader(
        :associations,
        :has_plural_arity_as_index,
        :has_writable_terminals,
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

    class TerminalAssociation___ < CommonChildAssociation__

      def initialize
        yield self
        super
      end

      attr_accessor(
        :stem_symbol,
        :type_symbol,
      )

      def _write_methods_for_non_plural_ cls, hard_offset

        # currently while we assume that COMPONENT is a simple primary,
        # likewise keep the reading simple - memoization wouldn't gain anything

        cls.send :define_method, @stem_symbol do
          @_node_.children.fetch hard_offset
        end
      end

      # ~ ( #open [#007.F]
      # having a hard-coded set of available terminal types is kinda awful
      # but A) we're just trying to make it up the run for now and B) we
      # want to let this incubate a bit as we soak out into the grammar.

      def hacky_type_check__ x
        if x
          hacky_type_check_when_trueish_ x
        end
      end

      def hacky_type_check_when_trueish_ x
        case @type_symbol
        when :symbol ; ::Symbol === x || self._COVER_ME__type_mismatch__
        when :integer ; ::Integer === x || self._COVER_ME__type_mismatch__
        else ; self._COVER_ME__its_reasonable_to_want_more_types_here__
        end
      end

      # ~ )

      def _SYMBOL_FOR_MEMBERS_
        @stem_symbol
      end

      def group_information
        NOTHING_
      end

      def is_terminal
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

      def _SYMBOL_FOR_MEMBERS_
        @association_symbol
      end

      attr_reader(
        :method_name_for_read_subsequently,
      )

      def is_terminal
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

    MONADIC_TRUTH_ = -> _ { true }

    # ==
    # ==
  end
end
# #tombstone-A.1: changed association store to accomodate inheritence
# #broke-out from "selector via string"
