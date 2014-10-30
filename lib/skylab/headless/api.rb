module Skylab::Headless

  module API  # read [#017] the API node narrative (was (historical) [#010])

    class << self

      def [] mod, * x_a
        via_client_and_iambic mod, x_a
      end

      def iambic_builder cls
        Iambic_builder[ cls ] ; nil
      end

      def simple_monadic_iambic_writers
        Simple_monadic_iambic_writers
      end

      def via_arglist x_a
        via_client_and_iambic x_a.shift, x_a
      end

      def via_client_and_iambic mod, x_a
        Bundles__.apply_iambic_on_client x_a, mod ; nil
      end
    end

    Headless_.const_get :Library_, false

    module Bundles__
      # ~ in dependency order!
      With_service = -> _ do  # #storypoint-10
        extend Service_Methods_for_Toplevel_Module__ ; nil
      end
      With_session = -> _ do  # #storypoint-15
        extend Session_Methods_for_Toplevel_Module__
        service_class.extend Session_Methods_for_Service_Class__ ; nil
      end
      With_actions = -> _ do  # #storypoint-20
        module_exec( & Touch_dir_patname__ )
        const_set :Actions, ::Module.new
        const_defined?( :Action, false ) or
          const_set :Action, ::Class.new( Iambic_Action__ )
        define_singleton_method :action_class do end  # future-proofing
      end
      Headless_::Lib_::Bundle[]::Multiset[ self ]
    end

    Touch_dir_patname__ = -> do
      Has_dpn__[ self ] or module_exec( & Rslv_Dpn__ )
    end
    Has_dpn__ = -> x do
      x.respond_to? :dir_pathname and x.dir_pathname
    end
    Rslv_Dpn__ = -> do  # #storypoint-25
      parent = Headless_::Lib_::Module_lib[].value_via_relative_path self, '..'
      parent and Has_dpn__[ parent ] or fail "no support for toplevel modules"
      Autoloader_[ self ] ; nil
    end
    module Service_Methods_for_Toplevel_Module__
      def invoke * x_a  # :+[#sl-121] the standard façade
        x_a.unshift :action_locator_x
        svc_singleton.invoke_with_iambic x_a  # #storypoint-30
      end
      def invoke_with_iambic x_a
        x_a.unshift :action_locator_x
        svc_singleton.invoke_with_iambic x_a
      end
    private
      # [#117] de-vowelated names mean something
      def svc_singleton
        @svc_singl ||= bld_service
      end
      def bld_service
        service_class.new
      end
      def service_class
        if const_defined? :Service, false
          const_get :Service
        else
          const_set :Service, bld_service_class
        end
      end
      def bld_service_class
        toplevel_module = self
        ::Class.new.class_exec do
          include Service_Instance_Methods__
          const_set :API_MODULE, toplevel_module
          self
        end
      end
    end

    module Service_Instance_Methods__
      def invoke_with_iambic x_a
        x_a.unshift :service, self
        sssn_cls.new( x_a ).execute
      end
      def sssn_cls
        self.class.session_cls
      end
    end

    module Session_Methods_for_Service_Class__
      def session_cls
        tplvl_module.session_class
      end
    private
      def tplvl_module
        const_get :API_MODULE, false
      end
    end

    module Session_Methods_for_Toplevel_Module__
      def session_class
        if const_defined? :Session, false
          const_get :Session
        else
          const_set :Session, bld_session_class
        end
      end
    private
      def bld_session_class
        toplevel_module = self
        ::Class.new.class_eval do
          include Session_Instance_Methods__
          const_set :API_MODULE, toplevel_module
          self
        end
      end
    end

    SUI_ = :say_unexpected_iambic

    Say_unexpected_iambic_ = -> do
      "unexpected iambic term #{ Headless_::Lib_::Strange[ @x_a[ 0 ] ] }"
    end

    module Simple_monadic_iambic_writers  # :[#130].

      class << self

        def [] * x_a
          via_arglist x_a
        end

        def via_arglist x_a
          via_client_and_symlist x_a.shift, x_a
        end

        def via_client_and_symlist mod, i_a
          mod.module_exec i_a, & Bundle__
        end
      end

      Bundle__ = -> i_a do
        module_exec i_a, & Define_writers__
        include Absorbtion_Methods__
      end
      Define_writers__ = -> i_a do
        i_a.each do |i|
          wmeth_i = :"#{ i }=" ; ivar = :"@#{ i }"
          define_method wmeth_i do
            instance_variable_set ivar, @x_a.shift ; nil
          end ; private wmeth_i
        end ; nil
      end

      Absorb_iambic_passively__ = -> x_a do
        @x_a = x_a
        white_p = self.class.method :private_method_defined?
        while x_a.length.nonzero?
          white_p[ i = :"#{ x_a.first }=" ] or break
          x_a.shift
          send i
        end ; nil
        # leave @x_a as set
      end

      module Absorbtion_Methods__
        _AIP = :absorb_iambic_passively
        define_method _AIP, Absorb_iambic_passively__
        private _AIP
      private
        def absorb_iambic_fully x_a
          absorb_iambic_passively x_a
          @x_a.length.zero? or raise ::ArgumentError, say_unexpected_iambic
          @x_a = nil
        end
        define_method SUI_, Say_unexpected_iambic_ ; private SUI_
      end
    end

    Reflective_Iambic_ = ::Module.new
    Reflective_Iambic_::Enhance = ::Class.new

    module Iambic_parameters

      def self.[] mod, * x_a
        Enhance__.new( mod, x_a ).execute
      end

      class Enhance__ < Reflective_Iambic_::Enhance

        Simple_monadic_iambic_writers[ self ]
      private
        def params=
          @params = @x_a ; @x_a = EMPTY_A_ ; nil
        end
        def reflection_method_stem=
          @reflection_mthd_stem_i = @x_a.shift ; nil
        end

        def initialize cls, x_a
          absorb_iambic_fully x_a
          @reflection_mthd_stem_i ||= :parameter
          @mod = cls ; @sing = cls.singleton_class
          @DSL_meth_i = false
          super()
        end
      public
        def execute
          super
          Reflective_Iambic_::Parameter_Definition_Edit_Session.
            new( @mod, @params ).execute
        end
      end
    end

    module Iambic_parameters_DSL

      def self.[] mod, * x_a
        Enhance__.new( mod, x_a ).execute
      end

      class Enhance__ < Reflective_Iambic_::Enhance

        Simple_monadic_iambic_writers[ self ]
      private
        def DSL_writer_method_name=
          @DSL_meth_i = @x_a.shift ; nil
        end
        def reflection_method_stem=
          @reflection_mthd_stem_i = @x_a.shift ; nil
        end

        def initialize cls, x_a
          @mod = cls ; @sing = cls.singleton_class
          absorb_iambic_fully x_a
          @DSL_meth_i or raise ::ArgumentError, say_expecting_DSL_writer_mn
          @sing.private_method_defined? @DSL_meth_i and fail say_already_enh
          @reflection_mthd_stem_i ||= @DSL_meth_i
          nil
        end
        def say_expecting_DSL_writer_mn
          "expecting 'DSL_writer_method_name'"
        end
        def say_already_enh
          "already enhanced with DSL?"
        end
      end
    end

    module Iambic_builder  # (as a happy accident, mirrors Iambic_parameters)

      def self.[] mod
        mod.extend Iambic_builder
      end

      def [] mod, * x_a
        Enhance__.new( self, mod, x_a ).execute
      end

      class Enhance__ < Reflective_Iambic_::Enhance

        Simple_monadic_iambic_writers[ self ]
      private
        def params=
          @params = @x_a ; @x_a = EMPTY_A_ ; nil
        end

        def initialize builder, cls, x_a
          absorb_iambic_fully x_a
          @builder = builder ; @mod = cls ; @sing = @mod.singleton_class
          @DSL_meth_i = false
          @reflection_mthd_stem_i ||= :parameter
          super()
        end
      public
        def execute
          super
          Reflective_Iambic_::Parameter_Definition_Edit_Session.
            new( @mod, @params ).execute
        end
      private
        def apply_instance_methods
          @mod.send :include, @builder.const_get( :Instance_Methods, false )
          nil
        end
      end

    private

      def parameter_class
        if const_defined? PCLASS_, false
          const_get PCLASS_, false
        else
          init_prmtr_class
        end
      end

      def init_prmtr_class
        cls = const_set PCLASS_, ::Class.new( Reflective_Iambic_::Parameter )
        cls.const_set PARSE_CLASS_,
          ::Class.new( Reflective_Iambic_::Parameter__Parse )
        cls
      end

      def parameter__parse_class
        parameter_class.const_get PARSE_CLASS_, false
      end

      def instance_methods_module
        if const_defined? :Instance_Methods, false
          self::Instance_Methods
        else
          init_instnc_methods
        end
      end

      def init_instnc_methods
        mod = const_set :Instance_Methods, ::Module.new
        mod.module_exec do
          include Reflective_Iambic_::Constants_and_Absorbtion_Methods
          self
        end
      end
    end

    PCLASS_ = :Parameter
    PARSE_CLASS_ = :Parse
    RMETH_ = :REFLECTIVE_IAMBIC_PARAMETER_REFLECTION_METHOD_STEM_I___

    module Reflective_Iambic_
      class Enhance
        def execute
          apply_instance_methods
          apply_module_methods
        end
      private
        def apply_instance_methods
          @mod.send :include, Constants_and_Absorbtion_Methods__ ; nil
        end
        def apply_module_methods
          @sing.send :include, MM__
          apply_rdr_module_methods_and_constants
          @DSL_meth_i and apply_writer_module_methods ; nil
        end
        def apply_rdr_module_methods_and_constants
          rmeth_i = @reflection_mthd_stem_i
          @mod and @mod.const_set RMETH_, rmeth_i
          @sing.class_exec do
            define_method :"fetch_#{ rmeth_i }", Fetch_parameter__
            define_method :"#{ rmeth_i }_members", Parameter_members__
            module_exec :"#{ rmeth_i }s", & Define_enumerator_method__
            define_method :"get_#{ rmeth_i }_box", Get_box__
            define_method :"get_#{ rmeth_i }_scanner", Get_scanner__
          end ; nil
        end
        def apply_writer_module_methods
          wmeth_i = @DSL_meth_i
          @sing.class_exec do
            define_method wmeth_i, Parameter_definition_edit_session__
            private wmeth_i
          end ; nil
        end
      end

      module MM__
        def prototype_parameter
          self::PROTOTYPE_PARAMETER
        end
      private
        def parameter_class_for_edit
          if const_defined? PCLASS__, false
            const_get PCLASS__
          else
            init_prmtr_class_for_edit
          end
        end
        def init_prmtr_class_for_edit
          base_parameter = const_get PCLASS__
          new_parameter = ::Class.new base_parameter
          base_parse = base_parameter.const_get PARSE_CLASS__, false
          new_parse = ::Class.new base_parse
          new_parameter.const_set PARSE_CLASS__, new_parse
          const_set PCLASS__, new_parameter
        end
      end

      PCLASS__ = PCLASS_
      PARSE_CLASS__ = PARSE_CLASS_

      Nilify_and_absorb_iambic_passively__ = -> x_a do
        set = Library_::Set.new self.class.const_get CONST_A__
        h = self.class.const_get CONST_H__
        @x_a = x_a
        while x_a.length.nonzero?
          (( param_meth_i = h[ x_a.first ] )) or break
          x_a.shift
          param = self.class.send param_meth_i
          set.delete param.param_i
          send param.iambic_writer_method_name
        end
        set.each do |i|
          param = self.class.send h.fetch( i )
          _x = ( param.default_proc[] if param.has_default )
          instance_variable_set param.ivar, _x
        end
        nil
      end

      module Constants_and_Absorbtion_Methods__
      private
        def nilify_and_absorb_iambic_fully x_a
          nilify_and_absorb_iambic_passively x_a
          @x_a.length.zero? or raise ::ArgumentError, say_unexpected_iambic
          @x_a = nil
        end

        _NAAIP = :nilify_and_absorb_iambic_passively
        define_method _NAAIP, Nilify_and_absorb_iambic_passively__
        private _NAAIP

        define_method SUI_, Say_unexpected_iambic_ ; private SUI_
      end

      Parameter_definition_edit_session__ = -> * x_a do
        Parameter_Definition_Edit_Session.new( self, x_a ).execute ; nil
      end

      class Parameter_Definition_Edit_Session
        def initialize cls, x_a
          @mod = cls ; @x_a = x_a
        end
        def execute
          begin_mutable_a_and_h
          @x_a.length.zero? or absorb_nonzero_length_parameter_definition
          end_mutable_a_and_h
          nil
        end
      private
        def begin_mutable_a_and_h
          @mutable_a = @mod.module_exec( & Resolve_writable_a__ )
          @mutable_h = { } ; nil
        end
        def absorb_nonzero_length_parameter_definition
          _accepter = @mod.module_exec @mutable_a, @mutable_h, &
            Build_parameter_definition_accepter__
          Absorb_nonzero_length_parameter_definitions__[
            _accepter, get_parameter_builder_p, @x_a ]
          nil
        end
        def get_parameter_builder_p
          @mod.prototype_parameter.method :dupe
        end
        def end_mutable_a_and_h
          a = @mutable_a ; h = @mutable_h
          if a.length != h.length
            ( a - h.keys ).each do |i|
              h[ i ] = Long_name__[ i ]
            end
          end
          @mod.module_exec do
            const_set CONST_A__, a.freeze ; const_set CONST_H__, h.freeze
          end ; nil
        end
      end

      Resolve_writable_a__ = -> do
        if const_defined? CONST_A__
          const_defined? CONST_A__, false and raise Say_cannot_reopen__[ name ]
          const_get( CONST_A__ ).dup
        else [] end
      end

      Absorb_nonzero_length_parameter_definitions__ = -> accept_p, bld_p, x_a do
        param_i = x_a.shift ; next_x = nil
        begin
          is_more = x_a.length.nonzero?
          _param = bld_p.call do |parm|
            parm.param_i = param_i
            if is_more and (( next_x = x_a.shift )).respond_to? :shift
              parm.absorb_iambic next_x
              is_more = x_a.length.nonzero? and next_x = x_a.shift
            end
          end
          accept_p[ _param ]
          is_more or break
          param_i = next_x
        end while true ; nil
      end

      Say_cannot_reopen__ = -> name do
        "parameters edit session is write-once. #{
          }cannot re-open parameters definition for #{ name }"
      end

      Build_parameter_definition_accepter__ = -> a, h do
        -> param do
          h.fetch param.param_i do |i|
            meth_i = Long_name__[ i ]
            a << i ; h[ i ] = meth_i
            define_singleton_method meth_i do param end
            if param.has_generated_writer
              module_exec param, & Write_appropriate_writer__
            end ; nil
          end and raise "sanity - collision? - #{ param.param_i }"
        end
      end

      Long_name__ = -> i { :"frozen_#{ i }_parameter" }
      CONST_A__ = :INHERITED_PARAMETER_I_A___
      CONST_H__ = :INHERITED_PARAMETER_H___

      Write_appropriate_writer__ = -> param do
        wmeth_i = :"#{ param.param_i }="
        _p = param.write_p || Appropriate_writer_for__.
          fetch( param.argument_arity_i )
        _p_ = _p[ param ]
        define_method wmeth_i, _p_
        private wmeth_i ; nil
      end

      Appropriate_writer_for__ = {
        one: -> param do
          ivar = param.ivar
          -> do
            instance_variable_set ivar, @x_a.shift ; nil
          end
        end,
        zero: -> param do
          ivar = param.ivar
          -> do
            instance_variable_set ivar, true ; nil
          end
        end }.freeze

      Define_enumerator_method__ = -> meth_i do
        define_method meth_i do |& p|
          if p
            a = const_get CONST_A__ ; h = const_get CONST_H__
            d = -1 ; last = a.length - 1
            while d < last
              p[ send h.fetch( a.fetch( d += 1 ) ) ]
            end ; nil
          else
            to_enum meth_i
          end
        end
      end

      Fetch_parameter__ = -> param_i, & any_else_p do
        did_find = true
        meth_i = const_get( CONST_H__ ).fetch param_i do did_find = false end
        if did_find
          send meth_i
        elsif any_else_p
          any_else_p[ param_i ]
        else
          raise ::NameError, module_exec( param_i, & Say_fetch_param_name_er__ )
        end
      end
      #
      Say_fetch_param_name_er__ = -> param_i do

        inspect_p = Headless_::Lib_::Strange

        _phrase = Headless_::Lib_::Levenshtein[].with(
          :item, param_i,
          :closest_N_items, A_FEW__,
          :items, const_get( CONST_A__ ),
          :aggregation_proc, -> a do
            a * ' or '
          end,
          :item_proc, inspect_p )

        _rmeth_i = const_get RMETH_

        _n = Headless_::Name.naturalize _rmeth_i
        "there is no such #{ _n } #{ inspect_p[ param_i ] } - #{
          }did you mean #{ _phrase }?"
      end
      A_FEW__ = 3

      Get_box__ = -> do
        a = const_get CONST_A__ ; h = const_get CONST_H__
        h_ = ::Hash[ a.map { |i| [ i, send( h[ i ] ) ] } ]
        Headless_::Lib_::Meso_box_lib[].from_a_and_h a, h_
      end

      Get_scanner__ = -> do
        a = const_get CONST_A__ ; h = const_get CONST_H__
        d = -1 ; last = a.length - 1
        Scn_.new do
          send h.fetch( a.fetch( d += 1 ) ) if d < last
        end
      end

      Parameter_members__ = -> do
        const_get CONST_A__
      end

      class Parameter__  # :[#030], :+[#mh-053]
        def initialize
          yield self
          freeze
        end
        def dupe
          yield(( otr = dup ))
          otr.freeze
        end
        attr_accessor :argument_arity_i, :default_proc, :has_default,
          :has_generated_writer, :ivar, :write_p
        attr_reader :iambic_writer_method_name, :param_i
        def param_i= i
          @iambic_writer_method_name = :"#{ i }="
          @ivar = :"@#{ i }"
          @param_i = i
        end
        def absorb_iambic x_a
          self.class.const_get( PARSE_CLASS__, false ).new( self, x_a ).execute
          nil
        end
      end

      class Parameter__Parse__
        def initialize param, x_a
          @param = param ; @x_a = x_a ; nil
        end
        def execute
          begin
            send :"#{ @x_a.shift }="
          end while @x_a.length.nonzero? ; nil
        end
      private
        def argument_arity=
          @param.argument_arity_i = @x_a.shift ; nil
        end
        def default=
          @param.has_default = true
          x = @x_a.shift
          @param.default_proc = -> { x } ; nil
        end
        def has_custom_writer=
          @param.has_generated_writer = false ; nil
        end
        def ivar=
          @param.ivar = @x_a.shift ; nil
        end
        def write_with=
          @param.write_p = @x_a.shift ; nil
        end
        freeze
      end

      Parameter__.const_set PARSE_CLASS__, Parameter__Parse__
      Parameter__.freeze

      module Constants_and_Absorbtion_Methods__
        const_set PCLASS__, Parameter__
        PROTOTYPE_PARAMETER = Parameter__.new do |param|
          param.argument_arity_i = :one
          param.has_generated_writer = true
        end
      end

      Constants_and_Absorbtion_Methods = Constants_and_Absorbtion_Methods__
      Parameter = Parameter__
      Parameter__Parse = Parameter__Parse__
    end

    module Session_Instance_Methods__

      Simple_monadic_iambic_writers[ self,
        :action_locator_x, :errstream, :service, :unbound_action_box ]

      # [#117] de-vowelated names mean something

      def initialize x_a
        absorb_iambic_passively x_a
        rslv_errstream
        rslv_unbound_action_box ; nil
      end
    private
      def rslv_errstream
        @errstream ||= Headless_.system.IO.some_stderr_IO ; nil
      end
      def rslv_unbound_action_box
        @unbound_action_box ||= self.class::API_MODULE::Actions
      end
    public
      def execute
        rslv_bound_action_trio and @bound_action.send @method_name, * @args
      end
    private
      def rslv_bound_action_trio
        @unbound_action = any_unbnd_action
        @unbound_action and rslv_bound_action_trio_from_unbound_action
      end
      def any_unbnd_action
        Autoloader_.const_reduce do |cr|
          cr.const_path [ @action_locator_x ]
          cr.from_module @unbound_action_box
          cr.else_p method :unbnd_action_not_found
        end
      end
      def unbnd_action_not_found name_error
        raise ::NameError, say_nm_error( name_error )
      end
      def say_nm_error name_error
        "cannot \"#{ name_error.name }\" - there is no such constant #{
          }#{ name_error.module.name }::( ~ #{ name_error.name } )"
      end
      def rslv_bound_action_trio_from_unbound_action
        if @unbound_action.respond_to? :[]
          rlsv_bound_action_trio_from_proc_looking_unbound_action
        else
          rslv_bound_action_trio_from_unbound_action_that_looks_like_class
        end
      end
      def rslv_bound_action_trio_from_unbound_action_that_looks_like_proc
        @bound_action = @unbound_action
        @method_name = :[]
        @args = @x_a ; @x_a = nil
        true
      end
      def rslv_bound_action_trio_from_unbound_action_that_looks_like_class
        add_ancllry_parameters_to_the_iambic
        rslv_bound_action
        @method_name = :execute
        @args = EMPTY_A_
        true
      end
      def add_ancllry_parameters_to_the_iambic
        @x_a.unshift :errstream, @errstream, :service, @service, :session, self
        nil
      end
      def rslv_bound_action
        x_a = @x_a ; @x_a = nil
        @bound_action = @unbound_action.new x_a ; nil
      end
    end

    class Iambic_Action__

      Iambic_parameters_DSL[ self, :DSL_writer_method_name, :params,
                                   :reflection_method_stem, :parameter ]

      params :errstream, :service, :session

      def initialize x_a=nil
        x_a and nilify_and_absorb_iambic_fully x_a
        super()
      end
      def say_unexpected_iambic
        "#{ super } for \"#{ self.class.name_function.as_natural }\" action"
      end
      class << self
        def name_function
          @name_function ||= bld_name_function
        end
        def bld_name_function
          Headless_::Name.via_const.via_module_name name
        end
      end
    end

    Iambic_Action = Iambic_Action__

    module Client  # #todo:during-merge
      module InstanceMethods
      end
    end
    RuntimeError = ::RuntimeError
    module Pen
      module InstanceMethods
      end
    end
  end
end
