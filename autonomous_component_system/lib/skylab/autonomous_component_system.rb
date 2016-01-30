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

      def send_component_already_added qk, acs, & oes_p

        oes_p.call :error, :component_already_added do

          event( :Component_Already_Added ).new_with(
            :component, qk.value_x,
            :component_association, qk.association,
            :ACS, acs,
            :ok, nil,  # overwrite so error becomes info
          )
        end
        UNABLE_  # important
      end

      def send_component_not_found qkn, acs, & oes_p

        oes_p.call :error, :component_not_found do

          Home_.event( :Component_Not_Found ).new_with(
            :component, qkn.value_x,
            :component_association, qkn.association,
            :ACS, acs,
          )
        end
        UNABLE_  # important
      end

      def send_component_removed qk, acs, & oes_p

        oes_p.call :info, :component_removed do

          event( :Component_Removed ).new_with(
            :component, qk.value_x,
            :component_association, qk.association,
            :ACS, acs,
          )
        end
        ACHIEVED_
      end

      def event sym
        Home_.lib_.brazen.event sym
      end

      def _Mutation_Session
        ACS_::Mutation_Session___
      end

      def marshal_to_JSON * io_and_options, acs, & pp
        Home_::Modalities::JSON::Marshal[ io_and_options, acs, & pp ]
      end

      def unmarshal_from_JSON acs, cust, io, & pp
        Home_::Modalities::JSON::Unmarshal[ acs, cust, io, & pp ]
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
    # <-
  class Component_Association

    Reader_of_CAs_by_method_in___ = -> ca_class, acs do

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
          else
            sym_ = ca.is_plural_of
            if sym_
              _m_ = Method_name_via_name_symbol[ sym_ ]
              _sing_ca = read_association[ _m_, sym_ ]
              Home_::Singularize___[ _sing_ca, sym, ca, acs ]
            else
              self._COVER_ME
            end
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
  end
  # ->

    COMPOUND_CONSTRUCTOR_METHOD_ = :interpret_compound_component

    class Component_Association

      # assume that the ACS assumes that these structures are produced
      # lazily, on-the-fly, and are not memoized to be used beyond the
      # "moment": they are #dt3 dynamic and should not be #DT4 cached.

      class << self

        def reader_of_component_associations_by_method_in acs
          Reader_of_CAs_by_method_in___[ self, acs ]
        end

        alias_method :_begin_via_method_name, :new
        private :new
      end  # >>

      # -- Initializers

      def initialize m
        @association_is_available = true
        @association_method_name = m
        @_name_mutation = nil
      end

      def _finish_via cm, sym

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

      attr_accessor(
        :name,
        :association_method_name,  # where available. (1x [my], 0x here)
      )

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

      # --

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

      Value_writer_in = -> acs do

        -> qk do
          if qk.is_known_known
            acs.instance_variable_set qk.name.as_ivar, qk.value_x
          else
            self._NEVER_BEEN_NEEDED
          end
          NIL_
        end
      end

      Value_reader_in = -> acs do

        -> asc do
          ivar = asc.name.as_ivar
          if acs.instance_variable_defined? ivar
            Callback_::Known_Known[ acs.instance_variable_get ivar ]
          else
            Callback_::KNOWN_UNKNOWN
          end
        end
      end
    end

    Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

    module Operation
      Autoloader_[ self ]
      Here_ = self
      Request_for_Deliverable_ = -> * a { a }
    end

    module Reflection
      Autoloader_[ self ]
    end

    Lazy_ = Callback_::Lazy

    Require_field_library_ = Lazy_.call do
      Field_ = Home_.lib_.fields  # idiomatic name
      NIL_
    end

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
# #tombstone: `caching_method_based_reader_for`
# #tombstone (maybe) - how parts of this file is/were structured is/was [#bs-039]
