require 'skylab/common'

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

          Home_::Events::ComponentNotFound.with(
            :component, qkn.value_x,
            :component_association, qkn.association,
            :ACS, acs,
          )
        end
        UNABLE_  # important
      end

      def send_component_removed qk, acs, & oes_p

        oes_p.call :info, :component_removed do

          Home_::Events::ComponentRemoved.with(
            :component, qk.value_x,
            :component_association, qk.association,
            :ACS, acs,
          )
        end
        ACHIEVED_
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
    # <-
  class Component_Association

    Reader_of_CAs_by_method_in___ = -> ca_class, acs do

      read_association = nil

      when_no_component_model = -> sym, ca do

        if :plural_of == ca.singplur_category

          ref_sym = ca.singplur_referent_symbol
          _m = Method_name_via_name_symbol[ ref_sym ]
          _sing_ca = read_association[ _m, ref_sym ]
          Home_::Singularize___[ _sing_ca, sym, ca, acs ]
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
      Common_::Known_Known[ st.gets_one ]
    end
  end
  # ->

    COMPOUND_CONSTRUCTOR_METHOD_ = :interpret_compound_component

    class Component_Association

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
          x = qk.value_x
          ::Array.try_convert( x ) or self._SANITY
          write[ x, qk.association, acs ]
        end,
        :singular_of => -> qk, acs do
          write[ [ qk.value_x ], qk.association, acs ]  # the other side of [#026]
        end,
        nil => -> qk, acs do
          write[ qk.value_x, qk.association, acs ]
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
            Common_::Known_Known[ acs.instance_variable_get ivar ]
          else
            Common_::KNOWN_UNKNOWN
          end
        end
      end
    end

    Common_ = ::Skylab::Common
    Autoloader_ = Common_::Autoloader

    module Operation
      Autoloader_[ self ]
      Here_ = self
    end

    module Reflection

      Looks_primitive = -> x do  # `nil` is NOT primitive by this definition!
        case x
        when ::TrueClass, ::Fixnum, ::Float, ::Symbol, ::String  # #[#003.J] trueish
          true
        else
          false
        end
      end

      Autoloader_[ self ]
    end

    Stream_ = -> a, & p do
      Common_::Stream.via_nonsparse_array a, & p
    end

    MissingRequiredParameters = ::Class.new ::ArgumentError
    NotAvailable = ::Class.new ::ArgumentError

    Lazy_ = Common_::Lazy

    Require_fields_lib_ = Lazy_.call do
      Field_ = Home_.lib_.fields  # idiomatic name
      NIL_
    end

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

    ACHIEVED_ = true
    Autoloader_[ ( ACS_ = self ), Common_::Without_extension[ __FILE__ ] ]
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

  def self.describe_into_under y, _
    y << "experiment in independent but cooperative, reactive interface"
    y << "building blocks. the underpinnings of early \"zerk\"."
  end
end
# #tombstone: `caching_method_based_reader_for`
# #tombstone (maybe) - how parts of this file is/were structured is/was [#bs-039]
