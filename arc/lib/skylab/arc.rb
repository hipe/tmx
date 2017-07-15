require 'skylab/common'

module Skylab::Arc  # notes in [#002]
  # ->
    class << self

      def create x_a, acs, & oes_p_p  # :Tenet2, (same as below)

        o = _Mutation_Session.new( & oes_p_p )
        o.accept_argument_array x_a
        o.ACS = acs
        o.macro_operation_method_name = :create
        o.execute
      end

      def edit x_a, acs, & oes_p_p  # :Tenet3, [#006.E] hot binding

        o = _Mutation_Session.new( & oes_p_p )
        o.accept_argument_array x_a
        o.ACS = acs
        o.macro_operation_method_name = :edit
        o.execute
      end

      def interpret scn, acs, & oes_p_p  # #Tenet6, [#006.F] "HB again"

        o = _Mutation_Session.new( & oes_p_p )
        o.ACS = acs
        o.argument_scanner = scn
        o.macro_operation_method_name = :interpret
        o.execute
      end

      def send_component_already_added qk, acs, & oes_p

        oes_p.call :error, :component_already_added do

          Home_::Events::ComponentAlreadyAdded.with(
            :component, qk.value,
            :component_association, qk.association,
            :expectation_matrix, [ false, true, true, true ],  # "already has" not "found existing"
            :ACS, acs,
            :ok, nil,  # overwrite so error becomes info
          )
        end
        UNABLE_  # important
      end

      def send_component_not_found qkn, acs, & oes_p

        oes_p.call :error, :component_not_found do

          Home_::Events::ComponentNotFound.with(
            :component, qkn.value,
            :component_association, qkn.association,
            :ACS, acs,
          )
        end
        UNABLE_  # important
      end

      def send_component_removed qk, acs, & oes_p

        oes_p.call :info, :component_removed do

          Home_::Events::ComponentRemoved.with(
            :component, qk.value,
            :component_association, qk.association,
            :ACS, acs,
          )
        end
        ACHIEVED_
      end

      def _Mutation_Session
        Home_::Magnetics_::Mutate_via_ArgumentScanner_and_Verb_and_ACS
      end

      def marshal_to_JSON * io_and_options, acs, & pp
        Home_::JSON_Magnetics::JSON_via_ACS::Marshal[ io_and_options, acs, & pp ]
      end

      def unmarshal_from_JSON acs, cust, io, & pp
        Home_::JSON_Magnetics::ACS_via_JSON::Unmarshal[ acs, cust, io, & pp ]
      end

      def handler_builder_for acs  # for [#006.D] the hot event model

        block_given? and raise ::ArgumentError

        acs.method :event_handler_for
      end

      def test_support  # #[#ts-035]
        if ! Home_.const_defined? :TestSupport
          require_relative '../../test/test-support'
        end
        Home_::TestSupport
      end

      def lib_
        @___lib ||=
          Common_.produce_library_shell_via_library_and_app_modules(
            Lib_, self )
      end
    end  # >>

  # -- method definitions (forward declared)

  DEFINITION_FOR_THE_METHOD_CALLED_STORE_ = -> ivar, x do
    if x
      instance_variable_set ivar, x ; ACHIEVED_
    else
      x
    end
  end

  # -- these (forward declared)

  Common_ = ::Skylab::Common
  Autoloader_ = Common_::Autoloader
  Lazy_ = Common_::Lazy

  # --

  module AssociationToolkit

    Autoloader_[ self ]
    lazily :Entity_by_Simplicity_via_PersistablePrimitiveNameValuePairStream do |c|
      Home_::Magnetics::QualifiedComponent_via_Value_and_Association.const_get c, false
    end

    ekp = -> do
      Home_.lib_.fields::CommonAssociation::EntityKillerParameter
    end

    Pluralton_powered_parameter_grammatical_injection = Lazy_.call do

      _inj = ekp[].grammatical_injection

      _inj.redefine do |o|

        mod = MyCustomPostfixedModifiers___
        mod.include o.postfixed_modifiers  # yikes
        o.postfixed_modifiers = mod

        o.item_class = My_custom_parameter_class___[]
      end
    end

    module MyCustomPostfixedModifiers___

      # ~( might go up

      def pluralton_association

        @parse_tree.__receive_pluralton_group_symbol_ @scanner.gets_one

        KEEP_PARSING_
      end
      # ~)
    end

    My_custom_parameter_class___ = Lazy_.call do

      class MyCustomParameterClass____ < ekp[]

        def initialize
          @pluralton_group_symbol = nil
          super
        end

        def __receive_pluralton_group_symbol_ group_sym

          @store_by = -> pvs, x, asc do

            _qk = Common_::QualifiedKnownKnown[ x, asc ]

            pvs._insert_via_index_and_association_symbol_ _qk, -1, group_sym

            ACHIEVED_
          end

          @pluralton_group_symbol = group_sym
          NIL
        end

        def do_guard_against_clobber
          ! @pluralton_group_symbol
        end

        attr_reader(
          :pluralton_group_symbol,
          :store_by,
        )

        self
      end
    end

    class DefineAndAssignComponent_via_Block_and_Symbol < Common_::MagneticBySimpleModel

      def initialize
        @_mutex_for_this = nil
        super
      end

      def will_be_add
        remove_instance_variable :@_mutex_for_this
        @_will_be_add = true ; nil
      end

      def will_not_be_clobber
        remove_instance_variable :@_mutex_for_this
        @_will_be_add = false
        @_will_be_clobber = false ; nil
      end

      def will_be_clobber
        remove_instance_variable :@_mutex_for_this
        @_will_be_add = false
        @_will_be_clobber = true ; nil
      end

      def define_entity_by & p
        @entity_definition_block = p
      end

      attr_writer(
        :association_symbol,
        :listener,
        :MODEL_MODULE,
        :mutable_entity,
      )

      def execute
        __init
        if __is_singleton_association
          if __will_clobber
            if _is_already_set
              _resolve_singleton_entity_and_store
            else
              no
            end
          elsif _is_already_set
            no
          else
            _resolve_singleton_entity_and_store
          end
        elsif __will_add
          __resolve_pluralton_entity_and_add
        else
          no
        end
      end

      def __resolve_pluralton_entity_and_add
        if __resolve_pluralton_entity
          __add_pluralton_entity
        end
      end

      def _resolve_singleton_entity_and_store
        if __resolve_singleton_entity
          __set_singleton_entity
        end
      end

      def __resolve_pluralton_entity

        _ = @MODEL_MODULE.define do |o|
          @entity_definition_block[ o ]
        end
        _store :@_entity, _
      end

      def __resolve_singleton_entity

        _ = @_association.model_module.define do |o|
          @entity_definition_block[ o ]
        end
        _store :@_entity, _  # #cov1.1 when not
      end

      def __add_pluralton_entity

        __emit_about_pluralton_add
        @mutable_entity._insert_via_index_and_association_ @_entity, -1, @_association
        @_entity
      end

      def __set_singleton_entity

        # ([#cu-007.B] (yikes) would get closed by following suit here)
        # maybe clobber, maybe not. OK both. #cov1.2
        @mutable_entity._write_via_association_ @_entity, @_association
        @_entity
      end

      def __emit_about_pluralton_add
        @_association.module::On_added[ @listener, @_entity, @mutable_entity ]
        NIL
      end

      # --

      def _is_already_set
        @_qualified_component.is_known_known
      end

      def __will_clobber
        remove_instance_variable :@_will_be_clobber
      end

      def __will_add
        remove_instance_variable :@_will_be_add
      end

      def __is_singleton_association
        @_association.is_singleton_association
      end

      def __init
        @_qualified_component =
          QualifiedComponent_via___[ @association_symbol, @mutable_entity ]
        @_association = @_qualified_component.association
        NIL
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    end

    qualified_component_reader_for = nil
    association_stream_via_entity = nil

    QualifiedComponentStream_via_Entity = -> ent do

      # via the entity produce a stream whose each item is a [#co-004]
      # qualified knownness. the items in the stream will correspond 1-to-1
      # (in the same order) as the *formal* associations of the entity.
      # each such formal association either does or doesn't have an actual
      # component associated with it, and each item will accordingly be a
      # known known or known unknown.
      #
      # "plural" associations are not given special treatement in this
      # arrangement: the association will have one item in this stream
      # regardless of whether the association has an assignment or not.
      # when populated, the value of the item will be the array or
      # comparable collection adapter.

      # -
        read = qualified_component_reader_for[ ent ]
        _st = association_stream_via_entity[ ent ]

        _st.map_by do |asc|
          read[ asc ]  # hi.
        end
      # -
    end

    association_reader_via_entity = nil
    qualified_component_reader_for = nil

    QualifiedComponent_via___ = -> sym, ent do
      # -

        ob = ent._associations_operator_branch_

        _item = ob.dereference sym

        _asc = association_reader_via_entity[ ent ][ _item ]

        qualified_component_reader_for[ ent ][ _asc ]
      # -
    end

    qualified_component_reader_for = -> ent do
      -> asc do
        # -
          x = ent._read_softly_via_association_ asc
          if x || ! x.nil?  # imagine ::BasicObject
            Common_::QualifiedKnownKnown.via_value_and_association x, asc
          else
            Common_::QualifiedKnownUnknown.via_association asc
          end
        # -
      end
    end

    association_stream_via_entity = -> ent do

      # (you don't have to use the filesystem to represent your assocs but it is default)
      # -
        _ob = ent._associations_operator_branch_

        _st = _ob.to_loadable_reference_stream

        asc_via_item = association_reader_via_entity[ ent ]

        _st.map_by do |item|
          asc_via_item[ item ]  # hi.
        end
      # -
    end

    association_reader_via_entity = -> ent do

      prototype = Association___.new ent

      -> item do
        prototype.new item  # hi.
      end
    end

    class Association___

      # (think of this as the first of perhaps a couple kinds of adapters -
      # this one being for our weird new filesystem-based association API)

      def initialize ent

        @__association_module = -> item do
          _mod = item.value
          _mod  # hi. #todo
        end

        @__associated_module = -> item, me do

          if me.is_singleton_association
            _c = item.name.as_const
            _mod = ent._models_module_.const_get _c, false
            _mod  # hi. #todo
          else
            ::Kernel._OKAY
          end
        end

        @model_module = :__associated_model_module_initially
        @module = :__module_initially
        @name = :__name_initially
        @_counter = 0
        freeze  # as prototype. as instance freeze (also) #here1
      end

      def new item
        dup.__init item
      end

      def __init item
        @_remote_item = item
        self
      end

      # --

      def is_singleton_association
        _mod = self.module
        _mod::IS_SINGLETON_ASSOCIATION
      end

      def module
        send @module
      end

      def model_module
        send @model_module
      end

      def __module_initially
        @module = :__module
        @__module =
          remove_instance_variable( :@__association_module )[ @_remote_item ]
        _maybe_freeze
        send @module
      end

      def __associated_model_module_initially
        @model_module = :__model_module
        @__model_module =
          remove_instance_variable( :@__associated_module )[ @_remote_item, self ]
        _maybe_freeze
        send @model_module
      end

      def __module
        @__module
      end

      def __model_module
        @__model_module
      end

      def _maybe_freeze  # sneaky as hell
        if 2 == ( @_counter += 1 )
          @name = :__name_when_frozen
          @__name = remove_instance_variable( :@_remote_item ).name
          remove_instance_variable :@_counter
          freeze ; nil  # :#here1
        end
      end

      def name_symbol
        name.as_lowercase_with_underscores_symbol
      end

      def name
        # (we don't memoize the below name because it might correct itself..)
        send @name
      end

      def __name_initially
        @_remote_item.name
      end

      def __name_when_frozen
        @__name
      end
    end
  end

    # <-
  class ComponentAssociation

    Reader_of_CAs_by_method_in___ = -> ca_class, acs do

      read_association = nil

      when_no_component_model = -> sym, ca do

        if :plural_of == ca.singplur_category

          ref_sym = ca.singplur_referent_symbol
          _m = Method_name_via_name_symbol[ ref_sym ]
          _sing_ca = read_association[ _m, ref_sym ]
          Home_::Magnetics_::KnownKnownBySingularize_via_Associations_and_ACS[ _sing_ca, sym, ca, acs ]
        else
          self._COVER_ME_no_component_model
        end
      end

      read_association = -> m, sym do

        ca = nil

        p = -> x do
          ca = ca_class._begin_via_method_name m
          p = -> x_a do
            ca.send :"accept__#{ x_a.first }__meta_component", * x_a[ 1..-1 ]
            NIL_
          end
          p[ x ]
        end

        cm = acs.send m do | * x_a |  # :Tenet4. - assocs are defined as i.m's
          p[ x_a ]
        end

        if ca

          if cm
            ca._finish_via cm, sym

          elsif :zero == ca.argument_arity

            ca._finish_via Flag___, sym
          else
            when_no_component_model[ sym, ca ]
          end

        elsif cm
          ca_class._begin_via_method_name( m )._finish_via cm, sym

        else
          self._NO_deprecated_use_availability_instead  # #waiting [#025]
        end
      end

      -> token_x do

        if token_x.respond_to? :id2name
          m = Method_name_via_name_symbol[ token_x ]
          if acs.respond_to? m
            read_association[ m, token_x ]
          end
        end
      end
    end

    Method_name_via_name_symbol = -> sym do
      :"__#{ sym }__component_association"
    end

    Flag___ = -> st, & _pp do  # is Any_value
      # experimental, in cahoots with [#ze-044]
      Common_::KnownKnown[ st.gets_one ]
    end
  end
  # ->

    COMPOUND_CONSTRUCTOR_METHOD_ = :interpret_compound_component

    class ComponentAssociation

      # assume that the ACS assumes that these structures are produced
      # lazily, on-the-fly, and are not memoized to be used beyond the
      # "moment": they are #DT3 dynamic and should not be #DT4 cached.

      class << self

        def reader_of_component_associations_by_method_in acs
          Reader_of_CAs_by_method_in___[ self, acs ]
        end

        alias_method :_begin_via_method_name, :new
        private :new
      end  # >>

      # -- Initializers

      def initialize m
        @association_method_name = m
        @_name_mutation = nil
      end

      def prepend_normalization__ p  # #experimental
        model_classifications.looks_primitivesque || self._NO
        otr = dup
        _downstream = @component_model
        otr.instance_variable_set :@component_model, -> st, & pp do
          kn = p[ st, & pp ]
          if kn
            _scn = Field_::Argument_scanner_via_value.via_known_known kn
            _downstream[ _scn, & pp ]
          else
            kn
          end
        end
        otr
      end

      def _finish_via cm, sym

        nf = Common_::Name.via_variegated_symbol sym

        if @_name_mutation
          @_name_mutation[ nf ]  # *mutates*
        end

        _init_via nf, cm
      end

      def _init_via nf, mdl

        remove_instance_variable :@_name_mutation
        @component_model = mdl  # any
        @name = nf
        self
      end

      def model_classifications
        @___cx ||= Classify_model___[ @component_model ]
      end

      def say_no_method__

        # assume model does not look like proc - for use in raising e.g a
        # `NoMethodError` regarding an expected but missing construction
        # method. this exists partly because the platform is strange about
        # when it decides to include the class name in the message.

        a = CONSTRUCTOR_METHODS__.dup
        a.push :[]
        _s_a = a.map { | sym | "`#{ sym }`" }
        _or = Common_::Oxford_or[ _s_a ]

        "must respond to #{ _or } - #{ @component_model.name }"
      end

      # -- Expressive event hook-outs

      def description_under _expag
        @name.as_human
      end

      # -- "meta-components" (similar to #[#fi-010] universal meta-properties)

      # ~ availability (mode client must implement)

      def accept__unavailability__meta_component x
        @unavailability_proc = x
        NIL_
      end

      attr_reader :unavailability_proc

      # ~ description

      def accept__generate_description__meta_component  # [#003.L] infer desc

        # (for now this is only covered for primitives w/ operations)

        me = self
        @instance_description_proc = -> y do

          bx = me.transitive_capabilities_box

          _st = bx.to_key_stream

          _s_a = _st.join_into [] do |sym|
            Common_::Name.via_variegated_symbol( sym ).as_human
          end

          y << "#{ and_ _s_a } #{ me.name.as_human }"  # ..
        end
        NIL_
      end

      attr_reader :description_proc

      def accept__description__meta_component p
        @description_proc = p
        NIL_
      end

      # ~ name

      def accept__stored_in_ivar__meta_component ivar

        _name_as_ivar_will_be ivar
        NIL_
      end

      def name_symbol
        @name.as_variegated_symbol
      end

      attr_accessor(
        :name,
        :association_method_name,  # where available. (1x [my], 0x here)
      )

      # ~ transitive operation capabilities

      def accept__can__meta_component * i_a  # :Tenet8.

        bx = ( @transitive_capabilities_box ||= Common_::Box.new )
        i_a.each do |sym|
          bx.add sym, :declared
        end
        NIL_
      end

      attr_reader :transitive_capabilities_box

      # ~ default - there is no implementation of this in [ac]. see [#ze-041]

      def accept__default__meta_component x
        @default_proc = -> { x } ; nil
      end

      attr_reader :default_proc

      # ~ model

      def __model_has_operation sym
        @component_model.method_defined? :"__#{ sym }__component_operation"
      end

      attr_accessor :component_model

      # ~ argument arity (and related)

      def accept__is_plural_of__meta_component sym

        @argument_arity = :one_or_more  # hold up [#026]:B
        @singplur_referent_symbol = sym
        @singplur_category = :plural_of ; nil
      end

      def accept__is_singular_of__meta_component sym

        _name_as_ivar_will_be :"@#{ sym }"  # hold up [#026]:A (one side)
        @singplur_referent_symbol = sym
        @singplur_category = :singular_of ; nil
      end

      def accept__flag__meta_component
        @argument_arity = :zero ; nil
      end

      attr_reader(
        :argument_arity,
        :singplur_category,
        :singplur_referent_symbol,
      )

      # ~

      def _name_as_ivar_will_be ivar

        mutate_name = -> nm do
          nm.as_ivar = ivar ; nil
        end

        p = @_name_mutation
        if p
          @_name_mutation = -> nm do
            p[ nm ]
            mutate_name[ nm ]
            NIL_
          end
        else
          @_name_mutation = mutate_name
        end

        NIL_
      end

      # ~ constants

      def formal_node_category
        :association
      end

      # --

      say_etc = nil

      Classify_model___ = -> mdl do

        m = CONSTRUCTOR_METHODS__.detect { | m_ | mdl.respond_to? m_ }

        if m
          NON_PRIMITIVES___.fetch m

        elsif mdl.respond_to? :[]
          LOOKS_LIKE_PROC___
        else
          self._SEE_ME  # #todo -  this is not yet covered but is v. useful
          raise ::ArgumentError, say_etc[ mdl ]
        end
      end

      say_etc = -> mdl do

        _ = CONSTRUCTOR_METHODS__.map { |sym| "`#{ sym }`" }.join ', '
        _ << " or `[]`"
        __ = Home_.lib_.basic::String.via_mixed mdl
        "model is expected to respond to #{ _ } - #{ __ }"
      end

      ENTITESQUE_CONSTRUCTOR_METHOD__ = :interpret_component

      CONSTRUCTOR_METHODS__ = [
        ENTITESQUE_CONSTRUCTOR_METHOD__,
        COMPOUND_CONSTRUCTOR_METHOD_,
      ]

      class Looks_Like__ < ::Module

        def looks_compound
          false
        end

        def looks_entitesque
          false
        end

        def looks_primitivesque
          false
        end
      end

      h = {}

      LOOKS_LIKE_COMPOUND = Looks_Like__.new
      sing = LOOKS_LIKE_COMPOUND
      class << sing

        def construction_method_name
          COMPOUND_CONSTRUCTOR_METHOD_
        end

        def category_symbol
          :compound
        end

        def looks_compound
          true
        end
      end
      h[ sing.construction_method_name ] = sing

      LOOKS_LIKE_ENTITY___ = Looks_Like__.new
      sing = LOOKS_LIKE_ENTITY___
      class << sing

        def construction_method_name
          ENTITESQUE_CONSTRUCTOR_METHOD__
        end

        def category_symbol
          :entitesque
        end

        def looks_entitesque
          true
        end
      end
      h[ sing.construction_method_name ] = sing
      NON_PRIMITIVES___ = h
      h = nil

      LOOKS_LIKE_PROC___ = Looks_Like__.new
      class << LOOKS_LIKE_PROC___

        def category_symbol
          :primitivesque
        end

        def looks_primitivesque
          true
        end
      end
    end

    module By_Ivars

      write = -> x, asc, acs do
        acs.instance_variable_set asc.name.as_ivar, x
        NIL_
      end

      singplur = {
        :plural_of => -> qk, acs do
          x = qk.value
          ::Array.try_convert( x ) or self._SANITY
          write[ x, qk.association, acs ]
        end,
        :singular_of => -> qk, acs do
          write[ [ qk.value ], qk.association, acs ]  # the other side of [#026]
        end,
        nil => -> qk, acs do
          write[ qk.value, qk.association, acs ]
        end
      }

      Value_writer_in = -> acs do
        -> qk do
          singplur.fetch( qk.association.singplur_category )[ qk, acs ]
          NIL_
        end
      end

      Value_reader_in = -> acs do

        -> asc do
          ivar = asc.name.as_ivar
          if acs.instance_variable_defined? ivar
            Common_::KnownKnown[ acs.instance_variable_get ivar ]
          else
            Common_::KNOWN_UNKNOWN
          end
        end
      end
    end

    module Operation
      Autoloader_[ self ]
      Here_ = self
    end

    module Magnetics

      Model_via_Normalization = -> n11n do  # (became #stowaway at #tombstone-3.2)

        -> arg_st, & oes_p_p do

          # interesting conundrum .. we see it as outside of the model's
          # scope to have to know the name etc for the thing it's validating
          # (experimentally)..

          _oes_p = oes_p_p[ nil ]  # there is no entity to link up with

          _kn = Common_::KnownKnown[ arg_st.gets_one ]

          n11n.normalize_knownness _kn do | * i_a, & ev_p |

            # (hi.)
            _oes_p[ * i_a, & ev_p ]
          end
        end
      end

      Autoloader_[ self ]
    end

    module Magnetics_

      Autoloader_[ self ]

      lazily :ModelIndexBySimplicity_via_ModelClass do |c|
        Home_::Magnetics::QualifiedComponent_via_Value_and_Association.const_get c, false
      end
    end

    Reflection_looks_primitive = -> x do
      # `nil` is NOT primitive by this definition!
        case x
        when ::TrueClass, ::Fixnum, ::Float, ::Symbol, ::String  # #[#003.J] trueish
          true
        else
          false
        end
    end

    Stream_ = -> a, & p do
      Common_::Stream.via_nonsparse_array a, & p
    end

    Scanner_ = -> a do
      Common_::Scanner.via_array a
    end

    MissingRequiredParameters = ::Class.new ::ArgumentError
    NotAvailable = ::Class.new ::ArgumentError

    Require_fields_lib_ = Lazy_.call do
      Field_ = Home_.lib_.fields  # idiomatic name
      NIL_
    end

    # --

    RuntimeError = ::Class.new ::RuntimeError

    # --

    module Lib_

      sidesys, stdlib = Autoloader_.at(
        :build_require_sidesystem_proc,
        :build_require_stdlib_proc )

      System = -> do
        System_lib[].services
      end

      Basic = sidesys[ :Basic ]
      Brazen = sidesys[ :Brazen ]
      Fields = sidesys[ :Fields ]
      Human = sidesys[ :Human ]
      JSON = stdlib[ :JSON ]
      System_lib = sidesys[ :System ]
    end

    # --

    ACHIEVED_ = true
    Autoloader_[ ( ACS_ = self ), Common_::Without_extension[ __FILE__ ] ]
    EMPTY_A_ = [].freeze
    EMPTY_P_ = -> { NIL_ }
    Home_ = self
    KEEP_PARSING_ = true
    MONADIC_EMPTINESS_ = -> _ { NIL_ }
    NIL_ = nil
    NIL = nil  # open [#sli-016.C]
      FALSE = false ; TRUE = true
    NOTHING_ = nil
    SPACE_ = ' '.freeze
    UNABLE_ = false
  # -

  def self.describe_into_under y, _
    y << "experiment in independent but cooperative, reactive interface"
    y << "building blocks. the underpinnings of early \"zerk\"."
  end
end
# #tombstone-3.2: lost its own file
# #history-3.1: begin spike of brand new work for [cu] revamp
# #tombstone: `caching_method_based_reader_for`
# #tombstone (maybe) - how parts of this file is/were structured is/was [#bs-039]
