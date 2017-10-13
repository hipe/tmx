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

          (?<plurality>
            (?<zero_or>
              zero_or_ (?:
                more_ |
                (?<max_is_one> one_ )
              )
            ) |
            one_or_more_
          )?
          (?<rest> .+ )
        \z/x.match sym

        # -- first, depluralize (and finish using the matchdata)

        if md.offset( :plurality ).first
          has_plural_arity = true
          if md.offset( :zero_or ).first
            if md.offset( :max_is_one ).first
              max_is_one = true
            end
          else
            min_is_one = true
          end
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

          if has_plural_arity && ! max_is_one
            raise MyException_.new :terminals_cannot_currently_be_plural_for_lack_of_need
          end

          if is_any
            raise MyException_.new :we_have_never_needed_terminals_to_have_the_ANY_modifier
          end

          TerminalAssociation___.define do |o|

            if max_is_one
              o.BE_SPECIAL
            end

            o.stem_symbol = stem
            o.type_symbol = terminal_type_sym
            o.terminal_type_sanitizers = @module::TERMINAL_TYPE_SANITIZERS
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
              if min_is_one
                o.minimum_is_one = true
              elsif max_is_one
                o.maximum_is_one = true
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
            GenericGrammarSymbol___  # after #open #[#048] we shouldn't need these
          end
        end
      end

      def has_reference__ k
        # (assume result is cached so you don't techincally need to cache it here)
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

      # ~( ##spot1.3: probably has redunancy with this other levenshtein

      def __when_not_found listener, k

        me = self
        listener.call :error, :expression, :parse_error do |y|
          me.__levenshtein_into_under y, k, self
        end
        UNABLE_
      end

      def __levenshtein_into_under y, ick_sym, expag

        scn = to_symbolish_reference_scanner_  # see

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

      def to_symbolish_reference_scanner_
        $stderr.puts "MAKE A NAME OUT OF EVERYTHING ONCE"

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

      # ~)

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
          cls.receive_constituent_construction_services_ self
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

    class GenericGrammarSymbol___

      # (we shouldn't need this any more now that we have structured uber-alles. but confirm at #open [#048])

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

        def receive_constituent_construction_services_ x  # #testpoint
          @_constituent_construction_services = x
        end

        def __constituent_construction_services
          @_constituent_construction_services  # hi.
        end

        def children * sym_a

          # (exactly as described in the implementation section of [#022.E])

          if self::ASSOCIATIONS
            raise MyException_.new :cannot_redefine_or_add_to_any_existing_children_definition
          end

          const_set :ASSOCIATIONS, LazilyEvaluatedChildren___.new( self, sym_a )
          NIL
        end

        # -- read

        def each_qualified_child n

          # (you may be tempted to want to optimize this for, say, singleton
          # grammar symbols (that never have children) so you can write this
          # assuming a scanner with at least one element; BUT even when the
          # formal length expectation is zero, we still have to check this
          # formal assumption against the actual length (provided that that's
          # still our [#007.D] provision) and it behooves us to do all such
          # assertion with the same machinery.) #testpoint2.11

          scn = build_qualified_children_scanner_for_ n

          until scn.no_unparsed_exists
            _x = if scn.current_association_is_terminal
              scn.current_terminal_AST_node
            else
              scn.current_nonterminal_AST_node
            end
            yield _x, scn.current_association
            scn.advance_one
          end
        end

        def build_qualified_children_scanner_for_ n
          CrazyTownMagnetics_::Dispatcher_via_Hooks::
              QualifiedChildrenScanner.for n, association_index
        end

        # ~

        def dereference_terminal_association__ sym  # #testpoint
          _d = _terminal_association_index.fetch( sym )
          association_index.associations.fetch _d
        end

        def terminal_association_index_has_reference_as_function__
          h = _terminal_association_index
          -> k do
            h.key? k  # hi.
          end
        end

        def to_symbolish_reference_scanner_of_terminals_as_grammar_symbol_class__  # #testpoint
          _h = _terminal_association_index
          Scanner_[ _h.keys ]
        end

        def _terminal_association_index
          send( @_terminal_association_index ||= :__terminal_association_index_initially )
        end

        def __terminal_association_index_initially
          @_terminal_association_index = :__terminal_association_index
          ai = association_index
          if ! ai.has_writable_terminals
            self._COVER_ME__meh_no_terminals_meh__
          end
          @__terminal_association_index = TerminalAssociationIndex_via_AssociationIndex___[ ai ]
          send @_terminal_association_index
        end

        def __terminal_association_index
          @__terminal_association_index
        end

        # ~

        def MEMBERS  # not covered, use in development
          association_index.associations.map do |asc|
            asc._SYMBOL_FOR_MEMBERS_
          end
        end

        def association_index
          asc = self::ASSOCIATIONS
          if ! asc.__is_realized_
            asc.__realize_ @_constituent_construction_services
          end
          asc.__index_
        end

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

        _ai = self.class.association_index

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
        self.class.each_qualified_child @_node_ do |x, _asc|
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

        ai = AssociationIndex___.new(
          remove_instance_variable( :@__unevaluated_definition_of_children ),
          svcs )

        # (we can't write methods until we know if there's a plural)

        if ai.has_plural_arity_as_index
          Write_methods_for_variable_length_children_array___[ cls, ai ]
        else
          ai.associations.each_with_index do |asc, d|
            asc._write_methods_for_non_plural_ cls, d
          end
        end

        @__index_ = ai
        NIL
      end

      attr_reader(
        :__index_,
        :__is_realized_,
      )
    end

    # ==

    Write_methods_for_variable_length_children_array___ = -> cls, ai do

      a = ai.associations
      here = ai.offset_of_association_with_plural_arity
      plur_asc = a.fetch here
      num_ascs = a.length

      ai._each_association_offset_categorized do |o|

        o.first_third do |d|
          a.fetch( d )._write_methods_for_non_plural_ cls, d
        end

        neg = - num_ascs

        o.middle_third do |d|
          d == here || sanity
          if plur_asc.maximum_is_one
            plur_asc.__write_methods_for_winker_ cls, here, num_ascs  # (see)
          else
            _hard_offset = d + neg
            0 > _hard_offset || fail
            plur_asc.__write_methods_for_plural_ cls, _hard_offset  # (see)
          end
        end

        o.final_third do |d|
          a.fetch( d )._write_methods_for_non_plural_ cls, d + neg
        end
      end
    end

    # ==

    TerminalAssociationIndex_via_AssociationIndex___ = -> ai do
      # -
        hard_offset_via_terminal_stem_symbol = {}

        ascs = ai.associations
        num_assocs = ascs.length

        ai._each_association_offset_categorized do |o|

          o.first_third do |d|
            asc = ascs.fetch d
            if asc.is_terminal
              hard_offset_via_terminal_stem_symbol[ asc.stem_symbol ] = d
            end
          end

          o.middle_third do |_|
            NOTHING_
          end

          neg = - num_assocs
          o.final_third do |d|
            asc = ascs.fetch d
            if asc.is_terminal
              hard_offset_via_terminal_stem_symbol[ asc.stem_symbol ] = d + neg
            end
          end
        end

        hard_offset_via_terminal_stem_symbol
      # -
    end

    # ==

    class AssociationIndex___  # #testpoint

      def initialize sym_a, svcs

        plur_d = nil
        once = -> d do
          plur_d = d ; once = nil
        end

        a = []
        has_writable_terminals = false

        sym_a.each_with_index do |sym, d|

          asc = svcs.__child_association_via_symbol_and_offset_ sym, d

          if asc.is_terminal

            if asc.has_plural_arity && ! asc.maximum_is_one
              ::Kernel._COVER_ME__cant_be_both_terminal_and_have_truly_plural_arity__
            end
            has_writable_terminals = true

          elsif asc.has_plural_arity
            once[ d ]
          end

          a.push asc
        end

        # -- only: plur_d, has_writable_terminals, a

        len = a.length
        if plur_d

          plur_asc = a.fetch plur_d

          if plur_asc.minimum_is_one
            min = len
            max = NO_LIMIT_

          elsif plur_asc.maximum_is_one
            min = len - 1
            max = len

          else
            min = len - 1
            max = NO_LIMIT_
          end

          @number_of_associations_at_the_end = len - plur_d - 1
          @offset_of_association_with_plural_arity = plur_d
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

      def _each_association_offset_categorized( & p )  # #testpoint

        # (this used to be the "stretch" thing)

        CrazyTownMagnetics_::Dispatcher_via_Hooks::
            EachAssociationOffsetCategorized[ p, self ]
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

    CommonChildAssociation__ = ::Class.new Common_::SimpleModel

    class TerminalAssociation___ < CommonChildAssociation__

      def initialize
        @has_plural_arity = false
        yield self
        super
      end

      def BE_SPECIAL  # experiment for #spot1.2
        @has_plural_arity = true
      end

      attr_writer(
        :terminal_type_sanitizers,
      )

      attr_accessor(
        :stem_symbol,
        :type_symbol,
      )

      def _write_methods_for_non_plural_ cls, hard_offset

        # keep it simple - memoization wouldn't gain anything.
        # since it's a terminal (i.e primitive) value, there's not wrapping

        cls.send :define_method, @stem_symbol do
          @_node_.children.fetch hard_offset
        end
      end

      def assert_type_of_terminal_value_ x  # as documented at [#022.F]

        _x = @terminal_type_sanitizers.fetch @type_symbol
        _yes = _x[ x ]
        if ! _yes
          raise MyException_.new :terminal_type_assertion_failure
        end
      end

      # ~ )

      def _SYMBOL_FOR_MEMBERS_
        @stem_symbol
      end

      def group_information
        NOTHING_
      end

      attr_reader(
        :has_plural_arity,
      )

      def maximum_is_one  # only when relevant
        true
      end

      def is_terminal
        true
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
        :maximum_is_one,  # assume `has_plural_arity`, assume never co-occurs with below
        :minimum_is_one,  # assume `has_plural_arity`, assume never co-occurs with above
        :has_plural_arity,
        :is_any,
      )

      def __write_methods_for_plural_ cls, hard_offset

        # make a reader for variable-length segment of the children. we
        # don't know beforehand how many children we will have (only that
        # the number accords to our arity category :#here5). the subject
        # range for any given actual array of children is a function of:
        # the formal offset of the subject association, the number of
        # formals, and the number of actual children.

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

      def __write_methods_for_winker_ cls, here, num_ascs

        # "winker" is now shorthand for "association whose arity is zero or
        # one". this means its actual value can either be there nor not be
        # there. whereas in the case of the "any" modifier the value can
        # either be nil or not nil, but must take up width (one slot) in the
        # children array; in the subject case when the value is not present
        # it takes up no width in the array.
        #
        # although (like the "plural" association above) the children array
        # has a variable length segment; the maximum possible length for this
        # segment is 1 making the use of the "list" structure superflous here.
        #
        # #[#022.G]

        _write_memoizing_methods cls, @association_symbol do

          x_a = _node_children_normalized_BS
          case x_a.length
          when num_ascs  # #testpoint1.52
            ast = x_a.fetch here
            if ast
              _build_structured_child_BS ast
            end
          when num_ascs - 1  # #testpoint1.51
            NOTHING_
          else
            never
          end
        end
      end

      def _write_methods_for_non_plural_ cls, hard_offset  # put at for STRUCT CHILD

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
    NO_LIMIT_ = nil

    # ==
    # ==
  end
end
# #tombstone-A.2: replaced recursive method call-based traversal with scanner-based
# #tombstone-A.1: changed association store to accomodate inheritence
# #broke-out from "selector via string"
