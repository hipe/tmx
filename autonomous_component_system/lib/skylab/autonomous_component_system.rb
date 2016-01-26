require 'skylab/callback'

module Skylab::Autonomous_Component_System  # notes in [#002]
  # ->
    class << self

      def create x_a, acs, & oes_p_p  # :Tenet2, (same as below)

        o = _Mutation_Session.new( & oes_p_p )
        o.accept_argument_array x_a
        o.ACS = acs
        o.macro_operation_method_name = :create
        o.execute
      end

      def edit x_a, acs, & oes_p_p  # :Tenet3, [#006]#hot-binding

        o = _Mutation_Session.new( & oes_p_p )
        o.accept_argument_array x_a
        o.ACS = acs
        o.macro_operation_method_name = :edit
        o.execute
      end

      def interpret arg_st, acs, & oes_p_p  # :+Tenet6, [#003]:hb-again

        o = _Mutation_Session.new( & oes_p_p )
        o.ACS = acs
        o.argument_stream = arg_st
        o.macro_operation_method_name = :interpret
        o.execute
      end

      def send_component_already_added cmp, asc, acs, & oes_p

        oes_p.call :error, :component_already_added do

          event( :Component_Already_Added ).new_with(
            :component, cmp,
            :component_association, asc,
            :ACS, acs,
            :ok, nil,  # overwrite so error becomes info
          )
        end
        UNABLE_  # important
      end

      def send_component_not_found cmp, asc, acs, & oes_p

        oes_p.call :error, :component_not_found do

          Home_.event( :Component_Not_Found ).new_with(
            :component, cmp,
            :component_association, asc,
            :ACS, acs,
          )
        end
        UNABLE_  # important
      end

      def send_component_removed cmp, asc, acs, & oes_p

        oes_p.call :info, :component_removed do

          event( :Component_Removed ).new_with(
            :component, cmp,
            :component_association, asc,
            :ACS, acs,
          )
        end
        ACHIEVED_
      end

      def event sym
        Home_.lib_.brazen.event sym
      end

      def _Mutation_Session
        ACS_::Mutation
      end

      def marshal_to_JSON * io_and_options, acs, & pp
        Home_::Modalities::JSON::Marshal[ io_and_options, acs, & pp ]
      end

      def unmarshal_from_JSON acs, cust, io, & x_p
        Home_::Modalities::JSON::Unmarshal[ acs, cust, io, & x_p ]
      end

      def handler_builder_for acs  # for #Hot-eventmodel

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
          Callback_.produce_library_shell_via_library_and_app_modules(
            Lib_, self )
      end
    end  # >>

    Component_Association = ::Class.new

    # how this unit is structured is the subject of the [#bs-039] case study

    Component_Association::Caching_method_based_reader_for___ = -> cls, acs do

      # see [#]how-we-cache-component-associations

      read = Component_Association::Method_based_reader_for__[ cls, acs ]

      h = {}

      -> sym, & else_p do

        x = h.fetch sym do

          x_ = read.call sym do
            NIL_
          end
          # when nil, we munge the detail of how `x_` became that way here.
          h[ sym ] = x_
          x_
        end

        if x
          x
        elsif else_p
          else_p[]
        end
      end
    end

    method_name_for = -> sym do
      :"__#{ sym }__component_association"
    end

    Component_Association::Method_based_reader_for__ = -> ca_class, acs do

      send = -> m, sym do

        ca = nil

        p = -> x do
          ca = ca_class._begin_definition
          p = -> x_a do
            ca.send :"accept__#{ x_a.first }__meta_component", * x_a[ 1..-1 ]
            NIL_
          end
          p[ x ]
        end

        cm = acs.send m do | * x_a |  # :Tenet4.
          p[ x_a ]
        end

        if ca

          if cm
            ca._finish_definition_via cm, sym
          else
            sym_ = ca.is_plural_of
            if sym_
              _m_ = method_name_for[ sym_ ]
              _sing_ca = send[ _m_, sym_ ]
              Home_::Singularize___[ _sing_ca, sym, ca, acs ]
            else
              self._COVER_ME
            end
          end

        elsif cm
          ca_class._begin_definition._finish_definition_via cm, sym

        else
          NIL_  # conditionally turn a whole assoc. off [sa]
        end
      end

      -> sym, & else_p do

        m = method_name_for[ sym ]

        if else_p
          if acs.respond_to? m
            send[ m, sym ]
          else
            else_p[]
          end
        else
          send[ m, sym ]
        end
      end
    end

    COMPOUND_CONSTRUCTOR_METHOD_ = :interpret_compound_component

    class Component_Association

      # assume that the ACS assumes that these structures are produced
      # lazily, on-the-fly, and are not memoized to be used beyond the
      # "moment": they are #dt3 dynamic and should not be #DT4 cached.

      # -- Construction methods

      class << self

        def caching_method_based_reader_for acs
          Caching_method_based_reader_for___[ self, acs ]
        end

        def reader_for acs

          if acs.respond_to? METHOD__
            acs.send METHOD__
          else
            method_based_reader_for acs
          end
        end

        def method_based_reader_for acs
          Method_based_reader_for__[ self, acs ]
        end

        def via_name_and_model nf, mdl

          _begin_definition._init_via nf, mdl
        end

        alias_method :_begin_definition, :new
        private :new
      end  # >>

      METHOD__ = :component_association_reader

      # -- Initializers

      def initialize
        @association_is_available = true
        @_name_mutation = nil
      end

      def _finish_definition_via cm, sym

        nf = Callback_::Name.via_variegated_symbol sym

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

      Classify_model___ = -> mdl do

        m = CONSTRUCTOR_METHODS__.detect { | m_ | mdl.respond_to? m_ }

        if m
          NON_PRIMITIVES___.fetch m

        elsif mdl.respond_to? :[]
          LOOKS_LIKE_PROC___
        else
          self._COVER_ME_model_has_unrecognized_shape
        end
      end

      def say_no_method__

        # assume model does not look like proc - for use in raising e.g a
        # `NoMethodError` regarding an expected but missing construction
        # method. this exists partly because the platform is strange about
        # when it decides to include the class name in the message.

        a = CONSTRUCTOR_METHODS__.dup
        a.push :[]
        _s_a = a.map { | sym | "`#{ sym }`" }
        _or = Callback_::Oxford_or[ _s_a ]

        "must respond to #{ _or } - #{ @component_model.name }"
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

      # -- Expressive event hook-outs

      def description_under _expag
        @name.as_human
      end

      # -- "meta-components" (similar to #[#fi-010] universal meta-properties)

      # ~ availability (mode client must implement)

      def accept__is_available__meta_component yes
        @association_is_available = yes
        NIL_
      end

      attr_reader :association_is_available

      # ~ description

      def accept__generate_description__meta_component  # [#003]#infer-desc

        # (for now this is only covered for primitives w/ operations)

        me = self
        @instance_description_proc = -> y do

          bx = me.transitive_capabilities_box

          _st = bx.to_name_stream

          _s_a = _st.reduce_into_by [] do | m, sym |

            m << Callback_::Name.via_variegated_symbol( sym ).as_human
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

      attr_accessor :name

      # ~ transitive operation capabilities

      def accept__can__meta_component * i_a  # :Tenet8.

        bx = ( @transitive_capabilities_box ||= Callback_::Box.new )
        i_a.each do |sym|
          bx.add sym, :declared
        end
        NIL_
      end

      attr_reader :transitive_capabilities_box

      # ~ default

      def accept__default__meta_component x
        @default_proc = x ; nil
      end

      attr_reader :default_proc

      # ~ model

      def __model_has_operation sym
        @component_model.method_defined? :"__#{ sym }__component_operation"
      end

      attr_accessor :component_model

      # ~ argument arity (and related)

      def accept__is_plural_of__meta_component sym

        @argument_arity = :one_or_more
        @is_plural_of = sym ; nil
      end

      def accept__is_singular_of__meta_component sym

        _name_as_ivar_will_be :"@#{ sym }"
        @is_singular_of = sym ; nil
      end

      attr_reader(
        :argument_arity,
        :is_plural_of,
        :is_singular_of,
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

      def category
        :association
      end

      def sub_category
        :common
      end
    end

    Callback_ = ::Skylab::Callback

    Require_field_library_ = Callback_::Lazy.call do
      Field_ = Home_.lib_.fields  # idiomatic name
      NIL_
    end

    Autoloader_ = Callback_::Autoloader

    module Lib_

      sidesys, stdlib = Autoloader_.at(
        :build_require_sidesystem_proc,
        :build_require_stdlib_proc )

      Basic = sidesys[ :Basic ]
      Brazen = sidesys[ :Brazen ]
      Fields = sidesys[ :Fields ]
      JSON = stdlib[ :JSON ]

      system_lib = sidesys[ :System ]
      System = -> do
        system_lib[].services
      end
    end

    ACHIEVED_ = true
    Autoloader_[ ( ACS_ = self ), Callback_::Without_extension[ __FILE__ ] ]
    EMPTY_A_ = [].freeze
    EMPTY_P_ = -> { NIL_ }
    Home_ = self
    KEEP_PARSING_ = true
    Autoloader_[ Modalities = ::Module.new ]
    MONADIC_EMPTINESS_ = -> _ { NIL_ }
    NIL_ = nil
    NOTHING_ = nil
    SPACE_ = ' '.freeze
    UNABLE_ = false
  # -
end
